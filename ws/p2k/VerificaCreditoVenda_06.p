/* 28.03.2018 #_06 Cadastro Express Fase 1 */
/* 11.05.2018 #2 - Higienizacao CPF */
/* 17.05.2018 #3 - Melhorias Motor Pct 01 */
/* 01.06.2018 #4 helio - Solicitado novos campos para que o motor calcule o corte do limite quando tem novacao ou atraso */
/* 01.06.2018 #5 helio  Quando tem P2 Pendente , Reprova Venda */
/* 21.06.2018 #7 Helio - Revisao do Fluxo  */
/* 03.07.2018 #8 Helio - Revisao do Fluxo V2 */

{acha.i}            /* 03.04.2018 helio */
{neuro/achahash.i}  /* 03.04.2018 helio */
{neuro/varcomportamento.i} /* 03.04.2018 helio */
def var var-saldototnov as dec.
def var vtimeini as int.

/** 100    **/
def var par-recid-neuclien as recid.
def var vtipoconsulta          as char init "VC06".

def var vdtnasc as date.
/* #3 */
def var vneu_cdoperacao as char.
def var vneu_politica as char.

def var vsit_credito as char.
def var vvctolimite            as date. 
def var vvlrLimite              as dec.
def var vrenda as dec.
def var vtime                  as int.
def var vneurotech             as log init no.
def var vlojaneuro             as log init no. 
def var vvlrvenda           as dec.
def var vrenda_conjuge as dec.
def var vsituacao-instrucao as char.
def var vinstrucao  as char.
def var vseguro as char.
def var vplanosaude as char.
def var cestcivil as char.
def var vx as int.
def var vlstdadosbanco as char.
def var vlstrefcomerc  as char.
def var vlstcartaocred as char.
def var vveiculo       as char.
def var vlstdadosveic as char.     
def var vlstrefpessoais as char.
def var vlstspc as char.
def var vale-spc as char.
def var vche-spc as char.
def var vcre-spc as char.
def var vnac-spc as char.


/* Cartoes de loja */
def var vcartoes as char.
def var vct  as int.
def var auxcartao as char extent 7 format "x(20)"
      init ["Visa","Master","Banricompras","Hipercard",
            "Cartoes de Loja","American Express","Dinners"].
