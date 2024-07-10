<?php
        /**
         */
        //include "/u/bsweb/progr/php/progress.php";


        class boleto extends progress
        {
                var $ws = "boleto_v1701"; // Letra Minuscula por causa do progress

                function executarprogress($acao,$novaentrada)
                {

                        $arqlog  = "/u/bsweb/log/boleto".date("d").date("m").date("Y").".log";
                        
                        $arquivo = fopen($arqlog,"a");
                        fwrite($arquivo,"ACAO ".$acao);
                        fclose($arquivo);
                        
                        
                        //$xml = simplexml_load_string(str_replace("&","&amp;",$entrada));
                        // $entrada)); // PHP5
                        //$xml = simplexml_load_string($entrada);

                        $xml = $novaentrada;
                        $xml = str_replace("!", " ", $xml);

                        
                      if ("$acao" == "cybgravaacordo_v2001") {
                                $parametros = "<GravaAcordoEntrada>";
                                $parametros .= array_complex_to_xml($xml);
                                $parametros = $parametros."</GravaAcordoEntrada>";
                      }        

                      if ("$acao" == "cybgeraboleto") {
                                $parametros = "<GeraBoletoEntrada>";
                                $parametros .= array_complex_to_xml($xml);
                                $parametros = $parametros."</GeraBoletoEntrada>";
                      }
                      
                      if ("$acao" == "cybgravapromessa_v2101") {
                                $parametros = "<GravaPromessaEntrada>";
                                $parametros .= array_complex_to_xml($xml);
                                $parametros = $parametros."</GravaPromessaEntrada>";
                      }        

                      if ("$acao" == "consultacliente_v1701") {
                                $parametros = "<ClienteEntrada>";
                                $parametros .= array_complex_to_xml($xml);
                                $parametros = $parametros."</ClienteEntrada>";
                      }
                      if ("$acao" == "consultacliente_v1702") {
                                $parametros = "<ClienteEntrada>";
                                $parametros .= array_complex_to_xml($xml);
                                $parametros = $parametros."</ClienteEntrada>";
                      }

                     if ("$acao" == "consultaparcelas_v1701") {
                                $parametros = "<ClienteContratoEntrada>";
                                $parametros .= array_complex_to_xml($xml);
                                $parametros = $parametros."</ClienteContratoEntrada>";
                      }
                      if ("$acao" == "geraboletocontrato_v1701") {
                                $parametros = "<GeraBoletoContratoEntrada>";
                                $parametros .= array_complex_to_xml($xml);
                                $parametros = $parametros."</GeraBoletoContratoEntrada>";
                      }
                      if ("$acao" == "reenviaboletos_v1701") {
                                $parametros = "<ReenviaBoletosEntrada>";
                                $parametros .= array_complex_to_xml($xml);
                                $parametros = $parametros."</ReenviaBoletosEntrada>";
                      }
                      if ("$acao" == "avisopagamentoted_v1801") {
                                $parametros = "<AvisoPagamentoTedEntrada>";
                                $parametros .= array_complex_to_xml($xml);
                                $parametros = $parametros."</AvisoPagamentoTedEntrada>";
                      }
                      if ("$acao" == "efetivapagamentoted_v1801") {
                                $parametros = "<EfetivaPagamentoTedEntrada>";
                                $parametros .= array_complex_to_xml($xml);
                                $parametros = $parametros."</EfetivaPagamentoTedEntrada>";
                      }

                        //$parametros = "<".$acao.">".array_complex_to_xml($xml)."</".$acao.">";

                        $entrada = "<?xml version='1.0' encoding='ISO-8859-1' ?><conteudo><controle></controle>$parametros</conteudo>";

                        $arquivo = fopen($arqlog,"a");
                        fwrite($arquivo,"\nXML ENTRADA".$entrada."\n");
                        fclose($arquivo);
                        
                        $progresscfg="progress.cfg";

                        include "boleto/config.php";
                        $saida = "xml";

                        $this->progress($dlc,$pf,$propath,$progresscfg);
                        $this->parametro = "ws!acao!entrada";  
                        $this->parametros = $this->ws . "!" . $acao . "!" . $entrada; 
                        $this->executa($proginicial);

                        $arquivo = fopen($arqlog,"a");
                        fwrite($arquivo,"arquivo retorno\n");
                        fwrite($arquivo,$this->progress."\n");
                        fclose($arquivo);

 
// $texto = htmlspecialchars_decode($this->progress);

function tirarAcento($frase){

$search =  explode(",","ç,æ,œ  ,á,é,í,ó,ú,à,è,ì,ò,ù,ä,ë,ï,ö,ü,ÿ,â,ê,î,ô,û,å,e,i,ø,u,ã,Ã,Ç,Á,É,Í,Ó,Ú,À,È,Ì,Ò,Ù,Ä,Ë,Ï,Ö,Ü,Ÿ,Â,Ê,Î,Ô,Û,Å,E,I,Ø,U,&");
$replace = explode(",","c,ae,oe,a,e,i,o,u,a,e,i,o,u,a,e,i,o,u,y,a,e,i,o,u,a,e,i,o,u,a,A,C,A,E,I,O,U,A,E,I,O,U,A,E,I,O,U,Y,A,E,I,O,U,A,E,I,O,U,E");

$frase = str_replace($search, $replace, $frase);

return $frase;
}

 $texto = htmlspecialchars_decode(tirarAcento($this->progress));


    $xml = simplexml_load_string($texto);

//    $xml = simplexml_load_string(str_replace("&","&amp;",$this->progress));

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
