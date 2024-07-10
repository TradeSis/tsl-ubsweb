<?php
        
        /**
         * Servidor.php
         * 
         */

        /**
         * Inclui a biblioteca do nusoap
         */
        require("funcoes.inc");

        include ("p2k.php");

        
        /**
         * Instância os objetos
         */
        $servidor = new soap_server ();
        
	$ns = 'http://localhost/ws.p2k';
        /**
         * Configura o WSDL do servidor
         */
        $servidor->configureWSDL('p2k', $ns , false, 'document');

       $servidor->wsdl->schemaTargetNamespace = $ns."?wsdl";
        
        /**
         * Registra os métodos disponíveis
         */
       include ("ConsultaCliente.php");
       include ("AtualizacaoDadosCliente.php");
       include ("EfetivaPagamentoPrestacao.php");
       include ("BuscaDadosClienteNome.php");
       include ("CancelamentoCrediario.php");
       include ("ConsultaParcelas.php");
       include ("BuscaSenhaToken.php");

       include ("DataFuturaPagamentoPrestacao.php");
       include ("BuscaDadosContratoNf.php");
       include ("EfetivaPagamentoBonus.php");
       include ("CancelamentoPagamentoPrestacao.php");
       include ("EfetivaVenda.php");
       include ("ConsultaSPC.php");
       include ("ConsultaEstoque.php");
       include ("ConsultaImei.php");

       /* Credito Pessoal */
       include ("ConsultaProdutosFinanceiros.php");
       include ("SimularTransacaodeCredito.php");
       include ("AutorizarEmprestimo.php");
       include ("EfetivaEmprestimo.php");

$HTTP_RAW_POST_DATA = isset($HTTP_RAW_POST_DATA)?$HTTP_RAW_POST_DATA : '';
$HTTP_RAW_POST_DATA = str_replace("&lt;","ABRE",$HTTP_RAW_POST_DATA);
$HTTP_RAW_POST_DATA = str_replace("&gt;","FECHA",$HTTP_RAW_POST_DATA);

        $servidor->service($HTTP_RAW_POST_DATA);
?>
