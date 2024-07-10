
{acha.i}            /* 03.04.2018 helio */
{neuro/achahash.i}  /* 03.04.2018 helio */
{neuro/varcomportamento.i} /* 03.04.2018 helio */

/** 100    **/
def var par-recid-neuclien as recid.
def var vtipoconsulta          as char init "WsAC".

def var vneu_cdoperacao as char.
def var vsit_credito as char.
def var vvctolimite            as date. 
def var vvlrLimite              as dec.
def var vrenda as dec.
def var vtime                  as int.
def var vneurotech             as log init no.
def var vlojaneuro             as log init no. 
def var vvlrvenda           as dec.

def var vneuro-sit as char.
def var vneuro-mens as char.

def var vehcpf as log.
def new global shared var setbcod       as int.

def var vprops as char.
def var vPOLITICA as char.
def var var-atrasoparcperc as char.
def var var-PARCPAG as int.

/** 100 **/


def new shared temp-table PreAutorizacao
    field codigo_filial   as char
    field codigo_operador as char
    field numero_pdv      as char
    field codigo_cliente  as char
    field cpf             as char
    field tipo_pessoa     as char
    field nome_pessoa     as char
    field data_nascimento as char
    field mae             as char
    field codigo_mae      as char
    field categoria_profissional as char.


def var vetbcod as int.
def var vcpf    as char.
def var par-ok  as log.
def var vclicod as int.
def var vstatus as char.   
def var vmensagem_erro as char.
def var vgeralog as log.

def shared temp-table VerificaCreditoVenda
    field codigo_filial   as char
    field codigo_operador as char
    field numero_pdv      as char
    field tipo_venda       as char 
    field codigo_cliente  as char
    field produtos_valores as char
    field qtde_parcelas    as char
    field vlr_acrescimo as char
    field vlr_entrada as char
    field vlr_prestacao as char
    field dt_primvcto as char
    field dt_ultivcto as char
    field vdaterceiros as char.


{bsxml.i}

find first VerificaCreditoVenda no-lock no-error.
if avail VerificaCreditoVenda
then do.
    vstatus = "S".
    vetbcod = int(VerificaCreditoVenda.codigo_filial).
    vclicod = int(VerificaCreditoVenda.codigo_cliente).

    vehcpf = yes.
    
    find clien where clien.clicod = vclicod no-lock no-error.
    if not avail clien
    then run erro("Cliente nao localizado").
    else do.
        vcpf = trim(clien.ciccgc).
        run cpf.p (vcpf, output par-ok).
        if not par-ok
        then vehcpf = no.
    end.
end.
else run erro("Parametros de Entrada nao recebidos").


if vstatus = "S"
then do.
    setbcod = int(VerificaCreditoVenda.codigo_filial).
    
end.

if vstatus = "S"
then do:

    vtime = time.
    
    /* 100 */
    find neuclien where neuclien.cpfcnpj = dec(clien.ciccgc) /** int64 **/
        no-lock no-error.
    if not avail neuclien
    then do:
         create PreAutorizacao.
         preAutorizacao.codigo_filial   = verificacreditovenda.codigo_filial.
         preAutorizacao.codigo_cliente  = string(clien.clicod).
         preautorizacao.cpf             = clien.ciccgc.
         preautorizacao.tipo_pessoa     = if clien.tippes
                                          then "J"
                                          else "F".
         preAutorizacao.nome_pessoa     = clien.clinom.
         preautorizacao.data_nascimento = string(year(clien.dtnasc),"9999") +
                                          ":" +
                                          string(month(clien.dtnasc),"99")  +
                                          ":" +
                                          string(day(clien.dtnasc),"99").

         run neuro/gravaneuclien_H.p (clien.ciccgc,
                                    output par-recid-neuclien).
     
         find neuclien
                where recid(neuclien) = par-recid-neuclien 
                no-lock 
                no-error.
        if not avail neuclien
        then do:
            vstatus = "E".
            vmensagem_erro = "Erro ao Cadastrar Credito Cliente".
        end.
    end.        
    else do:
        par-recid-neuclien = recid(neuclien).
    end. 
    
    if vstatus = "S"
    then do:
        if neuclien.clicod = ? 
        then do:  
            run neuro/gravaneuclihist.p   
                    (recid(neuclien), 
                     vtipoconsulta, 
                     setbcod), 
                     clien.clicod, 
                     neuclien.vctolimite, 
                     neuclien.vlrlimite, 
                     0,
                     neuclien.sit_credito).
        end.
        if neuclien.clicod <> clien.clicod
        then do:
            find clien where clien.clicod = neuclien.clicod no-lock.
        end.
    end.
    
    /* 100 */

