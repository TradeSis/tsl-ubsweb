<?php
$entrada=$argv[1];
$saida=$argv[2];

$temporario = fopen($entrada.".X.xml","w");
$ok = "";
$handle = fopen($entrada, "r");
    while (($line = fgets($handle)) !== false) {
	if (trim(substr($line,1,5)) == "?xml" ) {
		$ok = "OK";
	}
	if ( $ok == "OK" ) {
            fwrite($temporario,$line);
	}
    }
    fclose($handle);
fclose($temporario);

$xml = simplexml_load_file($entrada.".X.xml");

$pdf = $xml->dados->binario_pdf;

$base64 = $pdf /* some base64 encoded data fetched from somewhere */;
$binary = base64_decode($base64);
file_put_contents($saida, $binary);

system("chmod 777 " . $saida)

?>
