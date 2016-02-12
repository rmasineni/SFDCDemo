/*
Coder:       Peter Alexander Mandy
Date:        10/26/2012:10:46:28.02
Description: Apex Class that communicates with the CDYNE API for returning detailed address and geographical information.
             This class handles the needs to both Leads and Accounts with regard to determining the Zip+6 value, based on
             the information returned from the call to the CDYNE API.            
*/
public class CDYNEService {

public String DeliveryPoint{get;set;}
public String ZipPlus4{get;set;}
public String CDYNEStreet{get;set;}
public String CDYNECity{get;set;}
public String CDYNEState{get;set;}
public String CDYNEPostalCode{get;set;}
public String CDYNEReturnCode{get;set;}
public String CDYNECounty{get;set;}

//To Store LegislativeInfo and GeoLocationInfo
public String CDYNECongressDistrictNumber{get;set;}
public String CDYNEStateLegislativeUpper{get;set;}
public String CDYNEStateLegislativeLower{get;set;}
public String CDYNEFromlongitude{get;set;}
public String CDYNEFromLatitude{get;set;}
public String CDYNEToLongitude{get;set;}
public String CDYNEToLatitude{get;set;}
public String CDYNEAvgLongitude{get;set;}
public String CDYNEAvgLatitude{get;set;}
public String CDYNEHasDaylightSavings{get;set;}
public String CDYNETimeZone{get;set;}
public String CDYNEAreaCode{get;set;}

//To Store DPV Information
public String CDYNEDPVConfirmation {get;set;}
public String CDYNEDPVCrma {get;set;}
public String CDYNEDPVFootnote1 {get;set;}
public String CDYNEDPVFootnote2 {get;set;}
public String CDYNEDPVFootnote3 {get;set;}
public String CDYNEDPVNoStat {get;set;}
public String CDYNEDPVVacant {get;set;}



public Map<String, String> getMapCDYNEReturnCodes(){
   // Used to store a mapping of CDYNE Return Code to the desired Message that is writ to the record accordingly.
   Map<String, String> mapCDYNERetCodes = new Map<String, String>();
   for(CDYNE_Return_Codes__c CRC:[select id, Name, Description__c from CDYNE_Return_Codes__c])
   {
      mapCDYNERetCodes.put(CRC.Name, CRC.Description__c);
   }
   return mapCDYNERetCodes;
}
// TRIAL KEY: 2CAEAC0F-E1D2-42C4-BCA1-5C84CC98B435 good for 300 xtns 
private String LicenseKey = Label.Cdyne_LicenseKey;           //'2CAEAC0F-E1D2-42C4-BCA1-5C84CC98B435';
private String EndPoint = Label.Cdyne_VerifyAddressAdvanced; //'http://pav3.cdyne.com/PavService.svc/VerifyAddressAdvanced';

public Lead updateLead(Lead l, Map<String, CDYNEInformation> mapLeadToCDYNE)
{
        system.debug('mapLeadToCDYNE:' + mapLeadToCDYNE);
        if(mapLeadToCDYNE.get(l.Id).status == 'Success')
        { 
           // Only update the address information if the VerifyAddressAdvanced call is successful and therefore yeilds a Zip+6 value. 
           l.Zip_6__c = mapLeadToCDYNE.get(l.Id).zipplussix;
           l.Street = mapLeadToCDYNE.get(l.Id).street;
           l.City = mapLeadToCDYNE.get(l.Id).city;
           l.State = mapLeadToCDYNE.get(l.Id).state;
           l.PostalCode = mapLeadToCDYNE.get(l.Id).postalcode;
           l.county__c=mapLeadToCDYNE.get(l.Id).county;
           l.CDYNE_Status__c = mapLeadToCDYNE.get(l.Id).status;
           l.CDYNE_Result__c = mapLeadToCDYNE.get(l.Id).description;
           l.CDYNE_Address__c = mapLeadToCDYNE.get(l.Id).street + mapLeadToCDYNE.get(l.Id).city + mapLeadToCDYNE.get(l.Id).state + mapLeadToCDYNE.get(l.Id).postalcode;
           
           //LegislativeInfo and GeoLocationInfo
           l.CongressDistrictNumber__c = mapLeadToCDYNE.get(l.Id).CongressDistrictNumber;
           l.StateLegislativeUpper__c =  mapLeadToCDYNE.get(l.Id).StateLegislativeUpper;
           l.StateLegislativeLower__c =  mapLeadToCDYNE.get(l.Id).StateLegislativeLower;
           l.FromLongitude__c = mapLeadToCDYNE.get(l.Id).FromLongitude;
           l.FromLatitude__c = mapLeadToCDYNE.get(l.Id).FromLatitude;
           l.ToLongitude__c =  mapLeadToCDYNE.get(l.Id).ToLongitude;
           l.ToLatitude__c = mapLeadToCDYNE.get(l.Id).ToLatitude;
           l.AvgLongitude__c = mapLeadToCDYNE.get(l.Id).AvgLongitude;
           l.AvgLatitude__c = mapLeadToCDYNE.get(l.Id).AvgLatitude;
           l.HasDaylightSavings__c = mapLeadToCDYNE.get(l.Id).HasDaylightSavings;
           l.TimeZone__c = mapLeadToCDYNE.get(l.Id).TimeZone;
           l.AreaCode__c = mapLeadToCDYNE.get(l.Id).AreaCode;          
        }
        else
        {
           // Nullify the current zip+6 as it would no longer be valid for this address
           // Set theCDYNE fields on the record.
           l.Zip_6__c = '';
           l.CongressDistrictNumber__c = ''; 
           l.StateLegislativeUpper__c = ''; 
           l.StateLegislativeLower__c = ''; 
           l.FromLongitude__c = ''; 
           l.FromLatitude__c = ''; 
           l.ToLongitude__c = ''; 
           l.ToLatitude__c = ''; 
           l.AvgLongitude__c = ''; 
           l.AvgLatitude__c = ''; 
           l.HasDaylightSavings__c = ''; 
           l.TimeZone__c = ''; 
           l.AreaCode__c = '';
           l.CDYNE_Status__c = mapLeadToCDYNE.get(l.Id).status; //'Could not find zip+6.'; 
           l.CDYNE_Result__c = mapLeadToCDYNE.get(l.Id).description; //'Could not find zip+6: ' + XMLResponse; //mapAccountToCDYNE.get(a.Id).description;
           l.CDYNE_Address__c = l.Street + l.City + l.State + l.PostalCode;
        }   
        return l;
}

public Account updateAccount(Account a, Map<String, CDYNEInformation> mapAccountToCDYNE)
{
   if(mapAccountToCDYNE.get(a.Id).status == 'Success')
   {
           // Only update the address information if the VerifyAddressAdvanced call is successful and therefore yeilds a Zip+6 value.
           a.Zip_6__c = mapAccountToCDYNE.get(a.Id).zipplussix;
           a.Void_Proposals__c = true;
           a.BillingStreet = mapAccountToCDYNE.get(a.Id).street;
           a.BillingCity = mapAccountToCDYNE.get(a.Id).city;
           a.BillingState = mapAccountToCDYNE.get(a.Id).state;
           a.BillingPostalCode = mapAccountToCDYNE.get(a.Id).postalcode;
           a.county__c = mapAccountToCDYNE.get(a.Id).county;
           a.CDYNE_Status__c = mapAccountToCDYNE.get(a.Id).status;
           a.CDYNE_Result__c = mapAccountToCDYNE.get(a.Id).description;
           a.CDYNE_Address__c = mapAccountToCDYNE.get(a.Id).street + mapAccountToCDYNE.get(a.Id).city + mapAccountToCDYNE.get(a.Id).state + mapAccountToCDYNE.get(a.Id).postalcode;
           //LegislativeInfo and GeoLocationInfo
           a.CongressDistrictNumber__c = mapAccountToCDYNE.get(a.Id).CongressDistrictNumber;
           a.StateLegislativeUpper__c =  mapAccountToCDYNE.get(a.Id).StateLegislativeUpper;
           a.StateLegislativeLower__c =  mapAccountToCDYNE.get(a.Id).StateLegislativeLower;
           a.FromLongitude__c = mapAccountToCDYNE.get(a.Id).FromLongitude;
           a.FromLatitude__c = mapAccountToCDYNE.get(a.Id).FromLatitude;
           a.ToLongitude__c =  mapAccountToCDYNE.get(a.Id).ToLongitude;
           a.ToLatitude__c = mapAccountToCDYNE.get(a.Id).ToLatitude;
           a.AvgLongitude__c = mapAccountToCDYNE.get(a.Id).AvgLongitude;
           a.AvgLatitude__c = mapAccountToCDYNE.get(a.Id).AvgLatitude;
           a.HasDaylightSavings__c = mapAccountToCDYNE.get(a.Id).HasDaylightSavings;
           a.TimeZone__c = mapAccountToCDYNE.get(a.Id).TimeZone;
           a.AreaCode__c = mapAccountToCDYNE.get(a.Id).AreaCode;
           
           //DPV Information
           a.Dpv_Confirmation_Ind__c = mapAccountToCDYNE.get(a.Id).DPVConfirmation;
           a.DPV_Crma_Ind__c = mapAccountToCDYNE.get(a.Id).DPVCrma;
           a.DPV_Footnote1__c = mapAccountToCDYNE.get(a.Id).DPVFootnote1;
           a.DPV_Footnote2__c = mapAccountToCDYNE.get(a.Id).DPVFootnote2;
           a.DPV_Footnote3__c = mapAccountToCDYNE.get(a.Id).DPVFootnote3;
           a.DPV_NoStat_Ind__c = mapAccountToCDYNE.get(a.Id).DPVNoStat;
           a.DPV_Vacant_Ind__c = mapAccountToCDYNE.get(a.Id).DPVVacant;
           a.CDYNE_ReturnCode__c = mapAccountToCDYNE.get(a.Id).ReturnCode;
           
   }
   else
   {
           // Nullify the current zip+6 as it would no longer be valid for this address
           // Set theCDYNE fields on the record.
           a.Zip_6__c = '';
           a.CongressDistrictNumber__c = ''; 
           a.StateLegislativeUpper__c = '';
           a.StateLegislativeLower__c = ''; 
           a.FromLongitude__c = ''; 
           a.FromLatitude__c = ''; 
           a.ToLongitude__c = ''; 
           a.ToLatitude__c = ''; 
           a.AvgLongitude__c = ''; 
           a.AvgLatitude__c = ''; 
           a.HasDaylightSavings__c = ''; 
           a.TimeZone__c = ''; 
           a.AreaCode__c = '';
           a.CDYNE_Status__c = mapAccountToCDYNE.get(a.Id).status; //'Could not find zip+6.'; 
           a.CDYNE_Result__c = mapAccountToCDYNE.get(a.Id).description; //'Could not find zip+6: ' + XMLResponse; //mapAccountToCDYNE.get(a.Id).description;
           a.CDYNE_Address__c = '';    //mapAccountToCDYNE.get(a.Id).street + mapAccountToCDYNE.get(a.Id).city + mapAccountToCDYNE.get(a.Id).state + mapAccountToCDYNE.get(a.Id).postalcode;      
           
           //DPV Information
           a.Dpv_Confirmation_Ind__c = mapAccountToCDYNE.get(a.Id).DPVConfirmation;
           a.DPV_Crma_Ind__c = mapAccountToCDYNE.get(a.Id).DPVCrma;
           a.DPV_Footnote1__c = mapAccountToCDYNE.get(a.Id).DPVFootnote1;
           a.DPV_Footnote2__c = mapAccountToCDYNE.get(a.Id).DPVFootnote2;
           a.DPV_Footnote3__c = mapAccountToCDYNE.get(a.Id).DPVFootnote3;
           a.DPV_NoStat_Ind__c = mapAccountToCDYNE.get(a.Id).DPVNoStat;
           a.DPV_Vacant_Ind__c = mapAccountToCDYNE.get(a.Id).DPVVacant;
           a.CDYNE_ReturnCode__c = mapAccountToCDYNE.get(a.Id).ReturnCode;     
   }
   return a;
}

public void processLeadUpdates(List<Lead> listForUpdate)
{
    
    List<Lead> listForSecondUpdate = new List<Lead>();
    Map<Integer, String> mapIndexToError = new Map<Integer, String>();
    Database.SaveResult[] SRList = database.update(listForUpdate, false);
    Integer i = 0;
    for(Database.SaveResult SR: SRList)
    {             
       for(Database.Error err: SR.getErrors())
       {
          if (!SR.isSuccess()) 
          {               
              // process any errors here into a map based on the index of the list.
              // errors are indexed the same as the list object
              // this is the only way to trap the id => error mapping
              // because salesforce only returns ids for successful dml actions.
              // yes, this is unfortunate and odd.  
              mapIndexToError.put(i, err.getStatusCode()+ ': ' + err.getMessage());
          }
       }
       i++;
    }
    Integer j = 0;
    for(Lead l:listForUpdate)
    {
        if(mapIndexToError.get(j) != null)
        {
           l.CDYNE_Result__c = mapIndexToError.get(j) + '<a href=\'/' + mapIndexToError.get(j).right(15) + '\'';
           l.Zip_6__c = '';
           listForSecondUpdate.add(l);
        }
        j++;
    }    
    if(!listForSecondUpdate.isEmpty())
    {
       update listForSecondUpdate;
    } 
}

public void processAccountUpdates(List<Account> listForUpdate)
{
   List<Account> listForSecondUpdate = new List<Account>();
   Map<Integer, Map<String, String>> mapIndexToError = new Map<Integer, Map<String, String>>();
   Database.SaveResult[] SRList = database.update(listForUpdate, false);
   Integer i = 0;
   for(Database.SaveResult SR: SRList)
   {      
      for(Database.Error err: SR.getErrors())
      {
         if (!SR.isSuccess()) 
         {                
             // process any errors here                    
             mapIndexToError.put(i, new Map<String, String>{String.ValueOf(err.getStatusCode())=>err.getMessage()});
         }
      }
      i++;
   }
   Integer j = 0;
   for(Account a:listForUpdate)
   {
       if(mapIndexToError.get(j) != null)
       {                
           String errorMsg = '';
           for(String s: mapIndexToError.get(j).keySet())
           {
              if(s == 'DUPLICATE_VALUE')
              { 
                 // Manage Duplicate Value (on Zip+6) Message, to render a more user-friendly message to the user. 
                 errorMsg += '<b><font color=red>DUPLICATE_VALUE: </font></b>' + mapIndexToError.get(j).get('DUPLICATE_VALUE').substring(0,mapIndexToError.get(j).get('DUPLICATE_VALUE').length()-15) + '<a href=\'/' + mapIndexToError.get(j).get('DUPLICATE_VALUE').right(15) + '\'>'+mapIndexToError.get(j).get('DUPLICATE_VALUE').right(15)+'</a><br/>CDYNE successfully returned a Zip Plus Six Value of: ' + a.Zip_6__c + '<br/> CDYNE returned an address of: <br/>' + CDYNEStreet + '<br/> ' + CDYNECity + ', ' + CDYNEState + ' ' + CDYNEPostalCode + '.';
                 a.Duplicate__c = True;
                 a.Zip_6__c = '';
              }
              else
              {
                  // Let other error messages show as they are naturally rendered by Salesforce.com.
                  errorMsg += s + ': ' + mapIndexToError.get(j).get(s) + '<br/>';
              }
           }                 
           a.CDYNE_Result__c = errorMsg;           
           listForSecondUpdate.add(a);
        }
        j++;
     }    
     if(!listForSecondUpdate.isEmpty())
     {
        update listForSecondUpdate;
     } 
}

public void doFutureLeadMethodContent(Set<String> setLeadIds)
{   
    
    //Commented to integrate new AddressService
    if (true) {
        System.debug('########### Old CDyne address verification process has been deprecated in favor of new Address Service');
        return;
    }
    
    Map<String, CDYNEInformation> mapLeadToCDYNE = new Map<String, CDYNEInformation>();
    List<Lead> listForUpdate = new List<Lead>();
    CDYNEService CDYNE = new CDYNEService();
    
    //Converted leads cannot be updated at all otherwise, salesforce will throw 
    //CANNOT_UPDATE_CONVERTED_LEAD, cannot reference converted lead: []
    //
    //So added a condition below to ignore leads which are already converted.
    for(Lead l:[select id, Street,County__c, City, State, PostalCode, Zip_6__c, CDYNE_Status__c, CDYNE_Result__c, CongressDistrictNumber__c, StateLegislativeUpper__c, StateLegislativeLower__c, FromLongitude__c, FromLatitude__c, ToLongitude__c, ToLatitude__c, AvgLongitude__c, AvgLatitude__c, HasDaylightSavings__c, TimeZone__c, AreaCode__c from Lead where id in :setLeadIds and IsConverted=false])
    {       
        mapLeadToCDYNE = CDYNE.parse(l, CDYNE.getZipPlusSix(l), CDYNE.getMapCDYNEReturnCodes()); 
        listForUpdate.add(CDYNE.updateLead(l, mapLeadToCDYNE));
    }
    if(!listForUpdate.isEmpty())
    {
        CDYNE.processLeadUpdates(listForUpdate);
    }
}

public static void processZipPlusSixForLeads(Set<String> setLeadIds)
{
    //Commented to integrate new AddressService
    if (true) {
        System.debug('########### Old CDyne address verification process has been deprecated in favor of new Address Service');
        return;
    }
    
    // Future method used for call from Apex Trigger, to handle Asychronous call, since triggers cannot call webservices synchronously.
    CDYNEService CDYNE = new CDYNEService();
    CDYNE.doFutureLeadMethodContent(setLeadIds);
}

public void doFutureAccountMethodContent(Set<String> setAcctIds)
{
    
    //Commented to integrate new AddressService
    if (true) {
        System.debug('########### Old CDyne address verification process has been deprecated in favor of new Address Service');
        return;
    }
    
    Map<String, CDYNEInformation> mapAccountToCDYNE = new Map<String, CDYNEInformation>();
    List<Account> listForUpdate = new List<Account>();
    List<Account> listForSecondUpdate = new List<Account>();
    Map<Integer, String> mapIndexToError = new Map<Integer, String>();
    CDYNEService CDYNE = new CDYNEService();
    for(Account a:[select id, BillingStreet, BillingCity, BillingState, BillingPostalCode, Zip_6__c, county__c,CDYNE_Status__c, CDYNE_Result__c, 
                   CongressDistrictNumber__c, StateLegislativeUpper__c, StateLegislativeLower__c, FromLongitude__c, FromLatitude__c,  
                   ToLongitude__c, ToLatitude__c, AvgLongitude__c, AvgLatitude__c, HasDaylightSavings__c, TimeZone__c, AreaCode__c, void_proposals__c, 
                   Dpv_Confirmation_Ind__c, DPV_Crma_Ind__c, DPV_Footnote1__c, DPV_Footnote2__c, DPV_Footnote3__c, DPV_NoStat_Ind__c, DPV_Vacant_Ind__c, CDYNE_ReturnCode__c from Account where id in :setAcctIds])
    {
        mapAccountToCDYNE = CDYNE.parse(a, CDYNE.getZipPlusSix(a), CDYNE.getMapCDYNEReturnCodes()); 
        listForUpdate.add(CDYNE.updateAccount(a, mapAccountToCDYNE));
    }
    if(!listForUpdate.isEmpty())
    {
        CDYNE.processAccountUpdates(listForUpdate);
    }
}

public static void processZipPlusSixForAccounts(Set<String> setAccountIds)
{
    //Commented to integrate new AddressService
    if (true) {
        System.debug('########### Old CDyne address verification process has been deprecated in favor of new Address Service');
        return;
    }
    // Future method used for call from Apex Trigger, to handle Asychronous call, since triggers cannot call webservices synchronously.
    CDYNEService CDYNE = new CDYNEService();
    CDYNE.doFutureAccountMethodContent(setAccountIds);
}

public void processZipPlusSixForAccountsImmediate(Set<String> setAccountIds)
{
    //Commented to integrate new AddressService
    if (true) {
        System.debug('########### Old CDyne address verification process has been deprecated in favor of new Address Service');
        return;
    }
    
    // Synchronous calls (from button on page) call this method to return an immediate response to the user.
    Map<String, CDYNEInformation> mapAccountToCDYNE = new Map<String, CDYNEInformation>();
    List<Account> listForUpdate = new List<Account>();
    CDYNEService CDYNE = new CDYNEService();
    for(Account a:[select id, BillingStreet, BillingCity, BillingState, BillingPostalCode, Zip_6__c,county__c, CDYNE_Status__c, CDYNE_Result__c, 
                   CongressDistrictNumber__c, StateLegislativeUpper__c, StateLegislativeLower__c, FromLongitude__c, FromLatitude__c, 
                   ToLongitude__c, ToLatitude__c, AvgLongitude__c, AvgLatitude__c, HasDaylightSavings__c, TimeZone__c, AreaCode__c, void_proposals__c, 
                   Dpv_Confirmation_Ind__c, DPV_Crma_Ind__c, DPV_Footnote1__c, DPV_Footnote2__c, DPV_Footnote3__c, DPV_NoStat_Ind__c, DPV_Vacant_Ind__c, CDYNE_ReturnCode__c from Account where id in :setAccountIds])
    {
        String XMLResponse = CDYNE.getZipPlusSix(a);
        mapAccountToCDYNE = CDYNE.parse(a, XMLResponse, CDYNE.getMapCDYNEReturnCodes()); 
        listForUpdate.add(CDYNE.updateAccount(a, mapAccountToCDYNE));
    }
    if(!listForUpdate.isEmpty())
    {
        processAccountUpdates(listForUpdate);
    }
}

public void processZipPlusSixForLeadsImmediate(Set<String> setLeadIds)
{
    
    //Commented to integrate new AddressService
    if (true) {
        System.debug('########### Old CDyne address verification process has been deprecated in favor of new Address Service');
        return;
    }
    
    // Synchronous calls (from button on page) call this method to return an immediate response to the user.
    Map<String, CDYNEInformation> mapLeadToCDYNE = new Map<String, CDYNEInformation>();
    List<Lead> listForUpdate = new List<Lead>();
    CDYNEService CDYNE = new CDYNEService();
    for(Lead l:[select id, Street, City,County__c, State, PostalCode, Zip_6__c, CDYNE_Status__c, CDYNE_Result__c, CongressDistrictNumber__c, StateLegislativeUpper__c, StateLegislativeLower__c, FromLongitude__c, FromLatitude__c, ToLongitude__c, ToLatitude__c, AvgLongitude__c, AvgLatitude__c, HasDaylightSavings__c, TimeZone__c, AreaCode__c from Lead where id in :setLeadIds])
    {
        String XMLResponse = CDYNE.getZipPlusSix(l);
        mapLeadToCDYNE = CDYNE.parse(l, XMLResponse, CDYNE.getMapCDYNEReturnCodes()); 
        listForUpdate.add(CDYNE.updateLead(l, mapLeadToCDYNE));
    }
    if(!listForUpdate.isEmpty())
    {
        processLeadUpdates(listForUpdate);
    }
}

public Map<String, CDYNEInformation> parse(Account a, String toParse, Map<String, String> mapCDYNEReturnCodes) {
  // Used to parse out the response from CDYNE to get what we need for ZIP+6.
  Map<String, CDYNEInformation> mapAccountToCDYNE = new Map<String, CDYNEInformation>();    
  DOM.Document doc = new DOM.Document();      
  try {
    doc.load(toParse);    
    DOM.XMLNode root = doc.getRootElement();
    String callparser = walkThrough(root);
   mapAccountToCDYNE.put(a.id, new CDYNEInformation(mapCDYNEReturnCodes, CDYNEReturnCode, DeliveryPoint + ZipPlus4, CDYNEStreet, CDYNECity, CDYNEState, CDYNEPostalCode,CDYNECounty, 'Success' , '<b><font color=red>Updated Address Info and ZipPlusSix.</b></font>'
   , CDYNECongressDistrictNumber, CDYNEStateLegislativeUpper, CDYNEStateLegislativeLower, CDYNEFromlongitude, CDYNEFromLatitude, CDYNEToLongitude, CDYNEToLatitude, CDYNEAvgLongitude, CDYNEAvgLatitude, CDYNEHasDaylightSavings, CDYNETimeZone, CDYNEAreaCode
   , CDYNEDPVConfirmation, CDYNEDPVCrma, CDYNEDPVFootnote1, CDYNEDPVFootnote2, CDYNEDPVFootnote3, CDYNEDPVNoStat, CDYNEDPVVacant));
    return  mapAccountToCDYNE;
  } catch (System.XMLException e) {  // invalid XML
       System.Debug('XML Error Message: ' + e.getMessage());
     return null;
  }
}

public Map<String, CDYNEInformation> parse(Lead l, String toParse, Map<String, String> mapCDYNEReturnCodes) {
  // Used to parse out the response from CDYNE to get what we need for ZIP+6.
  Map<String, CDYNEInformation> mapLeadToCDYNE = new Map<String, CDYNEInformation>();   
  DOM.Document doc = new DOM.Document();      
  try {
    doc.load(toParse);    
    DOM.XMLNode root = doc.getRootElement();
    String callparser = walkThrough(root);
    mapLeadToCDYNE.put(l.id, new CDYNEInformation(mapCDYNEReturnCodes, CDYNEReturnCode, DeliveryPoint + ZipPlus4, CDYNEStreet, CDYNECity, CDYNEState, CDYNEPostalCode,CDYNECounty, 'Success' , '<b><font color=red>Updated Address Info and ZipPlusSix.</b></font>'
    , CDYNECongressDistrictNumber, CDYNEStateLegislativeUpper, CDYNEStateLegislativeLower, CDYNEFromlongitude, CDYNEFromLatitude, CDYNEToLongitude, CDYNEToLatitude, CDYNEAvgLongitude, CDYNEAvgLatitude, CDYNEHasDaylightSavings, CDYNETimeZone, CDYNEAreaCode));
    return  mapLeadToCDYNE; 
  } catch (System.XMLException e) {  // invalid XML
       System.Debug('XML Error Message: ' + e.getMessage());
     return null;
  }
}

public String walkThrough(DOM.XMLNode node) {
  String result = '/n';
  //
  if (node.getNodeType() == DOM.XMLNodeType.ELEMENT) {
    //
    // Get the values from the XML that we need to calculate ZIP+6 
    // and also return the CDYNE Address values.
    //
    if(node.getName() == 'DeliveryPoint')
    {
        DeliveryPoint = node.getText().trim();
    }
    if(node.getName() == 'ZipCode')
    {
        ZipPlus4 = node.getText().trim().replace('-', '');
    }    
    if(node.getName() == 'PrimaryDeliveryLine')
    {
        CDYNEStreet = node.getText().trim();
    }
    if(node.getName() == 'PreferredCityName')
    {
        CDYNECity = node.getText().trim();
    }    
    if(node.getName() == 'StateAbbreviation')
    {
        CDYNEState = node.getText().trim();
    }
    if(node.getName() == 'ZipCode')
    {
        CDYNEPostalCode = node.getText().trim();
    }   
    if(node.getName() == 'County')
    {
        CDYNECounty = node.getText().trim();
    }         
    if(node.getName() == 'ReturnCode')
    {
        CDYNEReturnCode = node.getText().trim();
    }
    //Getting LegislativeInfo and GeoLocationInfo
    if(node.getName() == 'CongressionalDistrictNumber')
    {
        CDYNECongressDistrictNumber = node.getText().trim();
    }
    if(node.getName() == 'StateLegislativeUpper')
    {
        CDYNEStateLegislativeUpper = node.getText().trim();
        system.debug('StateLegislativeUpper:' + CDYNEStateLegislativeUpper);
    } 
    if(node.getName() == 'StateLegislativeLower')
    {
        CDYNEStateLegislativeLower = node.getText().trim();
    } 
    if(node.getName() == 'Fromlongitude')
    {
        CDYNEFromlongitude = node.getText().trim();
    } 
    if(node.getName() == 'FromLatitude')
    {
        CDYNEFromLatitude = node.getText().trim();
    } 
    if(node.getName() == 'ToLongitude')
    {
        CDYNEToLongitude = node.getText().trim();
    } 
    if(node.getName() == 'ToLatitude')
    {
        CDYNEToLatitude = node.getText().trim();
    } 
    if(node.getName() == 'AvgLongitude')
    {
        CDYNEAvgLongitude = node.getText().trim();
    } 
    if(node.getName() == 'AvgLatitude')
    {
        CDYNEAvgLatitude = node.getText().trim();
    } 
    if(node.getName() == 'HasDaylightSavings')
    {
        CDYNEHasDaylightSavings = node.getText().trim();
    } 
    if(node.getName() == 'TimeZone')
    {
        CDYNETimeZone = node.getText().trim();
    } 
    if(node.getName() == 'AreaCode')
    {
        CDYNEAreaCode = node.getText().trim();
    } 
    
    //DPV Information
    if(node.getName() == 'DpvConfirmationIndicator')
    {
        CDYNEDPVConfirmation = node.getText().trim();
    }
    if(node.getName() == 'DPVFootnote1')
    {
        CDYNEDPVFootnote1 = node.getText().trim();
    }
    if(node.getName() == 'DPVFootnote2')
    {
        CDYNEDPVFootnote2 = node.getText().trim();
    }
    if(node.getName() == 'DPVFootnote3')
    {
        CDYNEDPVFootnote3 = node.getText().trim();
    }
    if(node.getName() == 'DpvNoStatIndicator')
    {
        CDYNEDPVNoStat = node.getText().trim();
    }
    if(node.getName() == 'DpvVacantIndicator')
    {
        CDYNEDPVVacant = node.getText().trim();
    }
    if(node.getName() == 'DpvCrmaIndicator')
    {
        CDYNEDPVCrma = node.getText().trim();
    }
       
    for (Dom.XMLNode child: node.getChildElements()) {
      result += walkThrough(child);
    }
  }
  if(DeliveryPoint != '' && ZipPlus4 != '')
  {
     return DeliveryPoint + ZipPlus4;
  }
  return DeliveryPoint + ZipPlus4;  //should never reach here 
}

public String getZipPlusSix(Lead l)
{
// http://pav3.cdyne.com/PavService.svc/help/operations/VerifyAddressAdvanced
   HttpRequest req = new HttpRequest();
   HttpResponse res = new HttpResponse();
   Http http = new Http();
   req.setEndpoint(EndPoint);
   req.setMethod('POST');
   req.setHeader(LicenseKey, LicenseKey);
   req.setHeader('Content-type', 'text/xml;charset=utf-8');
   req.setHeader('SOAPAction', 'VerifyAddressAdvanced');
   //
   String strRequest = '';
   strRequest += '<PavRequest xmlns="pav3.cdyne.com">';
   strRequest += '<CityName>' + l.City + '</CityName>';
   strRequest += '<FirmOrRecipient></FirmOrRecipient>';
   strRequest += '<LicenseKey>' + LicenseKey + '</LicenseKey>';
   strRequest += '<PrimaryAddressLine>' + l.Street + '</PrimaryAddressLine>';
   strRequest += '<ReturnCaseSensitive>true</ReturnCaseSensitive>';
   strRequest += '<ReturnCensusInfo>true</ReturnCensusInfo>';
   strRequest += '<ReturnCityAbbreviation>true</ReturnCityAbbreviation>';
   strRequest += '<ReturnGeoLocation>true</ReturnGeoLocation>';
   strRequest += '<ReturnLegislativeInfo>true</ReturnLegislativeInfo>';
   strRequest += '<ReturnMailingIndustryInfo>true</ReturnMailingIndustryInfo>';
   strRequest += '<ReturnResidentialIndicator>true</ReturnResidentialIndicator>';
   strRequest += '<ReturnStreetAbbreviated>true</ReturnStreetAbbreviated>';
   strRequest += '<SecondaryAddressLine></SecondaryAddressLine>';
   strRequest += '<State>' + l.State + '</State>';
   strRequest += '<Urbanization></Urbanization>';
   strRequest += '<ZipCode>' + l.PostalCode + '</ZipCode>';
   strRequest += '</PavRequest>';
   //
   req.setBody(strRequest);
   //
   If(!Test.isRunningTest()){
       res = http.send(req);
   }else{
       String responseBody = '<PavResponse xmlns=\"pav3.cdyne.com\" xmlns:i=\"http://www.w3.org/2001/XMLSchema-instance\"><CensusInfo><CMSA/><CensusBlockNumber>3029</CensusBlockNumber><CensusTractNumber>4507.03</CensusTractNumber><FIPS>06001</FIPS><MA>084</MA><MSA/><PMSA>5775</PMSA></CensusInfo><CityName>Pleasanton</CityName><Country>USA</Country><County>ALAMEDA</County><CountyNum>001</CountyNum><FinanceNumber>56138</FinanceNumber><FirmOrRecipient/><GeoLocationInfo><AreaCode>925</AreaCode><AvgLatitude>37.685880</AvgLatitude><AvgLongitude>-121.872367</AvgLongitude><FromLatitude>37.686430</FromLatitude><FromLongitude>-121.872967</FromLongitude><HasDaylightSavings>true</HasDaylightSavings><TimeZone>PST</TimeZone><ToLatitude>37.685330</ToLatitude><ToLongitude>-121.871767</ToLongitude></GeoLocationInfo><IntelligentMailBarcodeKey>RZHexk2OGvzqP37LOxSjWA==</IntelligentMailBarcodeKey><LegislativeInfo><CongressionalDistrictNumber>15</CongressionalDistrictNumber><StateLegislativeLower>016</StateLegislativeLower><StateLegislativeUpper>007</StateLegislativeUpper></LegislativeInfo><MailingIndustryInfo><CSKey>Z22523</CSKey><CarrierRoute>R002</CarrierRoute><CheckDigit>1</CheckDigit><DefaultFlag>true</DefaultFlag><DeliveryPoint>99</DeliveryPoint><DpvConfirmationIndicator>D</DpvConfirmationIndicator><DpvCrmaIndicator>N</DpvCrmaIndicator><DpvFootnote1>AA</DpvFootnote1><DpvFootnote2>N1</DpvFootnote2><DpvFootnote3/><DpvNoStatIndicator>N</DpvNoStatIndicator><DpvVacantIndicator>N</DpvVacantIndicator><ELOTAscDesc>A</ELOTAscDesc><ELOTSequenceNumber>0076</ELOTSequenceNumber><EwsFlag>false</EwsFlag><LACSFlag/><LACSIndicator/><LACSReturnCode/><RecordTypeCode>H</RecordTypeCode><SuiteLinkReturnCode/></MailingIndustryInfo><MultipleMatches><AddressInfo><CarrierRoute>R002</CarrierRoute><FinanceNumber>56138</FinanceNumber><Firm/><Plus4High>8333</Plus4High><Plus4Low>8333</Plus4Low><PostDirectional/><PreDirectional/><PrimaryEO>E</PrimaryEO><PrimaryHigh>3954</PrimaryHigh><PrimaryLow>3954</PrimaryLow><RecordTypeCode>H</RecordTypeCode><SecondaryAbbreviation>APT</SecondaryAbbreviation><SecondaryEO>B</SecondaryEO><SecondaryHigh>8</SecondaryHigh><SecondaryLow>1</SecondaryLow><StreetName>STONERIDGE</StreetName><Suffix>DR</Suffix><ZipCode>94588</ZipCode></AddressInfo><AddressInfo><CarrierRoute>R002</CarrierRoute><FinanceNumber>56138</FinanceNumber><Firm/><Plus4High>8322</Plus4High><Plus4Low>8322</Plus4Low><PostDirectional/><PreDirectional/><PrimaryEO>E</PrimaryEO><PrimaryHigh>3998</PrimaryHigh><PrimaryLow>3900</PrimaryLow><RecordTypeCode>S</RecordTypeCode><SecondaryAbbreviation/><SecondaryEO/><SecondaryHigh/><SecondaryLow/><StreetName>STONERIDGE</StreetName><Suffix>DR</Suffix><ZipCode>94588</ZipCode></AddressInfo></MultipleMatches><PMBDesignator/><PMBNumber/><PostDirectional/><PostnetBarcode>f945888333991f</PostnetBarcode><PreDirectional/><PreferredCityName>Pleasanton</PreferredCityName><Primary>3954</Primary><PrimaryDeliveryLine>3954 Stoneridge Dr</PrimaryDeliveryLine><PrimaryEO>E</PrimaryEO><PrimaryHigh>3954</PrimaryHigh><PrimaryLow>3954</PrimaryLow><ResidentialDeliveryIndicator>Y</ResidentialDeliveryIndicator><ReturnCode>103</ReturnCode><Secondary/><SecondaryAbbreviation/><SecondaryDeliveryLine/><SecondaryEO>B</SecondaryEO><SecondaryHigh/><SecondaryLow/><StateAbbreviation>CA</StateAbbreviation><StreetName>STONERIDGE</StreetName><Suffix>DR</Suffix><Urbanization/><ZipCode>94588-8333</ZipCode></PavResponse>' ;
       String statusCode = '200';
       String status = 'OK';
       res.setBody(responseBody);
       res.setStatusCode(200);
       res.setStatus(status);       
   }
   //      
   System.Debug(res.getBody());
   System.Debug(res.getStatusCode());
   System.Debug(res.getStatus());
   //
   return res.getBody();
}

public String getZipPlusSix(Account a)
{
// http://pav3.cdyne.com/PavService.svc/help/operations/VerifyAddressAdvanced   
   HttpRequest req = new HttpRequest();
   HttpResponse res = new HttpResponse();
   Http http = new Http();
   req.setEndpoint(EndPoint);
   req.setMethod('POST');
   req.setHeader(LicenseKey, LicenseKey);
   req.setHeader('Content-type', 'text/xml;charset=utf-8');
   req.setHeader('SOAPAction', 'VerifyAddressAdvanced');
   //
   String strRequest = '';
   strRequest += '<PavRequest xmlns="pav3.cdyne.com">';
   strRequest += '<CityName>' + a.BillingCity + '</CityName>';
   strRequest += '<FirmOrRecipient></FirmOrRecipient>';
   strRequest += '<LicenseKey>' + LicenseKey + '</LicenseKey>';
   strRequest += '<PrimaryAddressLine>' + a.BillingStreet + '</PrimaryAddressLine>';
   strRequest += '<ReturnCaseSensitive>true</ReturnCaseSensitive>';
   strRequest += '<ReturnCensusInfo>true</ReturnCensusInfo>';
   strRequest += '<ReturnCityAbbreviation>true</ReturnCityAbbreviation>';
   strRequest += '<ReturnGeoLocation>true</ReturnGeoLocation>';
   strRequest += '<ReturnLegislativeInfo>true</ReturnLegislativeInfo>';
   strRequest += '<ReturnMailingIndustryInfo>true</ReturnMailingIndustryInfo>';
   strRequest += '<ReturnResidentialIndicator>true</ReturnResidentialIndicator>';
   strRequest += '<ReturnStreetAbbreviated>true</ReturnStreetAbbreviated>';
   strRequest += '<SecondaryAddressLine></SecondaryAddressLine>';
   strRequest += '<State>' + a.BillingState + '</State>';
   strRequest += '<Urbanization></Urbanization>';
   strRequest += '<ZipCode>' + a.BillingPostalCode + '</ZipCode>';
   strRequest += '</PavRequest>';
   //
   req.setBody(strRequest);
   //
   If(!Test.isRunningTest()){
       res = http.send(req);
   }else{
       String responseBody = '<PavResponse xmlns=\"pav3.cdyne.com\" xmlns:i=\"http://www.w3.org/2001/XMLSchema-instance\"><CensusInfo><CMSA/><CensusBlockNumber>3029</CensusBlockNumber><CensusTractNumber>4507.03</CensusTractNumber><FIPS>06001</FIPS><MA>084</MA><MSA/><PMSA>5775</PMSA></CensusInfo><CityName>Pleasanton</CityName><Country>USA</Country><County>ALAMEDA</County><CountyNum>001</CountyNum><FinanceNumber>56138</FinanceNumber><FirmOrRecipient/><GeoLocationInfo><AreaCode>925</AreaCode><AvgLatitude>37.685880</AvgLatitude><AvgLongitude>-121.872367</AvgLongitude><FromLatitude>37.686430</FromLatitude><FromLongitude>-121.872967</FromLongitude><HasDaylightSavings>true</HasDaylightSavings><TimeZone>PST</TimeZone><ToLatitude>37.685330</ToLatitude><ToLongitude>-121.871767</ToLongitude></GeoLocationInfo><IntelligentMailBarcodeKey>RZHexk2OGvzqP37LOxSjWA==</IntelligentMailBarcodeKey><LegislativeInfo><CongressionalDistrictNumber>15</CongressionalDistrictNumber><StateLegislativeLower>016</StateLegislativeLower><StateLegislativeUpper>007</StateLegislativeUpper></LegislativeInfo><MailingIndustryInfo><CSKey>Z22523</CSKey><CarrierRoute>R002</CarrierRoute><CheckDigit>1</CheckDigit><DefaultFlag>true</DefaultFlag><DeliveryPoint>99</DeliveryPoint><DpvConfirmationIndicator>D</DpvConfirmationIndicator><DpvCrmaIndicator>N</DpvCrmaIndicator><DpvFootnote1>AA</DpvFootnote1><DpvFootnote2>N1</DpvFootnote2><DpvFootnote3/><DpvNoStatIndicator>N</DpvNoStatIndicator><DpvVacantIndicator>N</DpvVacantIndicator><ELOTAscDesc>A</ELOTAscDesc><ELOTSequenceNumber>0076</ELOTSequenceNumber><EwsFlag>false</EwsFlag><LACSFlag/><LACSIndicator/><LACSReturnCode/><RecordTypeCode>H</RecordTypeCode><SuiteLinkReturnCode/></MailingIndustryInfo><MultipleMatches><AddressInfo><CarrierRoute>R002</CarrierRoute><FinanceNumber>56138</FinanceNumber><Firm/><Plus4High>8333</Plus4High><Plus4Low>8333</Plus4Low><PostDirectional/><PreDirectional/><PrimaryEO>E</PrimaryEO><PrimaryHigh>3954</PrimaryHigh><PrimaryLow>3954</PrimaryLow><RecordTypeCode>H</RecordTypeCode><SecondaryAbbreviation>APT</SecondaryAbbreviation><SecondaryEO>B</SecondaryEO><SecondaryHigh>8</SecondaryHigh><SecondaryLow>1</SecondaryLow><StreetName>STONERIDGE</StreetName><Suffix>DR</Suffix><ZipCode>94588</ZipCode></AddressInfo><AddressInfo><CarrierRoute>R002</CarrierRoute><FinanceNumber>56138</FinanceNumber><Firm/><Plus4High>8322</Plus4High><Plus4Low>8322</Plus4Low><PostDirectional/><PreDirectional/><PrimaryEO>E</PrimaryEO><PrimaryHigh>3998</PrimaryHigh><PrimaryLow>3900</PrimaryLow><RecordTypeCode>S</RecordTypeCode><SecondaryAbbreviation/><SecondaryEO/><SecondaryHigh/><SecondaryLow/><StreetName>STONERIDGE</StreetName><Suffix>DR</Suffix><ZipCode>94588</ZipCode></AddressInfo></MultipleMatches><PMBDesignator/><PMBNumber/><PostDirectional/><PostnetBarcode>f945888333991f</PostnetBarcode><PreDirectional/><PreferredCityName>Pleasanton</PreferredCityName><Primary>3954</Primary><PrimaryDeliveryLine>3954 Stoneridge Dr</PrimaryDeliveryLine><PrimaryEO>E</PrimaryEO><PrimaryHigh>3954</PrimaryHigh><PrimaryLow>3954</PrimaryLow><ResidentialDeliveryIndicator>Y</ResidentialDeliveryIndicator><ReturnCode>103</ReturnCode><Secondary/><SecondaryAbbreviation/><SecondaryDeliveryLine/><SecondaryEO>B</SecondaryEO><SecondaryHigh/><SecondaryLow/><StateAbbreviation>CA</StateAbbreviation><StreetName>STONERIDGE</StreetName><Suffix>DR</Suffix><Urbanization/><ZipCode>94588-8333</ZipCode></PavResponse>' ;
       String statusCode = '200';
       String status = 'OK';
       res.setBody(responseBody);
       res.setStatusCode(200);
       res.setStatus(status);
   }
   //           
   System.Debug('BODY: ' + res.getBody());
   System.Debug('STATUS CODE: ' + res.getStatusCode());
   System.Debug('STATUS: ' + res.getStatus());
   //
   return res.getBody();
}

public class CDYNEInformation{
    String status{get;set;}
    String description{get;set;}
    String street{get;set;}
    String city{get;set;}
    String state{get;set;}
    String postalcode{get;set;}
    String zipplussix{get;set;}
    String county{get;set;}
    
