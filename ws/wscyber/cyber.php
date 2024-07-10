<?php
        /**
         */
        //include "/u/bsweb/progr/php/progress.php";


        class cyber extends progress
        {
                var $ws = "cyber"; // Letra Minuscula por causa do progress

                function executarprogress($acao,$novaentrada)
                {
                        $x = str_replace("ABRE","<",$entrada);
                        $x = str_replace("FECHA",">",$x);

                        $original = $x;

                        $entrada = $x;
                          $arquivo = fopen("/u/bsweb/log/cyber.log","a");
                          fwrite($arquivo,"XML\n");
                          fwrite($arquivo,$novaentrada);
                         fclose($arquivo);
                        
                        $xml = simplexml_load_string(str_replace("&","&amp;",$entrada));
                        // $entrada)); // PHP5
                        //$xml = simplexml_load_string($entrada);

                        $xml = $novaentrada;

                          $arquivo = fopen("/u/bsweb/log/cyber.log","a");
                          fwrite($arquivo,"\nLEU XML".$xml."\n");
                         fclose($arquivo);
                        
                        $usuario = $xml->controle->loja;
                        $senha   = $xml->controle->senha;
                        
                                if ("$acao" == "consultasaldocpf") {
                                $parametros = "<consultasaldocpf>";
                                $parametros .= arrayparaxml($xml);
                                $parametros = $parametros."</consultasaldocpf>";
                        }        

                                if ("$acao" == "consultasaldocontrato") {
                                $parametros = "<consultasaldocontrato>";
                                $parametros .= arrayparaxml($xml);
                                $parametros = $parametros."</consultasaldocontrato>";
                        }


                        $entrada = "<?xml version='1.0' encoding='UTF-8' ?><conteudo><controle></controle>$parametros</conteudo>";

                        $arquivo = fopen("/u/bsweb/log/cyber.log","a");
                          fwrite($arquivo,"\nXML ENTRADA".$entrada."\n");
                         fclose($arquivo);

                        
                        include "config.php";
                        $saida = "xml";


                        $this->progress($dlc,$pf,$propath,$progresscfg);

                        $this->parametro = "ws!acao!entrada";
                        
                        $this->parametros = $this->ws . "!" . $acao . "!" . $entrada; 
                        $this->executa($proginicial);
 
                          $arquivo = fopen("/u/bsweb/log/cyber.log","a");
                          fwrite($arquivo,"EXECUTOU PROGRESS\n");
                         fclose($arquivo);
 
                          $arquivo = fopen("/u/bsweb/log/cyber.log","a");
                          fwrite($arquivo,$this->progress."\n");
                         fclose($arquivo);

                          $arquivo = fopen("/u/bsweb/progr/retorno.xml","w");
                          fwrite($arquivo,$this->progress."\n");
                         fclose($arquivo);
 
    $xml = simplexml_load_string(str_replace("&","&amp;",$this->progress));

$array = json_decode(json_encode((array) $xml), 1);
$array = array($xml->getName() => $array);
return $array;

function XML2Array(SimpleXMLElement $parent)
{
    $array = array();

    foreach ($parent as $name => $element) {
        ($node = & $array[$name])
            && (1 === count($node) ? $node = array($node) : 1)
            && $node = & $node[];

        $node = $element->count() ? XML2Array($element) : trim($element);
    }

    return $array;
}

$array = XML2Array($xml);
$array = array($xml->getName() => $array);


$xml_array = unserialize(serialize(json_decode(json_encode((array) $xml), 1)));

                        return $array; 
                        //return $this->progress;
                }
                
        }
?>
