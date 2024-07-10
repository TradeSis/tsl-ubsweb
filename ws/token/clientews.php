<?php

// PHP CLIENTE QUE FAZ MEIO DE CAMPO PROGRESS COM WS

function getvar($varname) {
        $v=(isset($_GET[$varname]))?$_GET[$varname]:((isset($_POST[$varname]))?$_POST[$varname]:'');
        //if(!$v) $v = $_SESSION[$varname];
        //else $_SESSION[$varname] = $v;
        return($v);
}


function RodaWebServices  ($ws,$chamar,$variavel,$entrada)
{

        $client = new SoapClient($ws,
                        array( 'soap_version' => SOAP_1_2,
                               'trace'    => 1));
/*
        $arquivo = fopen($entrada,"r+");
        $xmlEntrada = fread($arquivo,filesize($entrada));
  */  

      $xmlEntrada = $entrada;

      $hora = date("Ymd");       
 
  $fp = fopen("/ws/log/tk_sol." . $hora . ".log", "a");
      fwrite($fp, "\nEntrada".$xmlEntrada);
      fclose($fp);
 
        $result = $client->__Call($chamar,
                         array('parameters'=>array($variavel=>$xmlEntrada)));
     
  
/*
$fp = fopen("/u/wse-com/ws-token/logs/ret." . $hora . ".log", "w");
      fwrite($fp, $result);
      fclose($fp);
*/


   return $result;


}


        $ws             = getvar('ws');
        $metodo         = getvar('metodo');
        $variavel       = getvar('variavel');
        $entrada        = getvar('entrada');
        $varresposta    = getvar('varresposta');
            
      $hora = date("Ymd");

  $fp = fopen("/ws/log/tk_sol." . $hora . ".log", "a");
      fwrite($fp, "\nParametros".$ws." ");
     fwrite($fp, $metodo." ");
     fwrite($fp, $variavel." ");
     fwrite($fp, $entrada." ");
     fwrite($fp, $varresposta." ");

      fclose($fp);

        $saida = RodaWebServices($ws,$metodo,$variavel,$entrada);
        print_r($saida->$varresposta);
      $hora = date("Ymd");

  $fp = fopen("/ws/log/tk_sol." . $hora . ".log", "a");
 //fwrite($fp,"\nRsaida->".$saida." \n");

      fwrite($fp,"\nRresposta->".$saida->$varresposta." \n");

      fclose($fp);

        
        exit;

?>
