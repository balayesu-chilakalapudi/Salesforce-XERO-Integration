public class XeroInvoicePageController {
    @AuraEnabled
    public static CaseWrapper getCaseWrapper(String caseId){
        System.debug('caseId: '+caseId);
        CaseWrapper cw=new CaseWrapper();
        String region='';        
        //Add T_C_Milestones__c 
        List<T_C_Milestones__c> tmlist=new List<T_C_Milestones__c>();
        for(T_C_Milestones__c tc:[SELECT Id, Name, Milestone_Value__c 
                                  FROM T_C_Milestones__c where case__c=:caseId
                                  and invoice__c=null]){
                                      tmlist.add(tc);
                                  }
        cw.tclist=tmlist;
        String casenum='';
        //Add customers
        try{
            Case caserec = [select Id,(select Id,billing_entity__c,billing_entity__r.Name,billing_entity__r.xero_region__c,billing_entity__r.created_by_country__c,billing_entity__r.xero_contactId__c,
                                       education_provider__c,education_provider__r.Name,education_provider__r.xero_region__c,education_provider__r.created_by_country__c,education_provider__r.xero_contactId__c
                                       from commission_milestones__r),contactid, contact.name, contact.xero_contactId__c,Organisational_Contact__r.xero_contactId__c,
                            Organisational_Contact__c,Organisational_Contact__r.name,Organisational_Contact__r.xero_region__c,Organisational_Contact__r.created_by_country__c,
                            Dependent_Contact__c,Dependent_Contact__r.xero_contactId__c,Dependent_Contact__r.xero_region__c,Dependent_Contact__r.created_by_country__c,
                            Dependent_Contact__r.name,Account.Name,accountid,account.xero_contactId__c,Admin_Fees_Invoiced__c,Admin_Fees_Description__c,
                            Provision_of_office_services__c,account.xero_region__c,account.xero_accountId__c,CaseNumber,xero_region__c,
                            account.created_by_country__c,contact.created_by_country__c,contact.xero_region__c
                            from case where id =:caseId];
            casenum=caserec.CaseNumber;
            region=caserec.xero_region__c;
            if(region==null || region==''){
                region=caserec.account.created_by_country__c;
            }
            System.debug('region:'+region);
            if(region.containsIgnoreCase('UK')){
                cw.Region='UK';
            }
            if(region.containsIgnoreCase('Au')){
                cw.Region='Australia';
            }            
            List<Customer> culist=new List<Customer>();  
            // if(caserec.account.xero_region__c==null){
            //myob contact
          
            String caseregion=region;           
           
            System.debug('case region:'+caseregion); 
           
            set<String> xcustIdset=new set<String>();
            
            String caserec_con_region=caserec.contact.xero_region__c;
            if(caserec_con_region==null){
                caserec_con_region=caserec.contact.created_by_country__c;
            }
            
            //add case contact to customer list
            if(caserec!=null && caserec.contact!=null && caserec.contact.xero_contactId__c!=null && caserec.contact.name!='' && 
               isRegionMatched(caseregion,caserec_con_region)
              ){
                  if(!xcustIdset.contains(caserec.contact.xero_contactId__c)){
                       xcustIdset.add(caserec.contact.xero_contactId__c);
                  	   culist.add(new Customer(caserec.contact.xero_contactId__c,caserec.contact.name)); 
                  }
              }
           
            // add case account to customer list
            if(caserec.account.xero_contactId__c!=null){
                if(!xcustIdset.contains(caserec.account.xero_contactId__c)){
                     xcustIdset.add(caserec.account.xero_contactId__c);
             		culist.add(new Customer(caserec.account.xero_contactId__c,caserec.account.name));
                }
            }
            
            //Add Billing Entity, Education Provider to customer list
            for(Commission_Milestone__c cm:caserec.Commission_Milestones__r){
                String billregion=cm.Billing_Entity__r.Xero_region__c;
                if(billregion==null){
                    billregion=cm.Billing_Entity__r.Created_by_country__c;
                }                
                if(cm.Billing_Entity__c!=null &&
                   cm.Billing_Entity__r.xero_contactId__c!=null &&
                   isRegionMatched(caseregion,billregion)
                   ){
                        if(!xcustIdset.contains(cm.Billing_Entity__r.xero_contactId__c)){
                     		xcustIdset.add(cm.Billing_Entity__r.xero_contactId__c);
                			culist.add(new Customer(cm.Billing_Entity__r.xero_contactId__c,cm.Billing_Entity__r.name));    
                        }
                }
                
                String eduregion=cm.Education_Provider__r.Xero_region__c;
                if(eduregion==null){
                    eduregion=cm.Education_Provider__r.Created_by_country__c;
                }
                if(cm.Education_Provider__c!=null &&
                   cm.Education_Provider__r.xero_contactId__c!=null &&
                   isRegionMatched(caseregion,eduregion) 
                   ){
                        if(!xcustIdset.contains(cm.Education_Provider__r.xero_contactId__c)){
                     		xcustIdset.add(cm.Education_Provider__r.xero_contactId__c);
                			culist.add(new Customer(cm.Education_Provider__r.xero_contactId__c,cm.Education_Provider__r.name));  
                        }
                }
            }
            
            
            String caserec_dep_region=caserec.Dependent_Contact__r.xero_region__c;
            if(caserec_dep_region==null){
                caserec_dep_region=caserec.Dependent_Contact__r.created_by_country__c;
            }
            //Add dependent contact            
            if(caserec!=null && caserec.Dependent_Contact__c!=null &&
               caserec.Dependent_Contact__r.xero_contactId__c!=null && 
               caserec.Dependent_Contact__r.name!='' && 
               isRegionMatched(caseregion,caserec_dep_region) 
              ){
                  if(!xcustIdset.contains(caserec.Dependent_Contact__r.xero_contactId__c)){
                     	xcustIdset.add(caserec.Dependent_Contact__r.xero_contactId__c);
                  		culist.add(new Customer(caserec.Dependent_Contact__r.xero_contactId__c,caserec.Dependent_Contact__r.name));
                  }
              }
            
            String orgconregion=caserec.Organisational_Contact__r.xero_region__c;
            if(orgconregion==null){
                orgconregion=caserec.Organisational_Contact__r.created_by_country__c;
            }
            //Add Organisation contact            
            if(caserec!=null && caserec.Organisational_Contact__c!=null && 
               caserec.Organisational_Contact__r.xero_contactId__c!=null &&
               caserec.Organisational_Contact__r.name!='' && 
               isRegionMatched(caseregion,orgconregion) 
              ){
                   if(!xcustIdset.contains(caserec.Organisational_Contact__r.xero_contactId__c)){
                     	xcustIdset.add(caserec.Organisational_Contact__r.xero_contactId__c);
                  		culist.add(new Customer(caserec.Organisational_Contact__r.xero_contactId__c,caserec.Organisational_Contact__r.name)); 
                   }
              }
            
            cw.clist=culist;
            
            //set admin fee
            if(caserec.Provision_of_office_services__c==null){
                caserec.Provision_of_office_services__c=0;
                try{
                    update caserec;
                }catch(Exception ex){
                    System.debug('Exception:'+ex);
                }
            }
            AdminFees af=new AdminFees(caserec);
            system.debug('af: '+af);
            cw.aflist=new List<AdminFees>{af};
                
                }catch(Exception ex){
                    System.debug('Exception: '+ex+'\n'+ex.getStackTraceString());
                }
        
        List<Items__c> itemlist=new List<Items__c>();
        Set<Id> itemset=new Set<Id>();
        
        //Add Milestones
        List<Milestone__c> mslist=new List<Milestone__c>();
        //  if(region!=null && (region.containsIgnoreCase('UK') || region.containsIgnoreCase('Aus'))){
        for(Milestone__c ms:[select Id,SentToMyOB__c, Name,Date__c,Quantity__c,Milestone_Value__c,case__c,Type__c,Item_Description__c,
                             Item_Name__c,Qty_Type__c,Tax_Type__c,Allocate_To__c,MyOB_Item_Id__c,invoice__c,
                             XERO_UK_Items__c,Xero_UK_Items__r.Name,xero_uk_items__r.xero_code__c,XERO_UK_Tax_Type__c,
                             XERO_AUS_Items__c,Xero_AUS_Items__r.Name,xero_Aus_items__r.xero_code__c,XERO_Aus_Tax_Type__c,
                             XERO_Milestone_Value__c,unitprice__c,xero_items__r.xero_code__c, recordtypeId,recordtype.name
                             from milestone__c 
                             where case__c=:caseId
                             and invoice__c=null                             
                             //  and (XERO_UK_Items__c!=null or XERO_AUS_Items__c!=null)
                            ]){ 
                                ms.XERO_Milestone_Value__c=ms.Milestone_Value__c;
                                mslist.add(ms);
                                /*  if(region.containsIgnoreCase('UK')){
if(ms.xero_uk_items__c!=null){
// itemset.add(ms.xero_uk_items__c);
ms.XERO_Milestone_Value__c=ms.Milestone_Value__c;
mslist.add(ms);
}
}else{
if(ms.XERO_AUS_Items__c!=null){
//  itemset.add(ms.XERO_AUS_Items__c);

}
} */
                            }
        //    }
        
        cw.mslist=mslist;
        //get case number
        List<Invoice__c> lstinvoicemax = new List<Invoice__c>();       
        if(caseId!=null||caseId!='')
        {
            lstinvoicemax = [select name,case__r.casenumber,Due_Date__c,Date_of_issue__c from invoice__c where case__c=:caseId];                   
            
            Integer maxinvnum = lstinvoicemax.size();
            maxinvnum = maxinvnum + 1; 
            if(casenum.contains(' ')){
                casenum=casenum.replace(' ', '');
            }
            if(casenum.contains('Case')){
                casenum=casenum.replace('Case','C');
            }         
            
            cw.InvNumber  = casenum + '-' + maxinvnum;
        }
        
        //Add Disbursements
        List<Disbursements__c> dmlist=new List<Disbursements__c>();
        //  if(region!=null && (region.containsIgnoreCase('UK') || region.containsIgnoreCase('Au'))){
        for(Disbursements__c dm:[Select Id,name,Item_Code__c,Item_Description__c,Date_of_Transaction__c,Date__c,Type__c,Milestone_Value__c,
                                 Total_value_of_transaction__c,Quantity__c, invoice__c,Case__c,Tax_Type__c,Allocate_To__c, 
                                 xero_UK_items__c, XERO_UK_Items__r.Name, xero_uk_items__r.xero_code__c,XERO_UK_Tax_Type__c,
                                 xero_Aus_items__c, XERO_Aus_Items__r.Name, xero_Aus_items__r.xero_code__c,XERO_Aus_Tax_Type__c,
                                 XERO_Milestone_Value__c, xero_items__r.xero_code__c,Xero_Items__r.Name,XERO_Items__c,
                                 unitprice__c,recordtypeId,recordtype.name
                                 from disbursements__c 
                                 where case__c=:caseId
                                 and invoice__c=null
                                 //  and (xero_UK_items__c!=null or xero_aus_items__c!=null)
                                ]){    
                                    /*  if(dm.xero_uk_items__c!=null){
itemset.add(dm.xero_uk_items__c);
}
if(dm.XERO_AUS_Items__c!=null){
itemset.add(dm.XERO_AUS_Items__c);
} */
                                    dm.XERO_Milestone_Value__c=dm.Milestone_Value__c;
                                    dmlist.add(dm);
                                }
        // }
        //Add Commission Milestones
        List<Commission_Milestone__c> commlist=new List<Commission_Milestone__c>(); 
        //  if(region!=null && (region.containsIgnoreCase('UK') || region.containsIgnoreCase('Au'))){
        for(Commission_Milestone__c cm:[Select Id,name,Item_Name__c,Item_Description__c,Milestone_Billable_Date__c,Date__c,Type__c,Commission_Amount__c,
                                        Quantity__c, invoice__c,Case__c,Tax_Type__c,Allocate_To__c, 
                                        xero_UK_items__c, XERO_UK_Items__r.Name, xero_uk_items__r.xero_code__c,XERO_UK_Tax_Type__c,
                                        xero_AUS_items__c, XERO_Aus_Items__r.Name, xero_Aus_items__r.xero_code__c,XERO_Aus_Tax_Type__c,
                                        XERO_Milestone_Value__c,Billing_Entity__r.Name,Course__c, Billing_Entity__c,                                
                                        recordtypeId,recordtype.name,student_Id__c
                                        from Commission_Milestone__c
                                        where case__c=:caseId
                                        and invoice__c=null
                                        and invoice_raised__c=false
                                        // and (xero_UK_items__c!=null or xero_aus_items__c!=null)
                                       ]){ 
                                           /*  if(cm.xero_uk_items__c!=null){
itemset.add(cm.xero_uk_items__c);
}
if(cm.xero_aus_items__c!=null){
itemset.add(cm.xero_aus_items__c);
} */
                                           cm.XERO_Milestone_Value__c=cm.Commission_Amount__c;
                                           cm.item_description__c=cm.course__c+' - '+cm.Student_ID__c;
                                           commlist.add(cm);
                                       }
        //  }
        
        cw.dmlist=dmlist;
        cw.commlist=commlist;
        /*  for(Items__c itm:[select id,name,xero_code__c from items__c where Id IN:itemset]){
itemlist.add(itm);
}

cw.itemlist=itemlist;  */
        Map<String,XERO_TaxType_Rates__c> rates=XERO_TaxType_Rates__c.getAll();            
        cw.xero_taxrates=rates;
        system.debug('cw: '+cw);
        return cw;
    }
    
    @AuraEnabled
    public static String processInvoice(Invoice__c inv, String selectedMilestones,String selectedDisbursements,String tcmId,String selectedAdminFee,String selectedCommissionMilestones,String region){
        System.debug('selectedMilestones:'+selectedMilestones);
        System.debug('selectedDisbursements:'+selectedDisbursements);
        System.debug('selectedAdminFee: '+selectedAdminFee);
        System.debug('selectedCommissionMilestones: '+selectedCommissionMilestones);
        System.debug('Transaction Type: '+inv.Transaction_Type__c);
        System.debug('Region:'+region);
        String result='';
        try{
            System.debug('savingInvoice...'); 
            String inv_case=inv.case__c;           
            String inv_contact=inv.XERO_ContactId__c;
            String inv_itemcode='';  
            //inv.XERO_ItemCode__c;
            
            //check invoice number
            if(inv.Invoice_Number__c==null || inv.Invoice_Number__c.equals('')){
                return 'ERROR:Please Enter Invoice number';
            }else{
                //check for existing numbers
                integer count=[select count() from invoice__c where invoice_number__c=:inv.Invoice_Number__c];
                if(count!=0){
                   return 'ERROR:Please Enter Different Invoice number. Same number Already exists'; 
                }
            }
            
            if(inv_case==null || inv_case.equals('')){
                return 'ERROR:Please select Case';
            }
            if(inv_contact==null || inv_contact.equals('')){
                return 'ERROR:Please select Contact';
            }
            if(inv.Date_of_issue__c==null){
                return 'ERROR:Please enter date of issue';
            }
            if(inv.Due_Date__c==null){
                return 'ERROR:Please enter due date';
            }           
            if(inv.Transaction_Type__c==null || inv.Transaction_Type__c==''){
                return 'ERROR:Please select Transaction Type';
            }            
                      
            List<Map<String,Object>> itemslist=new List<Map<String,Object>>();
            //deserialize milestones
            List<Milestone__c> mslist;
            try{
                mslist=(List<Milestone__c>)JSON.deserialize(selectedMilestones, List<Milestone__c>.class);
            }catch(Exception ex){
                mslist=new List<Milestone__c>();
            }
             List<Disbursements__c> dmlist;
            try{
                dmlist=(List<Disbursements__c>)JSON.deserialize(selectedDisbursements,List<Disbursements__c>.class);
            }catch(Exception ex){
                dmlist =new List<Disbursements__c>();
            }
            System.debug('dmlist:'+dmlist);
             List<Commission_Milestone__c> commlist;
            try{
                commlist=(List<Commission_Milestone__c>)JSON.deserialize(selectedCommissionMilestones,List<Commission_Milestone__c>.class);
            }catch(Exception ex){
                commlist =new List<Commission_Milestone__c>();
            }
            //add all items in set
            set<Id> itemset=new Set<Id>();
            for(Milestone__c ms:mslist){
                if(ms.XERO_AUS_Items__c!=null){
                	itemset.add(ms.XERO_AUS_Items__c);
                }
                if(ms.XERO_UK_Items__c!=null){
                	itemset.add(ms.XERO_UK_Items__c);
                }
            }
             for(Disbursements__c dm:dmlist){
                if(dm.XERO_AUS_Items__c!=null){
                	itemset.add(dm.XERO_AUS_Items__c);
                }
                if(dm.XERO_UK_Items__c!=null){
                	itemset.add(dm.XERO_UK_Items__c);
                }
            }
            for(Commission_Milestone__c cm:commlist){
                if(cm.XERO_AUS_Items__c!=null){
                	itemset.add(cm.XERO_AUS_Items__c);
                }
                if(cm.XERO_UK_Items__c!=null){
                	itemset.add(cm.XERO_UK_Items__c);
                }
            }
            Map<Id,String> itemsmap=new Map<Id,String>();
            for(Items__c itm:[select Id,xero_code__c,xero_itemId__c from items__c where Id IN:itemset
                             and xero_code__c!=null
                             and xero_itemid__c!=null]){
                itemsmap.put(itm.Id,itm.xero_code__c);
            }
            System.debug('mslist:'+mslist);
            Decimal totalsum=0;
            //add admin fee
            List<AdminFees> admflist;
            try{
                admflist=(List<AdminFees>)JSON.deserializeStrict(selectedAdminFee, List<AdminFees>.class);
            }catch(Exception ex){
                admflist=new List<AdminFees>();
                System.debug('Exception:'+ex+'\n'+ex.getStackTraceString());
            }
            System.debug('admflist:'+admflist);
            
            String admintaxtype='';
            for(Milestone__c ms:mslist               
               ){                   
                   Map<String,String> amountsmap=new Map<String,String>();                                           
                   amountsmap.put('Quantity',String.valueOf(ms.Quantity__c));
                   amountsmap.put('UnitPrice',String.valueOf(ms.milestone_value__c));
                   amountsmap.put('Description',ms.Item_Description__c);
                   if(region.containsIgnoreCase('UK')){
                       if(ms.XERO_UK_Tax_Type__c!=null && ms.XERO_UK_Tax_Type__c!=''){
                           amountsmap.put('Taxtype',ms.XERO_UK_Tax_Type__c);
                           if(admintaxtype==''){
                               admintaxtype=ms.XERO_UK_Tax_Type__c;
                           }
                           if(ms.XERO_UK_Items__c!=null && itemsmap.containsKey(ms.XERO_UK_Items__c)){
                               itemslist.add(new Map<String,Object>{itemsmap.get(ms.XERO_UK_Items__c)=>amountsmap});
                           }else{
                               return 'ERROR: XERO UK Items with xero code Required on selected milestones';
                           }
                       }else{
                           return 'ERROR: XERO UK Tax Type Required on selected milestones';
                       }
                   }else{
                       if(ms.XERO_AUS_Tax_Type__c!=null && ms.XERO_AUS_Tax_Type__c!=''){
                           amountsmap.put('Taxtype',ms.XERO_Aus_Tax_Type__c);
                           if(admintaxtype==''){
                               admintaxtype=ms.XERO_Aus_Tax_Type__c;
                           }
                           if(ms.XERO_Aus_Items__c!=null && itemsmap.containsKey(ms.XERO_Aus_Items__c)){
                               itemslist.add(new Map<String,Object>{itemsmap.get(ms.XERO_Aus_Items__c)=>amountsmap});
                           }else{
                               return 'ERROR: XERO Aus Items with xero code Required on selected milestones';
                           }
                       }else{
                           return 'ERROR: XERO Aus Tax Type Required on selected milestones';
                       }
                   }
                   
                   
                   if(ms.Milestone_Value__c!=null){
                       totalsum+=ms.milestone_value__c;
                   }
                  
               }
           
            System.debug('mslist:'+mslist);
            //deserialize disbursements            
           
            for(Disbursements__c dm:dmlist
               ){
                   Map<String,String> amountsmap=new Map<String,String>();
                   amountsmap.put('Quantity',String.valueOf(dm.Quantity__c));
                   amountsmap.put('UnitPrice',String.valueOf(dm.milestone_value__c));  
                   amountsmap.put('Description',dm.Item_Description__c);
                   if(region.containsIgnoreCase('UK')){
                       if(dm.XERO_UK_Tax_Type__c!=null && dm.XERO_UK_Tax_Type__c!=''){
                           amountsmap.put('Taxtype',dm.XERO_UK_Tax_Type__c);
                           if(admintaxtype==''){
                               admintaxtype=dm.XERO_UK_Tax_Type__c;
                           }
                           if(dm.XERO_UK_Items__c!=null && itemsmap.containsKey(dm.XERO_UK_Items__c)){
                               itemslist.add(new Map<String,Object>{itemsmap.get(dm.XERO_UK_Items__c)=>amountsmap});
                           }else{
                               return 'ERROR: XERO UK Items with xero code Required on Selected Disbursements';
                           }
                       }else{
                           return 'ERROR: XERO UK Tax Type Required on Selected Disbursements';
                       }
                   }else{
                       if(dm.Xero_Aus_Tax_Type__c!=null && dm.Xero_Aus_Tax_Type__c!=''){
                           amountsmap.put('Taxtype',dm.XERO_Aus_Tax_Type__c);
                           if(admintaxtype==''){
                               admintaxtype=dm.XERO_Aus_Tax_Type__c;
                           }
                           if(dm.XERO_AUS_Items__c!=null && itemsmap.containsKey(dm.XERO_AUS_Items__c)){
                               itemslist.add(new Map<String,Object>{itemsmap.get(dm.XERO_AUS_Items__c)=>amountsmap});
                           }else{
                               return 'ERROR: XERO AUS items with xero code Required on selected disbursements';
                           }
                       }else{
                           return 'ERROR: XERO Aus tax type Required on selected disbursements';
                       }
                   }
                  
                   if(dm.Milestone_Value__c!=null){
                       totalsum+=dm.milestone_value__c;
                   }
                  
               }
            
           
            System.debug('commlist:'+commlist);
            
            for(Commission_Milestone__c comm:commlist){
                Map<String,String> amountsmap=new Map<String,String>();
                amountsmap.put('Quantity',String.valueOf(comm.Quantity__c));
                amountsmap.put('UnitPrice',String.valueOf(comm.commission_amount__c)); 
                amountsmap.put('Description',comm.Item_Description__c);
                if(region.containsIgnoreCase('UK')){
                    if(comm.XERO_UK_Tax_Type__c!=null && comm.XERO_UK_Tax_Type__c!=''){
                        amountsmap.put('Taxtype',comm.XERO_UK_Tax_Type__c);
                         if(admintaxtype==''){
                               admintaxtype=comm.XERO_UK_Tax_Type__c;
                           }
                        if(comm.XERO_UK_Items__c!=null && itemsmap.containsKey(comm.XERO_UK_Items__c)){
                            itemslist.add(new Map<String,Object>{itemsmap.get(comm.XERO_UK_Items__c)=>amountsmap});
                        }else{
                            return 'ERROR: XERO UK Items with xero code Required on selected Commission Milestones';
                        }
                    }else{
                        return 'ERROR: XERO UK Tax Type required on selected Commission Milestones';
                    }
                }else{
                    if(comm.Xero_Aus_Tax_Type__c!=null && comm.Xero_Aus_Tax_Type__c!=''){
                        amountsmap.put('Taxtype',comm.XERO_Aus_Tax_Type__c);
                         if(admintaxtype==''){
                               admintaxtype=comm.XERO_Aus_Tax_Type__c;
                           }
                        if(comm.XERO_AUS_Items__c!=null && itemsmap.containsKey(comm.XERO_AUS_Items__c)){
                            itemslist.add(new Map<String,Object>{itemsmap.get(comm.XERO_AUS_Items__c)=>amountsmap});
                        }else{
                            return 'ERROR: XERO AUS Items with xero code Required on selected commission milestones';
                        } 
                    }else{
                        return 'ERROR: XERO AUS Tax Type Required on selected Commission Milestones';
                    }
                } 
                
            }
            //admin fee line item 
            if(selectedAdminFee!=null && selectedAdminFee!='' && admflist.size()>0){
                inv.Admin_Fees_Invoiced__c=true;
                try{
                    Case cs=[select Id,Provision_of_office_services__c,account.xero_code__c,accountId,XERO_Region__c
                             from case where Id=:inv.case__c limit 1];                                      
                    // inv.XERO_AccountCode__c=cs.account.xero_code__c;
                    cs.Admin_Fees_Invoiced__c=true;
                    update cs;
                    totalsum+=admflist[0].Value;
                    //cs.Provision_of_office_services__c;  
                    
                    Map<String,String> amountsmap=new Map<String,String>();                                           
                    amountsmap.put('Quantity',String.valueOf(admflist[0].Units));
                    amountsmap.put('UnitPrice',String.valueOf(admflist[0].Value));
                    
                    String xero_code='';
                    if(region.containsIgnoreCase('UK')){
                        amountsmap.put('Taxtype',admintaxtype);
                        xero_code=[select name,xero_code__c 
                                   from items__c 
                                   where name='Admin Fee' 
                                   and xero_itemId__c!=null 
                                   and Recordtype.name='XERO UK'
                                   limit 1].xero_code__c;
                    }
                    else{
                        amountsmap.put('Taxtype',admintaxtype);
                        xero_code=[select name,xero_code__c 
                                   from items__c 
                                   where name='Admin Fee' 
                                   and Recordtype.name='XERO AUS'
                                   and xero_itemId__c!=null 
                                   limit 1].xero_code__c;
                    }
                    
                    amountsmap.put('Description','Admin fees');
                    
                    itemslist.add(new Map<String,Object>{xero_code=>amountsmap});
                }catch(Exception ex){
                    System.debug('Exception: '+ex+'\n'+ex.getStackTraceString());
                }
            }
            
            //inv_itemcode;
            
            T_C_Milestones__c tcm=null;
            Decimal tcmValue=null;
            if(tcmId!=null && tcmId!='' && tcmId!='None'){
                try{
                    tcm=[select Id,milestone_value__c from T_C_Milestones__c 
                         where Id=:tcmId];
                    if(tcm.milestone_value__c!=null){
                        tcmValue=tcm.milestone_value__c;
                    }
                }catch(Exception ex){
                    System.debug('Failed to get tcm'+ex);
                }            
            }        
            if(totalsum==0 || (tcmValue!=null && 
                               totalSum.round()==tcmValue.round())){
                                   String invid='';
                                   try{
									   Case cs=[select Id,Provision_of_office_services__c,account.xero_code__c,accountId,account.xero_region__c
                                                from case where Id=:inv.case__c limit 1];                                      
                                       inv.XERO_AccountCode__c=cs.account.xero_code__c;
                                      // inv.XERO_Region__c=cs.account.xero_region__c;
                                   }catch(Exception ex){
                                       System.debug('Exception :'+ex);
                                   }  
                                   
                                       //set customer details
                                       if(inv.Customer_Id__c==null){
                                           //set contact Id as customer Id
                                           if(inv.XERO_ContactID__c!=null){                                               
                                               Contact con;
                                               try{
                                                   con=[SELECT Id,email,Name
                                                            from contact
                                                            where xero_contactId__c=:inv.XERO_ContactID__c];
                                               }catch(Exception ex){
                                                   System.debug(ex);
                                               }
                                               if(con!=null){
                                               		inv.Customer_Id__c=con.Id;
                                               		inv.Customer_Email__c=con.email;
                                               		inv.Customer_Name__c=con.Name;
                                               }else{
                                                   Account acc;
                                                   try{
                                                        acc=[SELECT Id,Email__c,Name
                                                            from account
                                                            where xero_contactId__c=:inv.XERO_ContactID__c];
                                                   }catch(Exception ex){
                                                       System.debug(ex);
                                                   }
                                                   if(acc!=null){
                                                       inv.Customer_Id__c=acc.Id;
                                                       inv.Customer_Email__c=acc.Email__c;
                                                       inv.Customer_Name__c=acc.Name;                                                  
                                                   }
                                               }                                               
                                           }                                          
                                       }
                                      
                                  
                                   try{
                                       // add kpi split
                                        Case cs=[select Id,Provision_of_office_services__c,account.xero_code__c,accountId,XERO_Region__c,
                                                 A_Consultant__c,A_Percentage__c,A_Amount__c,
                                                 B1_Consultant__c,B1_Percentage__c,B1_Amount__c,
                                                 B2_Consultant__c,B2_Percentage__c,B2_Amount__c,
                                                 C_Consultant__c,C_Percentage__c,C_Amount__c
                             from case where Id=:inv.case__c limit 1];
                                       inv.A_Consultant__c=cs.A_Consultant__c;
                                       inv.A_Percentage__c=cs.A_Percentage__c;
                                       inv.A_Amount__c=cs.A_Amount__c;
                                       inv.B1_Consultant__c=cs.B1_Consultant__c;
                                       inv.B1_Percentage__c=cs.B1_Percentage__c;
                                       inv.B1_Amount__c=cs.B1_Amount__c;
                                       inv.B2_Consultant__c=cs.B2_Consultant__c;
                                       inv.B2_Percentage__c=cs.B2_Percentage__c;
                                       inv.B2_Amount__c=cs.B2_Amount__c;
                                       inv.C_Consultant__c=cs.C_Consultant__c;
                                       inv.C_Percentage__c=cs.C_Percentage__c;
                                       inv.C_Amount__c=cs.C_Amount__c;
                                   }catch(Exception ex){
                                       System.debug(''+ex.getStackTraceString());
                                   }
                                   inv.Created_By_XERO_Invoice_Page__c=true;
                                   inv.XERO_Region__c=region;
                                   inv.XERO_Items_Map__c=JSON.serialize(itemslist);
            					   inv.Xero_Invoice__c=true;
                                   insert inv;
                                   invId=inv.Id;
                                   //update milestones
                                   // Set<Id> itemidset=new Set<Id>();
                                   for(Milestone__c ms:mslist){
                                       ms.Invoice__c=inv.Id;     
                                       //   itemidset.add(ms.XERO_UK_Items__c);
                                   }
                                   if(mslist.size()>0)
                                       update mslist;
                                   //update disbursements
                                   for(Disbursements__c dm:dmlist){
                                       dm.Invoice__c=inv.Id;
                                       //   itemidset.add(dm.XERO_UK_Items__c);
                                   }
                                   if(dmlist.size()>0)
                                       update dmlist;
                                   result=inv.id;
                                   try{
                                       tcm.invoice__c=inv.Id;
                                       update tcm;
                                   }catch(Exception ex){
                                       System.debug('Exception:'+ex);
                                   }    
                                   //update commission milestones
                                   for(Commission_Milestone__c comm:commlist){
                                       comm.invoice__c=inv.Id;
                                       comm.Invoice_raised__c=true;
                                   } 
                                   if(commlist.size()>0)	
                                       update commlist;
                                   //update item with tax type
                                  
                               }else{                  
                                   result='ERROR: Please Check Milestones, Disbursement and Admin Fee Amounts matches with T_C Milestone';                   
                               }
        }catch(Exception ex){
            System.debug('Exception: '+ex+'\n'+ex.getStackTraceString());
            return 'ERROR:'+ex.getMessage()+'\n'+ex+'\n'+ex.getStackTraceString();
        }
        return result;
    }
    
    public class CaseWrapper{
        @AuraEnabled
        public List<Customer> clist;
        @AuraEnabled
        public List<T_C_Milestones__c> tclist;
        @AuraEnabled
        public List<Milestone__c> mslist;
        @AuraEnabled
        public List<disbursements__c> dmlist;
        @AuraEnabled
        public List<AdminFees> aflist;        
        @AuraEnabled
        public List<Items__c> itemlist;
        @AuraEnabled
        public String InvNumber;
        @AuraEnabled
        public Map<String,XERO_TaxType_Rates__c> xero_taxrates;        
        @AuraEnabled
        public List<Commission_Milestone__c> commlist;
        @AuraEnabled
        public String Region='';
    }
    public class Customer{
        @AuraEnabled
        public String Id;
        @AuraEnabled
        public String Name;
        public Customer(String p_Id,String p_Name){
            Id=p_Id;
            Name=p_Name;
        }
    }
    
    public class AdminFees{
        @AuraEnabled
        public Boolean Admin_Fees_Invoiced{get;set;}
        @AuraEnabled
        public Boolean selected {get; set;}
        @AuraEnabled
        public String ItemId{get; set;}
        @AuraEnabled
        public String Admin_Fees_Description{get; set;}
        @AuraEnabled
        public String Units{get; set;}
        @AuraEnabled
        public String Name{get; set;}
        @AuraEnabled
        public double Value{get; set;}        
        @AuraEnabled
        public double XERO_Milestone_Value{get; set;}
        
        public AdminFees(Case c){
            Name='Admin Fees';
            Admin_Fees_Invoiced=c.Admin_Fees_Invoiced__c;            
            ItemId='Administration Costs';
            Admin_Fees_Description ='Admin fees';
            Units ='1';
            Value=c.Provision_of_office_services__c;
            XERO_Milestone_Value=Value;
        }
    }       
    
    public static boolean isRegionMatched(String param1,String param2){
        Boolean flag=false;
        if(param1!=null && param2!=null){
            if(param1.containsIgnoreCase(param2) || 
               param2.containsIgnoreCase(param1)){
                flag=true;
            }
        }
        return flag;
    }
}