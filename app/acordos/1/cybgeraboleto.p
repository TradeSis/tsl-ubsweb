/* #012023 helio onda 3 */
def new global shared var setbcod       as int.

{/admcom/progr/api/acentos.i} /* helio 14/09/2021 */
def input  parameter vlcentrada as longchar.
def var vlcsaida   as longchar.
def var vsaida as char.
def var hentrada as handle.
def var hsaida   as handle.

DEFINE VARIABLE lokJSON                  AS LOGICAL.



def var vtipo as char.
def var vstatus as char.
def var vmensagem_erro as char.

def var par-recid-boleto as recid.
def var vdtvencimento as date.

def var par-tabelaorigem as char.
def var par-chaveorigem as char.
def var par-dadosorigem as char.
def var par-valorOrigem  as dec.

def buffer bclien for clien.
def temp-table GeraBoletoEntrada serialize-name "GeraBoleto"
    field CNPJ_CPF as char
    field IDAcordo as char
    field NumeroParcela as char
    field Vencimento as char
    field Valor as char.

def temp-table ttboleto serialize-name "boleto"
    field Banco as char
    field Agencia as char
    field codigoCedente as char
    field contaCorrente as char
    field Carteira as char
    field nossoNumero   as char
    field DVnossoNumero as char
    field dtEmissao as char
    field dtVencimento as char
    field fatorVencimento as char
    field numeroDocumento as char
    field CNPJ_CPF as char
    field sacadoNome as char
    field sacadoEndereco as char
    field sacadoCEP as char
    field sacadoCidade as char
    field sacadoUF as char
    field linhaDigitavel as char
    field codigoBarras as char
    field VlPrincipal as char.



    assign
            vstatus = "S"
            vmensagem_erro = "".

vtipo = "NOV".
def temp-table ttsaida  no-undo serialize-name "conteudoSaida"
    field tstatus        as int serialize-name "status"
    field descricaoStatus      as char.


hEntrada = temp-table GeraBoletoEntrada:HANDLE.

lokJSON = hentrada:READ-JSON("longchar",vlcentrada, "EMPTY").
    
find first geraboletoEntrada no-error.
if avail GeraBoletoEntrada 
then do.
    find first clien where clien.ciccgc = GeraBoletoEntrada.cnpj_cpf
            no-lock no-error.
    if not avail clien
    then assign
            vstatus = "N"
            vmensagem_erro = "Cliente Nao Encontrado".

    if avail clien
    then do:
        find first CybAcordo where
            cybAcordo.idacordo = int(geraboletoEntrada.idacordo)
                no-lock no-error.
        if not avail cybacordo
        then do:
            vstatus = "N".
            vmensagem_erro = "Acordo " + geraboletoentrada.idacordo +
                             " nao existe.".
        end.
        else do:
            
            if cybacordo.tipo <> "" /* promessa */
            then vtipo = cybacordo.tipo.
            
            if cybacordo.clifor <> clien.clicod
            then do:
                find bclien where bclien.clicod = cybacordo.clifor
                    no-lock.
                vstatus = "N".
                vmensagem_erro = "Acordo " + geraboletoentrada.idacordo +
                             " eh do cliente " +
                             bclien.ciccgc + " " +
                             bclien.clinom.
            end.
            else do: 
             find first cybAcParcela of cybAcordo where
                 cybAcParcela.parcela = int(geraboletoEntrada.numeroparcela)
                 no-lock no-error.
             if not avail cybacParcela and not vtipo = "PRO"
             then do:
                 vstatus = "N".
                 vmensagem_erro = "Parcela " + geraboletoEntrada.numeroparcela +
                                 " Nao Existe no Acordo " +
                             geraboletoEntrada.idacordo.
             end.      
             else do:
                vdtvencimento = 
                    date(int(substr(geraboletoentrada.vencimento,1,2)),
                     int(substr(geraboletoentrada.vencimento,3,2)),
                     int(substr(geraboletoentrada.vencimento,5,4))). 
                if vdtvencimento < today
                then do:
                    vstatus = "N".
                    vmensagem_erro = "Vencimento ANTERIOR a Hoje " +
                            string(vdtvencimento,"99/99/9999").
                end.
                /**
                if cybacparcela.vlcobrado <> 
                        dec(geraboletoentrada.vlprincipal)
                then do:
                    vstatus = "N".
                    vmensagem_erro = "Valor da parcela eh " +
                            string(cybacparcela.vlcobrado,">>>>,>>9.99").
                end.
                **/
                
             end.
            end.    
        end.
    end.                                         

end.
else assign
        vstatus = "E"
        vmensagem_erro = "Parametros de Entrada nao recebidos.".


if vstatus = "S"
then do:
    if vtipo = "PRO" /* helio 16/11/2021 ID 92468 - Pagamento pendente boleto */
    then do: 
        find first  CSLpromessa of cybacordo no-lock no-error.
        if not avail cslpromessa
        then vtipo = "".
    end.    
    if vtipo <> "PRO"

    then do:
        par-tabelaorigem = "cybacparcela".
        par-chaveOrigem  = "idacordo,parcela".
        par-dadosOrigem  = string(cybacordo.idacordo) + "," +
                       string(cybacparcela.parcela).
        par-valorOrigem  = cybacparcela.vlcobrado + cybacparcela.vljuro. /* helio 0310 */
    
        find first banbolOrigem 
            where banbolorigem.tabelaOrigem = par-tabelaOrigem and
                  banbolorigem.chaveOrigem  = par-chaveOrigem and
                  banbolorigem.dadosOrigem  = par-dadosOrigem 
            no-lock no-error.
        if avail banBolOrigem
        then do:
            vstatus = "N".
            vmensagem_erro = "Boleto " + 
                            string(banbolorigem.nossonumero,"99999999")
                         + " ja foi emitido para esta solicitacao.".
            find banboleto of banbolOrigem no-lock.
            par-recid-Boleto = recid(banboleto).                         
        end.
    end.
