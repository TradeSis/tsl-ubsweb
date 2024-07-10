def var bsxml as char. /* contem o XML */
def var bsxml-fill as int.
def var bsxml-tipo as char.

function topto returns character
    (input par-virgula as char).
    return
        replace(par-virgula,",",".").
end function.


function tovig returns character
    (input par-ponto as char).
    return
        replace(par-ponto,".",",").
end function.



/*** Retirar acentos ***/
function Texto return character
    (input par-texto as char).

    def var vtexto as char.
    def var vletra as char.
    def var vct    as int.
    def var vi     as int.
    def var vtam   as int.

    def var oldvletra as char.
    if par-texto = ?
    then return "".

    par-texto = trim(replace(par-texto, "~\",".")).
    vtam = length(par-texto).
    do vi = 1 to vtam.
        vletra = substring(par-texto, vi, 1).
        if vletra = "<" or
           vletra = ">" or
           asc(vletra) = 34 or
           asc(vletra) = 39
        then vtexto = vtexto + " ".
        else if vletra = "&" then vtexto = vtexto + "E".
        else
            if length(vletra) = 1 and
               asc(vletra) >  31 and
               asc(vletra) < 127
        then vtexto = vtexto + vletra.
        else do:
            oldvletra = vletra.
            assign  vletra = replace(vletra, 'À', 'A') vletra = replace(vletra, 'Á', 'A') vletra = replace(vletra, 'Â', 'A')
                    vletra = replace(vletra, 'Ã', 'A') vletra = replace(vletra, 'Ä', 'A') vletra = replace(vletra, 'È', 'E')
                    vletra = replace(vletra, 'É', 'E') vletra = replace(vletra, 'Ê', 'E') vletra = replace(vletra, 'Ë', 'E')
                    vletra = replace(vletra, 'Ì', 'I') vletra = replace(vletra, 'Í', 'I') vletra = replace(vletra, 'Î', 'I')
                    vletra = replace(vletra, 'Ï', 'I') vletra = replace(vletra, 'Ò', 'O') vletra = replace(vletra, 'Ó', 'O')
                    vletra = replace(vletra, 'Ô', 'O') vletra = replace(vletra, 'Õ', 'O') vletra = replace(vletra, 'Ö', 'O') 
                    vletra = replace(vletra, 'Ù', 'U') vletra = replace(vletra, 'Ú', 'U') vletra = replace(vletra, 'Û', 'U') 
                    vletra = replace(vletra, 'Ü', 'U') vletra = replace(vletra, 'Ý', 'Y') vletra = replace(vletra, '.', 'Y') 
                    vletra = replace(vletra, 'Ç', 'C') vletra = replace(vletra, 'Ñ', 'N') vletra = replace(vletra, 'à', 'a') 
                    vletra = replace(vletra, 'á', 'a') vletra = replace(vletra, 'â', 'a') vletra = replace(vletra, 'ã', 'a') 
                    vletra = replace(vletra, 'ä', 'a') vletra = replace(vletra, 'è', 'e') vletra = replace(vletra, 'é', 'e') 
                    vletra = replace(vletra, 'ê', 'e') vletra = replace(vletra, 'ë', 'e') vletra = replace(vletra, 'ì', 'i') 
                    vletra = replace(vletra, 'í', 'i') vletra = replace(vletra, 'î', 'i') vletra = replace(vletra, 'ï', 'i') 
                    vletra = replace(vletra, 'ò', 'o') vletra = replace(vletra, 'ó', 'o') vletra = replace(vletra, 'ô', 'o') 
                    vletra = replace(vletra, 'õ', 'o') vletra = replace(vletra, 'ö', 'o') vletra = replace(vletra, 'ù', 'u') 
                    vletra = replace(vletra, 'ú', 'u') vletra = replace(vletra, 'û', 'u') vletra = replace(vletra, 'ü', 'u') 
                    vletra = replace(vletra, 'ý', 'y') vletra = replace(vletra, 'ÿ', 'y') vletra = replace(vletra, 'ç', 'c') 
                    vletra = replace(vletra, 'ñ', 'n') vletra = replace(vletra, 'ª', 'a') vletra = replace(vletra, 'º', 'o') 
                    vletra = replace(vletra, '&', 'E') vletra = replace(vletra, 'Â', 'A') vletra = replace(vletra, '', ' ') .
                /*
                if oldvletra = vletra
                then vletra = "-".
                */
            vtexto = vtexto + vletra.
        end.
    end.

    return vtexto.

end function.


function bsxml returns char
    (input tag as char,
     input conteudo as char).

    def var vskip as char.
    vskip = "". /*chr(10).*/

    if conteudo = ? then conteudo = "".

    if bsxml-tipo <> "VARIAVEL" then bsxml = "".
    
    if tag = "ABREXML"
    then do:
        bsxml = "<?xml version=\"1.0\" encoding=\"ISO-8859-1\"  ?>" + vskip +
                  vskip.
        bsxml-fill = 1 /***4***/.
        if conteudo <> ""
        then bsxml-tipo = conteudo.
    end.
    else if tag = "FECHAXML"
    then do:
        bsxml = bsxml +  vskip.
        if bsxml-tipo = "VARIAVEL"
        then do:
            /**
            **  MANDA O XML 
            **/
            put unformatted bsxml.
            bsxml = "".
        end.
    end.        
    else if tag = "ABRE"
    then do:
        bsxml = "<?xml version=\"1.0\" encoding=\"ISO-8859-1\"  ?>" + vskip +
                 "<conteudo>" + vskip.
        bsxml-fill = 1 /***4***/.
        if conteudo <> ""
        then bsxml-tipo = conteudo.
    end.
    else if tag = "FECHA"
    then do:
        bsxml = bsxml + "</conteudo>" + vskip.
        if bsxml-tipo = "VARIAVEL"
        then do:
            /**
            **  MANDA O XML 
            **/
            put unformatted bsxml.
            bsxml = "".
        end.
    end.        
    else if tag = "ABRETABELA"
    then do: 
        bsxml = bsxml + fill(" ",bsxml-fill) + "<" + conteudo + ">" + vskip.
        /***bsxml-fill = bsxml-fill + 4.***/
    end.        
    else if tag = "FECHATABELA"
    then do: 
        /***bsxml-fill = bsxml-fill - 4.***/
        bsxml = bsxml + fill(" ",bsxml-fill) + "</" + conteudo + ">" + vskip.
    end.
    else if tag = "ABREREGISTRO"
    then do:
        bsxml = bsxml + fill(" ",bsxml-fill) + "<" + conteudo + ">" + vskip.
        /***bsxml-fill = bsxml-fill + 4.***/
    end.        
    else if tag = "FECHAREGISTRO"
    then do:
        /***bsxml-fill = bsxml-fill - 4.***/
        bsxml = bsxml + fill(" ",bsxml-fill) + "</" + conteudo + ">" + vskip.
    end.        
    else if tag = "ABRETAG"
    then bsxml = bsxml + fill(" ",bsxml-fill) + "<" + conteudo + ">" + vskip.
    else if tag = "FECHATAG"
    then bsxml = bsxml + fill(" ",bsxml-fill) + "</" + conteudo + ">" + vskip.
    else bsxml = bsxml + fill(" ",bsxml-fill) + "<" + tag + ">" + 
                    trim(conteudo) + "</" + tag + ">" + vskip.

    if bsxml-tipo <> "VARIAVEL"
    then put unformatted bsxml.

    return bsxml.     

end function.


function bsxmlvar returns char
    (input tag as char,
     input conteudo as char).

    if tag = "ABREXML"
    then return "<?xml version=\'1.0\' encoding=\'ISO-8859-1\' ?>".
    else if tag = "ABRETABELA"
    then return " <" + conteudo + "> ".
    else if tag = "FECHATABELA"
    then return " </" + conteudo + "> ".
    else if tag = "ABREREGISTRO"
    then return " <" + conteudo + "> ".
    else if tag = "FECHAREGISTRO"
    then return "   </" + conteudo + "> ".
    else return "   <" + tag + ">" + conteudo + "</" + tag + ">".
     
end function.


function montatab           returns char 
        (input tabela      as char,
         input registro    as char,
         input parametros  as char).
    def var vxml as char.
    def var vx   as int.
    def var auxiliar as char.

    vxml = vxml + bsxmlvar("ABRETABELA",tabela).
    if registro <> ""
    then vxml = vxml + bsxmlvar("ABREREGISTRO",registro).

    if parametros <> ""
    then do: 
        do vx = 1 to num-entries(parametros,"|"). 
            auxiliar    = entry(vx,parametros,"|").
            vxml = vxml + bsxmlvar(entry(1,auxiliar   ,"="),
                                   entry(2,auxiliar   ,"=")).
        end.
    end.
    if registro <> ""
    then vxml = vxml + bsxmlvar("FECHAREGISTRO",registro).
    
    vxml = vxml + bsxmlvar("FECHATABELA",tabela).
    
    return vxml.
end function.


function montaxml           returns char 
        (input controles   as char,
         input parametros  as char).
    def var vxml as char.
    def var vx   as int.
    def var auxiliar as char.
    vxml = vxml + bsxmlvar("ABREXML","").
    vxml = vxml + bsxmlvar("ABRETABELA","conteudo").
    if controles <> ""
    then do:
        vxml = vxml + bsxmlvar("ABREREGISTRO","controle").
        if controles = "bsecombrivia"
        then do:
            vxml = vxml + bsxmlvar("usuario","brivia").
            vxml = vxml + bsxmlvar("senha","1f0efad05bbbfa9017047262c54b86f4").
        end.
        else do:
            if controles <> ""
            then do:
                do vx = 1 to num-entries(controles,"|").
                    auxiliar             = entry(vx,controles,"|").
                    vxml = vxml + bsxmlvar(entry(1,auxiliar   ,"="),
                                           entry(2,auxiliar   ,"=")).
                end.
            end.
        end.
        vxml = vxml + bsxmlvar("FECHAREGISTRO","controle").
    end.
    if parametros <> "" 
    then do: 
        if num-entries(parametros,"|") > 0
        then do:
            do vx = 1 to num-entries(parametros,"|"). 
                auxiliar    = entry(vx,parametros,"|").
                if num-entries(auxiliar,"=") > 1
                then vxml = vxml + bsxmlvar(entry(1,auxiliar   ,"="), 
                                               entry(2,auxiliar   ,"=")).
                else vxml = vxml + auxiliar.
            end.
        end.
    end.
    vxml = vxml + bsxmlvar("FECHATABELA","conteudo").
    
    return vxml.
end function.


function chamawebservices return char 
    (input webcliente as char,
     input webservidor as char,
     input acao        as char,
     input xml         as char).
     
    def var varquivo as char.
    def var ctime as char.

    ctime = string(time).
    varquivo =  "/u/bsweb/works/" + acao + "." + ctime + ".xml".

    unix silent value("wget \"http://" + webcliente +
                        "?chamar=" + acao +
                        "&servidor=" + webservidor +
                        "&xml=" + xml + "\"" +
                        " -O " + varquivo + " -q --timeout=30").
    return varquivo.
end function.


function testavalido return log
    (input par-palavra as char).
    def var vok as log.

       if  par-palavra <> "" and 
           par-palavra <> ?  and
           par-palavra <> "?"
       then vok = yes.
       else vok = no.
     return vok.

end function.


function trata-numero returns character
    (input par-num as char).

    def var par-ret as char.
    def var j as int.
    def var t as int.
    def var vletra as char.

    if par-num = ?
    then par-num = "".

    t = length(par-num).
    do j = 1 to t:
        vletra = substr(par-num,j,1).
        if vletra = "0" or
           vletra = "1" or
           vletra = "2" or
           vletra = "3" or
           vletra = "4" or
           vletra = "5" or
           vletra = "6" or
           vletra = "7" or
           vletra = "8" or
           vletra = "9"
        then assign par-ret = par-ret + vletra.
    end.
    return par-ret.

end function.


/*** Formatar data para envio no XML ***/
function EnviaData returns character
    (input par-data as date).

    if par-data <> ?
    then return string(year(par-data),"9999") + "-" +
                string(month(par-data),"99") + "-" + 
                string(day(par-data),"99") + 
                "T00:00:00".
    else return "1900-01-01T00:00:00".

end function.

