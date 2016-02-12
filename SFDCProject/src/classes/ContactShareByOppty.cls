public with sharing class ContactShareByOppty {
	@future
	public static void doContactSharing(Set<id> contactIds,Set<id> OpptyIds){
		List<ContactShare> contactShareList=new List<ContactShare>();
		Map<id,Set<id>> OpptyUserShareMap=new Map<id,set<id>>();
		for(OpportunityShare OppShare:[select OpportunityId,UserOrGroupId from OpportunityShare where OpportunityId in:OpptyIds and rowcause='Manual']){
			        Set<id> temp=OpptyUserShareMap.get(oppShare.OpportunityId);
			        if(temp==null){
        			OpptyUserShareMap.put(oppShare.OpportunityId,new Set<id>{oppShare.UserOrGroupId});
        			}
        			else{
        			temp.add(oppShare.UserOrGroupId);
        			}
		}
		for(OpportunityContactRole ocr:[select opportunityid,contactid from OpportunityContactRole where contactid in:contactIds]){
			if(OpptyUserShareMap.containsKey(ocr.opportunityid)){
				for(Id id:OpptyUserShareMap.get(ocr.opportunityid)){
					 ContactShare contactShareObj = new ContactShare();
                     contactShareObj.ContactAccessLevel = 'Edit';
                     contactShareObj.ContactId = ocr.ContactId;
                     contactShareObj.UserOrGroupId =  Id;
                     contactShareList.add(contactShareObj); 
				}
			}
			
		}
		if(!contactShareList.isempty()){
			 Database.UpsertResult[] result =  database.upsert(contactShareList,false);
		}
	}
}