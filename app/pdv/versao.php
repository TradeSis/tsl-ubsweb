<?php
/*VERSAO 2 26062023*/

include "config.php";
if ($versao==""){$versao="1";}

if ($metodo=="POST"||$metodo=="GET") {

      switch ($versao) {
         case "1":
               include '1/controle.php';
               break;
         case "2":
              include '2/controle.php';
              break;
        case "3": //  Integração ID Biometria Facial 
          include '3/controle.php';
          break;
       default:
          $jsonSaida = json_decode(json_encode(
             array("status" => 400,
                 "retorno" => "Aplicacao " . $aplicacao . " Versao ".$versao." Invalida")
               ), TRUE);
            break;
          }

}  else {

    $jsonSaida = json_decode(json_encode(
        array("status" => 405,
            "retorno" => "Aplicacao " . $aplicacao . " Metodo ".$metodo." Invalido")
          ), TRUE);

  

  }
