public class XEROErrorMessageCtrl {
    @AuraEnabled
    public static MessageWrapper getErrorMessage(String p_recordId){
        MessageWrapper mw=new MessageWrapper();
        List<String> mresp=new List<String>();        
        String xresp=getMessage(p_recordId);
        if(xresp!=null){
            for(String s:xresp.split('\n')){
                if(s.contains('Message')){
                    String sp=s.substringAfter('Message');
                    if(sp!=null){
                        if(sp.contains('\"')){
                            sp=sp.replace('\"','');
                        }
                        if(sp.contains(':')){
                            sp=sp.replace(':','');
                        }
                        if(sp.contains(',')){
                            sp=sp.replace(',','');
                        }
                        mresp.add(sp);
                    }
                }
            }
        }    
        mw.msglist=mresp;
        mw.xeroId=getXeroId(p_recordId);
        mw.dupMap=getdupmap(p_recordId);
        mw.tokenfail=getTokenStatus();
        mw.tokenurl=getTokenUrl();
        system.debug('mw:'+mw);
        return mw;
    }
    public static String getMessage(String p_recordId){
        String resp='';
        try{
            Id myId=Id.valueOF(p_recordId);
            //get sobjectname
            String sObjName = myId.getSObjectType().getDescribe().getName();
            System.debug('sobjectname:'+sObjName);
            String rname='';
            rname=(String)database.query('select xero_response__c from '+sobjName+' where Id=\''+p_recordId+'\'')[0].get('xero_response__c');
            resp=rname;
        }catch(exception ex){
            system.debug('exception:'+ex+'\n'+ex.getStackTraceString());
        }  
        return resp;
    }
    public class MessageWrapper{
        @AuraEnabled
        public List<String> msglist;
        @AuraEnabled
        public String xeroId;
        @AuraEnabled
        public Map<Id,String> dupMap;
        @AuraEnabled
        public Boolean tokenfail;
        @AuraEnabled
        public String tokenurl;
    }
    public static String getXeroId(String p_recordId){
        String xeroId=null;
        try{
            Id myId=Id.valueOF(p_recordId);
            //get sobjectname
            String sObjName = myId.getSObjectType().getDescribe().getName();
            System.debug('sobjectname:'+sObjName);   
            if(sObjName!=null && sObjName.contains('__c')){
                sObjName=sObjName.replace('__c','');
            }
            String xname='Xero_'+sObjName+'Id__c';
            if(xname.equals('Xero_AccountId__c')){
                xname='Xero_ContactId__c';
            }
            xeroId=(String)database.query('select '+xname+' from '+sobjName+' where Id=\''+p_recordId+'\'')[0].get(xname);           
        }catch(exception ex){
            system.debug('exception:'+ex+'\n'+ex.getStackTraceString());
        }  
        return xeroId;
    }
    public static map<Id,string> getdupmap(String p_recordId){
        map<Id,string> dupmap=new map<Id,string>();
         Id myId=Id.valueOF(p_recordId);
         String sObjName = myId.getSObjectType().getDescribe().getName();
        String name=(String)database.query('select Name from '+sobjName+' where Id=\''+p_recordId+'\'')[0].get('Name');
        String filter=name;
        for(Account acc:[select Id,name from Account where name=:filter]){               
                dupmap.put(acc.id,acc.name);            
        }
        for(Contact con:[select Id,name from Contact where name=:filter]){           
                dupmap.put(con.Id,con.name);
        }
        for(items__c itm:[select Id,name from items__c where name=:filter]){           
                dupmap.put(itm.Id,itm.name);
        } 
        if(sobjName.equals('Invoice__c')){
            string invnum=(String)database.query('select Invoice_number__c from '+sobjName+' where Id=\''+p_recordId+'\'')[0].get('Invoice_number__c');
            filter=invnum;
            for(Invoice__c inv:[select Id,Name,invoice_number__c from invoice__c where invoice_number__c=:filter]){
                dupmap.put(inv.Id,inv.name);
            }
        }
        return dupmap;
    }
    public static Boolean getTokenStatus(){
        Boolean status=false;
        String country='';
        XERO__c xr;
        try{
        	country=[select country from User where Id=:userinfo.getUserId()].country;
        }catch(Exception ex){
            country='';
            system.debug('Exception:'+ex+'\n'+ex.getStackTraceString());
        }
        if(country!=null &&
           country.startsWithIgnoreCase('UK')){
            xr=XERO__c.getValues('Ryan Henderson');  
        }
        else{
            xr=XERO__c.getValues('Tandin Dorji');
        }
         String expected_str=(xr.access_token_part1__c+xr.access_token_part2__c+xr.access_token_part3__c+xr.access_token_part4__c+xr.access_token_part5__c+xr.access_token_part6__c+xr.access_token_part7__c);
            if(expected_str.contains('null')){
                expected_str=expected_str.replace('null', '');
            }
            expected_str=expected_str.trim();
            String access_token=expected_str;
        if(access_token==null || access_token==''){
            status=true;
        }
        else{
            status=false;
        }
        return status;
    }
    public static String getTokenUrl(){
        String tokenurl='';
         String country='';
        XERO__c xr;
        try{
        	country=[select country from User where Id=:userinfo.getUserId()].country;
        }catch(Exception ex){
            country='';
            system.debug('Exception:'+ex+'\n'+ex.getStackTraceString());
        }
        if(country!=null && country.startsWithIgnoreCase('UK')){
            xr=XERO__c.getValues('Ryan Henderson');            
        }
        else{
            xr=XERO__c.getValues('Tandin Dorji');
        }
         String client_id=xr.client_id__c;
        String redirect_uri=xr.redirect_uri__c;
        String client_secret=xr.client_secret__c;
         tokenurl= 'https://login.xero.com/identity/connect/authorize?response_type=code&client_id='+client_id+'&redirect_uri='+redirect_uri+'&scope=openid profile email offline_access accounting.transactions accounting.settings accounting.contacts&state=123';
         return tokenurl;
    }
}