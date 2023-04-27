@isTest
public class XEROTokenSchedulerTest {
	@isTest
    static void test1(){
        XERO__c xr=new XERO__c();
        xr.name='Tandin Dorji';
        xr.tenant_id__c='test';
        insert xr;
        
        XERO__c xr2=new XERO__c();
        xr2.name='Ryan Henderson';
        xr2.tenant_id__c='test';
        insert xr2;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new XEROTokenMockHttpResponseGenerator());
        XEROTokenScheduler xs=new XEROTokenScheduler();
        xs.scheduleMe();
        xs.execute(null);
        Test.stopTest();
    }
    public class XEROTokenMockHttpResponseGenerator implements HttpCalloutMock {
        // Implement this interface method
        public  HTTPResponse respond(HTTPRequest req) {      
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"access_token":"testtesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttest","start":0,"count":235,"data":[{"id":84,"firstName":"D","lastName":"Xie","email":null,"phone":null,"address":{"address1":null,"address2":null,"city":null,"state":null,"zip":null,"countryID":1,"countryName":"United States","countryCode":"US"},"lead":{"id":23},"owner":{"id":1,"firstname":"abc","lastname":"test"},"clientCorporation":{"id":1,"name":"test"}}]}');
            res.setStatusCode(200);
            res.setStatus('OK');
            return res;
        }        
    }
}