@isTest(SeeAllData=true)
public with sharing class Test_trg_opp_zip_to_utility {
    
    static testmethod void method1(){
    ZipUtility__c zp=new ZipUtility__c(Territory__c='P',Zip_Code__c='00000',State__C='CA',Utility_Company__c='Pacific Gas and Electric (PG&E)',Sales_Branch__c='Bakersfield');
    List<ZipUtility__c> zpList=new List<ZipUtility__c>();
    zpList.add(zp);
    insert zp; 
    Account recAcc= new Account(name='SunRun',billingpostalcode='00000');
    insert recAcc;
    Opportunity opp = new Opportunity(Accountid=recAcc.id,Name='Test123',stagename='Closed Won',Closedate=system.today(),Sales_Branch__c='South Bay Area');
    insert opp;
    opp.Sales_Branch__c='Bakersfield';
    update opp;
    }

    static testmethod void method2(){
    ZipUtility__c zp=new ZipUtility__c(Territory__c='P',Zip_Code__c='00000',State__C='CA',Utility_Company__c='Pacific Gas and Electric (PG&E)',Sales_Branch__c='Bakersfield');
    List<ZipUtility__c> zpList=new List<ZipUtility__c>();
    zpList.add(zp);
    insert zp; 
    Account recAcc= new Account(name='SunRun',billingpostalcode='00000');
    insert recAcc;
    Lead newlead = new Lead(state='CA',city='San Francisco',street='123 street',postalcode='12345',lastname='Test',channel__c='Test',company='Home');
    insert newlead; 
    Opportunity opp = new Opportunity(Accountid=recAcc.id,lead_id__c=newlead.Id,Name='Test123',stagename='Closed Won',Closedate=system.today(),Sales_Branch__c='South Bay Area');
    insert opp;
    opp.Sales_Branch__c='Bakersfield';
    update opp;
    }
    
    static testmethod void method3(){
    ZipUtility__c zp=new ZipUtility__c(Territory__c='P',Zip_Code__c='00000',State__C='CA',Utility_Company__c='Pacific Gas and Electric (PG&E)',Sales_Branch__c='Bakersfield');
    List<ZipUtility__c> zpList=new List<ZipUtility__c>();
    zpList.add(zp);
    insert zp; 
    Account recAcc= new Account(name='SunRun',billingpostalcode='11111');
    insert recAcc;
    Lead newlead = new Lead(state='CA',city='San Francisco',street='123 street',postalcode='12345',lastname='Test',channel__c='Test',company='Home');
    insert newlead; 
    Opportunity opp = new Opportunity(Accountid=recAcc.id,lead_id__c=newlead.Id,Name='Test123',stagename='Closed Won',Closedate=system.today(),Sales_Branch__c='South Bay Area');
    insert opp;
    opp.Sales_Branch__c='Bakersfield';
    update opp;
    }
 }