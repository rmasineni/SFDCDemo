@isTest(seeAllData=false)
public class ShowOptyTeamDetailsTest {
public static List<Opportunity_Team__c> listOpty = new List<Opportunity_Team__c>(); 
    
static testmethod void InsertanddeleteOptyTeamdata()
 {    
    	
     //Profile p = [select id from profile where Name ='System Administrator' limit 1]; 
     //User pu = new User(profileId = p.id, username ='testemail', email ='one@email.com',emailencodingkey = 'UTF-8', localesidkey = 'en_US',  languagelocalekey = 'en_US', timezonesidkey = 'America/Los_Angeles',  alias='cspu', lastname='lastname', firstname = 'firstname', title = 'developer');
     user pu=new user(id=userinfo.getUserId());
     Account a = new Account(name='Test Acct1');
     insert a;
     
     Opportunity oppty = new Opportunity();
     oppty.AccountId = a.Id;
     oppty.Name = 'NewOptyTeam Test';
     oppty.StageName = 'Qualified';
     oppty.CloseDate = Date.Today().addDays(18);
     insert oppty;
    
     Proposal__c proposal = new Proposal__c();
     proposal.Opportunity__c = oppty.Id;
     proposal.Sales_Rep_Email__c = 'Salesrep@repsfortesting.com';
     proposal.Date_Issued__c = Date.Today().addDays(18);
     proposal.Mode_Name__c = 'Mode100';
     proposal.System_Size_STC_DC__c = 1290;
     proposal.Upfront_Payment__c = 1290;
     //proposal__c proposal = UnitTest_ServiceContractUtil.createTestProposal();
     insert proposal;   
     
     ServiceContract scAssetRec = new ServiceContract();
     scAssetRec.accountId = a.Id;
     // scAssetRec.contactId = contactRec.Id;  
     scAssetRec.Proposal__c = proposal.id;
     scAssetRec.Opportunity__c = oppty.Id;
     insert scAssetRec;
     
     project__c project = new project__c ( name = 'test project', Account__c= a.Id , Opportunity__c= oppty.id, Proposal__c = proposal.id, service_contract__c = scAssetRec.id); 
     insert project;
     Phase__c phase = new Phase__c(name='testPhase', Project__c=project.Id);
     insert phase;
     Task__c tasklocal = new Task__c(name='Prepare Electrical Subk', Project_Name__c =project.id, Phase__c = phase.Id,category__c='Optional',status__c ='OPEN');
     insert tasklocal ;
     Task__c tasklocal2 = new Task__c(name='Get Electrical Subk Signed', Project_Name__c =project.id, Phase__c = phase.Id,category__c='Optional',status__c ='OPEN');
     insert tasklocal2 ;
     
     Opportunity_Team__c optyTeam = new Opportunity_Team__c();
     optyTeam.Role__c='Project Planner';
     system.debug('userid:'+userinfo.getUserId());
     optyTeam.User__c=userinfo.getUserId();
     optyTeam.Opportunity__c=oppty.id;
     Opportunity_Team__c optyTeam2 = new Opportunity_Team__c();
     optyTeam2.Role__c='Design Engineering';
     optyTeam2.User__c=userinfo.getUserId();
     optyTeam2.Opportunity__c=oppty.id;
      Opportunity_Team__c optyTeam3 = new Opportunity_Team__c();
     optyTeam3.Role__c='';
     optyTeam3.User__c=userinfo.getUserId();
     optyTeam3.Opportunity__c=oppty.id;
     Opportunity_Team__c optyTeam4 = new Opportunity_Team__c();
     optyTeam4.Role__c='Brea PC';
     optyTeam4.User__c=null;
     optyTeam4.Opportunity__c=oppty.id;
     
     listOpty.add(optyTeam);
     listOpty.add(optyTeam2);

     test.startTest();
     
     ShowOptyTeamDetails show= new ShowOptyTeamDetails();
     ApexPages.currentPage().getParameters().put('projID', project.id);
     show.projId=project.id;
     show.InitialLoad();
     show.getProjectDetails();
     show.oppId=oppty.id;
     show.populateOptyTeam();
     show.addOptyTeam();
     show.optyTeamList=listOpty;
     show.saveOptyTeam();
     show.updateOptyDetails(listOpty);
     show.deleteOptyTeam();
     show.getOptyTeamId=optyTeam.id;
     show.deleteOptyTeam();
   
    // system.assertEquals(4, listOpty.size());
    // System.assertEquals('Project Planner', listOpty[0].Role__c);
    
     listOpty.add(optyTeam3);
     listOpty.add(optyTeam4);
   
     ShowOptyTeamDetails show1= new ShowOptyTeamDetails();
     ApexPages.currentPage().getParameters().put('projID', project.id);
     show1.projId=project.id;
     show1.InitialLoad();
     show1.getProjectDetails();
     show1.oppId=oppty.id;
     show1.populateOptyTeam();
     show1.addOptyTeam();
     show1.optyTeamList=listOpty;
     show1.saveOptyTeam();
     show1.updateOptyDetails(listOpty);
     show1.deleteOptyTeam();
     show1.getOptyTeamId=optyTeam.id;
     show1.deleteOptyTeam();
     test.stopTest();
 }

}