@isTest(SeeAllData=true)
public with sharing class Test_LeadUtil {
    public static testmethod void Test_LeadUtil(){       
        Account acc = new Account(name='Test1',billingpostalcode='00000',billingstate='CA'); 
        insert acc;
        Contact cont = new contact(firstname='TestFirst',lastname='contact1',Ultimate_Parent_Account__c = acc.Id,otherphone='9998887776'); 
        insert cont;
        Promotion__c promotion = new Promotion__c(Name='Test2',Promotion_Type__c='Customer',Start_Date__c=system.today()-5,end_date__c=system.today()+4);
        insert promotion ;
        offer__c offer=new offer__c(promotion__c=promotion.id,Customer_Contact__c=cont.id);
        insert offer;       
        Lead lead=new Lead(state='CA',city='San Francisco',street='123 street',postalcode='12345',lastname='Test',channel__c='Test',company='Home',average_Monthly_Electric_Bill__c=100,firstname='Test',email='tset@yopmail.com',alternate_phone__c='(111)-(111)-(1234)',phone='(123)-(123)-(1234)');
        insert lead;        
        Opportunity opp = new Opportunity(name='Test11',Accountid=acc.id,Average_Monthly_Electric_Bill__c=66,stagename='Created',CloseDate=system.today(),Offer__c=offer.Id);
        insert opp;           
          
        map<id, Lead> convertedContactMap = new Map<Id,Lead>();
        convertedContactMap.put(cont.Id,Lead);
        map<id, string> convertedAccountMap = new Map<Id,string>();
        convertedAccountMap.put(acc.Id,acc.name);
        map<id, string> convertedOpptyMap = new Map<Id,string>();
        convertedOpptyMap.put(opp.Id,opp.name);
        map<id,id> mapOffertoOppty = new Map<Id,Id>();
        mapOffertoOppty.put(opp.Id,opp.Offer__c);
         
        Test.StartTest();
        LeadUtil.UpdateContactOnConversion(convertedContactMap);
        LeadUtil.UpdateAccountOnConversion(convertedAccountMap);
        LeadUtil.UpdateOpptyOnConversion(convertedOpptyMap);
        LeadUtil.UpdateOpptywithOffer(mapOffertoOppty);
        Test.StopTest(); 
    }
}