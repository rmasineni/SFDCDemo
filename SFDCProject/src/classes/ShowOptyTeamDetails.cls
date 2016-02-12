public class ShowOptyTeamDetails {
    //declaration  
    Public List<Opportunity_Team__c> optyTeamList {get;set;}
    Public List<Opportunity_Team__c> optyTeamDeleteList =new List<Opportunity_Team__c>();
    Public String projId {get;set;}
    Public String oppId {get;set;}
    Public String getOptyTeamId {get;set;} 
    public Project__c projDetails{get;set;}
    public List<Opportunity> oppList = new List<Opportunity>();
    public Static String PROJECTPLANNER= 'Project Planner';
    public Static String DESIGNENGINEERING= 'Design Engineering';
   
    
    //constructor 
    public ShowOptyTeamDetails(){
       projId= ApexPages.currentPage().getParameters().get('projID');
       InitialLoad();
    }
    
    public void InitialLoad(){
         If (ProjId!=''&&ProjId!=null){
            oppId=[SELECT Opportunity__r.Id FROM Project__c where Id=:projId].Opportunity__r.id; 
            populateOptyTeam();
            getProjectDetails();
            getOptDetails();
        }
        
    }
    
    public void getOptDetails() {
        oppList = [SELECT Id FROM Opportunity where Id=:oppId];
      }
        
    //get project details
    public void getProjectDetails(){
        projDetails  = new Project__c();
        projDetails = [SELECT Name, Opportunity_Name__c, Service_Contract__c, Status__c, Service_Contract_Name__c,
                       Opportunity__r.Install_Branch__c,Opportunity__r.Sales_Branch__c  FROM Project__c where Id=:projId ]; 
    }
    //get opty team details
    public void populateOptyTeam(){
       // optyTeamList =  new List<Opportunity_Team__c>();
        optyTeamList =[SELECT Id, LastModifiedById, LastModifiedDate, CreatedDate, CreatedById, Role__c, User__c,User__r.Name, Opportunity__c,OwnerId  
                        FROM Opportunity_Team__c where Opportunity__c=:oppId];
    }
    // add new opty team
    public void addOptyTeam() {
        Opportunity_Team__c Opty= new Opportunity_Team__c();
        opty.Opportunity__c=oppId;
        optyTeamList.add(Opty);
    }
    //save the opty team details
    public pageReference saveOptyTeam(){
       for(Opportunity_Team__c optyTeam: optyTeamList){
            If (optyTeam.Role__c==null|| optyTeam.Role__c==''){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Please select Project Role.'));
                return null;
            }
            else if(optyTeam.User__c==null){
                 ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Please select user.'));
                 return null;
            }
           
        }
        If(!optyTeamList.isEmpty()){
            try{ 
                 upsert optyTeamList;
                 ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.CONFIRM, 'Project Role saved successfully.'));
                 populateOptyTeam();
                 updateOptyDetails(optyTeamList);
            }
            catch(DMLException ex){
                apexpages.addMessages(ex);
           
            }
            
        }
        return null;       
    }
    
    public void updateOptyDetails(List<Opportunity_Team__c> optyTeamList){
        
        for(Opportunity_Team__c optyTeam : optyTeamList){
            If(optyTeam.Role__c==PROJECTPLANNER){
                oppList[0].Project_Manager__c=optyTeam.User__c;
            }
            If(optyTeam.Role__c==DESIGNENGINEERING){
                oppList[0].PV_Designer__c=optyTeam.User__c;
            }
        }
        if(!oppList.isEmpty())
        update oppList[0];
           
    }
    
    public void deleteOptyTeam(){
    	
        try{   
            If(getOptyTeamId!=null && getOptyTeamId!='' ){
                 optyTeamDeleteList = [SELECT Id FROM Opportunity_Team__c where Id=:getOptyTeamId ];
                 delete optyTeamDeleteList;
                 ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.CONFIRM, 'Project Role deleted successfully.'));
                  
            }else{
                   ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Please select record to delete.'));
              }
            populateOptyTeam();
        }
        catch(DMLException ex){
            ApexPages.addMessages(ex);
            
        }
        
    }
     
}