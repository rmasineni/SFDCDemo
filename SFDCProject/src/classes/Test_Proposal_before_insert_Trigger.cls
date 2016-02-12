@isTest
private class Test_Proposal_before_insert_Trigger {

    static testMethod void myUnitTest() {
    Opportunity Opp = new Opportunity();
          Opp.Name = 'TestOpp';
          Opp.CloseDate = date.today();
          Opp.StageName = 'Closed Won';
          insert Opp;
    Opportunity Opp2 = new Opportunity();
          Opp2.Name = 'TestOpp';
          Opp2.CloseDate = date.today();
          Opp2.StageName = 'Closed Won';
          Opp2.Credit_Status__c = 'Expired';
          insert Opp2;      
       List<Proposal__c> listProp = new List<Proposal__c>();
        Proposal__c prop = new Proposal__c();
        prop.Opportunity__c = Opp.Id;
      //  prop.Assigne__c = u1.Id;        
        prop.Stage__c = 'Created';  
        prop.Sales_Rep_Email__c = 'therepsemail@repemailfake.com';
        prop.Date_Issued__c = Date.Today().addDays(18); 
        prop.Mode_Name__c = '1234';
        prop.System_Size_STC_DC__c  = 5.8;
        prop.Upfront_Payment__c = 20.0;
        prop.Sunrun_Credit_Status__c = 'SR Credit Approved';
        prop.EDP_Phase__c = 'EDP Phase-0';
        listProp.add(prop);
        //
        Proposal__c prop2 = new Proposal__c();
        prop2.Opportunity__c = Opp.Id;
       // prop2.Assigne__c = u1.Id;        
        prop2.Stage__c = 'Created';
        prop2.Sales_Rep_Email__c = 'therepsemail@repemailfake.com'; 
        prop2.Date_Issued__c = Date.Today().addDays(18); 
        prop2.Mode_Name__c = '1234';
        prop2.System_Size_STC_DC__c  = 5.8;
        prop2.Upfront_Payment__c = 20.0;
        prop2.Sunrun_Credit_Status__c = 'SR Credit Approved';
        prop2.EDP_Phase__c = 'EDP Phase-0';
        listProp.add(prop2);
        insert listProp;
        //
        prop.Estimated_Rebate_Amount__c = 999;
        prop.Partner_Guaranteed_Rebate__c = true;         
      //  prop.Assigne__c = u2.Id;
        prop.Stage__c = EDPUtil.SR_OPS_APPROVED;
        prop.Customer_SignOff_Date__c = datetime.now();
        update prop;
        //
        
        prop2.Estimated_Rebate_Amount__c = 999;
        prop2.Partner_Guaranteed_Rebate__c = true;         
       // prop2.Assigne__c = u2.Id;
        prop2.SR_Ops_Actions__c = EDPUtil.WITH_DRAWN;
        prop2.SR_Finance_Action__c = 'Pending';
       prop2.Pending_Proposal_Reason__c = 'Additional utility bills required';
      //  prop2.Stage__c = EDPUtil.EXPIRED;
        update prop2;
        Proposal__c prop3 = new Proposal__c();
        prop3.Opportunity__c = Opp2.Id;
      //  prop.Assigne__c = u1.Id;        
        prop3.Stage__c = 'Created';  
        prop3.Sales_Rep_Email__c = 'therepsemail@repemailfake.com';
        prop3.Date_Issued__c = Date.Today().addDays(18); 
        prop3.Mode_Name__c = '1234';
        prop3.System_Size_STC_DC__c  = 5.8;
        prop3.Upfront_Payment__c = 20.0;
        prop3.Sunrun_Credit_Status__c = 'SR Credit Approved';
        prop3.EDP_Phase__c = 'EDP Phase-0';
        insert prop3;
        
        Proposal__c prop4 = new Proposal__c();
        prop4.Opportunity__c = Opp.Id;
      //  prop.Assigne__c = u1.Id;        
        prop4.Stage__c = 'Created';  
        prop4.Sales_Rep_Email__c = 'therepsemail@repemailfake.com';
        prop4.Date_Issued__c = Date.Today().addDays(18); 
        prop4.Mode_Name__c = '1234';
        prop4.System_Size_STC_DC__c  = 5.8;
        prop4.Upfront_Payment__c = 20.0;
        prop4.Sunrun_Credit_Status__c = 'SR Credit Approved';
        prop4.EDP_Phase__c = 'EDP Phase-0';
       // prop4.Customer_Signoff_Date__c = Null;
        insert prop4;
      prop4.Estimated_Rebate_Amount__c = 999;
        prop4.Partner_Guaranteed_Rebate__c = true;         
      //  prop4.Assigne__c = u2.Id;
		prop4.Stage__c = EDPUtil.SR_OPS_APPROVED;
        prop4.Customer_SignOff_Date__c = datetime.now();
        update prop4;  
         prop4.Estimated_Rebate_Amount__c = 999;
        prop4.Partner_Guaranteed_Rebate__c = true;         
      //  prop.Assigne__c = u2.Id;
        prop4.Stage__c = EDPUtil.SR_OPS_APPROVED;
                prop4.Pending_Proposal_Reason__c = 'Additional utility bills required';
        prop4.Pending_notes__c = 'XYZ';
        update prop4;
        //
    }
              
    
}