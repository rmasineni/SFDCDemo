@istest(seeAllData=true)
public with sharing class Test_trg_fs_dispatch_after_update{
     static testMethod void myUnitTest() {
     Test.starttest();  
      
      Account a = new Account(name ='TEST ACCOUNT',Type = 'partner');
      insert a;
      Contact con = new Contact(FirstName = 'TestAcct',LastName = 'TestAcctOppty',Email = 'emailfake@fakeemail.net',AccountId = a.Id);
      insert con;
      Generation_Assets__c gen= new Generation_Assets__c (Home_Address__c='2950 California',City__c='Santa Clara',Zip__c='90000',Customer_Contact__c=con.Id);
      insert gen;Case cs = new case (Status ='Open',Reason='Customer');  
      //insert cs;
      Case cs1 = new case (Status ='Open',Reason=null,Generation_Asset__c=gen.Id);  
      //insert cs1;
      List<Case> caselist=new List<Case>();
      caselist.add(cs);
      caselist.add(cs1);
      insert caselist;  
      ServiceContract sc = new ServiceContract(AccountId=a.Id,Name='service test');
      insert sc;
      sc = [select id from ServiceContract LIMIT 1 ];
      update sc;
      FS_Dispatch__c fsd = new FS_Dispatch__c(FS_Parent_Case__c=cs.Id,FS_Dispatch_State__c='new',FS_Approve_Findings__c = true,FS_Generation_Asset__c=gen.Id);//,Close_Case__c='false');//,Close_Case__c='true');
      insert fsd;
       
      fsd.Close_Case__c=Boolean.valueof('true');
      fsd.FS_Dispatch_State__c = 'Dispatched';
      fsd.FS_Service_Contract__c = sc.Id;
      update fsd;

     
      
      test.stoptest();
      }
}