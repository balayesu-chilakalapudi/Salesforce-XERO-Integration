public class XEROInvoice {
    /*   public static void getXEROInvoices(){
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
String tokenuri = 'https://api.xero.com/api.xro/2.0/Invoices';        
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
}
*/
    
    @future(Callout=true)
    public static void sendInvoiceToXERO(String  p_invstr){
       // XEROstaticInvoicevar.contexec = false;
        Invoice__c inv=(Invoice__c)JSON.deserialize(p_invstr, Invoice__c.class);       
        System.debug('sendInvoiceToXERO: '+inv);
        System.debug('region:'+inv.XERO_Region__c);
        XERO__c xr;
        if(inv!=null){
        if(inv.XERO_Region__c!=null && inv.XERO_Region__c.containsIgnoreCase('UK')){            
            xr=XeroConnector.refreshToken('Ryan Henderson');               
        }
        else{	
            xr=XeroConnector.refreshToken('Tandin Dorji');           
        }
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
            String tokenuri = 'https://api.xero.com/api.xro/2.0/Invoices'; 
            
            if(inv.xero_Name__c==null){
                inv.xero_Name__c=inv.Name;
            }
            
            if(inv.xero_type__c==null){
                inv.xero_type__c='ACCREC';
            }
            
            if(inv.xero_CurrencyRate__c==null){
                inv.xero_CurrencyRate__c='0';
            }
            if(inv.xero_SubTotal__c==null){
                inv.xero_SubTotal__c='0';
            }        
            if(inv.xero_TotalTax__c==null){
                inv.xero_TotalTax__c='0';
            }
            if(inv.xero_Total__c==null){
                inv.xero_Total__c='0';
            }
            if(inv.xero_TotalDiscount__c==null){
                inv.xero_TotalDiscount__c='0';
            }
            if(inv.xero_AmountPaid__c==null){
                inv.xero_AmountPaid__c='0';
            }   
            if(inv.xero_CISDeduction__c==null){
                inv.xero_CISDeduction__c='0';
            }
            if(inv.xero_AmountCredited__c==null){
                inv.xero_AmountCredited__c='0';
            }
            if(inv.xero_url__c==null || inv.xero_url__c=='null'){
                inv.xero_url__c='https://www.xero.com/';
            }
            
            if(inv.XERO_Quantity__c==null){
                inv.XERO_Quantity__c='0';
            }
            
            if(inv.XERO_UnitAmount__c==null){
                inv.XERO_UnitAmount__c='0';
            }
            
            if(inv.XERO_AccountCode__c==null){
                inv.XERO_AccountCode__c='0';
            }
            
            Tracking tk=new Tracking();
            tk.Name=inv.xero_Name__c;
            tk.Option=inv.xero_Name__c;
            List<LineItem> lilist=new List<LineItem>();
            
            String inv_itemcode=inv.XERO_Items_Map__c;
            
            if(inv_itemcode==null){
                inv_itemcode=getItemsMap(inv.Id);
            }
            
            //extract itemsmap
            List<Object> itemsmap=new List<Object>();
            try{
                itemsmap=(List<Object>)JSON.deserializeUntyped(inv_itemcode);
            }catch(Exception ex){
                System.debug('Exception: '+ex);
            }
           
            //prepare items map
            Map<String,String> itemcodemap=new Map<String,String>();
            for(Items__c itm:[select xero_code__c,xero_accountcode__c 
                              from items__c 
                              where xero_code__c!=null 
                              and xero_accountcode__c!=null]){
                itemcodemap.put(itm.xero_code__c,itm.xero_accountcode__c);
            }
           
            
            if(itemsmap!=null){
                for(Object itemcode:itemsmap){
                    Map<String,Object> item=(Map<String,object>)itemcode;
                    for(String code:item.keyset()){
                        Map<String,object> mp=(Map<String,Object>)item.get(code);
                        LineItem li=new LineItem();
                        li.Description=(String)mp.get('Description');
                            //inv.xero_description__c;
                        li.Quantity=(String)mp.get('Quantity');
                        li.UnitAmount=(String)mp.get('UnitPrice');
                    
                        li.Tracking=new List<Tracking>{tk};
                         li.TaxType=(String)mp.get('Taxtype');
                     //   if(accountcode_label){
                        if(code!=null && itemcodemap.containsKey(code)){
                            li.AccountCode=itemcodemap.get(code);
                        }else{
                            if(inv!=null && inv.xero_region__c!=null && inv.xero_region__c.equals('UK')){
                            	li.AccountCode=system.label.xero_uk_dummy_account_code;
                            }
							else{
                            	li.AccountCode=system.label.xero_aus_dummy_account_code;
                            }
                        }
                                //taxacccodemap.get(li.TaxType);
                      //  }
                                //inv.XERO_AccountCode__c;
                            //inv.XERO_TaxType__c;
                            li.ItemCode=code;                       
                        lilist.add(li); 
                    }
                }            
            }
            //check admin fee invoiced?
           /* try{
                Case cs=[select Id,Admin_Fees_Invoiced__c,Provision_of_office_services__c
                         from case 
                         where Id=:inv.case__c 
                         limit 1];
                LineItem li=new LineItem();
                li.Description=inv.xero_description__c;
                li.Quantity='1';
                if(cs.Provision_of_office_services__c!=null)
                    li.UnitAmount=''+cs.Provision_of_office_services__c;
                else
                    li.UnitAmount='0';
               // li.AccountCode=inv.XERO_AccountCode__c;
                li.Tracking=new List<Tracking>{tk};
                    li.ItemCode=[select name,xero_code__c 
                                 from items__c 
                                 where name='Admin Fee' 
                                 and xero_itemId__c!=null 
                                 limit 1].xero_code__c;
                li.TaxType=inv.XERO_TaxType__c;
                lilist.add(li); 
            }catch(Exception ex){
                System.debug('Exception: '+ex);
            } */
            
            String xcontactId='';
            // try{
            if(inv.XERO_ContactID__c!=null){
                xcontactId=inv.xero_contactId__c;            	
            }else{
                try{
               // contact con=[select Id,name,xero_contactId__c from contact where Id=:inv.Customer_Id__c];
                   // update con;
                    Contact con=[select Id,name,xero_contactId__c from contact where Id=:inv.Customer_Id__c];
                    if(con.XERO_ContactID__c!=null){
                        xcontactId=con.XERO_ContactID__c;
                    }
                }catch(Exception ex){
                    System.debug(ex.getStackTraceString());
                } 
            }
            /*else{
xcontactId=[SELECT Id,xero_contactId__c from contact where xero_contactId__c!=null limit 1].xero_contactId__c;
}
}catch(Exception ex){
System.debug('Exception: '+ex);
}*/
            xContact con=new xContact();
            con.ContactId=xcontactId;
            
            /*  String constr=;
if(constr.contains('\"{')){
constr=constr.replace('\"{','{');
}
if(constr.contains('\"}')){
constr=constr.replace('\"}','}');
}
if(constr.contains('\"[')){
constr=constr.replace('\"[','[');
}
if(constr.contains('\"]')){
constr=constr.replace('\"]',']');
}
System.debug('constr:'+constr);
*/
            
            String LineAmountTypes='';
            if(inv.Transaction_Type__c.equals('Inclusive of GST / VAT')){
                LineAmountTypes='Inclusive';
            }
            else if(inv.Transaction_Type__c.equals('Exclusive of GST / VAT')){
                LineAmountTypes='Exclusive';
            }
            else if(inv.Transaction_Type__c.equals('NOTAX')){
                LineAmountTypes='NoTax'; 
            }
            
            String status=System.Label.XERO_Invoice_Status;
            // String lnstr=
            String body='{\"Type\":\"'+inv.xero_type__c+'\",'+
                '\"Contact\":'+JSON.serialize(con)+','+            
                '\"LineItems\":'+JSON.serialize(lilist)+','+
                '\"InvoiceNumber\":\"'+inv.Invoice_Number__c+'\",'+
                '\"LineAmountTypes\":\"'+LineAmountTypes+'\",'+
                '\"Status\":\"'+status+'\",'+
                '\"Date\":\"'+inv.Date_of_issue__c+'\",'+
                '\"DueDate\":\"'+inv.Due_Date__c+'\",'+
                '\"Name\":\"'+inv.xero_Name__c+
                '\"';
            
            /*
// '\"Date\":\"'+inv.xero_Date__c+'\",'+
// '\"DueDate\":\"'+inv.xero_DueDate__c+'\",'+
'\"Status\":\"'+inv.xero_Status__c+'\",'+
//   '\"LineAmountTypes\":\"'+inv.xero_LineAmountTypes__c+'\",'+
'\"SubTotal\":\"'+Integer.valueOf(inv.xero_SubTotal__c)+'\",'+
'\"TotalTax\":\"'+Integer.valueOf(inv.xero_TotalTax__c)+'\",'+
'\"Total\":\"'+Integer.valueOf(inv.xero_Total__c)+'\",'+
'\"TotalDiscount\":\"'+Integer.valueOf(inv.xero_TotalDiscount__c)+'\",'+
// '\"UpdatedDateUTC\":\"'+inv.xero_UpdatedDateUTC__c+'\",'+
'\"CurrencyCode\":\"'+inv.xero_CurrencyCode__c+'\",'+
'\"CurrencyRate\":\"'+Integer.valueOf(inv.xero_CurrencyRate__c)+'\",'+
// '\"InvoiceID\":\"'+inv.xero_InvoiceID__c+'\",'+
'\"InvoiceNumber\":\"'+inv.xero_InvoiceNumber__c+'\",'+
'\"Reference\":\"'+inv.xero_Reference__c+'\",'+
// '\"BrandingThemeID\":\"'+inv.xero_BrandingThemeID__c+'\",'+
'\"Url\":\"'+inv.xero_Url__c+'\",'+
'\"SentToContact\":\"'+Boolean.valueOf(inv.xero_SentToContact__c)+'\",'+
// '\"ExpectedPaymentDate\":\"'+inv.xero_ExpectedPaymentDate__c+'\",'+
// '\"PlannedPaymentDate\":\"'+inv.xero_PlannedPaymentDate__c+'\",'+
'\"HasAttachments\":\"'+inv.xero_HasAttachments__c+'\",'+
// '\"Payments\":\"'+inv.xero_Payments__c+'\",'+
//  '\"CreditNotes\":\"'+inv.xero_CreditNotes__c+'\",'+
// '\"Prepayments\":\"'+inv.xero_Prepayments__c+'\",'+
//  '\"Overpayments\":\"'+inv.xero_Overpayments__c+'\",'+
// '\"AmountDue\":\"'+inv.xero_AmountDue__c+'\",'+
'\"AmountPaid\":\"'+Integer.valueOf(inv.xero_AmountPaid__c)+'\",'+
'\"CISDeduction\":\"'+Integer.valueOf(inv.xero_CISDeduction__c)+'\",'+
// '\"FullyPaidOnDate\":\"'+inv.xero_FullyPaidOnDate__c+'\",'+
'\"AmountCredited\":\"'+Integer.valueOf(inv.xero_AmountCredited__c)+'\",'+
'\"Description\":\"'+inv.xero_Description__c+'\",'+
'\"Quantity\":\"'+inv.xero_Quantity__c+'\",'+
'\"UnitAmount\":\"'+inv.xero_UnitAmount__c+'\",'+
'\"ItemCode\":\"'+inv.xero_ItemCode__c+'\",'+
'\"AccountCode\":\"'+inv.xero_AccountCode__c+'\",'+
'\"LineItemID\":\"'+inv.xero_LineItemID__c+'\",'+
'\"TaxType\":\"'+inv.xero_TaxType__c+'\",'+
'\"TaxAmount\":\"'+inv.xero_TaxAmount__c+'\",'+
'\"LineAmount\":\"'+inv.xero_LineAmount__c+'\",'+
'\"DiscountRate\":\"'+inv.xero_DiscountRate__c+'\",'+
'\"DiscountAmount\":\"'+inv.xero_DiscountAmount__c+'\",'+
'\"Tracking\":\"'+inv.xero_Tracking__c+
//  '\"TrackingCategoryID\":\"'+inv.xero_TrackingCategoryID__c+  */
            
            
            
            
            // System.debug('params: '+params);
            HttpRequest req = new HttpRequest();
            req.setEndpoint(tokenuri);
            
            //update record
            if(inv.XERO_InvoiceID__c!=null){   
                body+=',\"InvoiceID\":\"'+inv.XERO_InvoiceID__c+'\"}';
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
            inv.xero_response__c=resp;
            JSONParser parser = JSON.createParser(resp);
            while (parser.nextToken() != null) {
                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME)){
                    String fieldName = parser.getText();
                    parser.nextToken();
                   /* if(fieldName == 'Type') {
                        inv.XERO_Type__c = getString(parser.getText());
                    } */
                    if(fieldName == 'Date') {
                        inv.XERO_Date__c = getString(parser.getText());
                    } 
                    if(fieldName == 'DueDate') {
                        inv.XERO_DueDate__c = getString(parser.getText());
                    }   
                    if(fieldName == 'Status') {
                        inv.XERO_Status__c = getString(parser.getText());
                    }   
                    if(fieldName == 'LineAmountTypes') {
                        inv.XERO_LineAmountTypes__c = getString(parser.getText());
                    }   
                    if(fieldName == 'LineItems') {
                        inv.XERO_LineItems__c = getString(parser.getText());
                    }   
                    if(fieldName == 'SubTotal') {
                        inv.XERO_SubTotal__c = getString(parser.getText());
                    }   
                    if(fieldName == 'TotalTax') {
                        inv.XERO_TotalTax__c = getString(parser.getText());
                    }   
                    if(fieldName == 'TotalDiscount') {
                        inv.XERO_TotalDiscount__c = getString(parser.getText());
                    }   
                    if(fieldName == 'UpdatedDateUTC') {
                        inv.XERO_UpdatedDateUTC__c = getString(parser.getText());
                    }   
                    if(fieldName == 'CurrencyCode') {
                        inv.XERO_CurrencyCode__c = getString(parser.getText());
                    }   
                    if(fieldName == 'CurrencyRate') {
                        inv.XERO_CurrencyRate__c = getString(parser.getText());
                    }   
                    if(fieldName == 'InvoiceID') {
                        inv.XERO_InvoiceID__c = getString(parser.getText());
                    }   
                    if(fieldName == 'InvoiceNumber') {
                        inv.XERO_InvoiceNumber__c = getString(parser.getText());
                    }   
                    if(fieldName == 'Reference') {
                        inv.XERO_Reference__c = getString(parser.getText());
                    }   
                    if(fieldName == 'BrandingThemeID') {
                        inv.XERO_BrandingThemeID__c = getString(parser.getText());
                    }   
                    if(fieldName == 'Url') {
                        inv.XERO_Url__c = getString(parser.getText());
                    }   
                    if(fieldName == 'SentToContact') {
                        inv.XERO_SentToContact__c = getBoolean(parser.getText());
                    }   
                    if(fieldName == 'ExpectedPaymentDate') {
                        inv.XERO_ExpectedPaymentDate__c = getString(parser.getText());
                    }   
                    if(fieldName == 'PlannedPaymentDate') {
                        inv.XERO_PlannedPaymentDate__c = getString(parser.getText());
                    }   
                    if(fieldName == 'HasAttachments') {
                        inv.XERO_HasAttachments__c = getBoolean(parser.getText());
                    }   
                    if(fieldName == 'Payments') {
                        inv.XERO_Payments__c = getString(parser.getText());
                    }   
                    if(fieldName == 'CreditNotes') {
                        inv.XERO_CreditNotes__c = getString(parser.getText());
                    }
                    if(fieldName == 'Prepayments') {
                        inv.XERO_Prepayments__c = getString(parser.getText());
                    }
                    if(fieldName == 'Overpayments') {
                        inv.XERO_Overpayments__c = getString(parser.getText());
                    }
                    if(fieldName == 'AmountDue') {
                        inv.XERO_AmountDue__c = getString(parser.getText());
                    }
                    if(fieldName == 'AmountPaid') {
                        inv.XERO_AmountPaid__c = getString(parser.getText());
                    }
                    if(fieldName == 'CISDeduction') {
                        inv.XERO_CISDeduction__c = getString(parser.getText());
                    }
                    if(fieldName == 'FullyPaidOnDate') {
                        inv.XERO_FullyPaidOnDate__c = getString(parser.getText());
                    }
                    if(fieldName == 'AmountCredited') {
                        inv.XERO_AmountCredited__c = getString(parser.getText());
                    }
                    if(fieldName == 'Description') {
                        inv.XERO_Description__c = getString(parser.getText());
                    }
                    if(fieldName == 'Quantity') {
                        inv.XERO_Quantity__c = getString(parser.getText());
                    }
                    if(fieldName == 'UnitAmount') {
                        inv.XERO_UnitAmount__c = getString(parser.getText());
                    }
                    if(fieldName == 'ItemCode') {
                        inv.XERO_ItemCode__c = getString(parser.getText());
                    }
                    if(fieldName == 'AccountCode') {
                        inv.XERO_AccountCode__c = getString(parser.getText());
                    }
                    if(fieldName == 'LineItemID') {
                        inv.XERO_LineItemID__c = getString(parser.getText());
                    }
                  /*  if(fieldName == 'TaxType') {
                        inv.XERO_TaxType__c = getString(parser.getText());
                    } */
                    if(fieldName == 'TaxAmount') {
                        inv.XERO_TaxAmount__c = getString(parser.getText());
                    }
                    if(fieldName == 'LineAmount') {
                        inv.XERO_LineAmount__c = getString(parser.getText());
                    }
                    if(fieldName == 'DiscountRate') {
                        inv.XERO_DiscountRate__c = getString(parser.getText());
                    }
                    if(fieldName == 'DiscountAmount') {
                        inv.XERO_DiscountAmount__c = getString(parser.getText());
                    }
                    if(fieldName == 'Tracking') {
                        inv.XERO_Tracking__c = getString(parser.getText());
                    }
                    if(fieldName == 'Name') {
                        inv.XERO_Name__c = getString(parser.getText());
                    }
                    if(fieldName == 'TrackingCategoryID') {
                        inv.XERO_TrackingCategoryID__c = getString(parser.getText());
                    }
                }
            }
            
            //update xero accountId  
            if(inv.Xero_Items_Map__c==null){
                inv.Xero_Items_Map__c=inv_itemcode;
            }  
            if(inv.XERO_ContactID__c==null){
                inv.XERO_ContactID__c=xcontactId;
            }
            update inv;
        }
    } 
    public class LineItem{
        public String ItemCode;
        public String Description;
        public String Quantity;
        public String UnitAmount;
        public String AccountCode;  
        public List<Tracking> Tracking;
        public String TaxType;
    }
    public class Tracking{
        public String Name;
        public String Option;
    }
    public class xContact{
        public String ContactID;
    }
    public static String getString(String s){
        String result='';
        if(s!=null){
            try{
                result=String.valueOf(s);
            }catch(Exception ex){
                System.debug('Exception: '+ex);
            }
        }
        return result;
    }
    public static Boolean getBoolean(String s){
        Boolean result=false;
        if(s!=null){
            try{
                result=Boolean.valueOf(s);
            }catch(Exception ex){
                System.debug('Exception: '+ex);
            }
        }
        return result;
    }
    public static String getItemsMap(String p_invId){
        String resp='';    
        String region=''; 
        Invoice__c inv;
        List<Map<String,Object>> itemslist=new List<Map<String,Object>>();
        try{
            inv=[select xero_region__c, case__r.Admin_Fees_Invoiced__c,case__r.Provision_of_office_services__c
                 from invoice__c
                 where Id=:p_invId];
            if(inv!=null && inv.XERO_Region__c!=null){
                region=inv.XERO_Region__c;
            }
            List<Milestone__c> mslist=[select Id,SentToMyOB__c, Name,Date__c,Quantity__c,Milestone_Value__c,case__c,Type__c,Item_Description__c,
                             Item_Name__c,Qty_Type__c,Tax_Type__c,Allocate_To__c,MyOB_Item_Id__c,invoice__c,
                             XERO_UK_Items__c,Xero_UK_Items__r.Name,xero_uk_items__r.xero_code__c,XERO_UK_Tax_Type__c,
                             XERO_AUS_Items__c,Xero_AUS_Items__r.Name,xero_Aus_items__r.xero_code__c,XERO_Aus_Tax_Type__c,
                             XERO_Milestone_Value__c,unitprice__c,xero_items__r.xero_code__c, recordtypeId,recordtype.name
                             from milestone__c 
                             where invoice__c=:p_invId];
            
            List<Disbursements__c> dmlist=[Select Id,name,Item_Code__c,Item_Description__c,Date_of_Transaction__c,Date__c,Type__c,Milestone_Value__c,
                                 Total_value_of_transaction__c,Quantity__c, invoice__c,Case__c,Tax_Type__c,Allocate_To__c, 
                                 xero_UK_items__c, XERO_UK_Items__r.Name, xero_uk_items__r.xero_code__c,XERO_UK_Tax_Type__c,
                                 xero_Aus_items__c, XERO_Aus_Items__r.Name, xero_Aus_items__r.xero_code__c,XERO_Aus_Tax_Type__c,
                                 XERO_Milestone_Value__c, xero_items__r.xero_code__c,Xero_Items__r.Name,XERO_Items__c,
                                 unitprice__c,recordtypeId,recordtype.name
                                 from disbursements__c 
                                 where invoice__c=:p_invId];
            
            List<Commission_milestone__c> commlist=[Select Id,name,Item_Name__c,Item_Description__c,Milestone_Billable_Date__c,Date__c,Type__c,Commission_Amount__c,
                                        Quantity__c, invoice__c,Case__c,Tax_Type__c,Allocate_To__c, 
                                        xero_UK_items__c, XERO_UK_Items__r.Name, xero_uk_items__r.xero_code__c,XERO_UK_Tax_Type__c,
                                        xero_AUS_items__c, XERO_Aus_Items__r.Name, xero_Aus_items__r.xero_code__c,XERO_Aus_Tax_Type__c,
                                        XERO_Milestone_Value__c,Billing_Entity__r.Name,Course__c, Billing_Entity__c,                                
                                        recordtypeId,recordtype.name,student_Id__c
                                        from Commission_Milestone__c
                                        where invoice__c=:p_invId];
            
            //add all items in set
            set<Id> itemset=new Set<Id>();
            for(Milestone__c ms:mslist){
                if(ms.XERO_AUS_Items__c!=null){
                	itemset.add(ms.XERO_AUS_Items__c);
                }
                if(ms.XERO_UK_Items__c!=null){
                	itemset.add(ms.XERO_UK_Items__c);
                }
            }
             for(Disbursements__c dm:dmlist){
                if(dm.XERO_AUS_Items__c!=null){
                	itemset.add(dm.XERO_AUS_Items__c);
                }
                if(dm.XERO_UK_Items__c!=null){
                	itemset.add(dm.XERO_UK_Items__c);
                }
            }
            for(Commission_Milestone__c cm:commlist){
                if(cm.XERO_AUS_Items__c!=null){
                	itemset.add(cm.XERO_AUS_Items__c);
                }
                if(cm.XERO_UK_Items__c!=null){
                	itemset.add(cm.XERO_UK_Items__c);
                }
            }
            Map<Id,String> itemsmap=new Map<Id,String>();
            for(Items__c itm:[select Id,xero_code__c,xero_itemId__c from items__c where Id IN:itemset
                             and xero_code__c!=null
                             and xero_itemid__c!=null]){
                itemsmap.put(itm.Id,itm.xero_code__c);
            }
            String admintaxtype='';
             for(Milestone__c ms:mslist               
               ){                   
                   Map<String,String> amountsmap=new Map<String,String>();                                           
                   amountsmap.put('Quantity',String.valueOf(ms.Quantity__c));
                   amountsmap.put('UnitPrice',String.valueOf(ms.milestone_value__c));
                   amountsmap.put('Description',ms.Item_Description__c);
                   if(region.containsIgnoreCase('UK')){
                       if(ms.XERO_UK_Tax_Type__c!=null && ms.XERO_UK_Tax_Type__c!=''){
                           amountsmap.put('Taxtype',ms.XERO_UK_Tax_Type__c);
                           if(admintaxtype==''){
                               admintaxtype=ms.XERO_UK_Tax_Type__c;
                           }
                           if(ms.XERO_UK_Items__c!=null && itemsmap.containsKey(ms.XERO_UK_Items__c)){
                               itemslist.add(new Map<String,Object>{itemsmap.get(ms.XERO_UK_Items__c)=>amountsmap});
                           }  
                       }
                   }else{
                       if(ms.XERO_AUS_Tax_Type__c!=null && ms.XERO_AUS_Tax_Type__c!=''){
                           amountsmap.put('Taxtype',ms.XERO_Aus_Tax_Type__c);
                           if(admintaxtype==''){
                               admintaxtype=ms.XERO_Aus_Tax_Type__c;
                           }
                           if(ms.XERO_Aus_Items__c!=null && itemsmap.containsKey(ms.XERO_Aus_Items__c)){
                               itemslist.add(new Map<String,Object>{itemsmap.get(ms.XERO_Aus_Items__c)=>amountsmap});
                           }                       
                   }
                   }
               }           
            System.debug('mslist:'+mslist);
            //deserialize disbursements            
           
            for(Disbursements__c dm:dmlist
               ){
                   Map<String,String> amountsmap=new Map<String,String>();
                   amountsmap.put('Quantity',String.valueOf(dm.Quantity__c));
                   amountsmap.put('UnitPrice',String.valueOf(dm.milestone_value__c));  
                   amountsmap.put('Description',dm.Item_Description__c);
                   if(region.containsIgnoreCase('UK')){
                       if(dm.XERO_UK_Tax_Type__c!=null && dm.XERO_UK_Tax_Type__c!=''){
                           amountsmap.put('Taxtype',dm.XERO_UK_Tax_Type__c);
                            if(admintaxtype==''){
                               admintaxtype=dm.XERO_UK_Tax_Type__c;
                           }
                           if(dm.XERO_UK_Items__c!=null && itemsmap.containsKey(dm.XERO_UK_Items__c)){
                               itemslist.add(new Map<String,Object>{itemsmap.get(dm.XERO_UK_Items__c)=>amountsmap});
                           }
                       }
                   }else{
                       if(dm.Xero_Aus_Tax_Type__c!=null && dm.Xero_Aus_Tax_Type__c!=''){
                           amountsmap.put('Taxtype',dm.XERO_Aus_Tax_Type__c);
                           if(admintaxtype==''){
                               admintaxtype=dm.XERO_Aus_Tax_Type__c;
                           }
                           if(dm.XERO_AUS_Items__c!=null && itemsmap.containsKey(dm.XERO_AUS_Items__c)){
                               itemslist.add(new Map<String,Object>{itemsmap.get(dm.XERO_AUS_Items__c)=>amountsmap});
                           }
                       }
                   }
                  
               }            
           
            System.debug('commlist:'+commlist);
            
            for(Commission_Milestone__c comm:commlist){
                Map<String,String> amountsmap=new Map<String,String>();
                amountsmap.put('Quantity',String.valueOf(comm.Quantity__c));
                amountsmap.put('UnitPrice',String.valueOf(comm.commission_amount__c)); 
                amountsmap.put('Description',comm.Item_Description__c);
                if(region.containsIgnoreCase('UK')){
                    if(comm.XERO_UK_Tax_Type__c!=null && comm.XERO_UK_Tax_Type__c!=''){
                        amountsmap.put('Taxtype',comm.XERO_UK_Tax_Type__c);
                        if(admintaxtype==''){
                               admintaxtype=comm.XERO_UK_Tax_Type__c;
                           }
                        if(comm.XERO_UK_Items__c!=null && itemsmap.containsKey(comm.XERO_UK_Items__c)){
                            itemslist.add(new Map<String,Object>{itemsmap.get(comm.XERO_UK_Items__c)=>amountsmap});
                        }
                    }
                }else{
                    if(comm.Xero_Aus_Tax_Type__c!=null && comm.Xero_Aus_Tax_Type__c!=''){
                        amountsmap.put('Taxtype',comm.XERO_Aus_Tax_Type__c);
                        if(admintaxtype==''){
                               admintaxtype=comm.XERO_Aus_Tax_Type__c;
                           }
                        if(comm.XERO_AUS_Items__c!=null && itemsmap.containsKey(comm.XERO_AUS_Items__c)){
                            itemslist.add(new Map<String,Object>{itemsmap.get(comm.XERO_AUS_Items__c)=>amountsmap});
                        }
                    }
                } 
                
            }
            // Admin Fee
            if(inv.case__r.Admin_Fees_Invoiced__c){
                Map<String,String> amountsmap=new Map<String,String>();                                           
                    amountsmap.put('Quantity','1');
                    amountsmap.put('UnitPrice',String.valueOf(inv.case__r.Provision_of_office_services__c));
                String xero_code='';
                    if(region.containsIgnoreCase('UK')){
                        amountsmap.put('Taxtype',admintaxtype);
                        xero_code=[select name,xero_code__c 
                                   from items__c 
                                   where name='Admin Fee' 
                                   and xero_itemId__c!=null 
                                   and Recordtype.name='XERO UK'
                                   limit 1].xero_code__c;
                    }
                    else{
                        amountsmap.put('Taxtype',admintaxtype);
                        xero_code=[select name,xero_code__c 
                                   from items__c 
                                   where name='Admin Fee' 
                                   and Recordtype.name='XERO AUS'
                                   and xero_itemId__c!=null 
                                   limit 1].xero_code__c;
                    }
                    
                    amountsmap.put('Description','Admin fees');
                    
                    itemslist.add(new Map<String,Object>{xero_code=>amountsmap});
                
            }
            resp=JSON.serialize(itemslist);
        }catch(Exception ex){
            System.debug('Exception:'+ex+'\n'+ex.getStackTraceString());            
        }
        return resp;
    }
}