@istest(seeAllData=true)
public with sharing class Test_trg_survey_createcase {
	public static testMethod void Test_trg_survey_createcase(){
		Test.starttest();
         Recordtype r=[select id from recordtype where sobjecttype='Case' and name='Survey' limit 1];
         Group Detractorid = [Select Id from Group where Name = 'Detractor Call Cases' and Type = 'Queue'];         
          Contact cont= new Contact (firstname='Test',LastName='TestCt');
          insert cont;
        ServiceContract sc = [Select id,agreement_number__c from ServiceContract where agreement_number__c !=null limit 1];
         Survey__c sy = new Survey__c (Contact__c=cont.id,CSAT_Survey_Response__c=3,Question_1__c='TestQ1',Question_2__c='TestQ2',Question_3__c='TestQ3',Question_4__c='TestQ4',Question_5__c='TestQ5',Question_6__c='TestQ6',Question_7__c='TestQ7',Question_8__c='TestQ8',
         Answer_1__c='TestA1',Answer_2__c='TestA2',Answer_3__c='TestA3',Answer_4__c='TestA4',Answer_5__c='TestA5',Answer_6__c='TestA6',Answer_7__c='TestA7',Answer_8__c='TestA8',Service_Contract__c=sc.id,Survey_Name__c='TestSurveyName',Survey_Sub_Type__c='TestSurveySubType');
         insert sy;
         Case c=new case ();
         c.Origin ='CSAT Survey';
         c.Service_Contract__c = sc.id;
         c.Survey__c =sy.id;
         c.Status = 'Open';
         c.Subject='Survey Detractor Callback';
         c.RecordTypeId = r.id;
         c.ContactId = cont.id;        
         insert c;
          Test.stoptest();
	}

}