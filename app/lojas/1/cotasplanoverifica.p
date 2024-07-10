/* 202309 helio cotas por cluster */
/* #042023 helio libera plano */

def input  parameter vlcentrada as longchar.
def var vlcsaida   as longchar.
def var vsaida as char.
def var hentrada as handle.
def var hsaida   as handle.

def temp-table ttentrada serialize-name "dadosEntrada" 
    field codigoFilial   as int
    field codigoPlano    as int.

def var vok as log.

{/admcom/progr/api/acentos.i}

{/admcom/progr/acha.i}
{/admcom/barramento/functions.i}


DEFINE VARIABLE lokJSON                  AS LOGICAL.

def temp-table ttfincotaetb serialize-name "return" 
    field codigoFilial   as int
    field fincod        as int
    field dtivig        as date
    field dtfvig        as date
    field cotaslib      as int
    field cotasuso      as int    
    field planobloqueio   as char /* 0= liberado / 1 = Bloqueio / 2= senha gerente */
    field mensagem   as char.

def temp-table ttsaida  no-undo serialize-name "conteudoSaida"
    field tstatus        as int serialize-name "status"
    field descricaoStatus      as char.

def var vetbcod as int.
def var vfincod    as int.
def var vplanoBloqueio as char.
def var vmensagem as char.
hEntrada = temp-table ttentrada:HANDLE.
lokJSON = hentrada:READ-JSON("longchar",vlcentrada, "EMPTY").


find first ttentrada no-error.


if not avail ttentrada
then do:
  create ttsaida.
  ttsaida.tstatus = 400.
  ttsaida.descricaoStatus = "Sem dados de Entrada".

  hsaida  = temp-table ttsaida:handle.

  lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).
  message string(vlcSaida).
  return.

end.

vetbcod = int(ttentrada.codigoFilial).
find estab where estab.etbcod = vetbcod  no-lock no-error.
if not avail estab
then do:

  create ttsaida.
  ttsaida.tstatus = if locked estab  then 500 else 404.
  ttsaida.descricaoStatus = "Estabelecimento de origem " + string(ttentrada.codigoFilial)
                 + " Não encontrado.".

  hsaida  = temp-table ttsaida:handle.

  lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).
  message string(vlcSaida).
  return.

end.

vfincod = int(ttentrada.codigoPlano).
find finan where finan.fincod = vfincod no-lock no-error.
if not avail finan
then do:

  create ttsaida.
  ttsaida.tstatus = if locked finan then 500 else 404.
  ttsaida.descricaoStatus = "plano " + string(ttentrada.codigoPlano) 
                 + " Não encontrado.".

  hsaida  = temp-table ttsaida:handle.

  lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).
  message string(vlcSaida).
  return.

end.
find first ttentrada.

vplanobloqueio = "0".
vmensagem = "".

create ttfincotaetb.
ttfincotaetb.codigoFilial = ttentrada.codigoFilial.
ttfincotaetb.fincod = ttentrada.codigoPlano.

/* Contagem por Cluster */
find fincotaclplan where fincotaclplan.fincod = int(ttfincotaetb.fincod) no-lock no-error.
if avail fincotaclplan
then do: 
        find fincotacluster of fincotaclplan no-lock. 
        find fincotacllib  where 
                fincotacllib.fcccod = fincotacluster.fcccod and  
                fincotacllib.etbcod = int(ttentrada.codigoFilial) and 
                fincotacllib.dtivig <= today and
               (fincotacllib.dtfvig >= today or 
                fincotacllib.dtfvig = ?) 
                     no-lock no-error.            
        if avail fincotacllib
        then do:              
            ttfincotaetb.cotasuso = 0.
            for each fincotaclplan of fincotacluster no-lock.
                for each fincotaetb where 
                    fincotaetb.etbcod = fincotacllib.etbcod and
                    fincotaetb.fincod = fincotaclplan.fincod and
                    fincotaetb.dtivig = fincotacllib.dtivig and
                    fincotaetb.dtfvig = fincotacllib.dtfvig 
                    no-lock.
                    ttfincotaetb.cotasuso = ttfincotaetb.cotasuso + fincotaetb.cotasuso.
                end.
            end.              
            ttfincotaetb.dtivig       = fincotacllib.dtivig.
            ttfincotaetb.dtfvig       = fincotacllib.dtfvig.
            ttfincotaetb.cotaslib     = fincotacllib.cotaslib.

            if ttfincotaetb.cotasuso + 1 > fincotacllib.cotaslib
            then do:
                vplanobloqueio = "1".
                vmensagem = "Plano bloqueado por politica de cotas, cluster " + fincotacluster.fccnom + "!".
            end.
            else do:
               vplanobloqueio = "2".
               vmensagem = "Restam " + string(fincotacllib.cotaslib - ttfincotaetb.cotasuso) + 
                " cotas disponiveis no cluster " + fincotacluster.fccnom + " " +
                chr(10) + " Solicite ao gerente autorizar por senha.".
            end.
            
        end.
            
end.
else do:
    find last fincotaetb where 
        fincotaetb.etbcod = int(ttentrada.codigoFilial) and
        fincotaetb.fincod = int(ttentrada.codigoPlano) and
        fincotaetb.dtivig <= today and
        (fincotaetb.dtfvig >= today or fincotaetb.dtfvig = ?) and
        fincotaetb.ativo = yes
        no-lock no-error.
    if avail fincotaetb
    then do:
        ttfincotaetb.dtivig       = fincotaetb.dtivig.
        ttfincotaetb.dtfvig       = fincotaetb.dtfvig.
        ttfincotaetb.cotaslib     = fincotaetb.cotaslib.
        ttfincotaetb.cotasuso     = fincotaetb.cotasuso.
  
        if fincotaetb.cotasuso + 1 > fincotaetb.cotaslib
        then do:
          vplanobloqueio = "1".
          vmensagem = "Plano bloqueado por politica de cotas!".
        end.
        else do:
           vplanobloqueio = "2".
           vmensagem = "Restam " + string(fincotaetb.cotaslib - fincotaetb.cotasuso) + 
            " cotas disponiveis. " + chr(10) + " Para utilizar este    plano, solicite ao gerente autorizar por senha.".
        end.
    end.        
end.

ttfincotaetb.planobloqueio = vplanobloqueio.
ttfincotaetb.mensagem      = vmensagem.

hSaida = temp-table ttfincotaetb:HANDLE.

lokJson = hSaida:WRITE-JSON("LONGCHAR", vlcsaida, TRUE) no-error.
if lokJson
then do:
        put unformatted trim(string(vlcsaida)).
end.
else do:
    create ttsaida.
    ttsaida.tstatus = 500.
    ttsaida.descricaoStatus = "Erro na Geração do JSON de SAIDA".

    hsaida  = temp-table ttsaida:handle.

    lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).
    message string(vlcSaida).
    return.
end.
