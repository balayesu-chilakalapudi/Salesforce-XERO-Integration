({
	getCaseDetails : function(component,event) {
		 //get case wrapper
	 	var inv=component.get("v.inv");
        console.log('inv:'+JSON.stringify(inv));
        var action = component.get("c.getCaseWrapper");
        action.setParams({ caseId : ''+inv.Case__c  });        
        action.setCallback(this, function(response) {
            var state = response.getState(); 
            console.log('state: '+state);
            if (state === "SUCCESS") {
                var presult=response.getReturnValue();
                console.log('presult:'+JSON.stringify(presult));
                console.log('presult: '+JSON.stringify(presult));
                component.set("v.cw",presult);
                component.set("v.tclist",presult.tclist);
                component.set("v.customerlist",presult.clist);
                component.set("v.mslist",presult.mslist);
                component.set("v.dmlist",presult.dmlist);
                component.set("v.commlist",presult.commlist);
                component.set("v.aflist",presult.aflist);
                component.set("v.Region",presult.Region);
                
              /*  component.set("v.xrmslist",presult.mslist);
                component.set("v.xrdmlist",presult.dmlist);
                component.set("v.xraflist",presult.aflist); */
                
               // component.set("v.itemlist",presult.itemlist);
                inv.Invoice_Number__c=presult.InvNumber;
                component.set("v.inv",inv);
                console.log('inv:'+JSON.stringify(component.get("v.inv")));
                component.set("v.xero_taxrates",presult.xero_taxrates);
            }             
        });
        $A.enqueueAction(action); 
	},
    setInvAmount:function(component){
        console.log('setInvAmount success');
        var tcmlist=component.get("v.tclist");
        console.log('tcmlist size:'+tcmlist.length);
        var tcmId=component.get("v.tcmId");
        console.log('tcmId:'+tcmId);
        var msvalue=0;
        for(var x=0;x<tcmlist.length;x++){
            if(tcmlist[x].Id==tcmId){
                msvalue=tcmlist[x].Milestone_Value__c;               
                break;
            }
        }
        var inv=component.get("v.inv");
        inv.Invoice_Amount__c=msvalue;
        component.set("v.inv",inv);
    },
    setInvWithTax:function(component){
        console.log('calculateInvoiceAmount success');
       var inv=component.get("v.inv");  
        var ratesmap=component.get("v.xero_taxrates");        
        var transtype=inv.Transaction_Type__c;   
        console.log('transaction:'+transtype);
        
       var InvoiceAmount=0.0;
       var TaxAmount=0.0;
       var TotalInvoiceAmount=0.0;
        
        //Process the selected Milestones      
        var selectedMilestones = [];
        var checkMSvalue = component.find("checkMilestone"); 
        //single milestone
        if(!Array.isArray(checkMSvalue)){
            if (checkMSvalue!=null &&
                checkMSvalue.get("v.value") == true) {
                selectedMilestones.push(checkMSvalue.get("v.text"));
                InvoiceAmount+=parseFloat(checkMSvalue.get("v.text").Milestone_Value__c);
            }
        }else{
            for (var i = 0; i < checkMSvalue.length; i++) {
                if (checkMSvalue!=null &&
                    checkMSvalue[i].get("v.value") == true) {
                    selectedMilestones.push(checkMSvalue[i].get("v.text"));
                    InvoiceAmount+=parseFloat(checkMSvalue[i].get("v.text").Milestone_Value__c);
                }
            }
        }
      //  console.log('selectedMilestones:' + JSON.stringify(selectedMilestones));  
            
        //Process the selected Disbursements      
        var selectedDisbursements = [];
        var checkDMvalue = component.find("checkDisbursement");
      //  console.log('checkDMvalue: '+checkDMvalue);
        if(!Array.isArray(checkDMvalue)){
            if (checkDMvalue!=null && 
                checkDMvalue.get("v.value") == true) {
                selectedDisbursements.push(checkDMvalue.get("v.text"));
                InvoiceAmount+=parseFloat(checkDMvalue.get("v.text").Milestone_Value__c);
            }
        }else{
            for (var i = 0; i < checkDMvalue.length; i++) {
                if (checkDMvalue!=null &&
                    checkDMvalue[i].get("v.value") == true) {
                    selectedDisbursements.push(checkDMvalue[i].get("v.text"));
                    InvoiceAmount+=parseFloat(checkDMvalue[i].get("v.text").Milestone_Value__c);               
                }
            }
        }
      //  console.log('selectedDisbursements:' + JSON.stringify(selectedDisbursements));  
        
        //Process selected admin fee
        var selectedAdminFee = [];
        var checkAFvalue = component.find("checkAdminFee");
        console.log('checkAFvalue: '+checkAFvalue);
        if(!Array.isArray(checkAFvalue)){
            if (checkAFvalue!=null && 
                checkAFvalue.get("v.value") == true) {
                selectedAdminFee.push(checkAFvalue.get("v.text"));
                InvoiceAmount+=parseFloat(checkAFvalue.get("v.text").Value);
            }
        }else{
            for (var i = 0; i < checkAFvalue.length; i++) {
                if (checkAFvalue!=null &&
                    checkAFvalue[i].get("v.value") == true) {
                    selectedAdminFee.push(checkAFvalue[i].get("v.text"));
                    InvoiceAmount+=parseFloat(checkAFvalue[i].get("v.text").Value);
                }
            }
        }
      //  console.log('selectedAdminFee:' + JSON.stringify(selectedAdminFee));  
    
		//Process the selected Commission Milestones      
        var selectedCommissionMilestones = [];
        var checkCommvalue = component.find("checkCommissionMilestone");
       // console.log('checkCommvalue: '+checkCommvalue);
        if(!Array.isArray(checkCommvalue)){
            if (checkCommvalue!=null && 
                checkCommvalue.get("v.value") == true) {
                selectedCommissionMilestones.push(checkCommvalue.get("v.text"));
                InvoiceAmount+=parseFloat(checkCommvalue.get("v.text").Commission_Amount__c);
            }
        }else{
            for (var i = 0; i < checkCommvalue.length; i++) {
                if (checkCommvalue!=null &&
                    checkCommvalue[i].get("v.value") == true) {
                    selectedCommissionMilestones.push(checkCommvalue[i].get("v.text"));
                    InvoiceAmount+=parseFloat(checkCommvalue[i].get("v.text").Commission_Amount__c);
                }
            }
        }
        console.log('selectedCommissionMilestones:' + JSON.stringify(selectedCommissionMilestones));  
        
       
      
        //calculate amounts
        try{
            if(transtype!=''){
                if(transtype=='Inclusive of GST / VAT'){
                    for(var i=0;i<selectedMilestones.length;i++){
                         var rate=0;
                        if(selectedMilestones[i].XERO_UK_Tax_Type__c!=null){
                        	rate=ratesmap[selectedMilestones[i].XERO_UK_Tax_Type__c].Rate__c;
                        }
                        if(selectedMilestones[i].XERO_AUS_Tax_Type__c!=null){
                            rate=ratesmap[selectedMilestones[i].XERO_AUS_Tax_Type__c].Rate__c;
                        }
                		 TaxAmount+=parseFloat((selectedMilestones[i].Milestone_Value__c)*(rate/(rate+100)));
                    }
                    for(var i=0;i<selectedDisbursements.length;i++){
                         var rate=0;
                         if(selectedDisbursements[i].XERO_UK_Tax_Type__c!=null){
                         	rate=ratesmap[selectedDisbursements[i].XERO_UK_Tax_Type__c].Rate__c;
                         }
                         if(selectedDisbursements[i].Xero_Aus_Tax_Type__c!=null){
                            rate=ratesmap[selectedDisbursements[i].Xero_Aus_Tax_Type__c].Rate__c; 
                         }
                		 TaxAmount+=parseFloat((selectedDisbursements[i].Milestone_Value__c)*(rate/(rate+100)));
                    }
                    for(var i=0;i<selectedAdminFee.length;i++){
                         var rate=ratesmap['NONE'].Rate__c;
                		 TaxAmount+=parseFloat((selectedAdminFee[i].Value)*(rate/(rate+100)));
                    }
                    for(var i=0;i<selectedCommissionMilestones.length;i++){
                         var rate=0;
                        if(selectedCommissionMilestones[i].XERO_UK_Tax_Type__c!=null){
                         rate=ratesmap[selectedCommissionMilestones[i].XERO_UK_Tax_Type__c].Rate__c;
                        }
                        if(selectedCommissionMilestones[i].Xero_Aus_Tax_Type__c!=null){
                         rate=ratesmap[selectedCommissionMilestones[i].Xero_Aus_Tax_Type__c].Rate__c;
                        }
                		 TaxAmount+=(selectedCommissionMilestones[i].Commission_Amount__c)*(rate/(rate+100));
                    }                    
                    TotalInvoiceAmount=InvoiceAmount-TaxAmount; //5000-(5000/(100+10))
                   
                }
                else if(transtype='Exclusive of GST / VAT'){
                    for(var i=0;i<selectedMilestones.length;i++){
                         var rate=0;
                        if(selectedMilestones[i].XERO_UK_Tax_Type__c!=null){
                         rate=ratesmap[selectedMilestones[i].XERO_UK_Tax_Type__c].Rate__c;
                        }
                        if(selectedMilestones[i].XERO_AUS_Tax_Type__c!=null){
                         rate=ratesmap[selectedMilestones[i].XERO_AUS_Tax_Type__c].Rate__c;
                        }
                		 TaxAmount+=(selectedMilestones[i].Milestone_Value__c)*(rate/100);
                    }
                    for(var i=0;i<selectedDisbursements.length;i++){
                         var rate=0;
                        if(selectedDisbursements[i].XERO_UK_Tax_Type__c!=null){
                        	rate=ratesmap[selectedDisbursements[i].XERO_UK_Tax_Type__c].Rate__c;
                        }
                        if(selectedDisbursements[i].Xero_Aus_Tax_Type__c!=null){
                        	rate=ratesmap[selectedDisbursements[i].Xero_Aus_Tax_Type__c].Rate__c;
                        }
                		 TaxAmount+=(selectedDisbursements[i].Milestone_Value__c)*(rate/100);
                    }
                    for(var i=0;i<selectedAdminFee.length;i++){
                         var rate=ratesmap['NONE'].Rate__c;
                		 TaxAmount+=(selectedAdminFee[i].Value)*(rate/100);
                    }
                    for(var i=0;i<selectedCommissionMilestones.length;i++){
                         var rate=0;
                        if(selectedCommissionMilestones[i].XERO_UK_Tax_Type__c!=null){
                         	rate=ratesmap[selectedCommissionMilestones[i].XERO_UK_Tax_Type__c].Rate__c;
                        }
                        if(selectedCommissionMilestones[i].Xero_Aus_Tax_Type__c!=null){
                         	rate=ratesmap[selectedCommissionMilestones[i].Xero_Aus_Tax_Type__c].Rate__c;
                        }
                		 TaxAmount+=(selectedCommissionMilestones[i].Commission_Amount__c)*(rate/100);
                    }                     
                    TotalInvoiceAmount=parseFloat(InvoiceAmount)+parseFloat(TaxAmount);  //5000+(5000%10))  
                    
                }  
                
            }
        }catch(err){
            console.log('Exception:'+err.stack);
        }
        try{
            console.log('InvoiceAmount:'+InvoiceAmount);
            console.log('TaxAmount:'+TaxAmount);
            console.log('TotalInvoiceAmount:'+TotalInvoiceAmount);
        inv.Invoice_Amount__c=InvoiceAmount.toFixed(2);
        inv.Tax_Amount__c=TaxAmount.toFixed(2);
        inv.Total_Invoice_Amount__c=TotalInvoiceAmount.toFixed(2);
        component.set("v.inv",inv); 
        }catch(err){
            console.log('ERROR:'+err.stack);
        }
    }
})