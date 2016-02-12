@isTest(SeeAllData=true)
private class Test_trg_opty_after_ins_salesrep {

    static testMethod void Test_salesrep() {
        
        Test.starttest();       
        User U=new User(id=userinfo.getuserid());
         
       
        
        Opportunity opp2= new Opportunity( Name='Test123',SalesRep__c=null,Lead_Qualifier__c=u.id,stagename='Created',CloseDate=system.today(),Designer_Assigned_Once__c=false,ready_for__c='Sales',designer__c=u.Id);
        Opportunity opp3= new Opportunity( Name='Test123',SalesRep__c=u.Id,Lead_Qualifier__c=u.id,stagename='Created',CloseDate=system.today(),Designer_Assigned_Once__c=false,ready_for__c='Sales',designer__c=u.Id);
        Opportunity opp4= new Opportunity( Name='Test123',SalesRep__c=u.Id,Lead_Qualifier__c=null,stagename='Created',CloseDate=system.today(),Designer_Assigned_Once__c=false,ready_for__c='Sales');
        Opportunity opp5= new Opportunity( Name='Test123',SalesRep__c=u.Id,Lead_Qualifier__c=u.id,stagename='Created',designer__c=null,designer_assigned_once__c=false,ready_for__c='Sales');//,stagename='Created',CloseDate=system.today(),Accountid=acc.id ,Designer_Assigned_Once__c=false);
        List<Opportunity> opptyList=new List<opportunity>();
        opptyList.add(opp2);
        opptyList.add(opp3);
        opptyList.add(opp4);                
        opptyList.add(opp5);     
        LightMile_User__c lightmuser =  LightMile_User__c.getValues('LightMile User');      
        if(lightmuser !=null){
        User lmuser=new User(id=lightmuser.user_id__c);
        system.runas(lmuser){
        insert opptyList;
        }
        } 
        else{  
         insert opptyList;
         }
       
         Contact c = [Select id, firstname, lastname, email, phone, division__c, department__c,role__c,Sunrun_User__c from Contact where division__c !=null or department__c !=null limit 1];
         Partner_Role__c pr1 = new Partner_Role__c();
         pr1.Opportunity__c = opp3.id;
         pr1.Sales_Rep_Division__c = c.Division__c;
         pr1.Sales_Rep_Email__c = c.Email;
         pr1.Sales_Rep_Phone__c = c.Phone;
         pr1.Department__c = c.Department__c;
         insert pr1;
       
         List<Proposal__c> proList = New List<Proposal__c>();
         Proposal__c pro = New Proposal__c(Upfront_Payment__c = 70000,System_Size_STC_DC__c = 25,Sales_Rep_Email__c = 'testrep@yopmail.com',Name = 'Testproposal',Opportunity__c = opp5.Id,Date_Issued__c = date.today(),Mode_Name__c  = 'Modetest',Stage__c  = 'SR Approved',Sunrun_Credit_Status__c = 'SR Credit Approved');   
         proList.add(pro);           
         insert proList;
         //User newUser=[select id from user where isactive=true order by createddate desc limit 1];
         Test_Partner_User__c newUser= UnitTest_ServiceContractUtil.getBlackBirdSalesRep();
         Opp4.salesrep__c=newUser.User_Id__c;
         List<Opportunity> updateList=new List<Opportunity>();
         updateList.add(opp5);
         updateList.add(opp4);        
         //update updateList;                            
       Test.stoptest();        
        
    }
}