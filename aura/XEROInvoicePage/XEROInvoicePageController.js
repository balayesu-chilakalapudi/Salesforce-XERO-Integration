({
    myAction : function(component, event, helper) {
        
    },
    doInit : function(component, event, helper) { 
        console.log('doInit success');
        var sPageURL = decodeURIComponent(window.location.search.substring(1)); //You get the whole decoded URL of the page.
        var sURLVariables = sPageURL.split('&'); //Split by & so that you get the key value pairs separately in a list
        var sParameterName;
        var i;
        console.log('sURLVariables:'+sURLVariables);
		var caseId='';
        for (i = 0; i < sURLVariables.length; i++) {
            sParameterName = sURLVariables[i].split('='); //to split the key from the value.

            if (sParameterName[0] == 'Case__c') { //lets say you are looking for param name - firstName
                caseId = sParameterName[1];
            }
           
        }
        console.log('caseId:'+caseId);
        
       // console.log('Param name:'+sParameterName[0]);
      //  console.log('Param value:'+sParameterName[1])
        
        component.set("v.showform",true);
        var inv=component.get("v.inv");
        inv.Case__c=caseId;
        component.set("v.inv",inv);
        
        /*
        if(inv.Case__c==null && sParameterName[0]=='Case__c'){
            inv.Case__c=sParameterName[1];
            component.set("v.inv",inv);
        }*/
        helper.getCaseDetails(component,event);
        /* 
        var action = component.get("c.getAdminFee");
        action.setParams({ caseId : recordTypeId  });        
        action.setCallback(this, function(response) {
            var state = response.getState();            
            if (state === "SUCCESS") {
                var presult=response.getReturnValue();
                console.log('presult: '+presult);
                if(presult!=''){
                    var urlEvent = $A.get("e.force:navigateToURL");
                    urlEvent.setParams({
                        "url": "/"+response.getReturnValue()
                    });
                    urlEvent.fire(); 
                }else{
                    component.set("v.showform",true);
                    console.log("showform: "+component.get("v.showform"));
                }
            }             
        });
        $A.enqueueAction(action);  */      
    },
    toggleSection : function(component, event, helper) {
        // dynamically get aura:id name from 'data-auraId' attribute
        var sectionAuraId = event.target.getAttribute("data-auraId");
        // get section Div element using aura:id
        var sectionDiv = component.find(sectionAuraId).getElement();
        /* The search() method searches for 'slds-is-open' class, and returns the position of the match.
         * This method returns -1 if no match is found.
        */
        var sectionState = sectionDiv.getAttribute('class').search('slds-is-open'); 
        
        // -1 if 'slds-is-open' class is missing...then set 'slds-is-open' class else set slds-is-close class to element
        if(sectionState == -1){
            sectionDiv.setAttribute('class' , 'slds-section slds-is-open');
        }else{
            sectionDiv.setAttribute('class' , 'slds-section slds-is-close');
        }
    },
    save : function(component,event,helper){ 
        component.find("xinv_savebtn").set("v.disabled",true);
        console.log('saving invoice...');
        try{
        var tcmId=component.get("v.tcmId");
        console.log('tcmId:'+tcmId);
        //Process the selected Milestones      
        var selectedMilestones = [];
        var checkMSvalue = component.find("checkMilestone");
        //single milestone
        if(!Array.isArray(checkMSvalue)){
            if (checkMSvalue!=null &&
                checkMSvalue.get("v.value") == true) {
                selectedMilestones.push(checkMSvalue.get("v.text"));
            }
        }else{
            for (var i = 0; i < checkMSvalue.length; i++) {
                if (checkMSvalue!=null &&
                    checkMSvalue[i].get("v.value") == true) {
                    selectedMilestones.push(checkMSvalue[i].get("v.text"));
                }
            }
        }
        console.log('selectedMilestones:' + JSON.stringify(selectedMilestones));  
            
        //Process the selected Disbursements      
        var selectedDisbursements = [];
        var checkDMvalue = component.find("checkDisbursement");
        console.log('checkDMvalue: '+checkDMvalue);
        if(!Array.isArray(checkDMvalue)){
            if (checkDMvalue!=null && 
                checkDMvalue.get("v.value") == true) {
                selectedDisbursements.push(checkDMvalue.get("v.text"));
            }
        }else{
            for (var i = 0; i < checkDMvalue.length; i++) {
                if (checkDMvalue!=null &&
                    checkDMvalue[i].get("v.value") == true) {
                    selectedDisbursements.push(checkDMvalue[i].get("v.text"));
                }
            }
        }
        console.log('selectedDisbursements:' + JSON.stringify(selectedDisbursements));  
        
        //Process selected admin fee
        var selectedAdminFee = [];
        var checkAFvalue = component.find("checkAdminFee");
        console.log('checkAFvalue: '+checkAFvalue);
        if(!Array.isArray(checkAFvalue)){
            if (checkAFvalue!=null && 
                checkAFvalue.get("v.value") == true) {
                selectedAdminFee.push(checkAFvalue.get("v.text"));
            }
        }else{
            for (var i = 0; i < checkAFvalue.length; i++) {
                if (checkAFvalue!=null &&
                    checkAFvalue[i].get("v.value") == true) {
                    selectedAdminFee.push(checkAFvalue[i].get("v.text"));
                }
            }
        }
        console.log('selectedAdminFee:' + JSON.stringify(selectedAdminFee));  
    
		//Process the selected Commission Milestones      
        var selectedCommissionMilestones = [];
        var checkCommvalue = component.find("checkCommissionMilestone");
        console.log('checkCommvalue: '+checkCommvalue);
        if(!Array.isArray(checkCommvalue)){
            if (checkCommvalue!=null && 
                checkCommvalue.get("v.value") == true) {
                selectedCommissionMilestones.push(checkCommvalue.get("v.text"));
            }
        }else{
            for (var i = 0; i < checkCommvalue.length; i++) {
                if (checkCommvalue!=null &&
                    checkCommvalue[i].get("v.value") == true) {
                    selectedCommissionMilestones.push(checkCommvalue[i].get("v.text"));
                }
            }
        }
        console.log('selectedCommissionMilestones:' + JSON.stringify(selectedCommissionMilestones));  
        
            
        var inv=component.get("v.inv");
      //  var mslist=component.get("v.mslist");
      //  var dmlist=component.get("v.dmlist");
        
        console.log('inv:'+JSON.stringify(inv));
        //  console.log('mslist:'+JSON.stringify(mslist));
        //  console.log('dmlist:'+JSON.stringify(dmlist));
        
        
        var action = component.get("c.processInvoice");    
        action.setParams({ inv :component.get("v.inv"),
                          selectedMilestones:JSON.stringify(selectedMilestones),
                          selectedDisbursements:JSON.stringify(selectedDisbursements),
                          tcmId:''+tcmId,
                          selectedAdminFee:JSON.stringify(selectedAdminFee),
                          selectedCommissionMilestones:JSON.stringify(selectedCommissionMilestones),
                          region:component.get("v.Region")
                         });
        
        action.setCallback(this, function(response) {
            var state = response.getState(); 
            console.log('state:'+state);
            if (state === "SUCCESS") {                
                var presult=response.getReturnValue();
                console.log('presult:'+presult);
                if(presult.includes('ERROR')){
                    component.find("xinv_savebtn").set("v.disabled",false);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "mode": 'sticky',
                        "type": 'error',
                        "title": "Failed to Save!",
                        "message": ""+presult
                    });
                    toastEvent.fire();
                }else{
                    console.log('saved inv id: '+presult);
                    if(presult!=''){
                        var urlEvent = $A.get("e.force:navigateToURL");
                        urlEvent.setParams({
                            "url": "/"+response.getReturnValue()
                        });
                        urlEvent.fire(); 
                    }  
                }
            }             
        });
        $A.enqueueAction(action);    
        }catch(err){
            console.log('ERROR: '+err.stack);
        }
    },
    cancel : function(component,event,helper){
        var retId=component.get("v.inv").Case__c;
        
        if(retId==null){
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/lightning/o/Invoice__c/list?filterName=Recent"
        });
        urlEvent.fire(); 
        }else{
         helper.getCaseDetails(component,event);
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/"+retId
        });
        urlEvent.fire(); 
        }
    },
    closeModel : function(component,event,helper){
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/lightning/o/Invoice__c/list?filterName=Recent"
        });
        urlEvent.fire(); 
    },
    caseSelected: function(component,event,helper){
        console.log('caseselected success');        
       helper.getCaseDetails(component,event);
    },
    getxcode:function(component,event,helper){
        console.log('xcode:'+component.find("xcode").get("v.value"));
    },
   /* tcmSelected:function(component,event,helper){
        helper.setInvAmount(component); 
        helper.setInvWithTax(component);
    },*/
    calculateInvoiceAmount:function(component,event,helper){
        try{
        helper.setInvWithTax(component);
        }catch(err){
            console.log('ERROR:'+err.stack);
        }
    },
    doSyncup:function(component,event,helper){
         helper.getCaseDetails(component,event);
    }
})