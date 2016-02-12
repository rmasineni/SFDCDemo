public with sharing class AddressServiceImpl extends BaseClass implements AddressService {

    /**
     * This is the maximum size of the Lead/Account fields which stores the detailed message Address_Standardization_Google_Message__c
     * or Address_Standardization_Cdyne_Message__c etc. If the text is longer than this, it is truncated.
     */ 
    public static Integer MaxMessageSize = 131050;
    
    public static String GoogleMapsGeocodeApiEndPoint = Sf.settingsService.getString('GoogleMapsGeocodeApiEndPoint',
        'https://maps.googleapis.com/maps/api/geocode/json?sensor=false&components=country:US&address={address}'); 
    
    public static String GoogleMapsDistanceMatrixApiEndPoint = Sf.settingsService.getString('GoogleMapsDistanceMatrixApiEndPoint',
		'https://maps.googleapis.com/maps/api/distancematrix/json?mode=drive&units=imperial&origins={origins}&destinations={destinations}');

    public static String GoogleMapsTimezoneApiEndPoint = Sf.settingsService.getString('GoogleMapsTimezoneApiEndPoint',
        'https://maps.googleapis.com/maps/api/timezone/json?location={location}&timestamp={timestamp}');
    
    public static String CdyneVerifyAddresApiEndPoint = Sf.settingsService.getString('CdyneVerifyAddresApiEndPoint',
        'http://pav3.cdyne.com/PavService.svc/VerifyAddressAdvanced');

    public static Boolean AddressStandardizationCDyneSecondary = Sf.settingsService.getBoolean('AddressStandardizationCDyneSecondary', false);

    Map<String, String> timezoneIdToShortNameMap = new Map<String, String>{
        'America/Phoenix' => 'MST',
        'America/New_York' => 'EST',
        'America/Los_Angeles' => 'PST',
        'America/Denver' => 'MST',
        'America/Chicago' => 'CST',
        'America/Anchorage' => 'AST',
        'America/Adak' => 'HST',
        'Pacific/Honolulu' => 'HST'
    };

    Map<String, Boolean> timezoneIdToHasDstMap = new Map<String, Boolean>{
        'America/Phoenix' => false,
        'America/New_York' => true,
        'America/Los_Angeles' => true,
        'America/Denver' => true,
        'America/Chicago' => true,
        'America/Anchorage' => true,
        'America/Adak' => true,
        'Pacific/Honolulu' => false
    };

    //This map is used to keep a list of all records which are processed already by a trigger in this transaction. If it is already processed
    //then we will not take this for processing again.
	public static Map<Id, String> recordsProcessedMap = new Map<Id, String>();
        
    public Boolean isAddressStandardizationForLeadsEnabled() {
        return Sf.settingsService.getBoolean('AddressStandardizationForLeadsEnabled', false); //Default false
    }
    
    public Boolean isAddressStandardizationForAccountsEnabled() {
        return Sf.settingsService.getBoolean('AddressStandardizationForAcctsEnabled', false); //Default false
    }

    public String getTriggerType() {
        return (Trigger.isBefore?'Before':'After') + (Trigger.isInsert?'Insert':'Update');
    }
    
    public void handleLeadsTrigger() {
        
        info('Coming to Address Service handle leads trigger [' + getTriggerType() + '] for ' + Trigger.new + ' ' + getStackTrace());
        
        //1) If this is insert
        //2) If this is update and if any of the address components changed (even if the it is just a case change)
        //3) If this is update and if Override flag is changed
        if (Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate))  {
            for (Integer i = 0; i < Trigger.new.size(); i++) {
                
                Lead oldLead = null;
                if (Trigger.old != null) {
                    oldLead = (Lead) Trigger.old.get(i);
                }

                Lead newLead = (Lead) Trigger.new.get(i);
                
                if (recordsProcessedMap.containsKey(newLead.id)) {
                    info('Lead Id [' + newLead.id + '] is present in the Processed Records map indicating it was already processed in this transaction and hence not processing it again.');
                    continue;
                }

                if (equalsIc(newLead.Address_Standardization_Status__c, AddressServiceDto.Status_StandardizedByUI)) {
                    //If this lead is standardized by UI, then we will leave the status as is. Batch will pick up the
                    //lead, run through the standardization, but keeps the Lat/Lng same as picked in UI
                    
                } else if (equalsIc(newLead.Address_Standardization_Status__c, AddressServiceDto.Status_DetailsRequired)) {
                    //If this lead is marked as details requried, it means we need to retrieve all details except
                    //address details. We will leave the status as is. Batch will pick up the
                    //lead, run through the standardization, and retrieves the details

                } else if ((Trigger.isInsert && isEmpty(newLead.Address_Standardization_Status__c))
                         || (Trigger.isUpdate && isChanged(oldLead.Address_Standardization_Override__c, newLead.Address_Standardization_Override__c))
                         || (Trigger.isUpdate && isAddressUpdated(oldLead, newLead))) {
                    //Otherwise, we will mark the lead as Standardization required, if it is new lead or if override flag is
                    //updated or if address is updated.
                    System.debug('Lead address is new or updated between oldLead=' + oldLead + ', newLead=' + newLead);
                    newLead.Address_Standardization_Status__c = AddressServiceDto.Status_StandardizationRequired;
                }
                
                //If install branch is changed,then mark the status as such
                if (oldLead != null && isChanged(oldLead.Install_Branch_Id__c, newLead.Install_Branch_Id__c)) {
                    newLead.Address_Driving_Details_Status__c = AddressServiceDto.Status_DrivingDetailsToBeCalculated;
                }
            }
        }

        if (isAddressStandardizationForLeadsEnabled()) {
            //In the after insert, and after update call, will call the future method if it is not already running from future or batch
            if (!System.isBatch() && !System.isFuture() && Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)) {
                List<Lead> leadsToStandardize = new List<Lead>();
                for (Integer i = 0; i < Trigger.new.size(); i++) {
                    
                    Lead oldLead = null;
                    if (Trigger.old != null) {
                        oldLead = (Lead) Trigger.old.get(i);
                    }
    
                    Lead newLead = (Lead) Trigger.new.get(i);
                    
                    if (recordsProcessedMap.containsKey(newLead.id)) {
                        info('Lead Id [' + lead.id + '] is present in the Processed Records map indicating it was already processed in this transaction and hence not processing it again.');
                        continue;
                    }
                    recordsProcessedMap.put(newLead.id, '');

                    if (newLead.Address_Standardization_Status__c == AddressServiceDto.Status_StandardizationRequired 
                        	|| newLead.Address_Standardization_Status__c == AddressServiceDto.Status_StandardizedByUI
                    		|| newLead.Address_Standardization_Status__c == AddressServiceDto.Status_StandardizationError
                            || newLead.Address_Driving_Details_Status__c == AddressServiceDto.Status_DrivingDetailsToBeCalculated
                            || newLead.Address_Standardization_Status__c == AddressServiceDto.Status_DetailsRequired) {
                        leadsToStandardize.add(newLead);
                    }
                }
                
                if (!leadsToStandardize.isEmpty()) {
                    List<Id> leadIds = getUniqueIdList(leadsToStandardize);
                    info('Starting the Address Standardization Future Job for lead ids ' + leadIds);
                    AddressServiceImpl.standardizeLeadsAddressAsFuture(leadIds);
                    //System.enqueueJob(new AddressServiceDto.AddressStandardizationLeadsJob(getUniqueIdList(leadsToStandardize, 'Id')));
                }
            }
        } else {
            debug('Address standardization is not enabled and hence not kicking off the future jobs.');
        }
    }

    /**
     * Standardizes the address component of specified lead. See standardizeAddress method for details
     * about address standardization itself.
     * 
     * Method reads Street, City, State, Postal Code and Country fields and updates back following fields.
     * 
     * For each lead, process makes upto 3 outbound calls, 1 select and upto 1 dml query. Considering
     * these, this method must be called only upto 25 leads (with Winter15 max callouts is 100)
     */ 
    public void standardizeLeadsAddress(List<Id> leadIds) {
        
        if (!isAddressStandardizationForLeadsEnabled()) {
            debug('Address standardization is not enabled and not processing the standardization request for lead ids ' + leadIds);
            return;
        }
        
        List<Lead> leads = [select 
                Id, 
                Street, 
                City, 
                State, 
                PostalCode, 
                Country,
                County__c,
                CongressDistrictNumber__c,
                StateLegislativeUpper__c,
                StateLegislativeLower__c,
                Longitude__c,
                Latitude__c,
                HasDaylightSavings__c,
                TimeZone__c,
                AreaCode__c,
                Address_Standardization_Source__c,
                Address_Standardization_Status__c,
                Address_Standardization_Override__c,
                Address_Token__c,
                IsConverted,
                Install_Branch_Id__r.Address_Standardization_Status__c,
                Install_Branch_Id__r.Latitude__c,
                Install_Branch_Id__r.Longitude__c,
                Install_Branch_Id__r.BillingStreet, 
                Install_Branch_Id__r.BillingCity, 
                Install_Branch_Id__r.BillingState, 
                Install_Branch_Id__r.BillingPostalCode, 
                Install_Branch_Id__r.BillingCountry
            from Lead 
            where id = :leadIds
                  and IsConverted=false
            order by LastModifiedDate];
        
        for (Lead lead : leads) {
            System.debug('Address standardizing lead ' + lead);
            
            if (lead.Address_Standardization_Override__c) {
                lead.Address_Standardization_Status__c = AddressServiceDto.Status_StandardizationOverridden;
                continue;
            }

            if (lead.Address_Standardization_Status__c == AddressServiceDto.Status_Standardized) {
                debug('Lead has already been standardized hence skipping the standardization. ' + lead);
                continue;
            }
            
            //We will standardize the leads address but will not calculate the install branch distance as
            //we will do that for all leads at end of this method.
            standardizeLeadsAddress(lead, false);
            
            //We will add this lead to processed records so we will run through the trigger again.
			recordsProcessedMap.put(lead.id, '');
        }
        
        //Calculate the address before creating address token as address could make dml resulting
        //in blocking the webservice calls
        for (Lead lead : leads) {
            calculateDrivingDistanceToInstallBranch(lead);
        }

        update leads;
    }
    
    public void standardizeLeadsAddress(Lead lead, Boolean calulcateDistanceToInstallBranch)  {
        AddressServiceDto.StandardizeAddressResponse resp =  standardizeAddress(
            new AddressServiceDto.Address(lead.Street, lead.City, lead.State, lead.PostalCode, lead.Country));
        
        //Copy the address fields only if it is success so that we will not empty out 
        //the old data. However, we will empty out the derived info like timezone etc.
        
        //If address status is makred as Detail required, then don't overwrite the address.
        if (lead.Address_Standardization_Status__c == AddressServiceDto.Status_DetailsRequired) {
            //Don't copy the address fields
            
        } else if (resp.status == AddressServiceDto.Status_Standardized) {
            //Else copy the address fields, only if response is successful.
            lead.Street = resp.address.street;
            lead.City = resp.address.city;
            lead.State = resp.address.state;
            lead.postalCode = resp.address.postalCode;
            lead.Country = resp.address.country;
        }
        
        copyStandardizationResponseToSObject(resp, lead);
        
        //This concatinated address segments field is used by external integration system and hence needs to be updated with latest address info.
        //Ideally, this would need to be updated to match the standard address represetnation with comma and all, but for now will keep it to match
        //current format.            
        lead.Cdyne_Address__c = createLegacyAddressString(new AddressServiceDto.Address(lead.Street, lead.City, lead.State, lead.PostalCode));
        
        System.debug('Address standardized the lead ' + lead);
        
        if (calulcateDistanceToInstallBranch) {
            calculateDrivingDistanceToInstallBranch(lead);
        }
    }
        
    public void standardizeLeadsAddressWithoutSave(Lead lead)  {   
        standardizeLeadsAddress(lead, true);
    }
    
    @Future(callout=true)
    public static void standardizeLeadsAddressAsFuture(List<Id> leadIds) {
        Sf.addressService.standardizeLeadsAddress(leadIds);
    }
    
    public void calculateDrivingDistanceToInstallBranch(Lead lead) {
        lead.Driving_Distance_to_Install_Branch__c = null;
        lead.Driving_Time_to_Install_Branch__c = null;
        
        //In class, lead_install_Branch_Sunrun code is looking for Install_Partner__c an Account Id as specified in label.
        //As we are using Tests which doesn't rely on org data, it is difficult to create an account with same id as in label
        //or update label temporarily, to match the id of account we created. This is an example of why labels are not a
        //good idea for settings values but they should be using Custom Settings, especially SettingsService, which makes it
        //very easy.
        //
        //So to overcome that, we will assign a custom id if we are running in test.
        if (Test.isRunningTest()) {
            String installBranchId = (String) BaseClass.testParams.get('Install_Branch_Id__c');
            if (isNotEmpty(installBranchId)) {
                lead.Install_Branch_Id__c = installBranchId;
            }
        }

        System.debug('Calcuting the driving details to install branch for lead ' + lead);
        if (isEmpty(lead.Install_Branch_Id__c)) {
            lead.Address_Driving_Details_Status__c = AddressServiceDto.Status_DrivingDetailsMissingInstallBranch;
            return;
        }
        
        //Check if lead status and account address status is either standardized or overridden
        String origin = createAddressString(new AddressServiceDto.Address(lead.Street, lead.City, lead.State, lead.PostalCode));
        Account installBranch = lead.Install_Branch_Id__r;
        if (Test.isRunningTest()) {
            Account installBranchTest = (Account) BaseClass.testParams.get('Install_Branch_Id__r');
            if (installBranchTest != null) {
                installBranch = installBranchTest;
            }
        }
        
        String destination = null;
        if (installBranch != null) {
            destination = createAddressString(new AddressServiceDto.Address(installBranch.BillingStreet, 
                installBranch.BillingCity, installBranch.BillingState, installBranch.BillingPostalCode));
        }
        
        System.debug('origin=' + origin);
        System.debug('destination=' + destination);
        if (isEmpty(origin) || isEmpty(destination)) {
            lead.Address_Driving_Details_Status__c = AddressServiceDto.Status_DrivingDetailsAddressMissing;
            return;
        }

        AddressServiceDto.DrivingDetails drivingDetails =  calculateDrivingDetails(new AddressServiceDto.DrivingDetails(origin, destination));
        lead.Address_Driving_Details_Status__c = drivingDetails.status;
        
        if (drivingDetails.status == AddressServiceDto.Status_DrivingDetailsCalculated) {
            lead.Driving_Distance_to_Install_Branch__c = drivingDetails.distanceText;
            lead.Driving_Time_to_Install_Branch__c = drivingDetails.drivingTimeText;
        }
        
        if (drivingDetails.message != null){
            drivingDetails.message = drivingDetails.message.left(MaxMessageSize);
        }
        lead.Address_Driving_Details_Message__c = drivingDetails.message;
    }
    
    public void handleAccountsTrigger() {
        //1) If this is insert
        //2) If this is update and if any of the address components changed (even if the it is just a case change)
        //3) If this is update and if Override flag is changed
        if (Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate))  {
            for (Integer i = 0; i < Trigger.new.size(); i++) {
                Account oldAccount = null;
                if (Trigger.old != null) {
                    oldAccount = (Account) Trigger.old.get(i);
                }
                
                Account newAccount = (Account) Trigger.new.get(i);
                
                debug('Handling the trigger for account ' + newAccount);
                if (recordsProcessedMap.containsKey(newAccount.id)) {
                    info('Account Id [' + newAccount.id + '] is present in the Processed Records map indicating it was already processed in this transaction and hence not processing it again.');
                    continue;
                }
                
                if (equalsIc(newAccount.Address_Standardization_Status__c, AddressServiceDto.Status_StandardizedByUI)) {
                    //If this lead is standardized by UI, then we will leave the status as is. Batch will pick up the
                    //lead, run through the standardization, but keeps the Lat/Lng same as picked in UI
                    
                } else if (equalsIc(newAccount.Address_Standardization_Status__c, AddressServiceDto.Status_DetailsRequired)) {
                    //If this account is marked as details required, it means we need to retrieve all details except
                    //address details. We will leave the status as is. Batch will pick up the
                    //lead, run through the standardization, and retrieves the details
                   
                } else if ((Trigger.isInsert && isEmpty(newAccount.Address_Standardization_Status__c))
                         || (Trigger.isUpdate && isChanged(oldAccount.Address_Standardization_Override__c, newAccount.Address_Standardization_Override__c))
                         || (Trigger.isUpdate && isAddressUpdated(oldAccount, newAccount))) {
                    //Otherwise, we will mark the account as Standardization required, if it is new account or if override flag is
                    //updated or if address is updated.
                    System.debug('Account address is new or updated between oldAccount=' + oldAccount + ', newAccount=' + newAccount);
                    newAccount.Address_Standardization_Status__c = AddressServiceDto.Status_StandardizationRequired;
                }
            }
        }

        if (isAddressStandardizationForAccountsEnabled()) {
            if (!System.isBatch() && !System.isFuture() && Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)) {
                List<Account> accountsToStandardize = new List<Account>();
                for (Integer i = 0; i < Trigger.new.size(); i++) {
                    
                    Account oldAccount = (Account) (Trigger.old == null?null:Trigger.old.get(i));
                    Account newAccount = (Account) Trigger.new.get(i);
                    
                    if (recordsProcessedMap.containsKey(newAccount.id)) {
                        info('Account Id [' + newAccount.id + '] is present in the Processed Records map indicating it was already processed in this transaction and hence not processing it again.');
                        continue;
                    }
                    recordsProcessedMap.put(newAccount.id, '');

                    if (newAccount.Address_Standardization_Status__c == AddressServiceDto.Status_StandardizationRequired 
                        	|| newAccount.Address_Standardization_Status__c == AddressServiceDto.Status_StandardizedByUI
                        	|| newAccount.Address_Standardization_Status__c == AddressServiceDto.Status_StandardizationError
                            || newAccount.Address_Standardization_Status__c == AddressServiceDto.Status_DetailsRequired) {
		            	accountsToStandardize.add(newAccount);
                    }
                }
                
                if (!accountsToStandardize.isEmpty()) {
                    AddressServiceImpl.standardizeAccountsAddressAsFuture(getUniqueIdList(accountsToStandardize, 'Id'));
                }
            }
        } else {
            debug('Address standardization is not enabled and hence not kicking off the future jobs');
        }
    }
    
    @Future(callout=true)
    public static void standardizeAccountsAddressAsFuture(List<Id> accountIds) {
        Sf.addressService.standardizeAccountsAddress(accountIds);
    }

    /**
     * Standardizes the address component of specified accounts. See standardizeAddress method for details
     * about address standardization itself.
     * 
     * Method reads BillingStreet, BillingCity, BillingState, BillingPostal Code and BillingCountry fields and updates back following fields.
     * 
     * For each account, process makes upto 3 outbound calls, 1 select and upto 1 dml query. Considering
     * these, this method must be called only upto 30 accounts (with Winter15 max callouts is 100)
     */ 
    public void standardizeAccountsAddress(List<Id> accountIds) {
        
        if (!isAddressStandardizationForAccountsEnabled()) {
            debug('Address standardization is not enabled and not processing the standardization request for account ids ' + accountIds);
            return;
        }
        
        List<Account> accounts = [select 
                Id, 
                BillingStreet, 
                BillingCity, 
                BillingState, 
                BillingPostalCode, 
                BillingCountry,
                County__c,
                CongressDistrictNumber__c,
                StateLegislativeUpper__c,
                StateLegislativeLower__c,
                Longitude__c,
                Latitude__c,
                HasDaylightSavings__c,
                TimeZone__c,
                AreaCode__c,
                Address_Standardization_Source__c,
                Address_Standardization_Status__c,
                Address_Standardization_Override__c,
                Address_Token__c
            from Account 
            where id = :accountIds
            order by LastModifiedDate];

        for (Account account : accounts) {
            System.debug('Address standardizing account ' + account);
            
            if (account.Address_Standardization_Override__c) {
                account.Address_Standardization_Status__c = AddressServiceDto.Status_StandardizationOverridden;
                continue;
            }
            
            AddressServiceDto.StandardizeAddressResponse resp =  standardizeAddress(
                new AddressServiceDto.Address(account.BillingStreet, account.BillingCity, account.BillingState, 
                account.BillingPostalCode, account.BillingCountry));
            
            //Copy the address fields only if it is success so that we will not empty out 
            //the old data. However, we will empty out the derived info like timezone etc.
            //If address status is makred as Detail required, then don't overwrite the address.
            if (account.Address_Standardization_Status__c == AddressServiceDto.Status_DetailsRequired) {
                //Don't copy the address fields
                
            } else if (resp.status == AddressServiceDto.Status_Standardized) {
                //Else copy the address fields, only if response is successful.
                account.BillingStreet = resp.address.street;
                account.BillingCity = resp.address.city;
                account.County__c = resp.address.county; 
                account.BillingState = resp.address.state;
                account.BillingpostalCode = resp.address.postalCode;
                account.BillingCountry = resp.address.country;
            }
            
            copyStandardizationResponseToSObject(resp, account);
            
            //This concatinated address segments field is used by external integration system and hence needs to be updated with latest address info.
            //Ideally, this would need to be updated to match the standard address represetnation with comma and all, but for now will keep it to match
            //current format.            
            account.Cdyne_Address__c = createLegacyAddressString(new AddressServiceDto.Address(account.BillingStreet, account.BillingCity, account.BillingState, account.BillingPostalCode));
            
            //Without this validations will fail.
            if (Sf.settingsService.getBoolean('AddressStandardizationVoidProposals', false)) {
                account.Void_Proposals__c = true;
            }

			recordsProcessedMap.put(account.id, '');            
            System.debug('Address standardized the account ' + account);
        }

        update accounts;
    }
    
    /**
     * There are many fields which are common between lead and account where we need to copy
     * the standardization response. Instead of doing them twice, we will use this utility method
     * to copy all common fields and will handle the different fields in individual methods.
     */
    public void copyStandardizationResponseToSObject(AddressServiceDto.StandardizeAddressResponse resp, SObject sobj) {
        debug('Copying the address standardization response ' + resp +' to sobject ' + sobj);
        
        sobj.put('Address_Standardization_Source__c', resp.source);
        sobj.put('Address_Standardization_Confidence_Level__c', resp.confidenceLevel);
        
        if (resp.cdyneMessage != null){
            resp.cdyneMessage = resp.cdyneMessage.left(MaxMessageSize);
        }

        sobj.put('Address_Standardization_Cdyne_Message__c', resp.cdyneMessage);

        if (resp.googleMapsMessage != null){
            resp.googleMapsMessage = resp.googleMapsMessage.left(MaxMessageSize);
        }
        sobj.put('Address_Standardization_Google_Message__c', resp.googleMapsMessage);
    
        if (resp.addressAdditionalInfo == null) {
            resp.addressAdditionalInfo = new AddressServiceDto.AddressAdditionalInfo();
        }
        
        //We need latitude and longitude to identify the exact location where the solar panels would need
        //to be installed. If a home owner has big lot, the lat/lng returned through Google or CDyne
        //is typically the entrace of the lot. In such cases, the sales reps picks the correct lat/lng in the
        //UI. In such cases the status would be marked as Status_StandardizedByUI and then we should not
        //override the lat/lng they picked. So we will copy the lat/lng only if staut is not standardized by ui
        if (!equalsIc((String)sobj.get('Address_Standardization_Status__c'), AddressServiceDto.Status_StandardizedByUI)) {
        
            debug('Copying the lat/lng from Standardization into sobject with status ' + sobj.get('Address_Standardization_Status__c'));
            sobj.put('Latitude__c', resp.addressAdditionalInfo.latitude);
            sobj.put('Longitude__c', resp.addressAdditionalInfo.longitude);
        } else {
            debug('Lat/lng from Standardization process is not copying into sobject because status is set to ' + sobj.get('Address_Standardization_Status__c'));
        }
        
        sobj.put('TimeZone__c', resp.addressAdditionalInfo.timeZone);
        sobj.put('AreaCode__c', resp.addressAdditionalInfo.areaCode);
        sobj.put('HasDaylightSavings__c', String.valueOf(resp.addressAdditionalInfo.hasDaylightSavings));
        sobj.put('CongressDistrictNumber__c', resp.addressAdditionalInfo.congressionalDistrictNumber);
        sobj.put('StateLegislativeLower__c', resp.addressAdditionalInfo.stateLegislativeLower);
        sobj.put('StateLegislativeUpper__c', resp.addressAdditionalInfo.stateLegislativeUpper);
        sobj.put('Address_Token__c', resp.address == null?null:resp.address.addressToken);
        sobj.put('County__c', resp.address == null?null:resp.address.county);

        //copying the status should be last field, as original status would need to be maintained till now.
        sobj.put('Address_Standardization_Status__c', resp.status);
        
        debug('After copying the common address fields ' + sobj);
    }

    /**
     * Standardizes the given address using CDyne and Google Maps (if Cdyne is not successful).
     * 
     * Returns the standardized address response, which could contain additional information like timezone.
     */
    public AddressServiceDto.StandardizeAddressResponse standardizeAddress(AddressServiceDto.Address address) {
        DateTime startTime = DateTime.now();
        
        AddressServiceDto.StandardizeAddressResponse response = new AddressServiceDto.StandardizeAddressResponse();
        if (isEmpty(address.city) && isEmpty(address.state)) {
            response.status = AddressServiceDto.Status_StandardizationMissingAddress;
            return response;
        }
        
        //First we will standardize using google maps. If it is completed, then we will stll run thorugh cdyne but only take
        //the data elements not available through google like Upper Level and Lower level congress.
        //
        //If google is not successful, then we will run through cdyne and take all the information.
        response = standardizeUsingGoogleMaps(address);
        
        AddressServiceDto.CdyneResponse cdyneResponse = null;
        
        //If we could standardize using google maps, then use the standardized address to get additional info.
        //Else, use the original address to standardize and get additional info.
        //
        if (response.status == AddressServiceDto.Status_Standardized) {
            cdyneResponse = standardizeUsingCdyne(response.address);
            
            //Cdyne return codes (http://wiki.cdyne.com/index.php/PAVv3_Return_Codes), 100-103 indicates
            //that it found the match but may be some exact delivery point information is missing.
            //In this case, when we found a match using google, we are just looking for very high level info
            //like area code or congress info, so we just don't care for DPV level accuracy.
            if (cdyneResponse.ReturnCode == 100 || cdyneResponse.ReturnCode == 101 || cdyneResponse.ReturnCode == 103 || cdyneResponse.ReturnCode == 103) {
                response.addressAdditionalInfo.areaCode = cdyneResponse.geoLocationInfo.AreaCode;
                response.addressAdditionalInfo.congressionalDistrictNumber = cdyneResponse.legislativeInfo.CongressionalDistrictNumber;
                response.addressAdditionalInfo.stateLegislativeLower = cdyneResponse.legislativeInfo.StateLegislativeLower;
                response.addressAdditionalInfo.stateLegislativeUpper = cdyneResponse.legislativeInfo.StateLegislativeUpper;
            }
            
            //Copy the cdyne response message for any troubleshooting.
            response.cdyneMessage = cdyneResponse.responseMessage;
            
        } else if (AddressStandardizationCDyneSecondary) {
            
            //Standardize the address using cdyne only if that is meant as secondary
            cdyneResponse = standardizeUsingCdyne(address);

            //As we don't depend on dpv data, we will treat 100, 101, 102 and 103 as success.
            if (cdyneResponse.ReturnCode == 100 || cdyneResponse.ReturnCode == 101 || cdyneResponse.ReturnCode == 102 || cdyneResponse.ReturnCode == 103) {
                AddressServiceDto.StandardizeAddressResponse responseNew = new AddressServiceDto.StandardizeAddressResponse(cdyneResponse);
                responseNew.googleMapsMessage = response.googleMapsMessage;
                responseNew.source = 'CDyne';
                responseNew.status = AddressServiceDto.Status_Standardized;
                response = responseNew;
                
            } else if (cdyneResponse.ReturnCode == -1) {
                response.status = AddressServiceDto.Status_StandardizationError;
                
            } else {
                response.status = AddressServiceDto.Status_StandardizationNoMatch;
            }
            
            //Copy the cdyne response message for any troubleshooting.
            response.cdyneMessage = cdyneResponse.responseMessage;
        }

        if (response.status == AddressServiceDto.Status_Standardized) {
            response.address.addressToken = createAddressToken(response.address);
        }
        
        System.debug('Standardized the address ' + address + ' as [Status=' + response.status + ', Address=' + response.address + '] in ' + (DateTime.now().getTime() - startTime.getTime()) + ' ms. Complete response is ' + response);
        return response;
    }

    public AddressServiceDto.CdyneResponse standardizeUsingCdyne(AddressServiceDto.Address address) {
        //Cdyne Return codes.
        //1=>'Invalid Address',
        //10=>'Input Address is not found',
        //100=>'Input Address is DPV confirmed for all components',
        //101=>'Input Address is found, but not DPV confirmed',
        //102=>'Input Address Primary number is DPV confirmed. Secondary number is present but not DPV confirmed',
        //103=>'Input address Primary number is DPV confirmed, Secondary number is missing',
        //2=>'Invalid License Key',
        //200=>'Canadian address verified for all components',
        //202=>'Canadian address verified for all components except for the Secondary Number'
    
        System.debug('Standardizing the address using cdyne ' + address);

        AddressServiceDto.CdyneRequest cdyneReq = new AddressServiceDto.CdyneRequest(address);
        cdyneReq.LicenseKey = Sf.settingsService.getString('AddressStandardizationCdyneApiKey');
        
        AddressServiceDto.CdyneResponse cdyneResponse = new AddressServiceDto.CdyneResponse();
        try {
            String response = httpPost(CdyneVerifyAddresApiEndPoint, Json.serialize(cdyneReq),
                new Map<String, String>{'Content-Type' => 'application/json;charset=UTF-8', 'Accept'=>'application/json'});
            
            cdyneResponse = (AddressServiceDto.CdyneResponse) Json.deserialize(response, AddressServiceDto.CdyneResponse.class);
            cdyneResponse.Country = normalizeCountry(cdyneResponse.Country);
            cdyneResponse.responseMessage = Json.serializePretty(Json.deserializeUntyped(response));
            
            System.debug('CDyne Response ' + cdyneResponse);
        } catch (Exception e) {
            cdyneResponse.responseMessage = getStackTrace(e) +'\n\n' + cdyneResponse.responseMessage;
            cdyneResponse.returnCode = -1;
        }
        return cdyneResponse;
    }

    public AddressServiceDto.StandardizeAddressResponse standardizeUsingGoogleMaps(AddressServiceDto.Address address) {
        AddressServiceDto.StandardizeAddressResponse response = new AddressServiceDto.StandardizeAddressResponse();
        
        try {
            Map<String, String> parms = new Map<String, String>();
            parms.put('address', createAddressString(address));
            
            String geocodeResponse = googleMapsHttpGet(GoogleMapsGeocodeApiEndPoint, parms);
            
            response = parseGoogleGeocodeResponse(geocodeResponse, response);
            System.debug('Parsed Google Geocode Response ' + response);
            
            if (response.status == AddressServiceDto.Status_Standardized) {
                if (isEmpty(response.address.city) && isEmpty(response.address.state)) {
                    response.status = AddressServiceDto.Status_StandardizationNoMatch;
                } else {
                    getTimezoneFromGoogleMaps(response);
                }
            }
        } catch (Exception e) {
            response.googleMapsMessage = getStackTrace(e) + '\n\n' + response.googleMapsMessage;
            response.status = AddressServiceDto.Status_StandardizationError;
        }
        return response;
    }
    
    public AddressServiceDto.StandardizeAddressResponse parseGoogleGeocodeResponse(String geocodeResponse, AddressServiceDto.StandardizeAddressResponse response) {
        response.source = 'Google Maps';
        response.googleMapsMessage = geocodeResponse;

        //Here is the sample Google maps geocode result
        //http://pastebin.com/BiPFnSki

        JsonReader jsonobj = new JsonReader(geocodeResponse);
        String status = jsonObj.getString('status');
        
        //Goole maps returns various statuses. We need to take some actions based on each status.
        if (status != 'OK') {
            if (equalsIc(status, 'ZERO_RESULTS')) {
                response.status = AddressServiceDto.Status_StandardizationNoMatch;
                
            } else if (equalsIc(status, 'REQUEST_DENIED') 
                      || equalsIc(status, 'OVER_QUERY_LIMIT') //This happens when we have hit the daily quota. We need to wait till next day.
                      || equalsIc(status, 'UNKNOWN_ERROR')) {
                response.status = AddressServiceDto.Status_StandardizationError;
                
            } else if (equalsIc(status, 'INVALID_REQUEST')) {
                response.status = AddressServiceDto.Status_StandardizationMissingAddress;
                
            } else {
                response.status = AddressServiceDto.Status_StandardizationError;
            }

            return response;
        }
        
        //Even if the result is returned, we want to ensure we pickup only accurate address locations.
        //To ensure that we will look for location_type attribute and take the address only if it is ROOFTOP or RANGE_INTERPOLATED or others as configured
        //http://stackoverflow.com/questions/3015370/how-to-get-the-equivalent-of-the-accuracy-in-google-map-geocoder-v3
        response.confidenceLevel = jsonObj.getString('results[0].geometry.location_type');
        if (!equalsIcAny(response.confidenceLevel, Sf.settingsService.getStringList('AddressStandardizationLocationTypes', new String[]{'ROOFTOP', 'RANGE_INTERPOLATED'}))) {
            debug('Address Standardization Lat/Lng Confidence Level is ' + response.confidenceLevel 
                  + ', which is not configured to be acceptable and hence treating it as No Match');
            response.status = AddressServiceDto.Status_StandardizationNoMatch;
            return response;
        }
        
        //Go through the address components and assign the values to address object.        
        String streetNumber = null;
        String streetName = null;
        String aptNumber = null;
        
        JsonReader addressComponentObj = null;
        String longName= null;
        String shortName = null;
        List<Object> types = null;
        
        AddressServiceDto.Address newAddress = new AddressServiceDto.Address();
        for(Object obj : jsonObj.getList('results[0].address_components')) {
            addressComponentObj = new JsonReader(obj);
            longName = addressComponentObj.getString('long_name');
            shortName = addressComponentObj.getString('short_name');
            types = addressComponentObj.getList('types');
            
            if (isAddressType(types, 'street_number')) {
                streetNumber = longName;
                
            } else if (isAddressType(types, 'route')) { //street name
                streetName = shortName;
                
            } else if (isAddressType(types, 'subpremise')) { //Apt number
                aptNumber = longName;
                
            } else if (isAddressType(types, 'locality') || isAddressType(types, 'sublocality')) { //city
                newAddress.city = longName;
                
            } else if (isAddressType(types, 'administrative_area_level_2')) { // county
                
                //Google usually appends "County" at the end so let's  trim that.
                shortName = shortName.substringBeforeLast(' County');
                newAddress.county = shortName;

            } else if (isAddressType(types, 'administrative_area_level_1')) { // state
                newAddress.state = shortName;
                
            } else if (isAddressType(types, 'postal_code')) {
                newAddress.postalCode = longName;
                
            } else if (isAddressType(types, 'country')) {
                newAddress.country = normalizeCountry(shortName);
            }
        }

        newAddress.street = joinIfNotEmpty(streetNumber, streetName, ' ');
        System.debug('Street Number=' + streetNumber +', streetName=' + streetName + ', combined value=' + newAddress.street);
        if (isNotEmpty(aptNumber)) {
            newAddress.street = newAddress.street + ' #' + aptNumber;
        }
        
        response.address = newAddress;
        response.addressAdditionalInfo = new AddressServiceDto.AddressAdditionalInfo();
        response.addressAdditionalInfo.latitude = jsonObj.getDecimal('results[0].geometry.location.lat');
        response.addressAdditionalInfo.longitude = jsonObj.getDecimal('results[0].geometry.location.lng');
        response.status = AddressServiceDto.Status_Standardized;
        
        return response;
    }
    
    private Boolean isAddressType(List<Object> types, String type) {
        for(Object typeObj : types) {
            if (equalsIc(type, (String) typeObj)) { 
                return true;
            }
        }
        
        return false;
    }
    
    /**
     * Retrieves the timezone shortcode and if there is daylight savings in that timezone using
     * Google Timezone API. Google API returns TimezoneId, which is converted into short name
     * and hasdst based on the lookup map defined above.
     * 
     * If timezone information couldn't be retrieved, then those fields are left blank.
     * 
     * Sample response from Google for timezone is http://pastebin.com/qZKt9Vwh
     * https://maps.googleapis.com/maps/api/timezone/json?location=39.6034810,-119.6822510&timestamp=1331161200
     */
    public AddressServiceDto.StandardizeAddressResponse getTimezoneFromGoogleMaps(AddressServiceDto.StandardizeAddressResponse response) {
        Map<String, String> parms = new Map<String, String>();
        parms.put('location', response.addressAdditionalInfo.latitude + ',' + response.addressAdditionalInfo.longitude);
        parms.put('timestamp', String.valueOf(getCurrentDateTime().getTime()/1000));
        
        String timezoneResponse = googleMapsHttpGet(GoogleMapsTimezoneApiEndPoint, parms);
        AddressServiceDto.GoogleMapsTimezoneResponse resp = (AddressServiceDto.GoogleMapsTimezoneResponse) 
            Json.deserialize(timezoneResponse, AddressServiceDto.GoogleMapsTimezoneResponse.class);
        
        if (equalsIc(resp.status, 'ok')) {
            response.addressAdditionalInfo.timezone = timezoneIdToShortNameMap.get(resp.timeZoneId);
            response.addressAdditionalInfo.hasDaylightSavings = timezoneIdToHasDstMap.get(resp.timeZoneId);
        }
        
        return response;        
    }
    
    /**
     * Creates a http request, signs using configured client secret and sends the request to google. The url should be
     * complete url which contians the merge tokens (in the format {key}), which will be url encoded and replaced,
     * before signing the url.
     * 
     * Don't specify the client id or client secret as part of the parameters.
     */ 
    public String googleMapsHttpGet(String url, Map<String, String> params) {
        url = replaceMergeTokensWithUrlEncode(url, params);
        
        //Add client id.
        if (url.indexOf('?') >= 0) {
            url += '&';
        } else {
            url += '?';
        }
        
        url += 'client=' + Sf.settingsService.getString('GoogleMapsClientId');
        
        //We need to sign as specified at https://developers.google.com/maps/documentation/business/webservices/auth#digital_signatures
        //Remove the base path.
        String signUrl = url.substringAfter('https://maps.googleapis.com');
        String signature = urlSafeBase64Encode(Crypto.generateMac('hmacSHA1', Blob.valueOf(signUrl), EncodingUtil.base64Decode(Sf.settingsService.getString('GoogleMapsClientSecretKey'))));
        
        url += '&signature=' + signature;
        
        return httpGet(url);
    }
    
    public String createAddressToken(AddressServiceDto.Address address) {
        String token = normalizeAddressComponent(address.country);
        
        if (!isEmpty(address.state)) {
            token += addressSeparator(token) + normalizeAddressComponent(address.state);
        }
        
        if (!isEmpty(address.city)) {
            token += addressSeparator(token) + normalizeAddressComponent(address.city);
        }
        
        //For street we would need to extract building number and actual street name and
        //append in reverse order.
        if (!isEmpty(address.street)) {
            Pattern p = Pattern.compile('(^[0-9\\-]*)(.*)');
            Matcher pm = p.matcher(address.street);
            
            if( pm.matches()){
                //Get the matched street name and possible apartment information.
                String streetNameAndApt = pm.group(2);
                String buildingNumber = pm.group(1);
                String streetName = null;
                String aptNumber = null;
                
                if (streetNameAndApt != null) {
                    streetNameAndApt = streetNameAndApt.toUpperCase();
                
                    //From that, split the street name and apartment info. Apartment/Suite info would start with "#", assuming it is standardized.
                    streetName = streetNameAndApt.substringBefore('#').trim();
                    aptNumber = streetNameAndApt.substringAfter('#').trim();
                }
                   
                if (isNotEmpty(streetName)) {
                    token += addressSeparator(token) + normalizeAddressComponent(streetName);
                }

                if (isNotEmpty(buildingNumber)) {
                    token += addressSeparator(token) + normalizeAddressComponent(buildingNumber);
                }

                if (isNotEmpty(aptNumber)) {
                    token += addressSeparator(token) + normalizeAddressComponent(aptNumber);
                }
            }
        }
        
        String postalCode = address.postalCode;
        if (!isEmpty(postalCode)) {
            //Take only the first 5 digits of the zip code.
            if (postalCode.trim().length() > 5) {
                postalCode = postalCode.substring(0, 5);
            }
        
            token += addressSeparator(token) + normalizeAddressComponent(postalCode);
        }

        return token;      
    }

    public String addressSeparator(String token) {
        return isEmpty(token)?'':':';
    }
    
    public String normalizeAddressComponent(String value) {
        if (isEmpty(value)) {
            return '';
        }
        
        value = value.replaceAll('\t', ' ');
        
        //For some reason, replaceAll wasn't replacing all two space instances with one space
        //so put this in loop till all two spaces are converted into one space.
        while(value.indexOf('  ') >= 0) {
            value = value.replaceAll('  ', ' ');
        }
        
        return value.trim().toUpperCase();
    }

    public String normalizeCountry(String value) {
        if (isEmpty(value)) {
            return 'USA';
        }
        
        //Remove all .s in the coutnry to handle u.s. or u.s.a etc
        String newValue = value.trim().replaceAll('\\.', '');
        if (equalsIc(newValue, 'us')
           || equalsIc(newValue, 'usa')
           || equalsIc(newValue, 'united states')
            || equalsIc(newValue, 'united states of america')) {
            newValue = 'USA';
        } else {
            newValue = value;
        }
        
        return newValue;
    }

    public String createAddressString(AddressServiceDto.Address address) {
        String addressString = '';
        addressString = joinIfNotEmpty(addressString, address.Street, ', ');
        addressString = joinIfNotEmpty(addressString, address.City, ', ');
        addressString = joinIfNotEmpty(addressString, address.State, ', ');
        addressString = joinIfNotEmpty(addressString, address.PostalCode, ', ');
        addressString = joinIfNotEmpty(addressString, address.Country, ', ');
        
        return addressString;
    }
    
    /**
     * This method creates a address string to match the legacy format as stored in Cdyne_Address__c.
     * 
     * Here is a piece of code which copied that string
     * 
     * l.CDYNE_Address__c = l.Street + l.City + l.State + l.PostalCode;
     */
    public String createLegacyAddressString(AddressServiceDto.Address address) {
        String addressString = '';
        addressString = joinIfNotEmpty(addressString, address.Street, ', ');
        addressString = joinIfNotEmpty(addressString, address.City, ', ');
        addressString = joinIfNotEmpty(addressString, address.State, ', ');
        addressString = joinIfNotEmpty(addressString, address.PostalCode, ', ');
        
        return addressString;
    }
    
    public Boolean isAddressUpdated(Lead leadOld, Lead newLead) {
        if (isChanged(leadOld.street, newLead.street)
            || isChanged(leadOld.city, newLead.city)
            || isChanged(leadOld.state, newLead.state)
            || isChanged(leadOld.postalCode, newLead.postalCode)
            || isChanged(leadOld.country, newLead.country)) {
            
            debug('Address is not updated between old lead [' + leadOld + '] and new lead [' + newLead + ']');
            return true;
        }
        
        debug('Address is updated between old lead [' + leadOld + '] and new lead [' + newLead + ']');
        return false;
    }

    public Boolean isAddressUpdated(Account oldAccount, Account newAccount) {
        if (isChanged(oldAccount.Billingstreet, newAccount.Billingstreet)
            || isChanged(oldAccount.Billingcity, newAccount.Billingcity)
            || isChanged(oldAccount.Billingstate, newAccount.Billingstate)
            || isChanged(oldAccount.BillingpostalCode, newAccount.BillingpostalCode)
            || isChanged(oldAccount.Billingcountry, newAccount.Billingcountry)) {
            return true;
        }
        
        return false;
    }

    public Boolean isAddressUpdated(AddressServiceDto.Address addressOld, AddressServiceDto.Address addressNew) {
        if (isChanged(addressOld.street, addressNew.street)
            || isChanged(addressOld.city, addressNew.city)
            || isChanged(addressOld.state, addressNew.state)
            || isChanged(addressOld.postalCode, addressNew.postalCode)
            || isChanged(addressOld.country, addressNew.country)) {
            return true;
        }
        
        return false;
    }

    public Decimal calculateDistance(Decimal fromLat, Decimal fromLng, Decimal toLat, Decimal toLng){
        //Earth's radius varis from place to place as it is not perfect sphere. It could vary from 6,353 kms to 6,384 kms so we will
        //use the mean radius 6,371 kms (http://en.wikipedia.org/wiki/Earth_radius)
        Decimal earthRadius = 6371.00;
        
        Decimal distanceLat = convertToRadians(toLat - fromLat);
        Decimal distanceLng = convertToRadians(toLng - fromLng);
        
        Decimal a = Math.sin(distanceLat/2) * Math.sin(distanceLat/2) 
            + Math.cos(convertToRadians(fromLat)) * Math.cos(convertToRadians(toLat)) * Math.sin(distanceLng/2) * Math.sin(distanceLng/2);
        
        Decimal c = 2 * Math.asin(Math.sqrt(a));
    
        return earthRadius * c * 0.621371; //0.621371 is miles per km
    }

    public List<AddressServiceDto.DrivingDetails> calculateDrivingDetails(List<AddressServiceDto.DrivingDetails> drivingDetailsList) {
       	Integer batchSize = Sf.settingsService.getInteger('GoogleDistanceMatrixApiBatchSize', 20);
        if (drivingDetailsList.size() <= batchSize) {
            return calculateDrivingDetailsInBatch(drivingDetailsList);
        } else {
            List<AddressServiceDto.DrivingDetails> newDrivingDetailsList = new List<AddressServiceDto.DrivingDetails>();
	        List<List<Object>> batches = splitBySize(drivingDetailsList, batchSize);
            for (List<Object> batch : batches) {
                System.debug('Calculating the driving details for batch ' + batch);
                newDrivingDetailsList.addAll(calculateDrivingDetailsInBatch(batch));
            }
            
            return newDrivingDetailsList;
        }
    }
    
    public List<AddressServiceDto.DrivingDetails> calculateDrivingDetails(String origin, List<String> destinations) {
       	Integer batchSize = Sf.settingsService.getInteger('GoogleDistanceMatrixApiBatchSize', 20);
        if (destinations.size() <= batchSize) {
            return calculateDrivingDetailsInBatch(origin, destinations);
        } else {
            List<AddressServiceDto.DrivingDetails> newDrivingDetailsList = new List<AddressServiceDto.DrivingDetails>();
	        List<List<Object>> batches = splitBySize(destinations, batchSize);
            for (List<Object> batch : batches) {
                System.debug('Calculating the driving details for batch ' + batch);
                newDrivingDetailsList.addAll(calculateDrivingDetailsInBatch(origin, batch));
            }
            
            return newDrivingDetailsList;
        }
    }

    public List<AddressServiceDto.DrivingDetails> calculateDrivingDetailsInBatch(String origin, List<Object> destinations) {
        System.debug('Calculating the driving details from ' + origin + ' to ' + destinations);
		List<AddressServiceDto.DrivingDetails> responseList = new List<AddressServiceDto.DrivingDetails>();
        String distanceMatrixHttpResponse = null;
        try {
            
            String destinationString = null;
            for (Object destination : destinations) {
                if (destinationString == null) {
                    destinationString = (String) destination;
                } else {
                    destinationString += '|' + (String) destination;
                }
            }

            Map<String, String> parms = new Map<String, String>();
            parms.put('origins', origin);
            parms.put('destinations', destinationString);

            //Here is the sample Google maps Distance matrix api result
            //http://pastebin.com/SNkwt3sw
            distanceMatrixHttpResponse = googleMapsHttpGet(GoogleMapsDistanceMatrixApiEndPoint, parms);
            
            //Make sure overall status is okay and response status is okay
            JsonReader jsonReader = new JsonReader(distanceMatrixHttpResponse);
            if (isOk(jsonReader.getString('status'))) {
                
                for (Integer i = 0; i < destinations.size(); i++) {
                    AddressServiceDto.DrivingDetails drivingDetails = new AddressServiceDto.DrivingDetails();
                    drivingDetails.origin = origin;
                    drivingDetails.destination = (String) destinations.get(i);
                    
                    JsonReader detailsReader = jsonReader.getReader('rows[0].elements[' + i + ']');
                    if (isOk(detailsReader.getString('status'))) {
                        drivingDetails.status = AddressServiceDto.Status_DrivingDetailsCalculated;
                        drivingDetails.distanceText = detailsReader.getString('distance.text');
                        drivingDetails.distance = detailsReader.getInteger('distance.value');
                        drivingDetails.drivingTimeText = detailsReader.getString('duration.text');
                        drivingDetails.drivingTime = detailsReader.getInteger('duration.value');
                    } else {
                        drivingDetails.status = AddressServiceDto.Status_DrivingDetailsNoMatch;
                    }
                    
                    responseList.add(drivingDetails);
                }
            } else {
                throw new SystemException('Couldn\'t calculate the driving distance. Message [' + distanceMatrixHttpResponse + ']');
            }
        } catch (SystemException e) {
            throw e;
            
        } catch (Exception e) {
            throw new SystemException('Error while calculating the driving distance. Message [' + e.getMessage() + '] Response[' + distanceMatrixHttpResponse + ']', e);
        }
        
        System.debug('Returning the calculated driving details ' + responseList);
        return responseList;
    }
    
    public List<AddressServiceDto.DrivingDetails> calculateDrivingDetailsInBatch(List<Object> drivingDetailsList) {
        System.debug('Calculating the driving details for ' + drivingDetailsList);
		List<AddressServiceDto.DrivingDetails> responseList = new List<AddressServiceDto.DrivingDetails>();
        String distanceMatrixHttpResponse = null;
        try {
            
            String origins = null;
            String destinations = null;
            
            for (Object obj : drivingDetailsList) {
                AddressServiceDto.DrivingDetails driving = (AddressServiceDto.DrivingDetails) obj;
                if (origins == null) {
                    origins = driving.origin;
                } else {
                    origins += '|' + driving.origin;
                }

                if (destinations == null) {
                    destinations = driving.destination;
                } else {
                    destinations += '|' + driving.destination;
                }
            }
            
            Map<String, String> parms = new Map<String, String>();
            parms.put('origins', origins);
            parms.put('destinations', destinations);

            //Here is the sample Google maps Distance matrix api result
            //http://pastebin.com/SNkwt3sw
            distanceMatrixHttpResponse = googleMapsHttpGet(GoogleMapsDistanceMatrixApiEndPoint, parms);
            
            //Make sure overall status is okay and response status is okay
            JsonReader jsonReader = new JsonReader(distanceMatrixHttpResponse);
            if (isOk(jsonReader.getString('status'))) {
                
                for (Integer i = 0; i < drivingDetailsList.size(); i++) {
                    AddressServiceDto.DrivingDetails drivingDetails = (AddressServiceDto.DrivingDetails) drivingDetailsList.get(i);
                    
                    JsonReader detailsReader = jsonReader.getReader('rows[' + i + '].elements[' + i + ']');
                    if (isOk(detailsReader.getString('status'))) {
                        drivingDetails.status = AddressServiceDto.Status_DrivingDetailsCalculated;
                        drivingDetails.distanceText = detailsReader.getString('distance.text');
                        drivingDetails.distance = detailsReader.getInteger('distance.value');
                        drivingDetails.drivingTimeText = detailsReader.getString('duration.text');
                        drivingDetails.drivingTime = detailsReader.getInteger('duration.value');
                    } else {
                        drivingDetails.status = AddressServiceDto.Status_DrivingDetailsNoMatch;
                    }
                    
                    responseList.add(drivingDetails);
                }
            } else {
                throw new SystemException('Couldn\'t calculate the driving distance. Message [' + distanceMatrixHttpResponse + ']');
            }
        } catch (SystemException e) {
            throw e;
            
        } catch (Exception e) {
            throw new SystemException('Error while calculating the driving distance. Message [' + e.getMessage() + '] Response[' + distanceMatrixHttpResponse + ']', e);
        }
        
        System.debug('Returning the calculated driving details ' + responseList);
        return responseList;
    }
    
    public AddressServiceDto.DrivingDetails calculateDrivingDetails(AddressServiceDto.DrivingDetails drivingDetails) {
        System.debug('Calculating the driving details for ' + drivingDetails);
        try {
            drivingDetails = calculateDrivingDetails(new AddressServiceDto.DrivingDetails[]{drivingDetails}).get(0);
        } catch (Exception e) {
            drivingDetails.status = AddressServiceDto.Status_DrivingDetailsCalculationError;
            drivingDetails.message = getExceptionDetails(e);
        }
        
        System.debug('Returning the calculated driving details ' + drivingDetails);
        return drivingDetails;
    }

    public List<List<Object>> splitBySize(List<Object> objs, Integer sublistSize) {
        if (objs == null) {
            return null;
        }
        
        List<List<Object>> sublists = new List<List<Object>>();
        List<Object> sublist = null;

        if (objs.size() <= sublistSize) {
            sublists.add(objs);
            return sublists;
        }
        
        for (Object obj : objs) {
            if (sublist == null) {
                sublist = new List<Object>();
            }
            
            sublist.add(obj);
            if (sublist.size() >= sublistSize) {
                sublists.add(sublist);
                sublist = null;
            }
        }
        
        if (sublist != null) {
            sublists.add(sublist);
        }
        
        return sublists;
    }
    
}