public with sharing class ContactSharing {
	@future
	public static void ContactSharing(Set<id> ContactIds){
		Map<id,Opportunity> ContactOpptyMap=new Map<id,Opportunity>();
		Set<id> accountIds=new Set<id>();
		List<ContactShare> CSShareList=new List<ContactShare>();
		Map<id,List<User>> UserAccMap=new Map<id,List<User>>();
		for(OpportunityContactRole Opptyrole:[select ContactId,OpportunityId,Opportunity.Sales_Partner__c,Opportunity.Install_Partner__c,Opportunity.Channel_2__c,Opportunity.Lead_Source_2__c FROM OpportunityContactRole where ContactId in:ContactIds and Opportunity.Channel_2__c='Partner' and Opportunity.Lead_Source_2__c='Partner: Legacy']){
			ContactOpptyMap.put(Opptyrole.contactId,Opptyrole.Opportunity);			
			if(Opptyrole.Opportunity.Sales_Partner__c!=null){
				accountIds.add(Opptyrole.Opportunity.Sales_Partner__c);
			}
			if(Opptyrole.Opportunity.Install_Partner__c!=null){
				accountIds.add(Opptyrole.Opportunity.Install_Partner__c);
			}
		}
		if(!accountIds.isempty()){
			for(User userObj:[select id,Contact.AccountId from user where Contact.AccountId=:accountIds and ProfileId=:System.label.Partner_Ops_Profile_Id]){
				 List<User> userLst=UserAccMap.get(userObj.Contact.AccountId);
       				if(userLst==null){
        			UserAccMap.put(userObj.Contact.AccountId,new List<User>{userObj});
        			}
        			else{
        			userLst.add(userObj);
        			}
			}
		if(!ContactOpptyMap.isEmpty()){
			for(Contact contObj:[select id from contact where id in:ContactOpptyMap.keyset()]){
				if(ContactOpptyMap.get(contObj.id).sales_partner__c==ContactOpptyMap.get(contObj.id).Install_partner__c&&UserAccMap.containsKey(ContactOpptyMap.get(contObj.id).sales_partner__c)){
					for(User userObj:UserAccMap.get(ContactOpptyMap.get(contObj.id).Sales_Partner__c)){
                  	ContactShare CS=new ContactShare();
                  	CS.ContactAccessLevel='Edit';
                  	CS.ContactId=contObj.id;
                  	CS.UserOrGroupId=userObj.Id;
                  	CSShareList.add(CS);
              		}
				}
				else {
		        if(ContactOpptyMap.get(contObj.id).sales_partner__c!=null&&UserAccMap.containsKey(ContactOpptyMap.get(contObj.id).sales_partner__c)){
		          for(User userObj:UserAccMap.get(ContactOpptyMap.get(contObj.id).sales_partner__c)){
		                  ContactShare CS=new ContactShare();
                  		  CS.ContactAccessLevel='Edit';
                  		  CS.ContactId=contObj.id;
                  		  CS.UserOrGroupId=userObj.Id;
                  		  CSShareList.add(CS);		              }
		              }
		              if(ContactOpptyMap.get(contObj.id).Install_partner__c!=null&&UserAccMap.containsKey(ContactOpptyMap.get(contObj.id).Install_partner__c)){
		                for(User userObj:UserAccMap.get(ContactOpptyMap.get(contObj.id).Install_partner__c)){
		                  ContactShare CS=new ContactShare();
                  		  CS.ContactAccessLevel='Edit';
                  		  CS.ContactId=contObj.id;
                  		  CS.UserOrGroupId=userObj.Id;
                  		  CSShareList.add(CS);	
		              }
		              }
		        }
			}
		}
	}
	if(!CSShareList.isempty()){
		System.debug('Print CSShare'+CSShareList);
		Database.SaveResult[] result = database.insert(CSShareList,false);
	}

}
}