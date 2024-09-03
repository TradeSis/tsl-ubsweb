<?php
// PROGRESS

$log_datahora_ini = date("dmYHis");
$acao="buscaTermos";  
$arqlog = "/ws/log/apitermos_"."$acao".date("dmY").".log";

$arquivo = fopen($arqlog,"a");

fwrite($arquivo,$log_datahora_ini."$acao"."-ENTRADA->".json_encode($jsonEntrada)."\n");

$termos = array();

if (isset($jsonEntrada["dadosEntrada"][0])) {
  $dadosEntrada = $jsonEntrada["dadosEntrada"];

}

$chamadaPREVENDA = "";

$progr = new chamaprogress();

if (!isset($jsonEntrada["dadosEntrada"])) {
  $jsonEntrada = (object) $jsonEntrada;
  $jsonEntradaCartaoLebes = isset($jsonEntrada->cartaoLebes[0]) ? (object) $jsonEntrada->cartaoLebes[0] : null;
  
  $conteudoEntrada = json_encode(
    array(
      "dadosEntrada" => array(
        "pedidoCartaoLebes" => array(
          array(
            "formatoTermo" => $jsonEntrada->formatoTermo ?? null,
            "tipoOperacao" => $jsonEntrada->tipoOperacao ?? null,
            "codigoLoja" => $jsonEntrada->codigoLoja ?? null,
            "numeroComponente" => $jsonEntrada->numeroComponente ?? null,
            "numeroNotaFiscal" => $jsonEntrada->numeroNotaFiscal ?? null,
            "dataTransacao" => $jsonEntrada->dataTransacao ?? null,
            "codigoCliente" => $jsonEntrada->codigoCliente ?? null,
            "idBiometria" => $jsonEntrada->idBiometria ?? null,
            "neuroIdOperacao" => $jsonEntrada->neuroIdOperacao ?? null,
            "codigoProdutoFinanceiro" => $jsonEntrada->codigoProdutoFinanceiro ?? null,
            "valorEmprestimo" => $jsonEntrada->valorEmprestimo ?? null,
            "codigoVendedor" => $jsonEntrada->codigoVendedor ?? null,
            "codigoOperador" => $jsonEntrada->codigoOperador ?? null,
            "valorTotal" => $jsonEntrada->valorTotal ?? null,
            "recebimentos" => $jsonEntrada->recebimentos ?? [],
            "cartaoLebes" => array(
              array(
                "seqForma" => $jsonEntradaCartaoLebes->seqForma ?? null,
                "numeroContrato" => $jsonEntradaCartaoLebes->numeroContrato ?? null,
                "contratoFinanceira" => $jsonEntradaCartaoLebes->contratoFinanceira ?? null,
                "cet" => $jsonEntradaCartaoLebes->cet ?? null,
                "cetAno" => $jsonEntradaCartaoLebes->cetAno ?? null,
                "taxaMes" => $jsonEntradaCartaoLebes->taxaMes ?? null,
                "valorIof" => $jsonEntradaCartaoLebes->valorIof ?? null,
                "qtdParcelas" => $jsonEntradaCartaoLebes->qtdParcelas ?? null,
                "valorTFC" => $jsonEntradaCartaoLebes->valorTFC ?? null,
                "valorAcrescimo" => $jsonEntradaCartaoLebes->valorAcrescimo ?? null,
                "parcelas" => $jsonEntradaCartaoLebes->parcelas ?? [],
                "seguroPrestamista" => array($jsonEntradaCartaoLebes->seguroPrestamista) ?? []
              )
            ),
            "contratosRenegociados" => $jsonEntrada->contratosRenegociados ?? [],
            "produtos" => $jsonEntrada->produtos ?? []
          )
        )
      )
    )
  );

  // var_dump(json_decode($conteudoEntrada));
} else {
  $conteudoEntrada = json_encode($jsonEntrada);
  $chamadaPREVENDA = "SIM";
  // var_dump($jsonEntrada);
}

fwrite($arquivo,$log_datahora_ini."$acao"."-FORMATADO->".$conteudoEntrada."\n");
$retorno = $progr->executarprogress("termos/1/buscatermos", $conteudoEntrada);
fwrite($arquivo,$log_datahora_ini."$acao"."-RETORNO->".$retorno."\n");
$termos = json_decode($retorno, true);
if (isset($termos["conteudoSaida"][0])) { // Conteudo Saida - Caso de erro
  $termos = $termos["conteudoSaida"][0];
} else {

  $termos = $termos["termos"];

}


$jsonSaida = $termos;


fclose($arquivo);

?>