@isTest(SeeAllData=true)
public class Employee_ReferralTest {
    
   private static  Account oAccount = UtilClassForTestCoverage.CreateAccount('Test Account');
   private static  Contact oContact = UtilClassForTestCoverage.createContact('Last Name','testemail@sunrun.com','Test Account','Admin','',oAccount.Id);
  // system.debug('>>> Id' + oAccount.id + oContact.id + oContact.Email );
      
    public static testMethod void RunTest1()

    {
      //  system.debug('>>> Id' + oAccount.id + oContact.id + oContact.Email );
       Account oAccount1 = UtilClassForTestCoverage.CreateAccount('Test Account');
        Contact oContact1 = UtilClassForTestCoverage.createContact('Last Name123','testemail@sunrun.com','Test Account','Admin','',oAccount1.Id);
        oContact1.recordtypeid='01260000000UN6HAAW';
        oContact1.ERP_Contact_of_Record__c=true;
        oContact1.Ambassador__Ambassador_ID__c = '';
        update oContact1;
        test.StartTest();
     controlContactTriggerRecursion.AllowTriggerFlag = true;
        list<contact> ContactLstToInsert = new list<contact>();
        contact con1 = new contact();
        con1.lastname = 'Last NameRunTest1';
        con1.email = 'testemail@sunrun.com';
        con1.AccountId = oAccount1.id;
        con1.Job_Function__c= 'Admin';
        con1.Ambassador__Ambassador_ID__c = '45328'; 
        con1.ERP_Contact_of_Record__c=true;
        
        contact con2 = new contact();
        con2.lastname = 'Last Name2RunTest1';
        con2.email = 'testemail@sunrun.com';
        con2.AccountId = oAccount1.id;
        con2.Job_Function__c= 'Admin';
        con2.Ambassador__Ambassador_ID__c = '58475'; 
        con2.ERP_Contact_of_Record__c=true;
        
        ContactLstToInsert.add(con1);
        ContactLstToInsert.add(con2);
        insert ContactLstToInsert;
        
      //  system.debug('>>> Id' + oAccount1.id + oContact1.id + oContact1.Email );
        
        system.debug('>>> con2.CreatedDate' + con2.CreatedDate +'$&!@$(&!@#!Con2 Id = '+con2.lastname);
        system.debug('>>> con1.CreatedDate' + con1.CreatedDate +'*#!@!@$#!*#!@Con1 Id = '+con1.lastname);
        
        Contact oContact13 = new contact();
        oContact13.lastname='Last Name123';
        oContact13.email ='testemail@sunrun.com';
        oContact13.Job_Function__c= 'Admin';
        oContact13.accountid= oAccount1.Id;
        oContact13.recordtypeid='01260000000UN6HAAW';
        oContact13.ERP_Contact_of_Record__c=true;
        oContact13.Ambassador__Ambassador_ID__c = '';
        insert oContact13;
        
         controlContactTriggerRecursion.AllowTriggerFlag = true;
        if(con2.CreatedDate > con1.CreatedDate)
        {
            con2.Ambassador__Ambassador_ID__c = '13478'; 
            con2.External_Id__c = null;
           // update con2;
        }
        else{
            con1.Ambassador__Ambassador_ID__c = '13478'; 
            con1.External_Id__c = null;
            //update con1;
        }
        controlContactTriggerRecursion.AllowcontactTrigger = true;
         update ContactLstToInsert;
         test.StopTest();
     }
    
       public static testMethod void RunTest2()

    {

        Account oAccount2 = UtilClassForTestCoverage.CreateAccount('Test Account');
        Contact oContact2 = UtilClassForTestCoverage.createContact('Last Name','testemail@sunrunhome.com','Test Account','Admin','',oAccount2.Id);
      //  oContact2.ERP_Contact_of_Record__c = true;
        oContact2.Ambassador__Ambassador_ID__c='1234';
        oContact2.External_Id__c='testemail@sunrunhome.com';
         controlContactTriggerRecursion.AllowTriggerFlag = true;
        update oContact2;
        
        list<contact> ContactLstToInsert = new list<contact>();
        
        
        contact con1 = new contact();
        con1.lastname = 'Last Name';
        con1.email = 'testemail@sunrunhome.com';
        con1.AccountId = oAccount2.id;
        con1.Job_Function__c= 'Admin';
        con1.Ambassador__Ambassador_ID__c = '12346'; 
        con1.ERP_Contact_of_Record__c = False;
        
        contact con2 = new contact();
        con2.lastname = 'Last Name2';
        con2.email = 'testemail@sunrunhome.com';
        con2.AccountId = oAccount2.id;
        con2.Job_Function__c= 'Admin';
        con2.Ambassador__Ambassador_ID__c = '13456'; 
        con2.ERP_Contact_of_Record__c = False;
        
        ContactLstToInsert.add(con1);
        ContactLstToInsert.add(con2);
         controlContactTriggerRecursion.AllowTriggerFlag = true;
        insert ContactLstToInsert;
        
         system.debug('>>> Id' + oAccount2.id + oContact2.id + oContact2.Email );
         
         
         
         
     }
     
    public static testMethod void RunTest3()
    {

        Account oAccount2 = UtilClassForTestCoverage.CreateAccount('Test Account');
        Contact oContact2 = UtilClassForTestCoverage.createContact('Last Name','testemail@sunrunhome.com','Test Account','Admin','1234',oAccount2.Id);
        oContact2.Mark_for_Delete__c = True;
        update oContact2;
    
        Id batchInstanceId = Database.executeBatch(new Batch_DeleteContact());
    }
}