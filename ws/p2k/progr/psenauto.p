{admcab.i}

def input parameter p-procod like produ.procod.
def output parameter p-ok as log.             

def var vlista-user as char extent 7 FORMAT "X(15)"
          init["Roni","Manoel Enildo","Ivane","Sandro","Emerson","Clair","Sandra"].
          
def var par-user as char.
def var vsenauto as dec format ">>>>>>>>>9".
def var vsenaudi as dec format ">>>>>>>>>9" init 0.
def var senha-cal as dec init 0.
def var vmes as int.
def var vdtaux as date.
def var vsencal as int.

vsenauto = 0.
vsencal = 0.

def var vmens as char.
def var vsen as int.
form vmens no-label format "x(30)"
    with frame fmens overlay
                   color message side-label
                   centered no-box.
 
if sparam = ""
then do:

    display skip(1)  vlista-user with 1 column centered no-labels row 3
                    title "Escolha o Supervisor: ".
                    
    choose field vlista-user.
                    
    hide no-pause.
    
    case frame-index:
        when 1 then assign par-user = "roni-sup|6516".
        when 2 then assign par-user = "manoelenildo|1242".
        when 3 then assign par-user = "ivanes|4285".
        when 4 then assign par-user = "sandrosup|3561".
        when 5 then assign par-user = "emerson|8257".
        when 6 then assign par-user = "clair|1231".
        when 7 then assign par-user = "sandrasup|3914".
    end case.

    /* teste ti - usar joao|2025 */

    vsencal = (int(substr(string(p-procod,"999999999"),7,3))
                + day(today)
                + int(substr(string(time,"HH:MM:SS"),1,2)))
                - setbcod.
    if vsencal < 0
    then vsencal = (-1 * vsencal).
    
    if setbcod = 189
    then message vsencal  .
    
    /*** antes
    ((( setbcod + day(today) ) + month(today))
                    + int(substr(string(time,"HH:MM:SS"),1,2))
                            + int(substr(string(time,"HH:MM:SS"),1,2))  ).
    ***/
    
    update skip(1) space(2) 
       vsenauto label "Senha" blank
       skip(1)
       with frame fsenauto
                  overlay side-label title " Autorizacao do Supervisor " 
                  row 13 centered.

    hide frame fsenauto no-pause.
    
    /**((( setbcod * day(today) ) * month(today) ) + year(today) )**/

    if vsenauto <> vsencal
    
    /*** antes
    ((( setbcod + day(today) ) + month(today)) 
                + int(substr(string(time,"HH:MM:SS"),1,2))
        + int(substr(string(time,"HH:MM:SS"),1,2))  )
    ***/
    
    then p-ok = no.
    else p-ok = yes.

    if not p-ok
    then do:
        /* Se nao foi informada a senha correta do supervisor verifica se foi            digitada a senha do token.*/
        run p-valida-senha-token.p (input par-user,
                                    input vsenauto,
                                    output p-ok).
    
    end.
    
    hide frame fsenauto no-pause.

end.
if sparam = "auditoria"
then do:
    if setbcod = 189
    then message year(today) + month(today) +
                    (day(vdtaux) - day(today)) +
                                    + int(substr(string(time,"HH:MM:SS"),1,2)).
                                    
    update skip(1) space(2) 
       vsenaudi label "Senha" blank
       skip(1)
       with frame fsenaudi
                  overlay side-label title " Autorizacao da Auditoria " 
                  row 10 centered.

    hide frame fsenaudi no-pause.
    
    vmes = month(today).
    vdtaux = date(if vmes = 12 then 1 else month(today) + 1,01,
                    if vmes = 12 then year(today) + 1 else year(today)) - 1. 
     
    senha-cal = year(today) + month(today) +
                (day(vdtaux) - day(today)) + 
                + int(substr(string(time,"HH:MM:SS"),1,2)).

    if vsenaudi <> senha-cal            
    then do:
        p-ok = no.
        vmens = "Senha Invalida." .
            disp vmens with frame fmens.
            pause 1 no-message.
            hide frame fmens no-pause.
    end.
    else p-ok = yes.
    hide frame fsenaudi no-pause.
end.
if sparam = "assistencia"
then do:
    update skip(1) space(2) 
       vsenaudi label "Senha" blank
       skip(1)
       with frame fsenaudi
                  overlay side-label title " Autorizacao da Auditoria " 
                  row 10 centered.

    hide frame fsenaudi no-pause.

    vmes = month(today).
    vdtaux = date(if vmes = 12 then 1 else month(today) + 1,01,
                    if vmes = 12 then year(today) + 1 else year(today)) - 1. 
     
    senha-cal = year(today) + month(today) +
                (day(vdtaux) - day(today)) /*+ 
                + int(substr(string(time,"HH:MM:SS"),1,2))*/.

    if vsenaudi <> senha-cal            
    then do:
        p-ok = no.
        vmens = "Senha Invalida." .
            disp vmens with frame fmens.
            pause 1 no-message.
            hide frame fmens no-pause.
    end.
    else p-ok = yes.
    hide frame fsenaudi no-pause.
end.

