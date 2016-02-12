/**********************************************************************************************************
 User Story: BSKY-6792
 1) As a sales or operations user, when I update a the Opportunity Stage from 8 or 9 
 back to stage 1-4, then the WFM Project status is updated from Cancelled to Open.
 
 2) As an operations user, when I update the Service Contract Status from Deal Cancelled 
 or Cancellation in Progress to an active status, then the WFM Project's status is updated from Cancelled to Open
***********************************************************************************************************/
public class ProjectStatusUpdateClass{
public static void OpptyProjectStatUpdate(Map<Id,Opportunity> OpptyMap)
    {
        List<Project__c> ProjectList = new List<Project__c> ();
        List<Project__c> ProjectStatList = new List<Project__c>();
        if(!OpptyMap.isEmpty()){
        ProjectList = [select Id,Status__c,Opportunity__c from Project__c  where Opportunity__c IN:OpptyMap.keyset() and Status__c ='Cancelled' ];
        }
        system.debug('Project list details--->'+ProjectList);
        if(ProjectList.size()>0)
        {
            for(Project__c pr:ProjectList)
            {
                pr.Status__c = 'Open';
                ProjectStatList.add(pr);
            } 
        }
        if(ProjectStatList.size()>0)
        {
        update ProjectStatList;
        }
    }

public static void ScProjectStatUpdate(Map<Id,ServiceContract> ServiceContractMap)
    {
        List<Project__c> ScProjectList = new List<Project__c> ();
        List<Project__c> ScProjectStatList = new List<Project__c>();
        if(!ServiceContractMap.isEmpty())
            {
            ScProjectList = [select Id,Status__c,Service_Contract__c from Project__c where Service_Contract__c IN:ServiceContractMap.keyset() and Status__c ='Cancelled'];
            }
            system.debug('Service contract Project list details--->'+ScProjectList);
            
            if(ScProjectList.size()>0)
            {
             for(Project__c pr:ScProjectList)
                {
                pr.Status__c = 'Open';
                ScProjectStatList.add(pr);
                } 
            }
             if(ScProjectStatList.size()>0)
                {
                update ScProjectStatList;
                }
            
    }
}