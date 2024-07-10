/*
#1 jun/2017 - cosulta duplicada
*/

def input  parameter setbcod        as int.
/*** spcconsulta.p ***/
def input  parameter par-rec        as recid.
def output parameter par-ok         as log.
def output parameter spc-conecta    as log.

def var varqlog as char.
def var vlog    as log.

find clien where recid(clien) = par-rec no-lock no-error.
if not avail clien then return.

def new shared var t-reg as int init 0.
def new shared var d-reg as int init 0.

def shared temp-table tp-titulo like titulo
    index dt-ven titdtven
    index titnum /*is primary unique*/ empcod
                 titnat 
                 modcod 
                 etbcod 
                 clifor 
                 titnum 
                 titpar.

function formatadata returns character
    (input par-data as date).

    if par-data = ?
    then return "00000000".
    else return string(day(par-data), "99") +
                string(month(par-data), "99") +
                string(year(par-data), "9999").

end function.


function formatanumero returns character
    (input par-texto    as char,
     input par-tamanho  as int).

    def var vct         as int.
    def var vchr        as char.
    def var vretorno    as char.

    par-texto = trim(par-texto).
    do vct = 1 to length(par-texto).
        vchr = substring(par-texto, vct, 1).
        if vchr >= "0" and vchr <= "9"
        then vretorno = vretorno + vchr.
    end.

    do vct = length(vretorno) to par-tamanho - 1.
        vretorno = "0" + vretorno.
    end.
    return substr(vretorno, 1, par-tamanho).

end function.


def var p-cgccpf   as char.
def var p-dtinicial     as date.
def var p-dtfinal       as date.
def var p-autorizacao   as char.
def var codigo-operadora   as char init "RS001".
def var versao-protocolo   as char. 
def var versao-software    as int. 
def var tipo-conexao       as char init "00006".
def var tipo-dispositivo   as char.
def var codigo-dispositivo as char init "0000000000".
def var sigla-usuario      as char. 
def var parametro-solicita as char.                                 
def var parametro-envia    as char.
def var p-og as char.
def var tipo-cpfcnpj    as int.
def var numero-autorizacao as char.
def var vseq            as int.
def var vdir-work       as char.
def var vspc-etbcod_spc as int  init 1.
def var vspc-senha      as char init "LEBES001".
def var vspc-associado  as int  init 44640.
def var v-quem as int.

find estab where estab.etbcod = setbcod no-lock.
if estab.spc-etbcod > 0
then assign
        vspc-etbcod_spc = estab.spc-etbcod
        vspc-senha      = estab.spc-senha.

numero-autorizacao = p-autorizacao.
parametro-solicita = "CONSULTAR".
    
assign
    vseq      = 1
    sigla-usuario = "LOJA001".

    p-cgccpf = trim(clien.ciccgc).
    v-quem = 1.

    if clien.estciv = 2 and
