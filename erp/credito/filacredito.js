
		// VARIAVEIS DE TODO O ESCOPO
		var vphoto = '';

		var today = new Date();
		today.setDate(today.getDate());
		
		//var ddi = '01';
		var ddf = today.getDate();
		var ddi = ddf;
		
		var mmi = today.getMonth()+1; 
		var yyi = today.getFullYear();
		var mmf = mmi;
		var yyf = yyi;
		
		var hoje = new Date(yyi, mmi, ddi); 
		
		var vpor = '';
		var vphp = '';
		var vfilial = '';

		var json = [];
		var json_filial = [];
		var json_vendedor = [];
		var vcliente = '';
		var record = [];
		
	//  MONTAGEM DA VIEW PRINCIPAL		
	var views = {
			id:"main",  
			rows:[
					{ view:"toolbar" , id:"top", elements:[
						{view:"text", id:"FILIAL", label:'Filial', width:240,  labelAlign:"right" , suggest:"/bsweb/erp/zoom/estab.php"},
//						{view:"text", id:"VENDEDOR", label:'Vendedor', width:240,  labelAlign:"right"  },
//						{view:"datepicker", id:"dti",  align: "right",  editable:true	},
//						{view:"datepicker", id:"dtf", align: "right",  editable:true	},
						{view:"button", id:"botao_pesquisar", type:"iconButton", label:"Pesquisar",  icon:"search"},
						{view:"button", id:"botao_imprimir", type:"iconButton", label:"Imprimir",  icon:"print"},
						{view:"button", id:"botao_email", type:"iconButton", label:"Excel",  icon:"envelope"}
					]}, //toolbar
					gridCliente
					
				]}; // view
	
	// MONTAGEM DA UI PRINCIPAL
	var ui = {
			rows:[{ type: "wide", 
			        cols:[views]}
				]
			};

       
	// CHAMA WEBIX			
	webix.ready(function(){

		// SETA WEBIX PARA BR
		webix.i18n.setLocale("pt-BR");
		// ATIVA UI			
		webix.ui(ui);
		
		// SETA DATA INICIAL	
/**
		$$("dti").setValue(yyi+'/'+mmi+'/'+ddi);	
		$$("dtf").setValue(yyf+'/'+mmf+'/'+ddf);	
**/
		// PESQUISA POR UMA FILIAL PADRAO, SE EXISTIR JÁ SETA	

		vjson_filial = chamaESTAB('/bsweb/erp/zoom/estab.php?POR=MEUIP');


		vfilial = vjson_filial.value;	
		//for (var i = 0; i < vjson_filial.length; i++) {
			//vfilial = vjson_filial[i].value;
		//}
		$$("FILIAL").setValue(vfilial);	

		// QUANDO CLICA NO BOTAO PESQUISAR	
		$$("botao_pesquisar").attachEvent("onItemClick", function(id, e){
//			vdti = $$("dti").getText();
//			vdtf = $$("dtf").getText();


			var vgridCliente = $$("gridCliente");
			
			webix.extend(vgridCliente, webix.ProgressBar);
						//using the functionality
			vgridCliente.showProgress({
					//type:"bottom",
					delay:3000,
					hide:false
			});

			vgridCliente.clearAll();
			vgridCliente.showOverlay("Aguarde...");
			dataCliente = chamaPHP('JSON');
			vgridCliente.parse(dataCliente);
			vgridCliente.hideOverlay();
			// MONTA O FRAME -> chamaPHP('');
		});

		// QUANDO CLICA NO BOTAO EMAIL		
		$$("botao_email").attachEvent("onItemClick", function(id, e){
			var vexcel = $$("gridCliente");
			vexcel.exportToExcel();
		});
		
		// QUANDO CLICA NO BOTAO IMPRIMIR		
		$$("botao_imprimir").attachEvent("onItemClick", function(id, e){
			var vexcel = $$("gridCliente");
			vexcel.exportToPDF();
		});
		
		// ZOOM DE VENDEDOR
/**		webix.ui({
			view: "suggest",
			input: $$("VENDEDOR"),
			body: {
				dataFeed: function (text) {
					this.load('../zoom/vendedor.php?FILIAL='+vfilial+"&filter[value]="+text);
				}
			}
		});
**/
		// QUANDO ALTERA A FILIAL
		$$("FILIAL").attachEvent("onChange", function(newv, oldv) {
			vfilial = newv; 
			webix.message("Selecao de: "+oldv+" para: "+newv);
			//chamaPHP();
			//$$('frame-body').define("src", "");
		});
		
});

		
