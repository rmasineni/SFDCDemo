public class ContactUtil {
    
    public static string RESIDENTIAL = 'Residential';
    public static Set<Id> eligibleForVoid = new Set<Id>();
    public static Set<Id> voidedContactIds = new Set<Id>();
    public static Boolean isContactInfoChanged(Contact newContactObj, Contact oldContactObj){
        boolean result = false;
        if(newContactObj != null && oldContactObj != null){
            System.debug('oldContactObj.firstname: ' + oldContactObj.firstname);
            System.debug('newContactObj.firstname: ' + newContactObj.firstname);
            System.debug('oldContactObj.lastname: ' + oldContactObj.lastname);
            System.debug('newContactObj.lastname: ' + newContactObj.lastname);
            
            if((newContactObj.firstname != oldContactObj.firstname) || (newContactObj.lastname != oldContactObj.lastname)){
                result = true;
            }
        }
        return result;
    }
    
    public static void copyContactNameInformation(Contact targetCont, Contact sourceCont){
        targetCont.firstname = sourceCont.firstname ;
        targetCont.lastname = sourceCont.lastname ;
    }

    public static Boolean isMemberIdWipedOut(Contact newContactObj, Contact oldContactObj){
        boolean result = false;
        if(newContactObj != null && oldContactObj != null){
            System.debug('oldContactObj.MemberId: ' + oldContactObj.Member_ID__c);
            System.debug('newContactObj.MemberId: ' + newContactObj.Member_ID__c);
            
            if(newContactObj.Member_ID__c == null && oldContactObj.Member_ID__c != null){
                result = true;
            }
        }
        return result;
    }    

    public static Map<Id, Contact> getContactRec(Set<Id> conIds){
        Map<Id, Contact> conIdConRecMap = new Map<Id, Contact>();
        if(!conIds.isEmpty()){
            for(Contact con: [select Id, Member_ID__c from Contact where id in :conIds]){
                conIdConRecMap.put(con.id, con);
            } 
        }

        return conIdConRecMap;
    }    
}