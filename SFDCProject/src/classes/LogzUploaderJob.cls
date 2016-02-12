public class LogzUploaderJob implements Queueable, Database.AllowsCallouts {
	private static final String LogzUploaderUrl = Sf.settingsService.getString('LogzUploaderUrl', 'https://listener-4.logz.io:8071/?token=hMBMlkBoklHPLBcnRGikbHJvrQsdnJRt');
    private static final String Setting_LogzUploaderLastQueryDate = 'LogzUploaderLastQueryDate';
    private static final BaseClass utils = new BaseClass();
	private static final String[] AsyncApexfields = new String[]{
        'ApexClass.Id',
        'ApexClass.Name',
        'CompletedDate',
        'CreatedBy.Id',
        'CreatedBy.Name',
        'CreatedDate',
        'ExtendedStatus',
        'Id',
        'JobItemsProcessed',
        'JobType',
        'LastProcessed',
        'LastProcessedOffset',
        'MethodName',
        'NumberOfErrors',
        'ParentJobId',
        'Status',
        'TotalJobItems'
    };
 	
	private static final String[] AppLogFields = new String[]{
        'Action__c',
        'External_Id__c',
        'Id',
        'LastModifiedBy.Id',
        'LastModifiedBy.Name',
        'LastModifiedDate',
        'Message__c',
        'Module__c',
        'Name',
        'Record_Id__c',
        'Sobject__c',
        'Sync_Record__c',
        'System__c',
        'Type__c',
        'Value1__c',
        'Value2__c',
        'Value3__c'
    };

    public void execute(QueueableContext context) {
        DateTime newDate = DateTime.now();
        DateTime dateSinceQueried = Sf.settingsService.getDateTime(Setting_LogzUploaderLastQueryDate, DateTime.now().addDays(-7));
    	postAyncApexLogsToLogz(dateSinceQueried);
    	postAppLogsToLogz(dateSinceQueried);
        Sf.settingsService.setDateTime(Setting_LogzUploaderLastQueryDate, newDate);
    }

    public void postAyncApexLogsToLogz(DateTime dateSinceQueried) {
        postToLogz(queryJobs(dateSinceQueried), AsyncApexfields, 'AsyncApexJob', 'ExtendedStatus');
    }

    public void postAppLogsToLogz(DateTime dateSinceQueried) {
        postToLogz(queryAppLogs(dateSinceQueried), AppLogFields, 'App_Log__c', 'Message__c');
    }

    public void postToLogz(List<Sobject> sobjs, String[] fields, String type, String messageField) {
        String payload = '';
        for (Sobject sobj : sobjs) {
            JsonWriter jsonWriter = new JsonWriter();
            for(String field : fields) {
                jsonWriter.write(field, utils.getValue(sobj, field));
            }
            jsonWriter.write('org.Id', UserInfo.getOrganizationId());
            jsonWriter.write('org.Name', UserInfo.getOrganizationName());
            
            if (messageField != null) {
                //Logz recognizes this field and shows in main screen.
	            jsonWriter.write('message', utils.getValue(sobj, messageField));
            }
            jsonWriter.write('environment', utils.isSandbox()?'sandbox':'production');
            
            payload += '\n' + jsonWriter.toJson();
        }
    
        if (!String.isBlank(payload.trim())) {
            String url = LogzUploaderUrl + '&type=' + type;
            utils.httpPost(url, payload.trim(), new Map<String, String>{'Content-Type' => 'text/plain'});
        }
    }
    
    List<AsyncApexJob> queryJobs(DateTime dateSinceQueried) {
        String soql = utils.createSoql(AsyncApexfields, 'AsyncApexJob', new String[]{'CompletedDate >= :dateSinceQueried', 'CompletedDate != null'}, 'CompletedDate', null, null);
        List<AsyncApexJob> jobs = Database.query(soql + ' limit ' + Sf.settingsService.getInteger('LogzUploaderQueryLimit', 1000));
        
        if (Test.isRunningTest()) {
            jobs = Database.query(utils.createSoql(AsyncApexfields, 'AsyncApexJob'));
        }
        
        return jobs;
    }

    List<App_Log__c> queryAppLogs(DateTime dateSinceQueried) {
        String soql = utils.createSoql(AppLogFields, 'App_Log__c', new String[]{'LastModifiedDate >= :dateSinceQueried', '(Type__c = \'Error\' or Type__c = \'Exception\')'}, 'LastModifiedDate', null, null);
        return Database.query(soql + ' limit ' + Sf.settingsService.getInteger('LogzUploaderQueryLimit', 1000));
    }
}