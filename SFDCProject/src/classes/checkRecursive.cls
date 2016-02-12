public Class checkRecursive{
    private static boolean runReferralService = true; 
    private static boolean findContact = true;
    private static boolean findContactPreference = true;  
    private static boolean promotionTrigger=false;
    public static set<id> leadsetIds=new Set<id>();    
    public static set<id> partnerPortalIds=new Set<id>(); 
    public static set<id> sunrunSouthIds=new Set<id>(); 
    public static set<id> referralLeadIds=new Set<id>(); 
    public static set<id> batchLeadIds=new Set<id>(); 
    public static set<id> BatchClassLeadIds=new Set<id>(); 
    public static set<id> convertedLeadIds=new Set<id>();
    public static set<id> referralServiceLeadIds=new Set<id>();
    public static set<id> installPartnerLeadIds=new Set<id>();
    public static set<id> installBranchFactors=new Set<id>();
    public static set<id> updatedNotesLeadIds=new Set<id>();
    public static set<id> updatedPartnerNotesLeadIds=new Set<id>();
    public static set<id> scheduledInstallIds=new Set<id>();
    public static set<id> permitSubmittedIds=new Set<id>();
    public static set<id> permitApprovedIds=new Set<id>();
    public static set<id> constructionCompletedIds=new Set<id>();
    public static set<id> inspectionSignOffIds=new Set<id>();
    public static set<id> utilityInterconnectionIds=new Set<id>();
    public static set<id> ptoIds=new Set<id>();
    public static set<String> LeadSourceSet=new Set<String>();
    public static set<id> AmbassadorReferralLeadIds=new Set<id>();
    public static set<id> siteAuditSchedule=new set<id>();
    public static set<id> siteAuditComplete= new set<id>();
    public static set<id> recipientlistids=new set<id>();
    public static set<id> capids=new set<id>();
    public static set<id> costcoContactIds=new set<id>();
    public static set<String> costcoids=new set<String>();
    public static set<String> newcostcoids=new set<String>();
    public static set<String> ambassadorContacts=new set<String>();
    public static set<String> ambassadornewContacts=new set<String>();
    public static set<String> ActivateAmbassadorContacts=new set<String>();
    public static set<String> ActivateAmbassadornewContacts=new set<String>();
    public static set<String> AmbassadorReferrals=new set<String>();
    public static set<String> AmbassadornewReferrals=new set<String>();
    public static set<String> NonAmbassadorReferrals=new set<String>();
    public static set<String> NonAmbassadornewReferrals=new set<String>();
    public static set<id> ERPContactIds=new set<id>();
    public static set<id> CloneERPContactIds=new set<id>();
    public static set<id> ServiceContractIds=new set<id>();
    public static set<id> NewServiceContractIds=new set<id>();
    public static set<id> phaseIds =new set<id>();
    public static set<id> homeDepotLeadIds =new set<id>();
    public static set<id> homeDepotOpptyIds =new set<id>();
    public static set<id> homeDepotAPIReqLeadIds =new set<id>();
    public static set<id> homeDepotAPIReqOptyIds =new set<id>();
    public static set<id> homeDepotSCEIds = new set<id>();
    public static set<id> homeDepotAPIReqSCEIds = new set<id>();
    public static set<id> taskIds = new set<id>();
    public static set<id> LeadOwnerUpdate = new set<id>();
    public static set<id> MileStoneSCIds = new set<id>();
    private static boolean MileStoneTrigger=true;
    public static set<id> coreLogicAcctIds = new set<id>();
    public static set<id> deDupLeadIds = new set<id>();
    public static set<id> duplicateProposalIds= new set<id>();
    public static set<id> deDupLeadIdsAfterUpdate = new set<id>();
    public static set<id> loadLeadIdsAfterUpdate = new set<id>();
    public static set<id> scIdforSendCancelMail = new set<id>();
    //public static boolean loadRelatedRecords;
    public static set<id> investorScIds = new set<id>();
    public static boolean runReferralServiceOnce(){
    if(runReferralService){
     runReferralService=false;
     return true;
    }else{
        return runReferralService;
    }
    }
    public static boolean runContactOnce(){
    if(findContact){
     findContact=false;
     return true;
    }else{
        return findContact;
    }
    }
    public static boolean runContactPreferenceOnce(){
    if(findContactPreference){
     findContactPreference=false;
     return true;
    }else{
        return findContactPreference;
    }
    }
    public static boolean runPromotionOnce(){
    if(promotionTrigger){
     promotionTrigger=false;
     return true;
    }else{
        return promotionTrigger;
    }
    }
    
    public static boolean runMileStoneOnce(){
    if(MileStoneTrigger){
     MileStoneTrigger=false;
     return true;
    }else{
        return MileStoneTrigger;
    }
    }
}