<?php
/* medico na tela 042022 - helio */
/* helio 03012022 api seguro prestamista */
/*VERSAO 2 23062021*/

//header
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

header("Access-Control-Allow-Methods: GET,POST,PUT,DELETE");
header("Access-Control-Max-Age: 3600");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

function retornaheader($code) {
    if (isset($code)) {
        switch ($code) {
               case 200: $text = 'OK';
                   break;
               case 201: $text = 'Created';
                   break;
               case 202: $text = 'Accepted';
                   break;
               case 203: $text = 'Non-Authoritative Information';
                   break;
               case 204: $text = 'No Content';
                   break;
               case 205: $text = 'Reset Content';
                   break;
               case 206: $text = 'Partial Content';
                   break;
               case 300: $text = 'Multiple Choices';
                   break;
               case 301: $text = 'Moved Permanently';
                   break;
               case 302: $text = 'Moved Temporarily';
                   break;
               case 303: $text = 'See Other';
                   break;
               case 304: $text = 'Not Modified';
                   break;
               case 305: $text = 'Use Proxy';
                   break;
               case 400: $text = 'Bad Request';
                   break;
               case 401: $text = 'Unauthorized';
                   break;
               case 402: $text = 'Payment Required';
                   break;
               case 403: $text = 'Forbidden';
                   break;
               case 404: $text = 'Not Found';
                   break;
               case 405: $text = 'Method Not Allowed';
                   break;
               case 406: $text = 'Not Acceptable';
                   break;
               case 407: $text = 'Proxy Authentication Required';
                   break;
               case 408: $text = 'Request Time-out';
                   break;
               case 409: $text = 'Conflict';
                   break;
               case 410: $text = 'Gone';
                   break;
               case 411: $text = 'Length Required';
                   break;
               case 412: $text = 'Precondition Failed';
                   break;
               case 413: $text = 'Request Entity Too Large';
                   break;
               case 414: $text = 'Request-URI Too Large';
                   break;
               case 415: $text = 'Unsupported Media Type';
                   break;
               case 500: $text = 'Internal Server Error';
                   break;
               case 501: $text = 'Not Implemented';
                   break;
               case 502: $text = 'Bad Gateway';
                   break;
               case 503: $text = 'Service Unavailable';
                   break;
               case 504: $text = 'Gateway Time-out';
                   break;
               case 505: $text = 'HTTP Version not supported';
                   break;
               default:
                   exit('Unknown http status code "' . htmlentities($code) . '"');
                   break;
           }

           $protocol = (isset($_SERVER['SERVER_PROTOCOL']) ? $_SERVER['SERVER_PROTOCOL'] : 'HTTP/1.0');
           header($protocol . ' ' . $code . ' ' . $text);
           $GLOBALS['http_response_code'] = $code;
       } else {
           $code = (isset($GLOBALS['http_response_code']) ? $GLOBALS['http_response_code'] : 200);
       }

       return $code;
   }

function pegaparam($varname) {
        $v=(isset($_GET[$varname]))?$_GET[$varname]:((isset($_POST[$varname]))?$_POST[$varname]:'');
        //if(!$v) $v = $_SESSION[$varname];
        //else $_SESSION[$varname] = $v;
        return($v);
}

//header
$aplicacao = null;
$funcao    = null; //Param

$metodo    = $_SERVER["REQUEST_METHOD"]; //POST, PUT, DELETE and GET
$uri       = $_SERVER["REQUEST_URI"];
$data      = null;

$versao   = pegaparam("versao");
$log      = pegaparam("log");


$uri_parse = parse_url($uri,PHP_URL_PATH);

$conteudoEntrada  = file_get_contents('php://input');

$jsonEntrada = json_decode($conteudoEntrada, TRUE); // Transforma um texto formato json, numa array json

//$data = array($conteudoEntrada);
//parse_str($conteudoEntrada,$data);

$unsetCount = 3; 
/**/
//TRATA A URI

$ex = explode("/", $uri_parse);

for($i = 0; $i < $unsetCount; $i++){
   
   unset($ex[$i]);
}
// Versionamento
$ex = array_filter(array_values($ex));


if (substr($ex[0], 0, 2) == 'V.' || substr($ex[0], 0, 2) == 'v.') { // alterado para substring
    
    $versao = substr($ex[0], 2, strlen($ex[0]));
    unset($ex[0]);
}


$ex = array_filter(array_values($ex));


