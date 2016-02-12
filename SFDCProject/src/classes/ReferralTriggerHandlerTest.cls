@istest
public class ReferralTriggerHandlerTest
{
private static BaseClass utils = new BaseClass();
 static testMethod void myunitReferral()
 {
   Contact contactObj1 = TestPRMLibrary.insertContact('PRMTestAccount1', 
                      PRMLibrary.PARTNER, 
                      'PRMTestLastName1',
                      'prmcontact1@sunrun.com');
                      
      Opportunity optyObj1 = TestPRMLibrary.insertOpportunity('ResidentialAccount-01', 'Residential','ResOpty-01', 'Platinum'); 
      optyObj1.SalesRep__c = UserInfo.getUserId();
      optyObj1.Sales_Partner__c  = contactObj1.AccountId;
      upsert optyObj1;
  
        Account acct = new Account(Id=contactObj1.AccountId,Name='Foo', RecordTypeId=utils.getRecordTypeId('Account', 'Partner'), 
        Sqs_Queue_Name__c='Test',
        Office_Location__c  = 'Headquarters',
        Stage__c = 'Confirmed',
        Active__c  = true);
        update acct;
    
                      
                         
        Lead lead = new Lead(FirstName='Foo', LastName='Bar', Company='Foo');   
        lead.Lead_Status__c = 'Updated2';
        lead.Lead_Gen_Partner__c = contactObj1 .accountId;
        lead.Sales_Partner__c = contactObj1 .accountId;
        lead.Partner_for_Lead_Passing__c = contactObj1 .accountId;
        insert lead;
        ServiceContract objSC = new ServiceContract(ContactId =contactObj1.Id,Opportunity__c = optyObj1.Id );
        insert objSC;
  
     Referral_Input__c referral = new Referral_Input__c(Lead__c =lead.id,Service_Contract_RR__c  =objSC.Id );
    referral.Source_Contact_Id__c  = contactObj1.Id;
    insert referral;
 
 
 }

}