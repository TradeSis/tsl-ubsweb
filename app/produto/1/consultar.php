<?php

$progr = new chamaprogress();

$produto = htmlspecialchars($parametro);

/* traduz para o progress */
$conteudoEntrada=json_encode(array('produtos' => array(array(
                        'produto' => $produto)
                        )));


  if(isset($parametro)){
      $retorno = $progr->executarprogress("produto/1/consultar",$conteudoEntrada,$dlc,$pf,$propath,$progresscfg,$tmp,$proginicial);
      $jsonSaida =  json_decode($retorno, TRUE);
    //  echo $retorno ;


    

      if ($jsonSaida) {


      } else {
        echo "\nERRO ".$retorno."\n";
      }

}
