public with sharing class Sf {

    public static final Map<String, String> testImplementations = new Map<String, String>();
    
    public static SettingsService settingsService {get {
        if (settingsService == null) {
            settingsService =  (SettingsService) createInstance('SettingsServiceImpl');
        }
        return settingsService;
    }private set;}
    
    public static PaymentService paymentService {get {
        if (paymentService == null) {
            paymentService =  (PaymentService) createInstance('PaymentServiceImpl');
        }
        return paymentService;
    }private set;}

    public static PaymentService paymentWsService {get {
        if (paymentWsService == null) {
            paymentWsService =  (PaymentService) createInstance('PaymentServiceWsImpl');
        }
        return paymentWsService;
    }private set;}
    
    public static AddressService addressService {get {
        if (addressService == null) {
            addressService =  (AddressService) createInstance('AddressServiceImpl');
        }
        return addressService;
    }private set;}    

    public static IKnockLeadSyncService iknockLeadSyncService {get {
        if (iknockLeadSyncService == null) {
            iknockLeadSyncService =  (IKnockLeadSyncService) createInstance('IKnockLeadSyncServiceImpl');
        }
        return iknockLeadSyncService;
    }private set;}    

    public static GoogleCalendarService googleCalendarService {get {
        if (googleCalendarService == null) {
            googleCalendarService =  (GoogleCalendarService) createInstance('GoogleCalendarServiceImpl');
        }
        return googleCalendarService;
    }private set;}    

    public static AuditService auditService {get {
        if (auditService == null) {
            auditService =  (AuditService) createInstance('AuditServiceImpl');
        }
        return auditService;
    }private set;}    

    public static AwsSyncService awsSyncService {get {
        if (awsSyncService == null) {
            awsSyncService =  (AwsSyncService) createInstance('AwsSyncServiceImpl');
        }
        return awsSyncService;
    }private set;}    

    public static AmbassadorSyncService ambassadorSyncService {get {
        if (ambassadorSyncService == null) {
            ambassadorSyncService =  (AmbassadorSyncService) createInstance('AmbassadorSyncServiceImpl');
        }
        return ambassadorSyncService;
    }private set;}    

    public static CostcoSyncService costcoSyncService {get {
        if (costcoSyncService == null) {
            costcoSyncService =  (CostcoSyncService) createInstance('CostcoSyncServiceImpl');
        }
        return costcoSyncService;
    }private set;}    

    public static HomeDepotSyncService homeDepotSyncService {get {
        if (homeDepotSyncService == null) {
            homeDepotSyncService =  (HomeDepotSyncService) createInstance('HomeDepotSyncServiceImpl');
        }
        return homeDepotSyncService;
    }private set;}    

    public static SchedulerService schedulerService {get {
        if (schedulerService == null) {
            schedulerService =  (SchedulerService) createInstance('SchedulerServiceImpl');
        }
        return schedulerService;
    }private set;}

    public static AppLogService appLogger {get {
        if (appLogger == null) {
            appLogger =  (AppLogService) createInstance('AppLogServiceImpl');
        }
        return appLogger;
    }private set;}    
/*
    public static NearbyCustomersViewerService nearbyCustomersViewerService {get {
        if (nearbyCustomersViewerService == null) {
            nearbyCustomersViewerService =  (NearbyCustomersViewerService) createInstance('NearbyCustomersViewerServiceImpl');
        }
        return nearbyCustomersViewerService;
    }private set;}    
*/
    public static SyncService syncService {get {
        if (syncService == null) {
            syncService =  (SyncService) createInstance('SyncServiceImpl');
        }
        return syncService;
    }private set;}    

    public static CommonScheduler commonScheduler {get {
        if (commonScheduler == null) {
            commonScheduler =  (CommonScheduler) createInstance('CommonSchedulerImpl');
        }
        return commonScheduler;
    }private set;}    

    public static CoreLogicService coreLogicService {get {
        if (coreLogicService == null) {
            coreLogicService =  (CoreLogicService) createInstance('CoreLogicServiceImpl');
        }
        return coreLogicService;
    }private set;}    

    @TestVisible
    private static Object createInstance(String cls) {
        
        //This helps us to override the implementations of servics to mock implementations
        //to isolate the testing
        if (Test.isRunningTest() && testImplementations.containsKey(cls)) {
            cls = testImplementations.get(cls);
        }
        
        Type typ = Type.forName(cls);
        Object instance = null;
        if (typ != null) {
            instance = typ.newInstance();
        }
        
        if (instance == null) {
            throw new BusinessException('Couldn\'t successfully instantiate an object for class ' + cls + '. Please check if Class name is correct, is compilable and current user has access.');
        }
        
        return instance;
    }
    
    public static void setTestImplementation(String implCls, String testCls) {
        testImplementations.put(implCls, testCls);
    }
}