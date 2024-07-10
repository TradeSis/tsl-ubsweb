<?php
/* #082022 helio bau */

$log_datahora_ini = date("dmYHis");
$acao="negociacaoboleto";  
$mypid = getmypid();
$identificacao=$log_datahora_ini."-PID".$mypid."-"."$acao";
$arqlog = "/ws/log/apiacordos_".date("dmY").".log";
$arquivo = fopen($arqlog,"a");

fwrite($arquivo,$identificacao."-ENTRADA->".json_encode($jsonEntrada)."\n");
fwrite($arquivo,$identificacao."-PARAMETRO->".json_encode($parametro)."\n");
function isJson($string) {
      json_decode($string);
      return json_last_error() === JSON_ERROR_NONE;
}



    $conteudoEntrada = (object) $jsonEntrada["cliente"];
   


    if ($conteudoEntrada->cpfCnpj<>$parametro) {
        $jsonSaida = json_decode(json_encode( array("status" => 400, 
                        "retorno" => "CPF do parametro <> CPF do JSON") 
                        ), TRUE); 
        return;
    }
    if ($conteudoEntrada->idNegociacao<>$parametro2) {
      $jsonSaida = json_decode(json_encode( array("status" => 400, 
                      "retorno" => "ID Negociacao do parametro <> ID Negociacao do JSON") 
                      ), TRUE); 
      return;
  }

    $conteudoFormatado= json_encode(array("negociacaoBoleto" => array(
        "cliente" => array(array(
                "codigoCliente" =>  $conteudoEntrada->codigoCliente,
                "cpfCnpj" => $parametro
                
            )),
        "negociacaoSelecionada" => array(array(
            "idNegociacao" => $conteudoEntrada->idNegociacao,
            "idCondicao"   => $conteudoEntrada->condicaoSelecionada["idCondicao"])
        )
        )));
        
    
    fwrite($arquivo,$identificacao."-ENTRADAFORMATADA->".$conteudoFormatado."\n");


  $progr = new chamaprogress();

  $retorno = $progr->executarprogress("acordos/1/negociacaoboleto",$conteudoFormatado,$dlc,$pf,$propath,$progresscfg,$tmp,$proginicial);

fwrite($arquivo,$identificacao."-SAIDA->".$retorno."\n");

  if (!isJson($retorno)) {  
    $jsonSaida = json_decode(json_encode( array("status" => 500, 
                        "retorno" => $retorno) 
                        ), TRUE); 
    fwrite($arquivo,$identificacao."-ERRO\n");
} else {

    $conteudoSaida =  json_decode($retorno,true);


    if (is_array($conteudoSaida["boleto"])) {
        $clienteSaida  = array(
            "codigoCliente"=> $conteudoEntrada->codigoCliente,
            "cpfCnpj"=> $conteudoEntrada->cpfCnpj,
            "idNegociacao" => $conteudoEntrada->idNegociacao,
            "condicaoSelecionada" => $conteudoEntrada->condicaoSelecionada,
            "boleto" => $conteudoSaida["boleto"][0],
  
          );  
  
          $jsonSaida = array(
            "cliente" =>  $clienteSaida
          );
  
    } else {
    
    $status = (object) $conteudoSaida["conteudoSaida"][0];

    $jsonSaida = json_decode(json_encode( array("status" => $status->status, 
                            "retorno" => $status->descricaoStatus) 
                    ), TRUE); 


    }


}


fclose($arquivo);


?>
