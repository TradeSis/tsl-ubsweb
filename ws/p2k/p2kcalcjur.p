/*  bstitjuro.p             */
def input  parameter par-rec        as recid.
def input  parameter par-today      as date.
def output parameter par-juros      as dec.
def output parameter par-saldojur   as dec.

def var ljuros  as log.
def var vtitvlpag   like titulo.titvlpag.
def var vtitjuro    like titulo.titjuro.
def var vnumdia as int.
def var vv as dec.
def var vtitvlcob like titulo.titvlcob.
def var vjuro as dec.

find titulo where recid(titulo) = par-rec no-lock.
if titulo.titdtpag <> ?
then leave.
if titulo.titsit <> "LIB"
then leave.

    vtitvlcob = 0.
    ljuros = no.
    if  par-today > titulo.titdtven
    then do:
        ljuros = yes.
        if par-today - titulo.titdtven = 3
        then do:
            find dtextra where exdata = par-today - 3 no-error.
            if weekday(par-today - 3) = 1 or avail dtextra
            then do:
                find dtextra where exdata = par-today - 1 no-error.
                if weekday(par-today - 1) = 1 or avail dtextra
                then ljuros = no.
            end.
        end.
        if par-today - titulo.titdtven = 2
        then do:
            find dtextra where exdata = par-today - 2 no-error.
            if weekday(par-today - 2) = 1 or avail dtextra
            then do:
                find dtextra where exdata = par-today - 1 no-error.
                if weekday(par-today - 1) = 1 or avail dtextra
                then ljuros = no.
            end.
        end.
        else do:
            if par-today - titulo.titdtven = 1
            then do:
                find dtextra where exdata = par-today - 1 no-error.
                if weekday(par-today - 1) = 1 or avail dtextra
                then ljuros = no.
            end.
        end.
        vnumdia = if not ljuros
                  then 0
                  else par-today - titulo.titdtven.
        /*
        {sel-tabjur.i titulo.etbcod vnumdia} .
        */
        
        find tabjur where tabjur.nrdias = vnumdia no-lock no-error.
        if  not avail tabjur
        then do:
            /*
            message "Fator para" vnumdia "dias de atraso, nao cadastrado".
            pause.
            undo.*/
        end. 
        assign vtitvlpag = titulo.titvlcob * (if avail tabjur 
                                              then tabjur.fator
                                              else 1)
               vtitjuro  = vtitvlpag - vtitvlcob.
        if ljuros
        then do: 
            vv = ( (int(vtitvlpag) -  vtitvlpag) )  - 
                    round(( (int(vtitvlpag) - 
                            (vtitvlpag)) ),1).
            if vv < 0  
            then vv = 0.10 - (vv * -1).
            vtitvlpag = vtitvlpag + vv.
            vtitjuro  =  vtitvlpag - titulo.titvlcob.
        end. 
    end.
    else vtitvlpag = titulo.titvlcob.
    assign vtitvlpag = vtitvlpag + vtitvlpag
           vtitvlcob = vtitvlcob + titulo.titvlcob.


vjuro = vtitvlpag - vtitvlcob.

par-juros    = vtitjuro.
par-saldojur = titulo.titvlcob + par-juros. 

