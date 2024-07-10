/* #012023 helio onda 3 */

def input  parameter vlcentrada as longchar.
def var vlcsaida   as longchar.
def var vsaida as char.
def var hentrada as handle.
def var hsaida   as handle.

{/admcom/progr/api/acentos.i}
def var vstatus as char.
def var vmensagem_erro as char.
def var vetbcod as int.
def var vcontnum as int64.
def var vParcelasLista as char.
def var vParcelasValorLista as char.
def var vdtAcordo as date.
def var vdtvenc as date.


def var vconta as int.
def var vx as int.
/* */
{/admcom/progr/acha.i}
{/admcom/barramento/functions.i}

{/admcom/progr/neuro/achahash.i}  /* 03.04.2018 helio */
{/admcom/progr/neuro/varcomportamento.i} /* 03.04.2018 helio */

def var xtime as int.

def var vmessage as log.
vmessage = no.

DEFINE VARIABLE lokJSON                  AS LOGICAL.

def temp-table ttAcordo serialize-name "GravaAcordo"
    field CNPJ_CPF as char
    field IDAcordo as char
    field DataAcordo as char
    field QtdttContratos as char
    field VlPrincipal as char
    field VlJuros   as char
    field VlMulta   as char
    field VlHonorarios as char
    field VlEncargos as char
    field VlTotalAcordo as char
    field VlDesconto as char
    field OrigemAcordo as char
    field taxa_juros  as char. /* onda 3 */


def temp-table ttContratos serialize-name "Contratos"
    field grupo as char
    field NumeroContrato as char.

def temp-table ttparcelasAcordo serialize-name "ParcelasAcordo"
    field NumeroParcela as char
    field Vencimento as char 
    field VlPrincipal as char
    field VlJuros as char
    field VlMulta as char
    field VlHonorarios as char
    field VlEncargos as char.


DEFINE DATASET dadosEntrada FOR ttAcordo, ttContratos , ttparcelasAcordo.

def temp-table ttsaida  no-undo serialize-name "conteudoSaida"
    field tstatus        as int serialize-name "status"
    field descricaoStatus      as char.

def var vvlrlimite  as dec.
def var vvlrdisponivel as dec.
def var vvctolimite as date.
def var var-salaberto-principal as dec.
def var var-salaberto-hubseg as dec.

def var vqtdParcelas as int.
def var vvlrParcelas as dec.
def var vvlrJuros   as dec.
def var vjuros       as dec.


hEntrada = DATASET dadosEntrada:HANDLE.

lokJSON = hentrada:READ-JSON("longchar",vlcentrada, "EMPTY").


find first ttAcordo no-error.
if not avail ttAcordo
then do:
  create ttsaida.
  ttsaida.tstatus = 400.
  ttsaida.descricaoStatus = "Sem dados de Entrada".

  hsaida  = temp-table ttsaida:handle.

  lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).
  message string(vlcSaida).
  return.

end.

find neuclien where neuclien.cpfCnpj =  dec(ttAcordo.CNPJ_CPF) no-lock no-error.
if not avail neuclien
then do:
    find clien where clien.ciccgc = trim(ttAcordo.CNPJ_CPF) no-lock no-error.
end.
else do:
  find clien where clien.clicod = neuclien.clicod no-lock no-error.
end.

if not avail clien
then do:

  create ttsaida.
  ttsaida.tstatus = 404.
  ttsaida.descricaoStatus = "Cliente com CPF " +
          (if ttAcordo.CNPJ_CPF = ?
           then ""
           else ttAcordo.CNPJ_CPF) + " Não encontrado.".

  hsaida  = temp-table ttsaida:handle.

  lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).
  message string(vlcSaida).
  return.

end.

find cybacordo where cybacordo.idacordo = int(ttAcordo.idacordo)
    no-lock no-error.
if avail cybacordo
then do:
    create ttsaida.
    ttsaida.tstatus = 404.
    ttsaida.descricaoStatus = "Acordo ja gravado".
  
    hsaida  = temp-table ttsaida:handle.
  
    lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).
    message string(vlcSaida).
        
    return.
end.    


vstatus = "S".
find first ttContratos no-error.
if avail ttContratos 
then do.

    for each ttContratos.
        
        find contrato where contrato.contnum = int64(substr(ttContratos.NumeroContrato,4)) no-lock no-error.
        if not avail contrato
        then do:
            vstatus = "N".
            vmensagem_erro = vmensagem_erro + 
                        (if vmensagem_erro = ""
                        then ""
                        else " - ")
                    + "Contrato Origem Inexistente".
            leave.            
        end.
    end.

end.

