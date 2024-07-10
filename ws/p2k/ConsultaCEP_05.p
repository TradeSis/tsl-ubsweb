
{/u/bsweb/progr/acha.i}

def var vstatus as char.   
def var vmensagem_erro as char.

def shared temp-table ConsultaCEP
    field codigo_filial   as char
    field codigo_operador as char
    field numero_pdv      as char
    field CEP             as char.

{/u/bsweb/progr/bsxml.i}

find first ConsultaCEP no-lock no-error.
if avail ConsultaCEP
then do.
    vstatus = "S".
end.
else run erro("Parametros de Entrada nao recebidos").

if vstatus = "S"
then do.

        /**
       
            run neuro/wcneurotech.p (int(ConsultaCEP.codigo_filial),
                                     int(ConsultaCEP.numero_pdv),
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
                             int(ConsultaCEP.codigo_filial),
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
                    if vneuro-sit = "R" 
                    then vneuro-mens = if vneuro-mens = ""
                                       then "Encaminhar Cliente a FILA DE CREDITO"
                                       else vneuro-mens.
                    else vneuro-mens = if vneuro-mens = ""
                                       then "Erro ao acessar o Motor de Credito"
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
            vneuro-mens = "Aprovacao ADMCOM".
            
            vclicod = neuclien.clicod.
            
            if vclicod = ?
            then run neuro/gravaclien.p
                    (par-recid-neuclien,
                     vpolitica + "ADMCOM",
                     int(ConsultaCEP.codigo_filial),
                     output vclicod,
                     output vstatus).
            
            if vstatus = "S"
            then vneuro-sit = "A".
            else vmensagem_erro = "ADMCOM - Erro Cadastrar Cliente".
            
            run neuro/gravaneuclilog.p
                     (neuclien.cpfcnpj,
                      vpolitica + "ADMCOM",
                      vtime, 
                      int(ConsultaCEP.codigo_filial), 
                      int(ConsultaCEP.numero_pdv),
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
                (ConsultaCEP.cpf,
                 vtipoconsulta,
                 vtime,
                 ConsultaCEP.codigo_filial,
                 ConsultaCEP.numero_pdv,
                 "",
                 vmensagem_erro).
                 
    end.
     
    **/
     
     
end.

BSXml("ABREXML","").
bsxml("abretabela","return").

bsxml("status",vstatus).
bsxml("mensagem_erro",vmensagem_erro).
bsxml("codigo_filial",ConsultaCEP.codigo_filial).
bsxml("numero_pdv",ConsultaCEP.numero_pdv).

bsxml("CEP", consultaCEP.CEP).
bsxml("Logradouro","").
bsxml("Bairro", "").
bsxml("Cidade", "").
bsxml("UF", "").
bsxml("CEPGeral", "").
       
bsxml("fechatabela","return").
BSXml("FECHAXML","").


procedure erro.
    def input parameter par-erro as char.

    assign
        vstatus = "E"
        vmensagem_erro = par-erro.

end procedure.

