public class AwsSyncServiceImpl extends BaseAwsService implements AwsSyncService {

    private static final String SqsQueueNotConfigured = 'SQS Queue Not Configured';
    private static final String EventOriginator = Sf.settingsService.getString('AwsSqsSyncEventOriginator', 'Salesforce');
    /**
     * Map is used to avoid the recursion of triggers and sending multiple updates to same record in this transaction.
     */
    public static final Map<Id, String> recordsProcessedInThisTxn = new Map<Id, String>();
    
    private static String sqsQueueUrl = null;
    private static AwsConfig awsConfig = null;
    
    public void handleLeadsTrigger() {
		handleTriggerForSqsSync(AwsSyncServiceDto.LeadsSync, false);
    }

    public void syncLeads(SyncJobInfo syncJob) {
        processSyncJob(syncJob);
    }
    
    public void handleOptysTrigger() {
		handleTriggerForSqsSync(AwsSyncServiceDto.OptysSync, false);
    }
    
    public void syncOptys(SyncJobInfo syncJob) {
        processSyncJob(syncJob);
    }
    
    public void handleContactsTrigger() {
        if (!isSqsSyncApplicable() || !isSqsSyncEnabled(AwsSyncServiceDto.OptysSync)) {
            return;
        }
        
        if (isAfterUpdate()) {
            insertSyncRecords(AwsSyncServiceDto.OptysSync, getOptysOfUpdatedContacts(Trigger.old, Trigger.new));
        }
    }
    
    public List<Opportunity> getOptysOfUpdatedContacts(List<Sobject> oldContacts, List<Sobject> newContacts) {
        List<Sobject> contactsWithChanges = getUpdatedRecords(oldContacts, newContacts, 
			Sf.settingsService.getStringList('AwsSqsContactsSyncTriggerFields', new List<String>()));

        List<OpportunityContactRole> optyRoles = [
            select OpportunityId 
            from OpportunityContactRole 
            where ContactId in :getUniqueIdList(contactsWithChanges)
       	];
        
        return [
            select Id, OwnerId
            from Opportunity 
            where Id in :getUniqueIdList(optyRoles, 'OpportunityId')
        ];
    }    
    
    public void handleAccountsTrigger() {
        if (!isSqsSyncApplicable() || !isSqsSyncEnabled(AwsSyncServiceDto.OptysSync)) {
            return;
        }
        
        if (isAfterUpdate()) {
            //Get Opportunities, linked to these accounts and sync them.
            List<Id> accountIds = getUniqueIdList(getUpdatedRecords(Trigger.old, Trigger.new, 
			Sf.settingsService.getStringList('AwsSqsAccountsSyncTriggerFields', new List<String>())));
            
            List<Opportunity> opties = [
                select Id, OwnerId
                from Opportunity 
                where AccountId in :accountIds];
            
            insertSyncRecords(AwsSyncServiceDto.OptysSync, opties);
        }
    }
    
    public void handlePaymentsTrigger() {
        info('Handling the Payment transactions trigger for Aws SQS Sync for records ' + Trigger.new);
        
        if (!isSqsSyncApplicable() || !isSqsSyncEnabled(AwsSyncServiceDto.PaymentsSync)) {
            return;
        }

        if (isAfterInsert()) {
            Map<Id, Sobject> optysWithSqsQueue = getIdMap([
                select id
                from Opportunity
                where id in :getUniqueIdList(Trigger.new, 'Opportunity__c')
                and (Lead_Gen_Partner__r.Sqs_Queue_Name__c != null 
                     or External_Source_Account__r.Sqs_Queue_Name__c != null)
            ]);
            
            List<Payment_Transaction__c> syncEligiblePayments = new List<Payment_Transaction__c>();
            for (Sobject sobj : Trigger.new) {
                Payment_Transaction__c tx = (Payment_Transaction__c) sobj;
                if (tx.Status__c == 'accept' 
                    && tx.Opportunity__c != null && optysWithSqsQueue.containsKey(tx.Opportunity__c)) {
                        syncEligiblePayments.add(tx);
                    }
            }
            
            insertSyncRecords(AwsSyncServiceDto.PaymentsSync, syncEligiblePayments);
        }
    }

