@isTest
public class XEROContactSyncBatchTest {
	@isTest
    static void test1(){
        XERO__c xr=new XERO__c();
        xr.name='Ryan Henderson';
        xr.tenant_id__c='test';
        insert xr;
        Account acc=new Account();
        acc.name='TEST';
        acc.XERO_Region__c='UK';
        insert acc;
        Contact Cont = new Contact(AccountId=Acc.Id, LastName = 'TLastnam4',email='testname4@test.com');
        insert Cont;
        XEROContactSyncBatch xb=new XEROContactSyncBatch();
        xb.execute(null);
        xb.scheduleMe();
        database.executeBatch(xb);
    }
}