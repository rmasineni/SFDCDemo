/****************************************************************************
Author  : Peter Alexander Mandy (pmandy@sunrunhome.com)
Date    : June 05, 2012
Description: This trigger creates a referral input based on the Lead data, 
             provided it is not a duplicate entry and the lead is from a referral.
             June052012: Decision was made to go lead=>referral vs. referral=>lead
*****************************************************************************/
trigger trg_lead_after_insert on Lead (after insert, after update) {
 /*  
      Map<Id, Set<String>> mapReferralIdToStatus = new Map<Id, Set<String>>();    
      ReferralService refSvc = new ReferralService();         
      List<Referral_Input__c> listNewReferrals = new List<Referral_Input__c>();  
      List<Referral_Input__c> listUpdateReferralsDupe = new List<Referral_Input__c>();
      List<Referral_Input__c> listUpdateReferralsNew = new List<Referral_Input__c>();
      Set<Id> setUpdateReferralToDupe = new Set<Id>();
      Set<Id> setUpdateReferralToNew = new Set<Id>();
      Map<Id, Id> mapReferralToNewSource = new Map<Id, Id>();
      Set<Id> setDeleteReferrals = new Set<Id>();
      Map<Id, Id> mapSourcePromo = refSvc.getMapSourceToPromo(Trigger.new);       
      for(Lead newLead: Trigger.New)
      {
          if(//setReferralLeadSource.Contains(newLead.LeadSource)
             // As of 06192012, we want to go ahead and create the duplicate referrals too, for reporting sake.
             //&& newLead.Status != 'Unqualified' -- technically we should NOT be able to set Why_Unqualified__c unless Status is "Unqualified", but we can, so just check Why_Unqualified__c
             //&& newLead.Why_Unqualified__c != 'Duplicate lead'
                (newLead.Referred_By_Contact__c != null && Trigger.isInsert)
             || (Trigger.isUpdate && Trigger.oldMap.get(newLead.Id).Referred_By_Contact__c == null && newLead.Referred_By_Contact__c !=  null)
            )     
         {
            Referral_Input__c newReferral = refSvc.createReferral(newLead, Trigger.New, mapSourcePromo);
            listNewReferrals.add(newReferral);           
         }
         // Delete referral
         if(Trigger.isUpdate && Trigger.oldMap.get(newLead.Id).Referred_By_Contact__c != null && newLead.Referred_By_Contact__c ==  null)
         {
            setDeleteReferrals.add(newLead.Referral_Input__c);
         }
         //Update Referred By Contact   
         if(Trigger.isUpdate && newLead.Referred_By_Contact__c != Trigger.oldMap.get(newLead.Id).Referred_By_Contact__c && Trigger.oldMap.get(newLead.Id).Referred_By_Contact__c != null && newLead.Referred_By_Contact__c !=  null)
         {
            mapReferralToNewSource.put(newLead.Referral_Input__c, newLead.Referred_By_Contact__c);
         }       
         // Update Status 
         if(Trigger.isUpdate && newlead.Lead_Status__c == Label.Lead_Status_Duplicate && (newlead.Why_Unqualified__c == Label.Lead_Why_Unqualified_DuplicateLeadFound || newlead.Why_Unqualified__c == Label.Lead_Why_Unqualified_DuplicateOpptyFound))
         {
            setUpdateReferralToDupe.add(newLead.Referral_Input__c);
         }
         if(Trigger.isUpdate && newlead.Why_Unqualified__c != Label.Lead_Why_Unqualified_DuplicateLeadFound && newlead.Why_Unqualified__c != Label.Lead_Why_Unqualified_DuplicateOpptyFound && Trigger.oldMap.get(newLead.Id).Lead_Status__c == Label.Lead_Status_Duplicate)
         {
            setUpdateReferralToNew.add(newLead.Referral_Input__c);
         }           
         if(Trigger.isUpdate && newLead.Lead_Status__c != Trigger.oldMap.get(newLead.Id).Lead_Status__c && newLead.Referral_Input__c != null)
         {              
             if(mapReferralIdToStatus.get(newLead.Referral_Input__c) != null)
             {
                mapReferralIdToStatus.get(newLead.Referral_Input__c).add(newLead.Lead_Status__c);
             }
             else
             {
                mapReferralIdToStatus.put(newLead.Referral_Input__c, new Set<String>{newLead.Lead_Status__c});  
             }                                                                      
         }
         Notes__c noteobj = new Notes__c();
         if(Trigger.isInsert){

                if(newLead.Notes__c != null && newLead.Notes__c != ''){
                    noteobj.Notes__c = newLead.Notes__c;
                    noteobj.Lead__c = newLead.Id;
                    noteobj.Notes_Added_By__c = getwhichOrg();
                    insert noteobj;
                }
                if(newLead.Partner_Notes__c != null && newLead.Partner_Notes__c != ''){

                    system.debug('LeadId' + newLead.Id);
                    noteobj.Notes__c = newLead.Partner_Notes__c;
                    noteobj.Lead__c = newLead.Id;
                    noteobj.Notes_Added_By__c = getwhichOrg();
                    insert noteobj;
                }

            }
            if(Trigger.isUpdate && newlead.Notes__c != Trigger.oldMap.get(newlead.id).Notes__c){
                noteobj.Notes__c = newLead.Notes__c;
                noteobj.Lead__c = newLead.Id;
                noteobj.Notes_Added_By__c = getwhichOrg();
                insert noteobj;
            }
            if(Trigger.isUpdate && newlead.Partner_Notes__c != Trigger.oldMap.get(newlead.id).Partner_Notes__c){
                noteobj.Notes__c = newLead.Partner_Notes__c;
                noteobj.Lead__c = newLead.Id;
                noteobj.Notes_Added_By__c = getwhichOrg();
                insert noteobj;
            }
      }
      //
      if(!setUpdateReferralToDupe.isEmpty())
      {
        for(Referral_Input__c r:[select id, Milestone_1_Status__c, Milestone_2_Status__c, Milestone_3_Status__c from Referral_Input__c where id in :setUpdateReferralToDupe])
        {
            listUpdateReferralsDupe.add(r);
        }
      }
      if(!setUpdateReferralToNew.isEmpty())
      {
         for(Referral_Input__c r:[select id, Milestone_1_Status__c, Milestone_2_Status__c, Milestone_3_Status__c from Referral_Input__c where id in :setUpdateReferralToNew])
         {
            listUpdateReferralsNew.add(r);
         }
      }      
      //
      if(!mapReferralToNewSource.isEmpty())
      {
        refSvc.updateReferralSource(mapReferralToNewSource);
      }
      //
      if(!setDeleteReferrals.isEmpty())
      {
         refSvc.deleteReferral(setDeleteReferrals);
      }
      //
      if(listNewReferrals.size() > 0)
      {
         insert listNewReferrals;
      }
      if(listUpdateReferralsDupe.size() > 0)
      {
         update listUpdateReferralsDupe;
      }
      if(listUpdateReferralsNew.size() > 0)
      {
         update listUpdateReferralsNew;
      }      
      //check for stage change to see if qualifies for referral payment
      if(!mapReferralIdToStatus.isEmpty())
      {
         System.Debug('Calling Referral Service to set the status to ' + Label.ReferralReadyForPayment);
         refSvc.setReferralStatus(mapReferralIdToStatus, 'Lead');
      } 
      
     private string getwhichOrg(){
        
        Boolean ispartnerUser;
        String whichOrgValue;
        String userType = UserInfo.getUserType();
        if(userType != null && userType != ''){
            if(userType.contains('Partner')){
                ispartnerUser = true;
            }
        }
        
        if(ispartnerUser == true){
            User userRec = [Select ContactId From User WHERE Id = :Userinfo.getUserid()];
            Contact conRec = [Select Id, Account.Name From Contact Where Id = :userRec.ContactId];
            
            system.debug('Organization Name' + conRec.Account.Name);
            whichOrgValue = conRec.Account.Name;
            return whichOrgValue;
        }
        
        whichOrgValue = 'SunRun';
        return whichOrgValue;
        
    }
    
    List<Offer__c> offerObjList = new List<Offer__c>();
    List<Partner_Role__c> partnerRoleList = new List<Partner_Role__c>();
    Partner_Role__c partnerRoleLead = new Partner_Role__c();
    Partner_Role__c partnerRoleInstall= new Partner_Role__c();
    Partner_Role__c partnerRoleSales= new Partner_Role__c();
    Set<Id> convertedOpportunity = new Set<Id>();
    map<Id, string> convertedContactMap = new map<Id, string>();
    map<Id, string> convertedAccountMap = new map<Id, string>();
    map<Id, string> convertedOpptyMap = new map<Id, string>();
    map<Id, Id> convertedLeadIds = new map<Id, Id>();
    
    for(Lead newLead: Trigger.New)
    {
        if(newlead.IsConverted == true && newLead.convertedOpportunityId != null){
            convertedLeadIds.put(newlead.id,newLead.convertedOpportunityId);
            if(newlead.Street != null || newlead.Street != ''){
                String OpptyName = newlead.Street + '-' + newlead.PostalCode;
                convertedOpptyMap.put(newlead.convertedOpportunityId, OpptyName);
            }
            system.debug('convertedLeadIds : ' + convertedLeadIds);
        }
        if(newlead.Isconverted == true && newlead.ConvertedContactId != null){
            convertedContactMap.put(newlead.ConvertedContactId, newlead.Alternate_Phone__c);
        }
        
        if(newlead.Isconverted == true && newlead.ConvertedAccountId != null){
            if(newlead.Street != null || newlead.Street != ''){
                String AccountName = newlead.Street + '-' + newlead.PostalCode;
                convertedAccountMap.put(newlead.ConvertedAccountId, AccountName);
            }
        }
        
        if(newLead.IsConverted == true && newLead.convertedOpportunityId != null){
            convertedOpportunity.add(newLead.convertedOpportunityId);
            if(newLead.Offer_Promo_Code__c != null || newLead.Offer_Promo_Code__c != ''){
                Offer__c offerObj = new Offer__c();
                offerObj.Opportunity__c = newLead.convertedOpportunityId;
                offerObj.Promotion__c = newLead.Offer_Promo_Name__c;
                offerObj.Customer_Salutation__c = newLead.LC_Salutation__c;
                offerObj.Customer_Contact__c = newLead.ConvertedContactId;
                 offerObj.Customer_Address_City__c =  newLead.LC_City__c;
                 offerObj.Customer_Address_Country__c =  newLead.LC_Country__c;
                 offerObj.Customer_Email__c =  newLead.LC_Email__c;
                 offerObj.Customer_First_Name__c =  newLead.LC_FirstName__c;
                 offerObj.Customer_Last_Name__c =  newLead.LC_LastName__c;
                 offerObj.Customer_Phone_Number__c =  newLead.LC_PhoneNumber__c;
                 offerObj.Customer_Address_State__c =  newLead.LC_State__c;
                 offerObj.Customer_Address_Street__c =  newLead.LC_Street__c;
                 offerObj.Customer_Address_ZipCode__c =  newLead.LC_ZipCode__c;
             
             offerObjList.add(offerObj);
                
            }
            //Contact contobj = PRMContactUtil.getLoginUserContact();
            //if(contObj != null){
                
                partnerRoleLead.Opportunity__c = newLead.convertedOpportunityId;
                partnerRoleLead.Partner_Name__c = newLead.Lead_Gen_Partner__c;
                partnerRoleLead.Role__c = 'Lead Gen';
                //partnerRoleLead.LeadOrganizationName__c = newlead.LeadOrganizationName__c;
                //partnerRoleLead.LeadOrganizationOffice__c = newlead.LeadOrganizationOffice__c;
                partnerRoleLead.CorporatePartner__c = newlead.CorporatePartner__c;
                
                partnerRoleList.add(partnerRoleLead);
                
                partnerRoleInstall.Opportunity__c = newLead.convertedOpportunityId;
                partnerRoleInstall.Partner_Name__c = newLead.Install_Partner__c;
                partnerRoleInstall.Role__c = 'Install';
                partnerRoleInstall.Contract_Execution_Date__c = newlead.EPCExecutionDate__c;
                //partnerRoleInstall.EPCPartnerName__c = newlead.EPCPartnerName__c;
                //partnerRoleInstall.InstallationOffice__c = newlead.InstallationOffice__c;
                partnerRoleInstall.CorporatePartner__c = newlead.CorporatePartner__c;
                
                partnerRoleList.add(partnerRoleInstall);
                
                partnerRoleSales.Opportunity__c = newLead.convertedOpportunityId;
                partnerRoleSales.Partner_Name__c = newLead.Sales_Partner__c;
                partnerRoleSales.Role__c = 'Sales';
                partnerRoleSales.Sales_Rep_Phone__c = newlead.SalesCellPhone__c;
                partnerRoleSales.Sales_Rep_Email__c = newlead.SalesEmail__c;
                //partnerRoleSales.SalesOrganizationName__c = newlead.SalesOrganizationName__c;
                partnerRoleSales.Contract_Execution_Date__c = newlead.SalesOrgContractExecutionDate__c;
                partnerRoleSales.SalesRep__c = newlead.SalesRep__c;
                partnerRoleSales.CorporatePartner__c = newlead.CorporatePartner__c;
                
                partnerRoleList.add(partnerRoleSales);
                
            //}
            
        }
    }
    
    List<Design_Option__c> designOptionList = [select costPerYearkWh__c,KWH_KWP__c,KWH__c,KWP__c,Lead__c,Module__c,Name,
                                                Opportunity__c,Serial_Number__c,Usage__c FROM Design_Option__c 
                                                where Lead__c in :convertedLeadIds.keyset()];
    system.debug('designOptionList : ' + designOptionList) ;
    List<Design_Option__c>  OpptyDesignOption = new List<Design_Option__c>();                       
    if(designOptionList.size() > 0){
        Design_Option__c newDesign = new Design_Option__c();
        for(Design_Option__c Design : designOptionList){
            newDesign.name = Design.Name;
            newDesign.costPerYearkWh__c = Design.costPerYearkWh__c;
            newDesign.KWH__c = Design.KWH__c;
            newDesign.KWH_KWP__c = Design.KWH_KWP__c;
            newDesign.KWP__c = Design.KWP__c;
            newDesign.Module__c = Design.Module__c;
            newDesign.Serial_Number__c = Design.Serial_Number__c;
            newDesign.Usage__c = Design.Usage__c;
            system.debug(' Oppty Id :' + convertedLeadIds.get(Design.lead__c));
            newDesign.Opportunity__c = convertedLeadIds.get(Design.lead__c);
            
            OpptyDesignOption.add(newDesign);
        }
        
        List<Design_Option__c> insertDOList = new List<Design_Option__c>();
        Set<Design_Option__c> insertDOset = new Set<Design_Option__c>();
        if(OpptyDesignOption.size() > 0){
            for(Design_Option__c designObj : OpptyDesignOption){
                if(insertDOset.add(designObj)){
                    insertDOList.add(designObj);
                }
            }
            if(insertDOList.size() > 0){
                insert insertDOList;
            }
        }
            
    }                           
    
    
    if(!convertedContactMap.isEmpty()){
        LeadUtil.UpdateContactOnConversion(convertedContactMap);
    }
    
    if(!convertedAccountMap.isEmpty()){
        LeadUtil.UpdateAccountOnConversion(convertedAccountMap);
    }
    List<OpportunityContactRole> contactRoleList = new List<OpportunityContactRole>();
    for(OpportunityContactRole ContactRole :[Select Id, role, isPrimary, ContactId, OpportunityId from OpportunityContactRole where OpportunityId =:convertedOpportunity] ){
        ContactRole.role = 'Homeowner';
          ContactRole.isPrimary = true;
          contactRoleList.add(ContactRole);
    }
    
   if(contactRoleList.size() > 0){
    update contactRoleList;
   }
   
   if(offerObjList.size() > 0 && offerObjList != null){
        insert offerObjList;
     }
  if(partnerRoleList != null && partnerRoleList.size() > 0){
        insert partnerRoleList;
    }
   */ 
}