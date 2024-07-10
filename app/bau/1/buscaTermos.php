<?php
/* medico na tela 042022 - helio */

$log_datahora_ini = date("dmYHis");
$acao="buscaTermos";  
$mypid = getmypid();
$identificacao=$log_datahora_ini."-PID".$mypid."-"."$acao";
$arqlog = "/ws/log/apibau_".date("dmY").".log";
$arquivo = fopen($arqlog,"a");
fwrite($arquivo,$identificacao."-ENTRADA->".json_encode($jsonEntrada)."\n");
function isJson($string) {
      json_decode($string);
      return json_last_error() === JSON_ERROR_NONE;
}

if (isset($jsonEntrada)) {
    //$conteudoEntrada= json_encode($jsonEntrada);
    $conteudoEntrada=json_encode(array('dadosEntrada' => array(array(
        'idPagamento' => $jsonEntrada["idPagamento"])
        )));

}  else {
    $idPagamento = htmlspecialchars($parametro);

    /* traduz para o progress */
    $conteudoEntrada=json_encode(array('dadosEntrada' => array(array(
                            'idPagamento' => $idPagamento)
                            )));
    
} 

      $progr = new chamaprogress();

  $retorno = $progr->executarprogress("bau/1/buscatermos",$conteudoEntrada,$dlc,$pf,$propath,$progresscfg,$tmp,$proginicial);
  

fwrite($arquivo,$log_datahora_ini."$acao"."-SAIDA->".$retorno."\n");


  
  $conteudoSaida = (object) json_decode($retorno,true);
  $pagamento        = (object) $conteudoSaida->dadosPagamento["pagamento"][0];               

  $jsonSaida = array(
                "idPagamento" =>  $pagamento->idPagamento,
                "idPropostaLebes" =>  $pagamento->idPropostaLebes,
                "dataTransacao"  =>  $pagamento->dataTransacao,
                "codigoLoja"  =>  $pagamento->codigoLoja,
                "numeroComponente"  =>  $pagamento->numeroComponente,
                "nsuTransacao"  =>  $pagamento->nsuTransacao,
                "termos"  =>  $conteudoSaida->dadosPagamento["termos"]);
                
  if (!isJson($retorno)) {  
        $jsonSaida = json_decode(json_encode( array("status" => 500, 
                                "retorno" => $retorno) 
                                ), TRUE); 
        fwrite($arquivo,$log_datahora_ini."$acao"."-ERRO\n");
  
  } 


fclose($arquivo);


?>
