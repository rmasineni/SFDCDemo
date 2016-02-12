public class InPersonCreditResponse {
	
	public String returnCodeStr = '';
	public String status = '';
	public string response {get;set;}
	public String message {
		get
		{
			System.debug('returnCodeStr2: ' + returnCodeStr);
			if(returnCodeStr == null || returnCodeStr == '' || (returnCodeStr == 'Success')){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'LeaseDimensions has successfully processed your request.'));
			}else{
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning, 'LeaseDimensions is unable to process your request. Please contact LeaseDimensions support.'));
			}
			return '';		
		}
		set;
	}
	public InPersonCreditResponse(){
		String returnCodeStr = System.currentPageReference().getParameters().get('returnCode');
		System.debug('returnCodeStr: ' + returnCodeStr);
		if(returnCodeStr == null || returnCodeStr == '' || (returnCodeStr == 'Success')){
			System.debug('Inside Success: ');
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'LeaseDimensions has successfully processed your request.'));
		}else{
			System.debug('Inside failure: ');
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning, 'LeaseDimensions is unable to process your request. Please contact LeaseDimensions support.'));
		}
	}
}