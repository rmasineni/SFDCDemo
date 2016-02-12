public class InstallAuditService
{

    public void InstallAuditService(){}

    public string SaveAuditFeedback(List<Audit_Feedback__c> auditFeedback)
    {
        try{
            upsert auditFeedback;
        }
        catch(DmlException ex){
            ApexPages.addMessages(ex);
        }

        return null;
    }
    
    public String getAccountNameFromUser()
    {
        String userId = UserInfo.getUserId();
        User user = [select Id, Name, Contact.Name, Contact.Contact_Type__c, Contact.RecordType.Name, Account_Name__c from User 
        where Id = :userId limit 1];
        
        return user.Account_Name__c;
    }
    
    public String getUserTypeFromUserProfile()
    {
        Id profileId = UserInfo.getProfileId();
        
        List<Profile> profile = [select Id, Name from Profile where Id = :profileId];
        List<Sunrun_Install_Audit_Profile_Mapping__c> profileMapping = [select Name, UserType__c from Sunrun_Install_Audit_Profile_Mapping__c where Name = :profile[0].Name limit 1];
        
        if(profileMapping.size() == 0)
            return 'Partner';
        else
            return profileMapping[0].UserType__c;
    }    
      
    public string SaveInstallAudit(Install_Audit__c installAudit)
    {
        update installAudit;
        
        return null;
    }
    
    public List<Audit_Feedback__c> getInstallAuditFeedback(string installAuditId)
    {
        List<Audit_Feedback__c> auditFeedback = [Select QA_Score__c, Comments__c, Name, Install_Audit__c, Install_Audit__r.Status__c, 
                                                Audit_Criteria__r.System_Component__c, Audit_Criteria__r.Criteria_Id__c, 
                                                Audit_Criteria__r.Notes_Evaluation__c, Audit_Criteria__r.Point_Value__c, 
                                                Audit_Criteria__r.Priority_Criteria__c, Audit_Criteria__r.Criteria_Type__c, 
                                                Audit_Criteria__r.Criteria_Description__c, Audit_Criteria__r.Criteria_QA_Score_Type__c,
                                                Audit_Criteria__r.Auto_Calculated__c 
                                                From Audit_Feedback__c WHERE Install_Audit__c = :installAuditId order by Audit_Criteria__r.Criteria_Id__c];
    
    
        return auditFeedback;
    }
    
    public List<Audit_Criteria__c> getActiveAuditCriteria()
    {
        List<Audit_Criteria__c> auditCriteria = [SELECT Active__c, Name, Audit_Type__c, CreatedById, CreatedDate, Criteria_Description__c, Criteria_Id__c, Criteria_Type__c, IsDeleted, LastModifiedById, LastModifiedDate, Notes_Evaluation__c, 
                                                OwnerId, Point_Value__c, Priority_Criteria__c, ConnectionReceivedId, Id, ConnectionSentId, System_Component__c, SystemModstamp, Criteria_QA_Score_Type__c,
                                                Audit_Criteria__c.Auto_Calculated__c
                                                FROM Audit_Criteria__c where Active__c = true order by Criteria_Id__c];
    
        return auditCriteria ;
    }
    
    public Install_Audit__c getInstallAudit(string installAuditId)
    {
        Install_Audit__c installAudit = [select Id, Site_Visit_Date__c, Status__c, Comments__c, Priority_Criteria_Missed__c, Criteria_Missing__c,
                                         Auditor_Account__c, Auditor_Contact__c, Priority_Criteria_Missing__c, 
                                         Install_Audit_Type__c, Score__c, EPC_Discrepancies__c, Partner_Metric__c, Corporate_Metric__c, 
										 Generation_Asset__r.Name, Generation_Asset__r.Home_Address__c,Generation_Asset__r.Proposal_Unique_ID__c,
										 Service_Contract__r.Id, Service_Contract__r.Name, Service_Contract__r.Home_Address__c,Service_Contract__r.Proposal__c
                                         from Install_Audit__c where Id = :installAuditId];
        
		System.debug('installAudit: ' + installAudit);
        return installAudit;
    }
    
    public List<selectOption> getAuditorAccounts()
    {
        List<selectOption> options = new List<selectOption>();
        options.add(new selectOption('',''));
        for(Account a:[SELECT Id, Name, RecordType.Name, Partner_Type__c
                       FROM Account Where Partner_Type__c Includes ('Auditor')
                        Order By Name])
        {
          options.add(new selectOption(a.Id, a.Name));
        }
        return options;  
    }
    
    public List<selectOption> getContactsForAuditorAccount(String Id)
    {
        if(Id == null || Id == '')
            return null;
        List<selectOption>  options = new List<selectOption>();
        options.add(new selectOption('',''));
        for(Contact c: [SELECT Id, Name
                       FROM Contact Where AccountId = :Id Order By Name])
        {
            options.add(new selectOption(c.Id, c.Name)); 
        }              
        return options;        
    }
    
    public List<Proposal__c> getProposalSiteCharacteristics(String propId)    
    {
        return [select id, Name, Proposal_Source__c,
                Array_1_Panel_Type__c, Array_1_No_of_Panels__c, Array_1_No_of_Inverters__c, Array_1_Inverter_Type__c, Array_1_Pitch__c, 
                Array_1_Azimuth__c, Array_1_January_Shade__c, Array_1_February_Shade__c, Array_1_March_Shade__c, Array_1_April_Shade__c, 
                Array_1_May_Shade__c, Array_1_June_Shade__c, Array_1_July_Shade__c, Array_1_August_Shade__c, Array_1_September_Shade__c, 
                Array_1_October_Shade__c, Array_1_November_Shade__c, Array_1_December_Shade__c,
                Array_2_Panel_Type__c, Array_2_No_of_Panels__c, Array_2_No_of_Inverters__c, Array_2_Inverter_Type__c, Array_2_Pitch__c, 
                Array_2_Azimuth__c, Array_2_January_Shade__c, Array_2_February_Shade__c, Array_2_March_Shade__c, Array_2_April_Shade__c,
                Array_2_May_Shade__c, Array_2_June_Shade__c, Array_2_July_Shade__c, Array_2_August_Shade__c, Array_2_September_Shade__c, 
                Array_2_October_Shade__c, Array_2_November_Shade__c, Array_2_December_Shade__c,
                Array_3_Panel_Type__c, Array_3_No_of_Panels__c, Array_3_No_of_Inverters__c, Array_3_Inverter_Type__c, Array_3_Pitch__c, 
                Array_3_Azimuth__c, Array_3_January_Shade__c, Array_3_February_Shade__c, Array_3_March_Shade__c, Array_3_April_Shade__c, 
                Array_3_May_Shade__c, Array_3_June_Shade__c, Array_3_July_Shade__c, Array_3_August_Shade__c, Array_3_September_Shade__c, 
                Array_3_October_Shade__c, Array_3_November_Shade__c, Array_3_December_Shade__c,
                Array_4_Panel_Type__c, Array_4_No_of_Panels__c, Array_4_No_of_Inverters__c, Array_4_Inverter_Type__c, Array_4_Pitch__c, 
                Array_4_Azimuth__c, Array_4_January_Shade__c, Array_4_February_Shade__c, Array_4_March_Shade__c, Array_4_April_Shade__c, 
                Array_4_May_Shade__c, Array_4_June_Shade__c, Array_4_July_Shade__c, Array_4_August_Shade__c, Array_4_September_Shade__c, 
                Array_4_October_Shade__c, Array_4_November_Shade__c, Array_4_December_Shade__c,
                Array_5_Panel_Type__c, Array_5_No_of_Panels__c, Array_5_No_of_Inverters__c, Array_5_Inverter_Type__c, Array_5_Pitch__c, 
                Array_5_Azimuth__c, Array_5_January_Shade__c, Array_5_February_Shade__c, Array_5_March_Shade__c, Array_5_April_Shade__c, 
                Array_5_May_Shade__c, Array_5_June_Shade__c, Array_5_July_Shade__c, Array_5_August_Shade__c, Array_5_September_Shade__c, 
                Array_5_October_Shade__c, Array_5_November_Shade__c, Array_5_December_Shade__c,
                Array_6_Panel_Type__c, Array_6_No_of_Panels__c, Array_6_No_of_Inverters__c, Array_6_Inverter_Type__c, Array_6_Pitch__c, 
                Array_6_Azimuth__c, Array_6_January_Shade__c, Array_6_February_Shade__c, Array_6_March_Shade__c, Array_6_April_Shade__c, 
                Array_6_May_Shade__c, Array_6_June_Shade__c, Array_6_July_Shade__c, Array_6_August_Shade__c, Array_6_September_Shade__c, 
                Array_6_October_Shade__c, Array_6_November_Shade__c, Array_6_December_Shade__c, 
                (Select Id, name, April_Shade__c, Array_Number__c, August_Shade__c, Azimuth__c, December_Shade__c, February_Shade__c,
					Ground_Mount__c, Inverter_Type__c, January_Shade__c, July_Shade__c, June_Shade__c, March_Shade__c, 	May_Shade__c, 
					Mounting_Method__c, November_Shade__c, 	Number_of_Inverters__c, Number_of_Panels__c, October_Shade__c, 	Panel_Type__c,
					Pitch__c, Production__c, September_Shade__c from Array_Information__r)
                from Proposal__c where Id = :propId];
    }
}