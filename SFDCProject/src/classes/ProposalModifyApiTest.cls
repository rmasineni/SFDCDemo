@IsTest(seealldata=true)
public class ProposalModifyApiTest {
    
    private static void proposalAction(string action, string proposalName,boolean IsTest){
        Test.startTest();
        RestContext.request  = new RestRequest();
        RestContext.response  = new RestResponse();
        RestContext.request.requestURI='/services/apexrest/v2/modifyProposal?debug=true';
        string str ='{ "action":';
        str+='"' + action+'",';
        str+= '"proposalName":';
        str+= '"'+ proposalName + '"' ;
        str+='}';
          if(IsTest){
              RestContext.request.requestBody=Blob.valueOf('{"testMode": "1"}');   
        }
        else{
            RestContext.request.requestBody = Blob.valueOf(str);
        }
        ProposalApiModifyEndpoint.httpPatch();
        Test.stopTest();
    }
    
    testmethod public static void testProposalActions(){
        Proposal__c proposal =[select name ,id from Proposal__c where stage__c='created' limit 1 ];
        proposalAction('submit',proposal.Name,false);
        
    }
    
    testmethod public static void testVoidProposal(){
        Proposal__c proposal =[select name ,id from Proposal__c where stage__c='created' limit 1 ];
        proposalAction('void',proposal.Name,false);
    }
    
    testmethod public static void testWarnProposal(){
        Proposal__c proposal =[select name ,id from Proposal__c where stage__c='created' and Agreement_Type__c ='Customer Owned - Full Upfront' and Finance_Type__c != 'N/A' and Finance_Type__c != 'Bank Financed' limit 1 ];
        proposalAction('submit',proposal.Name,false);
    }
    testmethod public static void testSRApprovedProposal(){
        Proposal__c proposal =[select name ,id from Proposal__c where stage__c='SR Ops Received'  limit 1 ];
        proposalAction('submit',proposal.Name,false);
    }
    
    testmethod public static void testVoidedProposal(){
        Proposal__c proposal =[select name ,id from Proposal__c where stage__c='Voided'  limit 1 ];
        proposalAction('void',proposal.Name,false);
    }
    
    testmethod public static void testInactiveProposal(){
        Proposal__c proposal =[select name ,id from Proposal__c where stage__c='Inactive'  limit 1 ];
        proposalAction('void',proposal.Name,false);
    }
    
    testmethod public static void testActionParam(){
        Proposal__c proposal =[select name ,id from Proposal__c where stage__c='Inactive'  limit 1 ];
        proposalAction('test',proposal.Name,false);
    }
    
    testmethod public static void testSubmitInvalid(){
        Proposal__c proposal =[select name ,id from Proposal__c where stage__c='Inactive'  limit 1 ];
        proposalAction('submit',proposal.Name,false);
    }
     testmethod public static void testApi(){
        
        proposalAction('','',true);
    }
}