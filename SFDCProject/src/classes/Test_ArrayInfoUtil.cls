@isTest
private class Test_ArrayInfoUtil {

    static testMethod void test_trigger_array_info() {
         Test.starttest();
                  
          Opportunity Opp = new Opportunity();
          Opp.Name = 'TestOpp';
          Opp.CloseDate = date.today();
          Opp.StageName = 'Closed Won';
          insert Opp;
          
          
          Proposal__c p = New Proposal__c();
          p.Upfront_Payment__c = 70000;
          p.System_Size_STC_DC__c = 25;
          p.Sales_Rep_Email__c = 'testrep@yopmail.com';
          p.Name = 'Testproposal';
          p.Opportunity__c = Opp.Id;
          p.Date_Issued__c = date.today();
          p.Mode_Name__c  = 'Modetest';
          p.Stage__c  = 'SR Approved';
          p.Sunrun_Credit_Status__c = 'SR Credit Approved';
          insert p;
          Account a = New Account(Name = 'TestAccount');
           insert a;
                     
           ServiceContract sc = New ServiceContract();
           sc.Name = 'Testsc';
           sc.AccountId = a.Id;
           sc.Name = 'Testservicecontract';
           sc.Proposal__c = p.Id;
           sc.Legacy_Asset_Number__c = '10082004';
           insert sc;
                  
          Array_Information__c ai = New Array_Information__c();
          ai.April_Shade__c = 5;
          ai.Array_Number__c = 6;
          ai.August_Shade__c = 7;
          ai.Azimuth__c = 8;
          ai.December_Shade__c = 9;
          ai.February_Shade__c = 10;
          ai.Inverter_Type__c = 'sc';
          ai.January_Shade__c = 15;
          ai.July_Shade__c = 16;
          ai.June_Shade__c = 17;
          ai.Proposal__c = p.Id;
          ai.March_Shade__c = 9;
          ai.May_Shade__c = 4;
          ai.November_Shade__c = 11;
          ai.October_Shade__c = 10;
          ai.Production__c = 67;
          ai.September_Shade__c = 9; 
          ai.Service_contract__c = sc.Id;
          insert ai;
          
                              
           Asset__c asset = New Asset__c();
           asset.ServiceContract__c = sc.Id;
           asset.Type__c = 'Asset';
           asset.Status__c = 'Active';
	       Map<String, Id> assetRecordTypes = ServiceContractUtil.getAssetRecordTypes();
	       Id recordTypeId = assetRecordTypes.get(asset.type__c);
	       asset.RecordTypeId = recordTypeId;
           insert asset;
           
           List<Contract_Array__c> caList =  new List<Contract_Array__c>();
            Contract_Array__c  ca = New  Contract_Array__c();
            ca.April_Shade__c = ai.April_Shade__c;
            ca.Array_Number__c = ai.Array_Number__c;
            ca.Asset__c = asset.Id;
            ca.August_Shade__c = ai.August_Shade__c;
            ca.Azimuth__c = ai.Azimuth__c;
            ca.December_Shade__c=  ai.December_Shade__c; 
            ca.February_Shade__c =  ai.February_Shade__c;
            ca.Inverter_Type__c =ai.Inverter_Type__c; 
            ca.January_Shade__c= ai.January_Shade__c ;
            ca.July_Shade__c =  ai.July_Shade__c; 
            ca.June_Shade__c =  ai.June_Shade__c;
            ca.Service_contract__c =  ai.Service_contract__c;
            ca.March_Shade__c = ai.March_Shade__c;
            ca.May_Shade__c = ai.May_Shade__c;
            ca.November_Shade__c = ai.November_Shade__c;
            ca.October_Shade__c = ai.October_Shade__c;
            ca.Production__c = ai.Production__c;
            ca.September_Shade__c = ai.September_Shade__c;
            caList.add(ca);
             insert caList;
         
            Asset__c asset2 = New Asset__c();
            asset2.ServiceContract__c = sc.Id;
            asset2.Type__c = 'Asset';
            asset2.RecordTypeId = recordTypeId;
            asset2.Status__c = 'Inactive';
            insert  asset2;  
            Test.stoptest();         
           
                    
    }
}