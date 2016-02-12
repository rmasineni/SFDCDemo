public with sharing class MilestoneManagement {
	
	public List<SelectOption> milestoneActions {get;set;}
    public String milestoneAction {get;set;}
    public MilestoneManagement(){
        milestoneActions = new List<SelectOption>();
       // milestoneActions.add(new SelectOption('Upload Milestone Proofs', 'Upload Milestone Proofs'));
        milestoneActions.add(new SelectOption('Upload Milestone Proofs', 'Upload Milestone Proofs'));
       // milestoneActions.add(new SelectOption('Meter Registration', 'Meter Registration'));
        milestoneActions.add(new SelectOption('Meter Registration', 'Meter Registration'));
        milestoneActions.add(new SelectOption('Milestone Preferences', 'Milestone Preferences'));
        milestoneActions.add(new SelectOption('Upload M2 Serial Number', 'Upload M2 Serial Number'));
         milestoneActions.add(new SelectOption('Monitoring Site ID Registration', 'Monitoring Site ID Registration'));
    }
    
    public Pagereference displayMilestoneAction(){
        PageReference pr;
        if(milestoneAction == 'Upload Milestone Proofs (Old)'){
            pr = Page.milestoneProof;
        }else if(milestoneAction == 'Upload Milestone Proofs'){
            pr = Page.ServiceContractMilestoneProof;
        }else if(milestoneAction == 'Upload M2 Serial Number'){
            pr = Page.milestoneM2SlNoFileUpload;
        }else if(milestoneAction == 'Meter Registration (Old)'){
            pr = Page.MeterRegistration;
        }else if(milestoneAction == 'Meter Registration'){
            pr = Page.ServiceContractMeterRegistration;
        }else if(milestoneAction == 'Monitoring Site ID Registration'){
            pr = Page.ServiceContractMonitoringSiteID;
            
        }
        return pr;
    }
    
    static testMethod void testMilestoneManagement() {
        MilestoneManagement milestoneManagementObj = new MilestoneManagement();
        milestoneManagementObj.milestoneAction = 'Upload Milestone Proofs (Old)';
        Pagereference pageRef = milestoneManagementObj.displayMilestoneAction();

        milestoneManagementObj.milestoneAction = 'Upload M2 Serial Number';
        pageRef = milestoneManagementObj.displayMilestoneAction();
        
        milestoneManagementObj.milestoneAction = 'Milestone Preferences';
        pageRef = milestoneManagementObj.displayMilestoneAction();

        milestoneManagementObj.milestoneAction = 'Upload Milestone Proofs';
        pageRef = milestoneManagementObj.displayMilestoneAction();

		milestoneManagementObj.milestoneAction = 'Meter Registration (Old)';
        pageRef = milestoneManagementObj.displayMilestoneAction();
		
		milestoneManagementObj.milestoneAction = 'Meter Registration';
        pageRef = milestoneManagementObj.displayMilestoneAction();       
    }
    
}