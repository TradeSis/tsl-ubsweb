/*#1 out/2018 Felipe -  log consulta SPC salvo em Tabela*/
{acha.i} /***WS {admcab.i}***/

def shared var t-reg as int init 0.
def shared var d-reg as int init 0.

/*** spcconres.p ***/
def input  parameter par-rec      as recid.
def input  parameter par-oper     as char.
def input  parameter par-quem     as int.
def input  parameter par-arqlog   as char.
def input  parameter par-resposta as longchar. /* #1 */
def output parameter par-ok       as log init yes.

/* PAR-QUEM = 1 CLIENTE
   PAR-QUEM = 2 CONJUGE */
find ConsSPC where recid(ConsSPC) = par-rec no-lock.   
find clien   where clien.clicod   = ConsSPC.clicod no-lock.

def var p-cgccpf  like clien.ciccgc.
def var vLetra    as char.

if PAR-QUEM = 1
then p-cgccpf = clien.ciccgc.
else p-cgccpf = trim(substr(string(clien.conjuge),51,20)).

/***WS
def temp-table tt-texto
    field tipo  as int
    field linha as char format "x(78)"

    index tipo tipo.

def buffer btt-texto       for tt-texto.
***/

def var vlinha      as char.
def var vtexto      as char.
def var vcharaux    as char.
def var vct         as int.
def var vok         as log.
def var vtipoaux    as int.
def var vtipo       as int init 700.
def var vconsulta   as int.
def var valerta     as int.
def var vregcheque  as int. /* Registro de cheque  */
def var vregcredit  as int. /* Registro de Credito */
def var vregnacion  as int. /* Registro Nacional   */
def var vqtd-consulta as int.

/* #1
if search(par-arq) = ?
then do.
    if vlog
    then do.
        output to value(par-arqlog) append.
        put unformatted "Retorno do SPC nao recebido: " par-arq skip.
        output close.
    end.
    return.
end.
*/

if par-resposta = "" 
then do:
    if par-arqlog <> ""
    then do.
        output to value(par-arqlog) append.
        put unformatted "Retorno do SPC nao recebido: " /*par-arq*/ skip.
        output close.
    end.
    return.
end.

/*#1
input from value(par-arq).
repeat on error undo, next.
    import unformatted vlinha.
*/
par-resposta = par-resposta + chr(13).

do vct = 1 to length(par-resposta).
    vletra = substr(par-resposta, vct, 1).
    if vletra = chr(10) or
       vletra = chr(13)
    then do.

/***WS
    if substr(vlinha, 1, 6) = "999999" and substr(vlinha, 13, 3) <> "000"
    then do.
        create tt-texto.
        tt-texto.tipo  = 100.
        tt-texto.linha = substr(vlinha, 13, 3) + " " + substr(vlinha, 16, 70).
    end.    
***/

    /*
        Identificacao
    */
    if substr(vlinha, 1, 6) = "002002"
    then do.
        vok = yes.
/***WS
        create tt-texto.
        tt-texto.tipo  = 200.
        tt-texto.linha = "        Nome: " + substr(vlinha, 28, 64)
                    no-error.

        create tt-texto.
        tt-texto.tipo  = 200.
        tt-texto.linha = "  Nascimento: " + 
            string(substr(vlinha, 98, 8),"99/99/9999") + 
            "   CPF: " + clien.ciccgc no-error.

        create tt-texto.
        tt-texto.tipo  = 200.
        tt-texto.linha = "         Mae: " + substr(vlinha, 107, 60)
            no-error.
***/
    end.

    if substr(vlinha, 1, 6) = "002003"
    then do.
        vok = yes.
