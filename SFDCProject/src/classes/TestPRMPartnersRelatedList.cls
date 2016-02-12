@isTest
private class TestPRMPartnersRelatedList {
    
    static  testmethod void testPRMRelatedPartners(){

        Account accountObj1 = TestPRMLibrary.insertAccount('PRMTest1', PRMLibrary.PARTNER);
        Account accountObj2 = TestPRMLibrary.insertAccount('PRMTest2', PRMLibrary.PARTNER);
        Account accountObj3 = TestPRMLibrary.insertAccount('PRMTest3', PRMLibrary.PARTNER);
        Account accountObj4 = TestPRMLibrary.insertAccount('PRMTest4', PRMLibrary.PARTNER);
        
        //Success: Create relationship between account
        Partner_Relationship__c relationshipObj = new Partner_Relationship__c();
        relationshipObj.Related_From_Account__c = accountObj1.Id;
        relationshipObj.Related_To_Account__c = accountObj2.Id;
        relationshipObj.From_Relationship__c = 'Sales';
        //relationshipObj.To_Relationship__c = 'Lead-Gen';
        insert relationshipObj;

        relationshipObj = new Partner_Relationship__c();
        relationshipObj.Related_From_Account__c = accountObj3.Id;
        relationshipObj.Related_To_Account__c = accountObj1.Id;
        relationshipObj.From_Relationship__c = 'Install';
        //relationshipObj.To_Relationship__c = 'Lead-Gen';
        insert relationshipObj;
        
        Boolean exceptionResult = false;        
        try{
            Partner_Relationship__c tempRelationshipObj = new Partner_Relationship__c();
            insert tempRelationshipObj;
        }catch(Exception exceptionObj){
            exceptionResult = true;
        }
        System.assert(exceptionResult);

        //Failure: Duplicate relationships are not allowed 
        exceptionResult = false;        
        try{
            Partner_Relationship__c relationshipObj1 = new Partner_Relationship__c();
            relationshipObj1.Related_From_Account__c = accountObj2.Id;
            relationshipObj1.Related_To_Account__c = accountObj1.Id;
            relationshipObj1.From_Relationship__c = 'Sales';
            //relationshipObj1.To_Relationship__c = 'Lead-Gen';
            insert relationshipObj1;
        }catch(Exception exceptionObj){
            exceptionResult = true;
        }
        System.assert(exceptionResult);


        //Failure: Duplicate relationships are not allowed 
        exceptionResult = false;        
        try{
            Partner_Relationship__c relationshipObj1 = new Partner_Relationship__c();
            relationshipObj1.Related_From_Account__c = accountObj1.Id;
            relationshipObj1.Related_To_Account__c = accountObj2.Id;
            relationshipObj1.From_Relationship__c = 'Sales';
            //relationshipObj1.To_Relationship__c = 'Lead-Gen';
            insert relationshipObj1;
        }catch(Exception exceptionObj){
            exceptionResult = true;
        }
        System.assert(exceptionResult);
        
        //Failure: 'To account' is missing in the relationship
        exceptionResult = false;
        try{
            Partner_Relationship__c relationshipObj2 = new Partner_Relationship__c();
            relationshipObj2.Related_From_Account__c = accountObj2.Id;
            insert relationshipObj2;
        }catch(Exception exceptionObj){
            exceptionResult = true;         
        }
        System.assert(exceptionResult);
        
        //Failure: Relationship are missing
        exceptionResult = false;
        try{
            Partner_Relationship__c relationshipObj2 = new Partner_Relationship__c();
            relationshipObj2.Related_From_Account__c = accountObj2.Id;
            relationshipObj2.Related_To_Account__c = accountObj1.Id;
            insert relationshipObj2;
        }catch(Exception exceptionObj){
            exceptionResult = true;
        }
        System.assert(exceptionResult);
        
        //Relationship with same account is not allowed
        exceptionResult = false;
        try{
            Partner_Relationship__c relationshipObj2 = new Partner_Relationship__c();
            relationshipObj2.Related_From_Account__c = accountObj2.Id;
            relationshipObj2.Related_To_Account__c = accountObj2.Id;
            insert relationshipObj2;
        }catch(Exception exceptionObj){
            exceptionResult = true;
        }
        System.assert(exceptionResult);     
        
    }
    
}