<?php
/* #082022 helio bau */

$log_datahora_ini = date("dmYHis");
$acao="efetivaPagamento";  
$mypid = getmypid();
$identificacao=$log_datahora_ini."-PID".$mypid."-"."$acao";
$arqlog = "/ws/log/apibau_".date("dmY").".log";
$arquivo = fopen($arqlog,"a");

fwrite($arquivo,$identificacao."-ENTRADA->".json_encode($jsonEntrada)."\n");
fwrite($arquivo,$identificacao."-PARAMETRO->".json_encode($parametro)."\n");
function isJson($string) {
      json_decode($string);
      return json_last_error() === JSON_ERROR_NONE;
}



    $conteudoEntrada= (object) $jsonEntrada;
   
    

    $conteudoFormatado= json_encode(array("dadosEfetivaPagamento" => array(
                                "pagamento" => array(array(
                                        "idPropostaLebes" =>  $conteudoEntrada->idPropostaLebes,
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
                                  "dadosAdicionais" => $conteudoEntrada->dadosProposta["dadosAdicionais"], 
                                  "parcelasJequiti" => $conteudoEntrada->dadosProposta["parcelasJequiti"])
                                    
                                ));




  $progr = new chamaprogress();

  $retorno = $progr->executarprogress("bau/1/efetivapagamento",$conteudoFormatado,$dlc,$pf,$propath,$progresscfg,$tmp,$proginicial);

fwrite($arquivo,$identificacao."-SAIDA->".$retorno."\n");


  
  $conteudoSaida = (object) json_decode($retorno,true);


  $jsonSaida = array(
                "idPropostaLebes" =>  $conteudoEntrada->idPropostaLebes,
                "idPagamento" =>  $conteudoSaida->PagamentoLebes[0]["idPagamento"],
                "tipoPagamento" =>  $conteudoSaida->PagamentoLebes[0]["tipoPagamento"],
                "dataTransacao"  =>  $conteudoEntrada->dataTransacao,
                "codigoLoja"  =>  $conteudoEntrada->codigoLoja,
                "numeroComponente"  =>  $conteudoEntrada->numeroComponente,
                "nsuTransacao"  =>  $conteudoEntrada->nsuTransacao,
                "dadosProposta"  =>  $conteudoEntrada->dadosProposta  );

  if (!isJson($retorno)) {  
        $jsonSaida = json_decode(json_encode( array("status" => 500, 
                                "retorno" => $retorno) 
                                ), TRUE); 
        fwrite($arquivo,$identificacao."-ERRO\n");
  
  } 


fclose($arquivo);


?>