/***WS
        find first tt-texto where tt-texto.tipo = 300 no-lock no-error.
        if not avail tt-texto
        then do.
            vtexto = substr(vlinha, 201, 3).
            case vtexto.
                when "001" then vcharaux = "Casado".
                when "002" then vcharaux = "Solteiro".
                when "003" then vcharaux = "Viuvo".
                when "004" then vcharaux = "Desquitado".
                when "005" then vcharaux = "Marital".
                when "006" then vcharaux = "Outros".
            end.
            
            create tt-texto.
            tt-texto.tipo  = 300.
            tt-texto.linha = "         Pai: " + substr(vlinha, 131, 70)
                no-error.
        
            create tt-texto.
            tt-texto.tipo  = 300.
            tt-texto.linha = "   Documento: " + substr(vlinha, 61, 20) + " " +
                             substr(vlinha, 101, 30)
                no-error.

            create tt-texto.
            tt-texto.tipo  = 300.
            tt-texto.linha = "Naturalidade: " +
                  string(trim(substr(vlinha, 274, 20)) + "/" + 
                         substr(vlinha, 314, 2), "x(23)")  + " " +
                  " Estado Civil: " + vcharaux no-error.
        
            create tt-texto.
            tt-texto.tipo  = 300.
            tt-texto.linha = "     Conjuge: " + substr(vlinha, 204, 70)
                no-error.

            create tt-texto.
            tt-texto.tipo  = 300.
            tt-texto.linha = "    Endereco: " + trim(substr(vlinha, 324, 50)) +
                " " + trim(substr(vlinha, 374, 10)) +
                " " + trim(substr(vlinha, 384, 50))
                    no-error.

            if substr(vlinha, 434, 30) <> ""
            then do.
                create tt-texto.
                tt-texto.tipo  = 300.
                tt-texto.linha = "      Bairro: " + substr(vlinha, 434, 30).
            end.

            create tt-texto.
            tt-texto.tipo  = 300.
            tt-texto.linha = 
                string("      Cidade: " + 
                       trim(substr(vlinha, 464, 40)), "x(55)") +
                "UF: " + substr(vlinha, 504, 2) +
                " CEP: " + substr(vlinha, 316, 8) no-error.
        end.
***/
    end.

    if substr(vlinha, 1, 6) = "002016"
    then do.
        vok = yes.
/***WS
        create tt-texto.
        tt-texto.tipo  = 310.
        tt-texto.linha = "Titulo de eleitor: " + substr(vlinha, 176, 15).
***/
    end.    

    /*
        Credito / Cheque
    */
    if substr(vlinha, 1, 6) = "002004" /* Registro de Credito */
    then do.
        vok = yes.
        par-ok = no. /* passagem no SPC */ 

        vcharaux = string( substr(vlinha, 18,20), "x(20)") + " " + 
                         substr(vlinha, 108, 40) no-error.
        if substr(vcharaux,1,2) <> ""  
        then do:
            t-reg = t-reg + 1.
            if vcharaux matches "*lebes*" or
               vcharaux matches "*drebes*"
            then d-reg = d-reg + 1.      
        end.         
        
        if substr(vlinha, 529, 3) <> "000"
        then assign
                vregcheque = vregcheque + 1
                vcharaux   = "Bco:"   + substr(vlinha, 149, 3) + " " +
                        substr(vlinha, 532, 10) + " " +
                        " Ag:"   + substr(vlinha, 152, 4) +
                        " Cheq:" + substr(vlinha, 156, 6).
        else assign
                vregcredit = vregcredit + 1
                vcharaux   = "Contrato:" + substr(vlinha, 148, 20).

/***WS
        create tt-texto.
        tt-texto.tipo  = 401.
        tt-texto.linha = fill(" ", 21) + vcharaux +
                         " Valor:" + 
              trim( string( dec(substr(vlinha, 214, 14)) / 100, ">>,>>9.99"))
                no-error.

        create tt-texto.
        tt-texto.tipo  = 401.
        tt-texto.linha = fill(" ", 21) +
            "Compra:" + string(substr(vlinha, 184, 8),"99/99/9999") +
            " Atraso:" + string(substr(vlinha, 192, 8),"99/99/9999") +
            " Inclusao:" + string(substr(vlinha, 176, 8),"99/99/9999")
                no-error.

        if substr(vlinha, 228, 78) <> ""
        then do.
            create tt-texto.
            tt-texto.tipo  = 401.
            tt-texto.linha = fill(" ", 21) + "Obs:" + substr(vlinha, 228, 78).
        end.

        if substr(vlinha, 328,78) <> ""
        then do.
            create tt-texto.
            tt-texto.tipo  = 401.
            tt-texto.linha = fill(" ", 21) + "Emp:" + substr(vlinha, 328,78).
        end.
***/
    end.

    /*
        Alerta
    */
    if substr(vlinha, 1, 6) = "002007"
    then do.
        vok = yes.
        valerta = valerta + 1.
