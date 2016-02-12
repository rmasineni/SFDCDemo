public class CustomErrorMessages {
	public static String MISSGIN_ALL_REQUIRED_DOCS = 'Warning: All the required documents are missing to submit this proposal';
    public static String MISSGIN_REQUIRED_DOCS = 'Following documents are either missing or require signature to submit this proposal. \n\n';
    public static String REQUIRED_DOCS_NOT_SIGNED = 'Warning: Following required documents are not signed by the recipients. \n\n';
    public static string OPPTY_CLOSED_WON_ERROR = 'Opportunity should have an approved proposal for \'Closed/Won\' stage';
	public static string HYBRID_CHANGEORDER_ERROR = 'The Final Inputs Hybrid ID does not correspond with the original proposal. Submit the Final Inputs Hybrid ID on proposal ';
	public static string HYBRID_CHANGEORDER_ERROR_NULL_PARENT = 'The Final Inputs Hybrid ID should have a parent Id';
	public static string REQUIRED_ESTIMATED_REBATE_AMOUNT = '\'Estimated Rebate Amount\' value is required for this proposal';
    public static string IN_FLIGHT_ERROR = ' esignature for this Document is In Progress. You cannot Upalod at this state.';
	public static string EXISTING_ERROR = ' The Proposal is Under Review, you cannot Overwrite an existing document.';
	public static string SIGNED_EXISTING_ERROR = ' Signed Document is Existing. To Upload , Kindly Delete the Exisitng Document';
	public static string MANDATORY_ERROR = 'The Proposal is Under Review, you cannot Overwrite a Mandatory Document at this stage';
	public static string INVALID_UPLOAD_STAGE = 'Invalid Proposal Stage to Upload Documents';
	public static string EDIT_NOTE = 'Please select/Add a note to Edit ';
	public static string INVALID_CUSTOMER_SIGNOFF_DATE = 'Invalid Customer Signoff date';

	public static string CONTACT_SUNRUN_TO_DELETE_ESIGNED_DOCS = 'Please contact Sunrun to delete eSigned documents';
	public static string FOUND_NO_VALID_OPPORTUNITY = 'This proposal is not associated with a valid Opportunity';
	public static string SUBMITTED_PROPOSAL_SUCCESSFULLY = 'This proposal has been submitted successfully';
	public static string INVALID_PROPOSAL_STAGE_FOR_SUBMISSION = 'The proposal stage is not valid for submission';
	public static string H_TYPE_PROPOSAL_NOT_SUPPORTED = 'The Customer Agreement was sent to the customer on the original proposal. Additional welcome email will not be sent.';
	public static string NOT_AUTHORIZED_USER = 'You are not authorized to submit this proposal';
	public static string REQUIRES_CREDIT_REVIEW = 'Not a valid request. Please submit the proposal for credit review.';	
	//Secondary Contact should be different from the Primary Contact
	//Please select Primary contact
	//Please select Partner Contact
	//eSignature request is in progress. Please Void the current request to proceed further.
	//eSign request is in progress for one OR more of the selected documents and they can\'t be deleted. \n Please modify your selection and resubmit the request.
	//Invalid proposal stage to delete the documents
	//Please select atleast one file for delete
	//Found more than one document with same document types
	//The proposal is under review and one OR more of the selected documents can\'t be deleted. \n Please modify your selection and resubmit the request
	//Invalid Proposal Stage to modify the proposal documents
	//Invalid proposal stage to void this document
	//Invalid proposal stage to delete the documents
	
	//Please select an user action
	//Select a record to void the eSignature request
	//

	//Select a record to resend the eSignature request
	public static string NO_PENDING_ESIGN_REQUESTS = 'No eSign requests are in pending for this record';
	public static string RESEND_NOT_ALLOWED = 'Resend is not allowed for Voided or Completed eSign requests';
	public static string WELCOME_EMAIL_NOT_SUPPORTED = 'This feature is not supported  for Verengo customers';
	public static string WELCOME_EMAILS_FOR_APPROVED_PROPOSALS = 'Welcome email will be sent only for the Approved proposals.';
	public static string INVALID_PROPOSAL = 'Invalid proposal. Please refersh your browser.';
	public static string WELCOME_EMAIL_SENT = 'Welcome email has been sent to ';
	public static string UNABLE_SEND_WELCOME_EMAIL = 'Unable to send the Welcome email. Please verify customer information.';
	public static string MISSING_WELCOME_EMAIL_DOCS = 'Required documents are missing for this proposal';
	public static string MISSING_WELCOME_EMAIL_TEMPLATE = 'Unable to find a valid email template';
	public static string MISSING_WELCOME_CUSTOMER_INFO = 'Unable to find recipient\'s email information';
	public static string MISSING_WELCOME_PARTNER_INFO = 'Unable to find partner\'s email information';
	public static string MISSING_SUNRUN_SIGNATURES = 'Sunrun Operations has not completed the eSignatures. Please review the documents.';
	public static string UNABLE_TO_PROCESS_E_SIGN_REQUEST = 'Salesforce is unable to process the eSign request. Please contact ' + Label.SunrunHelpdeskEmail;
	public static string MAXIMUM_REQUEST_SIZE = 'File size has exceeded the maximum limit. Please upload file size 2MB or smaller.';
	public static string UNABLE_TO_PROCESS_YOUR_REQUEST = 'Salesforce is unable to process your request. Please contact ' + Label.SunrunHelpdeskEmail;
	public static string MINIMUM_SEARCH_STRING = 'Your search term must have 2 or more characters.';	
	public static string NO_PENDING_E_SIGN_REQUESTS = 'No eSign requests are in pending for this record';
	public static string UNABLE_TO_RESEND_ENVELOP = 'Salesforce is unable to resend the eSignature request. Please contact ' + Label.SunrunHelpdeskEmail;
	public static string SFDC_SYSTEM_ERROR = 'Salesforce is unable process your request. Please contact ' + Label.SunrunHelpdeskEmail;
	public static string INVALID_PARTNER_DATA = 'Invalid Partner selection. Please contact ' + Label.SunrunHelpdeskEmail;
	public static string INVALID_CUSTOMER_DATA = 'Invalid Customer selection. Please contact ' + Label.SunrunHelpdeskEmail;
	public static string INACTIVE_SUBMITTED_PARTNER = 'Submitted partner is not active. Please modify submitted by partner details for this proposal.';
	public static string INVALID_CREDIT_STATUS = 'This proposal doesn\'t have valid credit status. Please submit the proposal to finance team for review.';
	public static string UNABLE_TO_SEND_WELCOME_EMAIL = 'Salesforce is unable to send the Welcome email. Please contact the Salesforce administrator.'; 
	public static string ALREADY_REVIWED_BY_SUNRUN_OPS = 'This proposal has already been reviewed by Sunrun operations.'; 
	public static string APPROVED_PROPOSAL_STAGE = 'This is an approved proposal and you are not allowed to modify the proposal stage.'; 
	public static string SIGNED_BY_ALL_RECIPIENTS = 'This document is signed by all the recipients and it can not be voided. Please contact ' + Label.SunrunHelpdeskEmail;
	public static string REQUIRES_LARGE_SYSTEM_CHECKS = 'For proposals in Connecticut or System Size STC DC greater than or equal to 15 or Utility LADWP, System Size should be validated by SR Ops before setting stage to SR Ops Reviewed.';
	public static string WELCOME_EMAIL_ALREADY_SENT = 'Welcome email has already been sent to this customer';
	public static string SAME_ORGINAL_AND_REVISED_PROPOSALS = 'Original and revised proposal are same. Please select a different proposal.';
	public static string SELECT_EDP_PHASE = 'Select EDP Phase for this proposal';
	public static string NOT_ALLOWED_TO_WITHDRAW = 'You are not allowed to withdraw the proposal from current stage';
	public static string NOT_ALLOWED_TO_WITHDRAW_IN_PENDING = 'Please close all pending tasks associated with this proposal before withdrawing it.';
	public static string UNABLE_TO_ADD_CONTACT_TO_PROPOSAL = 'Maximum three Contacts can be added to the Proposal. Please contact ' + Label.SunrunHelpdeskEmail;
	public static string CUSTOMER_CREDIT_REPORT_DOES_NOT_BELONG_TO_PROPOSAL = 'This credit report doesn\'t belong to the customers on this proposal.';
	public static string MISSING_REQUIRED_TABS = 'Sunrun has recently updated this document. Please re-generate this document and initiate eSignatures for this proposal.';
	public static string DOCUSIGN_MISSING_TAB_ERROR = 'ANCHOR_TAB_STRING_NOT_FOUND';
	public static string eSignature_ERROR(String newDocuTypeName){
		String errMsg = '';
		errMsg = 'Either Sunrun has counter signed or e-signature of ' +  newDocuTypeName + ' is in progress. You can not upload new ' + newDocuTypeName +' at this time.';
		return errMsg;
	}
	
	public static string S3_MaximumSizeError = 'Exceeded max size limit of';
	public static string UNABLE_TO_DOWN_LOAD_FILES = 'Unable to download documents from file server';
	public static string MAXIMUM_FILE_SIZE_TO_DOWNLOAD = 'The Customer Agreement file size exceeds the system limit. Please download the file, and send the Welcome Email through the Gen Asset as in EDP0.';
	public static string IN_PERSON_ERROR = 'In-person signature is allowed only for partner users';
	public static string SELECT_PRIMARY_CONTACT = 'Please select Primary contact';
	public static string SELECT_PARTNER_CONTACT = 'Please select Partner Contact';
	public static string MISSING_UTILITY_BILL = 'If this is a revised proposal and utility bill is uploaded on original proposal, please update the Revised Proposal checkbox.';
	public static string MISSING_LIVING_SPACE = 'If this is a revised proposal and Living Space Square Footage is uploaded on original proposal, please update the Revised Proposal checkbox.';
	public static string MONTHLY_BILL_ERROR = 'Solar systems are not buildable when usage is estimated from average monthly bill. Please create a proposal with each month\'s usage in order to submit.';	
	public static string NULL_EMAIL = 'Customer email address is required to initiate esignature.';	
	//public static string PO_ERROR = 'Retail PO# is required to submit the Proposal.';
    public static string EXPIRED_ERROR = 'Expired Proposals Cannot be modified.';
    public static string PARTNER_CASH_COBF_ERROR = 'Please only submit Monthly or Prepaid proposal to Sunrun'; 
    public static string MAX_LOAN_AMT_ERROR = 'Required Loan Amount is more than Maximum Loan Amount'; 
	
}