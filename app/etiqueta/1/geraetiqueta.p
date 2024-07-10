
def input parameter par-operacao as char.
def input parameter par-impressora as char.

def shared temp-table ttentrada  no-undo serialize-name "produtos"
    field codigo       as int
    field nome          as char 
    field quantidade   as int
    field tamanho          as char 
    field preco         as char
    field ordem        as char.

def var varquivo as char.
def var vsh      as char.
def var vdir     as char.

def var fila     as char format "x(20)" no-undo.
def var recimp   as recid.

    fila = "".
    
    if par-operacao = "imprimir" 
    then do: 
        assign fila = par-impressora.
    end.
    
 
    for each ttentrada 
        break by ttentrada.ordem.
        
        if first-of(ttentrada.ordem)
        then do:
            vdir = "/admcom/etiquetas/".

            varquivo = "eti-" + string(ttentrada.ordem) + ".bat".

            unix silent value("rm -f " + vdir + varquivo).

            /*
            unix silent value("rm -f " + vdir + "c*.*").
            unix silent value("rm -f " + vdir + "01.zip").
            unix silent value("rm -f " + vdir + "01.ZIP").
            */
            vsh = vdir + "zipa" + string(ttentrada.ordem) + ".sh".            

            output to value(vsh).
        
            put unformatted "cd " vdir skip.
            put unformatted "zip -q " vdir 
                    string(ttentrada.ordem) + ".zip  eti-" + string(ttentrada.ordem) + ".bat ".
        
            output close.
        
            /*unix silent value("chmod 777 " + vdir + "zipa" + string(ttentrada.ordem) + ".sh").*/
            
        end. 
        
        find produ where produ.procod = int(ttentrada.codigo) no-lock no-error.
        if avail produ
        then do:
            run leb-etiq-web01.p (vdir,
                                  varquivo, 
                                  vsh,  
                                  input recid(produ), 
                                  input int(ttentrada.quantidade), 
                                  input ttentrada.tamanho, 
                                  input fila).
        end.
   
        if last-of(ttentrada.ordem)
        then do:
        
            unix silent value("sh " + vdir + "zipa" + string(ttentrada.ordem) + ".sh").
            
            /*unix silent value("chmod 777 " + vdir + string(ttentrada.ordem) + ".zip").*/
         
        end.

    end.
    
        