/***WS
        vtipo = vtipo + 1.
        find first tt-texto where tt-texto.tipo = 700 no-lock no-error.
        if not avail tt-texto
        then do.
            create tt-texto.
            tt-texto.tipo  = 700.

            create tt-texto.
            tt-texto.tipo  = 700.
            tt-texto.linha = "Perda de Documentos".
        end.
        else do.
            create tt-texto.
            tt-texto.tipo  = vtipo.
        end.

        create tt-texto.
        tt-texto.tipo  = vtipo.
        tt-texto.linha = " Emprego:" + string(substr(vlinha, 58, 50), "x(44)") +
                         " Fone Com:" + substr(vlinha, 168, 4) + " " +
                         substr(vlinha, 172, 10).

        create tt-texto.
        tt-texto.tipo  = vtipo.
        tt-texto.linha = "Endereco:" + 
                 string(substr(vlinha,108,50) + substr(vlinha,158,10),"x(44)") +
                         " Fone Res:" + substr(vlinha, 182, 4) + " " +
                         substr(vlinha, 186, 10).

        if trim(substr(vlinha, 196, 78)) <> ""
        then do.        
            create tt-texto.
            tt-texto.tipo  = vtipo.
            tt-texto.linha = substr(vlinha, 196, 78).
        end.
***/
    end.

    if substr(vlinha, 1, 6) = "002008"
    then do.
        vok = yes.
/***WS
        vtipo = vtipo + 1.
        create tt-texto.
        tt-texto.tipo  = vtipo.
        tt-texto.linha = "Doc:" + substr(vlinha, 16, 40) + " " +
                         substr(vlinha, 56, 30).

        create tt-texto.
        tt-texto.tipo  = vtipo.
        tt-texto.linha = "Comunicacao: " + substr(vlinha, 86, 8).

        if trim(substr(vlinha, 94, 78)) <> ""
        then do.        
            create tt-texto.
            tt-texto.tipo  = vtipo.
            tt-texto.linha = substr(vlinha, 94, 78).
        end.
***/
    end.

    if substr(vlinha, 1, 6) = "002010"
    then do.
        vok = yes.
/***WS
        vtipo = vtipo + 1.
        create tt-texto.
        tt-texto.tipo  = vtipo.
        tt-texto.linha = substr(vlinha, 108, 40) +
                         " Data: " + substr(vlinha, 152, 8).
        create tt-texto.
        tt-texto.tipo  = vtipo.
        tt-texto.linha = substr(vlinha, 160, 78).
***/
    end.    

    /*
        Passagens de consulta
    */
    if substr(vlinha, 1, 6) = "002013"
    then do.
        vok = yes.
        vconsulta = vconsulta + 1.
/***WS
        vtipoaux = 1300 + (if substr(vlinha, 13, 2) = "01" then 1 else 5).
        find first tt-texto where tt-texto.tipo = vtipoaux no-lock no-error.
        if not avail tt-texto
        then do.
            create tt-texto.
            tt-texto.tipo  = vtipoaux.
            tt-texto.linha = "".

            create tt-texto.
            tt-texto.tipo  = vtipoaux.
            tt-texto.linha = "Estatisticas de Consultas " +
                             (if substr(vlinha, 13, 2) = "01"
                              then "Credito "
                              else "Cheque  ").
        end.

        create tt-texto.
        tt-texto.tipo  = vtipoaux.
        tt-texto.linha = string(substr(vlinha, 15, 8), "99/99/9999") + " " +
                         substr(vlinha, 73, 40) no-error.
***/
    end.

    if substr(vlinha, 1, 6) = "002014"
    then do.
        vok = yes.
/***WS
        vtipoaux = 1300 + (if substr(vlinha, 13, 2) = "01" then 2 else 6).
        find first tt-texto where tt-texto.tipo = vtipoaux no-lock no-error.
        if not avail tt-texto
        then do.
            create tt-texto.
            tt-texto.tipo  = vtipoaux.
            tt-texto.linha =     "Total de consulta nos ultimos " +
                substr(vlinha, 29, 3) +
                " dias: " + string(int(substr(vlinha, 23, 6))) + 
                " a partir de " +
                string(substr(vlinha, 15, 8),"99/99/9999").
        end.
***/
    end.

    /*
    
    */
    
    if substr(vlinha, 1, 6) = "002005"
    then do.
        vok = yes.
/***WS
        find first tt-texto where tt-texto.tipo = 1500 no-lock no-error.
        if not avail tt-texto
        then do.
***/
            par-ok = no. /* passagem no SPC */ 
/***WS
            create tt-texto.
            tt-texto.tipo  = 1500.

            create tt-texto.
            tt-texto.tipo  = 1500.
            tt-texto.linha = "Bacen".

            create tt-texto.
            tt-texto.tipo  = 1500.
            tt-texto.linha = string("Banco", "x(36)") +
                string("Agencia   Bacen       SPC        Qtde").
        end.

        create tt-texto.
        tt-texto.tipo  = 1501.
        tt-texto.linha = substr(vlinha, 13, 3) + " - " + 
            substr(vlinha, 16, 30) + "  " +
            substr(vlinha, 46, 4) + "  " +
            string(substr(vlinha,  97, 8),"99/99/9999") + "  " +
            string(substr(vlinha, 105, 8),"99/99/9999") + "  " +
            substr(vlinha, 93, 4).
***/
    end.

    /*
        Credito Nacional
    */
    if substr(vlinha, 1, 6) = "002100"
    then do.
        vok = yes.