    public void syncPayments(SyncJobInfo syncJob) {
        processSyncJob(syncJob);
    }    

    public void handleContractsTrigger() {
       info('Handling the Contracts trigger for Aws SQS Sync for records ' + Trigger.new);

        if (isAfterInsertOrUpdate()) {
            if (!isSqsSyncApplicable() || !isSqsSyncEnabled(AwsSyncServiceDto.ContractsSync)) {
                return;
            }
			
            //We need to sync when either it is inserted or updated with specified fields.
            List<Sobject> potentionalContracts = new List<Sobject>();
            if (Trigger.isInsert) {
                potentionalContracts = Trigger.new;
            } else {
                potentionalContracts = getUpdatedRecords(Trigger.old, Trigger.new, 
					Sf.settingsService.getStringList('AwsSqsContractsSyncTriggerFields', new List<String>()));
            }
            
            //If these contracts are already processed, then ignore them.
            potentionalContracts = removeObjectsMatchingIds(potentionalContracts, recordsProcessedInThisTxn);
            
            info('Potentional contracts to be sycned to sqs after filtering are ' + potentionalContracts);
            
            //Among these we need to check which are associated with opties, which have queue
            //configured. Only then, we will mark them as to be synced.
            Map<Id, Sobject> optysWithSqsQueue = getIdMap([
                select id
                from Opportunity
                where id in :getUniqueIdList(potentionalContracts, 'Opportunity__c')
                and (Lead_Gen_Partner__r.Sqs_Queue_Name__c != null 
                     or External_Source_Account__r.Sqs_Queue_Name__c != null)
            ]);
            
            info('Optys with queue map ' + optysWithSqsQueue);

            List<Sobject> syncEligibleContracts = new List<Sobject>();
            for (Sobject sobj : potentionalContracts) {
                ServiceContract contract = (ServiceContract) sobj;
                if (contract.Opportunity__c != null && optysWithSqsQueue.containsKey(contract.Opportunity__c)) {
					syncEligibleContracts.add(contract);
                }
            }
            
            insertSyncRecords(AwsSyncServiceDto.ContractsSync, syncEligibleContracts);
            
            //Will mark these contract ids as processed, so if trigger recurrs, we will not process them saving soqls.
            putAll(recordsProcessedInThisTxn, potentionalContracts);
        }
    }

    public void syncContracts(SyncJobInfo syncJob) {
        processSyncJob(syncJob);
    }    
    
    public void handleProposalsTrigger() {
       info('Handling the Proposals trigger for Aws SQS Sync for records ' + Trigger.new);

        if (isAfterInsertOrUpdate()) {
            if (!isSqsSyncApplicable() || !isSqsSyncEnabled(AwsSyncServiceDto.ProposalsSync)) {
                return;
            }
			
            //We need to sync when either it is inserted or updated with specified fields.
            List<Sobject> potentionalProposals = new List<Sobject>();
            if (Trigger.isInsert) {
                potentionalProposals = Trigger.new;
            } else {
                potentionalProposals = getUpdatedRecords(Trigger.old, Trigger.new, 
					Sf.settingsService.getStringList('AwsSqsProposalsSyncTriggerFields', new List<String>()));
            }
            
            //If these proposals are already processed, then ignore them.
            potentionalProposals = removeObjectsMatchingIds(potentionalProposals, recordsProcessedInThisTxn);
            
            //Among these we need to check which are associated with opties, which have queue
            //configured. Only then, we will mark them as to be synced.
            Map<Id, Sobject> optysWithSqsQueue = getIdMap([
                select id
                from Opportunity
                where id in :getUniqueIdList(potentionalProposals, 'Opportunity__c')
                and (Lead_Gen_Partner__r.Sqs_Queue_Name__c != null 
                     or External_Source_Account__r.Sqs_Queue_Name__c != null)
            ]);
            
            List<Sobject> syncEligibleProposals = new List<Sobject>();
            for (Sobject sobj : potentionalProposals) {
                Proposal__c proposal = (Proposal__c) sobj;
                if (proposal.Opportunity__c != null && optysWithSqsQueue.containsKey(proposal.Opportunity__c)) {
					syncEligibleProposals.add(proposal);
                }
            }
            
            insertSyncRecords(AwsSyncServiceDto.ProposalsSync, syncEligibleProposals);

            //Will mark these contract ids as processed, so if trigger recurrs, we will not process them saving soqls.
            putAll(recordsProcessedInThisTxn, potentionalProposals);
        }
    }

