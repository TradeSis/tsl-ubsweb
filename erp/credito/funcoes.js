	function chamaPHP (vsaida) {
			

/**
			vdti = $$("dti").getText();
			var ss = (vdti.split('/'));
			yyi = ss[2]; // parseInt(ss[2],10);
			mmi = ss[1]; //parseInt(ss[1],10);
			ddi = ss[0]; //parseInt(ss[0],10);

			vdtf = $$("dtf").getText();
			var ss = (vdtf.split('/'));
			yyf = ss[2]; // parseInt(ss[2],10);
			mmf = ss[1]; //parseInt(ss[1],10);
			ddf = ss[0]; //parseInt(ss[0],10);
**/
			
			vfilial = $$("FILIAL").getValue();
/**
			vvendedor = $$("VENDEDOR").getValue();
**/
			
			//alert('FILIAL='+vfilial+' VENDEDOR='+vvendedor)
/**			vphp = '/bsweb/erp/neurotech/neuproposta.php?SAIDA='+vsaida+'&POR=VENDEDOR&FILIAL='+vfilial+'&VENDEDOR='+vvendedor+'&DTI='+ddi+'/'+mmi+'/'+yyi+'&DTF='+ddf+'/'+mmf+'/'+yyf;
		**/
	vphp = '/bsweb/erp/neurotech/neuproposta.php?SAIDA='+vsaida+'&POR=VENDEDOR&FILIAL='+vfilial;		
		//alert(vphp);
			
			if (vsaida == 'JSON') {
				return chamaAJAX(vphp);
			}
			
			if (vsaida == '') {
				$$('frame-body').define("src", vphp);
			}
			
	
	}

	function chamaESTAB(vPHP) {
                        rows = [];


         $.ajax({
                url: vPHP,
                type: "get",
                async: false,

                dataType: "json",
                data: 'id=' + Math.random(),
                success: function (json_get) {
                
                                       //alert(JSON.stringify(json_get, null, 4));
                                        rows = json_get;
                                    //for (var i = 0; i < json.rows.length; i++) {
                                                //rows.push({ "ETBCOD": json.rows[i].id,
                                                                        //"FILIAL": json.rows[i].value

                                                                        //});


                                        //}


},
                error: function (xhr, status, errorThrown) {

                    alert("errorThrown=" + errorThrown);
                }
            })

            return rows;
        }






	function chamaAJAX(vPHP) {
			rows = [];
		
			
         $.ajax({
                url: vPHP,
                type: "get",
                async: false,

                dataType: "json",
                data: 'id=' + Math.random(),
                success: function (json_get) {

					json = json_get;
                                        
                                        // alert(JSON.stringify(json, null, 4));
					//alert(json_get);
				//alert(json.rows.length);

				    for (var i = 0; i < json.rows.length; i++) {
						rows.push({ "ETBCOD": json.rows[i].etbcod, 
									"DATA": json.rows[i].dtinclu, 
									"hrinclu": json.rows[i].hrinclu, 
									"CPF": json.rows[i].cpfcnpj, 
									"CLICOD": json.rows[i].clicod, 
									"NOME_PESSOA": json.rows[i].nome_pessoa, 
									"ETBCAD": json.rows[i].etbcad, 
									"SIT_CREDITO": json.rows[i].sit_credito, 
									"vctolimite": json.rows[i].vctolimite, 
									"vlrlimite": json.rows[i].vlrlimite, 
									"tipoconsulta": json.rows[i].tipoconsulta, 
									"neu_cdoperacao": json.rows[i].neu_cdoperacao,
									"neu_resultado": json.rows[i].neu_resultado
									
									});						
									
		
					}
                },
                error: function (xhr, status, errorThrown) {

                    alert("errorThrown=" + errorThrown);
                }
            })
			//alert(JSON.stringify(rows, null, 4));
            return rows;
        }

		
	
