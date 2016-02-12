public class AppointmentScheduledConfirmationEmail{

    
    public static void accountMap(Set<Id> accids, List<Contact> conList){
   
   Map<Id,Id> accIdMap = new Map<Id,Id>();
   
   Set<Id> accIdSet = new Set<Id>();
   Map<Id,Account> accountMap = new Map<Id,Account>();
   Map<Id,String> accTZMap = new Map<Id,String>();
   
   for(Account acc : [select Id, HasDaylightSavings__c, TimeZone__c from Account where Id in : accIds]) { 
       accIdSet.add(acc.Id);
       accountMap.put(acc.Id,acc);
       
     }
     
   if(!accountMap.isEmpty()){
    for(Id accId : accountmap.keyset()){
     string timeZone = '';
     timeZone = getCustomerTimeZone(accountMap.get(accId));
     
     accTZMap.put(accId,timeZone);
    }
   }  
    system.debug('-->accTZMap'+accTZMap);
    Map<Id,Id> accContactMap = new Map<Id,Id>();
    for(Contact con : conlist){
      accContactMap.put(con.Id,con.AccountId);
    }
    Map<Id,String> conTZmap = new Map<Id,String>();
    if(!accContactMap.isEmpty()){
      for(Id conId : accContactMap.keySet()){
        conTZmap.put(conId, accTZmap.get(accContactMap.get(conId)));
      }
    }
    if(!conTZmap.isEmpty()){
     for(Contact cont : conList){
       cont.Appointment_Scheduled_Time__c = cont.Appointment_Date_Time__c.format('dd MMMMMMMMMM h:mm a',conTZmap.get(cont.Id));
     system.debug('--> time'+cont.Appointment_Scheduled_Time__c);
     }
    }
  }
    public static String getCustomerTimeZone(Account acct){
        Boolean hasDaylightSavings = (acct.HasDaylightSavings__c == 'true') ? true : false;
        
        String customerTimeZone = '';
        String timezoneStr = acct.TimeZone__c;
        Map<Id,String> custTimeZoneMap = new Map<Id,String>();
        if(timezoneStr == 'PST' || timezoneStr == 'PST-2'){
            customerTimeZone = (hasDaylightSavings == true) ? 'America/Los_Angeles' : 'America/Los_Angeles';
        }else if(timezoneStr == 'EST'){
            customerTimeZone = (hasDaylightSavings == true) ? 'America/New_York' : 'America/Panama';
        }else if(timezoneStr == 'CST'){
            customerTimeZone = (hasDaylightSavings == true) ? 'America/Chicago' : 'America/El_Salvador';
        }else if(timezoneStr == 'MST'){
            customerTimeZone = (hasDaylightSavings == true) ? 'America/Denver' : 'America/Phoenix';
        }else if(timezoneStr == 'HST'){
            customerTimeZone = (hasDaylightSavings == true) ? 'America/Adak' : 'Pacific/Honolulu';
        }
        System.debug('customerTimeZone: ' + customerTimeZone);
        return customerTimeZone;
    }
    
   
}