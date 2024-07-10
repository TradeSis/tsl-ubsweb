/* helio 082022 - Acordo Online  */

def input  parameter vlcentrada as longchar.
def var vlcsaida   as longchar.
def var vsaida as char.
def var hentrada as handle.
def var hsaida   as handle.
def var velegivel as log.

def temp-table ttentrada no-undo serialize-name "clientes"
    field cpfCnpj as char.
{/admcom/progr/api/acentos.i}

def var vconta as int.
def var vx as int.
/* Cartoes de loja */
def var vcartoes as char.
def var vct  as int.
def var auxcartao as char extent 7 format "x(20)"
      init ["Visa","Master","Banricompras","Hipercard",
            "Cartoes de Loja","American Express","Dinners"].
/* */
{/admcom/progr/acha.i}
{/admcom/barramento/functions.i}

{/admcom/progr/neuro/achahash.i}  /* 03.04.2018 helio */
{/admcom/progr/neuro/varcomportamento.i} /* 03.04.2018 helio */

DEFINE VARIABLE lokJSON                  AS LOGICAL.

DEFINE TEMP-TABLE ttcliente NO-UNDO SERIALIZE-NAME "cliente"
        field id as char serialize-hidden
        field tipoPessoa as char
        field codigoCliente as char
        field nome as char
        field cpfCnpj as char
        field celular as char
 index x is unique primary id asc.

DEFINE TEMP-TABLE ttcontratos NO-UNDO SERIALIZE-NAME "contratos"
        field id as char serialize-hidden
        field idPai as char serialize-hidden
        field filial_contrato as char
        field modalidade    as char
        field numero_contrato   as char /* " : "0016949483", */
        field data_emissao_contrato as char /*" : "2014-02-08",*/
        field valor_contrato    as char
        field valor_total_pago  as char
        field valor_total_pendente as char
        field valor_total_encargo as char
        field valor_total_divida as char
        field qtdParcelas   as char
        index x is unique primary idpai asc id asc.

DEFINE TEMP-TABLE ttparcelas NO-UNDO SERIALIZE-NAME "parcelas"
        field id as char serialize-hidden
        field idPai as char serialize-hidden
        field seq_parcela as char
        field   venc_parcela as char    
        field vlr_parcela as char
        field valor_encargos as char
        field valor_total as char
        index x is unique primary idpai asc id asc.



DEFINE DATASET conteudoSaida FOR ttcliente, ttcontratos, ttparcelas
   DATA-RELATION for3 FOR ttcliente, ttcontratos       RELATION-FIELDS(ttcliente.id,ttcontratos.idpai) NESTED
   DATA-RELATION for4 FOR ttcontratos, ttparcelas      RELATION-FIELDS(ttcontratos.id,ttparcelas.idpai) NESTED.


hSaida = DATASET conteudoSaida:HANDLE.


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


hEntrada = temp-table ttentrada:HANDLE.

lokJSON = hentrada:READ-JSON("longchar",vlcentrada, "EMPTY").


find first ttentrada no-error.
if not avail ttentrada
then do:
  create ttsaida.
  ttsaida.tstatus = 400.
  ttsaida.descricaoStatus = "Sem dados de Entrada".

  hsaida  = temp-table ttsaida:handle.

  lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).
  message string(vlcSaida).
  return.

end.

find neuclien where neuclien.cpfCnpj =  dec(ttentrada.cpfCnpj) no-lock no-error.
if not avail neuclien
then do:
    find clien where clien.ciccgc = trim(ttentrada.cpfCnpj) no-lock no-error.
end.
else do:
  find clien where clien.clicod = neuclien.clicod no-lock no-error.
end.

if not avail clien
then do:

  create ttsaida.
  ttsaida.tstatus = 404.
  ttsaida.descricaoStatus = "Cliente com CPF " +
          (if ttentrada.cpfCnpj = ?
           then ""
           else ttentrada.cpfCnpj) + " Não encontrado.".

  hsaida  = temp-table ttsaida:handle.

  lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).
  message string(vlcSaida).
  return.

end.

create ttcliente.
         ttcliente.id = string(clien.clicod).

         ttcliente.tipoPessoa =   string(clien.tippes,"F/J").

         codigoCliente = string(clien.clicod).
         ttcliente.nome = removeacento(clien.clinom).
         ttcliente.cpfCnpj = clien.ciccgc.

         ttcliente.celular   = Texto(clien.FAX).