/***
       clien.entrefcom[2] <> ? and
       clien.entrefcom[2] <> "" and
***/
       clien.prorenda[1] = 0
    then assign
            p-cgccpf = trim(substr(string(clien.conjuge),51,20))
            v-quem = 2.

    if p-cgccpf = "" or
       p-cgccpf = ?
    then assign
            p-cgccpf = trim(clien.ciccgc)
            v-quem = 1.   
    
    tipo-cpfcnpj = if clien.tippes = no
                   then 2 else 1.    

    versao-protocolo = "2006031".
    versao-software = 0.
    p-og = "002001" +
       string(vseq,              "999999") +
       string(codigo-operadora,  "x(5)")    + /* "RS001" */
       string(vspc-associado,  "99999")   + /* vspccod */
       string(vspc-etbcod_spc, "99999")   + /* vspc-etbcod_spc */
       string(vspc-senha,      "x(10)")   + /* vspc-senha */
       string(versao-protocolo,  "9999999") + /* "2004061" */
       string(versao-software,   "9999999") + /* 0 */
       string(tipo-conexao,      "99999") +
       string(tipo-dispositivo,  "x(10)") +
       string(codigo-dispositivo,"9999999999") +
       string(sigla-usuario,     "x(20)") +
       string(3, "99") +   /* ocorrencia - Credito cheque */
       string(2, "9")  +   /* operacao - completa */
       string(dec(p-cgccpf),    "99999999999999") +
       string(tipo-cpfcnpj, "9") +
       string(0, "999999999999999") + /* codigo */
       string("","x(70)")          + /* nome */
       string(0, "99999999")       +
       string("","x(1)")           + /* sexo */
       string("","x(70)")          + /* nome da mae */
       string(0, "9999")           + /* ddd */
       string(0, "99999999")       + /* telefone */
       string(0, "999")  +      /* praca de compensacao */
       string(0, "999")  +      /* banco */
       string(0, "9999") +      /* agencia */
       string(0, "99999999999999999999") +    /* codigo */
       string(0, "999999") +         /* desde */
       string(0, "999999") +         /* cheque */
       string(0, "99") +             /* qtde cheques */
       string(0, "99999999") +       /* CEP */
       string(1, "99") +             /* 1 = consulta */
       string(0, "99999999999999") + /* valor */
       string(0, "99")     +         /* parcelas */
       string(0, "99999999") +       /* dt.primeira */
       string(0, "99999999999999") + /* valor entrada */
       string(0, "99999999999999") + /* renda */
       string(0, "999999") +         /* restrico SPC */
       string(0, "999999") +         /* restrico SPC */
       string(0, "9") +              /* resumida */
       string(1, "9") +              /* spc brasil */
       string(0, "9") +              /* Cheque sustado nacional */
       string(0, "9") +              /* Banrisul */
       string(0, "9") +              /* SRF */
       string(0, "9").               /* flag de continuacao */.

parametro-envia = parametro-envia + p-og.
parametro-envia = parametro-envia + "FIM".

if parametro-envia = ?
then parametro-envia = "".

vdir-work = "/u/bsweb/works/cpf" + string(clien.clicod).

varqlog = "/u/bsweb/log/con-spc" + string(clien.clicod) + ".log".
unix silent rm -f value(varqlog).
if vlog
then do.         
    output to value(vdir-work + ".ent.log").
    put unformatted parametro-envia.
    output close.

    output to value(varqlog) append.
    put "FASE 9 - CONSULTA AO SPC - CLIENTE" skip.
    put "Consultando CPF do Titular: " p-cgccpf skip.
    output close.
end.

run ./progr/pdv/spcsocket_v02.p (input parametro-solicita, 
                     input parametro-envia,
                     vdir-work + ".sai",
                     output spc-conecta).
par-ok = spc-conecta.
if par-ok = no
then return.

run ./progr/pdv/spcconres.p (setbcod,
                          par-rec,
                          "GRAVA",
                          vdir-work + ".sai", v-quem,
                          varqlog,
                          output par-ok).

