/*
update xero accounts one by one for syncing xero accounts to salesforce accounts 
this is written due to future call collision between xero and MYOB
*/
global class XEROAccountSyncBatch implements Database.Batchable<sObject>,Database.AllowsCallouts,Database.Stateful, Schedulable {
    global void scheduleMe() { 
        String CRON_Label=System.Label.XEROAccountSyncBatch;       
        if(!Test.isRunningTest()){
            system.schedule('XEROAccountSyncBatch 1', '0 0 * * * ?', new XEROAccountSyncBatch());  
            system.schedule('XEROAccountSyncBatch 2', '0 30 * * * ?', new XEROAccountSyncBatch());  
        }
    }
    global void execute(SchedulableContext sc){
        XEROAccountSyncBatch batch=new XEROAccountSyncBatch();
        if(!Test.isRunningTest()){
            Id batchprocessid=Database.executeBatch(batch,1); 
        }
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'select Id,XERO_Region__c,Created_By_Country__c,Batch_Completed__c from Account where Xero_ContactId__c=null LIMIT 25';       
        System.debug('query: '+query);
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Account> scope) { 
        System.debug('records: '+scope);
     //  update scope;
        System.enqueueJob(new QueueClass(scope));
    }   
    global void finish(Database.BatchableContext BC) {     
        System.debug('batch completed');
    }
    public class QueueClass implements Queueable {
        List<Account> records;
        public QueueClass(List<Account> records) {
            this.records = records;
        }
        public void execute(QueueableContext context) {
            for(Account acc:records){
                acc.Batch_Completed__c=true;
            }
            update records;
           /* for(Account acct:records){
                String region=acct.xero_region__c;
                if(region==null){
                    region=acct.Created_By_Country__c;
                }
                if(region!=null && 
                   (region.containsIgnoreCase('UK') || region.containsIgnoreCase('AU'))){  
                       XEROAccount.sendAccountToXERO(JSON.serialize(acct),region);
                   }
            }   */        
            //System.debug('Records updated successfully.');
        }
    } 
}