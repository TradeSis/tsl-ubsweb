<?php
/* helio 022023 insert nop crediario admcom */


$log_datahora_ini = date("dmYHis");
$acao="gera-contrato";  
$mypid = getmypid();
$identificacao=$log_datahora_ini."-PID".$mypid."-"."$acao";
$arqlog = "/ws/log/apivarejo_credito-pessoal_".date("dmY").".log";
$arquivo = fopen($arqlog,"a");
function isJson($string) {
  json_decode($string);
  return json_last_error() === JSON_ERROR_NONE;
} 

fwrite($arquivo,$identificacao."-ENTRADA->".json_encode($jsonEntrada)."\n");

$progr = new chamaprogress();


//var_dump($jsonEntrada);
$recebimentos = $jsonEntrada["recebimentos"][0];
$seguros = $jsonEntrada["seguros"][0];
  $conteudoEntrada = json_encode(
    array('dadosEntrada' =>  array(
              'entrada' => 
                    array(
                          array('codigoLoja' =>  $jsonEntrada["codigoLoja"], 
                                'dataTransacao' =>  $jsonEntrada["dataTransacao"], 
                                'numeroComponente' =>  $jsonEntrada["numeroComponente"], 
                                'sequencial' => $jsonEntrada["sequencial"], 
                                'tipoVenda' =>  $jsonEntrada["cabecario"]["tipoVenda"], 
                                'numeroCupom' =>  $jsonEntrada["cabecario"]["numeroCupom"], 
                                'codigoCliente' =>  $jsonEntrada["cabecario"]["codigoCliente"], 
                                'valorTotal' =>  $jsonEntrada["cabecario"]["valorTotal"], 
                                'valorTroco' =>  $jsonEntrada["cabecario"]["valorTroco"], 
                                'hora' =>  $jsonEntrada["cabecario"]["hora"], 
                                'tipoTransacao' =>  $jsonEntrada["cabecario"]["tipoTransacao"], 
                                'codigoOperador' =>  $jsonEntrada["cabecario"]["codigoOperador"], 
                                'tipoPedido' =>  $jsonEntrada["cabecario"]["tipoPedido"], 
                                'numeroCpfCnpj' =>  $jsonEntrada["cabecario"]["numeroCpfCnpj"], 
                                'agenciaArrecadadora' =>  $jsonEntrada["cabecario"]["agenciaArrecadadora"], 
                                'codigoVendedor' =>  $jsonEntrada["cabecario"]["codigoVendedor"], 
                                'empresaCreditada' => $jsonEntrada["cabecario"]["empresaCreditada"]
                              
                              )
                          )
                    , // entrada
                 'recebimentos' => 
                    array(
                          array('numSeqForma' =>  $recebimentos["numSeqForma"], 
                                'codigoForma' =>  $recebimentos["codigoForma"], 
                                'codigoPlano' =>  $recebimentos["codigoPlano"], 
                                'valorPagoForma' => $recebimentos["valorPagoForma"], 
                                'numSeqRecCrediario' =>  $recebimentos["recebimentoCrediario"][0]["numSeqRecCrediario"], 
                                'codCliente' =>  $recebimentos["recebimentoCrediario"][0]["codCliente"], 
                                'numeroContrato' =>  $recebimentos["recebimentoCrediario"][0]["numeroContrato"], 
                                'primeiroVencimento' =>  $recebimentos["recebimentoCrediario"][0]["primeiroVencimento"], 
                                'qtdParcelas' =>  $recebimentos["recebimentoCrediario"][0]["qtdParcelas"], 
                                'valorFinanciamento' =>  $recebimentos["recebimentoCrediario"][0]["valorFinanciamento"], 
                                'valEncargoFinanc' =>  $recebimentos["recebimentoCrediario"][0]["valEncargoFinanc"], 
                                'contratoFinanceira' =>  $recebimentos["recebimentoCrediario"][0]["contratoFinanceira"], 
                                'valorIof' =>  $recebimentos["recebimentoCrediario"][0]["valorIof"], 
                                'cetAno' =>  $recebimentos["recebimentoCrediario"][0]["cetAno"], 
                                'txMes' =>  $recebimentos["recebimentoCrediario"][0]["txMes"], 
                                'cet' =>  $recebimentos["recebimentoCrediario"][0]["cet"], 
                                'valorAcrescimo' => $recebimentos["recebimentoCrediario"][0]["valorAcrescimo"],
                                'dataEmissaoContrato' => $recebimentos["recebimentoCrediario"][0]["dataEmissaoContrato"],
                                'valorTfc' => $recebimentos["recebimentoCrediario"][0]["valorTfc"],
                                'codProdutoFinanceiro' => $recebimentos["recebimentoCrediario"][0]["codProdutoFinanceiro"],    
                                'parcelas' =>  $recebimentos["recebimentoCrediario"][0]["parcelas"]                                                                                     
                              )
                    ),
                     // recebimento    
                     'seguros' => 
                     array(
                           array('numSeqForma' =>  $seguros["numSeqForma"], 
                                 'numSeqSeguro' =>  $seguros["numSeqSeguro"], 
                                 'numeroContrato' =>  $seguros["numeroContrato"], 
                                 'valorSeguro' => $seguros["valorSeguro"], 
                                 'numApolice' =>  $seguros["numApolice"],
                                 'numSorteio' =>  $seguros["numSorteio"],
                                 'tipoSeguro' =>  $seguros["tipoSeguro"]
                               )
                           )
                      // seguros                    
 
                  )
              )
            );

 fwrite($arquivo,$identificacao."-ENTRADAFORMATADO->".$conteudoEntrada."\n");
 
      $retorno = $progr->executarprogress("varejo/1/cpgeracontrato",$conteudoEntrada,$dlc,$pf,$propath,$progresscfg,$tmp,$proginicial);

      fwrite($arquivo,$identificacao."-Progress_SAIDA->".$retorno."\n");

        if (!isJson($retorno)) {  
            $jsonSaida = json_decode(json_encode( array("status" => 500, 
                                "retorno" => $retorno) 
                                ), TRUE); 
            fwrite($arquivo,$identificacao."-ERRO\n");
        } else {

            $conteudoSaida = (object) json_decode($retorno,true);
  

            if ($conteudoSaida->dados[0]) {
                $jsonSaida       = $conteudoSaida->dados[0];     

            } else {
    
            $status = (object) $conteudoSaida->conteudoSaida[0];
            

            $jsonSaida = json_decode(json_encode( array("status" => $status->status, 
                                    "retorno" => $status->descricaoStatus) 
                            ), TRUE); 


            }


        }
    
    fwrite($arquivo,$identificacao."-SAIDA->".json_encode($jsonSaida)."\n");

    fclose($arquivo);
            
            
?>