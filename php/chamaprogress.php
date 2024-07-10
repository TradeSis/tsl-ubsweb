<?php

/*VERSAO 2 23062021*/

        include "progress_03.php";

        class chamaprogress extends progress
        {

                var $ws = "chamaprogress"; // Letra Minuscula por causa do progress

                function executarprogress($acao,$novaentrada,$dlc="/usr/dlc/",$pf="",$propath="",$progresscfg="",$tmp="/ws/works/",$proginicial)
                {

                        $this->progress($dlc,$pf,$propath,$progresscfg);

                        $this->parametro = "TERM!ws!acao!entrada!";

                      //  echo $propath;
                        $this->acao = $acao; // 09082022 helio -  para colocar como -param 

                        $this->parametros = "ansi!" . $this->ws . "!" . $acao . "!" . $novaentrada . "!";

                        $this->executa($proginicial);

                        return $this->progress;

                }

        }



?>
