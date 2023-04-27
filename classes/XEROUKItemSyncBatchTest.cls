@isTest
public class XEROUKItemSyncBatchTest {
	@isTest
    static void test1(){
        XERO__c xr=new XERO__c();
        xr.name='Ryan Henderson';
        xr.tenant_id__c='test';
        insert xr;
        Items__c itm=new Items__c();
        itm.Name='Test';
        itm.RecordTypeId=Schema.SObjectType.Items__c.getRecordTypeInfosByName().get('XERO UK').getRecordTypeId();
        insert itm; 
        XEROUKItemSyncBatch xb=new XEROUKItemSyncBatch();
        Test.startTest();
         Test.setMock(HttpCalloutMock.class, new XEROUKItemSyncMockHttpResponseGenerator());   
        xb.execute(null);
        xb.scheduleMe();       
        Test.stopTest();
    }
    public class XEROUKItemSyncMockHttpResponseGenerator implements HttpCalloutMock {
        // Implement this interface method
        public  HTTPResponse respond(HTTPRequest req) {      
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"Items":[{"ItemId":"abcd"}],"start":0,"count":235,"data":[{"id":84,"firstName":"D","lastName":"Xie","email":null,"phone":null,"address":{"address1":null,"address2":null,"city":null,"state":null,"zip":null,"countryID":1,"countryName":"United States","countryCode":"US"},"lead":{"id":23},"owner":{"id":1,"firstname":"abc","lastname":"test"},"clientCorporation":{"id":1,"name":"test"}}]}');
            res.setStatusCode(200);
            res.setStatus('OK');
            return res;
        }        
    }
}