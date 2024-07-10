<?php

        require_once("nusoapWS.php");
        include "/u/bsweb/progr/php/progress_03.php";

function array_complex_to_xml($array, $depth = 0 , $tag= ""){
    $indent = '';
    $return = '';
    for($i = 0; $i < $depth; $i++)
        $indent .= "\t";
    foreach($array as $key => $item){
        if(is_array($item)) {
                if (is_numeric($key)) {
                    $return .= "{$indent}<{$tag}>\n";
                }
                else {
                    if (!array_key_exists("0", $item)) {
                        $return .= "{$indent}<{$key}>\n";
                    }
                    $tag=$key;
                }
                $return .= array_complex_to_xml($item, $depth + 1 ,$tag);
                if (is_numeric($key)) {
                    $return .= "{$indent}</$tag>\n";
                }
                else {
                    if (!array_key_exists("0", $item)) {
                       $return .= "{$indent}</$key>\n";
                    }
                    $tag="";
                }
        }
        else {
            $return .= "{$indent}<{$key}>";
            $return .= "{$item}";
            //$return .= "\n";
            $return .= "</{$key}>\n";
        }
        //$return .= "{$indent}<\\{$key}>\n";
    }
    return $return;
}


function array_to_xml($array, $level=1 , $chave="") {
        $xml = '';
    //if ($level==1) {
        //$xml .= "<array>\n";
    //}
	echo "level=$level\n";
    foreach ($array as $key=>$value) {
        $key = strtolower($key);
        if (is_object($value)) {$value=get_object_vars($value);}// convert object to array
        
        if (is_array($value)) {
	    echo "is_array level=$level key=$key chave=$chave value=$value\n";
            $multi_tags = false;
		if ($chave=="") {$chave=$key;}

            $xml .= str_repeat("\t",$level)."<$chave>\n";

            foreach($value as $key2=>$value2) {
             if (is_object($value2)) {$value2=get_object_vars($value2);} // convert object to array
                if (is_array($value2)) {
             echo "is_array(value2) key=$key chave=$chave key2=$key2 value2=$value2\n";

            //        $xml .= str_repeat("\t",$level)."<$key2>\n";
                    $xml .= array_to_xml($value2, $level+1, $key2);
                    //$xml .= str_repeat("\t",$level)."</$key2>\n";
                    $multi_tags = true;
                } else {
		    echo "NAOis_array(value2) key=$key key2=$key2 value2=$value2\n";

                    if (trim($value2)!='') {
                        if (htmlspecialchars($value2)!=$value2) {
                            $xml .= str_repeat("\t",$level).
                                    "<$key2><![CDATA[$value2]]>". // changed $key to $key2... didn't work otherwise.
                                    "</$key2>\n";
                        } else {
                            $xml .= str_repeat("\t",$level).
                                    "<$key2>$value2</$key2>\n"; // changed $key to $key2
                        }
                    }
                    $multi_tags = true;
                }
            }
            $xml .= str_repeat("\t",$level)."</$chave>\n";

            if (!$multi_tags and count($value)>0) {
		echo "$multi_tags count($value)\n";
                $xml .= str_repeat("\t",$level)."<$key>\n";
                $xml .= array_to_xml($value, $level+1);
                $xml .= str_repeat("\t",$level)."</$key>\n";
            }
      
         } else {
	    echo "nao is_array value=$value\n";
            if (trim($value)!='') {
             echo "key=$key value=$value\n";
                if (htmlspecialchars($value)!=$value) {
                    $xml .= str_repeat("\t",$level)."<$key>".
                            "<![CDATA[$value]]></$key>\n";
                } else {
                    $xml .= str_repeat("\t",$level).
                            "<$key>$value</$key>\n";
                }
            }
        }
    }
   //if ($level==1) {
        //$xml .= "</array>\n";
    //}
    return $xml;
}

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
