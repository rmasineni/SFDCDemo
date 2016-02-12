/***************************************************************************************************
Name	: EmailService
Author  : Raghavendra Masineni
Date    : 
Purpose : 
*******************************************************************************************************/

public class EmailService {	
	
	public static String getHTMLErrorBody(String BatchJob, String errorMessage){
		String htmlBody = '<html>';
		htmlBody += EmailService.getHTMLHeader();
		htmlBody +=  '<p>Dear ' + 'Salesfroce User(s)' + ', </p>';
		htmlBody += '<br/> Reference Batch Job Id : ' +  BatchJob;
		
		htmlBody += 'Salesfroce has failed to execute the Batch Job ' + BatchJob ;
		
		if(errorMessage != null && errorMessage != ''){
			htmlBody += 'Please review the following error message.';
			htmlBody += errorMessage;
		}

		htmlBody += '<p></p>';
		htmlBody += '<br/>';
		htmlBody += '<br/>';
		htmlBody += '<br/>';
		htmlBody += '<p>Thank you,</p>';
		htmlBody += 'SunRun Salesfroce Administrator';
		htmlBody += '<p></p>';
		htmlBody += '<p></p>';
		htmlBody += EmailService.getHTMLFooter();
		htmlBody += '</html>';
		return htmlBody;
		
	}
	
	public static String getHTMLBody(String BatchJob,
								List<Partner_Contract__c> renewedContracts,
								List<Partner_Contract__c> expiredContracts,
								List<Partner_Contract__c> autoRenewalContractsAfter30Days,
								List<Partner_Contract__c> contractsExpiresAfter30Days,
								List<PRMLibrary.ErrorDescription> contractsUpdateResult,
								List<String> autorenewalErrors){
		
		String htmlBody = '<html>';
		htmlBody += EmailService.getHTMLHeader();
		htmlBody +=  '<p>Dear ' + 'Salesfroce User(s)' + ', </p>';
		
		htmlBody += '<br/> Reference Batch Job Id : ' +  BatchJob;
		
		if((renewedContracts == null || renewedContracts.size() <= 0) && 
			(expiredContracts == null || expiredContracts.size() <= 0) && 
			(contractsExpiresAfter30Days == null || contractsExpiresAfter30Days.size() <= 0) &&
			(autoRenewalContractsAfter30Days == null || autoRenewalContractsAfter30Days.size() <= 0) &&
			(contractsUpdateResult == null || contractsUpdateResult.size() <= 0) &&
			(autorenewalErrors == null || autorenewalErrors.size() <= 0)){
			htmlBody += '<p>No Contracts have been Modified/Updated</p>';
				htmlBody += '<br/>';
				htmlBody += '<br/>';
				htmlBody += '<br/>';
				htmlBody += '<br/>';
		
		}else{
		
			htmlBody +=  '</p><H2>Summary of Contract changes</H2>';
			if(renewedContracts != null && renewedContracts.size() >0){
				htmlBody += '<h3>Renewed Contracts</h3>';
				htmlBody += EmailService.getHTMLFormattedContracts(renewedContracts);
			}
			
			if(expiredContracts != null && expiredContracts.size() >0){
				htmlBody += '<h3>Expired Contracts</h3>';
				htmlBody += EmailService.getHTMLFormattedContracts(expiredContracts);
			}
			
			if(autoRenewalContractsAfter30Days != null && autoRenewalContractsAfter30Days.size() >0){
				htmlBody += '<h3>Following Contracts will be renewed after 30 days</h3>';
				htmlBody += EmailService.getHTMLFormattedContracts(autoRenewalContractsAfter30Days);
			}
			
			if(contractsExpiresAfter30Days != null && contractsExpiresAfter30Days.size() >0){
				htmlBody += '<h3>Following Contracts will be expired after 30 days</h3>';
				htmlBody += EmailService.getHTMLFormattedContracts(contractsExpiresAfter30Days);
			}									
		
			if((contractsUpdateResult != null && contractsUpdateResult .size() > 0) || 
				(autorenewalErrors != null && autorenewalErrors .size() > 0)){
				htmlBody += '<span><h3>Summary Of Errors</h3></span>';
			}
			
			if(contractsUpdateResult != null && contractsUpdateResult .size() > 0){
				htmlBody += '<span><p>Salesforce is unable to update the status of following contracts.';
				htmlBody += ' Please review the errors. <br/>';
				htmlBody += ' Contact Salesforce administrator for more details.</p>';
				htmlBody +=  getHTMLFormattedUpdateErrors(contractsUpdateResult);
				htmlBody += '</span>';
			}	
			
			if(autorenewalErrors != null && autorenewalErrors .size() > 0){
				htmlBody += '<span><p>Salesforce is unable to renew the contract due to following errors</p>';
				htmlBody +=  EmailService.getHTMLFormattedRenewedErrors(autorenewalErrors);
				htmlBody += '</span>';
			}
		
		}
		
		htmlBody += '<p></p>';
		htmlBody += '<br/>';
		htmlBody += '<br/>';
		htmlBody += '<br/>';
		htmlBody += '<p>Thank you,</p>';
		htmlBody += 'SunRun Salesfroce Administrator';
		htmlBody += '<p></p>';
		htmlBody += '<p></p>';
		htmlBody += EmailService.getHTMLFooter();
		htmlBody += '</html>';
		return htmlBody;
	}
	
