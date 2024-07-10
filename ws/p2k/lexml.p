DEFINE VARIABLE lOK      AS LOGICAL NO-UNDO.  

def temp-table parcelas
    field c_recid as recid  XML-NODE-TYPE "Hidden"
    field seq_parcela as char
    field vlr_parcela as char
    field venc_parcela as char.
DEFINE TEMP-TABLE contratos no-UNDO 
    field c_recid as recid XML-NODE-TYPE "Hidden"
    FIELD codigo_cliente         AS CHARACTER 
    FIELD numero_contrato         AS CHARACTER .

Define Temp-Table DataFuturaPagamentoPrestacao no-undo
    field c_recid as recid XML-NODE-TYPE "Hidden"  
    field codigo_filial as character 
    field codigo_operador as character
    field data_futura_pagamento as char.
    
DEFINE DATASET DATA xml-node-name "DataFuturaPagamentoPrestacao"
    FOR DataFuturaPagamentoPrestacao , contratos, parcelas
    data-relation dr1 for DataFuturaPagamentoPrestacao, contratos relation-fields(c_recid, c_recid) nested
    data-relation dr2 for contratos, parcelas relation-fields(c_recid, c_recid) nested.


DATASET DATA:READ-XML("file", "xx.xml", "empty", ?, FALSE, ?, "ignore") .

/*
lOk = DATASET DATA:READ-XML("file",                /* SourceType             */ 
                            "./xx.xml",
                            "append",              /* ReadMode               */ 
                            ?,                     /* SchemaLocation         */ 
                            ?,                     /* OverrideDefaultMapping */ 
                            ?,                     /* FieldTypeMapping       */ 
                            ?).                    /* VerifySchemaMode       */  
  */
  
for each datafuturapagamentoprestacao.
disp datafuturapagamentoprestacao.
 end.
 for each contratos .
 disp contratos.
for each parcelas where parcelas.c_recid = contratos.c_recid.
    disp parcelas.
    end.
end.

/*
DEFINE TEMP-TABLE ttExportTableDataResult NO-UNDO XML-NODE-NAME "ExportTableDataResult"
    FIELD c_recid AS RECID XML-NODE-TYPE "Hidden".

DEFINE TEMP-TABLE ttRoot NO-UNDO XML-NODE-NAME "root"
    FIELD c_recid AS RECID XML-NODE-TYPE "Hidden"
    FIELD xmlns   AS CHARACTER XML-NODE-TYPE "Attribute".

DEFINE TEMP-TABLE ttTable NO-UNDO XML-NODE-NAME "table"
    FIELD tablename AS CHARACTER XML-NODE-TYPE "Attribute" XML-NODE-NAME "name"
    FIELD c_recid   AS RECID XML-NODE-TYPE "Hidden".

DEFINE TEMP-TABLE ttR NO-UNDO XML-NODE-NAME 'r' 
    FIELD c_recid AS RECID     XML-NODE-TYPE "Hidden".

DEFINE TEMP-TABLE ttMessageTypeCode NO-UNDO XML-NODE-NAME 'c'
    FIELD cName                AS CHARACTER XML-NODE-TYPE "Attribute" XML-NODE-NAME "name"
    FIELD ElementValue         AS CHARACTER XML-NODE-TYPE "Text"
    FIELD c_recid AS RECID     XML-NODE-TYPE "Hidden".

DEFINE DATASET dsReceiverInfo XML-NODE-NAME 'ExportTableDataResponse'
    FOR  ttExportTableDataResult, ttRoot, ttTable, ttR, ttMessageTypeCode
    DATA-RELATION dr1 FOR ttExportTableDataResult, ttRoot RELATION-FIELDS(c_recid, c_recid) NESTED
    DATA-RELATION dr2 FOR ttRoot, ttTable RELATION-FIELDS(c_recid, c_recid) NESTED
    DATA-RELATION dr3 FOR ttTable, ttR RELATION-FIELDS(c_recid, c_recid) NESTED
    DATA-RELATION dr4 FOR ttR, ttMessageTypeCode RELATION-FIELDS(c_recid, c_recid) NESTED
    .

/* Removing NO-ERROR - so it will crash instead if there's an error! */
DATASET dsReceiverInfo:READ-XML("file", "c:\temp\dataset.xml", "empty", ?, FALSE, ?, "ignore") .

FOR EACH ttMessageTypeCode:
    DISP ttMessageTypeCode.ElementValue FORMAT "X(30)"
         ttMessageTypeCode.cName
         ttMessageTypeCode.c_recid.
END.
/* Saving the dataset for comparison (you will see that some root-level data is missing) */
DATASET dsReceiverInfo:WRITE-XML("file", "c:\temp\dataset_new.xml") .
  */
