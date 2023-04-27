public class XEROConnector_UK {
    
    //Fetched from URL
    String code ;
    
    public XEROConnector_UK()
    {
       
    }
    
    public PageReference XEROAuth()
    {
         code = ApexPages.currentPage().getParameters().get('code') ;
        
        //Get the access token once we have code
        if(code != '' && code != null)
        {
            AccessToken() ;
             return new PageReference('https://jamesclarke.lightning.force.com/lightning/page/home');
        }
        
        String XEROConnectorUser='Ryan Henderson';
            //System.Label.XeroConnector_User;  // update it based on region UK or AUS
        XERO__c xr=XERO__c.getValues(XEROConnectorUser);        
        String client_id=xr.client_id__c;
        String redirect_uri=xr.redirect_uri__c;
        String client_secret=xr.client_secret__c;
        String auth_uri = 'https://login.xero.com/identity/connect/authorize?response_type=code&client_id='+client_id+'&redirect_uri='+redirect_uri+'&scope=openid profile email offline_access accounting.transactions accounting.settings accounting.contacts&state=123';
        System.debug('auth_uri: '+auth_uri);
        //Authenticating
        PageReference pg = new PageReference(auth_uri);           
        return pg ;
    }
    
    public void AccessToken()
    {
        System.debug('code: '+code);
        String XEROConnectorUser='Ryan Henderson';
            //System.Label.XeroConnector_User;
        XERO__c xr=XERO__c.getValues(XEROConnectorUser);        
        String client_id=xr.client_id__c;
        String redirect_uri=xr.redirect_uri__c;
        String client_secret=xr.client_secret__c;
        
        //Getting access token from XERO
        String tokenuri = 'https://identity.xero.com/connect/token';
        
        String params='grant_type=authorization_code&code='+code+'&redirect_uri='+redirect_uri;
        
        System.debug('params: '+params);
        HttpRequest req = new HttpRequest();
        req.setEndpoint(tokenuri);
        req.setMethod('POST');
        req.setTimeout(60*1000);                       
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        
        Blob headerValue = Blob.valueOf(client_id + ':' + client_secret);
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        req.setHeader('Authorization', authorizationHeader); 
        req.setBody(params);
        
        Http h = new Http();
        String resp;
        HttpResponse res = h.send(req);
        resp = res.getBody();
        
        System.debug(' You can parse the response to get the access token ::: ' + resp);
        String accesstoken='';
        String refreshtoken='';
        //parse the access token
        JSONParser parser = JSON.createParser(resp);
        while (parser.nextToken() != null) {
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME)){
                String fieldName = parser.getText();
                parser.nextToken();
                if(fieldName == 'access_token') {
                    accesstoken = parser.getText();
                } 
                if(fieldName == 'refresh_token') {
                    refreshtoken = parser.getText();
                } 
            }
        }
        System.debug('access token: '+accesstoken); 
        System.debug('refresh token: '+refreshtoken);   
       // xr.refresh_token__c=refreshtoken;
        xr.refresh_token__c=null;
        xr.access_token_part1__c=null;
        xr.access_token_part2__c=null;
        xr.access_token_part3__c=null;
        xr.access_token_part4__c=null;
        xr.access_token_part5__c=null;
        xr.access_token_part6__c=null;
        xr.access_token_part7__c=null;        
        
      
        xr.refresh_token__c=refreshtoken;    
        
        if(accesstoken.length()>0){
            if(accesstoken.length()>250)
                xr.access_token_part1__c=accesstoken.subString(0,250);
            else
                xr.access_token_part1__c=accesstoken.subString(0,accesstoken.length());
        }
        if(accesstoken.length()>250){
            if(accesstoken.length()>500)
                xr.access_token_part2__c=accesstoken.subString(250,500);
            else
                xr.access_token_part2__c=accesstoken.subString(250,accesstoken.length());
        }
        if(accesstoken.length()>500){
            if(accesstoken.length()>750)
                xr.access_token_part3__c=accesstoken.subString(500,750);
            else
                xr.access_token_part3__c=accesstoken.subString(500,accesstoken.length());
        }
        if(accesstoken.length()>750){
            if(accesstoken.length()>1000)
                xr.access_token_part4__c=accesstoken.subString(750,1000);
            else
                xr.access_token_part4__c=accesstoken.subString(750,accesstoken.length());
        }	
        if(accesstoken.length()>1000){
            if(accesstoken.length()>1250)
                xr.access_token_part5__c=accesstoken.subString(1000,1250);
            else
                xr.access_token_part5__c=accesstoken.subString(1000,accesstoken.length());
        }
        if(accesstoken.length()>1250){
            if(accesstoken.length()>1500)
                xr.access_token_part6__c=accesstoken.subString(1250,1500);
            else
                xr.access_token_part6__c=accesstoken.subString(1250,accesstoken.length());
            
        }
        if(accesstoken.length()>1500){
            if(accesstoken.length()>1750)
                xr.access_token_part7__c=accesstoken.subString(1500,1750);
            else
                xr.access_token_part7__c=accesstoken.subString(1500,accesstoken.length());
        }
      
        update xr;
       // saveTokens(accesstoken,refreshtoken,true);
    }
    
    
    public static XERO__c refreshToken(String cname){  
        System.debug('cname:'+cname);
        String accesstoken='';
        XERO__c xr=XERO__c.getValues(cname);        
        String client_id=xr.client_id__c;
        String redirect_uri=xr.redirect_uri__c;
        String client_secret=xr.client_secret__c;
        
        String refresh_token=xr.refresh_token__c;
        String tenantId=xr.tenant_id__c;
        
      //  System.debug('refresh_token: '+refresh_token);
        //Getting access token from XERO
        String tokenuri = 'https://identity.xero.com/connect/token';        
        String params='grant_type=refresh_token&refresh_token='+refresh_token;   
        
      //  System.debug('params: '+params);
        HttpRequest req = new HttpRequest();
        req.setEndpoint(tokenuri);
        req.setMethod('POST');
        req.setTimeout(60*1000);                       
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        
        Blob headerValue = Blob.valueOf(client_id + ':' + client_secret);
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        req.setHeader('Authorization', authorizationHeader); 
        req.setHeader('Xero-tenant-id', tenantId);
        req.setBody(params);
        
        Http h = new Http();
        String resp;
        HttpResponse res = h.send(req);
        resp = res.getBody();
        
        System.debug(' You can parse the response to get the access token ::: ' + resp);
        
        String refreshtoken='';
        //parse the access token
        JSONParser parser = JSON.createParser(resp);
        while (parser.nextToken() != null) {
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME)){
                String fieldName = parser.getText();
                parser.nextToken();
                if(fieldName == 'access_token') {
                    accesstoken = parser.getText();
                } 
                if(fieldName == 'refresh_token') {
                    refreshtoken = parser.getText();
                } 
            }
        }
        System.debug('access token: '+accesstoken);
        System.debug('refresh token: '+refreshtoken);
        
        if(refreshtoken!='')
        	xr.refresh_token__c=refreshtoken;       
        
        // System.debug('accesstoken.length(): '+accesstoken.length());
        // System.debug('accesstoken.length()/2: '+accesstoken.length()/2);
        // System.debug('(accesstoken.length()/2)+1: '+(accesstoken.length()/2)+1);
        
        xr.access_token_part1__c=accesstoken;
        if(accesstoken.length()>0){
            if(accesstoken.length()>250)
                xr.access_token_part1__c=accesstoken.subString(0,250);
            else
                xr.access_token_part1__c=accesstoken.subString(0,accesstoken.length());
        }
        if(accesstoken.length()>250){
            if(accesstoken.length()>500)
                xr.access_token_part2__c=accesstoken.subString(250,500);
            else
                xr.access_token_part2__c=accesstoken.subString(250,accesstoken.length());
        }
        if(accesstoken.length()>500){
            if(accesstoken.length()>750)
                xr.access_token_part3__c=accesstoken.subString(500,750);
            else
                xr.access_token_part3__c=accesstoken.subString(500,accesstoken.length());
        }
        if(accesstoken.length()>750){
            if(accesstoken.length()>1000)
                xr.access_token_part4__c=accesstoken.subString(750,1000);
            else
                xr.access_token_part4__c=accesstoken.subString(750,accesstoken.length());
        }	
        if(accesstoken.length()>1000){
            if(accesstoken.length()>1250)
                xr.access_token_part5__c=accesstoken.subString(1000,1250);
            else
                xr.access_token_part5__c=accesstoken.subString(1000,accesstoken.length());
        }
        if(accesstoken.length()>1250){
            if(accesstoken.length()>1500)
                xr.access_token_part6__c=accesstoken.subString(1250,1500);
            else
                xr.access_token_part6__c=accesstoken.subString(1250,accesstoken.length());
            
        }
        if(accesstoken.length()>1500){
            if(accesstoken.length()>1750)
                xr.access_token_part7__c=accesstoken.subString(1500,1750);
            else
                xr.access_token_part7__c=accesstoken.subString(1500,accesstoken.length());
        }
       /* String actual_str=accesstoken;
        String expected_str=getToken(xr.access_token_part1__c)+
            getToken(xr.access_token_part2__c)+
            getToken(xr.access_token_part3__c)+
            getToken(xr.access_token_part4__c)+
            getToken(xr.access_token_part5__c)+
            getToken(xr.access_token_part6__c)+
            getToken(xr.access_token_part7__c);
        
        expected_str=expected_str.trim();
        actual_str=actual_str.trim(); */
        
      //  System.debug('expected_str: '+expected_str);
      //  system.debug('actual_str: '+actual_str);
     //   System.assertEquals(actual_str,expected_str);
        
        //save latest tokens
      //  update xr;
      
      return xr;
    }  
    public static String getToken(String str){
        String result='';
        if(str!=null){
            result=str.trim();
        }
        return result;
    }
    
    public static void getTenants(){
        String XEROConnectorUser=System.Label.XeroConnector_User;       
         XERO__c xr=XeroConnector.refreshToken(XEROConnectorUser);
             //XERO__c.getValues(XEROConnectorUser);        
        String client_id=xr.client_id__c;
        String redirect_uri=xr.redirect_uri__c;
        String client_secret=xr.client_secret__c;
        String expected_str=(xr.access_token_part1__c+xr.access_token_part2__c+xr.access_token_part3__c+xr.access_token_part4__c+xr.access_token_part5__c+xr.access_token_part6__c+xr.access_token_part7__c);
        if(expected_str.contains('null')){
            expected_str=expected_str.replace('null', '');
        }
        expected_str=expected_str.trim(); 
        String access_token=expected_str;
        String refresh_token=xr.refresh_token__c;
        
      //  System.debug('refresh_token: '+refresh_token);
      //  System.debug('access_token: '+access_token);
        //Getting access token from XERO
        String tokenuri = 'https://api.xero.com/connections';        
       //  String params='grant_type=refresh_token&refresh_token='+refresh_token;   
        
       // System.debug('params: '+params);
        HttpRequest req = new HttpRequest();
        req.setEndpoint(tokenuri);
        req.setMethod('POST');
        req.setTimeout(60*1000);   
        req.setHeader('Authorization', 'Bearer ' + access_token);
        req.setHeader('Content-Type', 'application/json');
        
        //req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        
       
        
        Http h = new Http();
        String resp;
        HttpResponse res = h.send(req);
        resp = res.getBody();
        System.debug('tenant resp data: '+resp);
        String tenantId='';
         JSONParser parser = JSON.createParser(resp);
        while (parser.nextToken() != null) {
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME)){
                String fieldName = parser.getText();
                parser.nextToken();
                if(fieldName == 'tenantId') {
                    tenantId = parser.getText();
                } 
            }
        }
        System.debug('tenantId: '+tenantId);
        xr.tenant_id__c=tenantId;
        update xr;
    }
   /*
    public static void saveTokens(String accesstoken, String refreshtoken, Boolean allowdml){
        XERO__c xr=XERO__c.getValues('Tandin Dorji');        
        String client_id=xr.client_id__c;
        String redirect_uri=xr.redirect_uri__c;
        String client_secret=xr.client_secret__c;
        
        if(refreshtoken!='')
        	xr.refresh_token__c=refreshtoken;   
        
        xr.access_token_part1__c=accesstoken;
        if(accesstoken.length()>0){
            if(accesstoken.length()>250)
                xr.access_token_part1__c=accesstoken.subString(0,250);
            else
                xr.access_token_part1__c=accesstoken.subString(0,accesstoken.length());
        }
        if(accesstoken.length()>250){
            if(accesstoken.length()>500)
                xr.access_token_part2__c=accesstoken.subString(250,500);
            else
                xr.access_token_part2__c=accesstoken.subString(250,accesstoken.length());
        }
        if(accesstoken.length()>500){
            if(accesstoken.length()>750)
                xr.access_token_part3__c=accesstoken.subString(500,750);
            else
                xr.access_token_part3__c=accesstoken.subString(500,accesstoken.length());
        }
        if(accesstoken.length()>750){
            if(accesstoken.length()>1000)
                xr.access_token_part4__c=accesstoken.subString(750,1000);
            else
                xr.access_token_part4__c=accesstoken.subString(750,accesstoken.length());
        }	
        if(accesstoken.length()>1000){
            if(accesstoken.length()>1250)
                xr.access_token_part5__c=accesstoken.subString(1000,1250);
            else
                xr.access_token_part5__c=accesstoken.subString(1000,accesstoken.length());
        }
        if(accesstoken.length()>1250){
            if(accesstoken.length()>1500)
                xr.access_token_part6__c=accesstoken.subString(1250,1500);
            else
                xr.access_token_part6__c=accesstoken.subString(1250,accesstoken.length());
            
        }
        if(accesstoken.length()>1500){
            if(accesstoken.length()>1750)
                xr.access_token_part7__c=accesstoken.subString(1500,1750);
            else
                xr.access_token_part7__c=accesstoken.subString(1500,accesstoken.length());
        }
        if(allowdml){
            update xr;
        }
    } */
}