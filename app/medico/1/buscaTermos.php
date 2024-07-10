<?php
/* medico na tela 042022 - helio */

$log_datahora_ini = date("dmYHis");
$acao="buscaTermos";  
$arqlog = "/ws/log/apimedico_"."$acao".date("dmY").".log";
$arquivo = fopen($arqlog,"a");
fwrite($arquivo,$log_datahora_ini."$acao"."-ENTRADA->".json_encode($jsonEntrada)."\n");
function isJson($string) {
      json_decode($string);
      return json_last_error() === JSON_ERROR_NONE;
}

if (isset($jsonEntrada)) {
    //$conteudoEntrada= json_encode($jsonEntrada);
    $conteudoEntrada=json_encode(array('dadosEntrada' => array(array(
        'idAdesaoLebes' => $jsonEntrada["idAdesaoLebes"])
        )));

}  else {
    $idadesao = htmlspecialchars($parametro);

    /* traduz para o progress */
    $conteudoEntrada=json_encode(array('dadosEntrada' => array(array(
                            'idAdesaoLebes' => $idadesao)
                            )));
    
} 

      $progr = new chamaprogress();

  $retorno = $progr->executarprogress("medico/1/buscatermos",$conteudoEntrada,$dlc,$pf,$propath,$progresscfg,$tmp,$proginicial);
  

fwrite($arquivo,$log_datahora_ini."$acao"."-SAIDA->".$retorno."\n");


  
  $conteudoSaida = (object) json_decode($retorno,true);
  $adesao        = (object) $conteudoSaida->dadosAdesao["adesao"][0];               

  $jsonSaida = array(
                "idAdesao" =>  $adesao->idAdesao,
                "idPropostaAdesaoLebes" =>  $adesao->idPropostaAdesaoLebes,
                "dataTransacao"  =>  $adesao->dataTransacao,
                "codigoLoja"  =>  $adesao->codigoLoja,
                "numeroComponente"  =>  $adesao->numeroComponente,
                "nsuTransacao"  =>  $adesao->nsuTransacao,
                "termos"  =>  $conteudoSaida->dadosAdesao["termos"]);
                
  if (!isJson($retorno)) {  
        $jsonSaida = json_decode(json_encode( array("status" => 500, 
                                "retorno" => $retorno) 
                                ), TRUE); 
        fwrite($arquivo,$log_datahora_ini."$acao"."-ERRO\n");
  
  } 


fclose($arquivo);


?>
