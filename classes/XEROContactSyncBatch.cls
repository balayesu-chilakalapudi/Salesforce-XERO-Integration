/*
update xero accounts one by one for syncing xero accounts to salesforce accounts 
this is written due to future call collision between xero and MYOB
*/
global class XEROContactSyncBatch implements Database.Batchable<sObject>,Database.AllowsCallouts,Database.Stateful, Schedulable {
    global void scheduleMe() { 
        String CRON_Label=System.Label.XEROContactSyncBatch;       
        if(!Test.isRunningTest()){
            system.schedule('XEROContactSyncBatch 1', '0 0 * * * ?', new XEROContactSyncBatch());  
            system.schedule('XEROContactSyncBatch 2', '0 30 * * * ?', new XEROContactSyncBatch());  
        }
    }
    global void execute(SchedulableContext sc){
        XEROContactSyncBatch batch=new XEROContactSyncBatch();
        if(!Test.isRunningTest()){
            Id batchprocessid=Database.executeBatch(batch,1); 
        }
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'select Id,XERO_Region__c,Batch_Completed__c,created_by_country__c from Contact where Xero_ContactId__c=null LIMIT 25';       
        System.debug('query: '+query);
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Contact> scope) {   
        System.debug('scope:'+scope);
        System.enqueueJob(new QueueClass(scope));
    }   
    global void finish(Database.BatchableContext BC) {     
        System.debug('batch completed');
    }
    public class QueueClass implements Queueable {
        List<Contact> records;
        public QueueClass(List<Contact> records) {
            this.records = records;
        }
        public void execute(QueueableContext context) {
            for(Contact con:records){
                con.Batch_Completed__c=true;
            }
            update records;
           /* for(Contact cont:records){
             String region=cont.XERO_Region__c;
                       if(region!=null && 
                          (region.containsIgnoreCase('UK') || region.containsIgnoreCase('AU'))){                    
                              XEROContact.sendContactToXERO(JSON.serialize(cont));
                          }
            }    */       
           // System.debug('Records updated successfully.');
        }
    }
}