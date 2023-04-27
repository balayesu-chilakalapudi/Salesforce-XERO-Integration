@isTest
public class XEROAccountSyncBatchTest {
	@isTest
    static void test1(){
        XERO__c xr=new XERO__c();
        xr.name='Ryan Henderson';
        xr.tenant_id__c='test';
        insert xr;
        Account acc=new Account();
        acc.name='TEST';
        insert acc;
        XEROAccountSyncBatch xb=new XEROAccountSyncBatch();
        xb.execute(null);
        xb.scheduleMe();
        database.executeBatch(xb);
    }
}