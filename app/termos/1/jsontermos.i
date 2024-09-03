/* helio 17022022 - 263458 - Revisão da regra de novações  */

def var vconteudo as char.
def var vlinha as char.
def var vid as int.
def var vparcelas-lista as char.
def var vparcelas-valor as char.
def var viofPerc as dec.
def var vvalorIOF as dec.
def var vprincipal as dec.
def var vprincipalPerc as dec.
def var vprodutos-Lista as char.
def var vcontratos-Lista as char.
def var vcatcod as int init 0.

def var textFile AS longchar NO-UNDO.
DEF VAR vtexto     AS MEMPTR    NO-UNDO.
DEF VAR textFile64 AS LONGCHAR  NO-UNDO.
DEF VAR vlength    AS INTEGER   NO-UNDO.
def var vdataNascimento AS CHAR.
def var vdataVencimento as date.
def var vdataTransacao as date.
def var vdataTransacaoExtenso as char.
def var vdia as int.
def var vmes as int.
def var vano as int.

def var vmesext         as char format "x(10)"  extent 12
                        initial ["Janeiro" ,"Fevereiro","Marco"   ,"Abril",
                                 "Maio"    ,"Junho"    ,"Julho"   ,"Agosto",
                                 "Setembro","Outubro"  ,"Novembro","Dezembro"] .


def var vvalorSeguroPrestamista as dec init 0.
def var vcopias as int.

def var vdatainivigencia12 as date.
def var vdatafimvigencia13 as date.
def var vvalorSeguroPrestamistaLiquido as dec.
def var vvalorSeguroPrestamistaIof as dec.
def var vvalorSeguroPrestamista29 as dec.
def var vvalorSeguroPrestamista30 as dec.

  

def  temp-table tttermos no-undo serialize-name "termos"
  field sequencial as char
  field tipo    as char
  field termo as char
  field quantidadeVias  as char
  field formato    as char.


def var hEntrada     as handle.
def var hSAIDA            as handle.

DEFINE {1} shared TEMP-TABLE ttpedidoCartaoLebes NO-UNDO SERIALIZE-NAME "pedidoCartaoLebes"
    field id as char serialize-hidden
    field   rascunho              as char
    FIELD   formatoTermo          as char 
    FIELD   tipoOperacao          as char 
    FIELD   codigoLoja          as char 
    FIELD   numeroComponente     AS CHAR
    FIELD   dataTransacao          as char 
    FIELD   codigoCliente          as char 
    FIELD    numeroNotaFiscal       AS CHAR
    FIELD   idBiometria as char 
    FIELD   neuroIdOperacao as char 
    FIELD   codigoProdutoFinanceiro as char 
    FIELD   valorEmprestimo as char 
    FIELD   codigoVendedor as char 
    FIELD   codigoOperador as char 
    FIELD   valorTotal as char. 

    
DEFINE {1} shared TEMP-TABLE ttrecebimentos NO-UNDO SERIALIZE-NAME "recebimentos"
    field idpai as char serialize-hidden
    field formaPagamento as char 
    field codigoPlano as char
    field valorPago as char
    field seqForma as char.

DEFINE {1} shared TEMP-TABLE ttcartaoLebes NO-UNDO SERIALIZE-NAME "cartaoLebes"
    field idpai as char serialize-hidden
    FIELD   seqForma as char
    FIELD   numeroContrato as char 
    FIELD   contratoFinanceira as char 
    FIELD   cet as char
    FIELD   cetAno as char 
    FIELD   taxaMes as char  
    field   valorIof as char
    field   qtdParcelas as char
    field   valorTFC as char
    field   valorAcrescimo as char.
            
            

DEFINE {1} shared TEMP-TABLE ttparcelas NO-UNDO SERIALIZE-NAME "parcelas"
    field idpai as char serialize-hidden
    field seqParcela as char 
    field valorParcela as char
    field dataVencimento as char
    INDEX X seqparcela ASC.


DEFINE {1} shared TEMP-TABLE ttseguroprestamista NO-UNDO SERIALIZE-NAME "seguroprestamista"
    field idpai as char serialize-hidden
    field numeroApoliceSeguroPrestamista as char
    field numeroSorteioSeguroPrestamista as char
    field codigoSeguroPrestamista as char
    field valorSeguroPrestamista as char
    field dataInicioVigencia as char
    field dataFimVigencia as char.

DEFINE {1} shared TEMP-TABLE ttcontratosrenegociados NO-UNDO SERIALIZE-NAME "contratosrenegociados"
    field idpai as char serialize-hidden
    field contratoRenegociado as char
    field valorRenegociado as char.


DEFINE {1} shared TEMP-TABLE ttprodutos NO-UNDO SERIALIZE-NAME "produtos"
    field idpai as char serialize-hidden
    field codigoProduto as char
    field codigoMercadologico as char
    field quantidade as char
    field valorTotal as char 
    field valorUnitario as char 
    field valorTotalDesconto as char
    field tipoProduto as char.
    

