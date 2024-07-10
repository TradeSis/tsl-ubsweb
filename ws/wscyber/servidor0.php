<?php
        
        /**
         * Servidor.php
         * 
         */

        /**
         * Inclui a biblioteca do nusoap
         */
        require("/u/bsweb/progr/php/funcoes.inc");

        include ("/u/bsweb/progr/ws/wscyber/wscyber.php");

        
        /**
         * Instância os objetos
         */
        $servidor = new soap_server();
        
        /**
         * Configura o WSDL do servidor
         */
        $servidor->configureWSDL('servidor.wscyber', 'urn:servidor.wscyber');
        $servidor->wsdl->schemaTargetNamespace = 'urn:servidor.wscyber';
        
        /**
         * Registra os métodos disponíveis
         */

      $servidor->register
        (
                'consultasaldocpf',
                array('valor' => 'xsd:string'),
                array('resultado' => 'xsd:string'),
                'urn:servidor.consultasaldocpf',
                'urn:servidor.wscyber#consultasaldocpf',
                'rpc',
                'encoded',
                'consultaSaldoCPF - XML consultaSaldoCPF'
        );


       function consultasaldocpf($parametro)
        {
                $wscyber = new wscyber();
                return $wscyber->executarprogress("consultasaldocpf",$parametro);
        }


      $servidor->register
        (
                'consultasaldocontrato',
                array('valor' => 'xsd:string'),
                array('resultado' => 'xsd:string'),
                'urn:servidor.consultasaldocontrato',
                'urn:servidor.wscyber#consultasaldocontrato',
                'rpc',
                'encoded',
                'consultaSaldoContrato - XML consultaSaldoContrato'
        );


       function consultasaldocontrato($parametro)
        {
                $wscyber = new wscyber();
                return $wscyber->executarprogress("consultasaldocontrato",$parametro);
        }



        
        
$HTTP_RAW_POST_DATA = isset($HTTP_RAW_POST_DATA)?$HTTP_RAW_POST_DATA : '';
$HTTP_RAW_POST_DATA = str_replace("&lt;","ABRE",$HTTP_RAW_POST_DATA);
$HTTP_RAW_POST_DATA = str_replace("&gt;","FECHA",$HTTP_RAW_POST_DATA);

        $servidor->service($HTTP_RAW_POST_DATA);
?>
