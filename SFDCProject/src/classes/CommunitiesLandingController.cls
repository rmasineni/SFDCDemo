/**
 * An apex page controller that takes the user to the right start page based on credentials or lack thereof
 */
public with sharing class CommunitiesLandingController {
    
    // Code we will invoke on page load.
    public PageReference forwardToStartPage() {
        return Network.communitiesLanding();
    }
    public PageReference forwardToCustomAuthPage() {
        String startUrl = System.currentPageReference().getParameters().get('startURL');
        if(startUrl==null){
        return new PageReference(Site.getPathPrefix() + '/home/home.jsp');
        }
        else{
        return new PageReference(Site.getPathPrefix() + '/PartnerPortalLogin?startURL=' + EncodingUtil.urlEncode(startURL, 'UTF-8'));
        }
        return null;
    }
    public CommunitiesLandingController() {}
}