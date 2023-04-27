/*
Refreshing access tokens
An access tokens expire after 12 minutes. Your app can refresh an access token without user interaction by using a refresh token.
*/
global class XEROTokenScheduler implements Database.AllowsCallouts,Database.Stateful, Schedulable {
    global void scheduleMe() {        
       // String CRON_Label= System.Label.XEROTokenScheduler; 
        if(!Test.isRunningTest()){
        	system.schedule('XEROTokenScheduler 1', '0 00 * * * ?', new XEROTokenScheduler());  
            system.schedule('XEROTokenScheduler 2', '0 30 * * * ?', new XEROTokenScheduler()); 
        }
    }
    global void execute(SchedulableContext sc){
     	getToken();   
    }    
    global static void getToken(){
        XEROConnector.refreshToken('Ryan Henderson');
        XEROConnector.refreshToken('Tandin Dorji');
    }
}