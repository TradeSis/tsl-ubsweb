	
	// DEFINICAO DA FUNCAO PARA ABRIL MODAL COM NOVO FORM
    function showForm(winId, node){
			
		
			var form = {
				view:"form",
				borderless:true,
				width:1050,
				height:550,
				elements: [
					{
						 
						view:"iframe", id:"frame-body", src:"https://painel-prd.neurotech.com.br/carregarPainel?cdAssociado=5yeBcNWTlOk=&senha=dFydHiTa7rU=&cdOperacao="+record.neu_cdoperacao
						
					},
					{ view:"button", value: "Fechar", click:function(){
					    this.getTopParentView().hide(); //hide window
						}
					}
					
				]
			};

			webix.ui({
				view:"window",
				id:"win2",
				//width:1200,
				//height:800,
				position:"center",
				modal:true,
				// head:"User's data",
				body:webix.copy(form)
			});
		
            $$(winId).getBody().clear();
            $$(winId).show(node);
            $$(winId).getBody().focus();
        
		}

		function img(obj){
			return "<img src='/bsweb/imagens/clientes/"+obj.src+".jpg' class='content' ondragstart='return false'/>"
		}

