<?php
/* medico na tela 042022 - helio */

$log_datahora_ini = date("dmYHis");
$acao="efetivaAdesao";  
$arqlog = "/ws/log/apimedico_"."$acao".date("dmY").".log";
$arquivo = fopen($arqlog,"a");
fwrite($arquivo,$log_datahora_ini."$acao"."-ENTRADA->".json_encode($jsonEntrada)."\n");
function isJson($string) {
      json_decode($string);
      return json_last_error() === JSON_ERROR_NONE;
}


    $conteudoEntrada= (object) $jsonEntrada;
   
    

    $conteudoFormatado= json_encode(array("dadosAdesao" => array(
                                "adesao" => array(array(
                                        "idPropostaAdesaoLebes" =>  $conteudoEntrada->idPropostaAdesaoLebes,
                                        "dataTransacao"  =>  $conteudoEntrada->dataTransacao,
                                        "codigoLoja"  =>  $conteudoEntrada->codigoLoja,
                                        "numeroComponente"  =>  $conteudoEntrada->numeroComponente,
                                        "nsuTransacao"  =>  $conteudoEntrada->nsuTransacao,
                                        "dataProposta"  =>  $conteudoEntrada->dadosProposta["dataProposta"],
                                        "tipoServico"  =>  $conteudoEntrada->dadosProposta["tipoServico"],
                                        "valorServico"  =>  $conteudoEntrada->dadosProposta["valorServico"],
                                        "codigoProdutoLebes"  =>  $conteudoEntrada->dadosProposta["codigoProdutoLebes"],
                                        "codigoProdutoExterno"  =>  $conteudoEntrada->dadosProposta["codigoProdutoExterno"]
                                    )),
                                  "dadosAdicionais" => $conteudoEntrada->dadosProposta["dadosAdicionais"])
                                    
                                ));




  $progr = new chamaprogress();

  $retorno = $progr->executarprogress("medico/1/efetivaadesao",$conteudoFormatado,$dlc,$pf,$propath,$progresscfg,$tmp,$proginicial);

fwrite($arquivo,$log_datahora_ini."$acao"."-SAIDA->".$retorno."\n");


  
  $conteudoSaida = (object) json_decode($retorno,true);


  $jsonSaida = array(
                "idPropostaAdesaoLebes" =>  $conteudoEntrada->idPropostaAdesaoLebes,
                "idAdesaoLebes" =>  $conteudoSaida->adesaoLebes[0]["idAdesao"],
                "dataTransacao"  =>  $conteudoEntrada->dataTransacao,
                "codigoLoja"  =>  $conteudoEntrada->codigoLoja,
                "numeroComponente"  =>  $conteudoEntrada->numeroComponente,
                "nsuTransacao"  =>  $conteudoEntrada->nsuTransacao,
                "dadosProposta"  =>  $conteudoEntrada->dadosProposta  );

  if (!isJson($retorno)) {  
        $jsonSaida = json_decode(json_encode( array("status" => 500, 
                                "retorno" => $retorno) 
                                ), TRUE); 
        fwrite($arquivo,$log_datahora_ini."$acao"."-ERRO\n");
  
  } 


fclose($arquivo);


?>
