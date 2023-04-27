global class XEROUKItemSyncBatch implements Database.AllowsCallouts,Database.Stateful, Schedulable {    
    //@future(Callout=true)
	public static void syncXEROUKItems(){
        XERO__c xr=Xeroconnector.refreshToken('Ryan Henderson');
          //  XERO__c.getValues('Ryan Henderson');        
        String client_id=xr.client_id__c;
        String redirect_uri=xr.redirect_uri__c;
        String client_secret=xr.client_secret__c;
        String expected_str=(xr.access_token_part1__c+xr.access_token_part2__c+xr.access_token_part3__c+xr.access_token_part4__c+xr.access_token_part5__c+xr.access_token_part6__c+xr.access_token_part7__c);
        if(expected_str.contains('null')){
            expected_str=expected_str.replace('null', '');
        }
        expected_str=expected_str.trim();
        String access_token=expected_str;
        String refresh_token=xr.refresh_token__c;
        String tenantId=xr.tenant_id__c;
        
        System.debug('refresh_token: '+refresh_token);
        System.debug('access_token: '+access_token);
        System.debug('tenant Id: '+tenantId);
        
        //Getting access token from XERO
        String tokenuri = 'https://api.xero.com/api.xro/2.0/Items';        
        //  String params='grant_type=refresh_token&refresh_token='+refresh_token;   
        
        // System.debug('params: '+params);
        HttpRequest req = new HttpRequest();
        req.setEndpoint(tokenuri);
        req.setMethod('GET');
        req.setTimeout(60*1000);   
        req.setHeader('Authorization', 'Bearer ' + access_token);
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Xero-tenant-id',tenantId);
        
        //req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        
        Http h = new Http();
        String resp;
        HttpResponse res = h.send(req);
        resp = res.getBody();
        System.debug('resp data: '+resp);
        Map<String,Object> respmap=new Map<String,Object>();
        respmap=(Map<String,Object>)JSON.deserializeUntyped(resp);
        List<Items__c> itlist=new List<Items__c>();
        List<Object> itobjlist=(List<Object>)respmap.get('Items');
        for(Object ob:itobjlist){
            Map<String,Object> itmp=(Map<String,Object>)ob;
            itlist.add(new Items__c(xero_ItemId__c=(String)itmp.get('ItemID'),
                                   xero_code__c=(String)itmp.get('Code'),
                                   xero_description__c=(String)itmp.get('Description'),
                                   xero_purchasedescription__c=(String)itmp.get('Purchasedescription'),
                                    xero_updateddateutc__c=(String)itmp.get('UpdateDateUTC'),
                                    xero_purchasedetails__c=String.valueOf(itmp.get('PurchaseDetails')),
                                    xero_salesdetails__c=String.valueOf(itmp.get('SalesDetails')),
                                    name=(String)itmp.get('Name'),
                                    xero_istrackedasinventory__c=getBoolean(itmp.get('IsTrackedAsInventory')),
                                    xero_isSold__c=getBoolean(itmp.get('isSold')),
                                    xero_isPurchased__c=getBoolean(itmp.get('IsPurchased')),
                                    RecordTypeId=Schema.SObjectType.Items__c.getRecordTypeInfosByName().get('XERO UK').getRecordTypeId()
                                   ));
        }
        System.debug('itlist: '+itlist);
        if(itlist.size()>0){
            Database.upsert(itlist,Items__c.xero_ItemId__c,false); 
        }
        update xr;
    }
    
    public static Boolean getBoolean(Object val){
        Boolean result=false;
        if(val!=null){
            result=Boolean.valueOf(result);
        }        
        return result;
    }
    global void scheduleMe() {    
        String CRON_Label= System.Label.XEROUKItemSyncBatch_CRON;
        if(!Test.isRunningTest()){
        	system.schedule('XEROUKItemSyncBatch', CRON_Label, new XEROUKItemSyncBatch());   
        }
    }
    
    global void execute(SchedulableContext sc){
        syncXEROUKItems();
    }
}