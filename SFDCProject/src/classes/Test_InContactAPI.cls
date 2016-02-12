@isTest(seealldata=true)
public  class Test_InContactAPI 
{
    public static testmethod void testInContacttoken(){
        List<InContactService.LeadFilterClass> leadFilterList= new List<InContactService.LeadFilterClass>();
        InContactService.LeadFilterClass lfList = new InContactService.LeadFilterClass();
        
        List<Lead> leadList = [select Id,Lead_Id_18__c,phone,state,Custom_Lead_Source__c,Lead_Type__c,
                               Dial_Status__c,Future_Contact_Date_Time__c,FirstName,LastName,
                               PostalCode,Campaign_Call_Attempts__c,Voicemail__c,Caller_ID__c
                               from lead where channel__c='3rd Party'and lead_type__c!=''   limit 1];
        Test.startTest();
        lfList.Lead_Id_18= leadList[0].lead_id_18__c;
        lfList.Phone= '(408) 567-9800';
        lfList.State=leadList[0].State;
        lfList.Lead_Source=  '3rd Party: B Green';
        lfList.Lead_Type=  'Exclusive';
        lfList.Dial_Status=  leadList[0].Dial_Status__c;
        lfList.Future_Contact_Date_Time=leadList[0].Future_Contact_Date_Time__c;
        lfList.FirstName=leadList[0].FirstName;
        lfList.LastName= leadList[0].LastName;
        lfList.PostalCode= leadList[0].PostalCode;
        lfList.Campaign_Call_Attempts= leadList[0].Campaign_Call_Attempts__c;
        lfList.InContact_Priority=true;
        lfList.Voicemail= leadList[0].Voicemail__c;
        lfList.Caller_ID= leadList[0].Caller_ID__c;
        leadFilterList.add(lfList);
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseInContactToken());  
        try{
           
            InContactService.createCSV(leadFilterList); 
            InContactService.getTokenInfo();
        }
        catch(exception e){}
        Test.stopTest();
    }
    
    public static testmethod void testInContactAPI(){
        
        string jsonstring ='Lead_Id_18__c,Phone,State,Custom_Lead_Source__c,Lead_Type__c,Dial_Status__c,Future_Contact_Date_Time__c,FirstName,LastName,PostalCode,Campaign_Call_Attempts__c,Priority__c,Voicemail__c,Caller_ID__c';
        jsonstring+='\n'+'00Q55000001vhNAEAY,(408) 567-9800,CA,3rd Party: B Green,Exclusive,READY,12/23/2015 10:23,Test Object,Objetcs Test AEE,94132,1,true,General,800#';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseInContact());  
        try{
            // InContactService.InConatctList(leadFilterList); 
           InContactService.processInContactListUpload(jsonstring);
        }
        catch(exception e){}
        Test.stopTest();
    }
    
    
}