    public void syncProposals(SyncJobInfo syncJob) {
        processSyncJob(syncJob);
    }
    
    public void handleCreditsTrigger() {
        info('Handling the Credits trigger for Aws SQS Sync for records ' + Trigger.new);
        
        if (!isSqsSyncApplicable() || !isSqsSyncEnabled(AwsSyncServiceDto.CreditsSync)) {
            return;
        }

        if (isAfterInsert()) {
            Map<Id, Sobject> contactsWithOptyRoles = getIdMap([
                select
                    ContactId
                from OpportunityContactRole
                where ContactId in :getUniqueIdList(Trigger.new, 'Contact__c')
                    and (Opportunity.Lead_Gen_Partner__r.Sqs_Queue_Name__c != null or Opportunity.External_Source_Account__r.Sqs_Queue_Name__c != null)
            ], 'ContactId');
            
            List<Customer_Credit__c> syncEligibleRecords = new List<Customer_Credit__c>();
            for (Sobject sobj : Trigger.new) {
                Customer_Credit__c credit = (Customer_Credit__c) sobj;
                if (contactsWithOptyRoles.containsKey(credit.Contact__c)) {
					syncEligibleRecords.add(credit);
                }
            }
            
            insertSyncRecords(AwsSyncServiceDto.CreditsSync, syncEligibleRecords);
        }
    }
    
    public void syncCredits(SyncJobInfo syncJob) {
        if (!isSqsSyncEnabled(AwsSyncServiceDto.CreditsSync, syncJob)) {
            return;
        }

        String jobId = getRandomString();
        
        List<Sobject> credits = queryRecords(AwsSyncServiceDto.CreditsSync, syncJob.getRecordIds());
        
        //Map stores the contact id to list of OptyContactRoles. This is because
        //one contact could be associated with multiple opties and we should notify
        //all opties when that happens.
        Map<String, List<Sobject>> contactToOptyRoles = 
            groupBy(queryOptyContactRolesForContacts(getUniqueIdList(credits, 'Contact__c')), 'ContactId');
        
        for (Sobject sobj : credits) {
          	Customer_Credit__c credit = (Customer_Credit__c) sobj;
            info('Syncing customer credit to Sqs ' + credit);
            
            for (Sobject sobjRole : contactToOptyRoles.get(credit.Contact__c)) {
                OpportunityContactRole role = (OpportunityContactRole) sobjRole;
                
                info('Syncing customer credit for opty role ' + role);
                
                if (getCalloutsQuota() < 1) {
                    info('Callouts quota limit reached while syncing the ' + syncJob.action + ' and hence stopping syncing to sqs and starting a new job run');
                    runJob(AwsSyncServiceDto.ProposalsSync);
                    break;
                }
                
                syncJob.setBatch(sobj.id);
                info('Syncing object to Sqs ' + sobj);

                try {
                    Opportunity opty = role.Opportunity;
                    List<String> queueNames = getSqsQueueNames(opty);
                    if (queueNames.isEmpty()) {
                        setSqsQueueNotConfigured(syncJob);
                        continue;
                    }
    
                    sendSqsMessage(queueNames, jobId, sobj, getEventFields(sobj, opty), syncJob);

                    syncJob.syncSuccess();
                } catch (Exception e) {
                    syncJob.handleException(e);
                }

            }
        }
    }    
    
    public List<Sobject> queryOptyContactRolesForContacts(List<Id> recordIds) {
        List<OpportunityContactRole> roles = [
            select  
            	ContactId,
            	OpportunityId,
            	Opportunity.Lead_Gen_Partner__r.Name, 
            	Opportunity.Lead_Gen_Partner__r.Sqs_Queue_Name__c, 
            	Opportunity.External_Source__c, 
            	Opportunity.External_Source_Account__r.Sqs_Queue_Name__c,
            	Opportunity.Prospect_id__c
            from OpportunityContactRole
            where ContactId in :recordIds
        ];
        
        //There could be multiple roles for same opty and in that case, we will consider first opty.
        return getIdMap(roles, 'OpportunityId').values();
    }
    
