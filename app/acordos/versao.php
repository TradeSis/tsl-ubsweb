<?php
/* helio 082022 - Acordo Online  */

include "config.php";

if ($versao==""){$versao="1";}

if ($metodo=="POST"||$metodo=="GET"||$metodo=="PUT") {

      switch ($versao) {
         case "1":
               include '1/controle.php';
               break;
         default:
          $jsonSaida = json_decode(json_encode(
             array("status" => 400,
                 "retorno" => "Aplicacao " . $aplicacao . " Versao ".$versao." Invalida - (versao.17)")
               ), TRUE);
            break;
          }

}  else {

    $jsonSaida = json_decode(json_encode(
        array("status" => 400,
            "retorno" => "Aplicacao " . $aplicacao . " Metodo ".$metodo." Invalido (versao.26)")
          ), TRUE);

  

  }
