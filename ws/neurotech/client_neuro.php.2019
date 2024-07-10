<?php
include "/u/bsweb/progr/php/funcoes_v1701.inc";
$Operacao = 0;

$arqlog = "/ws/log/p2k07_".date("dmY").".log";
$arquivo = fopen($arqlog,"a");
fwrite($arquivo,"\n ".date("H:i:s")." CLIENT_NEURO INICIO\n");
fclose($arquivo);

// Parametro
$FluxoParametro = array();

//for ($i=1; $i < $argc; $i++) {parse_str($argv[$i]);}

$POLITICA='';
$IDPROPOSTA='';

$vi = 0;
// PEGA PARAMETROS E TRANSFORMA EM ENTRADA
foreach ($_GET as $key=>$value) {
   //echo "\n".$key."=".$value;
   //$arquivo = fopen($arqlog,"a");
   //fwrite($arquivo,"\n".$key."=".$value);
   //fclose($arquivo);
  
   switch ($key) {
    case 'POLITICA':
        $POLITICA=$value;
        break;
    case 'PROP_CPFCLI':
        $IDPROPOSTA=$value;
        $FluxoParametro[$vi] = array('NmParametro'=>$key,'VlParametro'=>$value);
        $vi = $vi + 1;
        break;
    default:
        $FluxoParametro[$vi] = array('NmParametro'=>$key,'VlParametro'=>$value);
        $vi = $vi + 1;
        break;
   }
}

/**
Credenciais Lebes:
Codigo Associado: 148
Codigo Filial: 0
Senha: abcd@1234
Nome da Política: P1
Fluxo resultado final: FLX_PRINCIPAL
**/

$Credenciais = array('CodigoAssociado' => 148,'CodigoFilial' => '0','Senha' => 'abcd@1234');

$Fluxo =  array('NmPolitica'   => $POLITICA,
                'TagVersaoPolitica' => '',
                'NmFluxoResultado' => 'FLX_PRINCIPAL',
                'IdProposta' => $IDPROPOSTA,
                'LsParametros' => $FluxoParametro);

$Propriedade = array('Nome' => 'USUARIO','Valor' => 'USUARIO');
$arguments= array(array('Credenciais' => $Credenciais,
                        'Fluxo' => $Fluxo,
                        'Parametros' => $Propriedade ) );


function to_long_xml($longVal) {
    return '<long>' . $longVal . '</long>';
}
function from_long_xml($xmlFragmentString) {
    return (string) strip_tags($xmlFragmentString);
}

$arquivo = fopen($arqlog,"a");
fwrite($arquivo," client_neuro ".date("d/m/Y-H:i:s")." CHAMANDO NEURO->");
fclose($arquivo);

//file_put_contents($arqlog, print_r($arguments, true));

$client = new SoapClient("https://dr-lebes-prd.neurotech.com.br/services/soap/porting?wsdl", array(
//$client = new SoapClient("http://dr-prd.neurotech.com.br/services/soap/porting?wsdl", array(
  'typemap' => array(
    array(
      'type_ns' => 'http://www.w3.org/2001/XMLSchema',
      'type_name' => 'long',
      'to_xml' => 'to_long_xml',
      'from_xml' => 'from_long_xml',
    ),
  ),
));

$options = array('location' => 'https://dr-lebes-prd.neurotech.com.br/services/soap/porting', 'trace'=>1);

//$options = array('location' => 'https://dr-prd.neurotech.com.br/services/soap/porting', 'trace'=>1);

$dataehora = date("dmYHis");

$saida = array_complex_to_xml($arguments);
$arquivo = fopen("/ws/log/NeuroXML_Entrada_".$dataehora.".xml","w");
fwrite($arquivo,"\n".$saida);
fclose($arquivo);

$arquivo = fopen($arqlog,"a");
fwrite($arquivo,"\n XML ENTRADA NEURO\n".$saida."\n");
fclose($arquivo);

$function = "executarFluxoComParametros";
$result = $client->__soapCall($function, $arguments, $options);
//$xx = $client->__getLastRequest();
//echo "REQUEST:\n" . $client->__getLastRequest() . "\n";

