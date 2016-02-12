@isTest
public class CoreLogicInfoUpdateTest {
    @isTest static void testMethod1(){
        Set<String> LandUseCodeSet = new Set<String>();
        Account a = new Account(Name= 'TestAccount', BillingStreet='480 Fell St Apt 3', BillingCity = 'San Francisco', BillingState = 'CA', BillingCountry = 'US', latitude__c = 37.775830900000000, Longitude__c= 122.425776000000000 ,Land_Use__c ='' );
        insert a;
        a.Land_Use__c = '106';
        update a;
        LandUseCodeSet.add(a.Land_Use__c);
        Land_Use__c l = new Land_Use__c( Name = '106',Description__c='APARTMENT',Type__c ='MULTI FAMILY DWELLING',Permitted__c = true);
        insert l;
        Land_Use__c l1 = [select id,type__c from Land_Use__c where Name IN :LandUseCodeSet];
        a.Land_Use_Type__c = l1.Type__c;
       
        }
}