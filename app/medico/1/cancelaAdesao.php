<?php
/* medico na tela 042022 - helio */

$log_datahora_ini = date("dmYHis");
$acao="cancelaAdesao";  
$arqlog = "/ws/log/apimedico_"."$acao".date("dmY").".log";
$arquivo = fopen($arqlog,"a");
fwrite($arquivo,$log_datahora_ini."$acao"."-ENTRADA->".json_encode($jsonEntrada)."\n");
function isJson($string) {
      json_decode($string);
      return json_last_error() === JSON_ERROR_NONE;
}

    $conteudoAdesao     = $jsonEntrada["cancelaAdesao"]["adesao"][0];
    $conteudoAdicionais = $jsonEntrada["cancelaAdesao"]["dadosAdicionais"];
       
    $conteudoFormatado = json_encode(array(
            "adesaoCancelada" => array(
                "idAdesaoLebes" =>  $conteudoAdesao["idAdesaoLebes"],
                "idPropostaAdesaoLebes" =>  $conteudoAdesao["idPropostaAdesaoLebes"],
                "dataTransacao"  =>  $conteudoAdesao["dataTransacao"],
                "codigoLoja"  =>  $conteudoAdesao["codigoLoja"],
                "numeroComponente"  =>  $conteudoAdesao["numeroComponente"],
                "nsuTransacao"  =>  $conteudoAdesao["nsuTransacao"],
                "dadosProposta" => array(
                        "codigoLoja"  =>  $conteudoAdesao["codigoLoja"],
                        "dataProposta"  =>  $conteudoAdesao["dataProposta"],
                        "tipoServico"  =>  $conteudoAdesao["tipoServico"],
                        "valorServico"  =>  $conteudoAdesao["valorServico"],
                        "codigoProdutoLebes"  =>  $conteudoAdesao["codigoProdutoLebes"],
                        "codigoProdutoExterno"  =>  $conteudoAdesao["codigoProdutoExterno"],
                        "dadosAdicionais" => $conteudoAdicionais 
                            )
                    
             )
            ));


$retorno = $conteudoFormatado;

fwrite($arquivo,$log_datahora_ini."$acao"."-FORMATADO->".$conteudoFormatado."\n");

fwrite($arquivo,$log_datahora_ini."$acao"."-HML->".$hml."\n");

if ($hml==true) {
    $service_url = 'http://172.19.130.11:5555/gateway/LbServicoGenericoAPI/1.0/adesoes/cancelar-adesao'; // hml
} else {    
 $service_url = 'http://172.19.130.175:5555/gateway/LbServicoGenericoAPI/1.0/adesoes/cancelar-adesao'; // prd era .5 mudou em 18/04/2022
 }

 fwrite($arquivo,$log_datahora_ini."$acao"."-service_url->".$service_url."\n");

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
 fwrite($arquivo,$log_datahora_ini."$acao"."-http_code->".$info['http_code']."\n");
  

 curl_close($curl); // close cURL handler

//  $retorno = '{"cancelamentoAdesao":[{"cancelamentoParceirosStatus":[{"codigoParceiro":"SOMAR","statusParceiro":"200","mensagemParceiro":"Sucesso: true, Mensagem: Cancelamento feito    com sucesso x."},{"codigoParceiro":"DOC24","statusParceiro":"200","mensagemParceiro":"estado: 1, mensaje: OK"}]}]}';    

  fwrite($arquivo,$log_datahora_ini."$acao"."-curl_response->".$retorno."\n");
 
  $result = /*(object)*/ json_decode($retorno, true);
 // var_dump($result)  ;
  $cancelamentoParceirosStatus = $result["cancelamentoParceirosStatus"];
  

  if ($info['http_code']==200) {
       $jsonSaida=      array("cancelamentoParceirosStatus"    => $cancelamentoParceirosStatus);
  } else {
    //  var_dump($cancelamentoParceirosStatus);
      $retorno = '{"cancelamentoAdesao":[{"cancelamentoParceirosStatus":[{"codigoParceiro":"'.$cancelamentoParceirosStatus[0]['codigoParceiro'].'","statusParceiro":"'.$info['http_code'].'","mensagemParceiro":"'.$cancelamentoParceirosStatus[0]['mensagemParceiro'].'"}]}]}';    
      $result = /*(object)*/ json_decode($retorno, true);
      $cancelamentoParceirosStatus = $result["cancelamentoAdesao"][0]["cancelamentoParceirosStatus"];
    $jsonSaida=      array("cancelamentoParceirosStatus"    => $cancelamentoParceirosStatus );

 }


  fwrite($arquivo,$log_datahora_ini."$acao"."-jsonSaida->".json_encode( $jsonSaida)."\n");
 
fclose($arquivo);


?>
