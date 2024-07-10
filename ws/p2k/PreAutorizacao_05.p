
{/u/bsweb/progr/acha.i}

/* 100 */
def var par-recid-neuclien as recid.
def var par-recid-neuproposta as recid.
def var vtipoconsulta          as char init "WsP1".
def var vtime                  as int.
def var vvlrlimite             as dec.
 
def var vvctolimite            as date. 
def var vneurotech             as log init no.
def var vlojaneuro             as log init no. 
def var vsit_credito as char.
def var vprops as char.
def var vPOLITICA as char.

/* 100 */

def var vcpf    as char.
def var par-ok  as log.
def var vchar   as char.
def var vdtnasc as date.
def var vneuro-sit  as char.
def var vneuro-mens as char.  
def var vclicod as int init ?.
def var vstatus as char.   
def var vmensagem_erro as char.

def shared temp-table PreAutorizacao
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

{/u/bsweb/progr/bsxml.i}

find first PreAutorizacao  no-error.
if avail PreAutorizacao
then do.
    vstatus = "S".
    vcpf = PreAutorizacao.cpf.
    preautorizacao.nome_pessoa = caps(preautorizacao.nome_pessoa). 
    if trim(preAutorizacao.tipo_pessoa) = "J"
    then do: 
        run cgc.p (vcpf, output par-ok).
        if not par-ok
        then run erro("CNPJ Invalido").
    end.
    else do:
        run cpf.p (vcpf, output par-ok).
        if not par-ok
        then run erro("CPF invalido").
    end.

    /**if vstatus = "S"
    then do.
        find first clien where clien.ciccgc = PreAutorizacao.cpf
                no-lock no-error.
        if avail clien
        then run erro("Cliente ja cadastrado com este CPF:" +
                      string(clien.clicod)).
    end.**/                    

    if vstatus = "S"
    then do.
        vchar = PreAutorizacao.data_nascimento.
        if testavalido(vchar)
        then vdtnasc = date(int(substring(vchar,6,2)),
                             int(substring(vchar,9,2)),
                            int(substring(vchar,1,4))) no-error.
         if vdtnasc = ? or vdtnasc = 01/01/1900
         then run erro("Data de nascimento invalida").
    end.
end.
else run erro("Parametros de Entrada nao recebidos").

