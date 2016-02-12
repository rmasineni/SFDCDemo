@isTest (SeeAllData=true)
public class Test_NotesMaincls {
  public static testMethod void TestNotesMaincls(){
    Test.startTest();
    Opportunity optyObj1 = TestPRMLibrary.insertOpportunity('ResidentialAccount-EDP', 'Residential',
																'ResOpty-EDP', 'Platinum');	
		List<Proposal__C> proposalList = new List<Proposal__C>();
		Proposal__C proposalObj1 = new Proposal__C();
		proposalObj1.Name = 'P87A13E7174V1BN-H';
		proposalObj1.Opportunity__c = optyObj1.Id;
		proposalObj1.Upfront_Payment__c = 1000;
		proposalObj1.Proposal_ID__c = 2441242;
		proposalObj1.System_Size_STC_DC__c = 1;
		proposalObj1.Mode_Name__c = 'Mode-1';
		proposalObj1.Date_Issued__c =  date.today();
		proposalObj1.Sales_Rep_Email__c = 'test@gmail.com';
		insert proposalObj1;

    Notes__c noteObj = new Notes__c();
    noteobj.Notes__c = 'testing';
    noteobj.Proposal__c = proposalObj1.Id;
    insert noteobj;
    
    
    ApexPages.StandardController stdcon = new ApexPages.StandardController(proposalObj1);
    NotesMaincls notesMainObj = new NotesMaincls(stdcon);
    Integer testvar1 = notesMainObj.pageNumber;
    notesMainObj.getPId();
    List<Notes__c> notelist = notesMainObj.getAllNotes();

    notesMainObj.getIsPartnerUser();
    Boolean testvar2 = notesMainObj.hasNext;
    Boolean testvar3 = notesMainObj.hasPrevious;

        notesMainObj.first();
        notesMainObj.last();
        notesMainObj.previous();
        notesMainObj.next();
        
        Test.stopTest();
  		Id userId = PartnerDetail__c.getValues('Sunrun CRM').PartnerUserId__c;
		User partnerUser = [Select id, name, email from User where Id =:userId];
	
		System.runAs(partnerUser){ 
          notesMainObj.getIsPartnerUser();
        }
  }
}