if(isset($ex[0])){
  $aplicacao = $ex[0];
}
if(isset($ex[2])){
  $funcao = $ex[2];
  if(isset($ex[3])){
    $funcao = $funcao."/".$ex[3];
  } 
  if(isset($ex[4])){
    $funcao = $funcao."/".$ex[4];
  } 

}

if(isset($ex[1])){
  $parametro = $ex[1];
}

/**/
$hml=false;
if ($_SERVER['SERVER_ADDR']=="10.145.0.233"||$_SERVER['SERVER_ADDR']=="10.145.0.44") {
  $hml = true;
}

/*
echo 'host='.$_SERVER['SERVER_ADDR']."\n";
echo "aplicacao=".$aplicacao."\n";
echo "versao=".$versao."\n";
echo "funcao=".$funcao."\n";
echo "parametro=".$parametro."\n";
echo "metodo=".$metodo."\n";
echo "log=".$log."\n";
echo "hml=".$hml."\n";
*/

switch ($aplicacao) {
   case "boleto":
         include "../app/boleto/versao.php";
         break;

   case "cliente":
         include "../app/cliente/versao.php";
         break;

   case "limites":
         include "../app/limites/versao.php";
         break;

   case "produto":
         include "../app/produto/versao.php";
         break;

   case "etiqueta":
         include "../app/etiqueta/versao.php";
         break;

   case "seguro": /* inicio 17/08/2021 */
         include "../app/seguro/versao.php";
         break;

   case "sicred": /* inicio 05/10/2021 */
         include "../app/sicred/versao.php";
         break;

   case "prestamista": /* helio 03012022 api seguro prestamista */ /* inicio 06/01/2022 */
    include "../app/prestamista/versao.php";
    break;

    case "protesto": /* 05012022 helio iepro */ /* inicio 11/01/2022 */
        include "../app/protesto/versao.php";
        break;

    case "pdv": /* 25012022 helio API PDV  */ /* inicio 25/01/2022 */
    include "../app/pdv/versao.php";
    break;

    case "medico": /* medico na tela 042022 - helio */
        include "../app/medico/versao.php";
        break;

    case "acordos": /* acordo online 082022 - helio */
        include "../app/acordos/versao.php";
        break;

    case "bau": /* bau 082022 - helio */
        include "../app/bau/versao.php";
        break;
        
    case "lojas": /* reversa 092022 - helio */
        include "../app/lojas/versao.php";
        break;

    case "varejo": /* helio 022023 insert nop crediario admcom */
        include "../app/varejo/versao.php";
        break;

    case "serasa": /* lucas 02092024 inicio */
        include "../app/serasa/versao.php";
        break;
    
           
   default:
   $jsonSaida = json_decode(json_encode(
      array("status" => 400,
            "retorno" => "Aplicacao ".$aplicacao." Invalida")
          ), TRUE);
      break;
}


// Pega Saida



if ($log=="true") {
  echo json_encode(
      array("api" => array("tipo" => $metodo ,       // transforma um array , num texto formatado em json
                    "URI"  => $uri,
                    "Uri_Parse"=>$uri_parse,
                    "aplicacao" =>$aplicacao ,
                    "versao" => $versao ,
                    "funcao" => $funcao ,
                    "parametro" => $parametro ,
                    "jsonEntrada" => $jsonEntrada
                    //,"jsonSaida" => $jsonSaida

                  ),
             "return" => $jsonSaida)) ;
} else {
    if (isset($jsonSaida)){

    if ($aplicacao === "serasa") {
            /* exemplo para tratar por funcao a saida 422 direto no index.php
            if ($funcao == "ofertas") {

            }
            */
            if (isset($jsonSaida["status"])) {
                //echo "\nstatus="."-".$jsonSaida["status"]."\n";
                retornaheader($jsonSaida["status"]);
                unset($jsonSaida['status']);
            }
            if (!isset($jsonSaida["descricaoStatus"])) {
                //echo "\nstatus="."-".$jsonSaida["status"]."\n";
                unset($jsonSaida['descricaoStatus']);
            }
        
        echo json_encode($jsonSaida)."\n";
    }
    else {
        if (isset($jsonSaida->status)) {
            //echo "\nstatus=".$jsonSaida->status."-"."\n";
            retornaheader($jsonSaida->status);
        }
        if (isset($jsonSaida["status"])) {
            //echo "\nstatus="."-".$jsonSaida["status"]."\n";
            retornaheader($jsonSaida["status"]);
        }
        echo json_encode($jsonSaida)."\n";

      }
   } 
}

?>
