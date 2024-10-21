
/* API REST */
def input  parameter vlcentrada as longchar.


def var vlcsaida   as longchar.
def var vsaida as char.

DEFINE VARIABLE lokJSON                  AS LOGICAL.
def var hEntrada     as handle.
def var hSAIDA            as handle.

def temp-table ttproposta no-undo serialize-name "proposta"
    field idOperacaoMotor as char
    field statusProposta as char
    field politica  as char
    field fluxo as char
    field cpf as char.

def temp-table ttrets   no-undo serialize-name "rets"
    field chave as char
    field valor as char.


def dataset dadosEntrada for ttproposta, ttrets.

def temp-table ttreturn no-undo serialize-name "dadosSaida"
    field resposta  as char.


hentrada = dataset dadosEntrada:HANDLE.

lokJSON = hentrada:READ-JSON("longchar",vlcentrada, "EMPTY").

hsaida = TEMP-TABLE ttreturn:HANDLE.

    create ttreturn.

    find first ttproposta no-error.
    if not avail ttproposta
    then do:
            
            ttreturn.resposta = "Dados NÃ£o Fornecedos na Proposta".
    end.    
    else do on error undo:
        find neuproposta where neuproposta.neu_cdoperacao = ttproposta.idOperacaoMotor 
            exclusive no-wait no-error.
        if avail neuproposta
        then do:
            find neuclien  where neuclien.cpf = neuproposta.cpf exclusive.
            ttreturn.resposta = "ok".
            if neuproposta.neu_resultado <> ttproposta.statusProposta or
               ttproposta.statusProposta = "A"
            then do:
                def var p-ret-props as char.
                def var p-neuro-mens as char.
                def var p_vlrlimite as dec.
                def var p_vctolimite as date.
                def var vvlrlimitecompl as dec.
                                
                p-ret-props = "".
                p-neuro-mens = "".
                
                run log("PROPOSTA EXISTENTE ID=" + ttproposta.idOperacaoMotor + " ESTA " + neuproposta.neu_resultado +
                            " ATUALIZACAO para " + ttproposta.statusProposta).  

                neuproposta.neu_resultado = ttproposta.statusProposta.
                
                if NeuProposta.neu_resultado = "A" or
                   NeuProposta.neu_resultado = "R"
                then do:
 
                    for each ttrets.
                        run log("     ID=" + ttproposta.idOperacaoMotor + " RETORNOS " + ttrets.chave +
                                    " = " + ttrets.valor).  

                        p-ret-PROPS = p-ret-PROPS + 
                                      (if p-ret-PROPS = "" then "" else "&") +
                                       ttrets.chave + "=" + ttrets.valor.

                        if ttrets.chave begins "RET_MOTIVO" and /* hlio 181024 1384 Motivo Reprovação - Motor de credito */
                           ttrets.valor <> ""
                        then do:
                            p-neuro-mens = p-neuro-mens + 
                                           (if p-neuro-mens = ""
                                            then ""
                                            else "/ ") + ttrets.valor.
                        end.

                        if ttrets.chave = "RET_NOVOLIMITE" and NeuProposta.neu_resultado = "A"
                        then p_vlrlimite = if dec(ttrets.valor) <> 0
                                           then dec(ttrets.valor)
                                           else neuclien.vlrlimite.
    
                        if ttrets.chave = "RET_LIMITECOMPL" and NeuProposta.neu_resultado = "A"
                        then vvlrlimitecompl = if dec(ttrets.valor) <> 0
                                               then dec(ttrets.valor)
                                               else 0.
    
                        if ttrets.chave = "RET_DTLIMITEVAL" and NeuProposta.neu_resultado = "A"
                        then p_vctolimite = if date(ttrets.valor) <> ?
                                            then date(ttrets.valor)
                                            else neuclien.vctolimite.
           

                    end.
                    if p-neuro-mens <> ""
                    then do:
                         ttreturn.resposta = p-neuro-mens.
                         neuproposta.RET_MOTIVOS = p-neuro-mens.
                    end.
                
                    assign
                        neuproposta.dtlibera = today
                        neuproposta.hrlibera = time.
                end.
                
                if NeuProposta.neu_resultado = "A"
                then do:
                    run log("gravaneuclihist " + string(p_vctolimite,"99/99/9999") ).
                    run neuro/gravaneuclihist.p 
                            (recid(neuclien),
                             neuproposta.TipoConsulta,
                             neuproposta.etbcod, 
                             neuclien.clicod, 
                             p_vctolimite, 
                             p_vlrlimite, 
                             vvlrlimitecompl,
                             ttproposta.statusProposta).

                    neuproposta.vlrlimite      = p_vlrlimite.
                    neuproposta.vlrlimitecompl = vvlrlimitecompl.
                    neuproposta.vctolimite     = p_vctolimite.
                    
                end.
                
                if NeuProposta.neu_resultado = "A" or
                   NeuProposta.neu_resultado = "R"
                then do:      
                    def buffer bNeuPropostaOper for NeuPropostaOper      .
                    
                    find last bNeuPropostaOper where
                                 bNeuPropostaOper.etbcod  = neuproposta.etbcod
                    /* #1 */ and bNeupropostaoper.cxacod  = neuproposta.cxacod
                             and bNeuPropostaOper.dtinclu = neuproposta.dtinclu
                             and bNeuPropostaOper.cpfcnpj = neuproposta.cpfcnpj
                    /* #1 */ and bNeuPropostaOper.neu_cdoperacao =
                                                    neuproposta.neu_cdoperacao
                                   no-lock no-error.
                    create NeuPropostaOper.
                    assign
                        NeuPropostaOper.etbcod  = neuproposta.etbcod
                        NeuPropostaOper.dtinclu = neuproposta.dtinclu
                        NeuPropostaOper.hrinclu = neuproposta.hrinclu
                        NeuPropostaOper.cpfcnpj = neuproposta.cpfcnpj
                        NeuPropostaOper.seq     = if avail bNeuPropostaOper
                                              then bNeuPropostaOper.seq + 1
                                              else 1
                        neupropostaoper.neu_cdoperacao = neuproposta.neu_cdoperacao 
                        neupropostaoper.ret_cdoperacao = neuproposta.neu_cdoperacao
                        NeuPropostaOper.cxacod  = neuproposta.cxacod
                        NeuPropostaOper.tipoconsulta   = neuproposta.tipoconsulta
                        NeuPropostaoper.neuprops       = neuproposta.NeuProps
                        NeuPropostaoper.retprops       = p-ret-props /* #1 par-props */.
                        neupropostaoper.vlrlimite      = p_vlrlimite.
                        neupropostaoper.vlrlimitecompl = neuproposta.vlrlimitecompl.
                        neupropostaoper.vctolimite     = p_vctolimite.
                end.
                        
            end.
            else do:
                run log("PROPOSTA EXISTENTE ID=" + ttproposta.idOperacaoMotor + " ESTA " + neuproposta.neu_resultado +
                            " E MANTEM EM " + ttproposta.statusProposta).  

            end.

        end.
        else do:
                                                                                               
            ttreturn.resposta = "PROPOSTA NAO EXISTENTE ID=" + ttproposta.idOperacaoMotor.

        end.
    end.

    run log(ttreturn.resposta).


    lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).
    put unformatted string(vlcsaida).

/* 
message string(vlcsaida).
*/


procedure log.

    def input parameter par-texto as char.

    def var varquivo as char.

    varquivo = "/ws/log/apipdv_atualizaNeuProposta" + string(today, "99999999") + ".log".

    output to value(varquivo) append.
    put unformatted string(time,"HH:MM:SS")
        " atualizaNeuProposta " par-texto skip.
    output close.

end procedure.


