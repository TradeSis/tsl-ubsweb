/* bau 092022 - helio */

def input  parameter vlcentrada as longchar.

def var vidPagamento as int.
def var vtipopagamento as char.

{/admcom/progr/bau/baudefs.i new}

def var vlcsaida   as longchar.

def var vsaida as char.

def var lokjson as log.
def var hsaida   as handle.
def var hentrada   as handle.

def var vpar as int.
def var vqtdparcelas as int.
def var vdtvenc     as date format "99/99/9999".
def var vdia as int.
def var vd as int.
def var vmes as int.
def var vano as int.

FUNCTION acha2 returns character
    (input par-oque as char,
     input par-onde as char).
    def var vx as int.
    def var vret as char.
    vret = ?.
    do vx = 1 to num-entries(par-onde,"|").
        if num-entries( entry(vx,par-onde,"|"),"#") = 2 and
           entry(1,entry(vx,par-onde,"|"),"#") = par-oque
        then do:
            vret = entry(2,entry(vx,par-onde,"|"),"#").
            leave.
        end.
    end.
    return vret.
END FUNCTION.

hentrada = DATASET dadosEfetivaPagamento:handle.
lokJSON = hEntrada:READ-JSON("longchar",vlcentrada, "EMPTY").

find first ttEfetivaPagamento.

/* Helio #19092022 - uso de mesma sequencia que CHAMA DOUTOR
find last bauPagamento no-lock no-error.
if not avail bauPagamento
then vidPagamento = 1.
else vidPagamento = bauPagamento.idPagamento + 1.
*/

vidPagamento = next-value(IDBarramento).

create bauPagamento.
bauPagamento.idPagamento = vidPagamento.
bauPagamento.idPropostaPagamentoLebes = ttEfetivaPagamento.idPropostaLebes.
bauPagamento.etbcod   = int(ttEfetivaPagamento.etbcod).
bauPagamento.idbau = ttEfetivaPagamento.idbau.
bauPagamento.procod   = int(ttEfetivaPagamento.procod).
bauPagamento.nsuTransacao  = ttEfetivaPagamento.nsuTransacao.
bauPagamento.tipoServico   = ttEfetivaPagamento.tipoServico.
bauPagamento.valorServico  = dec(ttEfetivaPagamento.valorServico).
bauPagamento.dataProposta = date(int(substring(ttEfetivaPagamento.dataProposta,6,2)),
             int(substring(ttEfetivaPagamento.dataProposta,9,2)),
             int(substring(ttEfetivaPagamento.dataProposta,1,4))) no-error.
bauPagamento.dataTransacao = date(int(substring(ttEfetivaPagamento.dataTransacao,6,2)),
        int(substring(ttEfetivaPagamento.dataTransacao,9,2)),
        int(substring(ttEfetivaPagamento.dataTransacao,1,4))) no-error.

find cmon where cmon.etbcod = bauPagamento.etbcod and cmon.cxacod = int(ttEfetivaPagamento.numeroComponente) no-lock no-error.
if avail cmon
then bauPagamento.cmocod = cmon.cmocod.

find first bauprodu where bauprodu.procod = bauPagamento.procod no-lock.

for each ttEfetivaPagamentoDados.
    create baupagdados.
    baupagdados.idPagamento = vidPagamento.
    baupagdados.idcampo = ttEfetivaPagamentoDados.idcampo.
    baupagdados.conteudo = ttEfetivaPagamentoDados.conteudo.

    if baupagdados.idcampo = "proposta.cliente.cpf"
    then bauPagamento.cpf = dec(replace(replace(baupagdados.conteudo,".",""),"-","")) no-error.

end.

vtipoPagamento = "PAGAMENTO".

for each ttefetivaPagamentoParcelas.
    
    create baupagparcelas.
    
    baupagparcelas.idPagamento         = vidpagamento.
/*    baupagparcelas.dtvenc              = ttefetivaPagamentoParcelas.dtvenc. */
    baupagparcelas.valor               = dec(ttefetivaPagamentoParcelas.valor).
    baupagparcelas.dtpgto              = bauPagamento.dataTransacao.
    baupagparcelas.rstatus             = yes.
    baupagparcelas.adepar              = int(ttefetivaPagamentoParcelas.numeroParcela).
    baupagparcelas.codigoBarrasParcela = ttefetivaPagamentoParcelas.codigoBarrasParcela.
    baupagparcelas.codigoBarras        = ttefetivaPagamentoParcelas.codigoBarras.
    baupagparcelas.numeroTransacao     = ttefetivaPagamentoParcelas.numeroTransacao.
    baupagparcelas.codeLocalPagamento  = ttefetivaPagamentoParcelas.codeLocalPagamento.
    
    if baupagparcelas.adepar = 1
    then do:
        
        /* helio 19122022 - fica fixo as series
        if substring(trim(ttefetivaPagamentoParcelas.codigoBarras),1,3) = string(bauprodu.serielebes,"999")
        */
        /*  helio 19122022 - fica fixo as series */   
        if substring(trim(ttefetivaPagamentoParcelas.codigoBarras),1,3) = "174" or
           substring(trim(ttefetivaPagamentoParcelas.codigoBarras),1,3) = "180"
        then vtipoPagamento = "VENDAPROPRIA".
        else vtipoPagamento = "VENDAOUTROS".
    end.
    
end.

baupagamento.tipoPagamento = vtipoPagamento.

create ttefetivaPagamentoRetorno.
ttefetivaPagamentoRetorno.idPagamento = string(vidPagamento).
ttefetivaPagamentoRetorno.tipoPagamento = vtipoPagamento.

hsaida  = temp-table ttefetivaPagamentoRetorno:handle.

lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).
message string(vlcsaida).