    //LegislativeInfo: and GeoLocationInfo:
    String CongressDistrictNumber{get;set;}
    String StateLegislativeUpper{get;set;}
    String StateLegislativeLower{get;set;}
    String Fromlongitude{get;set;}
    String FromLatitude{get;set;}
    String ToLongitude{get;set;}
    String ToLatitude{get;set;}
    String AvgLongitude{get;set;}
    String AvgLatitude{get;set;}
    String HasDaylightSavings{get;set;}
    String TimeZone{get;set;}
    String AreaCode{get;set;}
    
    //DPV Information
    String DPVConfirmation {get;set;}
    String DPVCrma {get;set;}
    String DPVFootnote1 {get;set;}
    String DPVFootnote2 {get;set;}
    String DPVFootnote3 {get;set;}
    String DPVNoStat {get;set;}
    String DPVVacant {get;set;}
    String ReturnCode {get;set;} 

    public CDYNEInformation(Map<String, String> mapReturnCode, String CDYNERet, String zip6, String CStreet, String CCity, String CState, String CZip,String Ccounty, String status, String result
    , String CCongress, String CSLUpper, String CSLLower, String CFlongi, String CFLati, String CTlongi, String CTlati, String CAvLongi, String CAvLati, String CHasDay, String CTZone, String CArCode
    , String CDPVCon, String CDPVCrma, String  CDPVfoot1, String  CDPVfoot2, String  CDPVfoot3, String  CDPVStat, String  CDPVVac){
       //
       if(CDYNERet == '100') // All others are "Failure" codes, aka, the ones WE consider as failures as they do not yield a Valid Zip+6
       {
            this.status = 'Success';
       }
       else
       {
            this.status = 'Failure';
       }
       if(mapReturnCode.get(CDYNERet) != null)
       {
           this.description = mapReturnCode.get(CDYNERet);
       }
       this.street = CStreet;
       this.city = CCity;
       this.state = CState;
       this.postalcode = CZip;
       this.zipplussix = zip6;
       this.county=Ccounty;
        //LegislativeInfo: and GeoLocationInfo:
        this.CongressDistrictNumber =  CCongress;
        this.StateLegislativeUpper = CSLUpper;
        this.StateLegislativeLower = CSLLower;
        this.Fromlongitude = CFlongi;
        this.FromLatitude = CFLati;
        this.ToLongitude = CTlongi;
        this.ToLatitude =  CTlati;
        this.AvgLongitude = CAvLongi;
        this.AvgLatitude = CAvLati;
        this.HasDaylightSavings = CHasDay;
        this.TimeZone = CTZone;
        this.AreaCode = CArCode;
        
        //DPV Information
        this.DPVConfirmation = CDPVCon;
        this.DPVCrma = CDPVCrma;
        this.DPVFootnote1 = CDPVfoot1;
        this.DPVFootnote2 = CDPVfoot2;
        this.DPVFootnote3 = CDPVfoot3;
        this.DPVNoStat = CDPVStat;
        this.DPVVacant = CDPVVac;
        this.ReturnCode = CDYNERet;
        
    }
    public CDYNEInformation(Map<String, String> mapReturnCode, String CDYNERet, String zip6, String CStreet, String CCity, String CState, String CZip,String Ccounty ,String status, String result){
       //
       if(CDYNERet == '100') // All others are "Failure" codes, aka, the ones WE consider as failures as they do not yield a Valid Zip+6
       {
            this.status = 'Success';
       }
       else
       {
            this.status = 'Failure';
       }
       if(mapReturnCode.get(CDYNERet) != null)
       {
           this.description = mapReturnCode.get(CDYNERet);
       }
       this.street = CStreet;
       this.city = CCity;
       this.state = CState;
       this.postalcode = CZip;
       this.zipplussix = zip6;
       this.county=Ccounty;
    }
    
