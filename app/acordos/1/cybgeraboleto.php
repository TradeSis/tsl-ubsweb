<?php
/* #012023 helio onda 3 */

$log_datahora_ini = date("dmYHis");
$acao = "geraboleto";
$mypid = getmypid();
$identificacao = $log_datahora_ini . "-PID" . $mypid . "-" . "$acao";
$arqlog = "/ws/log/apiacordoscyb_" . date("dmY") . ".log";
$arquivo = fopen($arqlog, "a");

fwrite($arquivo, $identificacao . "-ENTRADA->" . json_encode($jsonEntrada) . "\n");
function isJson($string)
{
    json_decode($string);
    return json_last_error() === JSON_ERROR_NONE;
}



$conteudoEntrada = json_encode($jsonEntrada);

/*    $conteudoFormatado= json_encode(array("negociacaoBoleto" => array(
"cliente" => array(array(
"codigoCliente" =>  $conteudoEntrada->codigoCliente,
"cpfCnpj" => $parametro

)),
"negociacaoSelecionada" => array(array(
"idNegociacao" => $conteudoEntrada->idNegociacao,
"idCondicao"   => $conteudoEntrada->condicaoSelecionada["idCondicao"])
)
)));
*/

$conteudoFormatado = $conteudoEntrada;
fwrite($arquivo, $identificacao . "-ENTRADAFORMATADA->" . $conteudoFormatado . "\n");


$progr = new chamaprogress();

$retorno = $progr->executarprogress("acordos/1/cybgeraboleto", $conteudoFormatado, $dlc, $pf, $propath, $progresscfg, $tmp, $proginicial);

fwrite($arquivo, $identificacao . "-SAIDA->" . $retorno . "\n");

if (!isJson($retorno)) {
    $jsonSaida = json_decode(
        json_encode(
            array(
                "status" => 500,
                "retorno" => $retorno
            )
        ), TRUE);
    fwrite($arquivo, $identificacao . "-ERRO\n");
} else {

    $conteudoSaida = json_decode($retorno, true);


    if (is_array($conteudoSaida["boleto"])) {
        $jsonSaida = array(

            "boleto" => $conteudoSaida["boleto"][0],

        );



    } else {

        $status = (object) $conteudoSaida["conteudoSaida"][0];

        $jsonSaida = json_decode(
            json_encode(
                array(
                    "status" => $status->status,
                    "retorno" => $status->descricaoStatus
                )
            ), TRUE);


    }





}


fclose($arquivo);


?>