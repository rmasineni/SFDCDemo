@istest(seealldata=true)
public with sharing class UnitTest_OpportunityOverride {
static testmethod void method1(){
     Opportunity optyObj1 = TestPRMLibrary.insertOpportunity('ResidentialAccount-3', 'Residential',
                                                                'ResOpty-3', 'Platinum');
     ApexPages.StandardController controller = new Apexpages.Standardcontroller(optyObj1);
     OpportunityOverride oppExt = new OpportunityOverride(controller); 
     oppExt.goRedirectCustomOpptyEdit();
     oppExt.checkUserProfile(); 
     Id userId = PartnerDetail__c.getValues('ApexTestAccount').PartnerUserId__c;
     User partnerUser = [Select id, name, email from User where Id =:userId];        
     System.runAs(partnerUser){
         oppExt.goRedirectCustomOpptyEdit();
         oppExt.checkUserProfile();     
     }
}
}