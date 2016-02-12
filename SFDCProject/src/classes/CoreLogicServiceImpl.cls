public class CoreLogicServiceImpl extends BaseClass implements CoreLogicService {
    
    private static Integer MaxPayloadSize = 130000;
    private static String authEndPoint = Sf.settingsService.getString('CoreLogicAuthEndpoint', 'http://sws.corelogic.com/api/v3.0.0/authenticate');
    private static String parcelsEndPoint = Sf.settingsService.getString('CoreLogicParcelsEndpoint', 'http://sws.corelogic.com/api/v3.0.0/parcels');
    private static String featuresEndPoint = Sf.settingsService.getString('CoreLogicFeaturesEndpoint', 'http://sws.corelogic.com/api/v3.0.0/features');
    private static Map<String, String> httpHeaders = new Map<String, String> {'Content-Type' => 'application/json'};
    private static String authKey;
    public static Map<Id, String> accountsProcessed = new Map<Id, String>();
    
    public void handleAccountsTrigger() {
        if (Trigger.isInsert || Trigger.isUpdate) {
            List<Account> accountsToBeProcessed = new List<Account>();
            
            for (Integer i = 0; i < Trigger.new.size(); i++) {
                Account oldAccount = (Account) (Trigger.old==null?null:Trigger.old.get(i));
                Account newAccount = (Account) Trigger.new.get(i);
                
                if (Trigger.isBefore) {
                    if (isNullOrZero(newAccount.Latitude__c) 
                        	|| isNullOrZero(newAccount.Longitude__c)
                       		|| isCoreLogicSyncRequired(oldAccount, newAccount)) {
	                    clearCoreLogicFields(newAccount);
                    }
                } else {
                    if (isCoreLogicSyncRequired(oldAccount, newAccount)) {
                        //If we have submitted already this account for processing in this transaction, 
                        //then let's not process again.
                        if (!accountsProcessed.containsKey(newAccount.id)) {
                            accountsToBeProcessed.add(newAccount);
                            accountsProcessed.put(newAccount.id, '');
                        }
                    }
                }
            }
            
            if (!accountsToBeProcessed.isEmpty()) {
                Sf.syncService.insertSyncRecords(CoreLogicServiceDto.SyncModule, CoreLogicServiceDto.SyncAction, accountsToBeProcessed);
                Sf.commonScheduler.runJobAfterMins('CoreLogicJob', Sf.settingsService.getInteger('CoreLogicJobRealtimeDelayMins', 1));
            }
        }
    }
    
    public Boolean isCoreLogicSyncRequired(Account oldAccount, Account newAccount) {
        return !isNullOrZero(newAccount.Latitude__c) 
            		&& !isNullOrZero(newAccount.Longitude__c)
            		&& (oldAccount == null 
                        || isChanged(oldAccount, newAccount, new String[]{'Latitude__c', 'Longitude__c'}));
    }
    
    public void clearCoreLogicFields(Account account) {
        account.Primary_Title__c = null;
        account.Secondary_Title__c = null;
        account.Land_Use__c = null;
        account.Legal_Description__c = null;
        account.Incorporation_Flag__c = null;
        account.City_Type__c = null;
        account.Geometry__c = null;
    }
    
    public void processJob(SyncJobInfo syncJob) {
        
        if (!isCoreLogicEnabled()) {
            syncJob.setBatch(syncJob.syncRecords).syncFailed('Core Logic Not Enabled');
            return;
        }
        
        DbChangesWoSharing dbChanges = new DbChangesWoSharing();
        List<Account> accounts = queryAccounts(syncJob.getRecordIds());
        
        for (Account account : accounts) {
            
            //We need three callouts to complete a txn so if we don't have that quota, we will skip it.
            if (getCalloutsQuota() < 3) {
                break;
            }
            
            try {
                syncJob.setBatch(account.id);
                syncJob.log('Processing account ' + account + ' to retrieve core logic details');
                
                if (isNullOrZero(account.Latitude__c) || isNullOrZero(account.Longitude__c)) {
                    syncJob.syncFailed('Invalid Latitude or Longitude');
                    continue;
                }
                
                JsonReader parcels = getParcels(account.Latitude__c, account.Longitude__c, syncJob);
                JsonReader features = getFeatures(account.Latitude__c, account.Longitude__c, syncJob);
                
                parcels.with('parcels[0]');
                
                account.Primary_Title__c = (parcels.getString('OWN1_FRST', '') 
                                            + ' ' + parcels.getString('OWN1_LAST', '')).trim();
    
                account.Secondary_Title__c = (parcels.getString('OWN2_FRST', '') 
                                            + ' ' + parcels.getString('OWN2_LAST', '')).trim();
                
                account.Land_Use__c = parcels.getString('LAND_USE');
    
                //Yes, we are defaulting to string "null" per requirement.
                account.Legal_Description__c = parcels.getString('LEGAL1', 'null');

                //BSKY-6500
                account.Geometry__c = parcels.getString('GEOM');
                                
                account.Incorporation_Flag__c = decodeIncorporationFlag(features);
                
                account.City_Type__c = features.getString('AdminLocation.cityType', 'null');
                
                syncJob.syncSuccess();
                dbChanges.add(account);
            } catch (Exception e) {
                syncJob.handleException(e);
            }
        }
        
        //Update proposals with title information.
        dbChanges.add(updateProposals(accounts));
        
        //It could happen that by the time we pick the record for processing, record has already been deleted.
        //We will identify such records and mark them as Not Applicable Record Deleted.
        syncJob.markRecordsForSourceDeletes(getIdMap(accounts));
        
        dbChanges.save();
    }
    
    public String decodeIncorporationFlag(JsonReader features) {
        String value = features.getString('AdminLocation.incorporationFlag', '');
        if (value == '0') {
            value = 'No';
            
        } else if (value == '1') {
            value = 'Yes';

        } else {
            //Yes business wants null if value doesn't match
            value = 'null';
        }
        
        return value;
    }

    public List<Proposal__c> updateProposals(List<Account> accounts) {
        Map<Id, SObject> accountsMap = getIdMap(accounts);
        List<Proposal__c> proposals = queryProposals(accountsMap.keySet());
        for (Proposal__c proposal : proposals) {
            Account account = (Account) accountsMap.get(proposal.Opportunity__r.AccountId);
            proposal.Name_on_title__c = join(account.Primary_title__c, account.Secondary_title__c, ',');
        }
        
        return proposals;
    }
    
    public Boolean isCoreLogicEnabled() {
        return Sf.settingsService.getBoolean('CoreLogicEnabled', false);
    }
    
    public List<Account> queryAccounts(List<Id> accountIds) {
        return [
            select
                Id,
                Longitude__c,
                Latitude__c,
                Primary_Title__c,
                Secondary_title__c
            from Account 
            where id = :accountIds
        ];        
    }
    
    public List<Proposal__c> queryProposals(Set<Id> accountIds) {
        return [
            select 
                id,
                Name_on_title__c,
                Opportunity__r.AccountId 
            from Proposal__c 
            where Opportunity__r.AccountId in :accountIds
        ];
    }
    
    public JsonReader getParcels(Decimal latitude, Decimal longitude, SyncJobInfo syncJob) {
        Map<String, String> parms = new Map<String, String>{
            'lat' => '' + latitude,
            'lon' => '' + longitude,
            'pageNumber' => '1',
            'pageSize' => '4',
            'bundle' => 'SpatialRecordUTPro',
            'authKey' => getAuthKey()
        };
        
        HttpDetails details = httpGetDetails(parcelsEndPoint, httpHeaders, parms, null);
        String detailsLog = details.toString();
        if (detailsLog.length() <= MaxPayloadSize) {
            syncJob.log(detailsLog);
        } else {
            syncJob.log('Response is too huge [' + detailsLog.length() + ' bytes] so it is not logged. Request ' + details.getRequestDetails());
        }
         
        return new JsonReader(details.response.getBody());
    }
    
    public JsonReader getFeatures(Decimal latitude, Decimal longitude, SyncJobInfo syncJob) {
        Map<String, String> parms = new Map<String, String>{
            'lat' => '' + latitude,
            'lon' => '' + longitude,
            'include' => 'GeneralPropertyTax',
            'authKey' => getAuthKey()
        };

        HttpDetails details = httpGetDetails(featuresEndPoint, httpHeaders, parms, null);
        String detailsLog = details.toString();
        if (detailsLog.length() <= MaxPayloadSize) {
            syncJob.log(detailsLog);
        } else {
            syncJob.log('Response is too huge [' + detailsLog.length() + ' bytes] so it is not logged. Request ' + details.getRequestDetails());
        }

        return new JsonReader(details.response.getBody());
    }

    public String getAuthKey() {
        if (authKey == null) {
            //Core logic doesn't recognize payload if username doesn't come as first attribute
            String payload = '{"username":"' + Sf.settingsService.getString('CoreLogicUserName') 
                + '","password":"' + Sf.settingsService.getString('CoreLogicPassword') + '"}';
            
            String resp = httpPost(authEndPoint, payload, httpHeaders);
            authKey = new JsonReader(resp).getString('authKey');
        }
        
        return authKey;
    }
}