
	var dataNeuProposta = [];
	//var dataVenda   = [];
	
	// DEFINICAO DA GRID DE CLIENTES	
	var gridCliente = {
		id: "gridCliente",
		view: "datatable",
		//borderless: true,
		//autoheight:true,
		fixedRowHeight:false ,  
		//rowLineHeight:100, rowHeight:100,

		
		columns:[
	    	 { id:"ETBCOD",	 width:50, header:"Lj" ,  	 template: "#ETBCOD#" }
	    	,{ id:"DATA",	width:90, header:["Data", {content:"selectFilter"}], sort:"string", 	 template: "#DATA#" }
	    	,{ id:"HORA",	width:70, header:"Hora", sort:"string", 	 template: "#hrinclu#" }
	    	,{ id:"CPF",	width:100, header:["CPF", {content:"selectFilter"}], sort:"string", 	 template: "#CPF#" }
			,{ id:"CLICOD",	header:["Codigo", {content:"selectFilter"}], sort:"string",template: "#CLICOD#"}
			,{ id:"NOME_PESSOA",	header:["Cliente", {content:"selectFilter"}],adjust:"data", sort:"string", template: "#NOME_PESSOA#"}
	    	,{ id:"ETBCAD",	width:50, header:["Lj_Cad", {content:"selectFilter"}], sort:"string", 	 template: "#ETBCAD#" }
			,{ id:"SIT_CREDITO", width:50,	header:["Sit", {content:"selectFilter"}], sort:"string",  template: "#SIT_CREDITO#" }
			,{ id:"VCTOLIMITE",	header:"Vcto_Limite", template: "#vctolimite#"}
			,{ id:"VLRLIMITE",	header:"Limite", template: "#vlrlimite#"}
			,{ id:"TIPOCONSULTA",	header:["TC", {content:"selectFilter"}], template: "#tipoconsulta#" , css:{'text-align':'right'} , adjust:"data"}			
			,{ id:"NEU_CDOPERACAO",	header:"Operacao", template: "#neu_cdoperacao#", adjust:"data"}
			,{ id:"NEU_RESULTADO",	header:"Resultado", template: "#neu_resultado#",	adjust:"data", css:{'text-align':'right'} }
			
		],
		select: "row",
//		autoheight:true,
		data: dataNeuProposta
		,footer:false,
						multiselect:false
			,on:{
						onItemClick:function(id){

							record = this.getItem(id);
							vcliente = record.cpfcnpj;
							
//alert(JSON.stringify(record.neu_cdoperacao, null, 4));



							showForm("win2");
							
//							if (id.column == "XXXFOTO_CLIENTE") {
						}
							
/**					,onSelectChange:function(){
					
						
						
						//filterText(record.VENDEDOR);

					} **/
				}

	};

