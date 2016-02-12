@istest(seeAllData=true)
public with sharing class Test_trg_opptyteam_bef_ins_upd {
    static testmethod void Test_trg_opptyteam_bef_ins_upd(){
        Test.starttest();
        Recordtype r=[select id from recordtype where sobjecttype='Contact' and name='Employee' limit 1];
         Account a= [select id,name from account where office_location__c='Headquarters' and Ultimate_Parent_Account__c=null limit 1];
        Contact cont= new Contact (firstname='Test',LastName='TestCt',Accountid=a.Id,Ultimate_Parent_Account__c=a.id,recordtypeid=r.id);
        Contact cont1 = new Contact (firstname='Karthik', LastName='Prashanth',Accountid=a.id,Ultimate_Parent_Account__c=a.id,recordtypeid=r.id);
        List<Contact>contlist = new List<Contact>();
        contlist.add(cont);
        contlist.add(cont1);
          insert contlist;
         Opportunity opp = new Opportunity(Name ='Test1',StageName='Created',OM_Assigned__c=true);
         Opportunity opp1 = new Opportunity(Name ='Test2',StageName='Created',OM_Assigned__c=false);
        List<Opportunity> opptList=new List<Opportunity>();
        opptList.add(opp);
        opptList.add(opp1);
        insert opptList;    
        Opportunity_Team__c opptyteam1 = new Opportunity_Team__c(Contact__c = cont.id,Opportunity__c = opptList[0].Id, role__c = 'Order Manager');
        Opportunity_Team__c opptyteam2 = new Opportunity_Team__c(Contact__c = cont1.id,Opportunity__c = opptList[1].Id, role__c = 'Site Technician');        
        List<Opportunity_Team__c> opptyteamList=new List<Opportunity_Team__c>();
        opptyteamList.add(opptyteam1);
        opptyteamList.add(opptyteam2);
        insert opptyteamList;       
        delete opptyteamList;
        Test.StopTest();
            }
}