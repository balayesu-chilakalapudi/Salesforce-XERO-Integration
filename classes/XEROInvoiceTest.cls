@isTest
public class XEROInvoiceTest {
	@isTest
    static void test1(){
         XERO__c xr=new XERO__c();
        xr.name='Ryan Henderson';
        xr.tenant_id__c='test';
        insert xr;
          
         Account acc=new Account();
        acc.name='TEST3';
        acc.xero_region__c='UK';
        acc.XERO_ContactID__c='edu acc test';        
        insert acc;
       
        Case cs=new Case();
        cs.accountId=acc.Id;
        cs.subject='TEST';
        cs.Amount__c=1;
        cs.Provision_of_office_services__c=10;
        cs.Expected_Close_Date__c=system.today()+28;
        insert cs;
         
        Invoice__c inv=new Invoice__c();
        inv.Case__c=cs.Id;
        inv.XERO_Region__c='UK';
       // inv.XERO_ContactID__c='test';
        inv.Xero_Invoice__c=true;
        inv.Date_of_issue__c=system.today();
        inv.Due_Date__c=system.today();
        inv.Transaction_Type__c='Inclusive of GST / VAT';
        List<Map<String,String>> itemsmap=new List<Map<String,String>>();
        Map<String,String> mp=new Map<String,String>();
        itemsmap.add(mp);
        //inv.Xero_Items_Map__c=JSON.serialize(itemsmap);
        inv.XERO_TaxType__c='INPUT2';
        insert inv;        
        
        Items__c itm=new Items__c();
        itm.name='TEST';
        itm.RecordTypeId=Schema.SObjectType.Items__c.getRecordTypeInfosByName().get('XERO UK').getRecordTypeId();
        itm.XERO_ItemID__c='test';
        itm.XERO_Code__c='84873723';
        insert itm;
        
        Milestone__c m=new Milestone__c();
        m.Milestone_Value__c=10;
        m.Case__c=cs.Id;
        m.Date__c=system.today()+28;
        m.XERO_UK_Items__c=itm.Id;
        m.invoice__c=inv.Id;
        m.RecordTypeId=Schema.SObjectType.Milestone__c.getRecordTypeInfosByName().get('XERO UK').getRecordTypeId();
        m.XERO_UK_Tax_Type__c='INPUT2';
        insert m;
        
        Disbursements__c d=new Disbursements__c();
        d.Case__c=cs.Id;
        d.Date__c=system.today()+28;
        d.Milestone_Value__c=10;
        d.XERO_UK_Items__c=itm.Id;
        d.XERO_UK_Tax_Type__c='INPUT2';
        d.invoice__c=inv.Id;
        d.RecordTypeId=Schema.SObjectType.Disbursements__c.getRecordTypeInfosByName().get('XERO UK').getRecordTypeId();
        insert d;
        
        Commission_Milestone__c cm=new Commission_Milestone__c();
        cm.Commission_Amount__c=1;
        cm.Education_Provider__c=acc.Id;
        cm.Billing_Entity__c=acc.Id;
        cm.case__c=cs.Id;
        cm.Xero_UK_items__c=itm.Id;
        cm.item_name__c='Student Services PSF';
        cm.XERO_UK_Tax_Type__c='INPUT2';
        cm.invoice__c=inv.Id;
        cm.RecordTypeId=Schema.SObjectType.Commission_Milestone__c.getRecordTypeInfosByName().get('XERO UK').getRecordTypeId();
        insert cm;
        
        String p_invstr=JSON.serialize(inv);
         Test.startTest();
        Test.setMock(HttpCalloutMock.class, new XeroInvoiceMock());         
        XeroInvoice.sendInvoiceToXERO(p_invstr);
        XeroInvoice.getBoolean('false');
        Test.stopTest();
    }
    public class XeroInvoiceMock implements HttpCalloutMock {
        // Implement this interface method
        public  HTTPResponse respond(HTTPRequest req) {      
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"InvoiceId":"abcd-defg-hijk-lmno","Type":"test","Date":"test","DueDate":"","Status":"","LineAmountTypes":"","LineItems":"","SubTotal":"","TotalTax":"","TotalDiscount":"","UpdatedDateUTC":"","CurrencyCode":"","CurrencyRate":"","InvoiceNumber":"","Reference":"","BrandingThemeID":"","Url":""}');
            res.setStatusCode(200);
            res.setStatus('OK');
            return res;
        }        
    }
}