DEFINE DATASET dadosEntrada FOR ttpedidoCartaoLebes, ttrecebimentos, ttcartaoLebes, ttparcelas, ttseguroprestamista, ttcontratosrenegociados, ttprodutos
    DATA-RELATION for1 FOR ttpedidoCartaoLebes, ttrecebimentos      RELATION-FIELDS(ttpedidoCartaoLebes.id,ttrecebimentos.idpai) NESTED
    DATA-RELATION for2 FOR ttpedidoCartaoLebes, ttcartaoLebes      RELATION-FIELDS(ttpedidoCartaoLebes.id,ttcartaoLebes.idpai) NESTED
    DATA-RELATION for3 FOR ttcartaoLebes, ttparcelas               RELATION-FIELDS(ttcartaoLebes.id,ttparcelas.idpai) NESTED
    DATA-RELATION for4 FOR ttcartaoLebes, ttseguroprestamista      RELATION-FIELDS(ttcartaoLebes.id,ttseguroprestamista.idpai) NESTED
    DATA-RELATION for5 FOR ttpedidoCartaoLebes, ttcontratosrenegociados RELATION-FIELDS(ttpedidoCartaoLebes.id,ttcontratosrenegociados.idpai) NESTED
    DATA-RELATION for6 FOR ttpedidoCartaoLebes, ttprodutos         RELATION-FIELDS(ttpedidoCartaoLebes.id,ttprodutos.idpai) NESTED.


DEFINE {1} shared TEMP-TABLE ttcobparam NO-UNDO SERIALIZE-NAME "parametros"
    field id as char serialize-hidden
    field carteira as char.
/*
DEFINE {1} shared TEMP-TABLE ttsaidaparcelas NO-UNDO SERIALIZE-NAME "parcelas"
    field idPai as char serialize-hidden
    field seqParcela as char 
    field valorParcela as char
    field dataVencimento as char
    field valorSeguroRateado as char.
*/

DEFINE DATASET dadosSaida FOR ttcobparam. /*, ttsaidaparcelas
    DATA-RELATION for1 FOR ttcobparam, ttsaidaparcelas         RELATION-FIELDS(ttcobparam.id,ttsaidaparcelas.idpai) NESTED.
*/
hentrada = DATASET dadosEntrada:HANDLE.
hsaida   = DATASET dadosSaida:HANDLE.

function freplace RETURNS char ( 
        input pentrada as char,
        input pmnemo as char,
        input pcampo as char):
DEF VAR psaida AS CHAR.        
    if pcampo = ? then pcampo = "".
    psaida = replace(pentrada,pmnemo,pcampo). 
    if psaida = ? THEN psaida = "".
    RETURN psaida.
END FUNCTION.



procedure trocamnemos.


if avail ttpedidoCartaoLebes
then do:
    tttermos.termo = freplace(tttermos.termo,"~{codigoLoja~}",ttpedidoCartaoLebes.codigoLoja).
    tttermos.termo = freplace(tttermos.termo,"~{dataTransacao~}",string(vdataTransacao,"99/99/9999")).
    tttermos.termo = freplace(tttermos.termo,"~{dataTransacao.extenso~}",vdataTransacaoExtenso).
    tttermos.termo = freplace(tttermos.termo,"~{numeroComponente~}",ttpedidoCartaoLebes.numeroComponente).
    tttermos.termo = freplace(tttermos.termo,"~{codigoVendedor~}",ttpedidoCartaoLebes.codigoVendedor).
    tttermos.termo = freplace(tttermos.termo,"~{valorTotal~}",ttpedidoCartaoLebes.valorTotal).
    tttermos.termo = freplace(tttermos.termo,"~{codigoCliente~}",ttpedidoCartaoLebes.codigoCliente).
    tttermos.termo = freplace(tttermos.termo,"~{numeroNotaFiscal~}",ttpedidoCartaoLebes.numeroNotaFiscal).
end.

if avail clien
then do:
    tttermos.termo = freplace(tttermos.termo,"~{cpfCnpjCliente~}",clien.ciccgc).
    tttermos.termo = freplace(tttermos.termo,"~{rg~}",clien.ciins). /* helio-gabriel confirmar se � o campo RG*/
    tttermos.termo = freplace(tttermos.termo,"~{nomeCliente~}",clien.clinom).
    vdataNascimento = STRING(DAY(clien.dtnasc), "99") + "/" +
                          STRING(MONTH(clien.dtnasc), "99") + "/" +
                          STRING(YEAR(clien.dtnasc), "9999").
    tttermos.termo = freplace(tttermos.termo,"~{dataNascimento~}",vdataNascimento).
    tttermos.termo = freplace(tttermos.termo,"~{endereco.cep~}",clien.cep[1]).
    tttermos.termo = freplace(tttermos.termo,"~{endereco.logradouro~}",clien.endereco[1]).
    tttermos.termo = freplace(tttermos.termo,"~{endereco.numero~}",string(clien.numero[2])).
    tttermos.termo = freplace(tttermos.termo,"~{endereco.complemento~}",clien.compl[1]). 
    tttermos.termo = freplace(tttermos.termo,"~{endereco.bairro~}",clien.bairro[1]).
    tttermos.termo = freplace(tttermos.termo,"~{endereco.cidade~}",clien.cidade[1]).
    tttermos.termo = freplace(tttermos.termo,"~{endereco.estado~}",clien.ufecod[1]).
    tttermos.termo = freplace(tttermos.termo,"~{endereco.pais~}","BRASIL"). 
    tttermos.termo = freplace(tttermos.termo,"~{email~}",clien.zona).
    tttermos.termo = freplace(tttermos.termo,"~{telefone~}",clien.fone).

