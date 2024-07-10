<?php
/* medico na tela 042022 - helio */

$log_datahora_ini = date("dmYHis");
$acao="enviaProposta";  
$arqlog = "/ws/log/apimedico_"."$acao".date("dmY").".log";
$arquivo = fopen($arqlog,"a");
fwrite($arquivo,$log_datahora_ini."$acao"."-ENTRADA->".json_encode($jsonEntrada)."\n");
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
                                   "dadosAdicionais" => $jsonEntrada["dadosProposta"]["dadosAdicionais"]

                                    )
                                ));

  $retorno = $conteudoFormatado;
 

  


   if ($hml==true) {
       $service_url = 'http://172.19.130.11:5555/gateway/LbServicoGenericoAPI/1.0/propostas'; // hml
   } else {    
    $service_url = 'http://172.19.130.175:5555/gateway/LbServicoGenericoAPI/1.0/propostas'; // prd era .5 mudou em 18/04/2022
    }
     
  //  echo $service_url;
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

    curl_close($curl); // close cURL handler


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

  fwrite($arquivo,$log_datahora_ini."$acao"."-SAIDA->".$retorno."\n");

     
   
fclose($arquivo);
