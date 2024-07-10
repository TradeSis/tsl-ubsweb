<?php

  //  $jsonEntrada = json_decode($argv[1],true);

//    $conteudo = json_decode(json_encode($jsonEntrada["dadosEntrada"]));

  //echo $jsonEntrada;


    $jsonEntrada = (object) $jsonEntrada["adesaoEntrada"]["adesao"][0];

    $conteudoFormatado= json_encode(
                            array("codigoLoja" =>  $jsonEntrada->codigoLoja,
                                  "dataTransacao"  =>  $jsonEntrada->dataTransacao,
                                   "_generatedInput" => array(
                                          "canal"   => $jsonEntrada->canal,
                                          "produto"   => $jsonEntrada->produto,
                                          "modalidade" => $jsonEntrada->modalidade,
                                          "idReferenciaCliente"  => $jsonEntrada->idReferenciaCliente,
                                          "respostas" => $jsonEntrada->respostas

                                    )
                                ));

   //echo json_decode(json_encode($conteudoFormatado));
  
   if ($hml==true) {
       $service_url = 'http://172.19.130.11:5555/gateway/lebesHubSegApi/1.0/adesao/propostas-lebes'; // hml
   } else {    
    $service_url = 'http://172.19.130.175:5555/gateway/lebesHubSegApi/1.0/adesao/propostas-lebes'; // prd era .5 mudou em 18/04/2022
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
    //echo $curl_response;

     $result = (object) json_decode($curl_response, true);
     $adesao = (object) $result->data;
    //  var_dump($adesao);

    //$
//    var_dump($seguro);

    $jsonSaida=      array(
                                 "adesao" =>
                                  array(array(
                                      "idPropostaAdesaoLebes"    => "$adesao->idPropostaAdesaoLebes"
                                    )));


    //echo json_decode(json_encode($conteudoFormatado));


    $info = curl_getinfo($curl);

    curl_close($curl); // close cURL handler

/*
    if ($info['http_code']==200) {
      $jsonSaida     = array(
              "return"   => array(array(
                    "status" => "REGISTRADO",
                    "linhaDigitavel" => $result["boleto"]["linhaDigitavel"],
                    "codigoBarras"    => $result["boleto"]["codigoBarras"],
                    "DVNossoNumero"    =>  ""))
            );
    } else {
            $jsonSaida     = array(
                    "return"   => array(array(
                          "status" => "ERRO=".$info['http_code']))
                  );

    }
*/

    //echo json_decode(json_encode($jsonSaida))

    //echo $conteudoFormatado;
