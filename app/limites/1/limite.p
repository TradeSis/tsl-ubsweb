/*VERSAO 2 23062021*/


def input  parameter vlcentrada as longchar.
def var vlcsaida   as longchar.

run api/calculalimites.p (input vlcentrada, output vlcsaida).

put unformatted string(vlcsaida).