	/*
	public static String getHTMLHeader(){
		String htmlHeader = '<img id="Logo1" src="';
			htmlHeader  += 'https://' + 'c.na4.content.force.com';
			htmlHeader  += '/servlet/servlet.ImageServer?';
			htmlHeader  += 'id=' + '01560000000knRc';
			htmlHeader  += '&oid=' + '00D600000006rTW';
			htmlHeader  += '" height="75" width="500" />';
		return htmlHeader;
	}
	*/

	public static String getHTMLHeader(){
		String htmlHeader = '<img id="Logo1" src="';
			htmlHeader  += 'https://' + 'c.na4.content.force.com';
			htmlHeader  += '/servlet/servlet.ImageServer?';
			htmlHeader  += 'id=' + '015600000013nJc';
			htmlHeader  += '&oid=' + '00D600000006rTW';
			htmlHeader  += '"/>';
			htmlHeader  += '<br/>';
		return htmlHeader;
	}
	
	/*
	public static String getHTMLFooter(){
		String htmlFooter = '<img id="Logo2" src="';
			htmlFooter  += 'https://' + 'c.na4.content.force.com';
			htmlFooter  += '/servlet/servlet.ImageServer?';
			htmlFooter  += 'id=' + '01560000000knRh';
			htmlFooter  += '&oid=' + '00D600000006rTW';
			htmlFooter  += '" height="75" width="500" />';
		return htmlFooter;
	}
	*/
	
	public static String getHTMLFooter(){
		String htmlFooter = '';
		return htmlFooter;
	}
		
	private static String getHTMLFormattedContracts(List<Partner_Contract__c> contracts){
		
		String htmlFormattedTable = '<table border="1">';
				htmlFormattedTable += '<tr>';
				htmlFormattedTable += '<td>Contract Number</td>';
				htmlFormattedTable += '<td>Contract Effective Date</td>';
				htmlFormattedTable += '<td>Contract Expiration Date</td>';
				htmlFormattedTable += '<td>Contract Status</td>';
				htmlFormattedTable += '</tr>';
		
		for(Partner_Contract__c contractObj: contracts){
			htmlFormattedTable +=  '<tr>';
			htmlFormattedTable +=  '<td><span>'+ contractObj.contract_number__c + '</span></td>';
			htmlFormattedTable +=  '<td><span>'+ contractObj.Effective_Date__c + '</span></td>';
			htmlFormattedTable +=  '<td><span>'+ contractObj.Expiration_Date__c + '</span></td>';
			htmlFormattedTable +=  '<td><span>'+ contractObj.Contract_Status__c + '</span></td>';
			htmlFormattedTable +=  '</tr>';
		}
		htmlFormattedTable += '</table>';
		return htmlFormattedTable;
	}
	
	private static String getHTMLFormattedUpdateErrors(List<PRMLibrary.ErrorDescription> contractsUpdateResult){
		String htmlFormattedTable = '<table border="1">';
				htmlFormattedTable += '<tr>';
				htmlFormattedTable += '<td>Contract Number</td>';
				htmlFormattedTable += '<td>Error Description</td>';
				htmlFormattedTable += '</tr>';

		for(PRMLibrary.ErrorDescription errorObj: contractsUpdateResult){
			htmlFormattedTable +=  '<tr>';
			htmlFormattedTable +=  '<td><span>'+ errorObj.contractNumber + '</span></td>';
			htmlFormattedTable +=  '<td><span>'+ errorObj.errorMessage + '</span></td>';
			htmlFormattedTable +=  '</tr>';
		}
		htmlFormattedTable += '</table>';
		return htmlFormattedTable;
	}

	private static String getHTMLFormattedRenewedErrors(List<String> renewedErrors){
		String htmlFormattedTable = '<table border="1">';
				htmlFormattedTable += '<tr>';
				htmlFormattedTable += '<td>Error Description</td>';
				htmlFormattedTable += '</tr>';

		for(String errorMessage: renewedErrors){
			htmlFormattedTable +=  '<tr>';
			htmlFormattedTable +=  '<td><span>'+ errorMessage + '</span></td>';
			htmlFormattedTable +=  '</tr>';
		}
		htmlFormattedTable += '</table>';
		return htmlFormattedTable;
	}

}