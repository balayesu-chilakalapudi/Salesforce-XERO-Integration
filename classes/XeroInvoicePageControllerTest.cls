@isTest
public class XeroInvoicePageControllerTest {
	@isTest
    static void test1(){
        List<Account> acclist=new List<Account>();
        Account acc=new Account();
        acc.name='TEST1';
        acc.xero_region__c='UK';
        acc.XERO_ContactID__c='acc test';
        acclist.add(acc);    
        
        Account bacc=new Account();
        bacc.name='TEST2';
        bacc.xero_region__c='UK';
        bacc.XERO_ContactID__c='bill acc test';
        acclist.add(bacc);    
        
        Account eacc=new Account();
        eacc.name='TEST3';
        eacc.xero_region__c='UK';
        eacc.XERO_ContactID__c='edu acc test';
        acclist.add(eacc);
        insert acclist;
        
        Contact con=new Contact();
        con.lastname='TEST21jan2020';
        con.accountId=acc.Id;
        con.Email='test21jan2020@test.com';
        con.XERO_ContactID__c='con test';
        insert con;
        
        Case cs=new Case();
        cs.AccountId=acc.Id;
        cs.ContactId=con.Id;
        cs.subject='TEST';
        cs.Amount__c=1;
        cs.Provision_of_office_services__c=10;
        cs.Expected_Close_Date__c=system.today()+28;
        cs.Organisational_Contact__c=con.Id;
        cs.Dependent_Contact__c=con.Id;
        insert cs;
        
        String caseId=cs.Id;
        Invoice__c inv=new Invoice__c();
        inv.Case__c=cs.Id;
        inv.XERO_ContactID__c=con.XERO_ContactID__c;
        inv.Date_of_issue__c=system.today();
        inv.Due_Date__c=system.today();
        inv.XERO_TaxType__c='INPUT2';
        inv.Invoice_Number__c='5873-1';
        inv.Transaction_Type__c='Inclusive of GST / VAT';
       // insert inv;
        
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
        m.RecordTypeId=Schema.SObjectType.Milestone__c.getRecordTypeInfosByName().get('XERO UK').getRecordTypeId();
        m.XERO_UK_Tax_Type__c='INPUT2';
        insert m;
        
        Disbursements__c d=new Disbursements__c();
        d.Case__c=cs.Id;
        d.Date__c=system.today()+28;
        d.Milestone_Value__c=10;
        d.XERO_UK_Items__c=itm.Id;
        d.XERO_UK_Tax_Type__c='INPUT2';
        d.RecordTypeId=Schema.SObjectType.Disbursements__c.getRecordTypeInfosByName().get('XERO UK').getRecordTypeId();
        insert d;
        
        Commission_Milestone__c cm=new Commission_Milestone__c();
        cm.Commission_Amount__c=1;
        cm.Education_Provider__c=eacc.Id;
        cm.Billing_Entity__c=bacc.Id;
        cm.case__c=cs.Id;
        cm.Xero_UK_items__c=itm.Id;
        cm.item_name__c='Student Services PSF';
        cm.XERO_UK_Tax_Type__c='INPUT2';
        cm.RecordTypeId=Schema.SObjectType.Commission_Milestone__c.getRecordTypeInfosByName().get('XERO UK').getRecordTypeId();
        insert cm;
        
        T_C_Milestones__c tcm=new T_C_Milestones__c();
        tcm.Case__c=cs.Id;
        tcm.Date__c=system.today()+28;
        tcm.Milestone_Value__c=30;
        insert tcm;
        
        String tcmId=tcm.Id;
        String selectedMilestones=JSON.serialize(new List<milestone__c>{[select Id,SentToMyOB__c, Name,Date__c,Quantity__c,Milestone_Value__c,case__c,Type__c,Item_Description__c,
                             Item_Name__c,Qty_Type__c,Tax_Type__c,xero_uk_tax_type__c,Allocate_To__c,MyOB_Item_Id__c,invoice__c,XERO_UK_Items__c,Xero_UK_Items__r.Name,
                             XERO_Milestone_Value__c,xero_items__r.xero_code__c,unitprice__c,
                                 recordtypeId,recordtype.name,xero_uk_items__r.xero_code__c
                             from milestone__c] });
        String selectedDisbursements=JSON.serialize(new List<Disbursements__c>{[Select Id,name,Item_Code__c,Item_Description__c,Date_of_Transaction__c,Date__c,Type__c,Milestone_Value__c,
                                 Total_value_of_transaction__c,Quantity__c, invoice__c,Case__c,Tax_Type__c,Allocate_To__c, xero_UK_items__c,xero_uk_tax_type__c,
                                 XERO_UK_Items__r.Name,XERO_Milestone_Value__c,
                                 xero_items__r.xero_code__c,Xero_Items__r.Name,XERO_Items__c,
                                     unitprice__c,recordtypeId,recordtype.name,xero_uk_items__r.xero_code__c                                       
                                 from disbursements__c]});
        String selectedCommissionMilestones=JSON.serialize(new List<Commission_Milestone__c>{[Select Id,name,Item_Description__c,Milestone_Billable_date__c,Date__c,Type__c,Commission_Amount__c,
                                 Quantity__c, invoice__c,Case__c,Tax_Type__c,Allocate_To__c, xero_UK_items__c,xero_uk_tax_type__c,
                                 XERO_UK_Items__r.Name,XERO_Milestone_Value__c,                                
                                     recordtypeId,recordtype.name,xero_uk_items__r.xero_code__c                                       
                                 from Commission_Milestone__c]});
        XeroInvoicePageController.getCaseWrapper(caseId);
        List<XeroInvoicePageController.AdminFees> admlist=new List<XeroInvoicePageController.AdminFees>();
        XeroInvoicePageController.AdminFees adm=new XeroInvoicePageController.AdminFees(cs);
        admlist.add(adm);
        String selectedAdminFee=JSON.serialize(admlist);
        XeroInvoicePageController.processInvoice(inv, selectedMilestones, selectedDisbursements, tcmId, selectedAdminFee,selectedCommissionMilestones,'UK');
    }
}