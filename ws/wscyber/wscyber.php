<?php
        /**
         */
        //include "/u/bsweb/progr/php/progress.php";


        class wscyber extends progress
        {
                var $ws = "wscyber"; // Letra Minuscula por causa do progress

                function executarprogress($acao,$entrada)
                {
                        $x = str_replace("ABRE","<",$entrada);
                        $x = str_replace("FECHA",">",$x);


                        $entrada = $x;
                          $arquivo = fopen("/u/bsweb/log/wscyber.log","a");
                          fwrite($arquivo,"XML\n");
                          fwrite($arquivo,$entrada);
                         fclose($arquivo);
                        
                        //$xml = simplexml_load_string(str_replace("&","&amp;",
                        // $entrada)); // PHP5
                        $xml = simplexml_load_string($entrada);

                          $arquivo = fopen("/u/bsweb/log/wscyber.log","a");
                          fwrite($arquivo,"\nLEU XML".$xml."\n");
                         fclose($arquivo);
                        
                        $usuario = $xml->controle->loja;
                        $senha   = $xml->controle->senha;
			if ("$acao" == "consultasaldocpf") {
				$parametros = "<consultasaldocpf><cpfcnpj>$xml->cpfcnpj";
			        $parametros .= "</cpfcnpj></consultasaldocpf>";
		        }	
			
                        if ("$acao" == "consultasaldocontrato") {
                                $parametros = "<consultasaldocontrato><contrato>$xml->contrato";
                                $parametros .= "</contrato></consultasaldocontrato>";
                        }


			$entrada = "<?xml version='1.0' encoding='UTF-8' ?><conteudo><controle></controle>$parametros</conteudo>";
                        
                        include "config.php";
                        $saida = "xml";


                        $this->progress($dlc,$pf,$propath,$progresscfg);

                        $this->parametro = "ws!acao!entrada";
                        
                        $this->parametros = $this->ws . "!" . $acao . "!" . $entrada; 
                        $this->executa($proginicial);
 
                          $arquivo = fopen("/u/bsweb/log/wscyber.log","a");
                          fwrite($arquivo,"EXECUTOU PROGRESS\n");
                         fclose($arquivo);
 
                          $arquivo = fopen("/u/bsweb/log/wscyber.log","a");
                          fwrite($arquivo,$this->progress."\n");
                         fclose($arquivo);
                          
                        return $this->progress;
                }
                
        }
?>
