public with sharing class OpportunitySalesRepUpdate {
    @future
    public static void OpportunitySalesRepUpdate(Set <id> OpptyIds){
        Map<id,Contact> UserContactMap=new Map<id,Contact>();
        Map<id,id> OpptySalesRepMap=new Map<id,id>();
        Set<id> salesRepIds=new Set<id>();
        List<Proposal__c> propList=new List<Proposal__c>();
        for(opportunity oppObj:[select id,salesrep__c from opportunity where id in:OpptyIds]){
            OpptySalesRepMap.put(oppObj.id,oppObj.salesrep__c);
            salesRepIds.add(oppObj.salesrep__c);
        }
        for(Contact contObj:[select id,sunrun_user__c,email,phone,firstname,lastname from contact where sunrun_user__c in:salesRepIds]){
            UserContactMap.put(contObj.sunrun_user__c,contObj);
        }
        for(User userObj:[select id,contactid,contact.email,contact.phone,contact.FirstName,contact.lastName from user where id in:salesRepIds and contactid!=null]){
            UserContactMap.put(userObj.id,new contact(id=userObj.contactid,firstname=userObj.Contact.firstname,lastname=userObj.Contact.lastname,email=userObj.Contact.email,phone=userObj.Contact.Phone));
        }
        for(proposal__c propObj:[select id,Partner_Sales_Rep__c,Opportunity__c,Sales_Rep__c,Sales_Rep_Phone__c,Sales_Rep_Email__c from proposal__c where Opportunity__c in:OpptyIds]){
            if(UserContactMap.containsKey(OpptySalesRepMap.get(propObj.Opportunity__c))){
            propObj.Partner_Sales_Rep__c=UserContactMap.get(OpptySalesRepMap.get(propObj.Opportunity__c)).id;
            propObj.Sales_Rep_Phone__c=UserContactMap.get(OpptySalesRepMap.get(propObj.Opportunity__c)).phone;
            propObj.Sales_Rep_Email__c=UserContactMap.get(OpptySalesRepMap.get(propObj.Opportunity__c)).email;
            propObj.Sales_Rep__c=UserContactMap.get(OpptySalesRepMap.get(propObj.Opportunity__c)).firstname+' '+UserContactMap.get(OpptySalesRepMap.get(propObj.Opportunity__c)).lastname;
            propList.add(propObj);
            }
        }
        if(!propList.isempty()){
            update propList;
        }
    }

}