    public void processSyncJob(SyncJobInfo syncJob) {
       	if (!isSqsSyncEnabled(syncJob.action, syncJob)) {
            return;
        }

        String jobId = getRandomString();
        
        List<Sobject> sobjs = queryRecords(syncJob.action, syncJob.getRecordIds());
        syncJob.log('Sobjects queried to sync to sqs ' + sobjs);
        
        for (Sobject sobj : sobjs) {
            if (getCalloutsQuota() < 1) {
                syncJob.log('Callouts quota limit reached while syncing the ' + syncJob.action + ' and hence stopping syncing to sqs and starting a new job run');
                runJob(syncJob.action);
                break;
            }
            
            syncJob.setBatch(sobj.id);
            
            syncJob.log('Syncing object to Sqs ' + sobj);
            
            try {
                List<String> queueNames = getSqsQueueNames(sobj);
                if (queueNames.isEmpty()) {
					setSqsQueueNotConfigured(syncJob);
                    continue;
                }
                
                sendSqsMessage(queueNames, jobId, sobj, syncJob);

				syncJob.syncSuccess();

            } catch (Exception e) {
                syncJob.handleException(e);
            }
        }
    }

    public List<Sobject> queryRecords(String action, List<String> recordIds) {
        if (action == AwsSyncServiceDto.LeadsSync) {
            return [
                select Id, 
                	Name,
                    Prospect_Id__c,
                    Lead_Gen_Partner__r.Name, 
                	Lead_Gen_Partner__r.Sqs_Queue_Name__c, 
                    External_Source__c, 
                	External_Source_Account__r.Sqs_Queue_Name__c,
                    LastModifiedBy.UserName, 
                	LastModifiedDate
                from lead 
                where id in :recordIds
            ];
        }

        if (action == AwsSyncServiceDto.OptysSync) {
            return [
                select Id, 
                	Name,
                    Prospect_Id__c,
                    Lead_Gen_Partner__r.Name, 
                	Lead_Gen_Partner__r.Sqs_Queue_Name__c, 
                    External_Source__c, 
                	External_Source_Account__r.Sqs_Queue_Name__c,
                    LastModifiedBy.UserName, 
                	LastModifiedDate
                from Opportunity 
                where id in :recordIds
            ];
        }

        if (action == AwsSyncServiceDto.ContractsSync) {
            return [
                select Id, 
                	Agreement_Number__c,
	                Prospect_Id__c,
                    Opportunity__c,
                    Opportunity__r.Lead_Gen_Partner__r.Name, 
                    Opportunity__r.Lead_Gen_Partner__r.Sqs_Queue_Name__c, 
                    Opportunity__r.External_Source__c, 
                    Opportunity__r.External_Source_Account__r.Sqs_Queue_Name__c,
                    Name, 
                    LastModifiedBy.UserName, 
                    LastModifiedDate
                from ServiceContract 
                where id in :recordIds
            ];
        }

        if (action == AwsSyncServiceDto.PaymentsSync) {
            return [
                select Id, 
                    Name, 
                    Opportunity__r.Lead_Gen_Partner__r.Name, 
                    Opportunity__r.Lead_Gen_Partner__r.Sqs_Queue_Name__c, 
                    Opportunity__r.External_Source__c, 
                    Opportunity__r.External_Source_Account__r.Sqs_Queue_Name__c,
                    Opportunity__r.Prospect_id__c,
                    LastModifiedBy.UserName,
                    LastModifiedDate
                from Payment_Transaction__c
                where id in :recordIds
            ];
        }

        if (action == AwsSyncServiceDto.ProposalsSync) {
            return [
                select Id,
                	Name,
                    Opportunity__c,
                    Opportunity__r.Prospect_Id__c, 
                    Opportunity__r.Lead_Gen_Partner__r.Name, 
                    Opportunity__r.Lead_Gen_Partner__r.Sqs_Queue_Name__c, 
                    Opportunity__r.External_Source__c, 
                    Opportunity__r.External_Source_Account__r.Sqs_Queue_Name__c,
                    LastModifiedBy.UserName,
                    LastModifiedDate
                from Proposal__c 
                where id in :recordIds                
            ];
        }
        
        if (action == AwsSyncServiceDto.CreditsSync) {
            return [
                select Id, 
                    Name, 
                    Contact__c,
                    LastModifiedBy.UserName,
                    LastModifiedDate
                from Customer_Credit__c
                where id in :recordIds
            ];
        }
        
        throw new BusinessException('Getting records is not supported for action ' + action);
    }
    
