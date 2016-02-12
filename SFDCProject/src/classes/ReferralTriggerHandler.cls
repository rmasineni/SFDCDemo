public class ReferralTriggerHandler
{

// public static void leadOwnerUpdate(List<Referral_Input__c> lstReferralInput) 
   public static void leadOwnerUpdate(Map<id, Referral_Input__c> map_oldReferral, List<Referral_Input__c> lst_newReferral, Boolean isInsert, Boolean isUpdate) 
    {
        //System.debug('this is lstReferralInput:'+ lstReferralInput);
        map<Id,Id> mapLeadSC = new map<Id,Id>();
        map<Id,Id> mapContactLead = new map<Id,Id>();
        map<Id,Referral_Input__c> mapLeadReferral = new map<Id,Referral_Input__c>();
    //  for(Referral_Input__c referral : lstReferralInput)
        for(Referral_Input__c referral : lst_newReferral)
        {
          // if(referral.Lead__c !=null && referral.Source_Contact_Id__c !=null && !checkRecursive.LeadOwnerUpdate.contains(referral.id) )
             if(
                 (referral.Lead__c !=null && referral.Source_Contact_Id__c !=null && isInsert)
               ||(referral.Lead__c !=null &&( (map_oldReferral==null ||  !map_oldReferral.containsKey(referral.id))|| map_oldReferral.get(referral.id).Source_Contact_Id__c!= referral.Source_Contact_Id__c) && isUpdate)
               && !checkRecursive.LeadOwnerUpdate.contains(referral.id) 
               )
            {
                mapLeadReferral.put(referral.Lead__c,referral);
                mapContactLead.put(referral.Source_Contact_Id__c,referral.Lead__c);
                checkRecursive.LeadOwnerUpdate.add(referral.id);
                System.debug('this is mapLeadReferral:'+ mapLeadReferral);
                if(referral.Service_Contract_RR__c !=null)
                {
                    mapLeadSC.put(referral.Service_Contract_RR__c,referral.Lead__c);
                    System.debug('This is mapLeadSC:'+ mapLeadSC);
                }
            }   
        }

        if(mapLeadReferral !=null && mapLeadReferral.size()>0)
        {
            map<id,Id>mapSalesPartnerSC = new map<id,Id>();
            map<Id,Lead> mapLead = new map<Id,Lead>([select Id, OwnerId,Lead_Owner_Updated__c,IsConverted,Email,Phone,LastName,City,State,PostalCode,Country from Lead where Id in:mapLeadReferral.keySet() and Lead_Owner_Updated__c!=true]);
         // map<Id,ServiceContract> mapServiceContract = new map<Id,ServiceContract>([SELECT id,ContactId,Opportunity__c,Opportunity__r.SalesRep__c,Opportunity__r.Sales_Partner__c FROM ServiceContract where Id in:mapLeadSC.keyset()]);
            map<Id,ServiceContract> mapServiceContract = new map<Id,ServiceContract>([SELECT id,ContactId,Opportunity__c,Opportunity__r.SalesRep__c,Opportunity__r.Sales_Partner__c FROM ServiceContract where ContactId in:mapContactLead.keyset()]);
            if(mapServiceContract !=null && mapServiceContract.size()>0)
            {
                for(ServiceContract sc : mapServiceContract.Values())
                 {
                    if(sc.Opportunity__c !=null && sc.Opportunity__r.Sales_Partner__c !=null)
                    {
                        mapSalesPartnerSC.put(sc.Opportunity__r.Sales_Partner__c,sc.id);
                        System.debug('This is mapSalesPartnerSC:'+ mapSalesPartnerSC);
                    }
                 }          
            }
            if(mapSalesPartnerSC !=null && mapSalesPartnerSC.size()>0)
            {
                List<Account> lstAccount = [select Id,Active__c from Account where Active__c=:true and Id in:mapSalesPartnerSC.Keyset()];
                map<Id,Id>mapSalesRepSC = new map<Id,Id>();
                if(lstAccount !=null && lstAccount.size()>0)
                {
                    for(Account objAcc : lstAccount)
                    {
                        ServiceContract SelectedSC  = mapServiceContract.get(mapSalesPartnerSC.get(objAcc.Id));
                        if(SelectedSC.Opportunity__c !=null && SelectedSC.Opportunity__r.SalesRep__c !=null)
                        {
                            mapSalesRepSC.put(SelectedSC.Opportunity__r.SalesRep__c,SelectedSC.id);
                            System.debug('This is mapSalesRepSC:'+ mapSalesRepSC);
                        }
                    }
                }
                if(mapSalesRepSC !=null && mapSalesRepSC.size()>0 && mapLead !=null && mapLead.size()>0)
                {
                    List<Lead>lstLeadToUpdated = new List<Lead>();
                    map<Id,User>mapUsers = new map<Id,User>([select Id,ManagerId,IsActive from User where Id in: mapSalesRepSC.keySet()]);
                    for(Id salesRepId : mapSalesRepSC.keySet())
                    {
                       Id LeadId = mapLeadSC.get(mapSalesRepSC.get(salesRepId));
                       Lead objLead = mapLead.get(LeadId);
                       if(objLead!=null && objLead.IsConverted==false)
                        {
                           User salesRep = mapUsers.get(salesRepId);
                           Id ownerId = (salesRep.IsActive ==true ? salesRep.Id : salesRep.ManagerId);
                           Lead objUpdateLead = new Lead(Id=LeadId);
                           objUpdateLead.ownerId = ownerId;
                           objUpdateLead.Lead_Owner_Updated__c = True; 
                           objUpdateLead.Status='Future Prospect'; 
                           
                           lstLeadToUpdated.add(objUpdateLead);
                        }
                    }
                    if(lstLeadToUpdated !=null && lstLeadToUpdated.size()>0)
                    {
                         //update lstLeadToUpdated;
                         String JSONString = JSON.serialize(lstLeadToUpdated);
                        System.debug('This is lstLeadToUpdated:'+ lstLeadToUpdated);
                        System.debug('This is JSONString:'+ JSONString);
                        ReferralTriggerHandler.updateLeadOwner(JSONString);
                    }            
                }               
            }
        }     
    }

@future
public static void updateLeadOwner(String JSONString)
{
    List<Lead> deserializedLeads =(List<Lead>)JSON.deserialize(JSONString, List<Lead>.class);
    update deserializedLeads;
}

}