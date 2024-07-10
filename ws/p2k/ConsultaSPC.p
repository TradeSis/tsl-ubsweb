/*
#1 18.06.2018 - Deixar mesma logica do ConsultaCliente
*/
{acha.i}
{bsxml.i}

def NEW shared temp-table tp-titulo like titulo
    index dt-ven titdtven 
    index titnum /*is primary unique*/ empcod  
                                   titnat  
                                   modcod  
                                   etbcod 
                                   clifor 
                                   titnum  
                                   titpar.

def var par-ok  as log.
def var vcliente as int.
def var vclinom  as char.
def var vcpf  as char.
def var vchar as char.
def var vdtnasc as date.

/* buscarplanopagamento */
def var vatraso as log.
def var vspc_descr_motivo as char.
def var vspc_cod_motivo_cancelamento as char.
def new global shared var setbcod       as int.
def var vstatus as char.   
def var vmensagem_erro as char.
def var vmen-spc as char.
def var vdat-spc as date.
def var vcon-spc as char.
def var vale-spc as char.
def var vcre-spc as char.
def var vche-spc as char.
def var vfil-spc as char.
def var vnac-spc as char.

/* PDV hiscli2.p */
def NEW SHARED var pagas-db as int.

def NEW SHARED var maior-atraso as int /***like plani.pladat***/.
def NEW SHARED var vencidas like clien.limcrd.
def NEW SHARED var v-mes as int format "99".
def NEW SHARED var v-ano as int format "9999".
def NEW SHARED var v-acum like clien.limcrd.
def NEW SHARED var qtd-contrato as int format ">>>9".
def NEW SHARED var parcela-paga    as int format ">>>>9".
def NEW SHARED var parcela-aberta  as int format ">>>>9".
def NEW SHARED var qtd-15       as int format ">>>>9".
def NEW SHARED var qtd-45       as int format ">>>>9".
def NEW SHARED var qtd-46       as int format ">>>>9".
def NEW SHARED var vrepar       as log format "Sim/Nao".
def NEW SHARED var v-media      like clien.limcrd.
def NEW SHARED var ult-compra   like plani.pladat.
def NEW SHARED var sal-aberto   like clien.limcrd.
def NEW SHARED var lim-calculado like clien.limcrd format "->>,>>9.99".
def NEW SHARED var cheque_devolvido like plani.platot.
def NEW SHARED var vclicod like clien.clicod.
def NEW SHARED var vtotal like plani.platot.
def NEW SHARED var vqtd        as int.
def NEW SHARED var proximo-mes like clien.limcrd.

/* SPC */
def var par-spc     as log init yes.
def var spc-conecta as log init yes.
def var vlibera-cli as log init yes.
def NEW shared temp-table tp-contrato /***like fin.contrato***/
    field contnum   like contrato.contnum
    field etbcod    like contrato.etbcod
    field dtinicial like contrato.dtinicial
    field vltotal   like contrato.vltotal
    index contrato is primary unique etbcod contnum.
/* */

def shared temp-table ConsultaSPC
    field codigo_filial   as char
    field codigo_operador as char
    field numero_pdv      as char
    field codigo_cliente  as char
    field cpf             as char
    field tipo_pessoa     as char
    field nome_pessoa     as char
    field data_nascimento as char.

find first ConsultaSPC no-lock no-error.
if avail ConsultaSPC
then do.
    vstatus = "S".
    vcpf = ConsultaSPC.cpf.

    if ConsultaSPC.tipo_pessoa = "cliente" or
       ConsultaSPC.tipo_pessoa = "conjuge"
    then do.
        vcliente = int(ConsultaSPC.codigo_cliente) no-error.
    
        if vcliente <= 1
        then assign
                vstatus = "E"
                vmensagem_erro = "Codigo do cliente invalido".
        else do.
            find clien where clien.clicod = vcliente no-lock no-error.
            if not avail clien
            then assign
                    vstatus = "E"
                    vmensagem_erro = "Cliente " + ConsultaSPC.codigo_cliente + 
                                     " nao encontrado".
        end.
    end.

    else if ConsultaSPC.tipo_pessoa = "clientenovo"
    then do.
        run cpf.p (ConsultaSPC.cpf, output par-ok).
        if par-ok
        then do.
            if length(ConsultaSPC.nome_pessoa) < 9
            then assign
                    par-ok = false
                    vstatus = "E"
                    vmensagem_erro = "Nome invalido".
        end. 
        else assign
                vstatus = "E"
                vmensagem_erro = "CPF invalido".
        
        if par-ok
        then do.
            find first clien where clien.ciccgc = ConsultaSPC.cpf
                no-lock no-error.
            if avail clien
            then assign
                    vcliente = clien.clicod.

            vchar = ConsultaSPC.data_nascimento.
            if testavalido(vchar)
            then vdtnasc = date(int(substring(vchar,6,2)),
                              int(substring(vchar,9,2)),
                              int(substring(vchar,1,4))) no-error.
            if vdtnasc = ? or vdtnasc = 01/01/1900
            then assign
                    vstatus = "E"
                    vmensagem_erro = "Data de nascimento invalida".
        end.
    end.
    else assign
            vstatus = "E"
            vmensagem_erro = "Tag tipo_pessoa invalido:" +
                    ConsultaSPC.tipo_pessoa.
end.
else assign
        vstatus = "E"
        vmensagem_erro = "Parametros de Entrada nao recebidos".

