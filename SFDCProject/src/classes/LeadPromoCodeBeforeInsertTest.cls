@isTest(seeallData=true)
public class LeadPromoCodeBeforeInsertTest {
    public static testmethod void test1(){
        List<Promotion__c> promolist = New List<Promotion__c>();
        Promotion__c promo = new Promotion__c(Promotion_Type__c='Customer', Promotion_Code__c = '',Name='Test Promotion',Start_Date__c=system.today(),End_Date__c=system.today()+90);
        Promotion__c promo1 = new Promotion__c(Promotion_Type__c='Customer', Promotion_Code__c = 'cu1234',Name='Test Promotion',Start_Date__c=system.today(),End_Date__c=system.today()+90);
        promolist.add(promo);
        promolist.add(promo1);
        Lead ld = new Lead(lastname='Test',company='Home',firstname='Test',email='tset@yopmail.com',Promotion_Name__c=promo1.Id);
        insert ld;
        
    }

}