<?php
/* helio 072023 - Follow UP de Compras */

$log_datahora_ini = date("dmYHis");
$acao="previsaoEntrega";  
$mypid = getmypid();
$identificacao=$log_datahora_ini."-PID".$mypid."-"."$acao";
$arqlog = "/ws/log/apilojas_"."$acao".date("dmY").".log";
$arquivo = fopen($arqlog,"a");
function isJson($string) {
  json_decode($string);
  return json_last_error() === JSON_ERROR_NONE;
} 



fwrite($arquivo,$identificacao."-ENTRADA->".json_encode($jsonEntrada)."\n");
fwrite($arquivo,$identificacao."-PARAMETRO->".json_encode($parametro)."\n");
fwrite($arquivo,$identificacao."-PARAMETRO2->".json_encode($parametro2)."\n");
fwrite($arquivo,$identificacao."-HML->".json_encode($hml)."\n");

fwrite($arquivo,$identificacao."-SERVER_ADDR->".json_encode($_SERVER['SERVER_ADDR'])."\n");

if ($hml==true) {
    $service_url = 'http://172.19.130.11:5555/gateway/backoffice-loja/1.0/pedido-compra/previsa-entrega-produto/codigoProduto';
    //$service_url = 'http://172.19.130.11:5555/gateway/backoffice-loja/1.0/pedido-compra/previsa-entrega-produto/\{codigoProduto\}'; // hml
} else {    
 $service_url = 'http://172.19.130.5:5555/gateway/backoffice-loja/1.0/pedido-compra/previsa-entrega-produto/codigoProduto'; 
 }


 $service_url = str_replace('codigoProduto', $parametro2, $service_url);



fwrite($arquivo,$identificacao."-service_url->".$service_url."\n");

  $curl = curl_init($service_url);
  curl_setopt($curl, CURLOPT_CUSTOMREQUEST, "GET");
  //curl_setopt($curl, CURLOPT_POSTFIELDS, $conteudoFormatado);
  curl_setopt($curl, CURLOPT_RETURNTRANSFER, true);
  curl_setopt($curl, CURLOPT_HTTPHEADER, array(
    'Accept: application/json'
    )
  );
//   curl_setopt($curl, CURLOPT_HEADER, true);
//    curl_setopt($curl, CURLOPT_FOLLOWLOCATION, 1);
  curl_setopt($curl, CURLOPT_SSL_VERIFYPEER, false);
  $curl_response = curl_exec($curl);
  $info = curl_getinfo($curl);

  fwrite($arquivo,$identificacao."-http_code->".$info['http_code']."\n");
  fwrite($arquivo,$identificacao."-->curl_response".$curl_response."\n");

  curl_close($curl); // close cURL handler
  //var_dump($retorno);

  $conteudoBarramento = json_decode($curl_response, true);

/*
                // pega o retorno no admcom, e envia para o barramento.
                $conteudo = (object) $conteudoSaida->conteudoSaida["pedido"][0];
                $conteudoFormatado = json_encode(array("pedido" =>
                array("compCod" =>  $conteudo->compCod,
                      "tipoPedido"  =>  $conteudo->tipoPedido,
                      "dataPedido"  =>  $conteudo->dataPedido,
                      "estabOrigem"  =>  $conteudo->estabOrigem,
                      "organizacaoCompras"  =>  $conteudo->organizacaoCompras,
                      "grupoCompradores"  =>  $conteudo->grupoCompradores,
                      "observacaoPedido"  =>  $conteudo->observacaoPedido,
                       "itens" => $conteudoSaida->conteudoSaida["itens"]
                        )
                    ));
*/

    $jsonSaida = array("pedidos" => $conteudoBarramento["pedidos"]);
    
    fclose($arquivo);
            
            
?>
