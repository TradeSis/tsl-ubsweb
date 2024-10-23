/* {"dadosSaida":{
  "contato":[
  {
    "numeroContrato": "3131525241",
    "dataEmissao": "2024-01-23",
    "saldoDevedorPrincipal": "309.45",
    "somaParcelas": "1151.50",
    "valorParcelaComAcrescimo": "115.15",
    "valroParcelaPrincipal": "103.15",
    "qtdParcelas": "10",
    "qtdParcelasAbertas": "3",
    "proximoVencimento:": "2024-10-23"
  }
  
] }} */
def input  parameter vlcentrada as longchar.
def var vlcsaida   as longchar.
def var vsaida as char.
def var hentrada as handle.
def var hsaida   as handle.
def var lokJSON as log. 

def temp-table ttentrada no-undo serialize-name "dadosEntrada"
    field clicod like clien.clicod
    field cpfCnpj like clien.ciccgc.

def temp-table ttcontrato no-undo serialize-name "contrato"
  field numeroContrato as INT 
  field dataEmissao as DATE
  field saldoDevedorPrincipal as dec 
  field somaParcelas as dec
  field valorParcelaComAcrescimo as dec  
  field valorParcelaPrincipal AS DEC 
  field qtdParcelas as INT 
  field qtdParcelasAbertas as int 
  field proximoVencimento as date.
 
DEF TEMP-TABLE ttcliente NO-UNDO SERIALIZE-NAME "cliente"
    FIELD clicod LIKE clien.clicod
    FIELD clinom LIKE clien.clinom
    FIELD ciccgc LIKE clien.ciccgc
    FIELD etbcad LIKE clien.etbcad.
    
def temp-table ttsaida  no-undo serialize-name "conteudoSaida"  /* JSON SAIDA CASO ERRO */
    field tstatus        as int serialize-name "status"
    field descricaoStatus      as char.
    
DEF DATASET dadosSaida /*SERIALIZE-HIDDEN*/
  FOR ttcliente, ttcontrato.


def var vdias as int init 0.
def var tdias as int init 0.
def var vtitvlpag as dec.
def var vpercpag as dec.
def var velegivel as log.
def var velegivel-contrato as log.
DEF VAR vsaldoDevedorPrincipal AS DEC.
DEF VAR vqtdParcelas AS INT.
DEF VAR vqtdParcelasAbertas AS INT.
DEF VAR vsomaParcelas AS DEC.
DEF VAR vvalorParcelaPrincipal AS DEC.
DEF VAR vproximoVencimento AS DATE.
DEF VAR vvalorParcelaComAcrescimo AS DEC.

DEF VAR json AS CHAR.
def var vcpfCnpj as char.
def var vclicod as INT.

hEntrada = temp-table ttentrada:HANDLE.
lokJSON = hentrada:READ-JSON("longchar",vlcentrada, "EMPTY").

find first ttentrada.
IF ttentrada.clicod = ? AND ttentrada.cpfCnpj = ?
then do:
    create ttsaida.
    ttsaida.tstatus = 400.
    ttsaida.descricaoStatus = "Dados de Entrada nao encontrados".

    hsaida  = temp-table ttsaida:handle.

    lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).
    message string(vlcSaida).
    return.
end.

if ttentrada.clicod = 0
then do:
  vclicod = ?.
end.
ELSE DO:
  vclicod = ttentrada.clicod.
END.

IF vclicod <> ?  
THEN DO:
   FIND clien WHERE clien.clicod = vclicod NO-LOCK NO-ERROR.    
END.
ELSE DO:
    find neuclien where neuclien.cpf = dec(ttentrada.cpfCnpj) no-lock no-error.
    if not avail neuclien
    then do:
         find first clien where clien.ciccgc = ttentrada.cpfCnpj no-lock no-error.
    end.
    else do:
         find clien where clien.clicod = neuclien.clicod no-lock no-error.
    end. 
END.

if not avail clien
then do:
  create ttsaida.
  ttsaida.tstatus = 400.
  ttsaida.descricaoStatus = "Cliente nao encontrado".

  hsaida  = temp-table ttsaida:handle.

  lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).
  message string(vlcSaida).
  return.
end.
else do:
  CREATE ttcliente.
  ttcliente.clicod = clien.clicod.
  ttcliente.clinom = clien.clinom.
  ttcliente.ciccgc = clien.ciccgc.
  ttcliente.etbcad = clien.etbcad.
end.

tdias = 0.

find last rfnparam where rfnparam.dtinivig <= today 
                          no-lock no-error.
