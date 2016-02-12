@IsTest(seealldata=true)
public class CreditCheckApiTest {
    private static void creditCheck(string prospectId, string contactId,boolean IsTest){
        Test.startTest();
        RestContext.request  = new RestRequest();
        RestContext.response  = new RestResponse();
        RestContext.request.requestURI='/services/apexrest/v2/creditCheck?debug=true';
        RestContext.request.httpMethod='GET';
        if(IsTest){
              RestContext.request.addparameter('testMode','1');   
        }
        else{
        RestContext.request.addparameter('prospectId',prospectId);   
        RestContext.request.addparameter('contactId',contactId); 
        }
        CreditCheckApiEndpoint.httpGet();
        Test.stopTest();
    }
    
    testmethod public static void testProposalWithContactActions(){
        Opportunity Opportunity =[select Prospect_Id__c ,id from Opportunity limit 1 ];
        contact contact =[select id from contact limit 1 ];
        creditCheck(Opportunity.Prospect_Id__c,contact.id,false);
        
    }
    testmethod public static void testProposalWithNoContactActions(){
        Opportunity Opportunity =[select Prospect_Id__c ,id from Opportunity limit 1 ];
        contact contact =[select id from contact limit 1 ];
        creditCheck(Opportunity.Prospect_Id__c,'',false);
        
    }
     testmethod public static void testProposaltestActions(){
        creditCheck('','',true);
        
    }
}