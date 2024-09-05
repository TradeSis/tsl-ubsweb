using Progress.Json.ObjectModel.JsonObject.
using Progress.Json.ObjectModel.JsonArray.
using Progress.Json.ObjectModel.ObjectModelParser.

def input param vlcentrada as longchar. /* JSON ENTRADA */
//def input param vtmp       as char.     /* CAMINHO PROGRESS_TMP */

define VARIABLE omParser  as ObjectModelParser no-undo.
define variable joEntrada  AS JsonObject no-undo.
define variable jadet  AS JsonArray no-undo.
define variable jodet  AS JsonObject no-undo.


DEFINE VARIABLE lcOffers    AS LONGCHAR NO-UNDO.
DEFINE VARIABLE lcTaxes    AS LONGCHAR NO-UNDO.


DEFINE VARIABLE joOffers       AS JsonObject NO-UNDO.
DEFINE VARIABLE jaOffers       AS JsonArray NO-UNDO.
DEFINE VARIABLE jaDebts       AS JsonArray NO-UNDO.
DEFINE VARIABLE joDebts       AS JsonObject NO-UNDO.
DEFINE VARIABLE joCompany       AS JsonObject NO-UNDO.
DEFINE VARIABLE joCompanyOrigin       AS JsonObject NO-UNDO.



def var vlcsaida   as longchar.         /* JSON SAIDA */

def var lokjson as log.                 /* LOGICAL DE APOIO */
def var hentrada as handle.             /* HANDLE ENTRADA */
def var hsaida   as handle.             /* HANDLE SAIDA */

/* MODELO DADOS ENTRADA
{
  "document": "23599482020",
  "offer_id": "8d4b3cc7-5020-4c57-aa76-52eb9f28ab2a"
}
MODELO DADOS SAIDA 
{
  "offers": [
    {
      "id": "8d4b3cc7-5020-4c57-aa76-52eb9f28ab2a",
      "debtOriginalValues": 200,
      "debtCurrentValues": 400,
      "maxInstalments": 8,
      "maxInstalmentValue": 50,
      "atSight": 300,
      "interest": 200,
      "discountValue": 100,
      "discountPercentage": 25,
      "hasInstalments": true,
      "debts": [
        {
          "dueDate": "2020-04-17",
          "occurrenceDate": "2020-04-17",
          "originalValue": 150,
          "currentValue": 250,
          "contractNumber": "1234567",
          "type": "[PT] Cartão de Crédito [EN] Credit card",
          "company": {
            "id": "29939269000110",
            "businessName": "[PT] Parceiro da Serasa Ltda. [EN] Serasa Partner Ltda."
          },
          "companyOrigin": {
            "id": "29939269000110",
            "businessName": "[PT] Parceiro da Serasa Ltda. [EN] Serasa Partner Ltda."
          }
        },
        {
          "dueDate": "2018-01-02",
          "occurrenceDate": "2018-01-02",
          "originalValue": 50,
          "currentValue": 150,
          "contractNumber": "1234568",
          "type": "[PT] Financiamento [EN] Funding",
          "company": {
            "id": "29939269000110",
            "businessName": "[PT] Parceiro da Serasa Ltda. [EN] Serasa Partner Ltda."
          }
        }
      ]
    },
    {
      "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
      "debtOriginalValues": 100.1,
      "debtCurrentValues": 200.2,
      "maxInstalments": 1,
      "maxInstalmentValue": 200.2,
      "atSight": 200.2,
      "interest": 100.1,
      "discountValue": 0,
      "discountPercentage": 0,
      "hasInstalments": false,
      "debts": [
        {
          "dueDate": "2020-07-20",
          "occurrenceDate": "2020-07-20",
          "originalValue": 100.1,
          "currentValue": 200.2,
          "contractNumber": "1234569",
          "type": "[PT] Crediário [EN] Credit",
          "company": {
            "id": "29939269000110",
            "businessName": "[PT] Parceiro da Serasa Ltda. [EN] Serasa Partner Ltda."
          },
          "companyOrigin": {
            "id": "29939269000110",
            "businessName": "[PT] Parceiro da Serasa Ltda. [EN] Serasa Partner Ltda."
          }
        }
      ]
    }
  ]
}
*/

def temp-table ttentrada no-undo serialize-name "dadosEntrada"   /* JSON ENTRADA */
   field document        as char serialize-name "document" /* CPJ/CNPJ do consumidor */
   field offer_id         as char serialize-name "offerId".

def temp-table ttofertas  no-undo serialize-name "ofertas"  /* JSON SAIDA */
    field offers        as CHAR serialize-name "offers".
   
def temp-table ttsaida  no-undo serialize-name "conteudoSaida"  /* JSON SAIDA CASO ERRO */
    field tstatus        as int serialize-name "status"
    field descricaoStatus      as char.


hEntrada = temp-table ttentrada:HANDLE.
lokJSON = hentrada:READ-JSON("longchar",vlcentrada, "EMPTY") no-error.

find first ttentrada no-error.
if not avail ttentrada
then do:
    create ttsaida.
    ttsaida.tstatus = 400.
    ttsaida.descricaoStatus = "Dados de Entrada Invalidos".

    hsaida  = temp-table ttsaida:handle.

    lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).
    message string(vlcSaida).
    return.
end.

joCompany = NEW JsonObject().
joCompany:ADD("id","29939269000110").
joCompany:ADD("businessName","[PT] Parceiro da Serasa Ltda. [EN] Serasa Partner Ltda.").

joCompanyOrigin = NEW JsonObject().
joCompanyOrigin:ADD("id","29939269000110").
joCompanyOrigin:ADD("businessName","[PT] Parceiro da Serasa Ltda. [EN] Serasa Partner Ltda.").


joDebts = NEW JsonObject().
joDebts:ADD("dueDate","2020-04-17").
joDebts:ADD("occurrenceDate","2020-04-17").
joDebts:ADD("originalValue",150).
joDebts:ADD("currentValue",250).
joDebts:ADD("contractNumber","1234567").
joDebts:ADD("type","[PT] Cartão de Crédito [EN] Credit card").
joDebts:ADD("company",joCompany).
joDebts:ADD("companyOrigin",joCompanyOrigin).

jaDebts = NEW JsonArray().
jaDebts:ADD(joDebts).

joOffers = NEW JsonObject().
joOffers:ADD("id","8d4b3cc7-5020-4c57-aa76-52eb9f28ab2a").
joOffers:ADD("debtOriginalValues",200).
joOffers:ADD("debtCurrentValues",400).
joOffers:ADD("maxInstalments",8).
joOffers:ADD("maxInstalmentValue",50).
joOffers:ADD("atSight",300).
joOffers:ADD("interest", 200).
joOffers:ADD("discountValue", 100).
joOffers:ADD("discountPercentage", 25).
joOffers:ADD("hasInstalments", true).
joOffers:ADD("debts", jaDebts).

jaOffers = NEW JsonArray().
jaOffers:ADD(joOffers).


jaOffers:Write(lcOffers).

create ttofertas. 
ttofertas.offers = lcOffers.


hsaida  = TEMP-TABLE ttofertas:handle.


lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).

/* export LONG VAR*/
DEF VAR vMEMPTR AS MEMPTR  NO-UNDO.
DEF VAR vloop   AS INT     NO-UNDO.
if length(vlcsaida) > 30000
then do:
    COPY-LOB FROM vlcsaida TO vMEMPTR.
    DO vLOOP = 1 TO LENGTH(vlcsaida): 
        put unformatted GET-STRING(vMEMPTR, vLOOP, 1). 
    END.
end.
else do:
    put unformatted string(vlcSaida).
end.  
