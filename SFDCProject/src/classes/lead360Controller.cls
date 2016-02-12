public with sharing class lead360Controller {
    /* The standard controller object which will be used later for navigation and to invoke
       it's save action method to create the new Quote. */
    ApexPages.StandardController controller;
    public Lead leadRec {get;set;}
    public String errorPageDetails {get;set;}

    public lead360Controller (ApexPages.StandardController c) 
    {
        controller = c;
        leadRec = (Lead) c.getRecord();
        errorPageDetails = System.currentPageReference().getParameters().get('msg') ;
        if (errorPageDetails == null)
            errorPageDetails = '';
    }
    public PageReference send() 
    {
        Id leadId = leadRec.Id;
              
        if (errorPageDetails == '')
        {
            String updResult = '';
            String retMsg = CallOut2Leads360.sendLead(leadId);
            if (retMsg != null && retMsg.trim() == 'Success')
            {
                updResult = 'Lead passed to Verengo successfully ' + DateTime.now().format();
                errorPageDetails = 'Lead sent to Verengo successfully';
            }
            else
            {
                errorPageDetails = 'Error sending lead to Verengo : ' + retMsg;
                updResult = 'Error - ' + retMsg;
            }
            Lead updLeadRec = [Select Id from Lead where Id = :leadId];
            leadRec.Leads360_Result__c = updResult;
            update leadRec;
        }
        system.debug('Renewal response : ' + errorPageDetails);
        
        PageReference retPage = Page.VerengoLeadConf;
        retPage.setRedirect(true);
        retPage.getParameters().put('id',leadRec.id);
        retPage.getParameters().put('msg', errorPageDetails);
        return retPage;
        
    } 
    public void sendNotification(String leadId, String errorMsg)
    {
        Lead360_Int_Mapping__c[] mapList = [Select Lead360_Value__c from Lead360_Int_Mapping__c where Lookup_Field__c = 'SF_Notification_Lookup'];
        if (mapList.size() <= 0)
        {
            return;
        } 
        String toAddress = mapList[0].Lead360_Value__c ;
        String[] toEmailId = new String[] {toAddress};
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses( toEmailId );
                            
        String subject = 'Error posting lead to Verengo';
        String body = errorMsg;
        body += '\r\n\r\n';

        mail.setSubject(subject);
        mail.setHTMLBody(body);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
         
    }   
    public PageReference cancel() 
    {
        PageReference maintPage = new ApexPages.StandardController(leadRec).view();
        maintPage.setRedirect(true);
        return maintPage;
    }
}