trigger trg_case_before_upd_ins on Case (before update) {

	Boolean skipValidations = false;
	skipValidations = SkipTriggerValidation.performTriggerValidations();
	if(skipValidations == false){

	  for (Integer intPos = 0; intPos < Trigger.new.size(); intPos++)
	    {
	        Case newRec = Trigger.new[intPos];
	//        if (Trigger.new[intPos].Account_Manager_Email__c != null && Trigger.new[intPos].Account_Manager_Email__c != '')
	//            {                
	//                Trigger.new[intPos].Email_Address_of_Account_Manager__c = Trigger.new[intPos].Account_Manager_Email__c;
	//            }
	        if (( Trigger.isUpdate && (newRec.Status != Trigger.old[intPos].Status)))
	        {
	           Trigger.new[intPos].Status_Updated__c = true;
	        }
	        else if(Trigger.isUpdate && (newRec.Status == Trigger.old[intPos].Status))
	        {
	       	 Trigger.new[intPos].Status_Updated__c = false;
	        }
	        
	        if(Trigger.new[intPos].ClosedDate <> null 
	           && Trigger.new[intPos].Case_M3_PTO__c == null 
	           && Trigger.new[intPos].Milestone_Proof_Type__c == 'M3 Proof')
	        {
	        	Trigger.new[intPos].AddError('To close an M3 Proof, a PTO date must be entered.');
	        }
	        
	    }
	}
}