<?php 
// functions.php


// helio 26042023 - funcoes padrão
function defineCaminhoLog() {
  $pasta = null;
  if (defined('LOG_CAMINHO')) {
    $pasta = LOG_CAMINHO;
  }
	return $pasta;
}

function defineNivelLog() {
  $nivel = null;
  if (defined('LOG_NIVEL')) {
    $nivel = LOG_NIVEL;
  }
	return $nivel;
}

function defineConexaoApi () {
    return API_IP;
  } 
  
  function defineConexaoMysql () {
  
      return        array(   "host" => MYSQL_HOST, 
                             "base" => MYSQL_BASE,
                          "usuario" => MYSQL_USUARIO, 
                          "senhadb" => MYSQL_SENHADB
                              );
  
  }
  
  function defineEmail () {
  
    return        array(  "Host"      => EMAIL_HOST, 
                          "Port"      => EMAIL_PORT, 
                          "Username"  => EMAIL_USERNAME,
                          "Password"  => EMAIL_PASSWORD,
                          "from"      => EMAIL_FROM,
                          "fromNome"  => EMAIL_FROMNOME
                            );
  
  }
  
  function defineSenderWhatsapp () {
  
    return        array(  'api_key' => WHATS_APIKEY, 
                          'sender' => WHATS_SENDER
                            );
  
  }


function defineConexaoProgress()
{
  
  return        array(    "progresscfg" => PROGRESS_CFG, 
                          "dlc"         => PROGRESS_DLC,
                          "pf"          => PROGRESS_PF, 
                          "tmp"         => PROGRESS_TMP,
                          "propath"     => PROGRESS_PROPATH,
                          "proginicial" => PROGRESS_PROGRINICIAL
   );

}

?>