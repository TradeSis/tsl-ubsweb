<?php
/* helio 022023 insert nop crediario admcom */


$log_datahora_ini = date("dmYHis");
$acao="gera-segnum";  
$mypid = getmypid();
$identificacao=$log_datahora_ini."-PID".$mypid."-"."$acao";
$arqlog = "/ws/log/apivarejo_credito-pessoal_".date("dmY").".log";
$arquivo = fopen($arqlog,"a");
function isJson($string) {
  json_decode($string);
  return json_last_error() === JSON_ERROR_NONE;
} 

fwrite($arquivo,$identificacao."-ENTRADA->".json_encode($jsonEntrada)."\n");
fwrite($arquivo,$identificacao."-PARAMETRO_etbcod->".json_encode($parametro)."\n");
fwrite($arquivo,$identificacao."-PARAMETRO2_codigoSeguro->".json_encode($parametro2)."\n");


$progr = new chamaprogress();


  $conteudo = json_decode(json_encode($jsonEntrada["cliente"]));

  $conteudoEntrada = json_encode(
              array('dadosEntrada' => 
                    array(
                          array('etbcod' => $parametro,
                                'codigoSeguro' => $parametro2                                                       
                              )
                          )
                    )
                  );

 fwrite($arquivo,$identificacao."-ENTRADAFORMATADO->".json_encode($conteudoEntrada)."\n");

      $retorno = $progr->executarprogress("varejo/1/cpgerasegnum",$conteudoEntrada,$dlc,$pf,$propath,$progresscfg,$tmp,$proginicial);

      fwrite($arquivo,$identificacao."-SAIDA->".$retorno."\n");

        if (!isJson($retorno)) {  
            $jsonSaida = json_decode(json_encode( array("status" => 500, 
                                "retorno" => $retorno) 
                                ), TRUE); 
            fwrite($arquivo,$identificacao."-ERRO\n");
        } else {

            $conteudoSaida = (object) json_decode($retorno,true);
  

            if ($conteudoSaida->dados[0]) {
                $jsonSaida       = $conteudoSaida->dados[0];     

            } else {
    
            $status = (object) $conteudoSaida->conteudoSaida[0];
            

            $jsonSaida = json_decode(json_encode( array("status" => $status->status, 
                                    "retorno" => $status->descricaoStatus) 
                            ), TRUE); 


            }


        }

    fclose($arquivo);
            
            
?>