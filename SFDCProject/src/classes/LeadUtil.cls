public class LeadUtil {

    public static List<String> getUniqueProspectNumbers(Integer size){
        List<String> generatedContactNumbers = new List<String>();
        List<Lead> leadList = new List<Lead>();    
        List<Opportunity> oppList = new List<Opportunity>();  
        do{
            generatedContactNumbers.clear();
            for(Integer counter = 0; counter < size;  counter++){
                generatedContactNumbers.add(RandomNumberGenerator.generateRandomNumber());
            }
             if(!Test.isRunningTest()){
             leadList = [Select Id from Lead where Prospect_Id__c in :generatedContactNumbers];
             oppList = [Select Id from Opportunity where Prospect_Id__c in :generatedContactNumbers];    
             system.debug('--leadlist'+leadlist);        
             system.debug('--oppList'+oppList);        
            }
            
        }while((leadList != null && leadList.size() > 0) || (oppList!=null && oppList.size()>0));
        return generatedContactNumbers; 
    }
    
    public static void UpdateContactOnConversion(map<id, Lead> convertedContactMap){
        List<Contact> ContactList = new List<Contact>();
        for(Contact contObj : [select id, name,OtherPhone,DoNotCall,HasOptedOutOfEmail,alternate_phone__c, HomePhone from Contact where id in :convertedContactMap.keyset()]){
            //contObj.HomePhone = convertedContactMap.get(contObj.id);
            contObj.OtherPhone = convertedContactMap.get(contObj.id).alternate_phone__c;
            contObj.alternate_phone__c= convertedContactMap.get(contObj.id).alternate_phone__c;
            contObj.HasOptedOutOfEmail=convertedContactMap.get(contObj.id).HasOptedOutOfEmail;
            contObj.DoNotCall=convertedContactMap.get(contObj.id).DoNotCall;
            ContactList.add(contObj);
        }
        
        if(ContactList.size() > 0){
            update ContactList;
        }
        
    }
    
    public static void UpdateAccountOnConversion(map<id, string> convertedAccountMap){
        List<Account> AccountList = new List<Account>();
        for(Account AccountObj : [select id, name from Account where id in :convertedAccountMap.keyset()]){
            AccountObj.name = convertedAccountMap.get(AccountObj.id);
            AccountList.add(AccountObj);
        }
        
        if(AccountList.size() > 0){
            update AccountList;
        }
        
    }
    
    public static void UpdateOpptyOnConversion(map<id, string> convertedOpptyMap){
        List<Opportunity> OpptyList = new List<Opportunity>();
        for(Opportunity OpptyObj : [select id, name from Opportunity where id in :convertedOpptyMap.keyset()]){
            OpptyObj.name = convertedOpptyMap.get(OpptyObj.id);
            OpptyList.add(OpptyObj);
        }
        
        if(OpptyList.size() > 0){
            update OpptyList;
        }
        
    }
    
    public static void UpdateOpptywithOffer(map<id,id> mapOffertoOppty){
        List<Opportunity> OpptyList = new List<Opportunity>();
        for(Opportunity OpptyObj : [select id, name, Offer__c from Opportunity where id in :mapOffertoOppty.keyset()]){
            system.debug('UpdateOpptywithOffer:');
            OpptyObj.Offer__c = mapOffertoOppty.get(OpptyObj.id);
            OpptyList.add(OpptyObj);
        }
        
        if(OpptyList.size() > 0){
            update OpptyList;
        }
    }

//  public static void calculateMonUsage(List <Lead> lst_lead,Map<id,Lead> oldMap,boolean isinsert,boolean isupdate){
//      Set<String> states = new Set<String>();
//      List<Lead> leadsList = new List<Lead>();
//      for(Lead leadObj: lst_lead){
            /*
            System.debug('leadObj.Jan_Usage__c: ' + leadObj.Jan_Usage__c);
            System.debug('leadObj.Feb_Usage__c: ' + leadObj.Feb_Usage__c);
            System.debug('leadObj.Mar_Usage__c: ' + leadObj.Mar_Usage__c);
            System.debug('leadObj.Apr_Usage__c: ' + leadObj.Apr_Usage__c);
            System.debug('leadObj.May_Usage__c: ' + leadObj.May_Usage__c);
            System.debug('leadObj.Jun_Usage__c: ' + leadObj.Jun_Usage__c);
            System.debug('leadObj.Jul_Usage__c: ' + leadObj.Jul_Usage__c);
            System.debug('leadObj.Aug_Usage__c: ' + leadObj.Aug_Usage__c);
            System.debug('leadObj.Sep_Usage__c: ' + leadObj.Sep_Usage__c);
            System.debug('leadObj.Oct_Usage__c: ' + leadObj.Oct_Usage__c);
            System.debug('leadObj.Nov_Usage__c: ' + leadObj.Nov_Usage__c);
            System.debug('leadObj.Dec_Usage__c: ' + leadObj.Dec_Usage__c);
            System.debug('leadObj.State__c: ' + leadObj.State__c);
            System.debug('leadObj.Average_Monthly_Electric_Bill__c: ' + leadObj.Average_Monthly_Electric_Bill__c);
            */
            /*
            if((leadObj.Jan_Usage__c == 0.0 || leadObj.Jan_Usage__c == null) && (leadObj.Feb_Usage__c == 0.0 || leadObj.Feb_Usage__c == null) && 
                (leadObj.Mar_Usage__c == 0.0 || leadObj.Mar_Usage__c == null) && (leadObj.Apr_Usage__c == 0.0 || leadObj.Apr_Usage__c == null) && 
                (leadObj.May_Usage__c == 0.0 || leadObj.May_Usage__c == null) && (leadObj.Jun_Usage__c == 0.0 || leadObj.Jun_Usage__c == null) && 
                (leadObj.Jul_Usage__c == 0.0 || leadObj.Jul_Usage__c == null) && (leadObj.Aug_Usage__c == 0.0 || leadObj.Aug_Usage__c == null) && 
                (leadObj.Sep_Usage__c == 0.0 || leadObj.Sep_Usage__c == null) && (leadObj.Oct_Usage__c == 0.0 || leadObj.Oct_Usage__c == null) && 
                (leadObj.Nov_Usage__c == 0.0 || leadObj.Nov_Usage__c == null) && (leadObj.Dec_Usage__c == 0.0 || leadObj.Dec_Usage__c == null) && 
                leadObj.State__c != null && leadObj.State__c != '' && leadObj.Average_Monthly_Electric_Bill__c != 0.0){
                leadsList.add(leadObj); 
                states.add(leadObj.State__c);           
            }*/             
//          if((isinsert&&leadObj.Average_Monthly_Electric_Bill__c!=null&&leadObj.Average_Monthly_Electric_Bill__c!=0.0&&leadObj.Calculate_Usage__c)                
//          ||(isupdate&&leadObj.Average_Monthly_Electric_Bill__c!=null&&leadObj.Average_Monthly_Electric_Bill__c!=0.0&&oldMap.get(leadObj.id).Average_Monthly_Electric_Bill__c!=leadObj.Average_Monthly_Electric_Bill__c&&leadObj.Calculate_Usage__c)
//          ||(isupdate&&leadObj.Calculate_Usage__c&&(leadObj.Jan_Usage__c!=oldMap.get(leadObj.id).Jan_Usage__c||leadObj.Feb_Usage__c!=oldMap.get(leadObj.id).Feb_Usage__c
//          ||leadObj.Mar_Usage__c!=oldMap.get(leadObj.id).Mar_Usage__c||leadObj.Apr_Usage__c!=oldMap.get(leadObj.id).Apr_Usage__c
//          ||leadObj.May_Usage__c!=oldMap.get(leadObj.id).May_Usage__c||leadObj.Jun_Usage__c!=oldMap.get(leadObj.id).Jun_Usage__c
//          ||leadObj.Jul_Usage__c!=oldMap.get(leadObj.id).Jul_Usage__c||leadObj.Aug_Usage__c!=oldMap.get(leadObj.id).Aug_Usage__c
//          ||leadObj.Sep_Usage__c!=oldMap.get(leadObj.id).Sep_Usage__c||leadObj.Oct_Usage__c!=oldMap.get(leadObj.id).Oct_Usage__c
//          ||leadObj.Nov_Usage__c!=oldMap.get(leadObj.id).Nov_Usage__c||leadObj.Dec_Usage__c!=oldMap.get(leadObj.id).Dec_Usage__c
//          ))
//          ||(isupdate&&oldMap.get(leadObj.id).Calculate_Usage__c==false&&leadObj.Calculate_Usage__c==true)            
//          ){          
//          leadsList.add(leadObj); 
//          states.add(leadObj.State__c);
//          }
//      }
//      System.debug('states: ' + states);      
//      Map<String, Average_kWh_by_State__c> averageKWHByStateMap = new Map<String, Average_kWh_by_State__c>();
//      if(!states.isEmpty()){
//          states.add('Other');
//          for(Average_kWh_by_State__c averageKWHByStateObj : [Select id,Name,kwh__c from Average_kWh_by_State__c where Name in :states]){
//              averageKWHByStateMap.put(averageKWHByStateObj.Name, averageKWHByStateObj);
//          }
//      }
//      Decimal monthlyUsage;
//      for(Lead leadObj : leadsList){
//          monthlyUsage = 0.0;
//          Average_kWh_by_State__c averageKWHByStateObj = (averageKWHByStateMap.containsKey(leadObj.state__c)) ? averageKWHByStateMap.get(leadObj.state__c) : averageKWHByStateMap.get('Other');
//          monthlyUsage = Math.round(leadObj.Average_Monthly_Electric_Bill__c/averageKWHByStateObj.kwh__c);
//          leadObj.Jan_Usage__c = monthlyUsage.intvalue();
//          leadObj.Feb_Usage__c = monthlyUsage.intvalue();
//          leadObj.Mar_Usage__c = monthlyUsage.intvalue();
//          leadObj.Apr_Usage__c = monthlyUsage.intvalue();
//          leadObj.May_Usage__c = monthlyUsage.intvalue();
//          leadObj.Jun_Usage__c = monthlyUsage.intvalue();
//          leadObj.Jul_Usage__c = monthlyUsage.intvalue();
//          leadObj.Aug_Usage__c = monthlyUsage.intvalue();
//          leadObj.Sep_Usage__c = monthlyUsage.intvalue();
//          leadObj.Oct_Usage__c = monthlyUsage.intvalue();
//          leadObj.Nov_Usage__c = monthlyUsage.intvalue();
//          leadObj.Dec_Usage__c = monthlyUsage.intvalue();
//      }
        //System.debug('leadsList: ' + leadsList);
//  }

}