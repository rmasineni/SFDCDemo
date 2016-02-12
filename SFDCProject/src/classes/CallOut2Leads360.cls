global class CallOut2Leads360
{
    public static String sendLead(String leadId)
    {
        Lead leadRec = [Select Name,FirstName, LastName, Company,lead_status__c
            ,Street,City,Country,State,PostalCode
            ,Phone, Alternate_Phone__c , MobilePhone, Email 
            ,Zip_6__c, Homeowner_Email__c, Site_Visit_Date_Time__c
            ,Utility_Company__c,Monthly_Electricity_Bill__c
            ,Other_decision_maker__c, Motivation_to_go_solar__c
            ,Roofing_Type__c, Age_of_Roof__c, Roof_Azimuth__c,Notes__c
            ,Online_map_accuracy__c,Installation_Type__c,Shading__c
            ,Which_SR_product__c,RepID__c, Status
            from Lead where Id = :leadId];
        HttpRequest req = new HttpRequest(); 
        String url = 'https://secure.leads360.com/Import.aspx?Provider=VerengoMaster&Client=VerengoSolar&CampaignId=12';
        String body = '';
        body += '&SourceCode=ALS-SunRun';
        body += '&ProviderUniqueLeadID=' + emptyNull(leadRec.Zip_6__c);
        body += '&FirstName=' + emptyNull(leadRec.FirstName);
        body += '&Middle=' ;
        body += '&LastName=' + emptyNull(leadRec.LastName) ;
        body += '&Address1=' + emptyNull(leadRec.Street) ;
        body += '&Address2='  ;
        body += '&City=' + emptyNull(leadRec.City) ;
        body += '&County=' + emptyNull(leadRec.Country) ;
        body += '&State=' + emptyNull(leadRec.State);
        body += '&ZipCode=' + emptyNull(leadRec.PostalCode);
        body += '&Phone1=' + emptyNull(leadRec.Phone) ;
        body += '&Phone2=' + emptyNull(leadRec.Alternate_Phone__c) ;
        body += '&Phone3=' + emptyNull(leadRec.MobilePhone) ;
        body += '&Email=' + emptyNull(leadRec.Homeowner_Email__c) ;
        body += '&UtilityName=' + getLead360Value('Utility_Company__c', leadRec.Utility_Company__c);
        body += '&AverageMonthlyBill='  + leadRec.Monthly_Electricity_Bill__c ;
        body += '&AverageMonthlyBillRange=' ;
        body += '&Homeowner=' + 'Yes' ;
        body += '&YearsinHome=' ;
        body += '&PropertyType=' + 'Residential';
        if (leadRec.Site_Visit_Date_Time__c != null)
            body += '&AppointmentDate=' + leadRec.Site_Visit_Date_Time__c;
        body += '&Confirmed=' ;
        body += '&HomeOwnershipStatus=' ;
        body += '&SpouseName=' + emptyNull(leadRec.Other_decision_maker__c);
        body += '&Motivation=' + emptyNull(leadRec.Motivation_to_go_solar__c);
        body += '&AssistanceDiscount=' ;
        body += '&Credit=' ;
        body += '&NumberofStories=' ;
        body += '&Pool=' ;
        body += '&SquareFootage=' ;
        body += '&RoofType=' + emptyNull(leadRec.Roofing_Type__c);
        body += '&YearHomeBuilt=' ;
        body += '&RoofAge=' + getLead360Value('Age_of_Roof__c',leadRec.Age_of_Roof__c ) ;
        body += '&RoofScope=' ;
        body += '&RoofAzimuth=' + getLead360Value('Roof_Azimuth__c',leadRec.Roof_Azimuth__c ) ;
        body += '&DwellingType=' ;
        body += '&OccupationalStatus=' ;
        body += '&Notes=' + emptyNull(leadRec.Notes__c);
        body += '&ReferringCustomerName=' ;
        body += '&ReferringCustomerPhone=' ;
        body += '&ReferringCustomerEmail=' ;
        body += '&OnlineMapAccuracy=' + emptyNull(leadRec.Online_map_accuracy__c) ;
        body += '&TypeofInstall=' + emptyNull(leadRec.Installation_Type__c) ;
        body += '&Shading=' + emptyNull(leadRec.Shading__c) ;
        body += '&WhichSolarProduct=' + emptyNull(leadRec.Which_SR_product__c) ;
        body += '&LeadPricePaid=' ;
        body += '&ClientIPAddress=' ;
        body += '&Howdidyouhearaboutus=' ;
        body += '&SalespersonName=' ;
        body += '&AgentID=' + leadRec.RepID__c ;
        body += '&LeadNotPre-Qualified=' + getLead360Value('Status',leadRec.lead_status__c) ;
        System.debug('URL : ' + url);
        System.debug('Body : ' + body);
        req.setEndpoint(url); 
        req.setBody(body);
        req.setMethod('POST');
        Http http = new Http(); 
        HTTPResponse resp;
        String respBody;
        if(!Test.isrunningtest()){
        resp = http.send(req); 
        respBody = resp.getBody();
        }
        System.debug('Response : ' + respBody);
        return respBody;
    }
    
    public static String getLead360Value(String fieldId, String fieldValue)
    {
        if (fieldValue == null)
            return '';
            
        String retValue = fieldValue;
        
        Lead360_Int_Mapping__c[] mapList = [Select Lead360_Value__c from Lead360_Int_Mapping__c where Lookup_Field__c = :fieldId and SF_Value__c = :fieldValue];
        if (mapList.size() > 0)
        {
            retValue = mapList[0].Lead360_Value__c ;
        } 
        return retValue;
    }    
    
    public static String emptyNull(String input)
    {
        if (input == null)
            return '';
            
        return input;
    }
}