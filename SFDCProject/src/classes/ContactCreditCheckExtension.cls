public without sharing class ContactCreditCheckExtension {
private Contact ConObj;
LeaseDimensions LD{get;set;}
    
public ContactCreditCheckExtension(ApexPages.StandardController stdController){
	this.ConObj = (Contact)stdController.getRecord();  
	System.debug('this.ConObj 1 : ' + this.ConObj);
	initContact();
} 

public ContactCreditCheckExtension(Contact contactObj){
  this.ConObj = contactObj;
  System.debug('this.ConObj 2 : ' + this.ConObj);
  initContact();
}

private void initContact(){
	if(this.ConObj != null && this.ConObj.Id != null){
		this.ConObj = [Select Id, name, firstname, lastname, email, accountId, MailingState, MailingCity, Birthdate, OtherPhone,
						Phone, MailingStreet, Preferred_Language__c, MailingCountry, MailingPostalCode, RecordTypeId from Contact where Id =:this.ConObj.Id];
	}
}

public PageReference returnToContact(){	
    PageReference pr = new PageReference('/' + this.ConObj.Id);
    pr.setRedirect(true);
    return pr;
}  

public PageReference ResendCreditCheckInvite(){	
	LeaseDimensions LD = new LeaseDimensions();
	LD.CallResend(String.ValueOf(this.ConObj.Id), this.ConObj.Name, this.conObj.Preferred_Language__c);       
    return null;
}

public PageReference submitCreditCheck(){
	LeaseDimensions LD = new LeaseDimensions();
	String sunrunCreditStr = ProposalUtil.SUNRUN_CUSTOMER_CREDIT;
	
    String retval = '';
    Integer expirationDays = Integer.valueOf(CustomerCreditUtil.getCreditExpirationDays()) * -1;
    for(Customer_Credit__c cc:[select id, Date_Pulled__c, type__c, Date_Submitted__c from Customer_Credit__c where type__c != :sunrunCreditStr and Contact__c = :this.ConObj.Id])
    {
       if(cc.Date_Pulled__c != null && system.today().addDays(expirationDays) < cc.Date_Pulled__c) // still has active credit report
       {
           ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING , '<font color="red" weight="bold">Customer ' + this.ConObj.Name + ' still has an active credit report.  You may not request a new one at this time.</font>'));
       }
       if(cc.Date_Submitted__c != null && cc.Date_Pulled__c == null)
       {
           ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING , '<font color="red" weight="bold">A Credit Report request has previously been submitted for ' + this.ConObj.Name + '.  If you believe they may not have received that previous invitation, please click "Resend"</font>'));
       }   
       return null;
    }
    for(OpportunityContactRole opptyContactRole : [Select id, opportunity.Deal_Id__c, IsPrimary,ContactId,OpportunityId, Role from OpportunityContactRole 
                                                                                                    where contactId = :this.ConObj.Id]){
		if(opportunity.Deal_Id__c != null){
		    LD.dealId = opptyContactRole.opportunity.Deal_Id__c;
			break;
		}
	} 
    LD.CallCreateAndInvite(this.ConObj);
    return null;
}

public PageReference CreditCheckRefresh(){
   LeaseDimensions LD = new LeaseDimensions();
   LD.CreditCheckRefresh(this.ConObj);
   return null;
}

}