    public List<String> getSqsQueueNames(Sobject sobj) {
        List<String> queueNames = new List<String>();
        
        String sobjName = getSobjectName(sobj);
        String queueName = null;
        
        if (sobjName == 'Lead' || sobjName == 'Opportunity') {
            queueName = getSqsQueueName(getStringValue(sobj, 'Lead_Gen_Partner__r.Name'), 
                    getStringValue(sobj, 'Lead_Gen_Partner__r.Sqs_Queue_Name__c'),
                    getStringValue(sobj, 'External_Source_Account__r.Sqs_Queue_Name__c'));
            
            if (queueName != null) {
                queueNames.add(queueName);
            }
            
        } else if (sobjName == 'Payment_Transaction__c' || sobjName == 'ServiceContract' || sobjName == 'Proposal__c') {
            queueName = getSqsQueueName(getStringValue(sobj, 'Opportunity__r.Lead_Gen_Partner__r.Name'), 
                    getStringValue(sobj, 'Opportunity__r.Lead_Gen_Partner__r.Sqs_Queue_Name__c'),
                    getStringValue(sobj, 'Opportunity__r.External_Source_Account__r.Sqs_Queue_Name__c'));
            if (queueName != null) {
                queueNames.add(queueName);
            }
            
        } else {
	        throw new BusinessException('Getting SQS Queue Name is not supported for object ' + sobjName);
        }
		
        return queueNames;
    }
    
    public String getSqsQueueName(String leadGenPartnerName, String leadGenPartnerSqsQueueName, String externalSrcAcctSqsQueueName) {
        //If lead gen partner is null or if it is Sunrun, then we will take it from 
        //external source account. Else, we will take the queue name from Lead gen partner
        return (leadGenPartnerName == null || leadGenPartnerName == 'Sunrun')
            ?externalSrcAcctSqsQueueName
            :leadGenPartnerSqsQueueName;
    }

    public Map<String, String> getEventFields(Sobject sobj) {
        return getEventFields(sobj, null);
    }
    
    public Map<String, String> getEventFields(Sobject sobj, Sobject sobj2) {
        String sobjName = getSobjectName(sobj);
        Map<String, String> eventFields = new Map<String, String>();
        
        //Common attributes
        eventFields.put('lastModifiedDate', formatAsUtcIsoDateTime((DateTime) sobj.get('lastModifiedDate')));
        eventFields.put('lastModifiedBy', getStringValue(sobj, 'lastModifiedBy.userName'));
        eventFields.put('eventOriginator', EventOriginator);
        eventFields.put('salesforceObject', sobjName);
        
        if (sobjName == 'Lead') {
            Lead lead = (Lead) sobj;
            eventFields.put('prospectId', lead.Prospect_Id__c);
            eventFields.put('leadId', lead.Id);
            eventFields.put('eventName', 'LeadUpdate');
            
        } else if (sobjName == 'Opportunity') {
            Opportunity opty = (Opportunity) sobj;
            eventFields.put('prospectId', opty.Prospect_Id__c);
            eventFields.put('opportunityId', opty.Id);
            eventFields.put('eventName', 'LeadUpdate');

        } else if (sobjName == 'ServiceContract') {
            ServiceContract contract = (ServiceContract) sobj;
            eventFields.put('contractNumber', contract.Agreement_Number__c);
            eventFields.put('prospectId', contract.Prospect_Id__c);
            eventFields.put('contractId', contract.Id);
            eventFields.put('eventName', 'ContractUpdate');

        } else if (sobjName == 'Payment_Transaction__c') {
            Payment_Transaction__c payment = (Payment_Transaction__c) sobj;
            eventFields.put('paymentId', payment.Id);
            eventFields.put('prospectId', payment.Opportunity__r.Prospect_Id__c);
            eventFields.put('eventName', 'LeadPaymentUpdate');

        } else if (sobjName == 'Proposal__c') {
            Proposal__c proposal = (Proposal__c) sobj;
            eventFields.put('proposalId', proposal.Id);
            eventFields.put('proposalNumber', proposal.Name);
            eventFields.put('prospectId', proposal.Opportunity__r.Prospect_Id__c);
            eventFields.put('eventName', 'ProposalUpdate');

        } else if (sobjName == 'Customer_Credit__c') {
            Customer_Credit__c credit = (Customer_Credit__c) sobj;
            Opportunity opty = (Opportunity) sobj2;
            eventFields.put('creditId', credit.Id);
            eventFields.put('prospectId', opty.Prospect_Id__c);
            eventFields.put('eventName', 'LeadCreditUpdate');
            
        } else {
            throw new BusinessException('Unrecognized sobject ' + sobjName + ' to get event attributes');
        }
        
        return eventFields;
    }
    
