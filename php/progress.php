<?php
class progress {

        var $parametro="";
        var $parametros="";
	var $saida="";
	var $dlc="";
 	var $progresscfg="progress.cfg";
	var $tmp=".";
	var $pf="";
	var $propath="";
	var $progress="";
	var $fetcharray = array();
	var $simplearray = array();

	function progress($dlc,$pf,$propath,$progresscfg,$tmp="/u/bsweb/works/"){
		$this->dlc=$dlc;
		$this->progresscfg=$progresscfg;
		$this->pf=$pf;
		$this->propath=$propath;
		$this->tmp=$tmp;
	}


        function montaacha($nome,$dado,$sep="=")
        {
        	if ("$sep" == "=") {
                	return "$nome=" . $dado . "|" ;
                  } else {
                       return "$nome$sep" . $dado . "#" ;
                }
        }

        
        function toprogress ($campo,$tipo="")
        {
            $saida =  $campo;
                    if ("$tipo" == "char") {
                        return "\"".$saida."\""." ";
                    } else {
                        if ("$tipo" == "fim") {
                           return "\n";
                        } else {
                            return $saida." ";
                          }
                     }
        }

        function ambiente() {

                   putenv("DLC=$this->dlc");
		   putenv("PROCFG=$this->dlc."/".$this->progresscfg");
                   putenv("PROPATH=$this->propath");

            while (list($k, $v) = each ($_ENV)) {
                        if ($v=="") {  putenv("$k=!"); } 
                        else { putenv("$k=$v"); }
                }
                while (list($k, $v) = each ($_POST)) {
                        if ($v=="") { putenv("$k=!"); } 
                        else { putenv("$k=$v"); }
                }
                while (list($k, $v) = each ($_GET)) {
                        if ($v=="") { putenv("$k=!"); } 
                        else { putenv("$k=$v"); }
               }
            while (list($k, $v) = each ($_SERVER)) {
                putenv("$k=$v");
            }

            $arrayparametro  = explode("!",$this->parametro);
            $arrayparametros = explode("!",$this->parametros);
            for ( $i = 0; $i < count ($arrayparametro); $i++) { 
	         $k = trim( $arrayparametro[$i] );  
		 $v = trim( $arrayparametros[$i] );
		 putenv("$k=$v");
		 if ("$k" == "saida") {
			$this->saida=$v;
                 }
	    } 

        } // ambiente
        
        function executa ($executa) {
        
            $this->ambiente();
	    $proexe = "$this->dlc/bin/_progres";
            
            $command = $proexe . " " . " -h 12 -T " . $this->tmp . " -pf " . $this->pf . " -b -p " . $executa ;

            $CMD="$command";

            // Executa Progress...
            $handle = popen ("$CMD", "r");
            $this->progress = "";
            do {
                    $data = fread($handle, 8192);
                    if (strlen($data) == 0) {
                        break;
                    }
                    $this->progress .= $data;
            } while(true);
            fclose ($handle);
	 
        } // executa
}
?>
