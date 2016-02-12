public with sharing class CopyNoteFromLeadConvertion {
 @future
 public static void CopyNoteFromLeadConvertion(Set<id> opptyIds){
 		Map<id,id> leadOpptymap=new Map<id,id>();
 		List<notes__c> noteList=new List<notes__c>();
 		for(opportunity opp:[select id,lead_id__c from opportunity where id in:opptyIds]){
 			if(opp.lead_id__c!=null)
 			leadOpptymap.put(opp.lead_id__c,opp.id);
 		}
 		if(!leadOpptymap.isempty()){
 			for(notes__c note:[select id,lead__c,opportunity__c from notes__c where lead__c in:leadOpptymap.keyset()]){
 				note.opportunity__c=leadOpptymap.get(note.lead__c);
 				noteList.add(note);
 			}
 		}
 		if(!noteList.isempty()){
 			update noteList;
 		}
 			
 }	
}