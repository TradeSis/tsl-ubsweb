/* medico na tela 042022 - helio */

def input  parameter vlcentrada as longchar.

def var vidadesao as int.

{/admcom/progr/med/meddefs.i new}

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

hentrada = DATASET dadosAdesao:handle.
lokJSON = hEntrada:READ-JSON("longchar",vlcentrada, "EMPTY").

find first ttadesao.
/* Helio #19092022 - uso de mesma sequencia que BAU
find last medadesao no-lock no-error.
if not avail medadesao
then vidadesao = 1.
else vidadesao = medadesao.idadesao + 1.
*/
vidadesao = next-value(IDBarramento).

create medadesao.
medadesao.idadesao = vidadesao.
medadesao.idPropostaAdesaoLebes = ttadesao.idPropostaAdesaoLebes.
medadesao.etbcod   = int(ttadesao.etbcod).
medadesao.idmedico = ttadesao.idmedico.
medadesao.procod   = int(ttadesao.procod).
medadesao.nsuTransacao  = ttadesao.nsuTransacao.
medadesao.tipoServico   = ttadesao.tipoServico.
medadesao.valorServico  = dec(ttadesao.valorServico).
medadesao.dataProposta = date(int(substring(ttadesao.dataProposta,6,2)),
             int(substring(ttadesao.dataProposta,9,2)),
             int(substring(ttadesao.dataProposta,1,4))) no-error.
medadesao.dataTransacao = date(int(substring(ttadesao.dataTransacao,6,2)),
        int(substring(ttadesao.dataTransacao,9,2)),
        int(substring(ttadesao.dataTransacao,1,4))) no-error.

find cmon where cmon.etbcod = medadesao.etbcod and cmon.cxacod = int(ttadesao.numeroComponente) no-lock no-error.
if avail cmon
then medadesao.cmocod = cmon.cmocod.

find first medprodu where medprodu.procod = medadesao.procod no-lock.

for each ttdados.
    create medadedados.
    medadedados.idadesao = vidadesao.
    medadedados.idcampo = ttdados.idcampo.
    medadedados.conteudo = ttdados.conteudo.
    if medadedados.idcampo = "proposta.cliente.cpf"
    then medadesao.cpf = dec(medadedados.conteudo).
    if medadedados.idcampo = "proposta.vigenciaPeriodoEmMeses"
    then do:

        vqtdparcelas = int(medadedados.conteudo) no-error.
        if vqtdparcelas = 0 or vqtdparcelas = ? then vqtdparcelas = 12.

        do vpar = 1 to vqtdparcelas:
            create medaderepasse.
            medaderepasse.idadesao = medadesao.idadesao.
            medaderepasse.adepar   = vpar.
            medaderepasse.vlRepasse = medprodu.valorRepasseMes.
            medaderepasse.rstatus       = yes.

            if vpar = 1
            then do:
                vmes = month(medadesao.dataTransacao) + 1.
                vano = year(medadesao.dataTransacao).
                vdia = day(medadesao.dataTransacao).

                if vmes = 13
                then do:
                    vmes = 1.
                    vano = vano + 1.
                end.
                vdtvenc = ?.
                vdtvenc = date(vmes,vdia,vano) no-error.
                if vdtvenc = ?
                then do vd = vdia to 1 by -1:
                    vdtvenc = date(vmes,vd,vano) no-error.
                    if vdtvenc <> ? then leave.
                end.
            end.
            else do:
                vdia = day(medadesao.dataTransacao).
                vmes = vmes + 1.
                if vmes = 13
                then do:
                    vmes = 1.
                    vano = vano + 1.
                end.
                vdtvenc = ?.
                vdtvenc = date(vmes,vdia,vano) no-error.
                if vdtvenc = ?
                then do vd = vdia to 1 by -1:
                    vdtvenc = date(vmes,vd,vano) no-error.
                    if vdtvenc <> ? then leave.
                end.
            end.
            medaderepasse.dtvenc        = vdtvenc.
        end.
    end.
end.

create ttadesaolebes.
ttadesaolebes.idadesao = string(vidadesao).


hsaida  = temp-table ttadesaolebes:handle.

lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).
message string(vlcsaida).






