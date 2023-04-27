public class XEROCustomSettingAccount {
@future(Callout=true)
    public static void sendCSAccountToXERO(String name){  
        system.debug('name:'+name);
        XERO_Account__c acc=[select Name,xero_code__c,xero_taxtype__c,xero_accountId__c,xero_description__c,xero_region__c
                             from XERO_Account__c where Name=:name];
        String code='';
        String accesstoken='';
        if(acc.XERO_Code__c==null){
            code=String.valueOf(crypto.getRandomLong()).substring(0,10);
            // remove - and replace with 1
            if(code!=null && code.contains('-')){
                code=code.replace('-','1');
            }
            acc.xero_code__c=code;
           // acc.name=acc.name+'__'+acc.XERO_Code__c;
        }
     
        XERO__c xr;
        String type='CURRENT';
        if(acc.xero_region__c!=null &&
           acc.xero_region__c.containsIgnoreCase('UK')){         
                xr=XeroConnector.refreshToken('Ryan Henderson');          
        }   
        else{	
                 xr=XeroConnector.refreshToken('Tandin Dorji');    
		}     
        if(xr!=null){    
                      
           /* if(acc.XERO_BankAccountNumber__c==null){
                acc.XERO_BankAccountNumber__c=code;
            } */
            System.debug('sendAccountToXERO: '+acc);
            
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
            String tokenuri = 'https://api.xero.com/api.xro/2.0/Accounts';  
            
            String body='{\"code\":\"'+acc.xero_code__c+'\",'+
                '\"Name\":\"'+acc.Name+'\",'+
                '\"Type\":\"'+type+'\",'+
                '\"BankAccountNumber\":\"'+acc.xero_code__c+'\",'+
                //'\"Status\":\"'+acc.xero_Status__c+'\",'+
                '\"Description\":\"'+acc.xero_Description__c+'\",'+
            //    '\"BankAccountType\":\"'+acc.xero_BankAccountType__c+'\",'+
            //    '\"CurrencyCode\":\"'+acc.xero_CurrencyCode__c+'\",'+         
                '\"TaxType\":\"'+acc.xero_taxtype__c+
             //   '\"EnablePaymentsToAccount\":\"'+acc.xero_EnablePaymentsToAccount__c+'\",'+
             //   '\"ShowInExpenseClaims\":\"'+acc.xero_ShowInExpenseClaims__c+
                //  '\"AccountID\":\"'+acc.xero_AccountID__c+'\",'+
                //   '\"Class\":\"'+acc.xero_Class__c+'\",'+
                //  '\"SystemAccount\":\"'+acc.xero_SystemAccount__c+'\",'+
                //   '\"ReportingCode\":\"'+acc.xero_ReportingCode__c+'\",'+
                //  '\"ReportingCodeName\":\"'+acc.xero_ReportingCodeName__c+'\",'+
                //  '\"HasAttachments\":\"'+acc.xero_HasAttachments__c+'\",'+
                //  '\"UpdatedDateUTC\":\"'+acc.xero_UpdatedDateUTC__c+        
                '\"';
            
            
            // System.debug('params: '+params);
            HttpRequest req = new HttpRequest();
            req.setEndpoint(tokenuri);
            
            //update record
            if(acc.XERO_AccountID__c!=null){            
                // body+='&AccountID='+acc.xero_AccountId__c;
                body+=',\"AccountID\":\"'+acc.xero_AccountId__c+'\"}';
                req.setMethod('POST');
            }
            else{
                System.debug('inserting record');
                //Insert record
                body+='}';
                req.setMethod('PUT');
            }
            System.debug('body: '+body);
            req.setTimeout(110000);   
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
          /*  if(resp.length()>131000){
                acc.XERO_Response__c=resp.substring(0, 131000);
            }else{
                acc.XERO_Response__c=resp; 
            }   */     
           
            JSONParser parser = JSON.createParser(resp);
            while (parser.nextToken() != null) {
                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME)){
                    String fieldName = parser.getText();
                    parser.nextToken();
                    if(fieldName == 'AccountID') {
                        String xId=parser.getText();
                        if(xId!=null &&
                           !xId.contains('0000')){   
                               acc.XERO_AccountID__c = xId;
                           }
                    } 
                  /*  if(fieldName == 'Code') {
                        acc.XERO_Code__c = parser.getText();
                    } 
                 
                    if(fieldName == 'Type') {
                        acc.XERO_Type__c = parser.getText();
                    } 
                    if(fieldName == 'BankAccountNumber') {
                        acc.XERO_BankAccountNumber__c = parser.getText();
                    } 
                    if(fieldName == 'Status') {
                        acc.XERO_Status__c = parser.getText();
                    } 
                    if(fieldName == 'Description') {
                        acc.XERO_Description__c = parser.getText();
                    } 
                    if(fieldName == 'BankAccountType') {
                        acc.XERO_BankAccountType__c = parser.getText();
                    } 
                    if(fieldName == 'CurrencyCode') {
                        acc.XERO_CurrencyCode__c = parser.getText();
                    } 
                 
                    if(fieldName == 'EnablePaymentsToAccount') {
                        acc.XERO_EnablePaymentsToAccount__c = Boolean.valueOf(parser.getText());
                    } 
                    if(fieldName == 'ShowInExpenseClaims') {
                        acc.XERO_ShowInExpenseClaims__c = Boolean.valueOf(parser.getText());
                    } 
                    if(fieldName == 'Class') {
                        acc.XERO_Class__c = parser.getText();
                    } 
                    if(fieldName == 'SystemAccount') {
                        acc.XERO_SystemAccount__c = parser.getText();
                    } 
                    if(fieldName == 'ReportingCode') {
                        acc.XERO_ReportingCode__c = parser.getText();
                    } 
                    if(fieldName == 'ReportingCodeName') {
                        acc.XERO_ReportingCodeName__c = parser.getText();
                    } 
                    if(fieldName == 'HasAttachments') {
                        acc.XERO_HasAttachments__c = Boolean.valueOf(parser.getText());
                    } 
                    if(fieldName == 'UpdatedDateUTC') {
                        acc.XERO_UpdatedDateUTC__c = parser.getText(); 
                    } */
                }
            }
            
            //update xero accountId  
            update acc;   
        } 
    }
}