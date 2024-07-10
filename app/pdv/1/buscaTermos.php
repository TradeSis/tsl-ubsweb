<?php
/* helio 17022022 - 263458 - Revisão da regra de novações  */
function isJson($string) {
  json_decode($string);
  return json_last_error() === JSON_ERROR_NONE;
}


$log_datahora_ini = date("dmYHis");
$acao="buscaTermos";  
$arqlog = "/ws/log/apipdv_"."$acao".date("dmY").".log";

$arquivo = fopen($arqlog,"a");


$dadosEntrada = $jsonEntrada["dadosEntrada"];

fwrite($arquivo,$log_datahora_ini."$acao"."-ENTRADA->".json_encode($jsonEntrada)."\n");


    $chamadaPREVENDA = "";

    $progr = new chamaprogress();
   
    if (!isset($dadosEntrada)) {
      
        $jsonEntrada = (object) $jsonEntrada["pedidoCartaoLebes"];
        $jsonEntradacartaoLebes = (object) $jsonEntrada->cartaoLebes;
        $jsonEntradaCliente = (object) $jsonEntrada->cliente;
        $conteudoEntrada= json_encode(
          array("dadosEntrada" => array(
                  "pedidoCartaoLebes"  =>  array(array(
                      "codigoLoja" => $jsonEntrada->codigoLoja,
                      "dataTransacao" => $jsonEntrada->dataTransacao,
                      "numeroComponente" => $jsonEntrada->numeroComponente,
                      "codigoVendedor" => $jsonEntrada->codigoVendedor,
                      "codigoOperador" => $jsonEntrada->codigoOperador,
                      "valorTotal" => $jsonEntrada->valorTotal,
                      "codigoCliente" => $jsonEntrada->codigoCliente,
                      "cpfCnpjCliente" => $jsonEntrada->cpfCnpjCliente,
                      "tipoOperacao" => $jsonEntrada->tipoOperacao,
                      "cliente" => array(array(
                        "tipoPessoa" => $jsonEntradaCliente->tipoPessoa,
                        "rg" => $jsonEntradaCliente->rg,
                        "cpf" => $jsonEntradaCliente->cpf,
                        "nome" => $jsonEntradaCliente->nome,
                        "dataNascimento" => $jsonEntradaCliente->dataNascimento,
                        "codigoCliente" => $jsonEntradaCliente->codigoCliente,
                        "cep" => $jsonEntradaCliente->endereco["cep"],
                        "logradouro" => $jsonEntradaCliente->endereco["logradouro"],
                        "numero" => $jsonEntradaCliente->endereco["numero"],
                        "complemento" => $jsonEntradaCliente->endereco["complemento"],
                        "bairro" => $jsonEntradaCliente->endereco["bairro"],
                        "cidade" => $jsonEntradaCliente->endereco["cidade"],
                        "uf" => $jsonEntradaCliente->endereco["uf"],
                        "pais" => $jsonEntradaCliente->endereco["pais"],
                        "email" => $jsonEntradaCliente->contato["email"],
                        "telefone" => $jsonEntradaCliente->contato["telefones"][0]["numero"]
                        )),

                      "cartaoLebes" => array(array(
                        "qtdParcelas" => $jsonEntradacartaoLebes->qtdParcelas,
                        "valorEntrada" => $jsonEntradacartaoLebes->valorEntrada,
                        "valorAcrescimo" => $jsonEntradacartaoLebes->valorAcrescimo,
                        "dataPrimeiroVencimento" => $jsonEntradacartaoLebes->dataPrimeiroVencimento,
                        "dataUltimoVencimento" => $jsonEntradacartaoLebes->dataUltimoVencimento,
                        "vendaTerceiros" => $jsonEntradacartaoLebes->vendaTerceiros,
                        "codigoSeguroPrestamista" => $jsonEntradacartaoLebes->codigoSeguroPrestamista,
                        "valorSeguroPrestamista" => $jsonEntradacartaoLebes->valorSeguroPrestamista,
                        "valorSeguroPrestamistaEntrada" => $jsonEntradacartaoLebes->valorSeguroPrestamistaEntrada,
                        "numeroContrato" => $jsonEntradacartaoLebes->numeroContrato,
                        "cet" => $jsonEntradacartaoLebes->cet,
                        "cetAno" => $jsonEntradacartaoLebes->cetAno,
                        "taxaMes" => $jsonEntradacartaoLebes->taxaMes,
                        "valorIof" => $jsonEntradacartaoLebes->valorIof,
                        "numeroBilheteSeguroPrestamista" => $jsonEntradacartaoLebes->numeroBilheteSeguroPrestamista,
                        "numeroSorteSeguroPrestamista" => $jsonEntradacartaoLebes->numeroSorteSeguroPrestamista,
                        "contratoFinanceira" => $jsonEntradacartaoLebes->contratoFinanceira,
                        "parcelas" => $jsonEntradacartaoLebes->parcelas)),
                      "produtos"  => $jsonEntrada->produtos
                          
                  ))
                )
              ));
          //    var_dump(json_decode($conteudoEntrada));
    
    } else {
        $conteudoEntrada = json_encode($jsonEntrada);
        $chamadaPREVENDA = "SIM";
       // var_dump($jsonEntrada);
    }
  
       

    
  //  $conteudoEntrada=json_encode(array('clienteEntrada' => $jsonEntrada));

    // echo "ENTRADA=".$conteudoEntrada;

   $retorno = $progr->executarprogress("pdv/1/buscatermos",$conteudoEntrada,$dlc,$pf,$propath,$progresscfg,$tmp,$proginicial);
    
   fwrite($arquivo,$log_datahora_ini."$acao"."-SAIDA->".$retorno."\n");
   


   $jsonSaida = json_decode($retorno,true);
      
   if (!isJson($retorno)) {  
        
        
         //json_decode(json_encode( 
         $jsonSaida = 
                                 array("status" => 500, 
                                 "erro" => "SAIDA->".substr($retorno,0,80)."\n"
         );
         //), TRUE); 
         fwrite($arquivo,$log_datahora_ini."-PID".$mypid."-"."$acao"."$acao"."-ERRO\n");
   
   } else {
          if ($chamadaPREVENDA=="SIM") {
            $jsonSaida = json_decode($retorno, TRUE);
        }   else {

        
          $conteudoSaida = json_decode($retorno, TRUE);

       
            $jsonSaida     = $conteudoSaida;
                  
        }

   }

    
    

fclose($arquivo);