end.

if vstatus = "S"
then do.

        /* 100 */

        vlojaneuro = no.
        vsit_credito = "R".
        vvlrlimite  = neuclien.vlrlimite.
        vvctolimite = neuclien.vctolimite.

        vneu_cdoperacao = "".       /* Usado para verificar se existe um Operacao Pendente */
        find first neuproposta where
            neuproposta.etbcod  = setbcod and
            neuproposta.dtinclu = today   and
            neuproposta.cpfcnpj = neuclien.cpfcnpj and
            neuproposta.hrinclu >= time - (5 * 60)
            no-lock no-error.

        if avail neuproposta
        then do:
            if neuproposta.neu_resultado = "P"
            then vneu_cdoperacao = neuproposta.neu_cdoperacao.
        end.

                                                               
        if vneu_cdoperacao = "" 
        then do:
            vPOLITICA = "P4". /* Pega Limite */
            if vehcpf
            then do:
                run neuro/submeteneuro.p (input setbcod,
                                          input vpolitica,
                                          input clien.clicod,
                                          0,
                                          output vlojaneuro,
                                          output vneurotech).
            end.
            else do:
                vlojaneuro = no.
                vneurotech = no.
            end.     
        end.             
        else do:
            vlojaneuro = yes.
            vneurotech = yes.
        end.

        if   vlojaneuro and
             (vneu_cdoperacao = "" and
                ( neuclien.vctolimite = ? or       /* Se nao tem limite valido */
                  neuclien.vctolimite < today      /* ou nao esta valido */
                  )
             )     
             or
             vlojaneuro = no /* 16.11.17*/
        then do:
                                 
            if vlojaneuro
            then do:
                find cpclien where cpclien.clicod = clien.clicod no-lock no-error.

                vrenda          = if clien.prorenda[1] = ?
                                  then 0
                                  else clien.prorenda[1].

                    vprops = 
                        "POLITICA="             + "CREDITO" + texto(string(setbcod,"9999")) +
                        "&PROP_CONTACLI="       + trim(string(clien.clicod))   
                       + "&PROP_CPFCLI="       + trim(texto(clien.ciccgc))   
                       + "&PROP_DTNASCCLI="      + texto(string(clien.dtnasc,"99/99/9999")) 
                       + "&PROP_LOJACAD="        + trim(texto(string(neuclien.etbcod))) 
                       + "&PROP_LIMITEATUAL="    + trim(texto(string(neuclien.vlrlimite))) 
                       + "&PROP_VALIDADELIM="    + (if neuclien.vctolimite = ? then ""
                                                   else string(neuclien.vctolimite,"99/99/9999") )
                       + "&PROP_PROFISSAO="      +      Texto(clien.proprof[1])
                       + "&PROP_RENDAMES="       +      string(vrenda)
                       + "&PROP_LOGRADCLI=" + Texto(clien.endereco[1])
                       + "&PROP_NUMERO="    + texto(string(clien.numero[1]))
                       + "&PROP_CEP="            +      Texto(clien.cep[1])  
                       + "&PROP_BAIRROCLI="      +      Texto(clien.bairro[1])
                       + "&PROP_COMPLEMENTO="    +      Texto(clien.compl[1])  
                       + "&PROP_CIDADE="         +      Texto(clien.cidade[1])
                       + "&PROP_UF="             +      Texto(clien.ufecod[1])
                       + "&PROP_NOTA="           + (if  not avail cpclien then ""
                                                  else texto( string(cpclien.var-int3) )   )
                                                  
                      +  "&PROP_FLXPOLITICA="    + vPOLITICA.
                      
                      
        
                if vprops <> ?
                then         run neuro/wcneurotech.p (setbcod,
                                                  int(VerificaCreditoVenda.numero_pdv),
                                                  input vprops,
                                                  input vPOLITICA,
                                                  input vtime,
                                                  input par-recid-neuclien, 
                                                  output vvlrLimite, 
                                                  output vvctolimite,
                                                  output vsit_credito, 
                                                  output vneuro-mens,
                                                  output vstatus,
                                                  output vmensagem_erro).
                else vstatus = "N".
                find current neuclien no-lock.
            end.
            else do:
                vtime = time.
                run neuro/callimiteadmcom.p (recid(neuclien),
                                             vtipoconsulta,
                                    vtime,
                                    setbcod,
                                    VerificaCreditoVenda.numero_pdv,
                                    output vvlrLimite,
                                    output vvctoLimite,
                                    output vsit_credito).
                vsit_credito = "A".
            end.
        end.
                       
                       
        
        find current neuclien no-lock.         
        
        run neuro/comportamento.p (neuclien.clicod, ?,  
                                   output var-propriedades). 
        var-atrasoatual = int(pega_prop("ATRASOATUAL")).
        var-salaberto = dec(pega_prop("LIMITETOM")).
        if var-salaberto = ? then var-salaberto = 0.
        var-sallimite  = vvlrlimite - var-salaberto.
        if var-sallimite = ? then var-sallimite = 0.
        var-atrasoparcperc = pega_prop("ATRASOPARCPERC").
        if var-atrasoparcperc = ? then var-atrasoparcperc = "". 
        var-parcpag = int(pega_prop("PARCPAG")). 
        if var-parcpag = ? then var-parcpag = 0.
                                

        vvlrvenda = (int(VerificaCreditoVenda.qtde_parcelas) * int(VerificaCreditoVenda.vlr_prestacao)).
                        
         
        
        vpolitica = substring(VerificaCreditoVenda.tipo_venda,5,2). /*Pega do p2k*/
        if vpolitica = "P5" or
           vpolitica = "P6" or
           vpolitica = "P7" or
           vpolitica = "P8"
        then.
        else vPOLITICA = "P5".   
                

        run neuro/submeteneuro.p (input setbcod, 
                                  input vpolitica,
                                  input clien.clicod,
                                  input vvlrvenda,
                                  output vlojaneuro,
                                  output vneurotech).

                               
        if     vneurotech = no and
               neuclien.vctolimite <> ? and     /* Se tem limite valido */
               neuclien.vctolimite >=  today  and
               var-sallimite - vvlrvenda >= 0  /* e tera saldo para esta venda */
        then  vsit_credito = "A".

        if vlojaneuro = yes and
           vneurotech = no  and
           (vvctolimite = ? or
            vvctolimite < today)
        then vneurotech = yes.   
        
        
        if vneurotech
        then do: 
                
            find cpclien where cpclien.clicod = clien.clicod no-lock no-error.
                
            vrenda          = if clien.prorenda[1] = ?
                              then 0
                              else clien.prorenda[1].
                                                                                      
            
            
            vprops =  
                "POLITICA="               + "CREDITO" + string(setbcod,"9999")   
                + (if vneu_cdoperacao = ""
                   then ""
                   else "&PROP_IDOPERACAO=" + trim(vneu_cdoperacao))
                + "&PROP_CONTACLI="       + trim(string(clien.clicod))     
                + "&PROP_CPFCLI="         + trim(clien.ciccgc)    
                + "&PROP_NOMECLI="        + trim(clien.clinom)    
                + "&PROP_LOJAVENDA="      + Texto(VerificaCreditoVenda.codigo_filial) 
                + "&PROP_DTVENDA="        + Texto(VerificaCreditoVenda.codigo_filial) 
                + "&PROP_HORAVENDA="      + Texto(VerificaCreditoVenda.codigo_filial) 
                + "&PROP_PRODUTO="        + Texto(VerificaCreditoVenda.produtos_valores) 
                + "&PROP_QTDEPARC="       + Texto(VerificaCreditoVenda.qtde_parcelas) 
                + "&PROP_ACRESC="         + Texto(VerificaCreditoVenda.vlr_acrescimo) 
                + "&PROP_VALORENTRADA="   + Texto(VerificaCreditoVenda.vlr_entrada) 
                + "&PROP_VALORPARC="      + Texto(VerificaCreditoVenda.vlr_prestacao) 
                + "&PROP_DTPRIMVECTO="    + Texto(VerificaCreditoVenda.dt_primvcto) 
                + "&PROP_DTULTIMOVCTO="   + Texto(VerificaCreditoVenda.dt_ultivcto) 
                + "&PROP_VDATERCEIROS="   + Texto(VerificaCreditoVenda.vdaterceiros) 
                + "&PROP_LIMITEATUAL="    + trim(string(neuclien.vlrlimite))  
                + "&PROP_VALIDADELIM="    + (if neuclien.vctolimite = ? then "" 
                                            else string(neuclien.vctolimite,"99/99/9999") )
                + "&PROP_PROFISSAO="      +      Texto(clien.proprof[1]) 
                + "&PROP_RENDAMES="       +      string(vrenda) 
                + "&PROP_LOGRADCLI="      + Texto(clien.endereco[1]) 
                + "&PROP_NUMERO="         + texto(string(clien.numero[1])) 
                + "&PROP_CEP="            + Texto(clien.cep[1])   
                + "&PROP_BAIRROCLI="      + Texto(clien.bairro[1]) 
                + "&PROP_CIDADE="         + Texto(clien.cidade[1]) 
                + "&PROP_UF="             + Texto(clien.ufecod[1]) 
                + "&PROP_NOTA="           + (if  not avail cpclien then ""
                                             else texto( string(cpclien.var-int3) )   )
                + "&PROP_DTNASCCLI="      + texto(string(clien.dtnasc,"99/99/9999")) 
                + "&PROP_LIMITETOM="    + string(var-salaberto)
                + "&PROP_LIMITEDISP="    + string(var-sallimite)
                + "&PROP_ATRASOATUAL="    + string(var-atrasoatual)
                + "&PROP_ATRASOPARCPERC=" + texto(var-atrasoparcperc)
                + "&PROP_PARCPAG=" + string(var-parcpag)
                + "&PROP_DTADMISSAO="     +      texto(string(clien.prodta[1],"99/99/9999"))
                + "&PROP_FLXPOLITICA="    + vPOLITICA  .
                

            run neuro/wcneurotech.p (setbcod, 
                                     int(VerificaCreditoVenda.numero_pdv), 
                                     input vprops, 
                                     input vPOLITICA, 
                                     input vtime, 
                                     input par-recid-neuclien,  
                                     output vvlrLimite,  
                                     output vvctolimite, 
                                     output vneuro-sit,  
                                     output vneuro-mens, 
                                     output vstatus, 
                                     output vmensagem_erro). 
        
            var-sallimite  = vvlrlimite - var-salaberto.
                                     
            if vstatus = "S" /* Sem Erros */
            then do:  
                if vneuro-sit = "P"   
                then vneuro-mens = if vneuro-mens = "" 
                                       then "Encaminhar Cliente a FILA DE CREDITO"
                                           else vneuro-mens.
                else vneuro-mens = if vneuro-mens = ""
                                   then ""
                                   else vneuro-mens.
                vsit_credito = vneuro-sit.
            end.
            else do:
                vneurotech = no. /* Usa Processo ADMCOM */
                vstatus = "S".
                vmensagem_erro = "".
            end.                
        end.
            

        if vlojaneuro = no
        then vsit_credito = "V".

end.

BSXml("ABREXML","").
bsxml("abretabela","return").

bsxml("status",vstatus).
bsxml("mensagem_erro",vmensagem_erro).
bsxml("codigo_filial",VerificaCreditoVenda.codigo_filial).
bsxml("numero_pdv",VerificaCreditoVenda.numero_pdv).


if avail clien
then do:
    if clien.clicod = 200
    then bsxml("sit_credito", "P").
    else
        if clien.clicod = 300
        then bsxml("sit_credito", "A").
        else
            if clien.clicod = 400
            then bsxml("sit_credito", "R").
            else
                if clien.clicod = 10002191
                then bsxml("sit_credito","X").
    else bsxml("sit_credito", vsit_credito).
end.    
else bsxml("sit_credito", vsit_credito).



bsxml("credito",string(vvlrlimite)).
bsxml("valor_limite",string(var-sallimite)).
bsxml("vcto_credito",EnviaData(vvctolimite)).
bsxml("mensagem_credito", vneuro-mens).

bsxml("fechatabela","return").
BSXml("FECHAXML","").


procedure erro.
    def input parameter par-erro as char.

    assign
        vstatus = "E"
        vmensagem_erro = par-erro.

end procedure.