if (is_soap_fault($result))
{
    $arquivo = fopen($arqlog,"a");
    fwrite($arquivo,"\nERRO".$result->faulstring);
    fclose($arquivo);

    trigger_error("Falha no SOAP: (faultcode: {$result->faultcode},
              faultstring: {$result->faulstring})", E_ERROR);
    return;
}

$arquivo = fopen($arqlog,"a");
fwrite($arquivo,"<-"." client_neuro ".date("d/m/Y-H:i:s")." VOLTOU!");
fclose($arquivo);

$saida = array_complex_to_xml(json_decode(json_encode($result), true));
$arquivo = fopen("/ws/log/NeuroXML_Saida_".$dataehora.".xml","w");
fwrite($arquivo,"\n".$saida);
fclose($arquivo);

$arquivo = fopen($arqlog,"a");
fwrite($arquivo,"\n XML ENTRADA NEURO no arquivo /ws/log/NeuroXML_Saida_".$dataehora.".xml"."\n");
fclose($arquivo);

//$string_id = sprintf('%.0f', $result->executarFluxoComParametrosResult->CdOperacao);
//echo "\nstring_id=".$string_id."\n";
//$Operacao=$result->executarFluxoComParametrosResult->CdOperacao;
//$OPER = number_format($Operacao, 0, '', '');
//echo "\nOPER= ".$OPER;

$Operacao=$result->executarFluxoComParametrosResult->CdOperacao;
$DsMensagem=$result->executarFluxoComParametrosResult->DsMensagem;
//echo "\n". $Operacao . " is a ". gettype($result->executarFluxoComParametrosResult->CdOperacao) . "<br>";

$Resultado="E";
if (property_exists($result->executarFluxoComParametrosResult, "Resultado")) {
    $Resultado=$result->executarFluxoComParametrosResult->Resultado;
}

//
$retorno = array();
$sub = array();
if (property_exists($result->executarFluxoComParametrosResult, "LsRetorno")) {
    $retorno = get_object_vars($result->executarFluxoComParametrosResult->LsRetorno);
}

if (array_key_exists("ParametroFluxo",$retorno)) {
    foreach ($retorno['ParametroFluxo'] as $key=>$value) {
        $sub = get_object_vars($value);
        $PARAMETRO=trim($sub['NmParametro']);
        $RESPOSTA =trim($sub['VlParametro']);


        if (substr( $PARAMETRO, 0, 5 ) === "xCALC_" ||
            substr( $PARAMETRO, 0, 5 ) === "xPROP_" ||
            substr( $PARAMETRO, 0, 4 ) === "xFLX_" ||
            substr( $PARAMETRO, 0, 4 ) === "RET_" ||
            substr( $PARAMETRO, 0, 5 ) === "xFLAG_" ||
                    $PARAMETRO         === "VI_NEUROTECH_CD_OPERACAO" ) {

            $arquivo = fopen($arqlog,"a");
            fwrite($arquivo,"\nRESPOSTA ".$PARAMETRO."=".$RESPOSTA);
            fclose($arquivo);

            echo "\n".$PARAMETRO;
            echo "=".$RESPOSTA;
            if ($PARAMETRO         === "VI_NEUROTECH_CD_OPERACAO" ) {
                $Operacao = $RESPOSTA;
            }
        }
    }
}

echo "\nOperacao=".$Operacao."\n";
echo "DsMensagem=".$DsMensagem."\n";
echo "Resultado=".$Resultado."\n";
echo "\n ";

$arquivo = fopen($arqlog,"a");
fwrite($arquivo,"\n"." Operacao=".$Operacao);
fwrite($arquivo,"\n"." DsMensagem=".$DsMensagem);
fwrite($arquivo,"\n"." Resultado=".$Resultado);
fwrite($arquivo,"\n ".date("H:i:s")." CLIENT_NEURO FIM\n");

fwrite($arquivo,"\n XML ENTRADA NEURO no arquivo /ws/log/NeuroXML_Saida_".$dataehora.".xml"."\n");
fclose($arquivo);
?>