/***
def var ind-cpf as log.
    ind-cpf = no.

    if par-ok = yes and
       clien.estciv = 2 and
       clien.prorenda[1] = 0 and
       v-quem = 1 /* #1 */
    then do:
        p-cgccpf = trim(substr(string(clien.conjuge),51,20)).
        if p-cgccpf <> "" and
           trim(clien.ciccgc) <> p-cgccpf
        then run cpf.p (input p-cgccpf, output ind-cpf).
    end.

    if ind-cpf
    then do.
        if vlog
        then do.
            output to value(varqlog) append.
            put "Consultando CPF do Conjuge: " p-cgccpf.
            output close.
        end.

        tipo-cpfcnpj = if clien.tippes = no
                       then 2 else 1.    

        versao-protocolo = "2006031".
        versao-software = 0.
        p-og = "002001" +
        string(vseq,              "999999") +
        string(codigo-operadora,  "x(5)")    + /* "RS001" */
        string(vspc-associado,    "99999")   + /* vspccod */
        string(vspc-etbcod_spc,   "99999")   + /* vspc-etbcod_spc */
        string(vspc-senha,        "x(10)")   + /* vspc-senha */
        string(versao-protocolo,  "9999999") + /* "2004061" */
        string(versao-software,   "9999999") + /* 0 */
        string(tipo-conexao,      "99999") +
        string(tipo-dispositivo,  "x(10)") +
        string(codigo-dispositivo,"9999999999") +
        string(sigla-usuario,     "x(20)") +
        string(3, "99") +   /* ocorrencia - Credito cheque */
        string(2, "9")  +   /* operacao - completa */
        string(dec(p-cgccpf),    "99999999999999") +
        string(tipo-cpfcnpj, "9") +
        string(0, "999999999999999") + /* codigo */
        string("","x(70)")          + /* nome */
        string(0, "99999999")       +
        string("","x(1)")           + /* sexo */
        string("","x(70)")          + /* nome da mae */
        string(0, "9999")           + /* ddd */
        string(0, "99999999")       + /* telefone */
        string(0, "999")  +      /* praca de compensacao */
        string(0, "999")  +      /* banco */
        string(0, "9999") +      /* agencia */
        string(0, "99999999999999999999") +    /* codigo */
        string(0, "999999") +         /* desde */
        string(0, "999999") +         /* cheque */
        string(0, "99") +             /* qtde cheques */
        string(0, "99999999") +       /* CEP */
        string(1, "99") +             /* 1 = consulta */
        string(0, "99999999999999") + /* valor */
        string(0, "99")     +         /* parcelas */
        string(0, "99999999") +       /* dt.primeira */
        string(0, "99999999999999") + /* valor entrada */
        string(0, "99999999999999") + /* renda */
        string(0, "999999") +         /* restrico SPC */
        string(0, "999999") +         /* restrico SPC */
        string(0, "9") +              /* resumida */
        string(1, "9") +              /* spc brasil */
        string(0, "9") +              /* Cheque sustado nacional */
        string(0, "9") +              /* Banrisul */
        string(0, "9") +              /* SRF */
        string(0, "9").               /* flag de continuacao */.

        parametro-envia = p-og.
        parametro-envia = parametro-envia + "FIM".

        if parametro-envia = ?
        then parametro-envia = "".

        vdir-work = "/u/bsweb/works/" + lc(p-ocor) + p-cgccpf.

        if vlog
        then do.
            output to value(vdir-work + ".ent").
            put unformatted parametro-envia.
            output close.
            /***unix silent chmod 777 value(vdir-work + ".ent").***/

            output to value(varqlog) append.
            put "FASE 9 - CONSULTA AO SPC - CONJUGE" skip.
            output close.
        end.

        run ./progr/pdv/spcsocket_v02.p (input parametro-solicita, 
                     input parametro-envia,
                     /*** #1 vtambuffer,***/
                     vdir-work + ".sai",
                     output par-ok,
                     output spc-conecta).
        if par-ok = no
        then return.

        v-quem = 2.
        run ./progr/pdv/spcconres.p (setbcod, recid(clien),
                          if par-param = "" then "GRAVA" else par-param,
                          vdir-work + ".sai", v-quem,
                          output par-ok).
    end. 
***/

def var vpag-ok as log.
if d-reg > 0 and
   d-reg = t-reg
then do:
    vpag-ok = yes.

    for each tp-titulo where
             tp-titulo.clifor = clien.clicod and
             tp-titulo.titnat = no and
             tp-titulo.modcod = "CRE" and
             tp-titulo.titdtpag = ? 
             no-lock:
        if tp-titulo.titsit  <> "LIB"
        then next.
        find first titulo where titulo.empcod = tp-titulo.empcod and
                                titulo.titnat = tp-titulo.titnat and
                                titulo.modcod = tp-titulo.modcod and
                                titulo.etbcod = tp-titulo.etbcod and
                                titulo.clifor = tp-titulo.clifor and
                                titulo.titnum = tp-titulo.titnum and
                                titulo.titpar = tp-titulo.titpar
                                no-lock no-error.
        if avail titulo and
           titulo.titsit <> "LIB"
        then next.                         
        if (today - tp-titulo.titdtven) > 45
        then do:
            vpag-ok = no.
            leave.
        end.
    end.            
    if vpag-ok then par-ok = yes.
end.                       

