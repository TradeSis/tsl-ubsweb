/***********************************************************
Nome: leb-etiq-imprime.p
Autor: Rafael A. (Kbase IT)
Forma uso:
    run leb-etiq-imprime.p (input <recid-produ>,
                            input <qtd>,
                            input <tam>,
                            input <fila>).

***********************************************************/

def input parameter p-dir    as char.
def input parameter p-bat    as char.
def input param     p-sh     as char. /*180620 Helio*/
def input parameter p-rec    as   recid no-undo.
def input parameter p-qtd    as   int   no-undo.
def input parameter p-grade  as   char  no-undo.
def input parameter p-qtditem as int.
def input parameter fila     as   char  format "x(20)" no-undo.

def var varquivo       as char no-undo.
def var varquivo-sobra as char no-undo.
def var vlinha         as int  no-undo.
def var vvezes         as int  no-undo.
def var vqtdetiq       as int  no-undo.
def var vsobraetiq     as int  no-undo.
def var vpos           as int  no-undo.
def var vvalor         as char no-undo.
def var vetiq as char.

def temp-table tt-layout-etiq
    field conteudo as char
    field linha    as int
    .

/* inicio busca dados */
find first produ where recid(produ) = p-rec no-lock no-error.
if not avail produ
then return.


/* carrega layout */
varquivo = "/u/bsweb/progr/app/etiqueta/etiq-mmixhorz.txt".

input from value(varquivo) no-echo.
vlinha = 0.
repeat:
    create tt-layout-etiq.
    import unformatted tt-layout-etiq.conteudo.

    vlinha = vlinha + 1.
    tt-layout-etiq.linha = vlinha.
end.
input close.
varquivo = "".
/* fim carrega layout */

/* calcula qtd */
vvezes     = truncate(p-qtd / 2,0).
vvezes     = vvezes * 2.
vqtdetiq   = vvezes / 2.
vsobraetiq = p-qtd - vvezes.

/* helio 05102022 - imprimir 149 etiquetas  */
vqtdetiq = vqtdetiq + vsobraetiq.
vsobraetiq = 0.

if vqtdetiq > 0 then do:

    run p-insere-dados.

        vetiq = "c" + if avail produ
                      then string(produ.procod)
                      else "00"
                      + ".zeb".

        varquivo = p-dir + "/" + vetiq.

        output to value (varquivo).
        for each tt-layout-etiq no-lock break by tt-layout-etiq.linha:
            put unformatted tt-layout-etiq.conteudo skip.
        end.
        output close.
        unix silent value("chmod 777 " + varquivo).
        if fila <> ""
        then do:
            os-command silent "lpr -P " value(fila) value(varquivo).
        end.
        run p-gera-arq-fornec(input varquivo, vetiq).

end.

if vsobraetiq > 0 then do:
    run p-insere-dados.


        vetiq = "c" + if avail produ
                      then string(produ.procod)
                      else "00"
                      + "sob.zeb".

        varquivo = p-dir + "/" + vetiq.

        output to value (varquivo).
        for each tt-layout-etiq no-lock break by tt-layout-etiq.linha:
            put unformatted tt-layout-etiq.conteudo skip.
        end.
        output close.
        unix silent value("chmod 777 " + varquivo).
        if fila <> ""
        then do:
            os-command silent "lpr -P " value(fila) value(varquivo).
        end.
        run p-gera-arq-fornec(input varquivo, vetiq).

end.

