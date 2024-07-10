/*{admcab.i}*/
{geraxml.i}  

def input parameter vEmpresa      as integer.
def input parameter vAgencia      as integer.
def input parameter vProduto      as integer.
def input parameter vLojista      as integer.
def input parameter vLoja         as integer.
def input parameter vPlano        as integer.
def input parameter vPrazo        as integer.
def input parameter vValorCompra  as decimal.
def input parameter vValorPMT     as decimal.
def input parameter vDiasParaPgto as integer.

def var varquivo as char.
def var mail-dest as char.
def var opc-dest as char.
def var vretorno as char.

def var p-valor  as char.

def output parameter vret-Empresa             as char.
def output parameter vret-Agencia             as char.
def output parameter vret-Lojista             as char.
def output parameter vret-Loja                as char.
def output parameter vret-Produto             as char.
def output parameter vret-Plano               as char.
def output parameter vret-Prazo               as char.
def output parameter vret-Emissao             as char.
def output parameter vret-PrimeiroVencimento  as char.
def output parameter vret-PMT                 as char.
def output parameter vret-ValorTAC            as char.
def output parameter vret-ValorTfc            as char.
def output parameter vret-Seguro              as char.
def output parameter vret-ValorIOF            as char.
def output parameter vret-ValorFinanciado     as char.
def output parameter vret-Taxa                as char.
def output parameter vret-Coeficiente         as char.
def output parameter vret-IRR                 as char.
def output parameter vret-ValorLiberar        as char.
def output parameter vret-CET                 as char.
def output parameter vret-CETAnual            as char.
def output parameter vret-PST                 as char.
def output parameter vret-TFC                 as char.
def output parameter vret-Tac                 as char.
def output parameter vret-ValorTotal          as char.

assign varquivo = "/u/bsweb/log/SimulacaoSicredi_"
                        + string(time,"HH:MM:SS")
                        + ".log".
                        
assign varquivo = replace(varquivo,":","_").                        
                        
output to value(varquivo).

geraxml("XML","","","").
geraxml("T1","","Simulacao","").
geraxml("T2","T2","Empresa",string(vEmpresa,">>99")).     
geraxml("T2","T2","Agencia",string(vAgencia,">>9999")).
geraxml("T2","T2","Produto",string(vProduto,">>999999")).
geraxml("T2","T2","Lojista",string(vLojista,">>999999")).
geraxml("T2","T2","Loja",string(vLoja,">>9999")).
geraxml("T2","T2","Plano",string(vPlano,">>9999")).
geraxml("T2","T2","Prazo",string(vPrazo,">>999")).
geraxml("T2","T2","ValorCompra",string(vValorCompra)).
geraxml("T2","T2","ValorPMT",string(vValorPMT)).
geraxml("T2","T2","DiasParaPgto",string(vDiasParaPgto)).
geraxml("","T1","Simulacao","").

output close.
                      
unix silent value("chmod 777 " + varquivo).


mail-dest = "laureano.noguez@linx.com.br".
opc-dest = "1".

run ws/p2k/progr/chama-ws-sicred.p(input vloja,
               input 1,
               input "SimulacaoSicredi",
               input "SimulacaoSicredi",
               input varquivo,
               input mail-dest,
               input opc-dest,
               input "1",
               input "1",
               output vretorno).


assign vret-Empresa            = ""
       vret-Agencia            = ""
       vret-Lojista            = ""
       vret-Loja               = ""
       vret-Produto            = ""
       vret-Plano              = ""
       vret-Prazo              = ""
       vret-Emissao            = ""
       vret-PrimeiroVencimento = ""
       vret-PMT                = ""
       vret-ValorTAC           = ""
       vret-ValorTfc           = ""
       vret-Seguro             = ""
       vret-ValorIOF           = ""
       vret-ValorFinanciado    = ""
       vret-Taxa               = ""
       vret-Coeficiente        = ""
       vret-IRR                = ""
       vret-ValorLiberar       = ""
       vret-CET                = ""
       vret-CETAnual           = ""
       vret-PST                = ""
       vret-TFC                = ""
       vret-Tac                = ""
       vret-ValorTotal         = "".


run le_xml.p(input vretorno, input "Empresa", output vret-Empresa).           
run le_xml.p(input vretorno, input "Agencia", output vret-Agencia).
run le_xml.p(input vretorno, input "Lojista", output vret-Lojista).
run le_xml.p(input vretorno, input "Loja", output vret-Loja).
run le_xml.p(input vretorno, input "Produto", output vret-Produto).
run le_xml.p(input vretorno, input "Plano", output vret-Plano).
run le_xml.p(input vretorno, input "Prazo", output vret-Prazo).
run le_xml.p(input vretorno, input "Emissao", output vret-Emissao).
run le_xml.p(input vretorno, input "PrimeiroVencimento", output vret-PrimeiroVencimento).
run le_xml.p(input vretorno, input "PMT", output vret-PMT).
run le_xml.p(input vretorno, input "ValorTAC", output vret-ValorTAC).
run le_xml.p(input vretorno, input "ValorTfc", output vret-ValorTfc).
run le_xml.p(input vretorno, input "Seguro", output vret-Seguro).
run le_xml.p(input vretorno, input "ValorIOF", output vret-ValorIOF).
run le_xml.p(input vretorno, input "ValorFinanciado", output vret-ValorFinanciado).
run le_xml.p(input vretorno, input "Taxa", output vret-Taxa).
run le_xml.p(input vretorno, input "Coeficiente", output vret-Coeficiente).
run le_xml.p(input vretorno, input "IRR", output vret-IRR).
run le_xml.p(input vretorno, input "ValorLiberar", output vret-ValorLiberar).
run le_xml.p(input vretorno, input "CET", output vret-CET).
run le_xml.p(input vretorno, input "CETAnual", output vret-CETAnual).
run le_xml.p(input vretorno, input "PST", output vret-PST).
run le_xml.p(input vretorno, input "TFC", output vret-TFC).
run le_xml.p(input vretorno, input "Tac", output vret-Tac).
run le_xml.p(input vretorno, input "ValorTotal", output vret-ValorTotal).