/***WS
        find first tt-texto where tt-texto.tipo = 1010 no-lock no-error.
        if not avail tt-texto
        then do.
            create tt-texto.
            tt-texto.tipo  = 1010.
            tt-texto.linha = "".

            create tt-texto.
            tt-texto.tipo  = 1010.
            tt-texto.linha = "S P C    N a c i o n a l".
        end.
        create tt-texto.
        tt-texto.tipo  = 1011.
        tt-texto.linha = "CPF: " + substr(vlinha, 14, 14) +
            " Nome: " + substr(vlinha, 29, 35) +
            " Nasc: " + string(substr(vlinha, 99, 8),"99/99/9999").
***/
    end.    

    if substr(vlinha, 1, 6) = "002101"
    then do.
        vok = yes.
        assign
            vregnacion = vregnacion + 1
            par-ok = no. /* passagem no SPC */ 
/***WS
        create tt-texto.
        tt-texto.tipo  = 1011.
        tt-texto.linha = string(trim(substr(vlinha, 13, 20)) + "/" + 
                         substr(vlinha, 43, 2), "x(23)")  + " " +
                         substr(vlinha, 45, 30). 

        create tt-texto.
        tt-texto.tipo  = 1011.
        tt-texto.linha = fill(" ", 24) + 
                         "Contrato: " + substr(vlinha, 76, 16) +
                         "  Valor: " + 
              trim( string( dec(substr(vlinha, 108, 14)) / 100, ">>,>>9.99")).

        create tt-texto.
        tt-texto.tipo  = 1011.
        tt-texto.linha = fill(" ", 24) +
              "Atraso: " + string(substr(vlinha, 92, 8),"99/99/9999") +
              "     Inclusao: " + string(substr(vlinha, 100, 8),"99/99/9999").
***/
    end.

    if substr(vlinha, 1, 6) = "002104"
    then do.
        vok = yes.
/***WS
        create tt-texto.
        tt-texto.tipo  = 1014.
        tt-texto.linha = "Acumulado geral SPC Nacional => " +
            "Total de Registros: " + string(int(substr(vlinha, 13, 4))) +
            "/Total de Consultas: " + string(int(substr(vlinha, 17, 4))).
***/
    end.
    
        vlinha = "".
    end.
    else vlinha = vlinha + vletra.

end.
/*#1
    end.
end.
input close.
if not vlog
then unix silent rm -f value(par-arq).
*/

/***WS
find first tt-texto where tt-texto.tipo = 400
                       or tt-texto.tipo = 1011
                    no-lock no-error.
if not avail tt-texto
then do.
    create tt-texto.
    tt-texto.tipo  = 400.

    create tt-texto.
    tt-texto.tipo  = 400.
    tt-texto.linha = "Registro de Credito".
    
    create tt-texto.
    tt-texto.tipo  = 401.

    create tt-texto.
    tt-texto.tipo  = 401.
    tt-texto.linha = "Nada Consta !!!!".
end.
***/

if vok and
   par-oper = "GRAVA"
