<?php

  //  $jsonEntrada = json_decode($argv[1],true);

//    $conteudo = json_decode(json_encode($jsonEntrada["dadosEntrada"]));


    $jsonEntrada = (object) $jsonEntrada["perfil"][0];
    $idPerfil    = $jsonEntrada->idPerfil;

  /*  $conteudoFormatado= json_encode(
                            array("data" => array(
                                    "idSeguro"   => $jsonEntrada->idSeguro
                                                                      )
                                ));


   echo json_decode(json_encode($conteudoFormatado));
*/


   if ($hml==true) {
       $service_url = 'http://172.19.130.11:5555/gateway/lebesHubSegApi/1.0/coleta/perfis/'.$idPerfil; // hml
   } else {    
    $service_url = 'http://172.19.130.175:5555/gateway/lebesHubSegApi/1.0/coleta/perfis/'.$idPerfil; // prd era .5 mudou em 18/04/2022
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

    //var_dump($seguro->grupos[0]['campos']);
    $campos = array();
    foreach($seguro->grupos[0]['campos'] as $key => $item){
        //  echo $key . "-" . json_decode(json_encode($item[$key])) . "\n";
        //  var_dump($item);

          $campo = array();
          foreach($item as $nome => $valor){
          //  echo "__1__ ".$nome . "-" . $valor . "\n";
            //  $novo = array($);
           if ($nome<>"dependentes"){
              if (is_array($valor)) {
                  $atributos = array();

                   //var_dump($valor);
                  //var_dump($atributo);

                  foreach($valor as $nome2 => $valor2){
                    //echo "____2__ ".$nome2 . "-" . $valor2 . "\n";
                    $atributo = array();
                    foreach($valor2 as $nome3 => $valor3){
                      //echo "______3__ ".$nome3 . "-" . $valor3 . "\n";
                      if ($nome3<>"perfil"){
                        $atributo[$nome3] = $valor3;
                      }
                    }
                    $atributo['idPai'] = $item['id'];
                    array_push($atributos,$atributo);
                 }
                  $campo['idPai'] = $seguro->id;
                  $campo[$nome]   = $atributos;

              } else{
                  if ($nome=="opcoes"){
                      $atributos = array();
                      $atributo = array();
                      $atributo['id'] = 0;
                      $atributo['nome'] = '';
                      $atributo['valor'] = '';
                      $atributo['ativo'] = false;
                      $atributo['idPai'] = 0;
                      array_push($atributos,$atributo);
                      
                      $campo['idPai'] = $seguro->id;
                      $campo[$nome]   = $atributos;
                  } else {
                    $campo[$nome] = $valor;
                  }
              }
            } // sem atributos
              //array_push($campo, arra($nome => $valor));
          }
          array_push($campos, $campo);
        }

    $jsonSaida=
                              array("perfilEntrada" => array(
                                 "perfil" =>
                                  array(array(
                                      "id"    => $seguro->id,
                                      "ativo" => $seguro->ativo,
                                      "codigo" => "$seguro->codigo" ,
                                      "campos" => $campos
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
