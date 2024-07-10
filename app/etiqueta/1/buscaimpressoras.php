<?php

  $progr = new chamaprogress();

  $retorno = $progr->executarprogress("etiqueta/1/buscaimpressoras",$jsonEntrada,$dlc,$pf,$propath,$progresscfg,$tmp,$proginicial);

  $jsonSaida =  json_decode($retorno, TRUE);


?>
