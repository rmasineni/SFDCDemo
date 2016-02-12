public with sharing class Constants {
    
    public static Integer DealIdLength = 12;
    public static Integer RefNumRandomStringLength = 5;
    
    public static String PaymentStatus_Accept = 'accept';
    public static String PaymentMode_AutoPayment = 'auto-payment';
    public static String PaymentMode_OneTimePayment = 'onetime-payment';
    public static String TransactionType_CreatePaymentToken = 'create_payment_token';
    
    public static String PaymentOptyContactRole = 'PaymentOptyContactRole';       
    public static String PaymentOptyAutoPaymentContactRole = 'PaymentOptyAutoPaymentContactRole';
    public static String PaymentOptyOneTimePaymentContactRole = 'PaymentOptyOneTimePaymentContactRole';
    public static String CybersourceFormPostUrl = 'CybersourceFormPostUrl';
    public static String CybersourceDepAccessKey = 'CybersourceDepAccessKey';
    public static String CybersourceDepSecretKeyPart1 = 'CybersourceDepSecretKeyPart1';
    public static String CybersourceDepSecretKeyPart2 = 'CybersourceDepSecretKeyPart2';
    public static String CybersourceDepProfileId = 'CybersourceDepProfileId';
    public static String CybersourceAchAccessKey = 'CybersourceAchAccessKey';
    public static String CybersourceAchSecretKeyPart1 = 'CybersourceAchSecretKeyPart1';
    public static String CybersourceAchSecretKeyPart2 = 'CybersourceAchSecretKeyPart2';
    public static String CybersourceAchProfileId = 'CybersourceAchProfileId';
    
    public static String PaymentAchDealIdPrefix = 'PaymentAchDealIdPrefix';
    public static String PaymentAchDealIdSuffix = 'PaymentAchDealIdSuffix';
    public static String PaymentDepositDealIdPrefix = 'PaymentDepositDealIdPrefix';
    public static String PaymentDepositDealIdSuffix = 'PaymentDepositDealIdSuffix';
    
    
    /**
     * This is the base url something like, https://ppdev-sunrunhome.cs17.force.com/partner/apex/. After this a VF page name
     * will be constructured (for ex., RequestForPayment) or if it is while label, RequestForPayment_Sengivity
     */       
    public static String RequestPaymentBaseUrl = 'RequestPaymentBaseUrl';
    
    public static String ServiceContractPaymentMode_Recurring = 'Recurring';
}