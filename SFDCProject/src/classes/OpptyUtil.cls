public class OpptyUtil {

    public static List<String> getUniqueProspectNumbers(Integer size){
        List<String> generatedContactNumbers = new List<String>();
        List<Opportunity> leadList = new List<Opportunity>();  
        List<Lead> ldList = new List<Lead>();     
        do{
            generatedContactNumbers.clear();
            for(Integer counter = 0; counter < size;  counter++){
                generatedContactNumbers.add(RandomNumberGenerator.generateRandomNumber());
            }
            if(!Test.isRunningTest()){
                leadList = [Select Id from Opportunity where Prospect_Id__c in :generatedContactNumbers];
                ldList= [Select Id from lead where Prospect_Id__c in :generatedContactNumbers];
            }
            
        }while((leadList != null && leadList.size() > 0) || (ldList!=null && ldList.size()>0));
        return generatedContactNumbers;     
    }
    
    public static Void updateOpptyName(Map<Id,String> AccIdNameMap){
        List<Opportunity> opptyList = new List<Opportunity>();
        opptyList = [select id, name, Accountid, Account.name from Opportunity where Accountid in : AccIdNameMap.keySet()];
        
        List<Opportunity> UpdateOppty = new List<Opportunity>();
        if(opptyList.size() > 0){
            for(Opportunity opptyObj : opptyList){
                opptyObj.name = AccIdNameMap.get(opptyObj.Accountid);
                UpdateOppty.add(opptyObj);
            }
            
            if(UpdateOppty.size() > 0){
                update UpdateOppty;
            }
                
        }
        
    }

}