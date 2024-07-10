<?php
	// progress.php 
  
    include "progress_class.php";
    
    class chamaprogress extends progress
    {

            var $ws = "chamaprogress"; // Letra Minuscula por causa do progress
         
            function executarprogress($acao,$novaentrada)
            {
                  
                    $dadosConexao = defineConexaoProgress();
                    $progresscfg    = $dadosConexao['progresscfg'];
                    $dlc            = $dadosConexao['dlc'];
                    $pf             = $dadosConexao['pf'];
                    $tmp            = $dadosConexao['tmp'];
                    $propath        = $dadosConexao['propath'];
                    $proginicial    = $dadosConexao['proginicial'];

                 
                                        
                    $this->progress($dlc,$pf,$propath,$progresscfg,$tmp);

                    $this->parametro = "TERM!ws!acao!entrada!tmp!";

                    //  echo $propath;
                    $this->acao = $acao; // 09082022 helio -  para colocar como -param 

                    $this->parametros = "ansi!" . $this->ws . "!" . $acao . "!"  . $novaentrada . "!" . $tmp . "!";
                  
                    $this->executa($proginicial);

                    return $this->progress;

            }

    }
    
    
?>