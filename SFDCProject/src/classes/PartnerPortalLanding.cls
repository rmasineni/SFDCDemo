public without sharing class PartnerPortalLanding {

public String accountMessage{get;set;}
public String accountMessage2{get;set;}

public PartnerPortalLanding(){
//
  for(Contact con:[select id, AccountId, Account.Name, Account.Account_Article__c, Account.Account_Article2__c from Contact where id in (select ContactId from User where Id = :UserInfo.getUserId())])
  {
    System.Debug('ARTICLE: '+con.Account.Account_Article__c);
    accountMessage = con.Account.Account_Article__c;
    accountMessage2 = con.Account.Account_Article2__c;
  }

}
@IsTest(SeeAllData=true) 
public static void testPartnerPortalLanding(){
    
    Id userId = PartnerDetail__c.getValues('EDPTestAccount').PartnerUserId__c;
    User partnerUser = [Select id, name, email from User where Id =:userId];        
    System.runAs(partnerUser){
        PartnerPortalLanding PartnerPortalLandingobj = new PartnerPortalLanding();
    }
}

}