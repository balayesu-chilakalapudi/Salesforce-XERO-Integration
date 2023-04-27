public class XEROItem {
   /* public static void getXEROItems(){
        XERO__c xr=XERO__c.getValues('Ryan Henderson');        
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
        String tenantId=xr.tenant_id__c;
        
        System.debug('refresh_token: '+refresh_token);
        System.debug('access_token: '+access_token);
        System.debug('tenant Id: '+tenantId);
        
        //Getting access token from XERO
        String tokenuri = 'https://api.xero.com/api.xro/2.0/Items';        
        //  String params='grant_type=refresh_token&refresh_token='+refresh_token;   
        
        // System.debug('params: '+params);
        HttpRequest req = new HttpRequest();
        req.setEndpoint(tokenuri);
        req.setMethod('GET');
        req.setTimeout(60*1000);   
        req.setHeader('Authorization', 'Bearer ' + access_token);
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Xero-tenant-id',tenantId);
        
        //req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        
        
        
        Http h = new Http();
        String resp;
        HttpResponse res = h.send(req);
        resp = res.getBody();
        System.debug('resp data: '+resp);
    }*/
    
    @future(Callout=true)
    public static void sendItemToXERO(String  p_itmstr){
        XEROstaticItemvar.contexec = false;
        Items__c itm=(Items__c)JSON.deserialize(p_itmstr, Items__c.class);
        String accesstoken='';
        
        /* if(acc.xero_code__c==null){
Integer randomNumber = Integer.valueof((Math.random() * 100));
//System.debug('randomNumber is'+randomNumber);
acc.xero_code__c=String.valueOf(randomNumber);
}
if(acc.xero_type__c==null){
acc.xero_type__c='CURRENT';
}
if(acc.Name==null){
acc.Name='No Name';
} */
        
        System.debug('sendItemToXERO: '+itm);
        XERO__c xr;
        if(itm.Record_Type__c!=null &&
           itm.Record_Type__c.equals('XERO UK')){
         //   accesstoken=
            xr=XeroConnector.refreshToken('Ryan Henderson');
             //   XERO__c.getValues('Ryan Henderson');   
        }
        if(itm.Record_Type__c.equals('XERO AUS')){
            xr=XeroConnector.refreshToken('Tandin Dorji');
                //XERO__c.getValues('Tandin Dorji');   
        } 
        if(xr!=null){
            
            String client_id=xr.client_id__c;
            String redirect_uri=xr.redirect_uri__c;
            String client_secret=xr.client_secret__c;
            String expected_str=(xr.access_token_part1__c+xr.access_token_part2__c+xr.access_token_part3__c+xr.access_token_part4__c+xr.access_token_part5__c+xr.access_token_part6__c+xr.access_token_part7__c);
            if(expected_str.contains('null')){
                expected_str=expected_str.replace('null', '');
            }
            expected_str=expected_str.trim(); 
            String access_token= expected_str;
            String refresh_token=xr.refresh_token__c;
            String tenantId=xr.tenant_id__c;
            
          //  System.debug('refresh_token: '+refresh_token);
          //  System.debug('access_token: '+access_token);
          //  System.debug('tenant Id: '+tenantId);
            
            //Getting access token from XERO
            String tokenuri = 'https://api.xero.com/api.xro/2.0/Items';  
            
            if(itm.XERO_TotalCostPool__c==null){
                itm.XERO_TotalCostPool__c='0';
            }
            
            if(itm.XERO_QuantityOnHand__c==null){
                itm.XERO_QuantityOnHand__c='0';
            }
            
            if(itm.xero_code__c==null){
                String code=String.valueOf(crypto.getRandomLong()).substring(0,10);
                //remove - and replace with 1
                if(code!=null && code.contains('-')){
                    code=code.replace('-','1');
                }
                itm.xero_code__c=code;
            }
            String body='{\"code\":\"'+itm.xero_code__c+'\",'+
                '\"Name\":\"'+itm.Name+'\",'+ 
                //  '\"IsSold\":\"'+itm.XERO_IsSold__c+'\",'+ 
                //   '\"IsPurchased\":\"'+itm.XERO_IsPurchased__c+'\",'+ 
                '\"Description\":\"'+itm.XERO_Description__c+'\",'+ 
                '\"PurchaseDescription\":\"'+itm.XERO_PurchaseDescription__c+'\",'+ 
                //   '\"PurchaseDetails\":\"'+itm.XERO_PurchaseDetails__c+'\",'+ 
                //   '\"SalesDetails\":\"'+itm.XERO_SalesDetails__c+'\",'+ 
                //   '\"IsTrackedAsInventory\":\"'+itm.XERO_IsTrackedAsInventory__c+'\",'+ 
                //   '\"InventoryAssetAccountCode\":\"'+itm.XERO_InventoryAssetAccountCode__c+'\",'+ 
                '\"TotalCostPool\":\"'+Integer.valueOf(itm.XERO_TotalCostPool__c)+'\",'+ 
                '\"QuantityOnHand\":\"'+Integer.valueOf(itm.XERO_QuantityOnHand__c)+'\",'+ 
                // '\"UpdatedDateUTC\":\"'+itm.XERO_UpdatedDateUTC__c+'\",'+ 
                '\"UnitPrice\":\"'+itm.XERO_UnitPrice__c+'\",'+ 
                //    '\"AccountCode\":\"'+itm.XERO_AccountCode__c+'\",'+ 
                '\"COGSAccountCode\":\"'+itm.XERO_COGSAccountCode__c+'\",'+ 
                '\"TaxType\":\"'+itm.XERO_TaxType__c+
                '\"'; 		
            
            
            // System.debug('params: '+params);
            HttpRequest req = new HttpRequest();
            req.setEndpoint(tokenuri);
            
            //update record
            if(itm.XERO_ItemID__c!=null){ 
                System.debug('updating record');
                body+=',\"ItemID\":\"'+itm.XERO_ItemID__c+'\"}';
                req.setMethod('POST');
            }
            else{
                System.debug('inserting record');
                //Insert record
                body+='}';
                req.setMethod('PUT');
            }
            System.debug('body: '+body);
            req.setTimeout(60*1000);   
            req.setHeader('Authorization', 'Bearer ' + access_token);
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('Xero-tenant-id',tenantId);
            req.setBody(body);
            
            //req.setHeader('Content-Type', 'application/x-www-form-urlencoded');           
            
            
            Http h = new Http();
            String resp;
            HttpResponse res = h.send(req);
            resp = res.getBody();
            System.debug('resp data: '+resp);
             try{
            	update xr;
            }catch(Exception ex){
                system.debug(ex);
            }  
            JSONParser parser = JSON.createParser(resp);
            while (parser.nextToken() != null) {
                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME)){
                    String fieldName = parser.getText();
                    parser.nextToken();
                    if(fieldName == 'ItemID') {
                        itm.XERO_ItemID__c = parser.getText();
                    } 
                    if(fieldName == 'Code') {
                        itm.XERO_Code__c = parser.getText();
                    } 
                  /*  if(fieldName == 'Name') {
                        itm.Name = parser.getText();
                    }  */
                    if(fieldName == 'IsSold') {
                        itm.XERO_IsSold__c = Boolean.valueOf(parser.getText());
                    } 
                    if(fieldName == 'IsPurchased') {
                        itm.XERO_IsPurchased__c = Boolean.valueOf(parser.getText());
                    } 
                    if(fieldName == 'Description') {
                        itm.XERO_Description__c = parser.getText();
                    } 
                    if(fieldName == 'PurchaseDescription') {
                        itm.XERO_PurchaseDescription__c = parser.getText();
                    } 
                    if(fieldName == 'PurchaseDetails') {
                        itm.XERO_PurchaseDetails__c = parser.getText();
                    } 
                    if(fieldName == 'SalesDetails') {
                        itm.XERO_SalesDetails__c = parser.getText();
                    } 
                    if(fieldName == 'IsTrackedAsInventory') {
                        itm.XERO_IsTrackedAsInventory__c = Boolean.valueOf(parser.getText());
                    } 
                    if(fieldName == 'InventoryAssetAccountCode') {
                        itm.XERO_InventoryAssetAccountCode__c = parser.getText();
                    } 
                    if(fieldName == 'TotalCostPool') {
                        itm.XERO_TotalCostPool__c = parser.getText();
                    } 
                    if(fieldName == 'QuantityOnHand') {
                        itm.XERO_QuantityOnHand__c = parser.getText();
                    } 
                    if(fieldName == 'UpdatedDateUTC') {
                        itm.XERO_UpdatedDateUTC__c = parser.getText();
                    } 
                    if(fieldName == 'UnitPrice') {
                        itm.XERO_UnitPrice__c = parser.getText();
                    } 
                    if(fieldName == 'AccountCode') {
                        itm.XERO_AccountCode__c = parser.getText();
                    } 
                    if(fieldName == 'COGSAccountCode') {
                        itm.XERO_COGSAccountCode__c = parser.getText();
                    } 
                    if(fieldName == 'UpdatedDateUTC') {
                        itm.XERO_UpdatedDateUTC__c = parser.getText();
                    } 
                  /*  if(fieldName=='TaxType'){
                        itm.XERO_TaxType__c=parser.getText();
                    } */
                }
            }
            
            //update xero accountId       
            update itm;
        }
    } 
}