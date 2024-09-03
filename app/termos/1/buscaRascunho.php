<?php
// PROGRESS


$log_datahora_ini = date("dmYHis");
$acao="buscaRascunho";  
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
            "rascunho" => "RASCUNHO", // CHAMARA O MESMO PROGRAMA PROGRESS BUSCA TERMOS - AQUI INDICA QUE É PARA PEGAR O CAMPO RASCUNHO
            "formatoTermo" => isset($jsonEntrada->formatoTermo) ? $jsonEntrada->formatoTermo : null,
            "tipoOperacao" => isset($jsonEntrada->tipoOperacao) ? $jsonEntrada->tipoOperacao : null,
            "codigoLoja" => isset($jsonEntrada->codigoLoja) ? $jsonEntrada->codigoLoja : null,
            "numeroComponente" => isset($jsonEntrada->numeroComponente) ? $jsonEntrada->numeroComponente : null,
            "numeroNotaFiscal" => isset($jsonEntrada->numeroNotaFiscal) ? $jsonEntrada->numeroNotaFiscal : null,
            "dataTransacao" => isset($jsonEntrada->dataTransacao) ? $jsonEntrada->dataTransacao : null,
            "codigoCliente" => isset($jsonEntrada->codigoCliente) ? $jsonEntrada->codigoCliente : null,
            "idBiometria" => isset($jsonEntrada->idBiometria) ? $jsonEntrada->idBiometria : null,
            "neuroIdOperacao" => isset($jsonEntrada->neuroIdOperacao) ? $jsonEntrada->neuroIdOperacao : null,
            "codigoProdutoFinanceiro" => isset($jsonEntrada->codigoProdutoFinanceiro) ? $jsonEntrada->codigoProdutoFinanceiro : null,
            "valorEmprestimo" => isset($jsonEntrada->valorEmprestimo) ? $jsonEntrada->valorEmprestimo : null,
            "codigoVendedor" => isset($jsonEntrada->codigoVendedor) ? $jsonEntrada->codigoVendedor : null,
            "codigoOperador" => isset($jsonEntrada->codigoOperador) ? $jsonEntrada->codigoOperador : null,
            "valorTotal" => isset($jsonEntrada->valorTotal) ? $jsonEntrada->valorTotal : null,
            "recebimentos" => isset($jsonEntrada->recebimentos) ? $jsonEntrada->recebimentos : array(),
            "cartaoLebes" => array(
              array(
                    "seqForma" => isset($jsonEntradaCartaoLebes->seqForma) ? $jsonEntradaCartaoLebes->seqForma : null,
                    "numeroContrato" => isset($jsonEntradaCartaoLebes->numeroContrato) ? $jsonEntradaCartaoLebes->numeroContrato : null,
                    "contratoFinanceira" => isset($jsonEntradaCartaoLebes->contratoFinanceira) ? $jsonEntradaCartaoLebes->contratoFinanceira : null,
                    "cet" => isset($jsonEntradaCartaoLebes->cet) ? $jsonEntradaCartaoLebes->cet : null,
                    "cetAno" => isset($jsonEntradaCartaoLebes->cetAno) ? $jsonEntradaCartaoLebes->cetAno : null,
                    "taxaMes" => isset($jsonEntradaCartaoLebes->taxaMes) ? $jsonEntradaCartaoLebes->taxaMes : null,
                    "valorIof" => isset($jsonEntradaCartaoLebes->valorIof) ? $jsonEntradaCartaoLebes->valorIof : null,
                    "qtdParcelas" => isset($jsonEntradaCartaoLebes->qtdParcelas) ? $jsonEntradaCartaoLebes->qtdParcelas : null,
                    "valorTFC" => isset($jsonEntradaCartaoLebes->valorTFC) ? $jsonEntradaCartaoLebes->valorTFC : null,
                    "valorAcrescimo" => isset($jsonEntradaCartaoLebes->valorAcrescimo) ? $jsonEntradaCartaoLebes->valorAcrescimo : null,
                    "parcelas" => isset($jsonEntradaCartaoLebes->parcelas) ? $jsonEntradaCartaoLebes->parcelas : array(),
                    "seguroPrestamista" => isset($jsonEntradaCartaoLebes->seguroPrestamista) ? array($jsonEntradaCartaoLebes->seguroPrestamista) : array()
              )
            ),
            "contratosRenegociados" => isset($jsonEntrada->contratosRenegociados) ? $jsonEntrada->contratosRenegociados : array(),
            "produtos" => isset($jsonEntrada->produtos) ? $jsonEntrada->produtos : array()
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
// CHAMARA O MESMO PROGRAMA PROGRESS BUSCA TERMOS
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