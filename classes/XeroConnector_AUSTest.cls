@isTest
public class XeroConnector_AUSTest {
    @testsetup
    static void testdata(){
        List<XERO__c> xrlist=new List<XERO__c>();
        XERO__c xr=new XERO__c();
        xr.name='Ryan Henderson';
        xr.tenant_id__c='test';
        xr.access_token_part1__c='estabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtes';
        xr.access_token_part2__c='estabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtes';
        xr.access_token_part3__c='estabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtes';
        xr.access_token_part4__c='estabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtes';
        xr.access_token_part5__c='estabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtes';
        xr.access_token_part6__c='estabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtes';
        xr.access_token_part7__c='estabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtes';
        xr.refresh_token__c='estabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtes';
        xrlist.add(xr);        
        XERO__c xr2=new XERO__c();
        xr2.name='Tandin Dorji';
        xr2.tenant_id__c='test';
         xr2.access_token_part1__c='estabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtes';
        xr2.access_token_part2__c='estabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtes';
        xr2.access_token_part3__c='estabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdt';
        xr2.access_token_part4__c='estabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtes';
        xr2.access_token_part5__c='estabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtes';
        xr2.access_token_part6__c='estabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtes';
        xr2.access_token_part7__c='estabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtes';
        xr2.refresh_token__c='estabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtestabcdtes';
   
        xrlist.add(xr2);
        insert xrlist;
    }
    @isTest
    static void test1(){       
        XeroConnector_AUS con=new XeroConnector_AUS();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new XEROConnectorMockHttpResponseGenerator());
        con.XEROAuth();      
        Test.stopTest();
    }
    @isTest
    static void test2(){
        XeroConnector_AUS con=new XeroConnector_AUS();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new XEROConnectorMockHttpResponseGenerator());
        con.AccessToken();
        Test.stopTest();
    }
    @isTest
    static void test3(){
        XeroConnector_AUS con=new XeroConnector_AUS();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new XEROConnectorMockHttpResponseGenerator());
        String XEROConnectorUser=System.Label.XeroConnector_User;
        XeroConnector_AUS.refreshToken(XEROConnectorUser);
        Test.stopTest();
    }
    @isTest
    static void test4(){
        XeroConnector_AUS con=new XeroConnector_AUS();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new XEROConnectorMockHttpResponseGenerator());
        XeroConnector_AUS.getTenants();
        Test.stopTest();
    }
    public class XEROConnectorMockHttpResponseGenerator implements HttpCalloutMock {
        // Implement this interface method
        public  HTTPResponse respond(HTTPRequest req) {      
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"access_token":"testtesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttest","start":0,"count":235,"data":[{"id":84,"firstName":"D","lastName":"Xie","email":null,"phone":null,"address":{"address1":null,"address2":null,"city":null,"state":null,"zip":null,"countryID":1,"countryName":"United States","countryCode":"US"},"lead":{"id":23},"owner":{"id":1,"firstname":"abc","lastname":"test"},"clientCorporation":{"id":1,"name":"test"}}]}');
            res.setStatusCode(200);
            res.setStatus('OK');
            return res;
        }        
    }
}