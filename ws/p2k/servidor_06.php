<?php
        
        /**
         * Servidor.php
         * Em desenvolvimento
         */

        global $versao;
        $versao = "06";
        putenv("versao-wsp2k=$versao");

        /**
         * Inclui a biblioteca do nusoap
         */
       require("funcoes_03.inc");

       include ("p2k_".$versao.".php");
        
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
       include ("ConsultaCliente_06.php");
       include ("AtualizacaoDadosCliente_06.php");
       include ("EfetivaPagamentoPrestacao_03.php");
       include ("BuscaDadosClienteNome_06.php");
       include ("CancelamentoCrediario.php");
       include ("ConsultaParcelas_04.php");
       include ("BuscaSenhaToken.php");

       include ("DataFuturaPagamentoPrestacao_03.php");
       include ("BuscaDadosContratoNf_03.php");
       include ("EfetivaPagamentoBonus.php");
       include ("CancelamentoPagamentoPrestacao.php");
       include ("EfetivaVenda_03.php");
       include ("ConsultaSPC_03.php");
       include ("ConsultaEstoque_03.php");
       include ("ConsultaImei.php");
       include ("MargemDesconto.php");

       /* Credito Pessoal */
       include ("ConsultaProdutosFinanceiros_03.php");
       include ("SimularTransacaodeCredito_03.php");
       include ("AutorizarEmprestimo_03.php");
       include ("EfetivaEmprestimo_03.php");
       include ("ConsultaAcordo_03.php");

        /* motor de credito */
        include ("PreAutorizacao_06.php");
        include ("VerificaCreditoVenda_06.php");
        include ("ConsultaCEP_05.php");


$HTTP_RAW_POST_DATA = isset($HTTP_RAW_POST_DATA)?$HTTP_RAW_POST_DATA : '';
$HTTP_RAW_POST_DATA = str_replace("&lt;","ABRE",$HTTP_RAW_POST_DATA);
$HTTP_RAW_POST_DATA = str_replace("&gt;","FECHA",$HTTP_RAW_POST_DATA);

       $servidor->service($HTTP_RAW_POST_DATA);
?>
