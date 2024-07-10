<?php

        class eistoadm extends progress
        {
                var $ws = "eistoadm"; // Letra Minuscula por causa do progress

                function executarprogress($acao,$novaentrada)
                {
                        $pegar_ip = $_SERVER["REMOTE_ADDR"];
                                                
                        
                        $arqlog = "/u/bsweb/log/eistoadm_".date("dmY").".log";
                        $arquivo = fopen($arqlog,"a");
                        fwrite($arquivo,date("H:i:s")." IP=".$pegar_ip."\n");
                        fwrite($arquivo,date("H:i:s")." METODO=".$acao."\n");
                        fwrite($arquivo,date("H:i:s")." PARAMETROENTRADA->".$novaentrada."\n");
                        fclose($arquivo);
                        
                        
                        $xml = $novaentrada;
                        $entrada = $xml;

                        $arquivo = fopen($arqlog,"a");
                        fwrite($arquivo,date("H:i:s")." ENTRADA=".$entrada."\n");
                        fclose($arquivo);
                        
                        include "config.php";
                        $saida = "xml";

                        $this->progress($dlc,$pf,$propath,$progresscfg);

                        $this->parametro = "ws!acao!entrada";
                        
                        $this->parametros = $this->ws . "!" . $acao . "!" . $entrada; 
                        $this->executa("/u/bsweb/progr/erp/eis_toadm/eistoadm.p");
 
                        $arquivo = fopen($arqlog,"a");
                        fwrite($arquivo,date("H:i:s")." PROGRESS=".$this->progress."\n");
                        fclose($arquivo);
                        
                        $xml = simplexml_load_string(str_replace("&","&amp;",$this->progress));
                                                
                        $json = json_encode($xml);
                        $array = json_decode($json,TRUE);
                        
                        return $json;


                }
                
        }



?>
