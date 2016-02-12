trigger trg_before_insert_upd_sce on Service_Contract_Event__c (before insert) {
     List<Opportunity> opptylist = New List<Opportunity>();
     Set<Id> opptyids = new Set<Id>();
     Map<id,Opportunity> OpptyMap=new Map<id,Opportunity>();
     Set<Id>scids = new Set<Id>();
     for(Service_Contract_Event__c sce:trigger.new){
         opptyids.add(sce.opportunity__c);          
        }
     if(!opptyids.isempty()){
        for(Opportunity oppObj:[select id,Scheduled_Construction_Start_Date__c,Plans_Reviewed_Date__c,Project_Manager__c,Submit_Final_Interconnection__c,
         Layout_Approval_Start__c,Site_Audit_Completed__c,Elect_PV_Finish_Date__c,Permitting_Process_Start_Date__c,
         Permitting_Process_Finish_Date__c,Actual_Construction_Start__c,Actual_Construction_Finish__c,Layout_Approval_Finish__c,
        Plans_Completed_Date__c,Date_when_Site_Audit_was_Scheduled__c,Site_Audit_Results_Rcvd__c,Return_to_Sales_Date__c,
        Critter_Guard__c,Reroof_under_array__c,Service_Panel_Upgrade__c,Vaulted_Ceilings__c,Main_Panel_Size_Amps__c,Job_Type__c,SunRun_NTP_Costco_PO_Issued__c,
        Oracle_Opportunity_Close_Date__c,Oracle_Revenue_Amount__c,Welcome_Call__c,Welcome_Call_Status__c,Permit_Jurisdiction_municipality__c,Site_Audit_Notes__c from Opportunity where id in:opptyids]){
            OpptyMap.put(oppObj.id,oppObj);
        }
     }
     for(Service_Contract_Event__c sce:trigger.new){
        if(OpptyMap.containsKey(sce.opportunity__c)){
            sce.Scheduled_Construction_Start_Date__c=OpptyMap.get(sce.opportunity__c).Scheduled_Construction_Start_Date__c;
            sce.Layout_Rcvd__c = OpptyMap.get(sce.opportunity__c).Plans_Reviewed_Date__c;
            sce.Project_Manager__c = OpptyMap.get(sce.opportunity__c).Project_Manager__c;
            sce.Submit_Final_Interconnection__c = OpptyMap.get(sce.opportunity__c).Submit_Final_Interconnection__c;
            sce.Layout_Approval_Start__c = OpptyMap.get(sce.opportunity__c).Layout_Approval_Start__c;
            sce.Site_Audit_Complete__c = OpptyMap.get(sce.opportunity__c).Site_Audit_Completed__c;
            sce.Final_Inspection_Signoff__c = OpptyMap.get(sce.opportunity__c).Elect_PV_Finish_Date__c;
            sce.Permit_Submitted_Date__c = OpptyMap.get(sce.opportunity__c).Permitting_Process_Start_Date__c;
            sce.Permit_Approval_Date__c = OpptyMap.get(sce.opportunity__c).Permitting_Process_Finish_Date__c;
            sce.Commencement_of_Construction__c = OpptyMap.get(sce.opportunity__c).Actual_Construction_Start__c;
            sce.Completion_of_Construction__c = OpptyMap.get(sce.opportunity__c).Actual_Construction_Finish__c;
            sce.CAP_date_approved__c = OpptyMap.get(sce.opportunity__c).Layout_Approval_Finish__c;
            sce.Plans_Completed_Date__c = OpptyMap.get(sce.opportunity__c).Plans_Completed_Date__c;
            sce.Date_when_Site_Audit_was_Scheduled__c = OpptyMap.get(sce.opportunity__c).Date_when_Site_Audit_was_Scheduled__c;
            sce.Site_Audit_Results_Rcvd__c = OpptyMap.get(sce.opportunity__c).Site_Audit_Results_Rcvd__c;
            sce.Return_to_Sales_Date__c = OpptyMap.get(sce.opportunity__c).Return_to_Sales_Date__c;
            sce.Critter_Guard__c = OpptyMap.get(sce.opportunity__c).Critter_Guard__c;
            sce.Reroof_under_array__c = OpptyMap.get(sce.opportunity__c).Reroof_under_array__c;
            sce.Service_Panel_Upgrade__c = OpptyMap.get(sce.opportunity__c).Service_Panel_Upgrade__c;
            sce.Vaulted_Ceilings__c = OpptyMap.get(sce.opportunity__c).Vaulted_Ceilings__c;
            sce.Main_Panel_Size_Amps__c = OpptyMap.get(sce.opportunity__c).Main_Panel_Size_Amps__c;
            sce.Job_Type__c = OpptyMap.get(sce.opportunity__c).Job_Type__c;
            sce.SunRun_NTP_Costco_PO_Issued__c = OpptyMap.get(sce.opportunity__c).SunRun_NTP_Costco_PO_Issued__c;
            sce.Oracle_Opportunity_Close_Date__c = OpptyMap.get(sce.opportunity__c).Oracle_Opportunity_Close_Date__c;
            sce.Oracle_Revenue_Amount__c = OpptyMap.get(sce.opportunity__c).Oracle_Revenue_Amount__c;
            sce.Permit_Jurisdiction_municipality__c = OpptyMap.get(sce.opportunity__c).Permit_Jurisdiction_municipality__c;
            sce.Welcome_Call_Status__c = OpptyMap.get(sce.opportunity__C).Welcome_Call_Status__c;
            sce.Welcome_Call__c = OpptyMap.get(sce.opportunity__C).Welcome_Call__c;
            sce.PP_Notes__c = OpptyMap.get(sce.opportunity__C).Site_Audit_Notes__c;
            
        }
     }
}