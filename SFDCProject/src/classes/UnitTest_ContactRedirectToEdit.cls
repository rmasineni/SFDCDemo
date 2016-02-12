@isTest(SeeAllData=true)
public class UnitTest_ContactRedirectToEdit {
	
	public static testmethod void testContactRedirectToEdit(){
		ContactRedirectToEdit contactRedirectObj1 = new ContactRedirectToEdit();
		contactRedirectObj1.getContactEditPage();
		
		Id userId = PartnerDetail__c.getValues('ApexTestAccount').PartnerUserId__c;
		User partnerUser = [Select id, name, email from User where Id =:userId];		
		System.runAs(partnerUser){
			ContactRedirectToEdit contactRedirectObj2 = new ContactRedirectToEdit();
			contactRedirectObj2.getContactEditPage();		
		}		
	}
	
}