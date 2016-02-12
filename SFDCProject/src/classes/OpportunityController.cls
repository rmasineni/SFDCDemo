public class OpportunityController{

    public String selectedRecTypeId {get; set;}
    public Map<Id, String> oppRecTypeMap;
    User loggedInUser;
    public boolean isAccessibleUser {get; set;}
    
    public OpportunityController(Apexpages.standardController controller){
        
    }
    
    public pagereference selectedRecordType() {
        isAccessibleUser = false;
        
        if(Opty_Custom_Setting__c.getInstance() != null){
            String profileNames = Opty_Custom_Setting__c.getInstance().ProfileNames__c;
            
            Schema.Describesobjectresult result = Schema.Sobjecttype.Opportunity;
            oppRecTypeMap = new Map<Id, String>();
            for(Schema.RecordTypeInfo s : result.getRecordTypeInfos()) {
                if(s.getName()!='master' && s.isAvailable()) {
                    oppRecTypeMap.put(s.getRecordTypeId(),s.getName());
                }
            }
            loggedInUser = [select Id, Name, ProfileId, Profile.Name from User where Id = :UserInfo.getUserId()];
            
            if(profileNames != null && profileNames.containsIgnoreCase(loggedInUser.Profile.Name)){
                isAccessibleUser = true;
                if(oppRecTypeMap.size() == 1){
                    selectedRecTypeId = new List<Id>(oppRecTypeMap.keySet())[0];
                    //countinueButtonClick();
                    PageReference oppEditPage = new PageReference('/006/e?retURL=006%2Fo&RecordType='+selectedRecTypeId+'&nooverride=1');
                    oppEditPage.setRedirect(true);
                    system.debug('oppEditPage ==: ' + oppEditPage);
                    return oppEditPage;
                }
            }
        } 
        return null;
    }
    
    public List<SelectOption> getRecordTypes(){
        List<SelectOption> options = new List<SelectOption>();
        if(oppRecTypeMap != null && oppRecTypeMap.size() > 0){
            for(Id recordTypeId : oppRecTypeMap.keySet()){
                options.add(new SelectOption(recordTypeId,oppRecTypeMap.get(recordTypeId)));
            }
        }
        System.debug(LoggingLevel.INFO, 'Opportunity record type selection : ' + options);
        return options;
    }
    
    public pagereference countinueButtonClick(){
        
        PageReference oppEditPage = new PageReference('/006/e?retURL=006%2Fo&RecordType='+selectedRecTypeId+'&nooverride=1');
        oppEditPage.setRedirect(true);
        system.debug('oppEditPage ==: ' + oppEditPage);
        return oppEditPage;
    }
    
    public pagereference cancel(){
        PageReference oppListPage = new Pagereference('/006/o');
        oppListPage.setRedirect(true);
        return oppListPage;
    }
}