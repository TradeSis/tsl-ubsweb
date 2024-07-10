<?php

        require_once("nusoapWS.php");
        include "/u/bsweb/progr/php/progress.php";


function arrayparaxml($array) {

    function hia2xml($array) {
        $xml="";
        foreach ($array as $key=>$value) {
            if (is_array($value)) {
                $xml.="<$key>".hia2xml($value)."</$key>";
            } else {
                $xml.="<$key>".$value."</$key>";
            }
        }
        return $xml;
    }

    return hia2xml($array);
}


function getvar($varname) {
        $v=(isset($_GET[$varname]))?$_GET[$varname]:((isset($_POST[$varname]))?$_POST[$varname]:'');
        //if(!$v) $v = $_SESSION[$varname];
        //else $_SESSION[$varname] = $v;
        return($v);
}

	/*
	*  Cliente do WebServices bsecom/Servidor.php
	*/

function RodaWebServices ($ws,$chamar,$xmlEntrada)
{

        $param  = array('name'=>$xmlEntrada);
	$cliente = new nusoapclient($ws, true);
	$erro = $cliente->getError();
	if ($erro)
	{
		echo "Erro no construtor<pre>" . $erro . "</pre>";
	}
	
	$resultado = $cliente->call($chamar,$param);
	if ($cliente->fault)
	{
		echo "Falha<pre>" . print_r($resultado) . "</pre>";
	}
	else
	{
		$erro = $cliente->getError();
		if ($erro)
		{
			echo "Erro<pre>" . $erro . "</pre>";	
		}
		else
		{
			return $resultado;
		}
	}
//echo '<h2>Request</h2><pre>' . htmlspecialchars($cliente->request, ENT_QUOTES) . '</pre>';
//echo '<h2>Response</h2><pre>' . htmlspecialchars($cliente->response, ENT_QUOTES) . '</pre>';
//echo '<h2>Debug</h2><pre>' . htmlspecialchars($cliente->debug_str, ENT_QUOTES) . '</pre>';

}
?>