    public CDYNEInformation(Map<String, String> mapReturnCode, String CDYNERet, String zip6, String CStreet, String CCity, String CState, String CZip, String Ccounty,String status, String result
    , String CCongress, String CSLUpper, String CSLLower, String CFlongi, String CFLati, String CTlongi, String CTlati, String CAvLongi, String CAvLati, String CHasDay, String CTZone, String CArCode){
       //
       if(CDYNERet == '100') // All others are "Failure" codes, aka, the ones WE consider as failures as they do not yield a Valid Zip+6
       {
            this.status = 'Success';
       }
       else
       {
            this.status = 'Failure';
       }
       if(mapReturnCode.get(CDYNERet) != null)
       {
           this.description = mapReturnCode.get(CDYNERet);
       }
       this.street = CStreet;
       this.city = CCity;
       this.state = CState;
       this.postalcode = CZip;
       this.zipplussix = zip6;
       this.county=Ccounty;
        //LegislativeInfo: and GeoLocationInfo:
        this.CongressDistrictNumber =  CCongress;
        this.StateLegislativeUpper = CSLUpper;
        this.StateLegislativeLower = CSLLower;
        this.Fromlongitude = CFlongi;
        this.FromLatitude = CFLati;
        this.ToLongitude = CTlongi;
        this.ToLatitude =  CTlati;
        this.AvgLongitude = CAvLongi;
        this.AvgLatitude = CAvLati;
        this.HasDaylightSavings = CHasDay;
        this.TimeZone = CTZone;
        this.AreaCode = CArCode;
        
    }
}

}