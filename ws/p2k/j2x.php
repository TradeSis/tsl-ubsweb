<?php

function xml_encode($mixed, $header = true, $domElement = null, $DOMDocument = null)
{
 if  (is_null($DOMDocument))  { //Cria o objeto
 
  $DOMDocument = new DOMDocument("1.0", "UTF-8");
  $DOMDocument->formatOutput = true;
  xml_encode($mixed,$header,$DOMDocument,$DOMDocument);
  
  // Retira a declaraç do header do XML $header = 'false'
  return ($header)? $DOMDocument->saveXML() : $DOMDocument->saveXML($DOMDocument->documentElement); 
  
 }  else  { // Popula
  
  if  (is_array($mixed))  {
  
   foreach  ($mixed as $index => $mixedElement)  {
    if  (is_int($index))  {
     
     if  ($index == 0)  {
      $node = $domElement;
     }  else  {
      $node = $DOMDocument->createElement($domElement->tagName);
      $domElement->parentNode->appendChild($node);
     }
     
    }  else  {
    
     $plural = $DOMDocument->createElement($index);
     $domElement->appendChild($plural);
     $node = $plural;
     
     if  (rtrim($index,'') !== $index)  {
      $singular = $DOMDocument->createElement(rtrim($index,''));
      $plural->appendChild($singular);
      $node = $singular;
     }
     
    }
    
    xml_encode($mixedElement,$header,$node,$DOMDocument);
   }
   
  }  else  {
   
   $domElement->appendChild($DOMDocument->createTextNode($mixed)); // Indere o valor dentro da tag
   
  }
  
 }
}


$data = Array(
 'conteudo' => Array(
  'item' => Array(
   Array(
    'nome' => 'a'
   ),
   Array(
    'nome' => 'b'
   )
  )
 )
);

echo xml_encode($data);
?>

