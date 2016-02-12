public class CoreLogicCallouts {
    
    public static CoreLogicFromJsonResponse authKeyMethod(){
        
        http p = new http();
        httprequest req = new httprequest();
        String EndPoint = label.CoreLogic; 
        req.setEndpoint(Endpoint);
        req.setMethod('POST');
        req.setHeader('Content-Type','application/json');
        string Body = '{"username":'+Label.CoreLogic_APIUserName+',"password":'+Label.CoreLogic_APIPassword+'}'; 
        req.setBody(body);
        httpresponse res = new httpresponse();
        res = p.send(req);
        string response = res.getBody();
        string CoreLogicResponse = null;
        system.debug('Response :'+res.getBody());
        system.debug('Response Status Code : ' +res.getStatuscode()); 
        if(res.getStatuscode()!=200)
        {
           try{    
                CoreLogicErrorfromJSON Err = (CoreLogicErrorfromJSON) System.JSON.deserialize(response, CoreLogicErrorfromJSON.class);
                Sunrun_Error_Message__c sr = new Sunrun_Error_Message__c();
                sr.Error_Code__c = String.valueOf(Err.errors[0].code);
                sr.Error_Description__c = Err.errors[0].documentationUrl;
                sr.Error_Message__c = Err.errors[0].message;
                Insert sr;   
            }catch(Exception e){
                System.debug('Exception in authKeyMethod---->1');
                System.debug('Exception : ' +e);
            }
        }
        else
        {
            try{
                CoreLogicFromJsonResponse f = new CoreLogicFromJsonResponse();
                f=(CoreLogicFromJsonResponse) System.JSON.deserialize(response, CoreLogicFromJsonResponse.class);
                system.debug('Auth Key :'+f.authkey);
                return f;   
            }catch(Exception e){
                System.debug('Exception in authKeyMethod---->2');  
                System.debug('Exception : ' +e);
            }    
        }
        return null;
    }
    
    public static CoreLogicSecondResponse corelogicSecondCallout(string latitude,string longitude, string authKey)
    {
        http p = new http();
        httpresponse res = new httpresponse();
        httprequest req = new httprequest();
        String Endpoint1 = Label.CoreLogic_Response+'lat='+latitude+'&lon='+longitude+'&pageNumber=1&pageSize=4&bundle=SpatialRecordUTPro&authKey='+authkey;
        req.setEndpoint(Endpoint1);    
        req.setMethod('GET');
        req.setHeader('Content-Type','application/json');
        req.setTimeout(60000);
        string CoreLogicResponse ;
        try
        {
            res = p.send(req);
            CoreLogicResponse = res.getBody();
        } 
        Catch(system.CalloutException e)
        {
            Sunrun_Error_Message__c sr = new Sunrun_Error_Message__c();
            sr.Error_Code__c = String.valueOf(res.getStatusCode());
            sr.Error_Description__c = String.valueOf(e.getCause ());
            sr.Error_Message__c = e.getMessage();
            Insert sr;
            return null; 
        }
        Catch(Exception e){
            System.debug('Exception in corelogicSecondCallout---->1');
            System.debug('Exception : ' +e);
            return null;
        }
        system.debug('CoreLogicResponse :'+ CoreLogicResponse);
        
        CoreLogicSecondResponse f1 = new CoreLogicSecondResponse();
        if(CoreLogicResponse!=null)
        {
            try{
                f1=(CoreLogicSecondResponse) System.JSON.deserialize(CoreLogicResponse, CoreLogicSecondResponse.class);
                return f1;
            }Catch(Exception e){
                System.debug('Exception in corelogicSecondCallout---->2');
                System.debug('Exception : ' +e);
            }
        }           
        return null;  
    }
    
    public static CoreLogicThirdResponse CorelogicThirdCallout ( string latitude, string longitude , string authkey){
        http p = new http();
        httpresponse res = new httpresponse();
        httprequest req = new httprequest();
        String Endpoint2 = Label.CoreLogic_Response1+'lat='+latitude+'&lon='+longitude+'&include=GeneralPropertyTax&authKey='+authkey;
        req.setEndpoint(Endpoint2);
        req.setMethod('GET');
        req.setHeader('Content-Type','application/json');
        req.setTimeout(60000);
        string CoreLogicResponse1 ;
        try
        {
            res = p.send(req);
            CoreLogicResponse1 = res.getBody();
        }
        Catch(system.CalloutException e) 
        {
            Sunrun_Error_Message__c sr = new Sunrun_Error_Message__c();
            sr.Error_Code__c = String.valueOf(res.getStatusCode());
            sr.Error_Description__c = String.valueOf(e.getCause());
            sr.Error_Message__c = e.getMessage();
            Insert sr;
            return null;
        }
        Catch(Exception e){
            System.debug('Exception in CorelogicThirdCallout---->1');
            System.debug('Exception : ' +e);
            return null;
        }
        system.debug('CoreLogicResponse1 :'+ CoreLogicResponse1);
        
        CoreLogicThirdResponse f2 = new CoreLogicThirdResponse();
        if (CoreLogicResponse1 != null){
            try{
                f2 = (CoreLogicThirdResponse) System.JSON.deserialize(CoreLogicResponse1, CoreLogicThirdResponse.class);
                return f2 ;
            } 
            Catch(Exception e){
                System.debug('Exception in CorelogicThirdCallout---->2');
                System.debug('Exception : ' +e);
            }
        }
        return null ;
    }
    
    public static void enrichAccounts(List<Account> acclist){
        String PrimaryTitleFirst ;
        String PrimaryTitleSecond ;
        String SecondaryTitleFirst;
        String SecondaryTitleSecond ;
        Map <Id,Account> AccountMap = new Map <Id,Account>();
        Map<Id,Id> OpportunityMap = new Map<Id,Id>();
        for (Account acctemp : acclist) {
            
            /* if (acctemp.Address_Standardization_Status__c != AddressServiceDto.Status_Standardized ){
                   continue;
                   }*/
            
            
            if(!acctemp.Core_Logic_Override__c){
                if (acctemp.Latitude__c !=null  && acctemp.Longitude__c!=null){
                    system.debug('Lat is ' + String.valueof(acctemp.Latitude__c)+' and Long is ' + String.valueof(acctemp.Longitude__c));
                    try {
                        CoreLogicFromJsonResponse cfr   = CoreLogicCallouts.authKeyMethod();
                        CoreLogicSecondResponse csr     = CoreLogicCallouts.corelogicSecondCallout(String.valueof(acctemp.Latitude__c),String.valueof(acctemp.Longitude__c),String.valueof(cfr.authkey));
                        CoreLogicThirdResponse ctr     = CoreLogicCallouts.CorelogicThirdCallout(String.valueof(acctemp.Latitude__c),String.valueof(acctemp.Longitude__c),String.valueof(cfr.authkey));
                        boolean flag = csr!=null?true:false;
                        boolean SecondFlag = ctr!=null?true:false;
                        integer sizeoflist = csr.parcels.size();
                        boolean sizef = sizeoflist>0?true:false;
                        
                        system.debug('Flag:'+Flag);
                        if(flag && sizef)
                        {   
                            PrimaryTitleFirst  =  csr.parcels[0].OWN1_FRST==null?'':csr.parcels[0].OWN1_FRST;
                            PrimaryTitleSecond = csr.parcels[0].OWN1_LAST==null?'':csr.parcels[0].OWN1_LAST;
                            acctemp.Primary_Title__c     = PrimaryTitleFirst +' '+PrimaryTitleSecond;
                            SecondaryTitleFirst =  csr.parcels[0].OWN2_FRST==null?'':csr.parcels[0].OWN2_FRST;
                            SecondaryTitleSecond = csr.parcels[0].OWN2_LAST== null?'':csr.parcels[0].OWN2_LAST;
                            acctemp.Secondary_Title__c   = SecondaryTitleFirst +' '+SecondaryTitleSecond;
                            acctemp.Land_Use__c          = csr.parcels[0].LAND_USE;
                            acctemp.Legal_Description__c = csr.parcels[0].LEGAL1==null?'null':csr.parcels[0].LEGAL1;
                            
                            
                        }
                        if(SecondFlag){
                            if (ctr.AdminLocation != null){
                                acctemp.Incorporation_Flag__c = (ctr.AdminLocation.incorporationFlag == null || ctr.AdminLocation.incorporationFlag == '')?'null': ctr.AdminLocation.incorporationFlag ;
                                if (ctr.AdminLocation.incorporationFlag == '1'){
                                   acctemp.Incorporation_Flag__c = 'Yes';
                                }
                                else if (ctr.AdminLocation.incorporationFlag =='0'){
                                   acctemp.Incorporation_Flag__c = 'No';
                                }
                                acctemp.City_Type__c = (ctr.AdminLocation.cityType == null || ctr.AdminLocation.cityType == '')?'null': ctr.AdminLocation.cityType ;
                            }
                            else{
                                acctemp.Incorporation_Flag__c = null;
                                acctemp.City_Type__c          = null;
                            }
                        }
                    }
                    
                    catch (system.JSONException e){
                        
                    //    throw e;
                        System.debug('JSONException : ' +e); 
                        acctemp.Primary_Title__c      = null;
                        acctemp.Secondary_Title__c    = null;
                        acctemp.Land_Use__c           = null;
                        acctemp.Legal_Description__c  = null;
                        acctemp.Incorporation_Flag__c = null;
                        acctemp.City_Type__c          = null;
                    }
                    catch (Exception e){
                        System.debug('Exception : ' +e); 
                        acctemp.Primary_Title__c      = null;
                        acctemp.Secondary_Title__c    = null;
                        acctemp.Land_Use__c           = null;
                        acctemp.Legal_Description__c  = null;
                        acctemp.Incorporation_Flag__c = null;
                        acctemp.City_Type__c          = null;                        
                    }                    
                }
                else {
                    acctemp.Primary_Title__c      = null;
                    acctemp.Secondary_Title__c    = null;
                    acctemp.Land_Use__c           = null;
                    acctemp.Legal_Description__c  = null;
                    acctemp.Incorporation_Flag__c = null;
                    acctemp.City_Type__c          = null;
                }
            }
            AccountMap.put(acctemp.Id, acctemp); 
        }
        List <Opportunity> OppList =  [ Select id,AccountId from Opportunity where AccountId IN : AccountMap.keySet() ];
        if (!OppList.isEmpty()){
            for (Opportunity opptemp : OppList){
                OpportunityMap.put(opptemp.Id, opptemp.AccountId);
            }
        }
        List <Proposal__c> PropList =  [ Select id,Name_on_title__c,Opportunity__c from Proposal__c where Opportunity__c IN : OpportunityMap.keySet() ];
        if (!PropList.isEmpty()){
            for (Proposal__c proptemp: PropList){
                String PrimaryTitle = Accountmap.get(OpportunityMap.get(proptemp.Opportunity__c)).Primary_title__c;
                String SecondaryTitle = Accountmap.get(OpportunityMap.get(proptemp.Opportunity__c)).Secondary_title__c;
                if (String.isNotBlank(PrimaryTitle) && String.isNotBlank(SecondaryTitle)){
                    proptemp.Name_on_title__c = PrimaryTitle +','+' '+ SecondaryTitle;
                    system.debug('CombinedTitle  '+proptemp.Name_on_title__c);
                }
                if (String.isBlank(PrimaryTitle) && String.isNotBlank(SecondaryTitle)){
                    proptemp.Name_on_title__c = SecondaryTitle;
                    system.debug('PropSecondaryTitle is  '+proptemp.Name_on_title__c);
                }
                if (String.isNotBlank(PrimaryTitle) && String.isBlank(SecondaryTitle)){
                    proptemp.Name_on_title__c = PrimaryTitle;
                    system.debug('PropPrimaryTitle is  '+proptemp.Name_on_title__c);
                } 
            }
            update propList;
        }
    }    
}