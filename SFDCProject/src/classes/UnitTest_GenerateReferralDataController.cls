@isTest(SeeAllData=true)
public class UnitTest_GenerateReferralDataController {
	public static testmethod void testGenerateReferralDataController(){
		GenerateReferralDataController referralObj = new GenerateReferralDataController();
		ApexPages.CurrentPage().getparameters().put('fromDate', '2012/01/01');
		ApexPages.CurrentPage().getparameters().put('fromDate', '2013/01/01');
		ApexPages.CurrentPage().getparameters().put('excel', 'Y');
		referralObj.init();
		referralObj.genExcel();
		referralObj.refreshData();
		referralObj.refreshData2();
		referralObj.getthousandBlocks();		
	}

}