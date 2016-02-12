@isTest
private class OpportunityController_Test{

    @isTest(seeAllData=true)
    public static void oppCtrlAdminTest(){
        
        String PROFILE_NAME = 'System Administrator';
        User adminUser = [select Id, profileId from User where profile.Name =:PROFILE_NAME AND isActive = true limit 1];
        
        if(Opty_Custom_Setting__c.getInstance() == null && Opty_Custom_Setting__c.getInstance(adminUser.profileId).ProfileNames__c == null){
            Opty_Custom_Setting__c objCS = new Opty_Custom_Setting__c(
                SetupOwnerId = adminUser.profileId,
                ProfileNames__c = PROFILE_NAME
            );
            insert objCS;
        }
        List<Schema.RecordTypeInfo> rtInfoList = Schema.Sobjecttype.Opportunity.getRecordTypeInfos();
        
        System.runAs(adminUser){
            PageReference pageRef = Page.NewOpportunity;
            Test.setCurrentPageReference(pageRef);
            
            
            Opportunity objOpp = new Opportunity();
            ApexPages.StandardController sc = new ApexPages.StandardController(objOpp);
            
            OpportunityController objOppController = new OpportunityController(sc);
            pagereference loadPage = objOppController.selectedRecordType();
            
            system.debug('Page Name ===>> ' + loadPage);
            
            List<SelectOption> soList = objOppController.getRecordTypes();
            pagereference cancelPage = objOppController.cancel();
            
            if(soList != null && soList.size() > 0){
                objOppController.selectedRecTypeId = soList[0].getValue();
                objOppController.countinueButtonClick();
            }
            system.assertEquals(rtInfoList.size()-1, soList.size());
        }
    }
    
    @isTest(seeAllData=true)
    public static void oppCtrlNonAdminTest(){
        String PROFILE_NAME = 'Sales - Channel Development';
        
        User nonAdminUser = [select Id, profileId from User where profile.Name =:PROFILE_NAME AND isActive = true limit 1];
        
        if(Opty_Custom_Setting__c.getInstance() == null && Opty_Custom_Setting__c.getInstance(nonAdminUser.profileId).ProfileNames__c == null){
            Opty_Custom_Setting__c objCS = new Opty_Custom_Setting__c(
                SetupOwnerId = nonAdminUser.profileId,
                ProfileNames__c = PROFILE_NAME
            );
            insert objCS;
        }
        List<Schema.RecordTypeInfo> rtInfoList = Schema.SobjectType.Opportunity.getRecordTypeInfos();
        
        System.runAs(nonAdminUser){
            PageReference pageRef = Page.NewOpportunity;
            Test.setCurrentPageReference(pageRef);
            Opportunity objOpp = new Opportunity();
            ApexPages.StandardController sc = new ApexPages.StandardController(objOpp);
            
            OpportunityController objOppController = new OpportunityController(sc);
            pagereference loadPage = objOppController.selectedRecordType();
            List<SelectOption> soList = objOppController.getRecordTypes();
            pagereference cancelPage = objOppController.cancel();
            
            if(soList != null && soList.size() > 0){
                objOppController.selectedRecTypeId = soList[0].getValue();
                objOppController.countinueButtonClick();
            }
            system.assert(rtInfoList.size()-1 >= soList.size());
        }
    }
    
    
    @isTest(seeAllData=true)
    public static void singleRecTyepTest(){
        String PROFILE_NAME = 'Sales - Channel Development';//Profile name with Single opp record type access
        User nonAdminUser = [select Id, profileId from User where profile.Name =:PROFILE_NAME AND isActive = true limit 1];
        
        if(nonAdminUser != null){
            if(Opty_Custom_Setting__c.getInstance() == null && Opty_Custom_Setting__c.getInstance(nonAdminUser.profileId).ProfileNames__c == null){
                Opty_Custom_Setting__c objCS = new Opty_Custom_Setting__c(
                    SetupOwnerId = nonAdminUser.profileId,
                    ProfileNames__c = PROFILE_NAME
                );
                insert objCS;
            }
            List<Schema.RecordTypeInfo> rtInfoList = Schema.SobjectType.Opportunity.getRecordTypeInfos();
            
            System.runAs(nonAdminUser){
                PageReference pageRef = Page.NewOpportunity;
                Test.setCurrentPageReference(pageRef);
                Opportunity objOpp = new Opportunity();
                ApexPages.StandardController sc = new ApexPages.StandardController(objOpp);
                
                OpportunityController objOppController = new OpportunityController(sc);
                List<SelectOption> soList = objOppController.getRecordTypes();
                pagereference cancelPage = objOppController.cancel();
                pagereference loadPage = objOppController.selectedRecordType();
                
                if(loadPage != null && loadPage.getUrl() != null){
                    string Url = string.valueOf(loadPage.getUrl());
                    system.assert(!Url.containsIgnoreCase('NewOpportunity'));
                }
                
                system.assert(rtInfoList.size()-1 >= soList.size());
            }
        }
    }
}