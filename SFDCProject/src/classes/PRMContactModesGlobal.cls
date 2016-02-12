global class PRMContactModesGlobal {
	webService static void sendContactModesToProposalTool(String contactId){
		PRMContactModes prmContactModes = new PRMContactModes();
		prmContactModes.sendContactModesToProposalTool(contactId, true);		
		return;
	}
}