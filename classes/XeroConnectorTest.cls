@isTest
public class XeroConnectorTest {
    @testsetup
    static void testdata(){
        List<XERO__c> xrlist=new List<XERO__c>();
        XERO__c xr=new XERO__c();
        xr.name='Ryan Henderson';
        xr.tenant_id__c='test';
        xrlist.add(xr);        
        XERO__c xr2=new XERO__c();
        xr2.name='Tandin Dorji';
        xr2.tenant_id__c='test';
        xrlist.add(xr2);
        insert xrlist;
    }
    @isTest
    static void test1(){       
        XeroConnector con=new xeroConnector();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new XEROConnectorMockHttpResponseGenerator());
        con.XEROAuth();      
        Test.stopTest();
    }
    @isTest
    static void test2(){
        XeroConnector con=new xeroConnector();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new XEROConnectorMockHttpResponseGenerator());
        con.AccessToken();
        Test.stopTest();
    }
    @isTest
    static void test3(){
        XeroConnector con=new xeroConnector();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new XEROConnectorMockHttpResponseGenerator());
        String XEROConnectorUser=System.Label.XeroConnector_User;
        XeroConnector.refreshToken(XEROConnectorUser);
        Test.stopTest();
    }
    @isTest
    static void test4(){
        XeroConnector con=new xeroConnector();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new XEROConnectorMockHttpResponseGenerator());
        XeroConnector.getTenants();
        Test.stopTest();
    }
    public class XEROConnectorMockHttpResponseGenerator implements HttpCalloutMock {
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