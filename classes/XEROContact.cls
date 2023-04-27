public class XEROContact {
    /*  public static void getXEROContacts(){
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
String tokenuri = 'https://api.xero.com/api.xro/2.0/Contacts';        
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
} */
    
    @future(Callout=true)
    public static void sendContactToXERO(String  p_accstr,String region){
        statclass.contexec = false;
        Contact con=(Contact)JSON.deserialize(p_accstr, Contact.class);
        String accesstoken='';
        System.debug('sendContactToXERO: '+con);
        XERO__c xr;
        
       /* String region=con.XERO_Region__c;
                    if(region==null){
                           region=con.Created_By_Country__c;
                       } */
        
        if(region!=null &&
           region.containsIgnoreCase('UK')){
           // accesstoken=
            xr=XeroConnector.refreshToken('Ryan Henderson');
                //XERO__c.getValues('Ryan Henderson');
        }
        else{          // if(con.XERO_Region__c!=null && con.XERO_Region__c.containsIgnoreCase('Au')){
            xr= XeroConnector.refreshToken('Tandin Dorji'); 
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
            String access_token=expected_str;
            String refresh_token=xr.refresh_token__c;
            String tenantId=xr.tenant_id__c;
            
            System.debug('refresh_token: '+refresh_token);
            System.debug('access_token: '+access_token);
            System.debug('tenant Id: '+tenantId);
            
            //Getting access token from XERO
            String tokenuri = 'https://api.xero.com/api.xro/2.0/Contacts';  
            
            
            String body='';
            
            String code=String.valueOf(crypto.getRandomLong()).substring(0,10);
            //remove - and replace with 1
            if(code!=null && code.contains('-')){
                code=code.replace('-','1');
            }
            
            String name=con.firstname+' '+con.LastName;
        try{
            string namestr=name+'%';
            integer autonum=0;
            for(contact odf:[select Id,Name from contact where name like :namestr]){
                if(odf.name.startsWith(name)){
                    autonum++;
                }
            }
            for(account acc:[select Id,Name from account where name like :namestr]){
                if(acc.name.startsWith(name)){
                    autonum++;
                }
            }
            if(autonum!=0){
                name=name+'_'+autonum;
            }
        }catch(Exception ex){
            System.debug('Exception:'+ex+'\n'+ex.getStackTraceString());
        }
            
            
            body='{'+
                '\"Name\":\"'+name+'\",'+
                //  '\"AccountNumber\":\"'+con.xero_AccountNumber__c+'\",'+            
                //  '\"ContactStatus\":\"'+con.xero_ContactStatus__c+'\",'+            
                '\"FirstName\":\"'+con.FirstName+'\",'+            
                '\"LastName\":\"'+con.LastName+           
                //  '\"EmailAddress\":\"'+con.Email+'\",'+            
                //  '\"SkypeUserName\":\"'+con.xero_SkypeUserName__c+'\",'+            
                //  '\"BankAccountDetails\":\"'+con.xero_BankAccountDetails__c+'\",'+            
                //  '\"TaxNumber\":\"'+con.xero_TaxNumber__c+'\",'+            
                //  '\"AccountsReceivableTaxType\":\"'+con.xero_AccountsReceivableTaxType__c+'\",'+            
                //  '\"AccountsPayableTaxType\":\"'+con.xero_AccountsPayableTaxType__c+          
                // '\"Addresses\":\"'+con.xero_Addresses__c+'\",'+            
                // '\"Phones\":\"'+con.xero_Phones__c+'\",'+            
                // '\"IsSupplier\":\"'+con.xero_IsSupplier__c+'\",'+            
                // '\"IsCustomer\":\"'+con.xero_IsCustomer__c+'\",'+            
                // '\"DefaultCurrency\":\"'+con.xero_DefaultCurrency__c+'\",'+            
                // '\"UpdatedDateUTC\":\"'+con.xero_UpdatedDateUTC__c+'\",'+            
                // '\"ContactPersons\":\"'+con.xero_ContactPersons__c+'\",'+            
                // '\"XeroNetworkKey\":\"'+con.xero_XeroNetworkKey__c+'\",'+            
                // '\"SalesDefaultAccountCode\":\"'+con.xero_SalesDefaultAccountCode__c+'\",'+            
                //  '\"PurchasesDefaultAccountCode\":\"'+con.xero_PurchasesDefaultAccountCode__c+'\",'+            
                //  '\"SalesTrackingCategories\":\"'+con.xero_SalesTrackingCategories__c+'\",'+            
                //  '\"PurchasesTrackingCategories\":\"'+con.xero_PurchasesTrackingCategories__c+'\",'+            
                //  '\"TrackingCategoryName\":\"'+con.xero_TrackingCategoryName__c+'\",'+            
                //  '\"TrackingOptionName\":\"'+con.xero_TrackingOptionName__c+'\",'+            
                //   '\"PaymentTerms\":\"'+con.xero_PaymentTerms__c+'\",'+            
                //   '\"ContactGroups\":\"'+con.xero_ContactGroups__c+'\",'+            
                //  '\"Website\":\"'+con.xero_Website__c+'\",'+            
                //  '\"BrandingTheme\":\"'+con.xero_BrandingTheme__c+'\",'+            
                //   '\"BatchPayments\":\"'+con.xero_BatchPayments__c+'\",'+            
                //   '\"Discount\":\"'+con.xero_Discount__c+'\",'+          
                //  '\"Balances\":\"'+con.xero_Balances__c+'\",'+          
                //  '\"HasAttachments\":\"'+con.xero_HasAttachments__c+'\",'+          
                //  '\"IncludeInEmails\":\"'+con.xero_IncludeInEmails__c+'\",'+          
                //  '\"includeArchived\":\"'+con.xero_includeArchived__c+'\",'+        
                //  '\"CISEnabled\":\"'+con.xero_CISEnabled__c+'\",'+        
                //  '\"Rate\":\"'+con.xero_Rate__c+
                '\"';
            
            
            // System.debug('params: '+params);
            HttpRequest req = new HttpRequest();
            req.setEndpoint(tokenuri);
            
            //update record
            if(con.XERO_ContactID__c!=null){  
                body+=',\"ContactID\":\"'+con.xero_ContactId__c+'\"}';
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
             try{
            	update xr;
            }catch(Exception ex){
                system.debug(ex);
            }  
            if(resp.length()>131000){
                con.XERO_Response__c=resp.substring(0, 131000);
            }else{
                con.XERO_Response__c=resp; 
            }        
            
            Map<String, Object> m =  (Map<String, Object>) JSON.deserializeUntyped(resp); //re is response body string
            List<Object> xcons=(List<Object>)m.get('Contacts');
            
            //  CResp rp=(CResp)JSON.deserialize(resp, CResp.class);
            //System.debug('rp.Contacts: '+rp.Contacts);
            // List<XEROCon> conlist=new List<XEROCon>();
            // conlist=xcons;
            System.debug('xcons:'+xcons);
            if(xcons!=null &&
               xcons.size()>0){
                   Map<String,Object> xc=(Map<String,Object>)xcons[0];
                   System.debug('XEROCon: '+xc);               
                   con.XERO_AccountNumber__c=(String)xc.get('AccountNumber');
                   con.XERO_ContactStatus__c=(String)xc.get('ContactStatus');
                   con.xero_contactId__c=(String)xc.get('ContactID');
                   con.XERO_SkypeUserName__c = (String)xc.get('SkypeUserName'); 
                   con.XERO_BankAccountDetails__c = (String)xc.get('BankAccountDetails');
                   con.XERO_TaxNumber__c = (String)xc.get('TaxNumber');
                   con.XERO_AccountsReceivableTaxType__c = (String)xc.get('AccountsReceivableTaxType');
                   con.XERO_AccountsPayableTaxType__c =(String) xc.get('AccountsPayableTaxType');
                   //  con.XERO_Addresses__c = xc.Addresses;
                   //  con.XERO_Phones__c = xc.Phones;
                   if(xc.get('IsSupplier')!=null)
                       con.XERO_IsSupplier__c = Boolean.valueOf(xc.get('IsSupplier'));
                   if(xc.get('IsCustomer')!=null)
                       con.XERO_IsCustomer__c = Boolean.valueOf(xc.get('IsCustomer'));
                   con.XERO_DefaultCurrency__c = (String)xc.get('DefaultCurrency');
                   // con.XERO_UpdatedDateUTC__c = xc.UpdatedDateUTC;
                   // con.XERO_ContactPersons__c =(String) xc.get('ContactPersons;
                   con.XERO_XeroNetworkKey__c =(String) xc.get('XERONetworkKey');
                   con.XERO_SalesDefaultAccountCode__c =(String) xc.get('SalesDefaultAccountCode');
                   con.XERO_PurchasesDefaultAccountCode__c = (String)xc.get('PurchasesDefaultAccountCode');
                   //  con.XERO_SalesTrackingCategories__c = xc.SalesTrackingCategories;
                   //  con.XERO_PurchasesTrackingCategories__c = xc.PurchasesTrackingCategories;
                   con.XERO_TrackingCategoryName__c =(String) xc.get('TrackingCategoryName');
                   con.XERO_TrackingOptionName__c = (String)xc.get('TrackingOptionName');
                   //  con.XERO_PaymentTerms__c = xc.PaymentTerms;
                   // con.XERO_ContactGroups__c = (String)xc.get('ContactGroups');
                   con.XERO_Website__c = (String)xc.get('Website');
                   con.XERO_BrandingTheme__c = (String)xc.get('BrandingTheme');
                   //  con.XERO_BatchPayments__c = (String)xc.get('BatchPayments');
                   con.XERO_Discount__c = (String)xc.get('Discount');
                   //   con.XERO_Balances__c = xc.Balances;
                   //   con.XERO_HasAttachments__c = Boolean.valueOf(xc.HasAttachments);
                   //   con.XERO_IncludeInEmails__c = xc.IncludeInEmails;
                   con.XERO_includeArchived__c = (String)xc.get('IncludeArchived');
                   if(xc.get('CISEnabled')!=null){
                       con.XERO_CISEnabled__c = Boolean.valueOf(xc.get('CISEnabled'));
                   }
                   con.XERO_Rate__c = (String)xc.get('Rate');                  
               }
            
            //update xero accountId  
            
            update con;
        }
    } 
   /* public Class CResp{
        public String Id;
        public List<XEROCon> Contacts;
    }
    public Class XEROCon{
        public String ContactID;
        public String AccountNumber;
        public String ContactStatus;
        public String Name;
        public String FirstName;
        public String LastName;
        public String EmailAddress;
        public String SkypeUserName;
        public String BankAccountDetails;
        public String TaxNumber;
        public String AccountsReceivableTaxType;
        public String AccountsPayableTaxType;
        //  public String Addresses;
        //  public String Phones;
        public String IsSupplier;
        public String IsCustomer;
        public String DefaultCurrency;
        //  public String UpdatedDateUTC;
        public String ContactPersons;
        public String XeroNetworkKey;
        public String SalesDefaultAccountCode;
        public String PurchasesDefaultAccountCode;
        //  public String SalesTrackingCategories;
        //  public String PurchasesTrackingCategories;
        public String TrackingCategoryName;
        public String TrackingOptionName;
        //  public String PaymentTerms;
        public String ContactGroups;
        public String Website;
        public String BrandingTheme;
        public String BatchPayments;
        public String Discount;
        //  public String Balances;
        public String HasAttachments;
        //  public String IncludeInEmails;
        public String includeArchived;
        public String CISEnabled;
        public String Rate;
    }*/
}