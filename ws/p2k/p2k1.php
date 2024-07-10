<?
        /**
         */
        //include "/u/bsweb/progr/php/progress.php";


        class p2k extends progress
        {
                var $ws = "p2k"; // Letra Minuscula por causa do progress

                function executarprogress($acao,$novaentrada)
                {
                        $x = str_replace("ABRE","<",$entrada);
                        $x = str_replace("FECHA",">",$x);

                        $original = $x;

                        $entrada = $x;
                          $arquivo = fopen("/u/bsweb/log/p2k.log","a");
                          fwrite($arquivo,"XML\n");
                          fwrite($arquivo,$novaentrada);
                         fclose($arquivo);
                        
                        $xml = simplexml_load_string(str_replace("&","&amp;",$entrada));
                        // $entrada)); // PHP5
                        //$xml = simplexml_load_string($entrada);

                        $xml = $novaentrada;

                          $arquivo = fopen("/u/bsweb/log/p2k.log","a");
                          fwrite($arquivo,"\nLEU XML".$xml."\n");
                         fclose($arquivo);
                        
                        $usuario = $xml->controle->loja;
                        $senha   = $xml->controle->senha;
                        
                                if ("$acao" == "ConsultaCliente") {
                                $parametros = "<ConsultaCliente>";
                                $parametros .= arrayparaxml($xml);
                                $parametros = $parametros."</ConsultaCliente>";
                        }        

                        if ("$acao" == "AtualizacaoDadosCliente") {

                                $parametros = "<AtualizacaoDadosCliente>".arrayparaxml($xml)."</AtualizacaoDadosCliente>";

                        }

                        if ("$acao" == "BuscaDadosContratoNf") {

                                $parametros = "<BuscaDadosContratoNf>".array_complex_to_xml($xml)."</BuscaDadosContratoNf>";

                        }
                        if ("$acao" == "EfetivaVenda") {

                                $parametros = "<EfetivaVenda>".arrayparaxml($xml)."</EfetivaVenda>";

                        }
                        if ("$acao" == "ConsultaParcelas") {

                                $parametros = "<ConsultaParcelas>".arrayparaxml($xml)."</ConsultaParcelas>";

                        }
                        if ("$acao" == "EfetivaPagamentoPrestacao") {

                                $parametros = "<EfetivaPagamentoPrestacao>".arrayparaxml($xml)."</EfetivaPagamentoPrestacao>";

                        }
                        if ("$acao" == "BuscaDadosClienteNome") {

                                $parametros = "<BuscaDadosClienteNome>".arrayparaxml($xml)."</BuscaDadosClienteNome>";

                        }
                        if ("$acao" == "CancelamentoCrediario") {

                                $parametros = "<CancelamentoCrediario>".arrayparaxml($xml)."</CancelamentoCrediario>";

                        }
                        if ("$acao" == "BuscaSenhaToken") {

                                $parametros = "<BuscaSenhaToken>".arrayparaxml($xml)."</BuscaSenhaToken>";

                        }
                        if ("$acao" == "DataFuturaPagamentoPrestacao") {

                                $parametros = "<DataFuturaPagamentoPrestacao>".array_complex_to_xml($xml)."</DataFuturaPagamentoPrestacao>";

                        }

                        $entrada = "<?xml version='1.0' encoding='UTF-8' ?><conteudo><controle></controle>$parametros</conteudo>";

                        $arquivo = fopen("/u/bsweb/log/p2k.log","a");
                          fwrite($arquivo,"\nXML ENTRADA".$entrada."\n");
                         fclose($arquivo);

                        
                        include "config.php";
                        $saida = "xml";


                        $this->progress($dlc,$pf,$propath,$progresscfg);

                        $this->parametro = "ws!acao!entrada";
                        
                        $this->parametros = $this->ws . "!" . $acao . "!" . $entrada; 
                        $this->executa($proginicial);
 
                          $arquivo = fopen("/u/bsweb/log/p2k.log","a");
                          fwrite($arquivo,"EXECUTOU PROGRESS\n");
                         fclose($arquivo);
 
                          $arquivo = fopen("/u/bsweb/log/p2k.log","a");
                          fwrite($arquivo,"arquivo retorno\n");

                          fwrite($arquivo,$this->progress."\n");
                         fclose($arquivo);

                          $arquivo = fopen("/u/bsweb/progr/retorno.xml","w");
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
                          $arquivo = fopen("/u/bsweb/log/p2k.log","a");
                          fwrite($arquivo,"SEM ACENTOS\n");

                          fwrite($arquivo,$texto."\n");
                         fclose($arquivo);

    $xml = simplexml_load_string($texto);

//    $xml = simplexml_load_string(str_replace("&","&amp;",$this->progress));

$array = json_decode(json_encode((array) $xml), 1);
$array = array($xml->getName() => $array);
                          $arquivo = fopen("/u/bsweb/log/p2k.log","a");
                          fwrite($arquivo,"retornando\n");

                          fwrite($arquivo,$array."\n");
                         fclose($arquivo);

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
