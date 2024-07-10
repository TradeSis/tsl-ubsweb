/* EfetivaPagamentoBonus */

def var vstatus as char.   
def var vmensagem_erro as char.
def var vchar as char.
def var vdec as dec.
def var vdata as date.
def var vvlcob as dec.
def var vdtven as date.
def var vcli as int.

def shared temp-table EfetivaPagamentoBonus
    field data_operacao as char
    field codigo_filial as char
    field numero_pdv    as char
    field codigo_cliente as char
    field nome_bonus as char
    field codigo_filial_bonus as char
    field numero_bonus as char
    field venc_bonus as char
    field vlr_bonus as char.
  
find first efetivapagamentobonus no-lock no-error.

vstatus = if avail efetivapagamentobonus
          then "S"
          else "E".
vmensagem_erro = if avail efetivapagamentobonus
                 then "S"
                 else "Parametros de Entrada nao recebidos.".

{bsxml.i}

BSXml("ABREXML","").
bsxml("abretabela","return").
        
vchar = efetivapagamentobonus.venc_bonus.
if testavalido(vchar)
then do:
    vdata = date(int(substring(vchar,6,2)),
                 int(substring(vchar,9,2)),
                 int(substring(vchar,1,4))) no-error.
    if vdata <> ?
    then vdtven = vdata.                                 
end.

vvlcob = 0.
if testavalido(efetivapagamentobonus.vlr_bonus)
then do:
    vdec = dec(efetivapagamentobonus.vlr_bonus) no-error.
    if vdec <> ?
    then vvlcob = vdec.
end.

if testavalido(efetivapagamentobonus.codigo_cliente)
then do:
    vdec = int(efetivapagamentobonus.codigo_cliente) no-error.
    if vdec <> ?
    then vcli = int(vdec).
end.

do on error undo.
    find first titulo where
            titulo.titnat = yes and
            titulo.clifor = vcli and
            titulo.titnum = efetivapagamentobonus.numero_bonus and
            titulo.modcod = "BON" and
            titulo.etbcod = int(efetivapagamentobonus.codigo_filial_bonus) and
            titulo.titdtpag = ? and
            titulo.titdtven = vdtven and
            titulo.titvlcob = vvlcob
        exclusive no-error.
    if avail titulo
    then do:
        assign
            titulo.titsit   = "PAG"
            titulo.titvlpag = titulo.titvlcob
            titulo.titdtpag = today.
        vmensagem_erro = "Pagamento - " + efetivapagamentobonus.numero_bonus + 
                " - Efetivado".
    end.
    else assign
         vstatus = "E"
         vmensagem_erro = "Pagamento - " + efetivapagamentobonus.numero_bonus + 
            " - NAO Encontrado".
end.

bsxml("status",vstatus).
bsxml("mensagem_erro",vmensagem_erro).
bsxml("codigo_filial",string(efetivapagamentobonus.codigo_filial)).
bsxml("numero_pdv",string(efetivapagamentobonus.numero_pdv)).

bsxml("fechatabela","return").
BSXml("FECHAXML","").

