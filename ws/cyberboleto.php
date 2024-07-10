<?php
        
        /**
         * Servidor.php
         * 
         */

        /**
         * Inclui a biblioteca do nusoap
         */

        require_once("boleto/nusoapWS_cyberboleto_v1701.php");

        require("/u/bsweb/progr/php/funcoes_v1701.inc");

        include ("boleto/xml_v1701.php");

        
        /**
         * Instância os objetos
         */
        $servidor = new soap_server ();
        
        $ns = 'http://localhost/ws.cyberboleto';
        /**
         * Configura o WSDL do servidor
         */
        $servidor->configureWSDL('cyberboleto', $ns , false, 'document');

       $servidor->wsdl->schemaTargetNamespace = $ns."?wsdl";
        
        /**
         * Registra os métodos disponíveis
         */
       include ("boleto/cybgravaacordo_v2001.php");
       include ("boleto/cybgeraboleto.php");
       include ("boleto/cybgravapromessa_v2101.php");

$HTTP_RAW_POST_DATA = isset($HTTP_RAW_POST_DATA)?$HTTP_RAW_POST_DATA : '';
$HTTP_RAW_POST_DATA = str_replace("&lt;","ABRE",$HTTP_RAW_POST_DATA);
$HTTP_RAW_POST_DATA = str_replace("&gt;","FECHA",$HTTP_RAW_POST_DATA);

        $servidor->service($HTTP_RAW_POST_DATA);
?>
