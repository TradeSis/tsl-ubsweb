
def input parameter par-operacao as char.
def input parameter par-impressora as char.

def shared temp-table ttentrada  no-undo serialize-name "produtos"
field codigo       as int
field nome          as char
field grade         as char
field quantidade   as int.

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
        break by ttentrada.codigo.

        if first-of(ttentrada.codigo)
        then do:
            vdir = "/admcom/etiquetasmix/".

            varquivo = "eti-" + string(ttentrada.codigo) + ".bat".

            unix silent value("rm -f " + vdir + varquivo).

            /*
            unix silent value("rm -f " + vdir + "c*.*").
            unix silent value("rm -f " + vdir + "01.zip").
            unix silent value("rm -f " + vdir + "01.ZIP").
            */
            vsh = vdir + "zipa" + string(ttentrada.codigo) + ".sh".

            output to value(vsh).

            put unformatted "cd " vdir skip.
            put unformatted "zip -q " vdir
                    string(ttentrada.codigo) + ".zip  eti-" + string(ttentrada.codigo) + ".bat ".

            output close.


            /*unix silent value("chmod 777 " + vdir + "zipa" + string(ttentrada.ordem) + ".sh").*/

        end.

        find produ where produ.procod = int(ttentrada.codigo) no-lock no-error.
        if avail produ
        then do:
            def var vqtditens as int.
            def var vi as int.
            vqtditens=0.
            do vi = 1 to num-entries(ttentrada.grade," ").
              vqtditens = vqtditens +
                int(entry(2,entry(vi,ttentrada.grade," "),"=")).
            end.
            run etiqueta/1/leb-etiq-mmix.p (vdir,
                                  varquivo,
                                  vsh,
                                  input recid(produ),
                                  input int(ttentrada.quantidade),
                                  input ttentrada.grade,
                                  input vqtditens,
                                  input fila).

            
        end.

        if last-of(ttentrada.codigo)
        then do:

            unix silent value("sh " + vdir + "zipa" + string(ttentrada.codigo) + ".sh").
            unix silent value("rm -f " + vdir + "zipa" + string(ttentrada.codigo) + ".sh").
            unix silent value("chmod 777 " + vdir + string(ttentrada.codigo) + ".zip").

        end.

    end.
