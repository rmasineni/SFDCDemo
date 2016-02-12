/****************************************************************************
Author  : Raghu Masineni (rmasineni@sunrunhome.com)
Date    : December 2012

Description: Following webservice is used by NetExam to insert/update
			certification results in SunRun SFDC.

*****************************************************************************/

global class SunRunCertifications {

    global class Certification{
        webservice String ContactId{get;set;}
        webservice String CertificationName{get;set;}
        webservice String Status{get;set;}
        webservice Date ExamDate{get;set;}
        webservice Date CertificationExpirationDate{get;set;}
        webservice String Grade{get;set;}
    }
    
	webservice static String sendCertificationsToSunRun(Certification[] certifications)
    {	
		
		System.debug('certifications: ' + certifications);
		
		Map<String, Map<String, LMSInfo__c>> existingCertificationMap = new Map<String, Map<String, LMSInfo__c>>();
		Set<String> contactIds = new Set<String>();
		Set<String> certificationNames = new Set<String>();
		for(Certification certificationObj: certifications){
        	if(certificationObj.ContactId == null 
        		|| certificationObj.ContactId == ''){
        		return 'Contact Id is Null OR Empty';	
			} 
        	if(certificationObj.CertificationName == null 
        		|| certificationObj.CertificationName == ''){
				return 'Certification name is Null OR Empty';
			}			
			contactIds.add(certificationObj.ContactId);
			certificationNames.add(certificationObj.CertificationName);
		}
		System.debug('contactIds: ' + contactIds);

		for(LMSInfo__c certificationObj : [Select Id, Contact__c, Certification_Name__c, 
													Exam_Date__c, Status__c, Grade__c,
													Certification_Expiration_Date__c from LMSInfo__c
													where Contact__c in : contactIds
													and  Certification_Name__c in :certificationNames]){
			Map<String, LMSInfo__c> contactCertificationsMap = existingCertificationMap.containsKey(certificationObj.Contact__c) ? 
										existingCertificationMap.get(certificationObj.Contact__c) : new Map<String, LMSInfo__c>();
			contactCertificationsMap.put(certificationObj.Certification_Name__c, certificationObj);
			existingCertificationMap.put(certificationObj.Contact__c, contactCertificationsMap);
		}

		Map<Id, Contact> contactsMap = new Map<Id, Contact>();
		for(Contact contactObj : [Select Id, Accreditation_date__c, Accreditation_Status__c from Contact where Id in :contactIds]){
			contactsMap.put(contactObj.Id, contactObj);
		}
		System.debug('contactsMap: ' + contactsMap);
		
    	List<LMSInfo__c> certificationList = new List<LMSInfo__c>();
    	LMSInfo__c tempCertificationObj;

        for(Certification certificationObj: certifications){
			tempCertificationObj = null;			
			if(existingCertificationMap.containskey(certificationObj.ContactId)){
				Map<String, LMSInfo__c> contactCertificationsMap = existingCertificationMap.get(certificationObj.ContactId);
				if(contactCertificationsMap != null && contactCertificationsMap.containskey(certificationObj.CertificationName)){
					tempCertificationObj = contactCertificationsMap.get(certificationObj.CertificationName);
				}
			}
			if(tempCertificationObj == null){
				tempCertificationObj = new LMSInfo__c();  
			}
			tempCertificationObj.Contact__c = certificationObj.ContactId;
			tempCertificationObj.Certification_Name__c = certificationObj.CertificationName;
			tempCertificationObj.Exam_Date__c = certificationObj.ExamDate;
			tempCertificationObj.Status__c = certificationObj.Status;
			tempCertificationObj.Grade__c = decimal.valueOf(certificationObj.Grade);
			if(certificationObj.CertificationExpirationDate != null){
				tempCertificationObj.Certification_Expiration_Date__c = certificationObj.CertificationExpirationDate;
			}else{
				tempCertificationObj.Certification_Expiration_Date__c = date.parse('12/31/2999');
			}
        	certificationList.add(tempCertificationObj);
			/*
			Contact contactObj = contactsMap.get(certificationObj.ContactId);        	
        	if(contactObj != null){
        		if(certificationObj.Status == 'Pass'){
        			contactObj.Accreditation_Status__c = 'Accredited';
        			contactObj.Accreditation_date__c = tempCertificationObj.Exam_Date__c;
        		}else {
        			contactObj.Accreditation_Status__c = 'Not Accredited';
        		}
        	}
        	*/
        }
        
        try{
        	if(certificationList.size() > 0 ){
        		upsert certificationList;
        	}
        	
        	//if(contactsMap.size() > 0){
        		//update contactsMap.values();
        	//}	
        }catch(DMLException dmlExceptionObj){
        	System.debug('DML Exception: ' + dmlExceptionObj.getMessage());
        	return dmlExceptionObj.getMessage();
        }catch(Exception e){
        	System.debug('Exception: ' + e.getMessage());
        	return e.getMessage();
        }
        System.debug('Success');
        return 'Success';

    }

    static testMethod void certificationTest(){

    	Contact contactObj = TestPRMLibrary.insertContact('TestNetExam1', PRMLibrary.PARTNER,
										'NetExamStudent1' , 'sunrun.nextexamstudent1@gmail.com');
    	
    	System.debug('contactObj: ' + contactObj);
    	Certification certificationObj = new Certification();
    	certificationObj.ContactId = contactObj.Id;
    	certificationObj.CertificationName = 'TestCertification-1';
    	certificationObj.ExamDate = Date.today();
    	certificationObj.Grade = '10';
    	certificationObj.Status = 'Pass';
    	List<Certification> certificationList = new List<Certification>();
    	certificationList.add(certificationObj);
    	
    	SunRunCertifications.sendCertificationsToSunRun(certificationList);
    	
    	certificationObj.Grade = '10';
    	certificationObj.CertificationExpirationDate = date.parse('12/31/2990');
     	SunRunCertifications.sendCertificationsToSunRun(certificationList);
		LMSInfo__c existingCertification = [Select Id, Grade__c from LMSInfo__c where
    											Contact__c = :certificationObj.ContactId and
												Certification_Name__c = :certificationObj.CertificationName];
		System.assertEquals(10, existingCertification.Grade__c);	


    	certificationObj.ContactId = '';
    	String result = SunRunCertifications.sendCertificationsToSunRun(certificationList);
    	System.assertNotEquals('Success', result);	

    	certificationObj.ContactId = contactObj.Id;
    	certificationObj.CertificationName = null;
		result = SunRunCertifications.sendCertificationsToSunRun(certificationList);
    	System.assertNotEquals('Success', result);	
    }

}