if avail rfnparam 
then do:
 
    for each contrato of clien no-lock.
      
        vtitvlpag = 0.
        vpercpag  = 0.
        velegivel-contrato = yes.

        if rfnparam.listaModalidades <> ? and
          rfnparam.listaModalidades <> ""
        then do:
            if lookup(string(contrato.modcod),rfnparam.listaModalidades) <> 0
            then.
            else do:
                velegivel-contrato = no.
            end.
        end.
      
        if velegivel-contrato
        then do:
            if rfnparam.permiteNovacao = no AND contrato.tpcontrato = "N"
            then do:
                velegivel-contrato = no.
            end.
        end.

        vsaldoDevedorPrincipal = 0.
        vqtdParcelas    = 0.
        vqtdParcelasAbertas = 0.
        vsomaParcelas = 0.
        vvalorParcelaPrincipal = 0.
        vproximoVencimento  = ?.
        for each titulo where
            titulo.empcod = 19 and titulo.titnat = no and
            titulo.etbcod = contrato.etbcod and titulo.modcod = contrato.modcod and titulo.clifor = contrato.clicod and
            titulo.titnum = string(contrato.contnum)
            no-lock
                by titulo.titpar. 
            if titulo.titsit = "LIB" or titulo.titsit = "PAG" 
            then.
            else next.
            
            if velegivel-contrato
            then do: 
            
                if rfnparam.carteirasPermitidas <> ? and
                    rfnparam.carteirasPermitidas <> ""
                then do:
                    if lookup(string(titulo.cobcod),rfnparam.carteirasPermitidas) <> 0
                    then .
                    else do:
                        velegivel-contrato = no.
                    end.
                end.
            end.
            if titulo.titpar > 0
            then vqtdParcelas = vqtdParcelas + 1.
            vvalorParcelaPrincipal      = if titulo.vlf_principal > 0
                                          then titulo.vlf_principal
                                          else titulo.titvlcob.
            vvalorParcelaComAcrescimo   = titulo.titvlcob.
            if titulo.titsit = "LIB"
            then do:
            
                if vproximoVencimento = ?
                then vproximoVencimento = titulo.titdtven.
                vdias = today - titulo.titdtven.
                tdias = max(tdias,vdias).
                if titulo.vlf_principal > 0
                then vsaldoDevedorPrincipal = vsaldoDevedorPrincipal + titulo.vlf_principal.
                else vsaldoDevedorPrincipal = vsaldoDevedorPrincipal + titulo.titvlcob.
                vsomaParcelas          = vsomaParcelas          + titulo.titvlcob.
                vqtdParcelasAbertas    = vqtdParcelasAbertas    + 1.
            end.
            if titulo.titsit = "PAG"
            then do:
                vtitvlpag = vtitvlpag + titulo.titvlcob.
            end.
            vpercpag = vtitvlpag / contrato.vltotal * 100.
            
        end.
        
        if velegivel-contrato
        then do:
            if rfnparam.contratoPago > 0
            then do.
                if vpercpag < rfnparam.contratoPago or vpercpag = 100
                then do:
                    velegivel-contrato = no.
                end.
            end.
        end.
         
        if true or velegivel-contrato
        then do:   
            create ttcontrato.
            ttcontrato.numeroContrato           = contrato.contnum. 
            ttcontrato.dataEmissao              = contrato.dtinicial.
            ttcontrato.saldoDevedorPrincipal    = vsaldoDevedorPrincipal.
            ttcontrato.somaParcelas             = vsomaParcelas.
            ttcontrato.valorParcelaComAcrescimo = vvalorParcelaComAcrescimo.
            ttcontrato.valorParcelaPrincipal    = vvalorParcelaPrincipal.
            ttcontrato.qtdParcelas              = vqtdParcelas.
            ttcontrato.qtdParcelasAbertas       = vqtdParcelasAbertas.
            ttcontrato.proximoVencimento        = vproximoVencimento.
        end.

    end.
/*    message rfnparam.diasAtrasoMax tdias rfnparam.diasAtrasoMax > 0 tdias <  rfnparam.diasAtrasoMax.    */
    if  rfnparam.diasAtrasoMax > 0
    then do:
        if tdias >=  rfnparam.diasAtrasoMax
        then do:
            for each ttcontrato.
                delete ttcontrato.
            end.
        end.
    end.
    
end. /* rfnparam */


find first ttcontrato no-error.
if not avail ttcontrato
then do:
    create ttsaida.
    ttsaida.tstatus = 400.
    ttsaida.descricaoStatus = "Nenhum contrato selecionado".

    hsaida  = temp-table ttsaida:handle.

    lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).
    message string(vlcSaida).
    return.
end.

    hsaida =  DATASET dadosSaida:HANDLE.
    
    lokJson = hSaida:WRITE-JSON("LONGCHAR", vlcsaida, TRUE) no-error.
    if lokJson
    then do:
            put unformatted trim(string(vlcsaida)).
    end.
    else do:
        
        hsaida  = temp-table ttcontrato:handle.
    
        lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).
        message string(vlcSaida).
        return.
    end.


