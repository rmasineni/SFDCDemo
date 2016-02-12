public class InContactService {
    
    public static InContactResponse parse(String jsonstring){
        return (InContactResponse) System.JSON.deserialize(jsonstring, InContactResponse.class);
    }
    public static InContactToken tokenParse(String jsonstring){
        return (InContactToken) System.JSON.deserialize(jsonstring, InContactToken.class);
    }
    
    @future(callout=true)
    public static void processInContactListUpload(string JsonString ){
        InContactToken contactToken = new InContactToken();
         App_Log__c log = new App_Log__c();
        InContactResponse InContactRes= new InContactResponse();        
        system.debug('JsonString' +JsonString);
        integer skillID=integer.valueOf(Label.InContactSkillID);
        string fileName =Label.InContactFileName;
        boolean forceOverWrite=true;
        String Base64ListFile = EncodingUtil.base64Encode(Blob.valueof(JsonString));
        string ListID = Label.InContactListID; 
        httpResponse response = new httpResponse();
        response=getTokenInfo();
        contactToken =  tokenParse(response.getBody());
        system.debug('contactToken>>' +  contactToken.access_token);
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndpoint(contactToken.resource_server_base_uri+'services/v6.0/lists/call-lists/'+ ListID +'/upload');
        req.setHeader('Authorization', 'bearer '  + contactToken.access_token);
        req.setHeader('Accept', '*/*');
        req.setBody('listFile='+ Base64ListFile +
                    '&skillId='+ skillID +
                    '&fileName='+ fileName +
                    '&forceOverwrite='+ forceOverWrite);
        HTTPResponse res  =null;
        
        system.debug('getBody>' +  req.getBody());
        system.debug('contactToken>>' +  contactToken.access_token);
        try{
            Http http = new Http();
            res = http.send(req);
            system.debug('res.getBody()' +  res.getBody());
            InContactRes =IncontactService.parse(res.getBody());
            
            log.System__c ='InContactAPI';
            log.Sobject__c='Lead';
            log.Module__c='InContact Upload List- 4811';
            if(InContactRes!=null){
                if(InContactRes.resultSet.validRecords!='0' && InContactRes.resultSet.invalidRecords!='0'){
                    log.Type__c ='Partial Success';
                }
                else if (InContactRes.resultSet.validRecords!='0' && InContactRes.resultSet.invalidRecords=='0'){
                    log.Type__c ='Success';
                }else{
                    log.Type__c ='Failure';
                }
            }else {
                log.Type__c = 'No Response'; 
            }
            log.Details__c= JsonString; 
            string requestbody = 'listFile='+ Base64ListFile.substring(0,180)+'\n'+ Base64ListFile.substring(181,360) +'\n'+ Base64ListFile.substring(361,Base64ListFile.length()) +'\n'+'skillId='+ skillID+'fileName='+ fileName +'forceOverwrite='+ forceOverWrite;
            log.Details2__c=res.getBody();
            log.Details5__c=requestbody;
            log.Action__c='Lead_Consolidated_Trigger';
        }
        catch(Exception ex){
             log.Details2__c=res.getBody(); 
             log.Details__c= ex.getMessage();
             log.Details5__c=JsonString;
        }
        insert log; 
        
    }
    
    
    public static void InConatctList(List<LeadFilterClass> LeadList){
        string jsonstring='';
        jsonstring =createCSV(LeadList);
        processInContactListUpload(jsonstring);
    }
    //create CSV format of content
    public static string  createCSV(List<LeadFilterClass> LeadList){
      String s ='Lead_Id_18__c,Phone,State,Custom_Lead_Source__c,Lead_Type__c,';
        s+= 'Dial_Status__c,Future_Contact_Date_Time__c,FirstName,LastName,';
        s+= 'PostalCode,Campaign_Call_Attempts__c,Priority__c,Voicemail__c,Caller_ID__c';   //,RecordPriority';
       
        for(LeadFilterClass lead : LeadList) {
            string phone='';
            if( lead.Phone!='' &&  lead.Phone!=null) 
                 phone =lead.Phone.replaceAll('\\W', '');
         
            s+='\n'+lead.Lead_Id_18+','+ phone +','+lead.State+','+lead.Lead_Source +',';
            s+= lead.Lead_Type+','+ lead.Dial_Status+','+ lead.Future_Contact_Date_Time.format('M/d/yyyy h:mm') +',' ;
            s+= lead.FirstName+','+ lead.LastName+','+ lead.PostalCode+',' +lead.Campaign_Call_Attempts+',';
            s+= lead.InContact_Priority+ ',' ;
            s+= lead.voicemail +','+ lead.Caller_ID;
            
        }        
        return s;
    }
  
    public static HTTPResponse getTokenInfo(){
        string endPointUrl = Label.InContactTokenEndPointUrl;
        string authorizationID = Label.InContactAPIAuthorizationCode;
        string userName = Label.InContactAPIUser;
        string Password = Label.InContactAPIPassword;
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndpoint(endPointUrl);
        //   req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization',authorizationID);
        system.debug('authorizationID' +  authorizationID);
        system.debug('endPointUrl' +  endPointUrl);
        system.debug('endPointUrl' +  username);
        system.debug('endPointUrl' +  password);
        req.setBody('grant_type=password' +
                    '&username=' + EncodingUtil.urlEncode(username, 'UTF-8') +
                    '&password=' + EncodingUtil.urlEncode(password, 'UTF-8') +
                    '&scope='+'');
        Http http = new Http();
        HTTPResponse res = http.send(req);
        system.debug('req' +  req.getBody());
        System.debug('BODY: '+res.getBody());
        // System.debug('STATUS:'+res.getStatus());
        //System.debug('STATUS_CODE:'+res.getStatusCode());
        //JSONParser parser = JSON.createParser(res.getBody());
        //InContactToken contactToken = new InContactToken();
        //contactToken =  (InContactToken)parser.readValueAs(InContactToken.class);
        //return contactToken;
        return res;
    }
    
    public class LeadFilterClass
    { 
        public string Phone;	
        public string State;	
        public string Lead_Source;
        public string Lead_Type;
        public string Dial_Status;	
        public datetime Future_Contact_Date_Time;
        public string FirstName;
        public string LastName;
        public string PostalCode;
        public decimal Campaign_Call_Attempts;
        public boolean InContact_Priority;	
        public string Voicemail;
        public string Caller_ID;
        public string  Lead_Id_18;
    }
    
    
    public class InContactToken{
        public string access_token;
        public string token_type;
        public integer expires_in;
        public string refresh_token;
        public string scope;
        public string resource_server_base_uri;
        public string refresh_token_server_uri;
        public long agent_id;
        public long team_id;
        public long bus_no;
    }
    
    public class InContactResponse{
        public InContactresultSet resultSet;
    }
    public class InContactresultSet {
        public String listId;	//4811
        public String importStatus;	//true
        public String procRecords;	//1
        public String validRecords;	//0
        public String invalidRecords;	//1
        //public  String  errorResults;
    }
   
}