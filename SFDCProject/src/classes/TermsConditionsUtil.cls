public with sharing class TermsConditionsUtil {
    public static Pagereference redirectToTermsConditions(ID partnerContactId, ID returnId, String returnPage, String selectedDesign, String prospectId, String tandCType, String src){        
           PageReference partnerTandCPage = Page.PartnerTermsConditions;
           partnerTandCPage.getParameters().put('Id',partnerContactId);
           partnerTandCPage.getParameters().put('returnId',returnId);
           partnerTandCPage.getParameters().put('returnPage',returnPage);
           partnerTandCPage.getParameters().put('selectedDesign',selectedDesign);
           partnerTandCPage.getParameters().put('prospectId',prospectId);
           partnerTandCPage.getParameters().put('tandCType',tandCType); 
           partnerTandCPage.getParameters().put('src',src); 
        
           //partnerTandCPage.setRedirect(true);
           return partnerTandCPage;  
    }
    
    public static List<TermsConditions__c> fetchPartnerTermsConditions(String tandCType){
        System.debug(LoggingLevel.INFO,'In fetchPartnerTermsandConditions()');
        List<TermsConditions__c> PartnerTermsConditions;
        //renderTermsConditions = true; 
            try{
                 PartnerTermsConditions = [SELECT TermsConditionsInfo__c FROM TermsConditions__c 
                                           WHERE TermsConditionsType__c = :tandCType AND Active__c = True ORDER BY SeqNo__c];
                 if (PartnerTermsConditions.isEmpty()) {
                     ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Terms and Conditions are not defined. Please contact System Admin');
                     ApexPages.addMessage(myMsg);
                     //renderTermsConditions = false;
                 }
                } catch(Exception e) {
                  System.debug(LoggingLevel.INFO,'Exception'); 
                  ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage());
                  ApexPages.addMessage(myMsg);
            }
           return PartnerTermsConditions; 
    }

    public static void updateTermsandConditions(ID partnerContactId) {
 
        system.debug(LoggingLevel.INFO,'In acceptTermsandConditions');
        try {
            Contact contacUpdate = new Contact(Id=partnerContactId,T_C_Accepted__c = true,T_C_Accepted_Date__c = DateTime.now().Date());
            update contacUpdate;         
        } catch(Exception e) {
            System.debug(LoggingLevel.INFO,'Exception : '+e.getMessage()); 
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage());
            ApexPages.addMessage(myMsg);
       }
    }

}