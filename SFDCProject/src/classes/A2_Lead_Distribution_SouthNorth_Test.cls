@isTest(SeeAlldata = true)
private class A2_Lead_Distribution_SouthNorth_Test{

    static testMethod void addLeds() {
        List<Lead> lst_Lead = new List<Lead>();
        List<Account> accList = new List<Account>();
        List<Lead_Distribution__c> lst_Lead_Distribution = new List<Lead_Distribution__c>();
        List<RecordType> rt = [ Select Id from RecordType Where sObjectType='Account' AND Name='Partner'];
        Account Ac  = new Account(Name='REC Solar', Active__c=true, RecordTypeId=rt[0].Id, channel_type__c='Retail', Office_Location__c='Headquarters',   Stage__c='Confirmed' );
        Account acCostco  = new Account(Name='Costco Test', Active__c=true, RecordTypeId=rt[0].Id, channel_type__c='Retail', Office_Location__c='Headquarters',   Stage__c='Confirmed' );
        accList.add(Ac);
        accList.add(acCostco);
        insert accList;
        //insert new Settings__c(Name='CostcoLeadSyncEnabled', Value1__c='true');
        Settings__c   sett=[select id,name,value1__c from settings__c where Name='CostcoLeadSyncEnabled'];
        sett.value1__c='false';
        update sett;
        lst_Lead_Distribution.add(new Lead_Distribution__c(Name='TestOne',  Active__c=true, Sunrun_North_Distribution__c=50, Sunrun_South_Distribution__c=50));
        
        lst_Lead.add(new lead(FirstName='TestFirst1', lastname='testLast1', Sales_Partner__c=Ac.Id, Company='TestComp1', Lead_Origin__c='SunRun', Status='Open', LeadSource='Retail: Costco In Store',Lead_Organization_Location_2__c=ac.id, Channel__c='3rd Party', Promotion_Code__c='MNCTy35', State__c='CA', Utility_Company__c='LADWP', Installation_Type__c='Roof'));
        
        lst_Lead.add(new lead(FirstName='TestFirst1', lastname='testLast1A', Sales_Partner__c=Ac.Id,  Company='TestComp1', Lead_Origin__c='SunRun', Status='Open', LeadSource='Retail: Costco In Store',Lead_Organization_Location_2__c=ac.id, Channel__c='3rd Party', Promotion_Code__c='MNCTy35A', State__c='FL', Installation_Type__c='Roof'));
        
        lst_Lead.add(new lead(FirstName='TestFirst1', lastname='testLast2', Sales_Partner__c=Ac.Id, Company='TestComp1', Lead_Origin__c='SunRun', Status='Open', LeadSource='Retail: Costco In Store',Lead_Organization_Location_2__c=ac.id, Channel__c='Retail',Field_Marketing_Branch__c='Denver', Promotion_Code__c='MNCTy36', State__c='FL',  Installation_Type__c='Roof'));
        
        lst_Lead.add(new lead(FirstName='TestFirst1', lastname='testLast3', Sales_Partner__c=Ac.Id, Company='TestComp1', Lead_Origin__c='SunRun', Status='Open', LeadSource='Retail: Costco In Store',Lead_Organization_Location_2__c=acCostco.id, Channel__c='Retail',Field_Marketing_Branch__c='Denver', Promotion_Code__c='MNCTy37', State__c='FL', Custom_Lead_Source__c = 'Retail: Costco In Store', Installation_Type__c='Roof'));
        
        lst_Lead.add(new lead(FirstName='TestFirst1', lastname='testLast4', Sales_Partner__c=Ac.Id, Company='TestComp1', Lead_Origin__c='SunRun', Status='Open', LeadSource='Retail: Costco In Store',Lead_Organization_Location_2__c=acCostco.id, Channel__c='Retail',Field_Marketing_Branch__c='Denver', Promotion_Code__c='MNCTy38', State__c='CA', Custom_Lead_Source__c = 'Retail: Costco In Store' , Utility_Company__c='CA - Pasadena Water and Power (PWP)', Installation_Type__c='Roof'));
        
        lst_Lead.add(new lead(FirstName='TestFirst1', lastname='testLast5', Sales_Partner__c=Ac.Id, Company='TestComp1', Lead_Origin__c='SunRun', Status='Open', LeadSource='Retail: Costco In Store',Lead_Organization_Location_2__c=ac.id, Channel__c='Event', Custom_Lead_Source__c = 'Event : Unknown',Field_Marketing_Branch__c='Denver', Promotion_Code__c='MNCTy23', State__c='CA', Utility_Company__c='CA - Pasadena Water and Power (PWP)', Installation_Type__c='Roof'));
        
        lst_Lead.add(new lead(FirstName='TestFirst1', lastname='testLast6', Company='TestComp1', Lead_Origin__c='SunRun', Status='Open', LeadSource='Retail: Costco In Store', Channel__c='Retail',Lead_Organization_Location_2__c=ac.id, Promotion_Code__c='MNCTy13',Field_Marketing_Branch__c='Denver', State__c='CA', Utility_Company__c='CA - Pasadena Water and Power (PWP)', Installation_Type__c='Roof', Sales_Partner__c=Ac.Id, Partner_for_Lead_Passing__c=Ac.Id));
        
        lst_Lead.add(new lead(FirstName='TestFirst1', lastname='testLast7', Sales_Partner__c=Ac.Id, Company='TestComp1', Lead_Origin__c='SunRun', Status='Open', LeadSource='Retail: Costco In Store', Channel__c='Retail',Lead_Organization_Location_2__c=ac.id,Field_Marketing_Branch__c='Denver', Promotion_Code__c='MNCTy93', State__c='CA', Utility_Company__c='CA - Pasadena Water and Power (PWP)', Installation_Type__c='Roof'));
        
        lst_Lead.add(new lead(FirstName='TestFirst1', lastname='testLast8', Sales_Partner__c=Ac.Id, Company='TestComp1', Lead_Origin__c='SunRun', Status='Open', LeadSource='Retail: Costco In Store', Channel__c='Retail',Lead_Organization_Location_2__c=ac.id,Field_Marketing_Branch__c='Denver', Promotion_Code__c='MNCTy83', State__c='CA', Utility_Company__c='CA - Pasadena Water and Power (PWP)', Installation_Type__c='Roof'));
        
        lst_Lead.add(new lead(FirstName='TestFirst1', lastname='testLast9', Sales_Partner__c=Ac.Id, Company='TestComp1', Lead_Origin__c='SunRun', Status='Open', LeadSource='Retail: Costco In Store', Channel__c='Unknown', Promotion_Code__c='MNCTy73',Field_Marketing_Branch__c='Denver', State__c='CA', Utility_Company__c='SCE', Installation_Type__c='Roof'));
        
        lst_Lead.add(new lead(FirstName='TestFirst1', lastname='testLast10', Sales_Partner__c=Ac.Id, Company='TestComp1', Lead_Origin__c='SunRun', Status='Open', LeadSource='Retail: Costco In Store', Channel__c='Retail',Lead_Organization_Location_2__c=acCostco.id,Field_Marketing_Branch__c='Denver', Custom_Lead_Source__c = 'Retail: Costco In Store' , Promotion_Code__c='MNCTy63', State__c='CA', Utility_Company__c='SCE', Installation_Type__c='Roof'));
        
        lst_Lead.add(new lead(FirstName='TestFirst1', lastname='testLast11', Sales_Partner__c=Ac.Id, Company='TestComp1', Lead_Origin__c='SunRun', Status='Open', LeadSource='Retail: Costco In Store', Channel__c='3rd Party', Promotion_Code__c='MNCTy53', State__c='CA', Utility_Company__c='CA - Pasadena Water and Power (PWP)', Installation_Type__c='Roof'));
        
        lst_Lead.add(new lead(FirstName='TestFirst1', lastname='testLast12', Sales_Partner__c=Ac.Id, Company='TestComp1', Lead_Origin__c='SunRun', Status='Open', LeadSource='Retail: Costco In Store', Channel__c='Retail',Lead_Organization_Location_2__c=ac.id,Field_Marketing_Branch__c='Denver', Promotion_Code__c='MNCTy43', State__c='CA', Utility_Company__c='CA - Pasadena Water and Power (PWP)', Installation_Type__c='Roof'));
        lst_Lead.add(new lead(FirstName='TestFirst1', lastname='testLast15', Company='TestComp1', Status='Open', Channel__c='3rd Party', state='CA',state__c='CA',Utility_Company__c='SMUD', Installation_Type__c='Roof'));        
        lst_Lead.add(new lead(FirstName='TestFirst1', lastname='testLast15', Company='TestComp1', Status='Open', Channel__c='3rd Party', state='IL',state__c='IL'));                
        lst_Lead.add(new lead(FirstName='TestFirst1', lastname='testLast13', Sales_Partner__c=Ac.Id, Company='TestComp1', Lead_Origin__c='SunRun', Status='Open', LeadSource='Retail: Costco In Store', Channel__c='Retail',Lead_Organization_Location_2__c=ac.id,Field_Marketing_Branch__c='Denver', Promotion_Code__c='MNCTy43', State__c='CA', Utility_Company__c='CA - Pasadena Water and Power (PWP)', Installation_Type__c='Roof', Referred_by_Contact_Email__c = 'maruthi.reddy@sunrun.com', Campaign_ID__c = 'United Airlines', Costco_Location__c = 'CA-Coachella Valley-441', Referred_by_Contact_First_Name__c = 'Test contact First Name13', Referred_by_Contact_Last_Name__c= 'Test Contact Last Name13', Referred_by_Contact_Phone__c = '4081111111'));
        lst_Lead.add(new lead(FirstName='TestFirst14', lastname='testLast14', Company='TestComp1', Status='Open', Channel__c='3rd Party', state='NJ',State__c='NJ'));
        lst_Lead.add(new lead(FirstName='TestFirst14', lastname='testLast14', Company='TestComp1', Status='Open', Channel__c='3rd Party', state='NJ',State__c='NJ'));
        List<Lead> lst_Lead2 = new List<Lead>();
        lst_Lead2.add(new lead(FirstName='TestFirst1', lastname='testLastaB', Sales_Partner__c=Ac.Id, Company='TestComp1', Lead_Origin__c='SunRun', Status='Open', LeadSource='Retail: Costco In Store',Lead_Organization_Location_2__c=ac.id, Channel__c='3rd Party', Promotion_Code__c='MNCTay35', State__c='CA', Utility_Company__c='LADWP', Installation_Type__c='Roof'));
        
        lst_Lead2.add(new lead(FirstName='TestFirst1', lastname='testLastc', Company='TestComp1', Lead_Origin__c='SunRun', Status='Open', LeadSource='Retail: Costco In Store', Channel__c='3rd Party',Lead_Organization_Location_2__c=ac.id, Promotion_Code__c='MNaCTy35A', State__c='FL', Installation_Type__c='Roof'));
        
        lst_Lead2.add(new lead(FirstName='TestFirst1', lastname='testLastd', Company='TestComp1', Lead_Origin__c='SunRun', Status='Open', LeadSource='Retail: Costco In Store', Channel__c='Retail',Lead_Organization_Location_2__c=ac.id,Field_Marketing_Branch__c='Denver', Promotion_Code__c='MaNCTy36', State__c='FL',  Installation_Type__c='Roof'));
        
        lst_Lead2.add(new lead(FirstName='TestFirst1', lastname='testLastf', Company='TestComp1', Lead_Origin__c='SunRun', Status='Open', LeadSource='Retail: Costco In Store', Channel__c='Retail',Lead_Organization_Location_2__c=acCostco.id,Field_Marketing_Branch__c='Denver', Promotion_Code__c='MaNCTy37', State__c='FL', Custom_Lead_Source__c = 'Retail: Costco In Store', Installation_Type__c='Roof'));
        
        lst_Lead2.add(new lead(FirstName='TestFirst1', lastname='testLastg', Company='TestComp1', Lead_Origin__c='SunRun', Status='Open', LeadSource='Retail: Costco In Store', Channel__c='Retail',Lead_Organization_Location_2__c=acCostco.id,Field_Marketing_Branch__c='Denver', Promotion_Code__c='MaNCTy38', State__c='CA', Custom_Lead_Source__c = 'Retail: Costco In Store' , Utility_Company__c='CA - Pasadena Water and Power (PWP)', Installation_Type__c='Roof'));
        
        lst_Lead2.add(new lead(FirstName='TestFirst1', lastname='testLasth', Company='TestComp1', Lead_Origin__c='SunRun', Status='Open', LeadSource='Retail: Costco In Store', Channel__c='Event',Lead_Organization_Location_2__c=ac.id,Field_Marketing_Branch__c='Denver', Custom_Lead_Source__c = 'Event : Unknown', Promotion_Code__c='MaNCTy23', State__c='CA', Utility_Company__c='CA - Pasadena Water and Power (PWP)', Installation_Type__c='Roof'));
        
        lst_Lead.add(new lead(FirstName='TestFirst1', lastname='testLast6', Company='TestComp1', Lead_Origin__c='SunRun', Status='Open', LeadSource='Retail: Costco In Store', Channel__c='Retail',Lead_Organization_Location_2__c=ac.id,Field_Marketing_Branch__c='Denver', Promotion_Code__c='MNCTy13', State__c='CA', Utility_Company__c='CA - Pasadena Water and Power (PWP)', Installation_Type__c='Roof', Sales_Partner__c=Ac.Id, Partner_for_Lead_Passing__c=Ac.Id));
        
        lst_Lead2.add(new lead(FirstName='TestFirst1', lastname='testLasti', Company='TestComp1', Lead_Origin__c='SunRun', Status='Open', LeadSource='Retail: Costco In Store', Channel__c='Retail',Lead_Organization_Location_2__c=ac.id,Field_Marketing_Branch__c='Denver', Promotion_Code__c='MaNCTy93', State__c='CA', Utility_Company__c='CA - Pasadena Water and Power (PWP)', Installation_Type__c='Roof'));
        
        lst_Lead2.add(new lead(FirstName='TestFirst1', lastname='testLastj', Company='TestComp1', Lead_Origin__c='SunRun', Status='Open', LeadSource='Retail: Costco In Store', Channel__c='Retail',Lead_Organization_Location_2__c=ac.id,Field_Marketing_Branch__c='Denver', Promotion_Code__c='MaNCTy83', State__c='CA', Utility_Company__c='CA - Pasadena Water and Power (PWP)', Installation_Type__c='Roof'));
        
        lst_Lead2.add(new lead(FirstName='TestFirst1', lastname='testLastk', Company='TestComp1', Lead_Origin__c='SunRun', Status='Open', LeadSource='Retail: Costco In Store', Channel__c='Unknown',Lead_Organization_Location_2__c=ac.id, Promotion_Code__c='MaNCTy73', State__c='CA', Utility_Company__c='SCE', Installation_Type__c='Roof'));
        
        lst_Lead2.add(new lead(FirstName='TestFirst1', lastname='testLastl0', Company='TestComp1', Lead_Origin__c='SunRun', Status='Open', LeadSource='Retail: Costco In Store', Channel__c='Retail',Lead_Organization_Location_2__c=acCostco.id,Field_Marketing_Branch__c='Denver', Custom_Lead_Source__c = 'Retail: Costco In Store' , Promotion_Code__c='MaCTy63', State__c='CA', Utility_Company__c='SCE', Installation_Type__c='Roof'));
        
        lst_Lead2.add(new lead(FirstName='TestFirst1', lastname='testLast11', Company='TestComp1', Lead_Origin__c='SunRun', Status='Open', LeadSource='Retail: Costco In Store', Channel__c='3rd Party',Lead_Organization_Location_2__c=ac.id, Promotion_Code__c='MNCTy53', State__c='CA', Utility_Company__c='CA - Pasadena Water and Power (PWP)', Installation_Type__c='Roof'));
        
        lst_Lead2.add(new lead(FirstName='TestFirst1', lastname='testLast12', Company='TestComp1', Lead_Origin__c='SunRun', Status='Open', LeadSource='Retail: Costco In Store', Channel__c='Retail',Lead_Organization_Location_2__c=ac.id,Field_Marketing_Branch__c='Denver', Promotion_Code__c='MNCTy43', State__c='CA', Utility_Company__c='CA - Pasadena Water and Power (PWP)', Installation_Type__c='Roof'));       
        
        Test.startTest();
            
           // insert lst_Lead_Distribution;
            //insert lst_Lead;
            //insert lst_Lead2; 
            //Lead_Distribution_SouthNorth.exceptionHandler(lst_Lead[0],'Error');       
            //Lead_Distribution_SouthNorth.updateRelatedValues(lst_Lead);   
        Test.StopTest();
    }
     
}