then do on error undo.
    /*#1*/
    find current Clien exclusive.
    /*find clien where recid(clien) = par-rec exclusive.*/
    /*** Gravar a consulta no quadro "SPC" do clioutb4
        era usado o campo clien.autoriza[5] 
    ***/
    if date(clien.entrefcom[1]) = today
    then vqtd-consulta = int(acha("Consultas",clien.entrefcom[2])) + 1.
    else vqtd-consulta = 1.
    
    if vqtd-consulta = ?
    then vqtd-consulta = 1.
    
    clien.entrefcom[1] = string(today,"99/99/9999").
    clien.entrefcom[2] = "Ok=" + (if par-ok then "Sim" else "Nao") +
                         "|Credito="  + string(vregcredit) + 
                         "|Cheques="  + string(vregcheque) +
                         "|Nacional=" + string(vregnacion) +
                         "|Alertas="  + string(valerta)    + 
                         "|Filial="   + string(ConsSPC.etbcod) +
                         "|Consultas=" + string(vqtd-consulta) +
                         "|CPF="  + p-cgccpf +
                         "|Hora=" + string(time) +
                         "|Local=P2K".
    if PAR-QUEM = 2                     
    then assign clien.entrefcom[2] = clien.entrefcom[2]
                                     + "|ConsultaCpfConjuge=" + string(today).
    
    find current Clien no-lock. /*#1*/
    
    /*#1*/
    find ConsSPC where recid(ConsSPC) = par-rec exclusive-lock.
    assign
        ConsSPC.Resposta = clien.entrefcom[2]
        /*
        ConsSPC.T-Reg = t-reg
        ConsSPC.D-Reg = d-reg.
        */.

    if par-arqlog <> ""
    then do.
        output to value(par-arqlog) append.
        put string(time, "hh:mm:ss") " FASE 10 - GRAVA CONSULTA " skip.
        PUT unformatted clien.entrefcom[1] SKIP.
        put unformatted clien.entrefcom[2] SKIP.
        put "Ok=".
        if par-ok then put "Sim". else put "Nao".
        put skip.
        put "|Credito="   string(vregcredit) skip.
        put "|Cheques="   string(vregcheque) skip.
        put "|Nacional="  string(vregnacion) skip.
        put "|Alertas="   string(valerta) skip.
        put "|Filial="    string(ConsSPC.etbcod) skip.
        put "|Consultas="  string(vqtd-consulta) skip.
    
        if PAR-QUEM = 2
        then put "|ConsultaCpfConjuge=" today skip.
    
        output close.
    end.

/***WS
    if ConsSPC.etbcod <> 189 and
       clien.clicod > 1 and
       search("/usr/admcom/progr/WSexporta.p") <> ?
    then do:
        run WSexporta.p("cliente;" + string(clien.clicod)).
    end.
***/
end.

/***WS
if not par-ok
then message "Cliente com registro restritivo !!" view-as alert-box.

if valerta > 0 or
   vconsulta > 8
then do.
    assign
        vlinha = (if valerta > 0   then "Alertas" else "")
        vtexto = (if vconsulta > 8 then "Mais de 8 consultas" else "").
    message color message "Foram encontrados:" skip
                          vlinha skip
                          vtexto skip
            view-as alert-box title " Alerta !!".
end.


/*
*
*    tt-texto.p    -    Esqueleto de Programacao    com esqvazio
*
*/

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqcom1         as char format "x(12)" extent 5
    initial [" F4 Retorna "," "].
def var esqhel1         as char format "x(80)" extent 5.

form
    esqcom1
    with frame f-com1
                 row 4 no-box no-labels side-labels column 1 centered.
assign
    esqregua = yes
    esqpos1  = 1
    esqpos2  = 1.

for each tt-texto where tipo = 401.
    if substr(tt-texto.linha,1,2) <> ""  
    then do:
        t-reg = t-reg + 1.
        if tt-texto.linha matches "*lebes*"
            or tt-texto.linha matches "*drebes*"
        then d-reg = d-reg + 1.      
    end.    
end.        
bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then
        run leitura (input "pri").
    else
        find tt-texto where recid(tt-texto) = recatu1 no-lock.
    if not available tt-texto
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then run frame-a.
    else leave.

    recatu1 = recid(tt-texto).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available tt-texto
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down
            with frame frame-a.
        run frame-a.
    end.
    if not esqvazio
    then up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:
        if not esqvazio
        then do:
            find tt-texto where recid(tt-texto) = recatu1 no-lock.

            choose field tt-texto.linha help ""
                go-on(cursor-down cursor-up
                      page-down   page-up
                      PF4 F4 ESC return).
            status default "".
        end.
            if keyfunction(lastkey) = "page-down"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "down").
                    if not avail tt-texto
                    then leave.
                    recatu1 = recid(tt-texto).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail tt-texto
                    then leave.
                    recatu1 = recid(tt-texto).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail tt-texto
                then next.
                color display white/red tt-texto.linha with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail tt-texto
                then next.
                color display white/red tt-texto.linha with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if not esqvazio
        then do:
            run frame-a.
        end.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(tt-texto).
    end.
    if keyfunction(lastkey) = "end-error"
    then do:
        view frame fc1.
        view frame fc2.
    end.
end.
hide frame f-com1  no-pause.
hide frame frame-a no-pause.

procedure frame-a.
    display tt-texto.linha format "x(78)"
            with frame frame-a 15 down centered color white/red row 5 no-label.
end procedure.

procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then   find first tt-texto  where true no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then   find next tt-texto  where true no-lock no-error.
             
if par-tipo = "up" 
then   find prev tt-texto where true   no-lock no-error.
        
end procedure.
***/

