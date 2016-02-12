/*
Coder:       Peter Alexander Mandy
Date:        10/26/2012:10:46:28.02
Description: Apex Class that handles the synchronous call to the CDYNE API based on button invocation on an Lead.            
*/
public class LeadExtensionForCDYNE {

private Lead leadObj;

public LeadExtensionForCDYNE(ApexPages.StandardController stdController){	
	this.leadObj = (Lead)stdController.getRecord();	
}

public PageReference getPageRef()
{
	PageReference pr = new PageReference('/' + this.leadObj.Id);
    pr.setRedirect(true);
    return pr;
}
public PageReference init(){
	
	CDYNEService CDYNE = new CDYNEService();
    Set<String> setLeadIds = new Set<String>();
    setLeadIds.add(String.ValueOf(this.leadObj.Id));
    // Call CDYNE Service to get immediate ZIP+6 Response and then refresh the page.
    CDYNE.processZipPlusSixForLeadsImmediate(setLeadIds); 
    return getPageRef();   

}

}