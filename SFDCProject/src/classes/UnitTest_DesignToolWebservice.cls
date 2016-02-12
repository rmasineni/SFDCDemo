@istest(SeeAllData=true)
private with sharing class UnitTest_DesignToolWebservice {
  static testMethod void UnitTest_DesignToolWebservice(){
    DesignToolWebservice.getDesignToolURL('objectId', 'prospectId', 'Lead');
    DesignToolWebservice.getModifyProposalURL('objectId');
    DesignToolWebservice.getModifyProposalURLForOpty('objectId');
  }
  }