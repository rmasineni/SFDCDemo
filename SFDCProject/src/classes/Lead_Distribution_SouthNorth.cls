/*
Writen By:    Maruthi Reddy
Date:        4/18/2014 9:27
Description: Apex Class that handles the Lead distribution between Sunrun South& North.            
*/


public with sharing class Lead_Distribution_SouthNorth {

    public static boolean ByPassChannel = false;
    public static void assignLeads(List<Lead> lst_All_Lead){
        
        Schema.DescribeSObjectResult d = Schema.SObjectType.Lead; 
        Map<String,Schema.RecordTypeInfo> rtMapByName = d.getRecordTypeInfosByName();
        Schema.RecordTypeInfo rtByName =  rtMapByName.get('Small Commercial Leads');
        String SMALL_COMMERCIAL_LEADS = rtByName.getRecordTypeId();
        Date BB_date=date.parse(System.label.Blackbird_Deploy_Date);
        Set<id> north_leads=new Set<id>();
        Set<String> set_Channel_Condition1 = new Set<String>{'3rd Party','Co-Marketing','Billboard','Experiential','Online Display','Social Media','Telemarketing','PR','Unknown','UTM','Corporate', 'Radio', 'TV', 'Email', 'Organic Search', 'Paid Search','Unknown','Other'};
        Map<Id, Account> map_PartnerAccounts = new Map<Id, Account>([Select Id,name from Account Where Name = 'REC Solar' and Ultimate_Parent_Account__c=null and Office_Location__c='Headquarters']);
        List<Lead> lst_RoundRobinLeads = new List<Lead>(); 
        List<Contact_Preferences__c> ContactPreferenceList=new List<Contact_Preferences__c>([select id from Contact_Preferences__c where contact__r.email=:userinfo.getUserEmail() and Lead_Routing__c='No']);
        List<Lead> batchLeads=new List<Lead>();
        for(Lead lead : lst_All_Lead){
        if(!checkrecursive.BatchClassLeadIds.contains(lead.id)){
                checkrecursive.BatchClassLeadIds.add(lead.id);
                if( system.isBatch() == false&&Trigger.isinsert && lead.State != null && lead.State != ''){
                lead.State__c = lead.State;
                }        
                if( system.isBatch() == false&&Trigger.isUpdate && lead.State != lead.State__c){
                  lead.State__c = lead.State;
                }
                if( system.isBatch() == false&&Trigger.isinsert&&!ContactPreferenceList.isempty()){
                 lead.called_in__c=true;
                 lead.Distributin_Logic_Completed__c=true;
                }    
             if(ContactPreferenceList.isempty()&&!(lead.phone==null&& lead.email==null && lead.MobilePhone==null && lead.Alternate_Phone__c==null)&&lead.channel__c!=null&&!lead.Distributin_Logic_Completed__c&&!lead.Called_In__c &&!lead.Referral_web_form__c && Userinfo.getUserType()!='PowerPartner'&& (!((lead.Channel__c == 'Retail'
                                           || lead.Channel__c=='Canvassing' || lead.Channel__c=='Event')) || ByPassChannel)&&lead.createddate>=BB_date){
            //System.debug('------'+ lead.Lastname);
                lead.Distributin_Logic_Completed__c=true;
                lead.Sunrun_South__c = false;
                lead.Sunrun_South_Lead_ID__c = null;
                lead.Lead_Distribution__c = null;
                
                
              
                if(set_Channel_Condition1.contains(lead.Channel__c) &&(lead.State__c=='CA' && lead.State__c!=null) && (lead.Utility_Company__c == 'LADWP'||lead.Utility_Company__c == 'SMUD')){
                    lead.Sunrun_South__c = true;
                    lead.Sunrun_South_Lead_ID__c = '1';
                    System.debug('-----');
                }
           /*
                else if(set_Channel_Condition1.contains(lead.Channel__c) && lead.State__c != null && (lead.State__c != 'NJ' && lead.State__c != 'NY' && lead.State__c != 'HI' && lead.State__c != 'CA' && lead.State__c != 'NV' && lead.State__c !='MA')){
                    lead.Sunrun_South__c = true;
                    lead.Sunrun_South_Lead_ID__c = '1'; 
                    System.debug('-----');                   
              
                }
                */
                
                /*
                else if((lead.Channel__c == 'Direct Mail') && (lead.State__c !=null)){
                    north_leads.add(lead.id);
                }
                */
                
                 else if(lead.Channel__c == 'Retail' && (lead.Custom_Lead_Source__c == 'Retail: Costco In Store' || lead.Custom_Lead_Source__c == 'Retail: Costco Print Advertising'||lead.Custom_Lead_Source__c =='Retail: Costco Solar Station') && ( lead.State__c != 'MA' && lead.State__c!=null)){
                    lead.Sunrun_South__c = true;
                    lead.Sunrun_South_Lead_ID__c = '1';
                    System.debug('----->> Retail Lead'+lead.Channel__c); 
                }
                
                
                else if(lead.Channel__c == 'Retail' && (lead.Custom_Lead_Source__c == 'Retail: Costco In Store' || lead.Custom_Lead_Source__c == 'Retail: Costco Print Advertising'||lead.Custom_Lead_Source__c =='Retail: Costco Solar Station') && ( lead.State__c == 'MA' && lead.State__c!=null) &&(lead.phone!=null || lead.email!=null || lead.MobilePhone!=null || lead.Alternate_Phone__c!=null)){
                    north_leads.add(lead.id);
                }
                
                
                //BSKY-4473 -- Karthik's Changes
                
                else if((lead.Channel__c =='3rd Party' || lead.Channel__c=='Co-Marketing'|| lead.Channel__c=='Corporate'|| lead.Channel__c=='Email'|| lead.Channel__c=='Experimental'|| lead.Channel__c=='Online Display'|| lead.Channel__c=='Organic Search'||
                lead.Channel__c=='Paid Search'|| lead.Channel__c=='PR'|| lead.Channel__c=='TV'|| lead.Channel__c=='Unknown' || lead.Channel__c=='UTM' || lead.Channel__c=='Billboard' || lead.Channel__c=='Telemarketing' || lead.Channel__c=='Social Media' || lead.Channel__c=='Other') && (lead.State__c =='MA' && lead.State__c!=null)){
                    north_leads.add(lead.id);
                }
                 else if((lead.Channel__c =='3rd Party' || lead.Channel__c=='Co-Marketing'|| lead.Channel__c=='Corporate'|| lead.Channel__c=='Email'|| lead.Channel__c=='Experimental'|| lead.Channel__c=='Online Display'|| lead.Channel__c=='Organic Search'||
                lead.Channel__c=='Paid Search'|| lead.Channel__c=='PR'|| lead.Channel__c=='TV'|| lead.Channel__c=='Unknown' || lead.Channel__c=='UTM' || lead.Channel__c=='Billboard' || lead.Channel__c=='Telemarketing' || lead.Channel__c=='Social Media' || lead.Channel__c=='Other') && (lead.State__c =='CA' && lead.State__c!=null)&&(lead.Utility_Company__c=='SMUD' || lead.Utility_Company__c=='LADWP')){
                    lead.Sunrun_South__c = true;
                    lead.Sunrun_South_Lead_ID__c = '1';
                }
                
                else if((lead.Channel__c =='3rd Party' || lead.Channel__c=='Co-Marketing'|| lead.Channel__c=='Corporate'|| lead.Channel__c=='Email'|| lead.Channel__c=='Experimental'|| lead.Channel__c=='Online Display'|| lead.Channel__c=='Organic Search'||
                lead.Channel__c=='Paid Search'|| lead.Channel__c=='PR'|| lead.Channel__c=='TV'|| lead.Channel__c=='Unknown' || lead.Channel__c=='UTM' || lead.Channel__c=='Billboard' || lead.Channel__c=='Telemarketing' || lead.Channel__c=='Social Media' || lead.Channel__c=='Other') && ((lead.State__c =='CA' || lead.State__c=='NY' || lead.State__c=='NJ'||lead.State__c=='HI' ||lead.State__c=='NV')&&lead.State__c!=null)&&
                (lead.Utility_Company__c!='SMUD' || lead.Utility_Company__c!='LADWP')){
                    lst_RoundRobinLeads.add(lead);
                }
                 else if((lead.Channel__c =='3rd Party' || lead.Channel__c=='Co-Marketing'|| lead.Channel__c=='Corporate'|| lead.Channel__c=='Email'|| lead.Channel__c=='Experimental'|| lead.Channel__c=='Online Display'|| lead.Channel__c=='Organic Search'||
                lead.Channel__c=='Paid Search'|| lead.Channel__c=='PR'|| lead.Channel__c=='TV'|| lead.Channel__c=='Unknown' || lead.Channel__c=='UTM' || lead.Channel__c=='Billboard' || lead.Channel__c=='Telemarketing' || lead.Channel__c=='Social Media' || lead.Channel__c=='Other') && ((lead.State__c !='CA' || lead.State__c!='NY' || lead.State__c!='NJ'||lead.State__c!='HI' ||lead.State__c!='NV' || lead.State__c!='MA')&&lead.State__c!=null)){
                    lead.Sunrun_South__c = true;
                    lead.Sunrun_South_Lead_ID__c = '1';
                }
                
                
               
                /*Karthik's Changes
                
                else if(lead.Channel__c == 'Retail' && (lead.Custom_Lead_Source__c == 'Retail: Costco In Store' || lead.Custom_Lead_Source__c == 'Retail: Costco Print Advertising'||lead.Custom_Lead_Source__c =='Retail: Costco Solar Station') && ( lead.State__c == 'CA' || lead.State__c!= null) && lead.Sales_Contact_Method__c == 'Site Visit'&&( lead.Utility_Company__c != 'CA - Southern California Edison (SCE)'||lead.Utility_Company__c == null||lead.Utility_Company__c != 'SCE'||lead.Utility_Company__c !='Southern California Edison (SCE)' )){
                    lead.Sunrun_South__c = true;
                    lead.Sunrun_South_Lead_ID__c = '1';
                    System.debug('-----');
                }else if(lead.Channel__c == 'Retail' && (lead.Custom_Lead_Source__c == 'Retail: Costco In Store' || lead.Custom_Lead_Source__c == 'Retail: Costco Print Advertising'||lead.Custom_Lead_Source__c =='Retail: Costco Solar Station') && lead.State__c == 'CA' && lead.Sales_Contact_Method__c == 'Site Visit'&& (lead.Utility_Company__c == 'CA - Southern California Edison (SCE)'||lead.Utility_Company__c == 'SCE'||lead.Utility_Company__c =='Southern California Edison (SCE)' )){
                    lead.Sunrun_South__c = true;
                    lead.Sunrun_South_Lead_ID__c = '1'; 
                    System.debug('-----');
                }else if(lead.Channel__c == 'Retail' && (lead.Custom_Lead_Source__c == 'Retail: Costco In Store' || lead.Custom_Lead_Source__c == 'Retail: Costco Print Advertising'||lead.Custom_Lead_Source__c =='Retail: Costco Solar Station')&& lead.State__c == 'CA' &&( lead.Utility_Company__c != 'CA - Southern California Edison (SCE)'||lead.Utility_Company__c != 'SCE'||lead.Utility_Company__c !='Southern California Edison (SCE)') &&(lead.Sales_Contact_Method__c =='No Preference'&& lead.Sales_Contact_Method__c == null)){
                    lead.Sunrun_South__c = true;
                    lead.Sunrun_South_Lead_ID__c = '1';   
                    System.debug('-----');      
                }else if(lead.Channel__c == 'Retail' && (lead.Custom_Lead_Source__c == 'Retail: Costco In Store' || lead.Custom_Lead_Source__c == 'Retail: Costco Print Advertising'||lead.Custom_Lead_Source__c =='Retail: Costco Solar Station') && lead.State__c == 'CA' && lead.Sales_Contact_Method__c == 'Phone Consultation' && ( lead.Utility_Company__c == 'CA - Sacramento Municipal Utility District (SMUD)'||lead.Utility_Company__c == 'CA - Los Angeles Dept of Water & Power  (LADWP)'||lead.Utility_Company__c == 'SMUD'||lead.Utility_Company__c == 'LADWP')){
                    lead.Sunrun_South__c = true;
                    lead.Sunrun_South_Lead_ID__c = '1';
                    System.debug('-----');                 
                }else if(lead.Channel__c == 'Retail' && (lead.Custom_Lead_Source__c == 'Retail: Costco In Store' || lead.Custom_Lead_Source__c == 'Retail: Costco Print Advertising'||lead.Custom_Lead_Source__c =='Retail: Costco Solar Station')&&lead.State__c == null && lead.Utility_Company__c == null && (lead.Sales_Contact_Method__c == 'Site Visit' || lead.Sales_Contact_Method__c == 'Phone Consultation') ){
                    lead.Sunrun_South__c = true;
                    lead.Sunrun_South_Lead_ID__c = '1'; 
                    System.debug('-----');
                }
                */
                
                else if(lead.Channel__c == 'Event' || lead.Channel__c == 'Canvassing'  ) {
                    lead.Sunrun_South__c = true;
                    lead.Sunrun_South_Lead_ID__c = '1'; 
                    System.debug('-----');
                }else if(lead.Sales_Partner__c != null && map_PartnerAccounts.containsKey(lead.Sales_Partner__c)){
                    lead.Sunrun_South__c = true;
                    lead.Sunrun_South_Lead_ID__c = '1';
                    System.debug('-----');
                }else if(lead.RecordTypeId == SMALL_COMMERCIAL_LEADS){
                    lead.Sunrun_South__c = true;
                    lead.Sunrun_South_Lead_ID__c = '1';
                    System.debug('-----');
                }
                
              /* Karthik's Changes  
                else if(lead.Channel__c == 'Retail' && (lead.Custom_Lead_Source__c == 'Retail: Costco In Store' || lead.Custom_Lead_Source__c == 'Retail: Costco Print Advertising'||lead.Custom_Lead_Source__c =='Retail: Costco Solar Station') && lead.State__c == 'CA'&& (lead.Utility_Company__c != 'CA - Southern California Edison (SCE)' && lead.Utility_Company__c != 'SCE'&&lead.Utility_Company__c !='Southern California Edison (SCE)' )&& ( Lead.Sales_Contact_Method__c == 'No Preference'||Lead.Sales_Contact_Method__c == null)){
                    lead.Sunrun_South__c = true;
                    lead.Sunrun_South_Lead_ID__c = '1';
                }
              
                
                else if(lead.Channel__c == 'Retail' && (lead.Custom_Lead_Source__c == 'Retail: Costco In Store' || lead.Custom_Lead_Source__c == 'Retail: Costco Print Advertising'||lead.Custom_Lead_Source__c =='Retail: Costco Solar Station') && lead.State__c == 'CA' && (lead.Utility_Company__c == 'CA - Southern California Edison (SCE)' || lead.Utility_Company__c == 'SCE'||lead.Utility_Company__c =='Southern California Edison (SCE)' )&& ( Lead.Sales_Contact_Method__c == 'No Preference'||Lead.Sales_Contact_Method__c == null)){
                    lst_RoundRobinLeads.add(lead);
                }
                
                else if(lead.Channel__c == 'Retail' && (lead.Custom_Lead_Source__c == 'Retail: Costco In Store' || lead.Custom_Lead_Source__c == 'Retail: Costco Print Advertising'||lead.Custom_Lead_Source__c =='Retail: Costco Solar Station') && lead.State__c == 'CA'&&(Lead.Sales_Contact_Method__c == null ||Lead.Sales_Contact_Method__c =='No Preference')&& (lead.Utility_Company__c == 'CA - Southern California Edison (SCE)'||lead.Utility_Company__c == 'SCE'||lead.Utility_Company__c =='Southern California Edison (SCE)' )){
                    lst_RoundRobinLeads.add(lead);
                }
                
                  */
                else if((lead.Channel__c == 'Unknown' || lead.Channel__c == 'Other' ) && (lead.State__c == 'CA' || lead.State__c == 'NY') && (lead.Utility_Company__c == 'CA - Southern California Edison (SCE)'|| lead.Utility_Company__c == null||lead.Utility_Company__c == 'SCE'||lead.Utility_Company__c =='Southern California Edison (SCE)' )){
                    lst_RoundRobinLeads.add(lead);
                }
               
             
               else if(set_Channel_Condition1.contains(lead.Channel__c) && (lead.State__c == 'NJ' || lead.State__c == 'NY' || lead.State__c == 'HI' || lead.State__c == 'CA' || lead.State__c == 'NV')){
                    lst_RoundRobinLeads.add(lead);
                }
              
                else if(lead.Custom_Lead_Source__c == 'Retail: Costco In Store'){
                    if(lead.State__c == 'CA'){
                        if(lead.Utility_Company__c == 'CA - Southern California Edison (SCE)'||lead.Utility_Company__c == 'SCE'||lead.Utility_Company__c =='Southern California Edison (SCE)' ){
                            
                        }
                    }else{
                        lead.Sunrun_South__c = true;
                        lead.Sunrun_South_Lead_ID__c = '1';
                    }
                }
                if(system.isBatch()&&ByPassChannel){
                    if(lead.Sunrun_South__c){
                      //Lead l=new Lead(id=lead.id);
                      batchLeads.add(lead);  
                    }
                    /*
                    else if(!lst_RoundRobinLeads.isempty()&&!lead.Sunrun_South__c){
                      for(Integer i=0;i<lst_RoundRobinLeads.size();i++){
                      if(lst_RoundRobinLeads[i].id!=lead.id&&!lst_RoundRobinLeads[i].sunrun_south__c){
                      north_leads.add(lead.id);  
                      lst_RoundRobinLeads.remove(i);
                      }
                      }
                    }*/
                    else if(lst_RoundRobinLeads.isempty()&&!lead.Sunrun_South__c){
                      north_leads.add(lead.id); 
                    }
                }
                System.debug('---=++++ '+ lead.Sunrun_South__c);
            }
         }   
        }
        if(!lst_RoundRobinLeads.isEmpty()){
            List<Lead_Distribution__c>  lst_LeadDistibution = [ Select Id, Total_RoundRobin_Leads__c, North_Leads__c, South_Leads__c, Sunrun_North_Distribution__c, Sunrun_South_Distribution__c from Lead_Distribution__c Where Active__c=true Order By CreatedDate DESC];
        
            Lead_Distribution__c leadDistibution_obj;
            Integer Total_RoundRobin_Leads = 0;
            Integer North_Lead_Count = 0;
            Integer South_Lead_Count = 0;
            if(lst_LeadDistibution.isEmpty()){
                lst_LeadDistibution[0].addError('Please Create Lead Distribution Record for Round Robin Processing !');
            }else{
                leadDistibution_obj = lst_LeadDistibution[0];
                if(leadDistibution_obj.Total_RoundRobin_Leads__c != null && leadDistibution_obj.Total_RoundRobin_Leads__c!=0 ){
                    Total_RoundRobin_Leads = leadDistibution_obj.Total_RoundRobin_Leads__c.intValue();
                }
                if(leadDistibution_obj.North_Leads__c != null){                    
                    North_Lead_Count = leadDistibution_obj.North_Leads__c.intValue();
                }
                if(leadDistibution_obj.South_Leads__c != null){
                    South_Lead_Count = leadDistibution_obj.South_Leads__c.intValue();
                }       
                
                for(Lead l : lst_RoundRobinLeads){
                    l.Lead_Distribution__c = leadDistibution_obj.Id;
                    if(Total_RoundRobin_Leads !=0 && (North_Lead_Count*100)/Total_RoundRobin_Leads < leadDistibution_obj.Sunrun_North_Distribution__c){
                        North_Lead_Count++;
                        Total_RoundRobin_Leads++;
                    }else{
                        South_Lead_Count++;
                        Total_RoundRobin_Leads++;
                        l.Sunrun_South__c = true;
                        l.Sunrun_South_Lead_ID__c = '1';
                    }
                    if(system.isBatch()&&ByPassChannel){
                    if(l.Sunrun_South__c ){
                      //Lead l=new Lead(id=lead.id);
                      batchLeads.add(l);  
                    }
                    else if(!l.Sunrun_South__c ){
                      north_leads.add(l.id);  
                    }
                }
                }
                System.debug('----- '+ leadDistibution_obj + '-- ' +leadDistibution_obj.South_Leads__c + '--' + leadDistibution_obj.North_Leads__c);
                leadDistibution_obj.South_Leads__c = South_Lead_Count;
                leadDistibution_obj.North_Leads__c = North_Lead_Count;
                update leadDistibution_obj;
            }           
        }
        if(!batchLeads.isempty()){
                system.debug('sssss'+batchLeads);
                database.update(batchLeads,false);
            }
            if(!north_leads.isempty()){
                 Lead_Assignment.Lead_Assignment_Immediate(north_leads);
            }
    }
    
    public static void updateRelatedValues(List<Lead> lst_Leads){
        Set<String> set_EmailsIds = new Set<String>();
        Set<String> set_Costco_Location = new Set<String>();
        Set<String> Set_ContactIds = new Set<String>();
        Map<String, Contact> map_Contacts = new Map<String, Contact>();     
        Map<String, Contact> map_Ins_Contact = new Map<String, Contact>();
        Map<String, Account> map_Accounts = new Map<String, Account>();
        //List<CampaignMember> cmList=new List<CampaignMember>();
        for(Lead l : lst_Leads){            
            if(l.Referred_by_Contact_Email__c  != null && l.Referred_by_Contact_Email__c  != ''){
                set_EmailsIds.add(l.Referred_by_Contact_Email__c);
            }
            if(l.Costco_Location__c != null && l.Costco_Location__c != ''){
                set_Costco_Location.add(l.Costco_Location__c);
            }
            if(l.Referred_By_Contact__c != null && l.Channel__c == 'Referral' && l.Asset_Sales_Organization__c != 'REC Solar'){
                Set_ContactIds.add(l.Referred_By_Contact__c);
            }
        }
        //List<Generation_Assets__c> lst_Generation_Assets = [ Select Id, Customer_Contact__c, Sales_Organization__c from Generation_Assets__c Where Sales_Organization__c='REC Solar' AND Customer_Contact__c IN  :Set_ContactIds AND Customer_Contact__c != null];
        Set<String> set_Gen_ContactIds = new Set<string>();
        /*for(Generation_Assets__c v : lst_Generation_Assets){
            set_Gen_ContactIds.add(v.Customer_Contact__c);
        }*/
        List<Service_Contract_Event__c> lst_serviceContractEvent = [ select service_Contract__r.contactid,service_Contract__r.Sales_Organization__c,pto__c from Service_Contract_Event__c where service_Contract__r.Sales_Organization__c='REC Solar' AND service_Contract__r.contactid IN  :Set_ContactIds];        
        for(Service_Contract_Event__c v : lst_serviceContractEvent){
            set_Gen_ContactIds.add(v.service_Contract__r.contactid);
        }
        for(Lead l : lst_Leads){
            if(l.Referred_By_Contact__c != null && l.Channel__c == 'Referral' && set_Gen_ContactIds.contains(l.Referred_By_Contact__c)){                                               
                //if(Trigger.isinsert){
                l.Sunrun_South__c = true;
                l.Sunrun_South_Lead_ID__c = '1';               
               // }
                l.Asset_Sales_Organization__c = 'REC Solar'; 
                l.Distributin_Logic_Completed__c=true;
            }
        }
        if(!set_EmailsIds.isEmpty()){
            List<Contact> lst_ExistingContacts = [ Select Id, Email, AccountId from Contact Where AccountId != null AND Email IN : set_EmailsIds ORDER BY CreatedDate DESC ];
            for(Contact con : lst_ExistingContacts){
                if(!map_Contacts.containsKey(con.Email)){
                    map_Contacts.put(con.Email, con);
                }
            }
            if(map_Contacts.size() != set_EmailsIds.size()){
                String ContactAccountId = System.Label.Lead_Non_Customer_Acount;
                if(ContactAccountId != null && ContactAccountId != ''){
                    for(Lead l : lst_Leads){
                        if(l.Referred_by_Contact_Email__c  != null && l.Referred_by_Contact_Email__c  != '' && !map_Contacts.containsKey(l.Referred_by_Contact_Email__c) && !map_Ins_Contact.containsKey(l.Referred_by_Contact_Email__c)){
                            map_Ins_Contact.put(l.Referred_by_Contact_Email__c, new Contact(AccountId=ContactAccountId, Email=l.Referred_by_Contact_Email__c, FirstName=l.Referred_by_Contact_First_Name__c, LastName=l.Referred_by_Contact_Last_Name__c, Phone=l.Referred_by_Contact_Phone__c));
                        }
                    }
                }   
                if(!map_Ins_Contact.isEmpty()){
                    insert map_Ins_Contact.values();
                }
            }
        }
        Id AccrectypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner').getRecordTypeId();
        if(!set_Costco_Location.isEmpty()){
            List<Account> lst_Accounts = [ Select Id, Site from Account Where Site!=null and recordtypeid=:AccrectypeId and Site IN : set_Costco_Location Order By CreatedDate DESC];
            for(Account acc : lst_Accounts){
                if(!map_Accounts.ContainsKey(acc.Site.toUpperCase())){
                    map_Accounts.put(acc.Site.toUpperCase(), acc);
                }
            }
        }
        /*
        List<Lead_Campaign__c> lst_LeadCampaign = Lead_Campaign__c.getAll().values();
        Set<String> set_Channels = new Set<String>();
        set_Channels.add('3rd Party');set_Channels.add('Co-Marketing');set_Channels.add('Billboard');set_Channels.add('Experiential');
        set_Channels.add('Online Display');set_Channels.add('Social Media');set_Channels.add('Telemarketing');set_Channels.add('PR');
        set_Channels.add('Unknown');set_Channels.add('UTM');set_Channels.add('3rd Party');set_Channels.add('Corporate');
        set_Channels.add('Direct Mail');set_Channels.add('Radio');set_Channels.add('TV');set_Channels.add('Email');
        set_Channels.add('Organic Search');set_Channels.add('Paid Search');set_Channels.add('Telemarketing');set_Channels.add('PR');
        set_Channels.add('Unknown');set_Channels.add('Other');
        */
        for(Lead l : lst_Leads){
            /*        
            if(!lst_LeadCampaign.isEmpty()){
                if(!l.Sunrun_South__c&&set_Channels.contains(l.Channel__c) && (l.Status == 'Created' || l.Status == 'Qualified')){
                    //l.Campaign_Nme__c = lst_LeadCampaign[0].General_Campaign__c;
                    CampaignMember cm=new CampaignMember(CampaignId=lst_LeadCampaign[0].General_Campaign__c,leadid=l.id);
                    cmList.add(cm);
                }else if(!l.Sunrun_South__c&&l.Channel__c == 'Retail' && (l.Status == 'Created' || l.Status == 'Qualified')){
                    //l.Campaign_Nme__c = lst_LeadCampaign[0].Retail_Campaign__c;               
                    CampaignMember cm=new CampaignMember(CampaignId=lst_LeadCampaign[0].Retail_Campaign__c,leadid=l.id);
                    cmList.add(cm);
                }            
            }
            */
            if(l.Costco_Location__c != null && l.Costco_Location__c != '' && map_Accounts.containsKey(l.Costco_Location__c.toUpperCase())){
                    l.Lead_Organization_Location_2__c = map_Accounts.get(l.Costco_Location__c.toUpperCase()).id;
                }
            else if(l.Lead_Organization_Location_2__c!=null&&l.Costco_Location__c==null){
                    l.Costco_Location__c =l.Costco_Location_Formula__c;
            }    
            if(l.Referred_by_Contact_Email__c  != null && l.Referred_by_Contact_Email__c  != ''){
                if(map_Contacts.containsKey(l.Referred_by_Contact_Email__c)){
                    l.Referred_by__c = map_Contacts.get(l.Referred_by_Contact_Email__c).AccountId;
                }else if(map_Ins_Contact.containsKey(l.Referred_by_Contact_Email__c)){
                    l.Referred_by__c = map_Ins_Contact.get(l.Referred_by_Contact_Email__c).AccountId;                  
                }    
            } 
            /* 
            if(l.Sunrun_South__c){
                l.Campaign_ID__c  = null;
            } */         
        }
        /*
        if(!cmList.isempty()){
            database.insert(cmList,false);
        }*/
    }
        
    public static void exceptionHandler(Lead l, String errorMsg){
        Custom_Lead__c customLeadError = new Custom_Lead__c();
        customLeadError.Last_Name__c = l.LastName;
        customLeadError.Address__c = l.Street + ', '+ l.state + ', '+ l.City;
        customLeadError.Channel__c = l.Channel__c;
        customLeadError.Company__c = l.Company;
        //customLeadError.City__c = l.City__c;
        customLeadError.Costco_Location__c = l.Costco_Location__c;
        customLeadError.Costco_Member_ID__c = l.Costco_Member_ID__c;
        customLeadError.Costco_Member_Type__c = l.Costco_Member_Type__c;
        customLeadError.Email__c = l.Email;
        customLeadError.Error_Message__c = errorMsg;
        customLeadError.First_Name__c = l.FirstName;
        customLeadError.How_Do_You_Know_This_Person__c = l.How_Do_You_Know_This_Person__c;
        customLeadError.Lead_Classification__c = '';
        customLeadError.Lead_Origin__c = l.Lead_Origin__c;
        customLeadError.Custom_Lead_Source__c = l.Custom_Lead_Source__c;
        customLeadError.Monthly_Electricity_Bill__c = String.valueOf(l.Monthly_Electricity_Bill__c);
        customLeadError.Phone__c = l.Phone;
        customLeadError.Referral_web_form__c = String.valueof(l.Referral_web_form__c);
        customLeadError.Referred_by_Contact_Email__c = l.Referred_by_Contact_Email__c;
        customLeadError.Referred_by_Contact_First_Name__c = l.Referred_by_Contact_First_Name__c;
        customLeadError.Referred_by_Contact_Last_Name__c = l.Referred_by_Contact_Last_Name__c;
        customLeadError.Referred_by_Contact_Phone__c = l.Referred_by_Contact_Phone__c;
        customLeadError.Referrer_Already_A_Customer__c = String.valueOf(l.I_m_Already__c);
        customLeadError.Sales_Rep_Email__c = l.Sales_Rep_Email__c;
        customLeadError.State__c = l.State__c;
        customLeadError.Zip_Postal_Code__c = l.Referred_by_Postal_Code__c;
        insert customLeadError; 
    }
}