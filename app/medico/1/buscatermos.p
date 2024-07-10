/* medico na tela 042022 - helio */

def input  parameter vlcentrada as longchar.
def var vdata as date.
def temp-table ttentrada no-undo serialize-name "dadosEntrada"
    field idAdesaoLebes as char.


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
def temp-table ttadesao  no-undo serialize-name "adesao"
    field idAdesaoLebes as char serialize-name "idAdesao"
    field idPropostaAdesaoLebes as char
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

def dataset dadosAdesao for ttadesao, tttermos.

hsaida  = dataset dadosAdesao:handle.

def var vconteudo as char.
def var vlinha as char.
def var vid as int.
DEFINE VARIABLE textFile AS LONGCHAR NO-UNDO.

find medadesao where medadesao.idadesao = int(ttentrada.idAdesaoLebes) no-lock.
find cmon where cmon.etbcod = medadesao.etbcod and cmon.cmocod = medadesao.cmocod no-lock.

create ttadesao.
ttadesao.idAdesaoLebes         = string(medadesao.idAdesao).
ttadesao.idPropostaAdesaoLebes = medadesao.idPropostaAdesaoLebes.
ttadesao.dataTransacao         = string(year(medadesao.dataTransacao)) + "-" + 
                                 string(month(medadesao.dataTransacao),"99") + "-" + 
                                 string(day(medadesao.dataTransacao),"99").
ttadesao.etbcod                = string(medadesao.etbcod).
ttadesao.numeroComponente      = string(cmon.cxacod).
ttadesao.nsuTransacao          = medadesao.nsuTransacao.

vid = 1.
COPY-LOB FROM FILE ("/admcom/progr/med/termoadesao_" + trim(CAPS(medadesao.idmedico)) + ".txt") TO textFile.

create tttermos.
tttermos.id = string(vid).
tttermos.data = string(year(today)) + "-" + string(month(today),"99") + "-" + string(day(today),"99").
tttermos.codigo = "TERMO_CHAMA_DOUTOR_DOC24". /*identificado de layout do termo*/
tttermos.conteudo = string(textFile).
tttermos.extensao = "TXT".
tttermos.nome = "Bilhete Termica".
tttermos.tipo = "TERMO_ADESAO_TITULAR".

    
    for each medadedados of medadesao no-lock.
        if medadedados.idcampo = "proposta.cliente.cpf"
        then tttermos.conteudo  = replace(tttermos.conteudo,"\{proposta.cliente.cpf\}",medadedados.conteudo).
        if medadedados.idcampo = "proposta.cliente.nome"
        then tttermos.conteudo  = replace(tttermos.conteudo,"\{proposta.cliente.nome\}",medadedados.conteudo).
        if medadedados.idcampo = "proposta.dataInicioVigencia"
        then do:
            vdata = date(int(entry(2,medadedados.conteudo,"-")),
                         int(entry(3,medadedados.conteudo,"-")),
                         int(entry(1,medadedados.conteudo,"-"))).
            tttermos.conteudo  = replace(tttermos.conteudo,"\{proposta.dataInicioVigencia\}",string(vdata,"99/99/9999")).
        end.            
        if medadedados.idcampo = "proposta.dataFimVigencia"
        then do:
            vdata = date(int(entry(2,medadedados.conteudo,"-")),
                         int(entry(3,medadedados.conteudo,"-")),
                         int(entry(1,medadedados.conteudo,"-"))).
            tttermos.conteudo  = replace(tttermos.conteudo,"\{proposta.dataFimVigencia\}",string(vdata,"99/99/9999")).
        end.    
        if medadedados.idcampo = "proposta.cliente.dataNascimento"
        then do:
            vdata = date(int(entry(2,medadedados.conteudo,"-")),
                         int(entry(3,medadedados.conteudo,"-")),
                         int(entry(1,medadedados.conteudo,"-"))).
            tttermos.conteudo  = replace(tttermos.conteudo,"\{proposta.cliente.dataNascimento\}",string(vdata,"99/99/9999")).
        end.    
    end.
    tttermos.conteudo  = replace(tttermos.conteudo,"\{valorServico\}",
                    trim(string(medadesao.valorServico,"->>>>>>>>>>>>>>>>>>>>>>>>>>>9.99"))).
    tttermos.conteudo  = replace(tttermos.conteudo,"\{dataTransacao\}",
                    string(medadesao.dataTransacao,"99/99/9999")).

                    {}                    
    


def var varquivo as char.
def var ppid as char.
INPUT THROUGH "echo $PPID".
DO ON ENDKEY UNDO, LEAVE:
IMPORT unformatted ppid.
END.
INPUT CLOSE.

varquivo  = "/u/bsweb/works/apimedicobuscatermos" + string(today,"999999") + replace(string(time,"HH:MM:SS"),":","") +
          trim(ppid) + ".json".

lokJson = hsaida:WRITE-JSON("FILE", varquivo, TRUE).

os-command value("cat " + varquivo).
os-command value("rm -f " + varquivo)