    public void handleTriggerForSqsSync(String action, Boolean captureInsert) {
        String triggerFieldsSetting = 'AwsSqs' + action + 'TriggerFields';
        info('Handling the trigger to identify records to ' + action + ' for records' + Trigger.new);
        
        if (isAfterInsertOrUpdate()) {
            if (!isSqsSyncApplicable() || !isSqsSyncEnabled(action)) {
                return;
            }

            List<Sobject> sqsSyncApplicableRecords = new List<Sobject>();
            if (Trigger.isInsert) {
                if (captureInsert) {
	                sqsSyncApplicableRecords = Trigger.new;
                }
            } else {
        		sqsSyncApplicableRecords = getUpdatedRecords(Trigger.old, Trigger.new, 
					Sf.settingsService.getStringList(triggerFieldsSetting, new List<String>()), true);
            }
		
			insertSyncRecords(action, sqsSyncApplicableRecords);
        }
	}

    public void insertSyncRecords(String action, List<Sobject> sqsSyncApplicableRecords) {
        info('Inserting SQS Sync Records for ' + sqsSyncApplicableRecords);
        
        if (sqsSyncApplicableRecords.isEmpty()) {
            info('Could not match any records for ' + action + ' to be synced to SQS.');
        } else {
	        List<Sobject> recurrsionFilteredRecords = new List<Sobject>();
            for (Sobject sobj : sqsSyncApplicableRecords) {
                if (recordsProcessedInThisTxn.containsKey(sobj.id)) {
                    info('Record is already processed in this tx to insert into sync records and hence ignoring it');
                } else {
                    recurrsionFilteredRecords.add(sobj);
                    recordsProcessedInThisTxn.put(sobj.id, '');
                }
            }
        
            info('Matched ' + recurrsionFilteredRecords.size() + ' records for ' + action + ' to be synced to SQS.');
            if (!recurrsionFilteredRecords.isEmpty()) {
                Sf.syncService.insertSyncRecords(AwsSyncServiceDto.SyncModule, action, recurrsionFilteredRecords);
			    runJob(action);
            }
        }
	}
    
    public void sendSqsMessage(List<String> queueNames, String jobId, Sobject sobj, SyncJobInfo syncJob) {
        sendSqsMessage(queueNames, jobId, sobj, getEventFields(sobj), syncJob);
    }
    
    public void sendSqsMessage(List<String> queueNames, String jobId, Sobject sobj, Map<String, String> eventFields, SyncJobInfo syncJob) {
        JsonWriter jsonWriter = new JsonWriter();
        jsonWriter.write('eventTxId', jobId + '-' + getRandomLongString());
		
		for (String eventField : eventFields.keyset()) {
	        jsonWriter.write(eventField, eventFields.get(eventField));
        }

        String messageJson = jsonWriter.toPrettyJson();
        for (String queueName : queueNames) {
            awsSendSqsMessage(replaceMergeToken(getAwsSqsUrl(), 'QueueName', queueName), messageJson, getAwsConfig(), syncJob);
        }
    }
    
    public AwsConfig getAwsConfig() {
        if (awsConfig == null) {
            awsConfig = new AwsConfig(
                Sf.settingsService.getString('AwsAccessKey'),
                Sf.settingsService.getString('AwsSecretKey')
            );
        }
        return awsConfig;
    }
 	