end. 

if avail ttcartaolebes
then do:

    tttermos.termo = freplace(tttermos.termo,"~{parcelas.lista~}",vparcelas-lista).
    tttermos.termo = freplace(tttermos.termo,"~{parcelas.valor~}",vparcelas-valor).
    tttermos.termo = freplace(tttermos.termo,"~{qtdParcelas~}",ttcartaoLebes.qtdParcelas).
    tttermos.termo = freplace(tttermos.termo,"~{valorAcrescimo~}",ttcartaoLebes.valorAcrescimo).
    tttermos.termo = freplace(tttermos.termo,"~{numeroContrato~}",ttcartaoLebes.numeroContrato).
    tttermos.termo = freplace(tttermos.termo,"~{cet~}",ttcartaoLebes.cet).
    tttermos.termo = freplace(tttermos.termo,"~{cetAno~}",ttcartaoLebes.cetAno).
    tttermos.termo = freplace(tttermos.termo,"~{taxaMes~}",ttcartaoLebes.taxaMes).
    tttermos.termo = freplace(tttermos.termo,"~{valorIOF~}",ttcartaoLebes.valorIOF).
    tttermos.termo = freplace(tttermos.termo,"~{iof.perc~}",trim(string(viofPerc,">>>>>>>>9.99"))).
    tttermos.termo = freplace(tttermos.termo,"~{principal~}",trim(string(vprincipal,">>>>>>>>9.99"))).
    tttermos.termo = freplace(tttermos.termo,"~{principal.perc~}",trim(string(vprincipalPerc,">>>>>>>>9.99"))).
    
   

end.

if avail ttseguroprestamista
then do:
    
    tttermos.termo = freplace(tttermos.termo,"~{numeroBilheteSeguroPrestamista~}",ttseguroprestamista.numeroApoliceSeguroPrestamista). 
    tttermos.termo = freplace(tttermos.termo,"~{numeroSorte~}",ttseguroprestamista.numeroSorteioSeguroPrestamista).    
    tttermos.termo = freplace(tttermos.termo,"~{sp18~}",trim(string(vvalorSeguroPrestamista,">>>>>>>>9.99"))).
    tttermos.termo = freplace(tttermos.termo,"~{sp16~}",trim(string(vvalorSeguroPrestamistaLiquido,">>>>>>>>9.99"))). 
    tttermos.termo = freplace(tttermos.termo,"~{sp17~}",trim(string(vvalorSeguroPrestamistaIof,">>>>>>>>9.99"))).
    tttermos.termo = freplace(tttermos.termo,"~{sp29~}",trim(string(vvalorSeguroPrestamista29,">>>>>>>>9.99"))).
    tttermos.termo = freplace(tttermos.termo,"~{sp30~}",trim(string(vvalorSeguroPrestamista30,">>>>>>>>9.99"))). 
    tttermos.termo = freplace(tttermos.termo,"~{sp12~}",string(vdatainivigencia12,"99/99/9999")).
    tttermos.termo = freplace(tttermos.termo,"~{sp13~}",string(vdatafimvigencia13,"99/99/9999")).

end.

    tttermos.termo = freplace(tttermos.termo,"~{dataPrimeiroVencimento~}",vdtPriVen).
    tttermos.termo = freplace(tttermos.termo,"~{dataUltimoVencimento~}",vdtUltVen). 
    tttermos.termo = freplace(tttermos.termo,"~{valorEntrada~}",trim(string(vvalorEntrada,">>>>>>>>9.99"))).
    tttermos.termo = freplace(tttermos.termo,"~{produtos.lista~}",vprodutos-lista).
    tttermos.termo = freplace(tttermos.termo,"~{contratos.lista~}",vcontratos-lista).

end procedure.

procedure encodebase64.

set-size(vtexto) = length(tttermos.termo) + 1. 
put-string(vtexto,1) = tttermos.termo.
textFile = tttermos.termo.
copy-lob from textFile to vtexto.
tttermos.termo = base64-encode(vtexto).
SET-SIZE(vtexto) = 0.

end procedure.






