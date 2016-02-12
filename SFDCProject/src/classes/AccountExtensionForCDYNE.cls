/*
Coder:       Peter Alexander Mandy
Date:        10/26/2012:10:46:28.02
Description: Apex Class that handles the synchronous call to the CDYNE API based on button invocation on an Account.            
*/
public with sharing class AccountExtensionForCDYNE {

private Account acctObj;

public AccountExtensionForCDYNE(ApexPages.StandardController stdController){	
	this.acctObj = (Account)stdController.getRecord();	
}

public PageReference getPageRef()
{
	PageReference pr = new PageReference('/' + this.acctObj.Id);
    pr.setRedirect(true);
    return pr;
}

public PageReference init(){	
	CDYNEService CDYNE = new CDYNEService();
    Set<String> setAcctIds = new Set<String>();
    setAcctIds.add(String.ValueOf(this.acctObj.Id));
    // Call CDYNE Service to get immediate ZIP+6 Response and then refresh the page.
    CDYNE.processZipPlusSixForAccountsImmediate(setAcctIds);
    return getPageRef();
}

}