# Extrair informações de tabela no SAP Hana

 O objetivo desse script é auxiliar colaboradores que não tem familiaridade com o Hana Studio e com consultas utilizando SQL a extrair informações massivamente de tabelas do SAP Hana.
 
 O modelo foi elaborado para extrair informações de pagamento dos clientes a partir de um indentificador (conta contrato, nesse exemplo). Os números das contas contratos são inseridos no arquivo de texto "Contas_contratos.txt" e o script pode então ser executado. Serão solicitados usuário e senha para o servidor no qual se encontra a tabela e o resultado é inserido em um novo arquivo de texto, que será salvo na área de trabalho com o nome "parcelamento.txt".
 
 Os nomes do schema, da tabela e as informações do servidor são apenas ilustrativos.
 
