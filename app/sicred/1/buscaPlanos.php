<?php
$log_datahora_ini = date("dmYHis");
$acao = "buscaPlanos";
$arqlog = "/ws/log/apisicred_" . "$acao" . date("dmY") . ".log";
$arquivo = fopen($arqlog, "a");
fwrite($arquivo, $log_datahora_ini . "$acao" . "-PARAMERRO->" . $parametro . "\n");
fwrite($arquivo, $log_datahora_ini . "$acao" . "-ENTRADA->" . json_encode($jsonEntrada) . "\n");

$username = "ADMCOM";
$password = "LL908521";

$novo_token = "sim";
if (isset($parametro)) {
    $access_token = $parametro;
    $novo_token = "nao";
}

fwrite($arquivo, $log_datahora_ini . "$acao" . "-NOVO_TOKEN->" . $novo_token. "\n");

if ($novo_token == "sim") {

    if ($hml == true) {
        $service_url = 'http://lebes-hml.k8s.lebes.com.br/auth/connect/token';
        $client_secret = "5fb7c802-9b5a-46a8-b022-cec03327a7e9";
    } else {
        $service_url = 'http://lebes-prod.k8s.lebes.com.br/auth/connect/token';
        $client_secret = "a055aee8-94a0-4f60-8568-0b2e5f8161fb";

    }

    $curl = curl_init($service_url);
    curl_setopt($curl, CURLOPT_POST, TRUE);
    curl_setopt($curl, CURLOPT_RETURNTRANSFER, true);

    curl_setopt($curl, CURLOPT_HTTPHEADER, array('Content-Type: application/x-www-form-urlencoded'));
    $fields = "grant_type=password&username=" . $username . "&password=" . $password;
    $fields .= "&scope=sicred.usuario&client_id=sicred-client";
    $fields .= "&client_secret=" . $client_secret; //5fb7c802-9b5a-46a8-b022-cec03327a7e9"; NOVO CLIENTE SECRED 04032022
    curl_setopt($curl, CURLOPT_POSTFIELDS, $fields);

    $data = curl_exec($curl);
    $info = curl_getinfo($curl);

    curl_close($curl);
    fwrite($arquivo, $log_datahora_ini . "$acao" . "-token->" . json_encode($jdata) . "\n");

    $data_obj = json_decode($data);
    $access_token = $data_obj->{"access_token"};
    $expires_in = $data_obj->{"expires_in"};

}
//echo "\n". $access_token."\n";
fwrite($arquivo, $log_datahora_ini . "$acao" . "-sccess_token->" . json_encode($access_token) . "\n");


if ($hml == true) {
    $service_url = 'http://lebes-hml.k8s.lebes.com.br/planos/Planos/01/000001';
} else {
    $service_url = 'http://lebes-prod.k8s.lebes.com.br/planos/Planos/01/000001';

}

$host = parse_url($service_url);
//var_dump($host);

//fwrite($arquivo, $log_datahora_ini . "$acao" . "-FORMATADO->" . $conteudoFormatado . "\n");

$headers = array(
    "Content-Type: application/json",
    "Authorization: Bearer $access_token",
    "Host: " . $host['host'] /*,
       "Content-Length: " . strlen($conteudoFormatado) */
);

$payload = json_encode($post_params);


$curl = curl_init($service_url);
//curl_setopt($curl, CURLOPT_POSTFIELDS, $conteudoFormatado);
curl_setopt($curl, CURLOPT_RETURNTRANSFER, true);
curl_setopt($curl, CURLOPT_HTTPHEADER, $headers);
$curl_response = curl_exec($curl);
fwrite($arquivo, $log_datahora_ini . "$acao" . "-RESPONSE->" . $curl_response . "\n");

$info = curl_getinfo($curl);

if (curl_errno($curl)) {
    $error_msg = curl_error($curl);
}
curl_close($curl); // close cURL handler

$retorno = json_decode($curl_response, true);
fwrite($arquivo, $log_datahora_ini . "$acao" . "-RETORNO->" . json_encode($retorno) . "\n");

// var_dump($retorno);
// echo $info['http_code'];

if ($info['http_code'] == 200) {

    $newArr = json_decode($curl_response, true);

    foreach ($newArr as $indice => $valor) {
        //  echo "(0)  -- ".$indice." -> ".$valor."\n";

        $arrayProduto = array();
        $produtook = "";
        if ($valor["produtos"]) {

            foreach ($valor["produtos"] as $indice1 => $valor1) {
                //echo "  (1)  -- ".$indice1." -> ".$valor1."\n";
                if ($valor1 == 2 || $valor1 == 5 || $valor1 == 19 || $valor1 == 20
                  ||$valor1 == 7 || $valor1 == 8 || $valor1 == 11 || $valor1 == 12) {
                    $arrayProduto[] = array(
                        "codigoPlano" => $valor["codigo"],
                        "codigoProduto" => $valor1
                    ); 
                    $produtook = "OK";
                }
            }
        }


        $arrayPrazo = array();
        if ($valor["prazos"]) {

            foreach ($valor["prazos"] as $indice1 => $valor1) {
                //  echo "  (1)  -- ".$indice1." -> ".$valor1."\n";
                $prazo = array(
                    "codigoPlano" => $valor["codigo"],
                    "prazo" => $valor1["prazo"],
                    "taxa" => $valor1["taxa"]
                );
            }
            $arrayPrazo[] = $prazo;
        }
        if ($produtook == "OK") {
            $arraytr[] = array(
                "codigoPlano" => $valor["codigo"],
                "descricao" => $valor["descricao"],
             //   "produtos" => $arrayProduto,
             //   "prazos" => $arrayPrazo,
                "prazo" => $arrayPrazo[0]["prazo"],
                "taxa" => $arrayPrazo[0]["taxa"]
            );
        }

    }




    if ($novo_token == "sim") {
        $jsonSaida = array(
            "retorno" => array(
                "token" => array(
                    array(
                        "username" => $username,
                        "access_token" => $access_token,
                        "expires_in" => $expires_in
                    )
                ),
                "planos" => $arraytr
            )
        );


    } else {
        $jsonSaida = array("retorno" => array("planos" => $arraytr));


    }


} else {
    $jsonSaida = json_decode(
        json_encode(
            array(
                "status" => $info['http_code'],
                "erro" => $retorno
            )
        ),
        TRUE
    );
}

fclose($arquivo);


?>