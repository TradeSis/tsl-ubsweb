<?php
 
 include("funcoes.inc");

 require_once("nusoapNEURO.php");

$client = new nusoap_client('https://p1-acce.neurotech.com.br/dr/services/soap/porting?wsdl', 'wsdl');


$err = $client->getError();
if ($err) {
 echo '<h2>Constructor error</h2><pre>' . $err . '</pre>';
 echo '<h2>Debug</h2>';
 echo '<pre>' . htmlspecialchars($client->getDebug(), ENT_QUOTES) . '</pre>';
 exit();
}

       $param1         = '67'; //getvar('param1');

$dados = array(
  'CodigoAssociado' => $param1, 
  'CodigoFilial' => '',
  'Senha' => 'abcd@1234'
  ); 
$credenciais = array('Credenciais'=>$dados);

$result = $client->call('executarFluxoComParametros', array('Credenciais' => $credenciais),'http://neurotech.com.br/','',false,null,'document','literal');
echo $result;

$result = str_replace("&lt;","<",$result);
$result = str_replace("&gt;",">",$result);

echo array_complex_to_xml($result);

return;


?>
