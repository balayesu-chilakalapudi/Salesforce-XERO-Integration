({
	doInit : function(component, event, helper) {
		 var action = component.get("c.getErrorMessage");
        action.setParams({ p_recordId : component.get("v.recordId")  });        
        action.setCallback(this, function(response) {
            var state = response.getState(); 
            console.log('state: '+state);
            if (state === "SUCCESS") {
                var presult=response.getReturnValue();
                console.log('presult:'+JSON.stringify(presult));
                component.set("v.msg",presult.msglist);       
                component.set("v.xeroId",presult.xeroId);
                component.set("v.tokenfail",presult.tokenfail);
                component.set("v.tokenurl",presult.tokenurl);
                var custs = [];
                var conts = presult.dupMap;
                for ( var key in conts ) {
                    custs.push({value:conts[key], key:key});
                }
                component.set("v.duplist", custs);
            }   
            component.set("v.showSpinner",false);
        });
        $A.enqueueAction(action); 
	},    
    authorize:function(component,event,helper){
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": ""+component.get("v.tokenurl")
        });
        urlEvent.fire();
    }
})