/* */





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
        then do:
            vehcpf = no.
            /* #8 */
            run erro ("Operacao de Credito Apenas para Pessoa Fisica").
            vstatus = "R".
        end.    
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
        /* #3 */
         run neuro/gravaneuclilog.p 
            (clien.ciccgc, 
             vtipoconsulta, 
             vtimeini, 
             setbcod, 
             verificacreditovenda.numero_pdv, 
             "", 
             "Cadastrando NeuClien"). 
    
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

         run neuro/gravaneuclien_06.p (clien.ciccgc,
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

        /* #3 */
        vneu_cdoperacao = "".       
        vneu_politica = "".
        /* Verifica se existe P2 Pendente */
            find first neuproposta where
                neuproposta.etbcod  = setbcod and
                neuproposta.dtinclu = today   and
                neuproposta.cpfcnpj = neuclien.cpfcnpj and
                neuproposta.hrinclu >= time - (10 * 60)
                and
                    (neuproposta.tipoconsulta = "P2" )
                and 
                    neuproposta.neu_resultado = "P" 
            no-lock no-error.

            if avail neuproposta
            then do:
                if neuproposta.neu_resultado = "P" and
                    (neuproposta.tipoconsulta = "P2" )
                then do:
                    vneu_cdoperacao = neuproposta.neu_cdoperacao.
                    vneu_politica   = neuproposta.tipoconsulta.
                    vsit_credito    = neuproposta.neu_resultado.
                end.    
            end.
         /* #3 */
 

        if vneu_cdoperacao = "" /* #3 Nao achou P2 Pendente */
        then do: 
            vneu_cdoperacao = "".       /* Usado para verificar se existe um Operacao Pendente */
            vneu_politica = "".
            find first neuproposta where
                neuproposta.etbcod  = setbcod and
                neuproposta.dtinclu = today   and
                neuproposta.cpfcnpj = neuclien.cpfcnpj and
                neuproposta.hrinclu >= time - (5 * 60)
                and
                    (neuproposta.tipoconsulta = "P5" or
                     neuproposta.tipoconsulta = "P6" or
                     neuproposta.tipoconsulta = "P7" or
                     neuproposta.tipoconsulta = "P8")
                and 
                    neuproposta.neu_resultado = "P" 
            
                no-lock no-error.

            if avail neuproposta
            then do:
                if neuproposta.neu_resultado = "P" and
                    (neuproposta.tipoconsulta = "P5" or
                     neuproposta.tipoconsulta = "P6" or
                     neuproposta.tipoconsulta = "P7" or
                     neuproposta.tipoconsulta = "P8")
                then do:
                    vneu_cdoperacao = neuproposta.neu_cdoperacao.
                    vneu_politica    = neuproposta.tipoconsulta.
                    vsit_credito    = neuproposta.neu_resultado.
                end.    
            end.
        end.
        
        if vneu_cdoperacao = "" 
        then do:
            vPOLITICA = "P4". /* Pega Limite */
            if vehcpf
            then do:
                run neuro/submeteneuro_v1802.p (input setbcod,
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


        /* #1 LOG PARA PRIMEIRA AVALIACAO SUBMETE */ 
        run neuro/gravaneuclilog.p 
                (neuclien.cpfcnpj, 
                 vtipoconsulta, 
                 0, 
                 setbcod, 
                 verificacreditovenda.numero_pdv, 
                 neuclien.sit_credito, 
                 if vneu_cdoperacao = ""
                 then "Politica " + vpolitica + " LJNeuro=" + string(vlojaneuro,"S/N") +
                                                " Submete=" + string(vneurotech,"S/N")
                 else  "Politica" + vneu_politica + " Operacao=" + string(vneu_cdoperacao) +
                      " SIT=" + vsit_credito). 
 
       
        /* Atualizar Limite */
        if  /* #3 - Quando Tiver P2 Pendente e nao for P2 Nao Sobe Neuro*/
            (vneu_cdoperacao <> "" and 
             vneu_politica   = "P2" and
             vPOLITICA       <> "P2") 
             or 
           (vneu_cdoperacao <> "" or
            (avail neuclien and
             (neuclien.vctolimite <> ? and neuclien.vctolimite >= today)
             )
            )
        then do:       
            if vneu_cdoperacao = ""
            then do:
                run neuro/gravaneuclilog.p 
                        (neuclien.cpfcnpj, 
                         vtipoconsulta, 
                         0, 
                         setbcod, 
                         VerificaCreditoVenda.numero_pdv, 
                         vsit_credito, 
                         "USANDO NEUCLIEN VCTO=" + string(neuclien.vctolimite) + 
                         " VLR=" + string(neuclien.vlrlimite)).
                vvlrLimite   = neuclien.vlrlimite.
                vvctoLimite  = neuclien.vctolimite.
            end.
            
        end.
        else do:
            /**
            *if   vlojaneuro and
            * (vneu_cdoperacao = "" and
            *    ( neuclien.vctolimite = ? or       /* Se nao tem limite valido */
            *      neuclien.vctolimite < today      /* ou nao esta valido */
            *      )
            * )     
            * or
            * vlojaneuro = no /* 16.11.17*/
            *then do:
            */
                                 
            if vneurotech
            then do:
                /* cai aqui 
                    QUANDO LOJANEURO e REGRAS SUBMISSAO = SUBMETE 
                */    
        
                find current neuclien no-lock.         
        
                run neuro/comportamento.p (neuclien.clicod, ?,  
                                       output var-propriedades). 

                var-atrasoatual = int(pega_prop("ATRASOATUAL")). /* #4 */
                var-saldototnov = dec(pega_prop("SALDOTOTNOV")). /* #4 */

                var-atrasoparcperc = pega_prop("ATRASOPARCPERC").
                if var-atrasoparcperc = ? then var-atrasoparcperc = "". 
        
                var-parcpag = int(pega_prop("PARCPAG")). 
                if var-parcpag = ? then var-parcpag = 0.
 
                find cpclien where cpclien.clicod = clien.clicod no-lock no-error.

                vrenda          = if clien.prorenda[1] = ?
                                  then 0
                                  else clien.prorenda[1].
                vrenda_conjuge  = if clien.prorenda[2] = ?
                                  then 0
                                  else clien.prorenda[2].
          
                    if avail cpclien and cpclien.var-char8 <> ?
                    then vinstrucao = acha("INSTRUCAO",cpclien.var-char8).
                    else vinstrucao = "".
                    if avail cpclien and cpclien.var-char6 <> ?
                    then vseguro = entry(1,trim(cpclien.var-char6),"=").
                    else vseguro = "".
                    if avail cpclien and cpclien.var-char7 <> ?
                    then vplanosaude = entry(1,cpclien.var-char7,"=").
                    else vplanosaude = "".
         
                    vlstcartaocred = "".
                    do vx = 1 to 7.
                        if avail cpclien  
                        then if int(cpclien.var-int[vx]) > 0
                             then vlstcartaocred = vlstcartaocred + auxcartao[vx].
                        if vx < 7 
                        then  vlstcartaocred = vlstcartaocred + ";".     
                    end.
                                
                /* veiculo */
                vveiculo = "N".
                vlstdadosveic = "".
                find carro where carro.clicod = clien.clicod no-lock no-error.
                if avail carro
                then if carro.carsit 
                     then vveiculo = "S".
                if vveiculo = "S"
                then do:
                    vlstdadosveic =  Texto(carro.marca) +  ";" +
                                     Texto(carro.modelo) + ";" +
                                   if carro.ano <> ?
                                   then string(carro.ano,"9999")         
                                   else "".
                end.
                vlstrefpessoais = "".
                do vx = 1 to 3.
                    vlstrefpessoais = vlstrefpessoais +
                                      (if vlstrefpessoais = ""
                                       then ""
                                       else ";")
                                       +
                                         Texto(clien.entbairro[vx]) + "|" + 
                                         Texto(clien.entcep[vx])    + "|" + 
                                         Texto(clien.entcidade[vx]) + "|" +
                                         Texto(clien.entcompl[vx]). 
                   end.

                vlstrefcomerc = "".
                do vx = 1 to 5:
                    vlstrefcomerc = vlstrefcomerc + 
                                    (if vlstrefcomerc = "" then "" else ";")
                                    +  
                                    Texto(clien.refcom[vx]) +
                                     "|".
                    if avail cpclien
                    then do:
                        if cpclien.var-ext1[vx] = "1" then   vlstrefcomerc = (vlstrefcomerc + "Apresentado").
                        else
                        if cpclien.var-ext1[vx] = "2" then vlstrefcomerc = (vlstrefcomerc + "Nao Apresentado").
                        else
                        if cpclien.var-ext1[vx] = "3" then vlstrefcomerc = vlstrefcomerc + "Nao possui cartao".
                        else vlstrefcomerc = (vlstrefcomerc + " ").  
                    end.                        
                    else vlstrefcomerc = vlstrefcomerc + " ".
                end.
                vlstdadosbanco = "".
                do vx = 1 to 4.
                    /*    
                    if avail cpclien and
                    (cpclien.var-ext2[vx] = "BANRISUL" or 
                     cpclien.var-ext2[vx] = "CAIXA ECONOMICA FEDERAL" or
                     cpclien.var-ext2[vx] = "BANCO DO BRASIL" or
                     cpclien.var-ext2[vx] = "OUTROS")
                    then*/ do:   
                        vlstdadosbanco = vlstdadosbanco +
                                        (if vlstdadosbanco = "" then "" else ";") +
                                         texto(if avail cpclien then cpclien.var-ext2[vx] else "") + "|" +
                                         texto(if avail cpclien then cpclien.var-ext3[vx] else "") + "|" +
                                         texto(if avail cpclien then cpclien.var-ext4[vx] else "").
                    end.
                end.   
                cestcivil = if clien.estciv = 1 then "Solteiro" else
                            if clien.estciv = 2 then "Casado"   else
                            if clien.estciv = 3 then "Viuvo"    else
                            if clien.estciv = 4 then "Desquitado" else
                            if clien.estciv = 5 then "Divorciado" else
                            if clien.estciv = 6 then "Falecido" else "".
  

                    vdtnasc = clien.dtnasc.
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
                      + "&PROP_DTADMISSAO="     +      texto(string(clien.prodta[1],"99/99/9999"))
                       + "&PROP_CPFCONJUGE="   +  texto(substr(clien.conjuge,51,20))
                       + "&PROP_RENDACONJUGE="   +       string(vrenda_conjuge)  
                       + "&PROP_PROFCONJUGE=" + texto(clien.proprof[2])    
                       + "&PROP_TELEFONE="       +      Texto(clien.fone) 
                       + "&PROP_INSTRUCAOCLI="   + texto(vinstrucao)   
                       + "&PROP_SEGURO="         + texto(vseguro)
                       + "&PROP_PLANOSAUDE="     + texto(vplanosaude)
                       + "&PROP_LSTCARTAOCRED="  +  vlstcartaocred  
                       + "&PROP_VEICULO="        +  vveiculo
                       + "&PROP_LSTDADOSVEIC="   +  vlstdadosveic  
                       + "&PROP_LSTREFPESSOAIS=" +  vlstrefpessoais 
                       + "&PROP_LSTREFCOMERC="   +  vlstrefcomerc  
                       + "&PROP_LSTDADOSBANCO="  +  vlstdadosbanco  
                       + "&PROP_ESTADOCIVIL="    + texto(cestcivil)   
                       + "&PROP_DEPENDENTES="    + texto(string(clien.numdep))
                       + "&PROP_TIPORESID="      +      string(clien.tipres,
                                                            "Propria/Alugada")
                       + "&PROP_TEMPORESID="     +      texto(    substr(string(int(temres),"999999"),1,2) + "/"  + 
                                                                  substr(string(int(temres),"999999"),3,4) )

                       + "&PROP_DEPENDENTES="    + texto(string(clien.numdep))
                       + "&PROP_NOMECLI="        + trim(clien.clinom)   
                       + "&PROP_PARCPAG=" + string(var-parcpag)
                       + "&PROP_ATRASOPARCPERC=" + texto(var-atrasoparcperc)
                       + "&PROP_ATRASOATUAL="    + string(var-atrasoatual)  /* #4 */
                       + "&PROP_SALDOTOTNOV="    + string(var-saldototnov)  /* #4 */
    
                      +  "&PROP_FLXPOLITICA="    + vPOLITICA.
                pause 1 no-message. 
                vtimeini = time.
                if vprops <> ?
                then         run neuro/wcneurotech_v1801.p (setbcod,
                                                  int(VerificaCreditoVenda.numero_pdv),
                                                  input vprops,
                                                  input vPOLITICA,
                                                  input vtimeini,
                                                  input par-recid-neuclien, 
                                                  output vvlrLimite, 
                                                  output vvctolimite,
                                                  output vneuro-sit, 
                                                  output vneuro-mens,
                                                  output vstatus,
                                                  output vmensagem_erro).
                else vstatus = "N".
                
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
                /* #1 */
                run neuro/gravaneuclilog.p 
                        (neuclien.cpfcnpj, 
                         vtipoconsulta, 
                         0, 
                         setbcod, 
                         VerificaCreditoVenda.numero_pdv, 
                         neuclien.sit_credito, 
                         if not vneurotech
                         then "ERRO MOTOR - USARA ADMCOM"
                         else "SIT=" + vsit_credito +
                              " VCTO=" + (if vvctolimite = ?
                                         then "-"
                                         else string(vvctolimite)) + 
                              " LIM=" + (if vvlrlimite = ?
                                         then "-"
                                         else string(vvlrlimite))). 

                vtimeini = 0.


            end.

            if vneurotech = no 
            then do: /** ADMCOM **/

                pause 1 no-message.
                vtime = time.
                vtimeini = time.
                run neuro/callimiteadmcom.p (recid(neuclien),
                                    "ADMC", /* #8 */
                                    vtime,
                                    setbcod,
                                    VerificaCreditoVenda.numero_pdv,
                                    output vvlrLimite,
                                    output vvctoLimite,
                                    output vsit_credito).
                vsit_credito = "V". 
                /* #2 */
                run neuro/gravaneuclilog.p 
                        (neuclien.cpfcnpj, 
                         vtipoconsulta, 
                         vtimeini, 
                         setbcod, 
                         VerificaCreditoVenda.numero_pdv, 
                         vsit_credito, 
                         "ADMCOM SIT=" + vsit_credito +
                              " VCTO=" + (if vvctolimite = ?
                                         then "-"
                                         else string(vvctolimite)) + 
                              " LIM=" + (if vvlrlimite = ?
                                         then "-"
                                         else string(vvlrlimite))). 

                if vsit_credito = "E"
                then do:
                    vstatus = "E".
                    vmensagem_erro = "Erro ao calcular Limite Admcom". 
                end.
                
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
                

        /* #3 */
        if vneu_cdoperacao <> "" and
           vneu_politica   = "P2"
        then do:
            vlojaneuro   = yes.
            vneurotech   = no.
            vsit_credito = "R". /* #5 Quando tem P2 Pendente , Reprova Venda */
            vneuro-mens  = "Reprovado - Verifique Analise Mesa - P2".
        end.
        else do:
            run neuro/submeteneuro_v1802.p (input setbcod, 
                                        input vpolitica,
                                        input clien.clicod,
                                        input vvlrvenda,
                                        output vlojaneuro,
                                        output vneurotech).

            pause 1 no-message.
            vtimeini = time.
            run neuro/gravaneuclilog.p 
                    (neuclien.cpfcnpj, 
                     vtipoconsulta, 
                     vtimeini, 
                     setbcod, 
                     VerificaCreditoVenda.numero_pdv, 
                     neuclien.sit_credito, 
                     "Politica " + vpolitica + " LJNeuro=" + string(vlojaneuro,"S/N") +
                                              " Submete=" + string(vneurotech,"S/N")  +
                                              " Vlr=" + string(vvlrvenda)).
                                
            if vlojaneuro
            then do:
                if vneurotech = no and
                   neuclien.vctolimite <> ? and     /* Se tem limite valido */
                   neuclien.vctolimite >=  today  and
                   var-sallimite - vvlrvenda >= 0  /* e tera saldo para esta venda */
                then  vsit_credito = "A".
            end.
        
            if vlojaneuro = yes and
               vneurotech = no  and
               (vvctolimite = ? or
                vvctolimite < today)
            then vneurotech = yes.   
        
        end.    
        
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
                
                pause 1 no-message. 
                vtimeini = time.
        

            run neuro/wcneurotech_v1801.p (setbcod, 
                                     int(VerificaCreditoVenda.numero_pdv), 
                                     input vprops, 
                                     input vPOLITICA, 
                                     input vtimeini, 
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
                /* #1 */
                run neuro/gravaneuclilog.p 
                        (neuclien.cpfcnpj, 
                         vtipoconsulta, 
                         vtimeini, 
                         setbcod, 
                         VerificaCreditoVenda.numero_pdv, 
                         vsit_credito, 
                         if not vneurotech
                         then "ERRO MOTOR SIT=" + vsit_credito
                         else "SIT=" + vsit_credito +
                              " VCTO=" + (if vvctolimite = ?
                                          then "-"
                                          else string(vvctolimite)) +
                              " LIM=" + string(vvlrlimite) ).
            
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


    bsxml("sit_credito", vsit_credito).



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