procedure p-insere-dados:
def var vi as int.
    for each tt-layout-etiq break by linha:

         /* helio 05102022 - imprimir 149 etiquetas  */
        tt-layout-etiq.conteudo = replace(tt-layout-etiq.conteudo,"QTDETIQ",string(vqtdetiq)).

        tt-layout-etiq.conteudo = replace(tt-layout-etiq.conteudo,"CODIGO_8",string(produ.procod)).
        tt-layout-etiq.conteudo = replace(tt-layout-etiq.conteudo,"NOME1_1_16",substring(produ.pronom,1,16)).
        tt-layout-etiq.conteudo = replace(tt-layout-etiq.conteudo,"NOME2_17_16",substring(produ.pronom,17,16)).
        if index(tt-layout-etiq.conteudo,"TAM:") > 0
        then do:
            do vi = 1 to num-entries(p-grade," ").
                /* helio 30062022 - retirado int( e o format zzz9, porque tem tamanhjo com letras */
                if vi = 1 then  tt-layout-etiq.conteudo = replace(tt-layout-etiq.conteudo,"GA1",string((entry(1,entry(vi,p-grade," "),"=")),"xxx")).
                if vi = 2 then  tt-layout-etiq.conteudo = replace(tt-layout-etiq.conteudo,"GA2",string((entry(1,entry(vi,p-grade," "),"=")),"xxx")).
                if vi = 3 then  tt-layout-etiq.conteudo = replace(tt-layout-etiq.conteudo,"GA3",string((entry(1,entry(vi,p-grade," "),"=")),"xxx")).
                if vi = 4 then  tt-layout-etiq.conteudo = replace(tt-layout-etiq.conteudo,"GA4",string((entry(1,entry(vi,p-grade," "),"=")),"xxx")).
                if vi = 5 then  tt-layout-etiq.conteudo = replace(tt-layout-etiq.conteudo,"GA5",string((entry(1,entry(vi,p-grade," "),"=")),"xxx")).
                if vi = 6 then  tt-layout-etiq.conteudo = replace(tt-layout-etiq.conteudo,"GA6",string((entry(1,entry(vi,p-grade," "),"=")),"xxx")).
                if vi = 7 then  tt-layout-etiq.conteudo = replace(tt-layout-etiq.conteudo,"GA7",string((entry(1,entry(vi,p-grade," "),"=")),"xxx")).
                if vi = 8 then  tt-layout-etiq.conteudo = replace(tt-layout-etiq.conteudo,"GA8",string((entry(1,entry(vi,p-grade," "),"=")),"xxx")).
            end.
            tt-layout-etiq.conteudo = replace(tt-layout-etiq.conteudo,"GA1","   ").
            tt-layout-etiq.conteudo = replace(tt-layout-etiq.conteudo,"GA2","   ").
            tt-layout-etiq.conteudo = replace(tt-layout-etiq.conteudo,"GA3","   ").
            tt-layout-etiq.conteudo = replace(tt-layout-etiq.conteudo,"GA4","   ").
            tt-layout-etiq.conteudo = replace(tt-layout-etiq.conteudo,"GA5","   ").
            tt-layout-etiq.conteudo = replace(tt-layout-etiq.conteudo,"GA6","   ").
            tt-layout-etiq.conteudo = replace(tt-layout-etiq.conteudo,"GA7","   ").
            tt-layout-etiq.conteudo = replace(tt-layout-etiq.conteudo,"GA8","   ").
        end.
        if index(tt-layout-etiq.conteudo,"QTD:") > 0
        then do:
            do vi = 1 to num-entries(p-grade," ").
                if vi = 1 then  tt-layout-etiq.conteudo = replace(tt-layout-etiq.conteudo,"TA1",string(int(entry(2,entry(vi,p-grade," "),"=")),"zz9")).
                if vi = 2 then  tt-layout-etiq.conteudo = replace(tt-layout-etiq.conteudo,"TA2",string(int(entry(2,entry(vi,p-grade," "),"=")),"zz9")).
                if vi = 3 then  tt-layout-etiq.conteudo = replace(tt-layout-etiq.conteudo,"TA3",string(int(entry(2,entry(vi,p-grade," "),"=")),"zz9")).
                if vi = 4 then  tt-layout-etiq.conteudo = replace(tt-layout-etiq.conteudo,"TA4",string(int(entry(2,entry(vi,p-grade," "),"=")),"zz9")).
                if vi = 5 then  tt-layout-etiq.conteudo = replace(tt-layout-etiq.conteudo,"TA5",string(int(entry(2,entry(vi,p-grade," "),"=")),"zz9")).
                if vi = 6 then  tt-layout-etiq.conteudo = replace(tt-layout-etiq.conteudo,"TA6",string(int(entry(2,entry(vi,p-grade," "),"=")),"zz9")).
                if vi = 7 then  tt-layout-etiq.conteudo = replace(tt-layout-etiq.conteudo,"TA7",string(int(entry(2,entry(vi,p-grade," "),"=")),"zz9")).
                if vi = 8 then  tt-layout-etiq.conteudo = replace(tt-layout-etiq.conteudo,"TA8",string(int(entry(2,entry(vi,p-grade," "),"=")),"zz9")).
            end.
            tt-layout-etiq.conteudo = replace(tt-layout-etiq.conteudo,"TA1","   ").
            tt-layout-etiq.conteudo = replace(tt-layout-etiq.conteudo,"TA2","   ").
            tt-layout-etiq.conteudo = replace(tt-layout-etiq.conteudo,"TA3","   ").
            tt-layout-etiq.conteudo = replace(tt-layout-etiq.conteudo,"TA4","   ").
            tt-layout-etiq.conteudo = replace(tt-layout-etiq.conteudo,"TA5","   ").
            tt-layout-etiq.conteudo = replace(tt-layout-etiq.conteudo,"TA6","   ").
            tt-layout-etiq.conteudo = replace(tt-layout-etiq.conteudo,"TA7","   ").
            tt-layout-etiq.conteudo = replace(tt-layout-etiq.conteudo,"TA8","   ").
        end.
        tt-layout-etiq.conteudo = replace(tt-layout-etiq.conteudo,"TOTP5",string(p-qtditem)).
    end.
end procedure.

procedure p-gera-arq-fornec:

    def input parameter p-arquivo as char no-undo.
    def input parameter p-etiq    as char.
    def var varquivo as char.

    varquivo = p-dir + p-bat.

    output to value(varquivo) append.
        put trim(" type c:~\drebes~\" +
                 p-etiq               +
                 " > prn") format "x(40)" skip.
    output close.

    output to value(p-sh) append.
        put unformatted " " p-etiq " ".
    output close.



end procedure.
