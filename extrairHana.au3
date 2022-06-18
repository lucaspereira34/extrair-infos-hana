#include <File.au3>
#include <Array.au3>

If FileExists(@desktopdir & "/parcelamento.txt") Then
   FileDelete(@desktopdir & "/parcelamento.txt")
EndIf

; Usuário e senha SAP HANA

   Local $sUser = InputBox("LOGIN HANA", "Insira o seu usuário do SAP HANA:")
   Local $sPassword = InputBox("LOGIN HANA", "Insira a sua senha do SAP HANA:")

; Contas contratos a serem consultadas
   Local $aConta_contrato = FileReadToArray(@DesktopDir & '\Contas_contratos.txt')

; Numero de contas contratos a serem consultadas
   Local $iNumero_CCs = UBound($aConta_contrato, $UBOUND_ROWS)

; Ajuste dos strings das Contas Contratos para a leitura SQL

For $i = 0 to $iNumero_CCs - 1
   ; Caso a string contenha mais de 12 dígitos ou caracteres diferentes de 0-9, interrompe o script e informa a contra contrato errada
	  If StringLen($aConta_contrato[$i]) > 12 or StringIsDigit($aConta_contrato[$i]) = 0 Then
		 MsgBox(0, "Erro", "Conta contrato inválida: " & $aConta_contrato[$i] ". Retire-a do arquivo ou corrija e execute o arquivo novamente.")
	  EndIf

   ; Caso a string de Conta Contrato possua menos que 12 dígitos, preenche a string com 0's até atingir os 12 dígitos
	  If StringLen($aConta_contrato[$i]) < 12 Then
		 For $j = StringLen($aConta_contrato[$i]) to 11
			$aConta_contrato[$i] = '0' & $aConta_contrato[$i]
		 Next
	  EndIf

   ; Adiciona as aspas simples e as vírgulas
	  If $i <> $iNumero_CCs -1 Then
		 $aConta_contrato[$i] = "'" & $aConta_contrato[$i] & "',"
	  Else
		 $aConta_contrato[$i] = "'" & $aConta_contrato[$i] & "'"
	  EndIf
Next

; Criação do Batch SQL

   Local $aSQL_bat[$iNumero_CCs + 8]

   $aSQL_bat[0] = 'SELECT DISTINCT'
   $aSQL_bat[2] = 'ACC AS CONTA_CONTRATO, FAT AS FATURA, PARC AS PARCELAMENTO, REAL AS DT_VENCIMENTO, SUM(MNT) AS MONTANTE'
   $aSQL_bat[4] = 'FROM SCHEMA.TABLE WHERE ACC IN ('

   For $i = 5 to $iNumero_CCs + 4
	  $aSQL_bat[$i] = $aConta_contrato[$i-5]
   Next

   $aSQL_bat[$iNumero_CCs + 5] = ')'
   $aSQL_bat[$iNumero_CCs + 7] = 'GROUP BY ACC, FAT, PARC, REAL'

   _FileWriteFromArray(@MyDocumentsDir & "\sql_bat.bat", $aSQL_bat)

; Criação do batch que conecta ao servidor Hana e executa o Batch SQL

   Local $aHdbsql_bat[1]

     $aHdbsql_bat[0] = '"C:\Program Files\sap\hdbclient\hdbsql" -n server -i instancenumber -u ' & $sUser & ' -p ' & $sPassword & ' -I "' & @MyDocumentsDir &'\sql_bat.bat" -o "' & @MyDocumentsDir &'\extract.txt"'

   _FileWriteFromArray(@MyDocumentsDir & "\extrair.bat", $aHdbsql_bat)

; Executa o batch criado na ultima linha

   Sleep(1000)
   RunWait(@MyDocumentsDir & "\extrair.bat")

; Lê o output do SQL
   Sleep(3000)

   Local $aExtract
   _FileReadToArray(@MyDocumentsDir & "\extract.txt", $aExtract, "Default", ",")

   ; Ajuste dos dados do output do SQL
   For $i = 1 to UBound($aExtract, $UBOUND_ROWS) - 1
	  $aExtract[$i][0] = StringReplace($aExtract[$i][0], '"', '')
	  $aExtract[$i][1] = StringReplace($aExtract[$i][1], '"', '')
	  $aExtract[$i][3] = StringReplace(StringReplace($aExtract[$i][3], '"', ''), '-', '/')
	  $aExtract[$i][4] = StringReplace($aExtract[$i][4], '.', ',')
   Next

; Insere os dados do output do SQL em um arquivo txt
   _FileWriteFromArray(@DesktopDir & "\parcelamento.txt", $aExtract, Default, Default, ';')

If FileExists(@DesktopDir & "parcelamento.txt") Then
   MsgBox(0, "Aviso", 'A extração foi realizada com sucesso! Os dados estão no arquivo "parcelamento.txt" em sua área de trabalho')
Else
   MsgBox(0, "Aviso", 'Erro ao realizar extração. Verifique se você inseriu o usuário e senhas ativas para o SAP HANA ou se houve algum erro no preenchimento das contas contratos.')
EndIf