    public String getAwsSqsUrl() {
        if (SqsQueueUrl == null) {
            SqsQueueUrl = Sf.settingsService.getString('AwsSqsUrl');
        }
		return SqsQueueUrl;
    }
 	
    public void setSqsSyncNotEnabled(SyncJobInfo syncJob) {
		syncJob.setBatch(syncJob.syncRecords).syncNotApplicable('Sqs Sync Not Enabled');
	}
 	
    public void setSqsQueueNotConfigured(SyncJobInfo syncJob) {
        syncJob.log('Sqs queue name is not configured hence not syncing');
		syncJob.syncNotApplicable(SqsQueueNotConfigured);
	}

    public Boolean isSqsSyncApplicable() {
        String awsSqsSyncApplicability = Sf.settingsService.getString('AwsSqsSyncApplicability', 'ui');
        if(equalsIc(awsSqsSyncApplicability, 'all')) {
            return true;
        }
        
        Boolean isApi = isApiOnlyUser();
        if(equalsIc(awsSqsSyncApplicability, 'ui') && !isApi) {
            return true;
        }

        if(equalsIc(awsSqsSyncApplicability, 'api') && isApi) {
            return true;
        }

        info('Current user context (isApi=' + isApi + ') is not applicable for Sqs Sync according to configured Sqs applicability (' 
             + awsSqsSyncApplicability + ') and hence not syncing to Sqs.');
        return false;
    }
    
    public String sendSqsMessage(String queueName, String message) {
    	return awsSendSqsMessage(replaceMergeToken(getAwsSqsUrl(), 'QueueName', queueName), message, getAwsConfig(), null);
    }
	
    public Boolean isSqsSyncEnabled(String action) {
    	return isSqsSyncEnabled(action, null);
    }
	
    public void runJob(String action) {
        String jobName = null;
        
        if (action == AwsSyncServiceDto.LeadsSync) {
            jobName = 'AwsSqsLeadsSyncJob';
        } else if (action == AwsSyncServiceDto.OptysSync) {
            jobName = 'AwsSqsOptysSyncJob';
        } else if (action == AwsSyncServiceDto.ContractsSync) {
            jobName = 'AwsSqsContractsSyncJob';
        } else if (action == AwsSyncServiceDto.ProposalsSync) {
            jobName = 'AwsSqsProposalsSyncJob';
        } else if (action == AwsSyncServiceDto.PaymentsSync) {
            jobName = 'AwsSqsPaymentsSyncJob';
        } else if (action == AwsSyncServiceDto.CreditsSync) {
            jobName = 'AwsSqsCreditsSyncJob';
        }

        Boolean markJobEligibleToRun = Sf.settingsService.getBoolean('AwsSqsSyncRunJobInRealtime', false);
        if (markJobEligibleToRun) {
	        Sf.commonScheduler.markJobEligibleToRun(jobName);
        }
   	}    
   
    public Boolean isSqsSyncEnabled(String action, SyncJobInfo syncJob) {
        String setting = null;
        
        if (action == AwsSyncServiceDto.LeadsSync) {
            setting = 'AwsSqsLeadsSyncEnabled';
        } else if (action == AwsSyncServiceDto.OptysSync) {
            setting = 'AwsSqsOptysSyncEnabled';
        } else if (action == AwsSyncServiceDto.ContractsSync) {
            setting = 'AwsSqsContractsSyncEnabled';
        } else if (action == AwsSyncServiceDto.ProposalsSync) {
            setting = 'AwsSqsProposalsSyncEnabled';
        } else if (action == AwsSyncServiceDto.PaymentsSync) {
            setting = 'AwsSqsPaymentsSyncEnabled';
        } else if (action == AwsSyncServiceDto.CreditsSync) {
            setting = 'AwsSqsCreditsSyncEnabled';
        }
        
        if (!Sf.settingsService.getBoolean(setting, false)) {
            if (syncJob != null) {
	            setSqsSyncNotEnabled(syncJob);
        		syncJob.log(syncJob.action + ' is not enabled in the settings [' + setting + '] and hence not processing the sync job');
            }
            info('Sqs sync is not enabled with setting ' + setting);
            return false;
        }
        
        return true;
    } 
}