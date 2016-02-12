global class ManagingPartnerAVLUrl {
    webservice static string getAVLUrl(id acctId,string function){
        Map<id,RecordType> rcIds=new Map<id,Recordtype>([select id from recordtype where sobjecttype='Account' and name in ('Company','Partner')]);
        Account acc=[select Name,Account_Number__c,recordtypeid from account where id=:acctid];
        if(!rcIds.keySet().contains(acc.recordtypeid)){
            return 'Failure';
        }
        String Authorities=EDPUtil.getAccessRights();
        if(function=='ManagingPartnerAVLCosts'&&!Authorities.contains('ManagingPartnerAVLCosts')){
            return 'You are not eligible to manage AVL Costs';
        }
        if(function=='ManagingPartnerAVLPrices'&&!Authorities.contains('ManagingPartnerAVLPrices')){
            return 'You are not eligible to manage AVL Prices';
        }
        String designToolSecretKey = Label.Design_Tool_Secret_Key;      
        String baseURL = EDPUtil.getBaseURL();
        String designToolFromPartnerPortal = Label.Design_Tool_From_PartnerPortal;
        String designToolFromSalesforce = Label.Design_Tool_From_Salesforce;        
        User userObj = PRMContactUtil.getLoginUser(); 
        String designToolBaseURL = (userObj.contactId != null) ? designToolFromPartnerPortal : designToolFromSalesforce;
        String designToolUserId = userObj.email;
        String returnURL =(userObj.contactId != null) ? EDPUtil.getBaseURL() +'/apex/PRMContactSearch': EDPUtil.getBaseURL() + '/' + acctId;
        Long Lexpires = SunRunS3RestConnection.getExpirationTime();                                  
        String   canonicalStr = 'partnerId=' + acc.Account_Number__c + '&expires=' + Lexpires + '&userId=' + EncodingUtil.urlEncode(designToolUserId,'UTF-8')+'&function='+function+'&authorities='+authorities;
        String signed = SunRunS3RestConnection.make_sunrunProxysig(canonicalStr, designToolSecretKey);
        String codedsigned = EncodingUtil.urlEncode(signed,'UTF-8');           
        String url=designToolBaseURL + '?' + canonicalStr + '&signature=' + codedsigned + '&returnUrl=' + returnURL +'&partnerName='+acc.name;
        return url;         
    }
}