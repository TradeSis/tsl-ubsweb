<?php

  //  $jsonEntrada = json_decode($argv[1],true);

//    $conteudo = json_decode(json_encode($jsonEntrada["dadosEntrada"]));


    $jsonEntrada = (object) $jsonEntrada["seguro"][0];
    $idSeguro    = $jsonEntrada->idSeguro;

  /*  $conteudoFormatado= json_encode(
                            array("data" => array(
                                    "idSeguro"   => $jsonEntrada->idSeguro
                                                                      )
                                ));


   echo json_decode(json_encode($conteudoFormatado));
*/


   if ($hml==true) {
       $service_url = 'http://172.19.130.11:5555/gateway/lebesHubSegApi/1.0/gerencial/produtos/'.$idSeguro; // hml
   } else {    
    $service_url = 'http://172.19.130.175:5555/gateway/lebesHubSegApi/1.0/gerencial/produtos/'.$idSeguro; // prd era .5 mudou em 18/04/2022
    }
    
  //  echo $service_url;
    $curl = curl_init($service_url);
    curl_setopt($curl, CURLOPT_CUSTOMREQUEST, "GET");
    //curl_setopt($curl, CURLOPT_POSTFIELDS, $conteudoFormatado);
    curl_setopt($curl, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($curl, CURLOPT_HTTPHEADER, array(
      'Content-Type: application/json'
      //,'Content-Length: ' . strlen($conteudoFormatado))
    )
    );
//    curl_setopt($curl, CURLOPT_HEADER, true);
//    curl_setopt($curl, CURLOPT_FOLLOWLOCATION, 1);
    curl_setopt($curl, CURLOPT_SSL_VERIFYPEER, false);
    $curl_response = curl_exec($curl);

    $result = (object) json_decode($curl_response, true);
    $seguro = (object) $result->data;

    //var_dump($seguro->perfilTitular);

    $jsonSaida=
                              array("seguroEntrada" => array(
                                 "seguro" =>
                                  array(array(
                                      "id"    => "$seguro->id",
                                      "ativo" => $seguro->ativo,
                                      "codigo" => "$seguro->codigo",
                                      "nome" => "$seguro->nome",
                                      "tipo" => "$seguro->tipo",
                                      "categoria" => $seguro->categoria['codigo'],
                                      "provedor" => $seguro->provedor['codigo'],
                                      "PerfilTitularId" => $seguro->perfilTitular['id'],
                                      "PerfilTitularCodigo" => $seguro->perfilTitular['codigo'],
                                      "PerfilTitularAtivo" => $seguro->perfilTitular['ativo'],
                                      "coberturaValor"  => $seguro->coberturas[0]['valor']

                                    )))
                                  );


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
