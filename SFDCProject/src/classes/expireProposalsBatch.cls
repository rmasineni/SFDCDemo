global class expireProposalsBatch implements database.Batchable<sObject>   {

    set<string> UserIdsBefExp = new set<string>();
    set<string> UserIdsAftrExp = new set<string>();
   global list<Proposal__c> proposalToUpd = new list <Proposal__C>();
  
	 String Stage1 = EDPUtil.SR_DECLINED;
	 String Stage2 = EDPUtil.WITH_DRAWN;
	 String Stage3 = EDPUtil.SR_OPS_APPROVED;
     String Stage4 = EDPUtil.EXPIRED;
	 
	 Public  String soql =  'SELECT  Id,Signed__c,Stage__c,Created_Date__c, Date_Time_Submitted__c, Date_Submitted__c, ' +
     'Sales_Rep_Email__c, Expiration_eMail_Count__c, Customer_Signoff_Date__c, SR_Signoff__c FROM Proposal__c ' +
         'where  stage__c != \''+Stage1+'\' and stage__c !=\''+Stage2+'\' and stage__c != \''+Stage3+'\' and stage__c != \''+Stage4+'\' and created_Date__c = Last_N_Days:90 '; //and CALENDAR_MONTH(Created_Date__c) = 3 and CALENDAR_YEAR(Created_Date__c)  = 2015  ';
	 
    
    global Database.QueryLocator start( Database.BatchableContext BC ){
       
      return Database.getQueryLocator(soql);  
        
    }
    
    global void execute( Database.BatchableContext BC, List<sObject> scope ){
      	 List <proposal__c> propList = (List <proposal__c> ) scope;
      try{
        integer submittedDateDiff = 0 ;
        
          system.debug('Proposal count:' + scope.size());
           /* For (proposal__C p: propList) {
                system.debug('Full Prop Ids:' + p.id);
            }  */
          
        for ( Proposal__c prop : propList){
            integer createdDateDiff = math.abs(prop.Created_Date__c.daysBetween(system.now().date())); //system.now().date().daysBetween(prop.Created_Date__c);        
            if(prop.Date_Submitted__c != null)
                submittedDateDiff = math.abs(prop.Date_Submitted__c.daysBetween(system.now().date()));
         
          //  system.debug('Condition Check -  Created Date' + prop.Created_Date__c + '-CreatedDateDiff-' + createdDateDiff + '-SubmittedDateDiff-' + submittedDateDiff + '-PropID-' + prop.id + '-Stage-' + prop.Stage__c);
           // system.debug( 'Condition Check -' +  '-Signed-'+ prop.Signed__c + '-Date Submitted-' + prop.Date_Submitted__c + '-Cust Sign off-' + prop.Customer_Signoff_Date__c + '-SR_Signoff__c-' + prop.SR_Signoff__c );
          
            if (  createdDateDiff > 30 && prop.Date_Submitted__c == null &&  (prop.Signed__c == false && prop.Customer_Signoff_Date__c == null && prop.SR_Signoff__c == null )){
            	prop.Stage__c = EDPUtil.EXPIRED;   
                 proposalToUpd.add(prop); 
            }
            else if(createdDateDiff > 45 && prop.Date_Submitted__c == null  && (prop.Signed__c == true || prop.Customer_Signoff_Date__c != null) && prop.SR_Signoff__c == null)
            {
                prop.Stage__c = EDPUtil.EXPIRED ;         
                 proposalToUpd.add(prop); 
            }
            else if(submittedDateDiff >= 50 &&  submittedDateDiff < 59 && prop.Date_Submitted__c != null && (prop.SR_Signoff__c == null) && (prop.Expiration_eMail_Count__c == 0 || prop.Expiration_eMail_Count__c == null)){ 
                prop.Expiration_eMail_Count__c = 1;
                proposalToUpd.add(prop); 
            } 
            else if(submittedDateDiff == 59 && prop.Date_Submitted__c != null && (prop.SR_Signoff__c == null) ){     
                    prop.Expiration_eMail_Count__c = 2;
                proposalToUpd.add(prop); 
            }
            else if(submittedDateDiff >= 60 && prop.Date_Submitted__c != null && ( prop.SR_Signoff__c == null) ){
               	prop.Stage__c = EDPUtil.EXPIRED;
                proposalToUpd.add(prop); 
            }
     
        } 
       /* Set<proposal__c> set1 = new Set<proposal__c>(propList);
        Set<Proposal__c> set2 = new Set<proposal__c>(proposalToUpd);
        for(Proposal__c p : set1){
            if(!set2.contains(p) ){
                System.debug('>> Prop Not in Update' + p);
            }
        } */
         System.debug('ProposalToUpdate: ' + proposalToUpd.size());
  
        if(proposalToUpd.size() > 0) {
       		update proposalToUpd; 
            /*For (proposal__C p: proposalToUpd) {
                system.debug('Prop Id:' + p.id);
            }   */		
        }
       
      } catch (Exception e) {
			System.debug('Exception: ' + e.getLineNumber() + e);
      }   
    }
    
    global void finish(Database.BatchableContext BC){
		BatchUtil.processBatchErrors(bc);
    }

}