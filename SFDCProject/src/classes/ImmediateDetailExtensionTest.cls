@isTest(seeAllData=true)
public class ImmediateDetailExtensionTest {
public static testMethod void testImmaediateDetailExtension()
{

ImmediateDetailExtension objImmi = new ImmediateDetailExtension();

objimmi.updateCounter();

objImmi.getSearchBy();

objimmi.SortWrapper();
objimmi.RefereshInterval();
objimmi.getHasPrevious();
objimmi.previous();

objimmi.next();

objimmi.getTotalPageCount();

objimmi.getPageNumber();
// objimmi.last();

objimmi.first();
objimmi.getHasNext();

objimmi.searchColumnName = 'Name';
objimmi.searchValue='t';
objimmi.RefereshInterval();
objimmi.doSearch();    

objimmi.searchColumnName = 'SiteDesigner';
objimmi.searchValue='t';
objimmi.doSearch();    
objimmi.RefereshInterval();

objimmi.searchColumnName = 'SiteDesignPriority';
objimmi.searchValue='t';
objimmi.doSearch();    
objimmi.RefereshInterval();

objimmi.searchColumnName = 'SalesPartner';
objimmi.searchValue='e';
objimmi.doSearch();    
objimmi.RefereshInterval();

objimmi.searchColumnName = 'InstallBranch';
objimmi.searchValue='a';
objimmi.doSearch();    
objimmi.RefereshInterval();

objimmi.searchColumnName = 'Channel';
objimmi.searchValue='a';
objimmi.doSearch();    
objimmi.RefereshInterval();

objimmi.searchColumnName = 'LeadSource';
objimmi.searchValue='e';
objimmi.doSearch();    
objimmi.RefereshInterval();
objimmi.searchColumnName = 'email';
objimmi.searchValue='a';
objimmi.RefereshInterval();

objimmi.searchColumnName = 'phone';
objimmi.searchValue='1';
objimmi.RefereshInterval();

objimmi.searchColumnName = 'Custname';
objimmi.searchValue='a';
objimmi.RefereshInterval();
objimmi.searchColumnName = 'readyfor';
objimmi.searchValue='a';
objimmi.RefereshInterval();
    
objimmi.userActions();  
objimmi.urlPrefix='';
objimmi.userId= UserInfo.getUserId();
objimmi.redirectURL='';
objimmi.displayTandCURL=false;
objimmi.showConfirm=true;
objimmi.SalesRepURL='';

list<Contact> CurrentContact=[select id, T_C_Accepted__c,Sunrun_User__c,Contact_Type__c,Email from Contact limit 1];
if(CurrentContact !=null && CurrentContact.size()>0)
{
Contact objCont = CurrentContact[0];
objCont.Sunrun_User__c = userinfo.getUserId();
objCont.Email = userinfo.getUserEmail();
objCont.Contact_Type__c='Employee';
//update objCont;
}
List<opportunity> lstOpp = new List<opportunity>();
  lstOpp = [select Id,Name from opportunity limit 1];
  if(lstOpp!=null && lstOpp.size()>0)
  {
  objimmi.SelectedOpportunityId = lstOpp[0].Id;
  objimmi.selectedOppId = lstOpp[0].Id;
  objimmi.clearOthers();
  objimmi.redirectDesignToolSaveProject();
 //objimmi.last();
  objimmi.loginContactId = lstOpp[0].Id;
  ApexPages.StandardSetController sc = objimmi.setCon;
  
  }
 lstOpp = [select Id,Name from opportunity where Site_Design_Status__c=:'In Progress' limit 1];
 if(lstOpp!=null && lstOpp.size()>0)
  {
      objimmi.SelectedOpportunityId = lstOpp[0].Id;
      objimmi.selectedOppId = lstOpp[0].Id;
      objimmi.clearOthers();
      objimmi.selectedDesign=null;
      objimmi.redirectDesignTool();
      ImmediateDetailExtension.getlatestOppRecord(lstOpp[0].Id);
  ImmediateDetailExtension.getlatestOppRecord(null);
  }
  List<Lead> lstLead = [select Id,Name,createddate from Lead limit 1];
  if(lstLead !=null && lstLead.size()>0)
  {
  ImmediateDetailExtension.MyWrapper myWrap = new ImmediateDetailExtension.MyWrapper(lstLead[0]);
  myWrap.CurrentDate = DateTime.now();
  myWrap.leadList = lstLead;
  myWrap.OpptyList = lstOpp;
  
  }
}
}