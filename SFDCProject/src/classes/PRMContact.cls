public class PRMContact {
	public Boolean selected{get;set;}
	public Contact contactObj{get;set;}		
	public boolean displayCheckBox{get;set;}	
	public Boolean isActive{get;set;}
	public String getActive()
	{
		return isActive ? 'Yes' : 'No';
	}	
	public PRMContact(){
		selected = false;
		contactObj = new Contact();
		displayCheckBox = false;
	}

	static testMethod void PRMContactTest() {
		PRMContact prmContact = new PRMContact();
		Contact contactObj = prmContact.contactObj;
		prmContact.isActive = false;
		prmContact.displayCheckBox = false;
		prmContact.selected = false;
		String activeStr = prmContact.getActive();
	}	
		
}