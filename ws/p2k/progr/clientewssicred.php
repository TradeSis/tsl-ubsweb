<?php

// PHP CLIENTE QUE FAZ MEIO DE CAMPO PROGRESS COM WS

function getvar($varname) {
        $v=(isset($_GET[$varname]))?$_GET[$varname]:((isset($_POST[$varname]))?$_POST[$varname]:'');
        //if(!$v) $v = $_SESSION[$varname];
        //else $_SESSION[$varname] = $v;
        return($v);
}

function RodaWebServices  ($ws,$chamar,$variavel,$entrada,$filial,
                        $param1,$param2,$param3,$param4)
{

        $fpb = fopen("/u/bsweb/log/teste2.log", "w");
        fwrite($fpb, 'testelog2.log');
        fclose($fpb);



        $client = new SoapClient($ws,
                        array( 'soap_version' => SOAP_1_2,
                               'trace'    => 1));

        $arquivo = fopen($entrada,"r+");
        $xmlEntrada = fread($arquivo,filesize($entrada));


        if ($chamar == "AutorizarNfe"){

             $arq1 = "<notamax_integracao>" .
                     "<dados usuario_notamax='publico' "  .
                          " senha_notamax='senha' " .
                          " aguardar_intervencao ='N' " .
                          " email_destinatario='$param1' " .
                          " email_transportadora='$param3' " .
                          " opcao_destinatario='$param2' " .
                          " opcao_transportadora='$param4' " .
                          " /> " .
                          " </notamax_integracao> " ;

            $xmlEntrada = $arq1 . "|" . $xmlEntrada;

        }
        
        
        $fpc = fopen("/u/bsweb/log/teste3.log", "w");
        fwrite($fpc, "$xmlEntrada");
       fclose($fpc);
       

        if ($chamar == "ConsultarPdfNfe"){

            $xmlEntrada = $xmlEntrada . "|" . $filial;

        }

        $result = $client->__Call($chamar,
                         array('parameters'=>array($variavel=>$xmlEntrada)));

     return $result;


}

        $ws             = getvar('ws');
        $metodo         = getvar('metodo');
        $variavel       = getvar('variavel');
        $entrada        = getvar('entrada');
        $filial         = getvar('filial');
        $varresposta    = getvar('varresposta');
        $param1         = getvar('param1');
        $param2         = getvar('param2');
        $param3         = getvar('param3');
        $param4         = getvar('param4');
       
        $fpa = fopen("/u/bsweb/log/teste.log", "w");
        fwrite($fpa, 'Achou6');
        
fwrite($fpa, "$ws");
fwrite($fpa, "$metodo");       
fwrite($fpa, "$variavel");     
fwrite($fpa, "$entrada");      
fwrite($fpa, "$filial");       
fwrite($fpa, "$varresposta");  
fwrite($fpa, "$param1");       
fwrite($fpa, "$param2");       
fwrite($fpa, "$param3");       
fwrite($fpa, "$param4");       




        fclose($fpa);
       
        $saida = RodaWebServices($ws,$metodo,$variavel,$entrada,$filial,
                $param1,$param2,$param3,$param4);


        $resposta = (string) $saida->$varresposta;

        $order   = ' xmlns="http //tempuri.org/"';
        $replace = '';

        $newstr = str_replace($order, $replace, $resposta);

        if ($metodo <> "ConsultarPdfNfe"){
                print_r($newstr);
        }


        exit;



?>