if vstatus = "S"
then do.
    setbcod = int(ConsultaSPC.codigo_filial).
    vatraso = no.

    if ConsultaSPC.tipo_pessoa = "clientenovo" and
       vcliente = 0
    then do on error undo.
        /* cadastrar cliente */
        run ./progr/p-geraclicod.p (output vcliente).
        
        create clien.
        assign
            clien.clicod = vcliente
            clien.ciccgc = ConsultaSPC.cpf
            clien.clinom = caps(ConsultaSPC.nome_pessoa)
            clien.tippes = yes
            clien.dtnasc = vdtnasc
            clien.etbcad = setbcod.

        create cpclien.
        assign 
            cpclien.clicod     = clien.clicod
            cpclien.var-char11 = ""
            cpclien.datexp     = today.
    end.
    
    run ./progr/hiscli_05.p (vcliente).

/* #1
    find first clispc where clispc.clicod = clien.clicod
                        and clispc.dtcanc = ?
                      no-lock no-error.

*/
    if clien.tippes /* #1 and
       not avail clispc */
    then do.
        run ./progr/pdv/spcpreconsulta.p (?, recid(clien),
                                          output par-spc,
                                          output vlibera-cli).
        if par-spc
        then do.
            run ./progr/pdv/spcconsulta_v02.p (setbcod,
                               recid(clien),
                               output par-spc,
                               output spc-conecta).
            /* #1 */
            if not par-spc
            then vlibera-cli = no.
        end.
    end. 
end.

if avail clien
then
    if ConsultaSPC.tipo_pessoa = "conjuge"
    then vclinom = Texto(substr(clien.conjuge,1,50)).
    else assign
            vclinom = Texto(clien.clinom)
            vcpf    = clien.ciccgc.

BSXml("ABREXML","").
bsxml("abretabela","return").

bsxml("status",vstatus).
bsxml("mensagem_erro",vmensagem_erro).
bsxml("codigo_filial",ConsultaSPC.codigo_filial).
bsxml("numero_pdv",ConsultaSPC.numero_pdv).
bsxml("codigo_cliente",string(vcliente)).
bsxml("cpf", vcpf).
bsxml("nome",vclinom).

if avail clien and clien.dtnasc <> ?
then bsxml("data_nascimento",EnviaData(clien.dtnasc)).
else bsxml("data_nascimento","1900-01-01T00:00:00").

    if avail clien
    then do:
        find cpclien where cpclien.clicod = clien.clicod no-lock no-error.
         
        /* consulta spc */   

        vspc_cod_motivo_cancelamento = "".
        vspc_descr_motivo = "".

/* #1
        if avail clispc or
           (acha("OK",clien.entrefcom[2]) <> ?  and
            acha("OK",clien.entrefcom[2]) = "NAO")
*/
        if not vlibera-cli /* #1 */
        then assign
                vmen-spc = "CLIENTE COM REGISTRO"
                vspc_cod_motivo_cancelamento = "93"
                vspc_descr_motivo = "CLIENTE COM RESTRICAO SPC".
        else vmen-spc = "CLIENTE SEM REGISTRO".

        vdat-spc = date(clien.entrefcom[1]).
        vfil-spc = acha("filial",clien.entrefcom[2]).
        vcon-spc = acha("consultas",clien.entrefcom[2]).
        vale-spc = acha("alertas",clien.entrefcom[2]).
        vcre-spc = acha("credito",clien.entrefcom[2]).
        vche-spc = acha("cheques",clien.entrefcom[2]).
        vnac-spc = acha("nacional",clien.entrefcom[2]).
end.

    bsxml("resultado_consulta_spc",vmen-spc).
    if vfil-spc = ?
    then bsxml("filial_efetuou_consulta",""). 
    else bsxml("filial_efetuou_consulta",vfil-spc). 

    bsxml("data_consulta", EnviaData(vdat-spc)).        
    bsxml("quantidade_consultas_realizadas",vcon-spc). 
    bsxml("registros_de_alertas",vale-spc). 
    bsxml("registro_do_credito",vcre-spc). 
    bsxml("registro_de_cheques",vche-spc). 
    bsxml("registro_nacional",vnac-spc). 
    bsxml("spc_cod_motivo_cancelamento",vspc_cod_motivo_cancelamento). 
    bsxml("spc_descr_motivo",vspc_descr_motivo). 

    /* consulta serasa */
    bsxml("resultado_consulta_serasa",""). 
    bsxml("serasa_cod_motivo_cancelamento","").
    bsxml("serasa_descr_motivo",""). 
    /* consulta crediario */
    if vatraso = no
    then do:
        bsxml("resultado_consulta_crediario",""). 
        bsxml("crediario_cod_motivo_cancelamento",""). 
        bsxml("crediario_descr_motivo",""). 
    end.
    else do:
        bsxml("resultado_consulta_crediario","CLIENTE COM REGISTRO"). 
        bsxml("crediario_cod_motivo_cancelamento","94"). 
        bsxml("crediario_descr_motivo","CLIENTE COM RESTRICAO CREDIARIO"). 
    end.

    /* cosulta limite */
    bsxml("limite_cod_motivo_cancelamento","95"). 
    bsxml("limite_descr_motivo","CLIENTE COM LIMITE DE CREDITO INSUFICIENTE"). 

    /* nota credit score */
    if not avail cpclien
    then bsxml("nota",""). 
    else bsxml("nota",string(cpclien.var-int3)).

bsxml("fechatabela","return").
BSXml("FECHAXML","").

