public class OpportunityContactRoleInlineVF{

 public Opportunity opp;
 public Id opptyId;
 public contact con;
 public Opportunity updOppty;
 public List<appointment__c> apptList;
 public List<appointment__c> updateAptList;

 public OpportunityContactRoleInlineVF(ApexPages.StandardController controller){
 
  opp = (Opportunity) controller.getRecord();
  opptyId = opp.Id;
  apptList = new List<appointment__c>();
  updateAptList = new List<appointment__c>();
  //updateOpportunityHomeOwner(opptyId);
  
 }
 
 public void updateOpportunityHomeOwner(){
 
 con = [select Id, FirstName, LastName, Phone,Text_Opt_Out__c from Contact where Id in (select ContactId from OpportunityContactRole where OpportunityId = :opptyId and IsPrimary = true )];
  
  updOppty = [select Id, Homeowner_First_Name__c, Homeowner_Last_Name__c, Homeowner_Full_Name__c from opportunity where Id = : opptyId];
  
  updOppty.Homeowner_First_Name__c = con.FirstName;
  updOppty.Homeowner_Last_Name__c = con.LastName;
  updOppty.Homeowner_Full_Name__c = con.FirstName + ' ' + con.LastName;
  
  update updOppty;
 
  apptList = ([select id, Text_Opt_Out__c, Mobile_for_SMS__c from appointment__c where opportunity__c =: updOppty.Id]);
  if(!apptList.isEmpty()){ 
   for(appointment__c apt : apptList){
    apt.Text_Opt_Out__c = con.Text_Opt_Out__c;
    apt.Mobile_for_SMS__c = con.Phone;
    updateAptList.add(apt);
   }
  }
  if(!updateAptList.isEmpty()){ 
   update updateAptList;
  }
 }


}