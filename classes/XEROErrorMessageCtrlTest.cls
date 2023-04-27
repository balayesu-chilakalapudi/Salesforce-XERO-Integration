@isTest
public class XEROErrorMessageCtrlTest {
	@isTest
    static void test1(){
        List<XERO__c> xrlist=new List<XERO__c>();
        XERO__c xr=new XERO__c();
        xr.name='Ryan Henderson';
        xr.access_token_part1__c='test1';
        xrlist.add(xr);
         XERO__c xr2=new XERO__c();
        xr2.name='Tandin Dorji';
        xr2.access_token_part1__c='test1';
        xrlist.add(xr2);
        insert xrlist;
        
         Case cs=new Case();
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
        inv.Xero_Items_Map__c=JSON.serialize(itemsmap);
        inv.XERO_TaxType__c='INPUT2';
         inv.XERO_Response__c='Message:abcd\nMessage:xyz';
        insert inv;          
       
        String p_recordId=inv.Id;
        XEROErrorMessageCtrl.getErrorMessage(p_recordId);
    }
}