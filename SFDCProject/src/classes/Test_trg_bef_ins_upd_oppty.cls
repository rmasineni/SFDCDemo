@isTest(SeeAllData=true)
public with sharing class Test_trg_bef_ins_upd_oppty {
    static testMethod void Test_trg_bef_ins_upd_oppty(){
    Test.StartTest();
    Profile p = [ Select id,name from Profile where Name ='Operations' LIMIT 1];
    User u = [Select id,ContactId from User where isactive=true and profileid = :p.Id limit 1];
    Account a= [select id,name from account where office_location__c='Headquarters' and Ultimate_Parent_Account__c=null limit 1];
    Contact cont= new Contact (firstname='Test',LastName='TestCt',Accountid=a.Id,Ultimate_Parent_Account__c=a.id,Email='Test_trg_bef_ins_upd_oppty.Customer1@yopmail.com');
    insert cont;  
        
    Opportunity opp = new Opportunity (Name ='Test111',StageName='Created',Sales_Representative__c=cont.id,Critter_Guard__c=true,Reroof_under_Array__c=true,Service_Panel_Upgrade__c=true,Vaulted_Ceilings__c='Yes',Main_Panel_Size_Amps__c='200',Scheduled_Construction_Start_Date__c=system.today(),
    Job_Type__c='Sales Representative',SunRun_NTP_Costco_PO_Issued__c=system.today()-2,Oracle_Revenue_Amount__c=20,Permit_Jurisdiction_municipality__c='San Jose',Layout_Approval_Start__c=system.today(),Elect_PV_Finish_Date__c=system.today(),
    Permitting_Process_Start_Date__c=system.today()-1,Permitting_Process_Finish_Date__c=system.today(),Actual_Construction_Finish__c=system.today()-4,Actual_Construction_Start__c=system.today(),Plans_Completed_Date__c=system.today(),
    Submit_Final_Interconnection__c=system.today()-2,Site_Audit_Completed__c=system.today()-3,Layout_Approval_Finish__c=system.today()-1,Oracle_Opportunity_Close_Date__c=system.today()-2,Plans_Reviewed_Date__c=system.today()-3,Project_Manager__c=u.id);
    
    Opportunity opp1 = new Opportunity (Name ='Test1',StageName='Created',On_Hold_Start_Date__c = system.today(),On_Hold_End_Date__c = system.today() + 90,Sales_Representative__c=cont.id,Critter_Guard__c=false,Reroof_under_Array__c=false,Service_Panel_Upgrade__c=false,Vaulted_Ceilings__c='No',Main_Panel_Size_Amps__c='125',Scheduled_Construction_Start_Date__c=system.today()-1,
    Job_Type__c='Sales Associate',SunRun_NTP_Costco_PO_Issued__c=system.today()-1,Oracle_Revenue_Amount__c=10,Permit_Jurisdiction_municipality__c='Sunnyvale',Layout_Approval_Start__c=system.today()-1,Elect_PV_Finish_Date__c=system.today()-3,
    Permitting_Process_Start_Date__c=system.today(),Permitting_Process_Finish_Date__c=system.today(),Actual_Construction_Finish__c=system.today(),Actual_Construction_Start__c=system.today()-2,Plans_Completed_Date__c=system.today(),
    Submit_Final_Interconnection__c=system.today(),Site_Audit_Completed__c=system.today(),Return_to_Sales_Date__c=system.today(),Layout_Approval_Finish__c=system.today(),Oracle_Opportunity_Close_Date__c=system.today()-1,Plans_Reviewed_Date__c=system.today()-1,Project_Manager__c=u.id); 
 
    List<Opportunity>opplist = new List<Opportunity>();
    opplist.add(opp);
    opplist.add(opp1);
    insert opplist;  
    
    ServiceContract sc = new ServiceContract(Name='9Test9',Opportunity__c=opp.id, contactid=cont.id);
    ServiceContract sc1 = new ServiceContract(Name='Test10',Opportunity__c=opp1.id, contactid=cont.id);
    

    List<ServiceContract> sclist = new List<ServiceContract>();
    sclist.add(sc);
    sclist.add(sc1);
    insert sclist;
    
    Service_Contract_Event__c sce = new Service_Contract_Event__c (Service_Contract__c = sc1.id,Critter_Guard__c =false,Reroof_under_Array__c=false,Service_Panel_Upgrade__c=false,Vaulted_Ceilings__c='No',Main_Panel_Size_Amps__c='125',Scheduled_Construction_Start_Date__c=system.today()-1,
    Oracle_Revenue_Amount__c=10,Permit_Jurisdiction_municipality__c='Sunnyvale',Layout_Approval_Start__c=system.today()-1,Final_Inspection_Signoff__c=system.today()-3,
    Permit_Submitted_Date__c=system.today(),Permit_Approval_Date__c=system.today(),Completion_of_Construction__c=system.today(),Commencement_of_Construction__c=system.today()-2,Plans_Completed_Date__c=system.today(),
    Submit_Final_Interconnection__c=system.today(),Site_Audit_Complete__c=system.today(),Oracle_Opportunity_Close_Date__c=system.today()-2,CAP_date_approved__c=system.today(),Layout_Rcvd__c=system.today()-1,SunRun_NTP_Costco_PO_Issued__c = system.today()-2,Return_to_Sales_Date__c=system.today()+1);
    
        insert sce;
        
        System.runAs(u){
            try{
                opp1.On_Hold_Start_Date__c = system.today() +1;
                opp1.On_Hold_End_Date__c = system.today() + 89;
                opp1.Oracle_Opportunity_Close_Date__c =system.today() +10;
                opp1.SunRun_NTP_Costco_PO_Issued__c =system.today();
                opp1.Oracle_Revenue_Amount__c =1200;
                opp1.Permit_Jurisdiction_municipality__c ='Dublin';
                opp1.Return_to_Sales_Date__c = system.today()-1;
                opp1.Plans_Reviewed_Date__c = system.today();
                opp1.Plans_Completed_Date__c =system.today() +10;
                opp1.Layout_Approval_Start__c =system.today() -10;
                opp1.Layout_Approval_Finish__c =system.today()+1;
                opp1.Project_Creation_Date__c =system.today();
                opp1.Submit_Final_Interconnection__c = system.today()-1;
                opp1.Actual_Construction_Start__c= system.today()-1;
                opp1.Actual_Construction_Finish__c = system.today()+2;
                opp1.Permitting_Process_Start_Date__c = system.today()-1;
                opp1.Permitting_Process_Finish_Date__c =system.today()+20;
                opp1.Elect_PV_Finish_Date__c = system.today()+30;
                opp1.Job_Type__c = 'Sales Representative';
                opp1.Site_Audit_Completed__c = system.today()+5;
                opp1.Site_Audit_Scheduled__c= system.now()+30;
                opp1.Site_Audit_Results_Rcvd__c =system.today()+3;
                opp1.Date_when_Site_Audit_was_Scheduled__c = system.today() -10;
                opp1.First_Call_Completed_Date__c = system.today()+3;
                opp1.Scheduled_Construction_Start_Date__c = system.today()+8;
                opp1.Critter_Guard__c = true;
                opp1.Reroof_under_Array__c = true;
                opp1.Service_Panel_Upgrade__c = true;
                opp1.Vaulted_Ceilings__c = 'yes';
                opp1.Main_Panel_Size_Amps__c = '200';
                update opp1;
                }
            catch(Exception e){
                Boolean expectedExceptionThrown = e.getMessage().contains('Field can not be edited as Service Contract Event has been created')? true :false;
                //System.AssertEquals(expectedExceptionThrown, true);
            } 
      }
    
       Test.StopTest(); 
    } 
 
    
}