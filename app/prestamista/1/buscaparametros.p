/* helio 20012022 - [UNIFICAÇÃO ZURICH - FASE 2] NOVO CÁLCULO PARA SEGURO PRESTAMISTA MÓVEIS NA PRÉ-VENDA */

def input  parameter vlcentrada as longchar.

def var vetbcod as int.
def var vprocod as int.
def var vlcsaida   as longchar.
def var vsaida as char.

def var lokjson as log.
def var hentrada   as handle.

def var hsaida   as handle.


def temp-table ttsaida  no-undo serialize-name "conteudoSaida"
    field tstatus        as int serialize-name "status"
    field descricaoStatus      as char.

def NEW shared temp-table ttplanos  no-undo serialize-name "parametros"
    like segprestpar.

    run prestamista/1/plersegprestpar.p.


hsaida  = temp-table ttplanos:handle.

lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).


/*vsaida  = replace(replace(string(vlcsaida),"[",""),"]","").*/

message string(vlcsaida).