if vstatus = "S"
then do:
   
    vdtAcordo = date(int(substr(ttAcordo.dataacordo,1,2)),
                    int(substr(ttAcordo.dataacordo,3,2)),
                    int(substr(ttAcordo.dataacordo,5,4))).

    create cybacordo.
    ASSIGN
        CybAcordo.IDAcordo   = int(ttAcordo.IDAcordo)
        CybAcordo.CliFor     = clien.clicod
        CybAcordo.DtAcordo   = vdtAcordo
        CybAcordo.Situacao   = "A"
        CybAcordo.VlAcordo   = dec(ttAcordo.VlTotalAcordo)
        CybAcordo.VlOriginal = dec(ttAcordo.VlPrincipal)
        CybAcordo.HrAcordo   = time
        CybAcordo.DtEfetiva  = ?
        CybAcordo.HrEfetiva  = ?.
    assign
        cybacordo.etbcod = 0
        cybacordo.modcod = ""
        cybacordo.tpcontrato = "".    
    
    cybacordo.taxa_juros = dec(ttAcordo.taxa_juros). /* onda 3 */

    /* executa o depara 
                    /* helio 122022 - onda 3 */
                    vplano = int(plano_pagamento) no-error.
                    if vplano = ? 
                    then do:
                        vcomjuro    = vtotalprazo > (vvalorcompra - ventrada).
                        
                        /* depara */
                        find first findepara where 
                                findepara.prazo      = vprazo and
                                findepara.comentrada = (ventrada > 0) and
                                findepara.comjuros   = vcomjuro
                            no-lock no-error.
                        if avail findepara
                        then vplano = findepara.fincod.
                        else vplano = 326.
                    end.    
                    if vplano = ?
                    then vplano = 326.

                    run log("chamando sicred plano ->" + string(vplano)).

                    /* helio 122022 - onda 3 */

    cybacordo.fincod = dec(ttAcordo.taxa_juros). /* onda 3 */
                        */
                        
    for each ttContratos.
        vetbcod   = int(substr(ttContratos.Numerocontrato,1,3)).
        vcontnum  = int(substr(ttContratos.Numerocontrato,4)).

        find contrato where contrato.contnum = vcontnum no-lock.

        if cybacordo.etbcod = 0
        then cybacordo.etbcod = vetbcod.
        if cybacordo.modcod = ""
        then cybacordo.modcod = contrato.modcod.
        if cybacordo.tpcontrato = ""
        then cybacordo.tpcontrato = "N".

        create cybacorigem.
        ASSIGN
        CybAcOrigem.IDAcordo   = cybacordo.IDAcordo
        CybAcOrigem.contnum    = contrato.contnum
        cybacorigem.vlOriginal = 0
        CybAcOrigem.etbcod     = contrato.etbcod /* #1 */
        CybAcOrigem.modcod     = contrato.modcod /* #1 */.

        vparcelasLista = "".
        vparcelasValorLista = "".

        for each titulo where 
            titulo.empcod = 19 and 
            titulo.titnat = no and 
            titulo.modcod = contrato.modcod and 
            titulo.etbcod = contrato.etbcod and 
            titulo.clifor = contrato.clicod and 
            titulo.titnum = string(contrato.contnum) 
            no-lock
            by titulo.titpar.

            if titulo.clifor <= 1 or
            titulo.clifor = ? or
            titulo.titpar = 0 or
            titulo.titnum = "" or
            titulo.titvlcob <= 0.01 /*** 02.08.16 ***/
            then next.

            if titulo.titsit <> "LIB" then next.

            vparcelasLista = vparcelasLista +
                            if vparcelasLista = ""
                            then string(titulo.titpar)
                            else "," + string(titulo.titpar).

            vparcelasValorLista = vparcelasValorLista +
                            if vparcelasValorLista = ""
                            then string(titulo.titvlcob)
                            else "," + string(titulo.titvlcob).

            cybacOrigem.vlOriginal = cybAcOrigem.VlOriginal + titulo.titvlcob.
        end.
        assign
            CybAcOrigem.ParcelasLista = vParcelasLista
            CybAcOrigem.ParcelasValor = vParcelasValorLista.
    end.

    for each ttparcelasAcordo.
        vdtvenc   = date(int(substr(ttparcelasAcordo.Vencimento,1,2)),
                    int(substr(ttparcelasAcordo.Vencimento,3,2)),
                    int(substr(ttparcelasAcordo.Vencimento,5,4))).

        create CybAcParcela.
        ASSIGN
        CybAcParcela.IDAcordo     = cybacordo.IDAcordo
        CybAcParcela.Parcela      = int(ttparcelasAcordo.NumeroParcela)
        CybAcParcela.DtVencimento = vDtVenc
        CybAcParcela.VlCobrado    = dec(ttparcelasAcordo.VlPrincipal).
        /* Quando Efetivado */
        ASSIGN
        CybAcParcela.contnum      = ?.
    end.

    
    vmensagem_erro = "Registrado acordo " + ttAcordo.IDAcordo.


end.

      
create ttsaida.
ttsaida.tstatus = if vstatus = "S" then 200 else 400.
ttsaida.descricaoStatus = vmensagem_erro.

hSaida = temp-table ttsaida:HANDLE.
lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).
message string(vlcSaida).
