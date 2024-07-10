<?php
/* #082022 helio bau */

$log_datahora_ini = date("dmYHis");
$acao="parcelasconfirmar-pagamento";  
$mypid = getmypid();
$identificacao=$log_datahora_ini."-PID".$mypid."-"."$acao";
$arqlog = "/ws/log/apiacordos_".date("dmY").".log";
$arquivo = fopen($arqlog,"a");

fwrite($arquivo,$identificacao."-ENTRADA->".json_encode($jsonEntrada)."\n");
fwrite($arquivo,$identificacao."-PARAMETRO->".json_encode($parametro)."\n");
function isJson($string) {
      json_decode($string);
      return json_last_error() === JSON_ERROR_NONE;
}



    $conteudoEntrada = (object) $jsonEntrada["cliente"];
   
    if ($conteudoEntrada->cpfCnpj<>$parametro) {
        $jsonSaida = json_decode(json_encode( array("status" => 400, 
                        "retorno" => "CPF do parametro <> CPF do JSON") 
                        ), TRUE); 
        return;
    }

   
    $parcela = array();
    $parcelas = array();

    $newArr = $jsonEntrada["cliente"];
    // var_dump($newArr);
     foreach($newArr as $indice => $valor)  {
//         echo "(0)  -- ".$indice." -> ".$valor."\n";
         foreach($valor as $indice1 => $valor1) {
//             echo "  (1)  -- ".$indice1." -> ".$valor1."\n";
             foreach($valor1 as $indice2 => $valor2) {
//                echo "      (2)contrato  -- ".$indice2." -> ".$valor2."\n";
                foreach($valor2 as $indice3 => $valor3) {
//                    echo "          (3)parcelas  -- ".$indice3." -> ".$valor3."\n";
                    $parcela["numero_contrato"] = $valor1["numero_contrato"];
                    $parcela["filial_contrato"] = $valor1["filial_contrato"];
                    $parcela["seq_parcela"] = $valor3["seq_parcela"];
                    $parcela["venc_parcela"] = $valor3["venc_parcela"];
                    $parcela["vlr_parcela"] = $valor3["vlr_parcela"];
                    $parcela["valor_encargos"] = $valor3["valor_encargos"];
                    $parcela["valor_total"] = $valor3["valor_total"];
                    array_push($parcelas,$parcela);    
//                    foreach($valor3 as $indice4 => $valor4) {
//                        echo "              (4)dadosParcelas  -- ".$indice4." -> ".$valor4."\n";
//                    }
    
                }
    
            }
   
         }
     }

    $conteudoFormatado= json_encode(array("parcelasPagamento" => array(
        "cliente" => array(array(
                "codigoCliente" =>  $conteudoEntrada->codigoCliente,
                "cpfCnpj" => $parametro,
                "formaPagamento" => $conteudoEntrada->formaPagamento
            )),
            "parcelasSelecionadas" => $parcelas)
            
        ));
        
    
    fwrite($arquivo,$identificacao."-ENTRADAFORMATADA->".$conteudoFormatado."\n");


  $progr = new chamaprogress();

  $retorno = $progr->executarprogress("acordos/1/parcelasconfirmar-pagamento",$conteudoFormatado,$dlc,$pf,$propath,$progresscfg,$tmp,$proginicial);

fwrite($arquivo,$identificacao."-SAIDA->".$retorno."\n");

  if (!isJson($retorno)) {  
    $jsonSaida = json_decode(json_encode( array("status" => 500, 
                        "retorno" => $retorno) 
                        ), TRUE); 
    fwrite($arquivo,$identificacao."-ERRO\n");
} else {

    $conteudoSaida =  json_decode($retorno,true);


    if (is_array($conteudoSaida["formaPagamento"])) {
        $clienteSaida  = array(
            "codigoCliente"=> $conteudoEntrada->codigoCliente,
            "cpfCnpj"=> $conteudoEntrada->codigoCliente,
            "formaPagamento" => $conteudoEntrada->formaPagamento,
            "contratosSelecionados" => $conteudoEntrada->contratosSelecionados,
            "transacao" => $conteudoSaida["formaPagamento"][0]
           
  
          );  
  
          $jsonSaida = array(
            "cliente" =>  $clienteSaida
          );
  
    } else {
    
    $status = (object) $conteudoSaida["conteudoSaida"][0];

    $jsonSaida = json_decode(json_encode( array("status" => $status->status, 
                            "retorno" => $status->descricaoStatus) 
                    ), TRUE); 


    }


}


fclose($arquivo);


?>
