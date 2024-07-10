<?php 
    
    include ("/u/bsweb/progr/php/funcoes_v1701.inc");


    $json       = file_get_contents('php://input');
    $results    = json_decode($json, true);

    include ("eistoadm.php");
    
    $entrada = "<?xml version='1.0' encoding='UTF-8' ?><conteudo><controle></controle>";
    foreach($results[1] as $key => $value){
        $entrada.="<metafil>";
        $entrada.="<etb>".$value['etb']."</etb>";
        $entrada.="<ano>".$value['ano']."</ano>";
        $entrada.="<mes>".$value['mes']."</mes>";
        $entrada.="<dia>".$value['dia']."</dia>";
        $entrada.="<segmetmov>".$value['segmetmov']."</segmetmov>";
        $entrada.="<segmetmod>".$value['segmetmod']."</segmetmod>";
        $entrada.="<garmet>".$value['garmet']."</garmet>";
        $entrada.="<rfqmet>".$value['rfqmet']."</rfqmet>";
        $entrada.="</metafil>";
    }
    $entrada.="</conteudo>";
    
    $eistoadm = new eistoadm(); 
    $array = $eistoadm->executarprogress("metafil",$entrada); 
    
    echo $array;
    
?>
