public with sharing class Web2LeadOwnerUpdate {
	@future
    public static void Web2LeadOwnerUpdate(Set<id> LdIds){ 
    	Set<String> salesrepemailset = new Set<String>();
    	List<lead> updateList=new List<Lead>();
    	List<LeadShare> leadShares = new List<LeadShare>();
     	Map<String,String> Emailaccountmap = new Map <String, String>();
     	Created_By__c devAccount =  Created_By__c.getValues('Created By Name');
     	//List<domain_names__c> domainNames=new List<domain_names__c>([select domain__c from domain_names__c]);
    	//user devAccount=[select id from user where name='Sunrun CRM' limit 1];
    	List<lead> leadList=[select id,Sales_Rep_Email__c,Channel__c,CreatedById,Lead_Organization_Location_2__c,Lead_Generated_by__c from lead where id in:LdIds];
    	for(lead l:leadList){
    		if((l.Sales_Rep_Email__c!=null || l.Sales_Rep_Email__c!='') && l.Channel__c == 'Retail'&&l.CreatedById==devAccount.User_ID__c){
            salesrepemailset.add(l.Sales_Rep_Email__c);
        	}
    	}
    	system.debug('----salesrepemailset'+salesrepemailset);
    	 for(Contact_Preferences__c cp: [Select contact__r.email,Contact__c, Lead_Organization_Location__c from Contact_Preferences__c where contact__r.email in : salesrepemailset and Lead_Organization_Location__c!=null order by Contact_Preferences__c.lastmodifieddate ]){
     		Emailaccountmap.put(cp.contact__r.email,cp.Lead_Organization_Location__c);
     	
     	}
     	 Map<string,User> emailusermap=new Map<string,user>();
     	for(user u:[select id,email from user where email in:salesrepemailset order by lastmodifieddate]){
     		emailusermap.put(u.email,u);
     	}
     	for(lead l : leadList){
     	Lead l1=new Lead();
        if(Emailaccountmap.containskey(l.Sales_Rep_Email__c)){   
        	    l1.id=l.id;    
            	l1.Lead_Organization_Location_2__c=Emailaccountmap.get(l.Sales_Rep_Email__c);
           		if(emailusermap.containskey(l.Sales_Rep_Email__c)){
           			l1.OwnerId=emailusermap.get(l.Sales_Rep_Email__c).id;
           			l1.Lead_Generated_by__c=emailusermap.get(l.Sales_Rep_Email__c).id;
           			updateList.add(l1);
           			LeadShare ls=new LeadShare(LeadId=l.id,LeadAccessLevel='Edit',UserOrGroupid=emailusermap.get(l.Sales_Rep_Email__c).id );
	    			leadShares.add(ls);
           		}
           		else{
           			l1.id=l.id;    
            		l1.Lead_Organization_Location_2__c=Emailaccountmap.get(l.Sales_Rep_Email__c);            		
           			l1.Lead_Generated_by__c=devAccount.User_ID__c ;
           			updateList.add(l1);
           			if(emailusermap.containskey(l.Sales_Rep_Email__c)){
           			LeadShare ls=new LeadShare(LeadId=l.id,LeadAccessLevel='Edit',UserOrGroupid=emailusermap.get(l.Sales_Rep_Email__c).id );
	    			leadShares.add(ls);
           			}
           		}
        	}
        	else{
        		l1.id=l.id;
        		l1.Lead_Generated_by__c=devAccount.User_ID__c;
           		updateList.add(l1);
        	}        	
     }
     if(!updateList.isempty()){     	
     	update updateList;
     }
     if(!leadShares.isEmpty()){
		   try {
		 
			Database.SaveResult[] results = Database.insert(leadShares,false);
			if (results != null){
				for (Database.SaveResult result : results) {
					if (!result.isSuccess()) {
						Database.Error[] errs = result.getErrors();
						for(Database.Error err : errs)
							System.debug(err.getStatusCode() + ' - ' + err.getMessage());
		 
					}
				}
			}
		 
			} 
		  catch (Exception e) {
			System.debug(e.getTypeName() + ' - ' + e.getCause() + ': ' + e.getMessage());
		  }	
	    }		    
    }

}