if vstatus = "S"
then do.

    vtime = time.
    vPOLITICA = "P1".
    vstatus = "S".
    vneuro-sit = "".
    
    vdtnasc = date(int(substring(preAutorizacao.data_nascimento,6,2)),
                   int(substring(preAutorizacao.data_nascimento,9,2)),
                   int(substring(preAutorizacao.data_nascimento,1,4))).        

    vprops = 
            "POLITICA="             + "CREDITO" + string(int(preAutorizacao.codigo_filial),"9999") +
            "&PROP_NOMECLI="   + trim(preAutorizacao.nome_pessoa) +  
            "&PROP_CPFCLI="            + vcpf +
            "&PROP_DTNASCCLI="      + trim(string(vdtnasc,"99/99/9999")) +
            "&PROP_CATEGCLI="       + trim(preAutorizacao.categoria_profissional) +
            "&PROP_CONTAMAE="       + trim(preAutorizacao.codigo_mae) +
            "&PROP_NOMEMAE="        + trim(preAutorizacao.mae) +
            "&PROP_LOJACAD="        + trim(preAutorizacao.codigo_filial) +
            "&PROP_FLXPOLITICA="    + vPOLITICA.

    /* 100 */
    find neuclien where neuclien.cpfcnpj = dec(preAutorizacao.cpf) /** int64 **/
        no-lock no-error.
    if not avail neuclien
    then do:
         run neuro/gravaneuclien_H.p (preAutorizacao.cpf,
                                      output par-recid-neuclien).
     
         find neuclien
                where recid(neuclien) = par-recid-neuclien 
                no-lock 
                no-error.
        if not avail neuclien
        then do:
            run erro("Erro ao Cadastrar Credito Cliente").
        end.
    end.        
    else do:
        par-recid-neuclien = recid(neuclien).
        if  neuclien.clicod <> ? 
        then do:
            vclicod = neuclien.clicod.
            vneuro-sit  = "E". /**neuclien.sit_credito.**/
            vneuro-mens = "Cliente existe na base, favor executar Consulta Cliente.".
            vstatus = "S".
            vmensagem_erro = "".
        end.            
    end.
    /* 100 */
   
    if vstatus = "S" and
       vneuro-sit = "" 
    then do: 
    
        /** Testa se vai para NEUROTECH **/  
               
        run neuro/submeteneuro.p (input int(preAutorizacao.codigo_filial) ,
                                  input vpolitica,
                                  input neuclien.clicod,
                                  0,
                                  output vlojaneuro,
                                  output vneurotech).
        
        if vneurotech
        then do:
        
            run neuro/wcneurotech.p (int(preAutorizacao.codigo_filial),
                                              int(preAutorizacao.numero_pdv),
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

            if vstatus = "S" /* Sem Erros */
            then do:
                if vneuro-sit = "A" /* Aprovado Neuro */
                then do:
                    vclicod = neuclien.clicod.
                    if vclicod = ?
                    then run neuro/gravaclien.p
                            (par-recid-neuclien,
                             vpolitica,
                             int(preAutorizacao.codigo_filial),
                             vcpf,
                             output vclicod,
                             output vstatus).
                    find clien where clien.clicod = vclicod 
                        no-lock no-error.
                    if not avail clien
                    then do:
                        run erro("Erro ao Cadastrar Cliente").
                    end.
                end.
                else do:
                    if vneuro-sit = "P" 
                    then vneuro-mens = if vneuro-mens = ""
                                       then "Encaminhar o Cliente a FILA DE CREDITO."
                                       else vneuro-mens.
                    else vneuro-mens = if vneuro-mens = ""
                                       then ""
                                       else vneuro-mens.
                end.
            end.
            else do:
                vneurotech = no. /* Usa Processo ADMCOM */
                vstatus = "S".
                vmensagem_erro = "".
            end.                
        end.
        
    
        if not vneurotech /* ADMCOM */
        then do:
            vtime = time.
            vneuro-sit = "".
            vneuro-mens = "".
            
            vclicod = neuclien.clicod.
            
            if vclicod = ?
            then run neuro/gravaclien.p
                    (par-recid-neuclien,
                     vpolitica + "ADMCOM",
                     int(preAutorizacao.codigo_filial),
                     vcpf,
                     output vclicod,
                     output vstatus).
            
            if vstatus = "S"
            then vneuro-sit = "A".
            else do:
                vneuro-sit = "R".
                vmensagem_erro = "ADMCOM - Erro Cadastrar Cliente".
            end.    
            
            run neuro/gravaneuclilog.p
                     (neuclien.cpfcnpj,
                      vpolitica + "ADMCOM",
                      vtime, 
                      int(preAutorizacao.codigo_filial), 
                      int(preAutorizacao.numero_pdv),
                      if vstatus = "S"
                      then vneuro-sit
                      else neuclien.sit_credito,
                      if vstatus = "S"
                      then vneuro-mens
                      else vmensagem_erro). 

        end.
    end.
    else do:
        run neuro/gravaneuclilog.p
                (preAutorizacao.cpf,
                 vtipoconsulta,
                 vtime,
                 preAutorizacao.codigo_filial,
                 preAutorizacao.numero_pdv,
                 "",
                 vmensagem_erro).
                 
    end. 
end.


BSXml("ABREXML","").
bsxml("abretabela","return").

bsxml("status",vstatus).
bsxml("mensagem_erro",vmensagem_erro).
bsxml("codigo_filial",PreAutorizacao.codigo_filial).
bsxml("numero_pdv",PreAutorizacao.numero_pdv).

bsxml("sit_credito", vneuro-sit).
bsxml("codigo_cliente",if vclicod <> ? then string(vclicod) else "").
bsxml("mensagem_credito", vneuro-mens).
         
bsxml("fechatabela","return").
BSXml("FECHAXML","").


procedure erro.
    def input parameter par-erro as char.

    assign
        vstatus = "E"
        vmensagem_erro = par-erro.

end procedure.

