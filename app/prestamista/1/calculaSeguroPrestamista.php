<?php
/* helio 112022 - campanha seguro prestamista gratis */
/* helio 20012022 - [UNIFICAÇÃO ZURICH - FASE 2] NOVO CÁLCULO PARA SEGURO PRESTAMISTA MÓVEIS NA PRÉ-VENDA */

$log_datahora_ini = date("dmYHis");
$acao="calculaSeguroPrestamista";  
$mypid = getmypid();
$identificacao=$log_datahora_ini."-PID".$mypid."-"."$acao";
$arqlog = "/ws/log/apiprestamista_".date("dmY").".log";
$arquivo = fopen($arqlog,"a");
fwrite($arquivo,$identificacao."-ENTRADA->".json_encode($jsonEntrada)."\n");
                        

    $chamadaPREVENDA = "";

    $progr = new chamaprogress();
  //  $conteudoEntrada= json_encode($jsonEntrada);
    
  //  $conteudo = json_decode(json_encode($jsonEntrada["pedidoCartaoLebes"]));
    $dadosEntrada = $jsonEntrada["dadosEntrada"];
   
   
    if (!isset($dadosEntrada)) {
      
        $jsonEntrada = (object) $jsonEntrada["pedidoCartaoLebes"];
        $jsonEntradacartaoLebes = (object) $jsonEntrada->cartaoLebes;
        $conteudoEntrada= json_encode(
          array("dadosEntrada" => array(
                  "pedidoCartaoLebes"  =>  array(array(
                      "codigoLoja" => $jsonEntrada->codigoLoja,
                      "dataTransacao" => $jsonEntrada->dataTransacao,
                      "numeroComponente" => $jsonEntrada->numeroComponente,
                      "codigoVendedor" => $jsonEntrada->codigoVendedor,
                      "codigoOperador" => $jsonEntrada->codigoOperador,
                      "valorTotal" => $jsonEntrada->valorTotal,
                      "codigoCliente" => $jsonEntrada->codigoCliente,
                      "cpfCnpjCliente" => $jsonEntrada->cpfCnpjCliente,
                      "cartaoLebes" => array(array(
                        "qtdParcelas" => $jsonEntradacartaoLebes->qtdParcelas,
                        "valorEntrada" => $jsonEntradacartaoLebes->valorEntrada,
                        "valorAcrescimo" => $jsonEntradacartaoLebes->valorAcrescimo,
                        "dataPrimeiroVencimento" => $jsonEntradacartaoLebes->dataPrimeiroVencimento,
                        "dataUltimoVencimento" => $jsonEntradacartaoLebes->dataUltimoVencimento,
                        "vendaTerceiros" => $jsonEntradacartaoLebes->vendaTerceiros,
                        "parcelas" => $jsonEntradacartaoLebes->parcelas)),
                      "produtos"  => $jsonEntrada->produtos
                          
                  ))
                )
              ));
            //  var_dump($conteudoEntrada);
    
    } else {
        $conteudoEntrada = json_encode($jsonEntrada);
        $chamadaPREVENDA = "SIM";
       // var_dump($jsonEntrada);
    }
  
       

    
  //  $conteudoEntrada=json_encode(array('clienteEntrada' => $jsonEntrada));

   //echo "ENTRADA=".$conteudoEntrada;

   $retorno = $progr->executarprogress("prestamista/1/calculaseguroprestamista",$conteudoEntrada,$dlc,$pf,$propath,$progresscfg,$tmp,$proginicial);

                fwrite($arquivo,$identificacao."-SAIDA->".$retorno."\n");

                function isJson($string) {
                           json_decode($string);
                              return json_last_error() === JSON_ERROR_NONE;
                }

                if (!isJson($retorno)) {  
                         $jsonSaida = json_decode(json_encode( array("status" => 500, 
                                    "retorno" => $retorno) 
                                    ), TRUE); 
                          fwrite($arquivo,$identificacao."-ERRO\n");
      
                }    
                fclose($arquivo);
    
    
    //echo "\nRETORNO=".$retorno ;

    if ($chamadaPREVENDA=="SIM") {
        $jsonSaida = json_decode($retorno, TRUE);
    }   else {

    
      $conteudoSaida = (object) json_decode($retorno, TRUE);
      $conteudoSaidaDados = (object) $conteudoSaida->dadosSaida;
      $conteudoSaidaParametros = (object) $conteudoSaidaDados->parametros["0"];
    //  var_dump($conteudoSaidaParametros);

      //echo "\nJSON=".$conteudoSaidaParametros->codigoSeguroPrestamista ;

    
        $jsonSaida     = array(
                      "codigoSeguroPrestamista" => $conteudoSaidaParametros->codigoSeguroPrestamista,
                      "valorTotalSeguroPrestamista"    => $conteudoSaidaParametros->valorTotalSeguroPrestamista,
                      "elegivel"    =>  $conteudoSaidaParametros->elegivel,
                      "campanhaGratis"    =>  $conteudoSaidaParametros->campanhaGratis,                      
                      "valorSeguroPrestamistaEntrada" => $conteudoSaidaParametros->valorSeguroPrestamistaEntrada,
                      "parcelas" => $conteudoSaidaParametros->parcelas
              );
      }  

    //  $jsonSaida  =  json_decode($retorno, TRUE);
