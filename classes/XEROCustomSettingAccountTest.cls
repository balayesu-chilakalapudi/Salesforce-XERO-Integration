@isTest
public class XEROCustomSettingAccountTest {
	@isTest
    static void test1(){
        XERO_Account__c xa=new XERO_Account__c();
        xa.name='test';
        xa.XERO_Region__c='UK';
        xa.XERO_TaxType__c='INPUT2';
        insert xa;
        XERO__c xr=new XERO__c();
        xr.name='Ryan Henderson';
        xr.client_id__c='test';
        xr.client_secret__c='test';
        xr.tenant_id__c='test';
        insert xr;
        String name='test';
         TEST.startTest();
        Test.setMock(HttpCalloutMock.class, new XEROCustomSettingAccountMock());        
        XEROCustomSettingAccount.sendCSAccountToXERO(name);
        Test.stopTest();
    }
     public class XEROCustomSettingAccountMock implements HttpCalloutMock {
        // Implement this interface method
        public  HTTPResponse respond(HTTPRequest req) {      
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"start":0,"count":235,"data":[{"id":84,"firstName":"D","lastName":"Xie","email":null,"phone":null,"address":{"address1":null,"address2":null,"city":null,"state":null,"zip":null,"countryID":1,"countryName":"United States","countryCode":"US"},"lead":{"id":23},"owner":{"id":1,"firstname":"abc","lastname":"test"},"clientCorporation":{"id":1,"name":"test"}}]}');
            res.setStatusCode(200);
            res.setStatus('OK');
            return res;
        }
        
    }
}