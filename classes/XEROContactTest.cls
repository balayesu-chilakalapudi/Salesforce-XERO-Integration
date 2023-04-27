@isTest
public class XEROContactTest {
    @isTest
    static void test1(){
        XERO__c xr=new XERO__c();
        xr.name='Ryan Henderson';
        xr.tenant_id__c='test';
        insert xr;
        Account acc=new Account();
        acc.name='TEST';
        acc.xero_region__c='UK';
        insert acc;
        Contact Cont = new Contact(AccountId=Acc.Id, LastName = 'TLastnam4',email='testname4@test.com');
        insert Cont;
        cont=[select xero_region__c from contact where Id=:cont.Id];
        System.assertEquals('UK',cont.XERO_Region__c);
        String p_constr=JSON.serialize(cont);
        String p_region='UK';
        TEST.startTest();
        Test.setMock(HttpCalloutMock.class, new XEROContactMockHttpResponseGenerator());
        XEROContact.sendContactToXERO(p_constr,'UK');
        TEST.stopTest();
    }   
    public class XEROContactMockHttpResponseGenerator implements HttpCalloutMock {
        // Implement this interface method
        public  HTTPResponse respond(HTTPRequest req) {      
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"Contacts":[{"AccountNumber":"test"}],"start":0,"count":235,"data":[{"id":84,"firstName":"D","lastName":"Xie","email":null,"phone":null,"address":{"address1":null,"address2":null,"city":null,"state":null,"zip":null,"countryID":1,"countryName":"United States","countryCode":"US"},"lead":{"id":23},"owner":{"id":1,"firstname":"abc","lastname":"test"},"clientCorporation":{"id":1,"name":"test"}}]}');
            res.setStatusCode(200);
            res.setStatus('OK');
            return res;
        }
        
    }
}