<?php

        /**
         */
        //include "/u/bsweb/progr/php/progress_03.php";

        class neurotech extends progress
        {
                var $ws = "neurotech"; // Letra Minuscula por causa do progress

                function executarprogress($acao,$novaentrada)
                {
                        $pegar_ip = $_SERVER["REMOTE_ADDR"];
						
			$arqlog = "/u/bsweb/log/ajneuro_".date("dmY").".log";
                        $arquivo = fopen($arqlog,"a");
                        fwrite($arquivo,date("H:i:s")." IP=".$pegar_ip."\n");
                        fwrite($arquivo,date("H:i:s")." METODO=".$acao."\n");
                        fwrite($arquivo,date("H:i:s")." PARAMETROENTRADA->".$novaentrada."\n");

                        fclose($arquivo);

                       
//                        $xml = simplexml_load_string(str_replace("&","&amp;",$entrada));
                        // $entrada)); // PHP5
                        //$xml = simplexml_load_string($entrada);

                        $xml = $novaentrada;


			$entrada = $xml;

                        //$entrada = "<?xml version='1.0' encoding='UTF-8' ? ><conteudo><controle></controle>$parametros</conteudo>";


                        $arquivo = fopen($arqlog,"a");
                        fwrite($arquivo,date("H:i:s")." ENTRADA=".$entrada."\n");
                        fclose($arquivo);

                        include "config.php";
                        $saida = "xml";


                        $this->progress($dlc,$pf,$propath,$progresscfg);

                        $this->parametro = "ws!acao!entrada";
                        
                        $this->parametros = $this->ws . "!" . $acao . "!" . $entrada; 
                        $this->executa("neurotech.p");
 
                        $arquivo = fopen($arqlog,"a");
                        fwrite($arquivo,date("H:i:s")." PROGRESS=".$this->progress."\n");
                        fclose($arquivo);

                        $xml = simplexml_load_string(str_replace("&","&amp;",$this->progress));
						
					//return $this->progress;
				// Object to Array 	
 			//$array = json_decode(json_encode((array) $xml), 1);
			return $xml;

 $array2 = $array["rows"]; //array($xml->getName() => $array);


			//print_r( $array2);
			return json_encode($array2);

						
						//return json_encode($xml);

                        $array = json_decode(json_encode((array) $xml), 1);
                        $array = array($xml->getName() => $array);
                        return $array;

                }
                
        }



?>
