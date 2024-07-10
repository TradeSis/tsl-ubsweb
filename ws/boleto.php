<?php
        
        /**
         * Servidor.php
         * 
         */

        /**
         * Inclui a biblioteca do nusoap
         */

        require_once("boleto/nusoapWS_v1701.php");

        require("/u/bsweb/progr/php/funcoes_v1701.inc");

        include ("boleto/xml_v1701.php");

        
        /**
         * Instância os objetos
         */
        $servidor = new soap_server ();
        
	$ns = 'http://localhost/ws.boleto';
        /**
         * Configura o WSDL do servidor
         */
        $servidor->configureWSDL('boleto', $ns , false, 'document');

       $servidor->wsdl->schemaTargetNamespace = $ns."?wsdl";
        
        /**
         * Registra os métodos disponíveis
         */
       include ("boleto/consultacliente_v1702.php");
       include ("boleto/consultaparcelas_v1701.php");
       include ("boleto/geraboletocontrato_v1701.php");
       include ("boleto/reenviaboletos_v1701.php");
       include ("boleto/avisopagamentoted_v1801.php");
       include ("boleto/efetivapagamentoted_v1801.php");




$HTTP_RAW_POST_DATA = isset($HTTP_RAW_POST_DATA)?$HTTP_RAW_POST_DATA : '';
$HTTP_RAW_POST_DATA = str_replace("&lt;","ABRE",$HTTP_RAW_POST_DATA);
$HTTP_RAW_POST_DATA = str_replace("&gt;","FECHA",$HTTP_RAW_POST_DATA);

        $servidor->service($HTTP_RAW_POST_DATA);
?>