end.



if vstatus = "S"
then do:
    vdtvencimento = date(int(substr(geraboletoentrada.vencimento,1,2)),
                     int(substr(geraboletoentrada.vencimento,3,2)),
                     int(substr(geraboletoentrada.vencimento,5,4))). 
    
    run bol/geradadosboleto.p (
                    input 104, /* Banco do Boleto */
                    input ?,      /* Bancarteira especifico */
                    input "CSlogBoleto",
                    input clien.clicod,
                    input replace(par-dadosOrigem,",","/"),
                    input vdtvencimento,
                    input dec(geraboletoentrada.valor),
                    input 0,
                    output par-recid-boleto,
                    output vstatus,
                    output vmensagem_erro).

    find banBoleto where recid(banBoleto) = par-recid-boleto no-lock
        no-error.
    if vstatus = "S" and avail banBoleto
    then do: 
    
        if banboleto.bancod = 104
        then do:
            run api/barramentoemitir.p 
                    (recid(banboleto),  
                        output vstatus , 
                        output vmensagem_erro).
        end. 

        if vstatus = "S"
        then do: 
    
            if vtipo = "PRO"
            then do:
                for each CSLpromessa of cybacordo no-lock.
                    par-tabelaorigem = "promessa".
                    par-chaveOrigem  = "idacordo,contnum,parcela".
                    par-dadosOrigem  = string(cybacordo.idacordo)   + "," +
                                   string(cslpromessa.contnum) + "," +
                                   string(cslpromessa.parcela) .
                    par-valorOrigem  = cslpromessa.vlcobrado + cslpromessa.vljuro. /* helio 0310 */
                    run bol/vinculaboleto.p (
                            input recid(banBoleto),
                            input par-tabelaorigem,
                            input par-chaveorigem,
                            input par-dadosorigem,
                            input par-valorOrigem,
                            output vstatus,
                            output vmensagem_erro).
                end.
            end.
            else do:
                run bol/vinculaboleto.p (
                        input recid(banBoleto),
                        input par-tabelaorigem,
                        input par-chaveorigem,
                        input par-dadosorigem,
                        input par-valorOrigem,
                        output vstatus,
                        output vmensagem_erro).
            end.
            do on error undo.
                find current banboleto exclusive.
                banboleto.situacao = "R". /* Registrado */
            end.
        end.    
    end.        
end.


if vstatus <> "S"
then do:
    create ttsaida.
    ttsaida.tstatus = 404.
    ttsaida.descricaoStatus = vmensagem_erro.
  
    hsaida  = temp-table ttsaida:handle.
  
    lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).
    message string(vlcSaida).
    return.
end.

if vstatus = "S"
then do: 
    find banBoleto where recid(banBoleto) = par-recid-boleto no-lock.
    find banco where banco.bancod = banboleto.bancod no-lock. 
    find banCarteira of banBoleto no-lock.

    create ttboleto.
    ttboleto.Banco           = string(banco.numban).
    ttboleto.Agencia         = string(banboleto.agencia).
    ttboleto.codigoCedente   = banCarteira.banCedente.
    ttboleto.contaCorrente   = string(banboleto.contacor).
    ttboleto.Carteira        = banboleto.banCart.
    ttboleto.nossoNumero     = banboleto.impnossonumero.
    ttboleto.DVnossoNumero   = string(banBoleto.DvNossoNumero).
    ttboleto.dtEmissao       = string(month(banboleto.dtemissao),"99") +
                              string(day(  banboleto.dtemissao),"99") +
                              string(year(banboleto.dtemissao ),"9999").
    ttboleto.dtVencimento    = string(month(banboleto.dtvencimento),"99") +
                              string(day(  banboleto.dtvencimento),"99") +
                              string(year(banboleto.dtvencimento ),"9999"). 
    ttboleto.fatorVencimento = string(banboleto.fatorVencimento,"9999").
    ttboleto.numeroDocumento = banboleto.Documento.
    ttboleto.CNPJ_CPF        = clien.ciccgc.
    ttboleto.sacadoNome      = removeacento(clien.clinom).
    ttboleto.sacadoEndereco  = removeacento(clien.endereco[1]).
    ttboleto.sacadoCEP       = string(clien.cep[1],"99999999").
    ttboleto.sacadoCidade    = removeacento(string(clien.cidade[1])).
    ttboleto.sacadoUF        = string(clien.uf[1]).
    ttboleto.linhaDigitavel  = banboleto.linhaDigitavel.
    ttboleto.codigoBarras    = banboleto.codigoBarras.
    ttboleto.VlPrincipal     = trim(string(banboleto.vlCobrado,">>>>>>>9.99")).

end.



hSaida = temp-table ttboleto:HANDLE.


def var varquivo as char.
def var ppid as char.
INPUT THROUGH "echo $PPID".
DO ON ENDKEY UNDO, LEAVE:
IMPORT unformatted ppid.
END.
INPUT CLOSE.

varquivo  = "/u/bsweb/works/apiacordoscybgeraboleto" + string(today,"999999") + replace(string(time,"HH:MM:SS"),":","") +
          trim(ppid) + ".json".

lokJson = hsaida:WRITE-JSON("FILE", varquivo, TRUE).
if lokJson
then do:
    os-command value("cat " + varquivo).
    os-command value("rm -f " + varquivo).
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



