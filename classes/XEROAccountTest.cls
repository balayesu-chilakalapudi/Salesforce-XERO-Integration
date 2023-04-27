@isTest
public class XEROAccountTest {
    @isTest
    static void test1(){
        XERO__c xr=new XERO__c();
        xr.name='Ryan Henderson';
        xr.tenant_id__c='test';
        insert xr;
        Account acc=new Account();
        acc.name='TEST';
        insert acc;
        String p_accstr=JSON.serialize(acc);
        String p_region='UK';
        TEST.startTest();
        Test.setMock(HttpCalloutMock.class, new XEROAccountMockHttpResponseGenerator());
        XEROAccount.sendAccountToXERO(p_accstr, p_region);
        TEST.stopTest();
    }   
    public class XEROAccountMockHttpResponseGenerator implements HttpCalloutMock {
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