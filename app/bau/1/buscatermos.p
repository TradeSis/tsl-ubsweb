/* bau 002022 - helio */

def input  parameter vlcentrada as longchar.
def var vdata as date.
def temp-table ttentrada no-undo serialize-name "dadosEntrada"
    field idPagamento as char.


def var vlcsaida   as longchar.

def var vsaida as char.

def var lokjson as log.
def var hsaida   as handle.
def var hentrada   as handle.


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

hentrada = temp-table ttentrada:handle.
lokJSON = hEntrada:READ-JSON("longchar",vlcentrada, "EMPTY").

find first ttentrada no-error.


/*lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).
message string(vlcsaida).*/
def temp-table ttpagamento  no-undo serialize-name "pagamento"
    field idPagamento as char serialize-name "idPagamento"
    field idPropostaLebes as char
    field dataTransacao as char
    field etbcod    as char serialize-name "codigoLoja"
    field numeroComponente as char
    field nsuTransacao as char.
    
def  temp-table tttermos no-undo serialize-name "termos"
  field id as char
  field data    as char
  field codigo  as char
  field conteudo as char
  field extensao    as char
  field nome        as char
  field tipo as char.

def dataset dadosPagamento for ttpagamento, tttermos.

hsaida  = dataset dadosPagamento:handle.

def var vconteudo as char.
def var vlinha as char.
def var vid as int.
DEFINE VARIABLE textFile AS LONGCHAR NO-UNDO.

find baupagamento where baupagamento.idpagamento = int(ttentrada.idpagamento) no-lock.
find cmon where cmon.etbcod = baupagamento.etbcod and cmon.cmocod = baupagamento.cmocod no-lock.

create ttpagamento.
ttpagamento.idpagamento       = string(baupagamento.idpagamento).
ttpagamento.idPropostaLebes = baupagamento.idPropostaPagamentoLebes.
ttpagamento.dataTransacao         = string(year(baupagamento.dataTransacao)) + "-" + 
                                 string(month(baupagamento.dataTransacao),"99") + "-" + 
                                 string(day(baupagamento.dataTransacao),"99").
ttpagamento.etbcod                = string(baupagamento.etbcod).
ttpagamento.numeroComponente      = string(cmon.cxacod).
ttpagamento.nsuTransacao          = baupagamento.nsuTransacao.

vid = 1.
COPY-LOB FROM FILE ("/admcom/progr/bau/termopagamento.txt") TO textFile.

create tttermos.
tttermos.id = string(vid).
tttermos.data = string(year(today)) + "-" + string(month(today),"99") + "-" + string(day(today),"99").
tttermos.codigo = "TERMO_JEQUITI". /*identificado de layout do termo*/
tttermos.conteudo = string(textFile).
tttermos.extensao = "TXT".
tttermos.nome = "Bilhete Termica".
tttermos.tipo = "TERMO_PAGAMENTO".

def var vbauparcelas as char.

    
    vbauparcelas = "".
    for each baupagparcelas of baupagamento no-lock.
        vbauparcelas = vbauparcelas + 
            "    Carne: " + string(baupagparcelas.codigoBarras) + "/" + string(baupagparcelas.adepar) + " R$ " +
                    trim(string(baupagparcelas.valor,">>>>>>>>9.99")) + "     " +
                    chr(10).
    end.
    
    tttermos.conteudo = replace(tttermos.conteudo,"\{bau.parcelas\}",vbauparcelas).
 
    for each baupagdados of baupagamento no-lock.
        if baupagdados.idcampo = "proposta.cliente.cpf"
        then tttermos.conteudo  = replace(tttermos.conteudo,"\{proposta.cliente.cpf\}",baupagdados.conteudo).
        if baupagdados.idcampo = "proposta.cliente.nome"
        then tttermos.conteudo  = replace(tttermos.conteudo,"\{proposta.cliente.nome\}",baupagdados.conteudo).
        if baupagdados.idcampo = "proposta.dataInicioVigencia"
        then do:
            vdata = date(int(entry(2,baupagdados.conteudo,"-")),
                         int(entry(3,baupagdados.conteudo,"-")),
                         int(entry(1,baupagdados.conteudo,"-"))).
            tttermos.conteudo  = replace(tttermos.conteudo,"\{proposta.dataInicioVigencia\}",string(vdata,"99/99/9999")).
        end.            
        if baupagdados.idcampo = "proposta.dataFimVigencia"
        then do:
            vdata = date(int(entry(2,baupagdados.conteudo,"-")),
                         int(entry(3,baupagdados.conteudo,"-")),
                         int(entry(1,baupagdados.conteudo,"-"))).
            tttermos.conteudo  = replace(tttermos.conteudo,"\{proposta.dataFimVigencia\}",string(vdata,"99/99/9999")).
        end.    
        if baupagdados.idcampo = "proposta.cliente.dataNascimento"
        then do:
            vdata = date(int(entry(2,baupagdados.conteudo,"-")),
                         int(entry(3,baupagdados.conteudo,"-")),
                         int(entry(1,baupagdados.conteudo,"-"))).
            tttermos.conteudo  = replace(tttermos.conteudo,"\{proposta.cliente.dataNascimento\}",string(vdata,"99/99/9999")).
        end.    
        
        
    end.
    tttermos.conteudo  = replace(tttermos.conteudo,"\{valorServico\}",
                    trim(string(baupagamento.valorServico,"->>>>>>>>>>>>>>>>>>>>>>>>>>>9.99"))).
    tttermos.conteudo  = replace(tttermos.conteudo,"\{dataTransacao\}",
                    string(baupagamento.dataTransacao,"99/99/9999")).

                    {}                    
    


def var varquivo as char.
def var ppid as char.
INPUT THROUGH "echo $PPID".
DO ON ENDKEY UNDO, LEAVE:
IMPORT unformatted ppid.
END.
INPUT CLOSE.

varquivo  = "/u/bsweb/works/apibaubuscatermos" + string(today,"999999") + replace(string(time,"HH:MM:SS"),":","") +
          trim(ppid) + ".json".

lokJson = hsaida:WRITE-JSON("FILE", varquivo, TRUE).

os-command value("cat " + varquivo).
os-command value("rm -f " + varquivo)

