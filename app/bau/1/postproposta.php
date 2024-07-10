<?php
/* bau 092022 - helio */

$log_datahora_ini = date("dmYHis");
$acao="postProposta";  
$mypid = getmypid();
$identificacao=$log_datahora_ini."-PID".$mypid."-"."$acao";
$arqlog = "/ws/log/apibau_".date("dmY").".log";
$arquivo = fopen($arqlog,"a");

fwrite($arquivo,$identificacao."-ENTRADA->".json_encode($jsonEntrada)."\n");
function isJson($string) {
      json_decode($string);
      return json_last_error() === JSON_ERROR_NONE;
}
//var_dump($jsonEntrada);

    $conteudoEntrada = (object) $jsonEntrada["dadosProposta"]["proposta"][0];


    $conteudoFormatado= json_encode(array("dadosProposta" =>
                            array("codigoLoja" =>  $conteudoEntrada->codigoLoja,
                                  "dataProposta"  =>  $conteudoEntrada->dataProposta,
                                  "tipoServico"  =>  $conteudoEntrada->tipoServico,
                                  "valorServico"  =>  $conteudoEntrada->valorServico,
                                  "codigoProdutoLebes"  =>  $conteudoEntrada->codigoProdutoLebes,
                                  "codigoProdutoExterno"  =>  $conteudoEntrada->codigoProdutoExterno,
                                   "dadosAdicionais" => $jsonEntrada["dadosProposta"]["dadosAdicionais"],
                                   "parcelasJequiti" => $jsonEntrada["dadosProposta"]["parcelasJequiti"]
                                    )
                                ));

  $retorno = $conteudoFormatado;
 

  


   if ($hml==true) {
       $service_url = 'http://172.19.130.11:5555/gateway/lebes-jequiti-api/1.0/pagto-jequiti'; // hml
   } else {    
    $service_url = 'http://172.19.130.175:5555/gateway/lebes-jequiti-api/1.0/pagto-jequiti'; // prd era .5 mudou em 18/04/2022
    }
     
  //  echo $service_url;
  
  fwrite($arquivo,$identificacao."-service_url->".$service_url."\n");
  fwrite($arquivo,$identificacao."-ENTRADA->".$conteudoFormatado."\n");

    $curl = curl_init($service_url);
    curl_setopt($curl, CURLOPT_CUSTOMREQUEST, "POST");
    curl_setopt($curl, CURLOPT_POSTFIELDS, $conteudoFormatado);
    curl_setopt($curl, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($curl, CURLOPT_HTTPHEADER, array(
      'Content-Type: application/json'
      ,'Content-Length: ' . strlen($conteudoFormatado))
    );
//    curl_setopt($curl, CURLOPT_HEADER, true);
//    curl_setopt($curl, CURLOPT_FOLLOWLOCATION, 1);
    curl_setopt($curl, CURLOPT_SSL_VERIFYPEER, false);
    $curl_response = curl_exec($curl);
    $retorno = $curl_response;
    $info = curl_getinfo($curl);

    fwrite($arquivo,$identificacao."-http_code->".$info['http_code']."\n");
    fwrite($arquivo,$identificacao."-->curl_response".$curl_response."\n");

    curl_close($curl); // close cURL handler
    //var_dump($retorno);


//    $retorno = '{"idPropostaLebes": "GEN_12", "dadosProposta": {}}';    

     $result = (object) json_decode($retorno, true);
     

     $idPropostaLebes = $result->idPropostaLebes;
     

     if ($info['http_code']==200) {
          $jsonSaida=      array(
                                 "propostaLebes" =>
                                  array(array(
                                      "idPropostaLebes"    => "$idPropostaLebes"
                                    )));
     } else {
      $jsonSaida=   array(
        "erro" =>
         array(array(
             "mensagem"    => "$mensagem"
           )));
     }

  fwrite($arquivo,$identificacao."-SAIDA->".$retorno."\n");

     
   
fclose($arquivo);
