@isTest
private class UnitTest_expireProposalBatch {
    
	 @testSetup static void dataSetup() {
   
         Account a = new Account(name='Test Acct1');
         insert a;
         
         Opportunity oppty = new Opportunity();
         oppty.AccountId = a.Id;
         oppty.Name = 'NewCC Test';
         oppty.StageName = 'Qualified';
         oppty.CloseDate = Date.Today().addDays(18);
         insert oppty;
         //login
         //Proposal__c proposal = UnitTest_ServiceContractUtil.createProposal(oppty.Id);
         //
         Proposal__c proposalObj = new Proposal__c();
         proposalObj.name = 'PKRN9CF53433I-A';
         proposalObj.stage__c = 'Submitted';
         proposalObj.Opportunity__c = oppty.Id;
         
         Id SunrunIncId = System.Label.Sunrun_Inc_Id;
         proposalObj.sales_partner__c = SunrunIncId;
         proposalObj.install_partner__c = SunrunIncId;
         proposalObj.Proposal_Source__c = 'BB';
         proposalObj.Date_Time_Submitted__c = system.now()-51;
         proposalObj.Sales_Rep_Email__c = 'test@yopmail.com';
         proposalObj.Signed__c = false;
         proposalObj.Date_Issued__c = Date.Today().addDays(18);
         proposalObj.Mode_Name__c = 'Mode323';
         proposalObj.System_Size_STC_DC__c = 1290;
         proposalObj.Upfront_Payment__c = 1290;
         proposalObj.Date_Submitted__c =system.now().date() - 52;
         insert proposalObj;       
   		system.assertNotEquals(null, proposalObj);  
  } 
    
    static testMethod void myUnitTest1() {
        
       expireProposalsBatch p1 = new expireProposalsBatch();
       Database.executeBatch(p1);
    } 
    
    static testMethod void myUnitTest2() {
        list<proposal__c> proplistUpdate = [SELECT Id,Signed__c,Stage__c,CreatedDate,Date_Submitted__c,Sales_Rep_Email__c FROM Proposal__c];
        if(proplistUpdate != null && proplistUpdate.size()>0){
            proplistUpdate[0].Date_Submitted__c =system.now().date() - 59;  
            proplistUpdate[0].Signed__c = true;
            proplistUpdate[0].Expiration_eMail_Count__c = 1;
            proplistUpdate[0].Stage__c = EDPUtil.SUBMITTED;
            System.debug('proplistUpdateSize:' +proplistUpdate.size() );
        }
        update proplistUpdate;
        if(proplistUpdate != null && proplistUpdate.size()>0)
            System.debug('Date_Submitted__c' +proplistUpdate[0].Date_Submitted__c + 'Signed?' + proplistUpdate[0].Signed__c + 
                         'emailCount' + proplistUpdate[0].Expiration_eMail_Count__c + 'Proposal Stage' +  proplistUpdate[0].stage__c);
        expireProposalsBatch p2 = new expireProposalsBatch();
        Database.executeBatch(p2);
    }
    
    static testMethod void myUnitTest3() {
        list<proposal__c> proplistUpdate = [SELECT Id,Signed__c,Stage__c,CreatedDate,Date_Submitted__c,Sales_Rep_Email__c FROM Proposal__c];
        if(proplistUpdate != null && proplistUpdate.size()>0){
            proplistUpdate[0].Date_Submitted__c =system.now().date() - 100;  
            proplistUpdate[0].Signed__c = true;
            proplistUpdate[0].Expiration_eMail_Count__c = 2;
             proplistUpdate[0].Stage__c = EDPUtil.SUBMITTED;
            System.debug('proplistUpdate2size:' +proplistUpdate.size() );
        }
        update proplistUpdate;
        if(proplistUpdate != null && proplistUpdate.size()>0)
        System.debug('Date_Submitted__c' +proplistUpdate[0].Date_Submitted__c + 'Signed?' + proplistUpdate[0].Signed__c + 
                     'emailCount' + proplistUpdate[0].Expiration_eMail_Count__c + 'Proposal Stage' +  proplistUpdate[0].stage__c);
        expireProposalsBatch p2 = new expireProposalsBatch();
        Database.executeBatch(p2);
    } 
    
    
  
}