for each contrato where contrato.clicod = clien.clicod no-lock.
    velegivel = no.
    for each titulo where titulo.empcod = 19 and titulo.titnat = no and
        titulo.clifor = contrato.clicod and titulo.modcod = contrato.modcod and
        titulo.etbcod = contrato.etbcod and titulo.titnum = string(contrato.contnum)
        no-lock.
        if titulo.titsit = "LIB"
        then do:
            velegivel = yes.
            leave.
        end.
    
    end.   
    if not velegivel
    then next.

    vqtdParcelas = 0.
    vvlrParcelas = 0.
    vvlrJuros    = 0.
    for each titulo where titulo.empcod = 19 and titulo.titnat = no and
        titulo.clifor = contrato.clicod and titulo.modcod = contrato.modcod and
        titulo.etbcod = contrato.etbcod and titulo.titnum = string(contrato.contnum)
        and titulo.titsit = "LIB"
        no-lock.
        vqtdParcelas = vqtdParcelas + 1.
        vvlrParcelas = vvlrParcelas + titulo.titvlcob.

        if titulo.titdtven < today
        then do:
            run juro_titulo.p (if clien.etbcad = 0 then titulo.etbcod else clien.etbcad,
                           titulo.titdtven,
                           titulo.titvlcob,
                           output vjuros).

            vvlrJuros = vvlrJuros + vjuros.
        end.

    end.
    if vqtdParcelas = 0 then next.

    create ttcontratos.
        ttcontratos.id = string(contrato.contnum) .
        ttcontratos.idpai = ttcliente.id.
    filial_contrato = string(contrato.etbcod).
    modalidade      = contrato.modcod.
    numero_contrato = string(contrato.contnum).        

    data_emissao_contrato   = string(year(contrato.dtinicial)) + "-" + string(month(contrato.dtinicial),"99") + "-" + string(day(contrato.dtinicial),"99").        
    valor_contrato      = trim(string(contrato.vltotal,"->>>>>>>>>>>>9.99")).
    valor_total_pago      = trim(string(contrato.vltotal - vvlrParcelas,"->>>>>>>>>>>>9.99")).
    valor_total_pendente      = trim(string(vvlrParcelas,"->>>>>>>>>>>>9.99")).
    valor_total_encargo      = trim(string(vvlrJuros,"->>>>>>>>>>>>9.99")).
    valor_total_divida      = trim(string(vvlrParcelas + vvlrJuros,"->>>>>>>>>>>>9.99")).
    qtdParcelas      = trim(string(vqtdParcelas,"->>>>>>>>>>>>9")).

    for each titulo where titulo.empcod = 19 and titulo.titnat = no and
        titulo.clifor = contrato.clicod and titulo.modcod = contrato.modcod and
        titulo.etbcod = contrato.etbcod and titulo.titnum = string(contrato.contnum)
        and titulo.titsit = "LIB"
        no-lock
            by titulo.titdtven by titulo.titpar .

            vjuros = 0.
            if titulo.titdtven < today
            then do:
                run juro_titulo.p (if clien.etbcad = 0 then titulo.etbcod else clien.etbcad,
                               titulo.titdtven,
                               titulo.titvlcob,
                               output vjuros).
    
            end.
    
    
            create ttparcelas.
            ttparcelas.id = string(titulo.titpar).
            ttparcelas.idpai =  ttcontratos.id .
            seq_parcela     = string(titulo.titpar). 
            venc_parcela    =   string(year(titulo.titdtven)) + "-" + 
                                string(month(titulo.titdtven),"99") + "-" + 
                                string(day(titulo.titdtven),"99").        
            vlr_parcela      = trim(string(titulo.titvlcob,"->>>>>>>>>>>>9.99")).
            valor_encargos      = trim(string(vjuros,"->>>>>>>>>>>>9.99")).
            ttparcelas.valor_total      = trim(string(titulo.titvlcob + vjuros,"->>>>>>>>>>>>9.99")).
        end.

end.

def var varquivo as char.
def var ppid as char.
INPUT THROUGH "echo $PPID".
DO ON ENDKEY UNDO, LEAVE:
IMPORT unformatted ppid.
END.
INPUT CLOSE.

varquivo  = "/u/bsweb/works/apiacordosgetparcelas" + string(today,"999999") + replace(string(time,"HH:MM:SS"),":","") +
          trim(ppid) + ".json".

lokJson = hsaida:WRITE-JSON("FILE", varquivo, TRUE).
if lokJson
then do:
    os-command value("cat " + varquivo).
    os-command value("rm -f " + varquivo).
end.
else do:
    create ttsaida.
    ttsaida.tstatus = 500.
    ttsaida.descricaoStatus = "Erro na Geração do JSON de SAIDA".

    hsaida  = temp-table ttsaida:handle.

    lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).
    message string(vlcSaida).
    return.
end.


