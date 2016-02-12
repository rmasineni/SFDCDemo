/************************************************************************************************************
Name    : EDPDocumentSettings
Author  : ZCloud Team
Date    : Mar, 2013
Description: This class contains the methods to read the Document Classification settings
************************************************************************************************************/
public class EDPDocumentSettings {
	
	public static String REQUIRES_SIGNATURE = 'Requires Signature';
    public static String REQUIRES_NO_SIGNATURE = 'Requires No Signature';
    public static String MANDATORY_REQUIREMENTS = 'Mandatory Documents';
    public static String MANUAL_UPLOAD = 'Manual Upload';
    public static String GENERAL_UPLOAD = 'General Upload';
    public static String CUSTOMER_AGREEMENT = 'Customer Agreement';
    public static string NA = 'Not Applicable';
    public static String ALL = 'All';
    public static Map<String, Map<String, Set<String>>> docClassificationMap;
	 public static String PHOTO_TYPE= 'Photo Upload';
    public static string INSTALL='Installation';
    public static string QUALITY='Quality';
    public static string FIELDSERVICE='Field Service';
    public static string SITEAUDITPARTNER= 'Site Audit-Partner';
    public static string proposalState{
        get{ return proposalState;}
   	 set{proposalState=value; }
    }
	public static List<String> getLoginPartnerInfo(String costStack){
		List<String> ptrTypesList = new List<String>();
		if(costStack == 'INTEGRATED' || costStack == 'INTEGRATED_SUNRUN_SELLS'){
			ptrTypesList.add(EDPUtil.FULL_SERVICE);
		}else if(costStack == 'MULTI_PARTY' || costStack == 'MULTI_PARTY_SUNRUN_SELLS'){
			ptrTypesList.add(EDPUtil.SALES);
		}
		System.debug('ptrTypesList: '  +ptrTypesList);
		return ptrTypesList;		
	}
    
     public static integer getQualityCount(string relatedObject) {
        string  soqlStr= SoqlStrCount(relatedObject);
        string photoType =EDPDocumentSettings.QUALITY;
        soqlStr+='and Document_Type_Name__c =:photoType';
        return Database.countQuery(soqlStr);
    }
	 public static integer getSiteAuditCount(string relatedObject) {
        string  soqlStr= SoqlStrCount(relatedObject);
         string photoType  =EDPDocumentSettings.SITEAUDITPARTNER;
        soqlStr+='and Document_Type_Name__c =:photoType';
        return  Database.countQuery(soqlStr);
    }
	
    
    public static integer getFSCount(string relatedObject) {
        string  soqlStr= SoqlStrCount(relatedObject);
        string photoType  =EDPDocumentSettings.FIELDSERVICE;
        soqlStr+='and Document_Type_Name__c =:photoType';
        return Database.countQuery(soqlStr);
    }
    
    public static integer getInstallCount(string relatedObject) {
        string  soqlStr= SoqlStrCount(relatedObject);
        string photoType  =EDPDocumentSettings.INSTALL;
        soqlStr+='and document_type_Name__c =:photoType';
        return Database.countQuery(soqlStr);
    }
    public static string SoqlStrCount(string relatedObject){
        string objectType = SRAttachmentManager.getSObjectType(relatedObject); 
         String soqlStr = 'select count() from SR_Gen_Asset_Attachment__c';
         		soqlStr += (objectType == 'ServiceContract') ?  '  where service_contract__c =:relatedObject ' : '  where Generation_Asset__c =:relatedObject ' ;
        	return soqlStr;	
           
    }
    

    public static List<String> getLoginPartnerInfo(Id salesPartnerId, Id installPartnerId){
		List<String> ptrTypesList = new List<String>();
		Contact loginUserContact = new Contact();
		loginUserContact = PRMContactUtil.getLoginUserAccountAndContact();
		if(PRMContactUtil.isPartnerContact(loginUserContact)){
            if(salesPartnerId != null && installPartnerId != null && salesPartnerId == installPartnerId && installPartnerId == loginUserContact.account.Id){
			//if(salesPartnerId != null && installPartnerId != null && salesPartnerId == installPartnerId){
                ptrTypesList.add(EDPUtil.FULL_SERVICE);
            }else if((loginUserContact.Sunrun_User__c != null && 
            		(loginUserContact.Division__c == 'Field Sales' || loginUserContact.Division__c == 'Inside Sales')) 
            	&& salesPartnerId == loginUserContact.account.Id){
                ptrTypesList.add(EDPUtil.SUNRUN_SALES);
            }else if(salesPartnerId == loginUserContact.account.Id){
                ptrTypesList.add(EDPUtil.SALES);
            }else if(installPartnerId == loginUserContact.account.Id){
                ptrTypesList.add(EDPUtil.INSTALL);
            }
		}else if(salesPartnerId == null && installPartnerId != null){
			ptrTypesList.add(EDPUtil.INSTALL);
		}else if(salesPartnerId != null && installPartnerId == null){
			ptrTypesList.add(EDPUtil.SALES);
		}else{
			ptrTypesList.add(EDPUtil.FULL_SERVICE);
			ptrTypesList.add(EDPUtil.SALES);
			ptrTypesList.add(EDPUtil.INSTALL);
		}
		System.debug('ptrTypesList: '  +ptrTypesList);
		return ptrTypesList;
    }
    public static Set<Id> getContactIdsForSubmittedUser(Id submittedById){
		List<User> usersList = [Select Id, name, userName, profileId, CompanyName, firstname, lastname, email, contactId from User where Id = :submittedById];
		Set<Id> contactIds = new Set<Id>();
		if(usersList != null && !usersList.isEmpty()){
			
			if(usersList[0].contactId == null){
				List<Contact> contactList = [Select Id, name, sunrun_user__c from Contact where sunrun_user__c =:usersList[0].Id];
				if(!contactList.isempty()){
					contactIds.add(contactList[0].Id);
				}
			}else{
				contactIds.add(usersList[0].contactId);
			}
		}	
		return contactIds;	   	
    }
    
     
    public static List<String> getLoginPartnerInfo(Id submittedById, Id salesPartnerId, Id installPartnerId){

		List<String> ptrTypesList = new List<String>();
		Set<Id> contactIds = getContactIdsForSubmittedUser(submittedById);
		if(salesPartnerId != null && salesPartnerId == installPartnerId){
			ptrTypesList.add(EDPUtil.FULL_SERVICE);
		}else{
			ptrTypesList.add(EDPUtil.SALES);
		}
		
		if(contactIds != null && !contactIds.isEmpty()){
			List<Contact> contactList = PRMContactUtil.getContacts(contactIds);
			if(contactList.size() > 0){
				Contact submittedContact = contactList[0];
				if(submittedContact != null && submittedContact.account != null){
				    if(salesPartnerId != null && installPartnerId != null && salesPartnerId == installPartnerId && installPartnerId == submittedContact.account.Id){
				        ptrTypesList.clear();
				        ptrTypesList.add(EDPUtil.FULL_SERVICE);
				    }else if(salesPartnerId == submittedContact.account.Id && submittedContact.Sunrun_User__c != null){
				    	ptrTypesList.clear();
				        ptrTypesList.add(EDPUtil.SUNRUN_SALES);
				    }else if(salesPartnerId == submittedContact.account.Id){
				    	ptrTypesList.clear();
				        ptrTypesList.add(EDPUtil.SALES);
				    }else if(installPartnerId == submittedContact.account.Id){
				    	ptrTypesList.clear();
				        ptrTypesList.add(EDPUtil.INSTALL);
				    }
				}
			}
		}
		return ptrTypesList;
    }

    public static Map<String, Document_Classification__c> generalDocumentClassification;
   // public static Map<String, Document_Classification__c> documentClassificationIdMapByCategory;

    public static Map<String, Document_Classification__c> documentClassificationMapByCategory;
    public static Map<String, Document_Classification__c> documentClassificationIdMapByCategory;
    public static Map<String, Document_Classification__c> getDocumentClassificationIdMapByCategroy(String categoryType, 
    																							String requiredForSubmission,
    																							Set<String> modes,
			                                                                                    Id salesPartnerId, Id installPartnerId){
		getDocumentClassificationByCategroy(categoryType, requiredForSubmission, modes,salesPartnerId, installPartnerId);
		return documentClassificationIdMapByCategory; 			                                                                                       	
	}
    
    public static String getDocumentClassificationQuery(){
    	String selectStr = 'Select Id, Allow_To_Over_Write__c, Document_Name__c, ESignature_allowed__c, ';
		selectStr += ' Proposal_Type__c, Source_System__c, Welcome_email_attachment__c,  show_on_mobile__c ';
    	return selectStr;
    }

	public static Map<String, Document_Classification__c> getDocumentClassificationByName(){
		String selectStr = getDocumentClassificationQuery();
        selectStr += ' , ( Select Id, Partner_Type__c, Mode__c, Partner_Location_Type__c, Mandatory_Document__c, Customer_signature_required__c ';
		selectStr += ' , Partner_signature_required__c , SR_Ops_signature_required__c from Partner_Document_Relationships__r  ) ';
		String whereCondition = ' from Document_Classification__c ';  
		selectStr += whereCondition;
		generalDocumentClassification = new Map<String, Document_Classification__c>();
        for(Document_Classification__c docClassificationObject : Database.query(selectStr)){
        	generalDocumentClassification.put(docClassificationObject.Document_Name__c, docClassificationObject);
        }
		return generalDocumentClassification; 	
    } 

    public static Map<String, Document_Classification__c> getDocumentClassificationByName(String documentName, String partnerType){
		if(generalDocumentClassification == null || generalDocumentClassification.size() == 0){
	        generalDocumentClassification = new Map<String, Document_Classification__c>();
			String selectStr = getDocumentClassificationQuery();
	        selectStr += ' , ( Select Id, Partner_Type__c, Mode__c, Partner_Location_Type__c, Mandatory_Document__c, Customer_signature_required__c ';
			selectStr += ' , Partner_signature_required__c , SR_Ops_signature_required__c from Partner_Document_Relationships__r where  ';
			selectStr += ' Partner_Type__c =:partnerType ) ';
			
			String whereCondition = ' from Document_Classification__c where Document_Name__c =:documentName ';  
			selectStr += whereCondition;
	        for(Document_Classification__c docClassificationObject : Database.query(selectStr)){
	        	generalDocumentClassification.put(docClassificationObject.Document_Name__c, docClassificationObject);
	        }
		 }  
		 return generalDocumentClassification; 	
    } 
   
    public static Map<String, Document_Classification__c> getGeneralDocuments(String categoryType){
		String documentCategory = 'General';
		if(generalDocumentClassification == null || generalDocumentClassification.size() == 0){
	        generalDocumentClassification = new Map<String, Document_Classification__c>();
			String selectStr = getDocumentClassificationQuery();
			String whereCondition = ' from Document_Classification__c where Category__c = :documentCategory order by Document_Name__c ASC  '; 
			selectStr += whereCondition;
			//List<Document_Classification__c> docClassificationRelatedList  = Database.query(selectStr);
	        for(Document_Classification__c docClassificationObject : Database.query(selectStr)){
	        	generalDocumentClassification.put(docClassificationObject.Document_Name__c, docClassificationObject);
	        }
		 }  
		 return generalDocumentClassification; 	
    } 
	
	public static Map<String, Document_Classification__c> getDocumentClassificationByCategroy(String categoryType, 
    																							String requiredForSubmission,
    																							Set<String> modes,
		                                                                                       Id salesPartnerId, Id installPartnerId){
		return 	getDocumentClassificationByCategroy(categoryType,requiredForSubmission,modes, salesPartnerId, installPartnerId,null);	                                                                                       	
	}

	public static Map<String, Document_Classification__c> getDocumentClassificationByCategroy(String categoryType, 
    																							String requiredForSubmission,
    																							Set<String> modes, String costStack){
		return 	getDocumentClassificationByCategroy(categoryType,requiredForSubmission,modes, null, null,costStack);	 
	}

    
    public static Map<String, Document_Classification__c> getDocumentClassificationByCategroy(String categoryType, 
    																							String requiredForSubmission,
    																							Set<String> modes,
		                                                                                       	Id salesPartnerId, Id installPartnerId,
		                                                                                       	String costStack){
        if(documentClassificationMapByCategory == null || documentClassificationMapByCategory.size() ==0){
	        documentClassificationMapByCategory = new Map<String, Document_Classification__c>();
	        documentClassificationIdMapByCategory = new  Map<String, Document_Classification__c>();
	        Set<String> tempDocumentTypes = new Set<String>();
	        String proposalToolSource = EDPUtil.PROPOSAL_TOOL_SOURCE;
	        String manualUploadSource = EDPUtil.MANUAL_UPLOAD_SOURCE;
	        String whereCondition = '';
	        String whereCondition2 = '';
	        String selectStr = getDocumentClassificationQuery();
	       	String partnerLocations = getPartnerLocations();
	       	
	        selectStr += ' , ( Select Id, Partner_Type__c, Mode__c, Partner_Location_Type__c, Mandatory_Document__c, Customer_signature_required__c ';
			selectStr += ' , Partner_signature_required__c , SR_Ops_signature_required__c from Partner_Document_Relationships__r where (Mode__c in :modes)  ';
			selectStr += '  AND (Partner_Location_Type__c includes ' + partnerLocations + ' ) ';
	
			List<String> ptrTypesList;
			if(costStack != null && costStack != ''){
				ptrTypesList = getLoginPartnerInfo(costStack);
			}else{
				ptrTypesList = getLoginPartnerInfo(salesPartnerId, installPartnerId);
			}
			if(ptrTypesList != null && ptrTypesList.size() > 0){
			    whereCondition = ' AND (Partner_Type__c in :ptrTypesList) ';
			}else{
			    whereCondition = ' AND (Partner_Type__c = null) ';
			}
			system.debug('proposalState>>' +  proposalState);
            system.debug('requiredForSubmission>>' +  requiredForSubmission);
              system.debug('requiredForSubmission>>' +  requiredForSubmission);
	        if(requiredForSubmission != NULL && requiredForSubmission != '' && requiredForSubmission == MANDATORY_REQUIREMENTS ){
	            whereCondition += ' AND ( Mandatory_Document__c = true )';   	
	        }
          /* else if (requiredForSubmission != NULL && requiredForSubmission != '' && requiredForSubmission == MANDATORY_REQUIREMENTS ){
                whereCondition += ' AND ( (Mandatory_Document__c = true)  OR  (Document_Name__c in :edputil.REBATE_FORM)) '; 
                
            }*/
        
	        if(categoryType != null && categoryType != '' && categoryType == REQUIRES_SIGNATURE){
	            whereCondition += (whereCondition == '' ) ? ' where ' : ' AND ';
	            whereCondition += ' (Customer_signature_required__c = true OR Partner_signature_required__c = true OR SR_Ops_signature_required__c = true ) ';
	        }else if(categoryType != null && categoryType != '' && categoryType == REQUIRES_NO_SIGNATURE){
	            whereCondition += (whereCondition == '' ) ? ' where ' : ' AND ';
	            whereCondition += ' ( Customer_signature_required__c = false AND Partner_signature_required__c = false AND SR_Ops_signature_required__c = false ) ';                                 
	        }if(categoryType != null && categoryType != '' && categoryType == MANUAL_UPLOAD){
	            //whereCondition2 += (whereCondition2 == '' ) ? ' where ' : ' AND ';
	            //whereCondition2 += ' (((Customer_signature_required__c = true OR Partner_signature_required__c = true OR SR_Ops_signature_required__c = true ) AND (Source_System__c =:proposalToolSource)) ';
	            //whereCondition2 += ' OR ( Source_System__c =:manualUploadSource ))' ;	        	
	        }
	
	        selectStr += whereCondition + ' ) ';
	        selectStr += ' from Document_Classification__c ';
	        
	       	whereCondition2 += ' where category__c != \'General\' ' ;       
	        if(categoryType != null && categoryType != '' && categoryType == MANUAL_UPLOAD){
	            whereCondition2 += (whereCondition2 == '' ) ? ' where ' : ' AND ';
	            whereCondition2 += ' ( Source_System__c =:proposalToolSource  OR Source_System__c =:manualUploadSource ) ';
	            selectStr += whereCondition2;  	        	
	        }
	        
	        selectStr +=  ' order by Document_Name__c ASC ' ;
	        System.debug('selectStr: ' + selectStr);     
	       
	        System.debug('ptrLocations: ' + partnerLocations);
	       	System.debug('modes: ' + modes);
	       	System.debug('ptrTypesList: ' + ptrTypesList);
	                                                            
	        List<Document_Classification__c> docClassificationRelatedList  = Database.query(selectStr);
	        for(Document_Classification__c docClassificationObject : docClassificationRelatedList){
	            System.debug('categoryType: ' + categoryType);
	            if(categoryType == MANUAL_UPLOAD){
					Boolean selectRecord = false;
					List<Partner_Document_Relationship__c> partnerDocumentRelationships =  docClassificationObject.Partner_Document_Relationships__r;
					System.debug('partnerDocumentRelationships.size(): ' + partnerDocumentRelationships.size());
					if(partnerDocumentRelationships != null && partnerDocumentRelationships.size() > 0){
						System.debug('docClassificationObject.Source_System__c: ' + docClassificationObject.Source_System__c);
						if(docClassificationObject.Source_System__c == manualUploadSource){
							selectRecord = true;
						}else if(docClassificationObject.Source_System__c == proposalToolSource){
							Partner_Document_Relationship__c ptrRelationshipObj = partnerDocumentRelationships[0];
							if(ptrRelationshipObj.Customer_signature_required__c == true 
								|| ptrRelationshipObj.Partner_signature_required__c == true){
								selectRecord = true; 
							}
						}
					}

					if(selectRecord == true){
						System.debug('docClassificationObject.Document_Name__c1: ' + docClassificationObject.Document_Name__c);
						documentClassificationMapByCategory.put(docClassificationObject.Document_Name__c, docClassificationObject);
						documentClassificationIdMapByCategory.put(docClassificationObject.Id, docClassificationObject);
					}
	            	
	            }else{
		            if(docClassificationObject.Partner_Document_Relationships__r != null 
		            	&& docClassificationObject.Partner_Document_Relationships__r.size() > 0){
		            	System.debug('docClassificationObject.Document_Name__c2: ' + docClassificationObject.Document_Name__c);
		            	System.debug('docClassificationObject.Partner_Document_Relationships__r 2: ' + docClassificationObject.Partner_Document_Relationships__r);
		                documentClassificationMapByCategory.put(docClassificationObject.Document_Name__c, docClassificationObject);
		                documentClassificationIdMapByCategory.put(docClassificationObject.Id, docClassificationObject);
		            }	            	
	            }
	        }
	        //System.debug('documentClassificationMapByCategory: ' + documentClassificationMapByCategory);
        }
        return documentClassificationMapByCategory;       
    }

	public static Map<String, Document_Classification__c> welcomeEmailDocumentTypesMap;	  
	public static Map<String, Document_Classification__c> ptrWelcomeEmailDocumentTypesMap;	    
    public static Map<String, Document_Classification__c> getWelcomeDocumentTypes(Id salesPartnerId, Id installPartnerId){

		welcomeEmailDocumentTypesMap = new Map<String, Document_Classification__c>();
		Set<String> tempDocumentTypes = new Set<String>();
	        
		String whereCondition = '';
		String whereCondition2 = '';
		String selectStr = 'Select Id, Allow_To_Over_Write__c, Document_Name__c, ESignature_allowed__c, ';
		selectStr += ' Proposal_Type__c, Source_System__c, Welcome_email_attachment__c, ';
		selectStr += ' ( Select Id, Partner_Type__c, Mode__c, Partner_Location_Type__c, Mandatory_Document__c, Customer_signature_required__c, Partner_signature_required__c, ';
		selectStr += ' SR_Ops_signature_required__c  from Partner_Document_Relationships__r where  ';

		List<String> ptrTypesList = getLoginPartnerInfo(salesPartnerId, installPartnerId);
		System.debug('ptrTypesList: ' + ptrTypesList);
		if(ptrTypesList != null && ptrTypesList.size() > 0){
		    whereCondition = ' (Partner_Type__c in :ptrTypesList) ';
		}else{
		    whereCondition = ' (Partner_Type__c = null) ';
		}
        selectStr += whereCondition + ' ) ';
        selectStr += ' from Document_Classification__c ';
        
		whereCondition2 += ' where ( Welcome_email_attachment__c = true ) ';
		selectStr += whereCondition2;
        selectStr +=  ' order by Document_Name__c ASC ' ;
        System.debug('selectStr: ' + selectStr);                                                         

        List<Document_Classification__c> docClassificationRelatedList  = Database.query(selectStr);
        for(Document_Classification__c docClassificationObject : docClassificationRelatedList){
            if(docClassificationObject.Partner_Document_Relationships__r != null 
            && docClassificationObject.Partner_Document_Relationships__r.size() > 0){
                welcomeEmailDocumentTypesMap.put(docClassificationObject.Document_Name__c, docClassificationObject);
            }
        }
        System.debug('welcomeEmailDocumentTypesMap: ' + welcomeEmailDocumentTypesMap);
        return welcomeEmailDocumentTypesMap;       
    }

    public static Map<String, Document_Classification__c> getWelcomeDocumentTypes(String emailType, Id submittedById, 
    																			Id salesPartnerId, Id installPartnerId){

		welcomeEmailDocumentTypesMap = new Map<String, Document_Classification__c>();
		ptrWelcomeEmailDocumentTypesMap = new Map<String, Document_Classification__c>();
		
		Set<String> tempDocumentTypes = new Set<String>();
	        
		String whereCondition = '';
		String whereCondition2 = '';
		String selectStr = 'Select Id, Allow_To_Over_Write__c, Document_Name__c, ESignature_allowed__c, ';
		selectStr += ' Proposal_Type__c, Source_System__c, Welcome_email_attachment__c, ';
		selectStr += ' ( Select Id, Partner_Type__c, Mode__c, Partner_Location_Type__c, Mandatory_Document__c, Customer_signature_required__c, Partner_signature_required__c, ';
		selectStr += ' SR_Ops_signature_required__c  from Partner_Document_Relationships__r where  ';

		List<String> ptrTypesList = getLoginPartnerInfo(submittedById, salesPartnerId, installPartnerId);
		System.debug('ptrTypesList: ' + ptrTypesList);
		if(ptrTypesList != null && ptrTypesList.size() > 0){
		    whereCondition = ' (Partner_Type__c in :ptrTypesList) ';
		}else{
		    whereCondition = ' (Partner_Type__c = null) ';
		}
        selectStr += whereCondition + ' ) ';

        if(emailType != null && emailType == EDPUtil.PARTNER){
        	whereCondition2 +=  ' where (Partner_Welcome_Email_Attachment__c = true ) ';
        }else{
        	whereCondition2 +=  ' where (Welcome_email_attachment__c = true) ';
        }
        selectStr += ' from Document_Classification__c ';
		selectStr += whereCondition2;
        selectStr +=  ' order by Document_Name__c ASC ' ;
        System.debug('selectStr: ' + selectStr);                                                         

        List<Document_Classification__c> docClassificationRelatedList  = Database.query(selectStr);
        for(Document_Classification__c docClassificationObject : docClassificationRelatedList){
            if(docClassificationObject.Partner_Document_Relationships__r != null 
            && docClassificationObject.Partner_Document_Relationships__r.size() > 0){
            	if(emailType != null && emailType == EDPUtil.PARTNER){
                	ptrWelcomeEmailDocumentTypesMap.put(docClassificationObject.Document_Name__c, docClassificationObject);
            	}else{
            		welcomeEmailDocumentTypesMap.put(docClassificationObject.Document_Name__c, docClassificationObject);
            	}
            }
        }

		if(emailType != null && emailType == EDPUtil.PARTNER){
			System.debug('ptrWelcomeEmailDocumentTypesMap: ' + ptrWelcomeEmailDocumentTypesMap);
			return ptrWelcomeEmailDocumentTypesMap;
		}
		System.debug('welcomeEmailDocumentTypesMap: ' + welcomeEmailDocumentTypesMap);
        return welcomeEmailDocumentTypesMap;       
    }
    
    
     //adding phototypes
    public static Map<String, Document_Classification__c> getPhotoTypes(String categoryType){
        system.debug('categoryType>>>' +  categoryType);
     if(generalDocumentClassification == null || generalDocumentClassification.size() == 0){
          generalDocumentClassification = new Map<String, Document_Classification__c>();
      String selectStr = getDocumentClassificationQuery();
      String whereCondition = ' from Document_Classification__c where Category__c = :categoryType order by Document_Name__c ASC  '; 
      selectStr += whereCondition;
          system.debug('selectStr>>>' +  selectStr);
      //List<Document_Classification__c> docClassificationRelatedList  = Database.query(selectStr);
          for(Document_Classification__c docClassificationObject : Database.query(selectStr)){
            generalDocumentClassification.put(docClassificationObject.Document_Name__c, docClassificationObject);
          }
     }  
     return generalDocumentClassification;   
    } 
    

    
    public static Set<String> getVisibleDocumentTypesByCategroy(String categoryType, Set<String> modes, Id salesPartnerId, Id installPartnerId){
        String ptrLocationType = EDPUtil.HEADQUARTERS;
        Map<String, Partner_Document_Relationship__c> documentTypesMap = new Map<String, Partner_Document_Relationship__c>();
        Set<String> tempDocumentTypes = new Set<String>();
        User userObj = PRMContactUtil.getLoginUser();
        String whereCondition = '';
        String selectStr = 'Select Id, Partner_Type__c, Mandatory_Document__c, Mode__c, Partner_Location_Type__c, ';
        selectStr += ' Customer_signature_required__c, Partner_signature_required__c, SR_Ops_signature_required__c, ' ;
		selectStr += ' Document_Classification__r.Allow_To_Over_Write__c, Document_Classification__r.category__c, '; 
        selectStr += ' Document_Classification__r.Document_Name__c, Document_Classification__r.ESignature_allowed__c,  ';
        selectStr += ' Document_Classification__r.Proposal_Type__c, Document_Classification__r.Source_System__c,  ';
        selectStr += ' Document_Classification__r.Welcome_email_attachment__c from Partner_Document_Relationship__c ';
        List<String> ptrTypesList;
        
        if(userObj.ContactId != null){
            Contact contactObj = [Select Id, Ultimate_Parent_Account__c from Contact where Id =:userObj.ContactId];
            if(contactObj.Ultimate_Parent_Account__c != null){
                Account accountObj = [Select Id, partner_type__c from Account where Id =:contactObj.Ultimate_Parent_Account__c];
                ptrTypesList = new List<String>();
                if(salesPartnerId != null && installPartnerId != null && salesPartnerId == installPartnerId && installPartnerId == accountObj.Id){
                    ptrTypesList.add('Full Service');
                }else if(installPartnerId == accountObj.Id){
                    ptrTypesList.add('Install');
                }else if(salesPartnerId == accountObj.Id){
                    ptrTypesList.add('Sales');
                }
                
                if(ptrTypesList.size() > 0){
                    whereCondition = ' WHERE (Partner_Type__c in :ptrTypesList) ';
                }else{
                    whereCondition = ' WHERE (Partner_Type__c = null) ';
                }
            }
        }
		String partnerLocations = getPartnerLocations();

		whereCondition += (whereCondition == '' ) ? ' where (Mode__c in :modes) ' : ' AND (Mode__c in :modes) ';
		whereCondition += ' AND Document_Classification__r.category__c != \'General\' ';
		whereCondition += '  AND (Partner_Location_Type__c includes ' + partnerLocations + ' ) ';
        if(categoryType != null && categoryType != '' && categoryType == REQUIRES_SIGNATURE){
            whereCondition += (whereCondition == '' ) ? ' where ' : ' AND ';
            whereCondition +=  ' Document_Classification__r.ESignature_allowed__c = true ' ;
        }else if(categoryType != null && categoryType != '' && categoryType == REQUIRES_NO_SIGNATURE){
            whereCondition += (whereCondition == '' ) ? ' where ' : ' AND ';
            whereCondition +=  ' Document_Classification__r.ESignature_allowed__c = false ' ;
        }
        selectStr += whereCondition;    
        System.debug('selectStr: ' + selectStr);                                                         
        List<Partner_Document_Relationship__c> ptrDocRelationshipList  = Database.query(selectStr);
        
        for(Partner_Document_Relationship__c ptrDocObject : ptrDocRelationshipList){
            documentTypesMap.put(ptrDocObject.Id, ptrDocObject);
            tempDocumentTypes.add(ptrDocObject.Document_Classification__r.Document_Name__c);
        }
        return tempDocumentTypes;       
    }

	static Map<String, Document_Classification__c> documentClassificationMap;
	static Map<String, Document_Classification__c> documentClassificationMapById;
    public static Map<String, Document_Classification__c> getDocumentSettingsInformation(){
        if(documentClassificationMap == null || documentClassificationMap.size() == 0){
            documentClassificationMap = new Map<String, Document_Classification__c>();
            documentClassificationMapById = new Map<String, Document_Classification__c>();
            for(Document_Classification__c documentClassificationObj : [Select Id, Document_Name__c, Source_System__c  from Document_Classification__c]){
                documentClassificationMap.put(documentClassificationObj.Document_Name__c, documentClassificationObj);
                documentClassificationMapById.put(documentClassificationObj.Id, documentClassificationObj);
            }
        }
        return documentClassificationMap;
    }
    
	public static Map<Id, Set<String>> getProposalToolGeneratedDocumentTypes(Set<Id> proposalIds){
		System.debug('proposalIds: ' + proposalIds);
		Map<Id, Set<String>> documentTypesByProposal = new Map<Id, Set<String>>();
		String soqlStr ;
		String proposalSource = ProposalUtil.BLACK_BIRD;
        String documentSource = EDPUtil.PROPOSAL_TOOL_SOURCE;
        soqlStr = SRAttachmentManager.getSRAttachmentSOQL();
        soqlStr += '  where proposal__c in :proposalIds ' ;
        soqlStr += '  AND document_source__c = :documentSource ' ;
		soqlStr += '  AND Proposal_Source__c = :proposalSource ' ;
        soqlStr += '  AND active__c = true ' ;  
        for(SR_Attachment__c attachmentObj : Database.query(soqlStr)){   
        	System.debug('attachmentObj.proposal__r.name: ' + attachmentObj.proposal__r.name);
        	System.debug('attachmentObj.Parent_proposal_name__c: ' + attachmentObj.Parent_proposal_name__c);
			if(attachmentObj.proposal__r.name == attachmentObj.Parent_proposal_name__c){
				Set<String> documentTypes = documentTypesByProposal.containsKey(attachmentObj.proposal__c) ? 
	        							documentTypesByProposal.get(attachmentObj.proposal__c) : new Set<String>();
				documentTypes.add(attachmentObj.Document_Type_Name__c);
				documentTypesByProposal.put(attachmentObj.proposal__c, documentTypes);
        	}
        }
        return documentTypesByProposal;
	} 
    
    public static void setSRAttachmentDefaultSignedStatus(List<SR_Attachment__c> srAttachmentList, Set<Id> proposalIds, Set<Id> scIds){
        getDocumentSettingsInformation();
        Map<Id, Proposal__c> proposalMap = new Map<Id, Proposal__c>();
        Map<Id, ServiceContract> scMap = new Map<Id, ServiceContract>();
        if(proposalIds != null && !proposalIds.isEmpty()){
        	proposalMap = new Map<Id, Proposal__c>([Select Id, Name, proposal_source__c from Proposal__c where Id in :proposalIds]);
        }
		
		if(scIds != null && !scIds.isEmpty()){
        	scMap = new Map<Id, ServiceContract>([Select Id, Name from ServiceContract where Id in :scIds]);
        }
        
        Set<String> proposalDocTypes = new Set<String>();
        Map<Id, Set<String>> documentTypesByProposal = getProposalToolGeneratedDocumentTypes(proposalIds);
		
		for(SR_Attachment__c srAttachment:srAttachmentList){          
            Proposal__c proposalObj;
            if(srAttachment.Proposal__c != null){
				proposalObj = proposalMap.get(srAttachment.Proposal__c);
				if(proposalObj != null){
	            	srAttachment.Proposal_Source__c = proposalObj.proposal_source__c;
					if(srAttachment.parent_proposal_name__c == null || srAttachment.parent_proposal_name__c == ''){
						srAttachment.parent_proposal_name__c = proposalObj.Name;
					}
	            }
            }else if(srAttachment.Service_Contract__c != null){
            	ServiceContract scObj = scMap.get(srAttachment.Service_Contract__c);
				if(scObj != null){
					srAttachment.parent_proposal_name__c = scObj.Name;
	            }
            }
			
			Boolean initializedSignatureDetails = false;
            if(proposalObj != null && srAttachment.Document_Classification__c != null 
            	&& documentClassificationMapById.containskey(srAttachment.Document_Classification__c)){
                Document_Classification__c documentClassificationObj = documentClassificationMapById.get(srAttachment.Document_Classification__c);
				Set<String> documentTypes = documentTypesByProposal.get(srAttachment.Proposal__c);

				if(proposalObj != null && srAttachment.proposal_source__c != null && srAttachment.proposal_source__c == ProposalUtil.BLACK_BIRD 
					&& srAttachment.parent_proposal_name__c != '' && proposalObj.Name != srAttachment.parent_proposal_name__c){
					if(documentTypes != null && documentClassificationObj != null && documentTypes.contains(documentClassificationObj.Document_Name__c)){
						srAttachment.active__c = false;
					}
				}

				List<Partner_Document_Relationship__c> partnerDocumentRelationships =  documentClassificationObj.Partner_Document_Relationships__r;
				if(partnerDocumentRelationships != null && partnerDocumentRelationships.size() > 0){
					initializedSignatureDetails = true;
					Partner_Document_Relationship__c ptrRelationshipObj = partnerDocumentRelationships[0];
                
	                if(ptrRelationshipObj.Customer_signature_required__c != true){
	                    srAttachment.Customer_Signed__c = 'N/A';
	                }else if(srAttachment.Customer_Signed__c == 'N/A' ){
	                    srAttachment.Customer_Signed__c = '';
	                }
	                if(ptrRelationshipObj.Partner_signature_required__c != true){
	                    srAttachment.Partner_Signed__c = 'N/A';
	                }else if(srAttachment.Partner_Signed__c == 'N/A' ){
	                    srAttachment.Partner_Signed__c = '';
	                }
	                if(ptrRelationshipObj.SR_Ops_signature_required__c != true){
	                    srAttachment.SunRun_Signed__c = 'N/A';
	                }else if(srAttachment.SunRun_Signed__c == 'N/A' ){
	                    srAttachment.SunRun_Signed__c = '';
	                }
				}           
            }

			if(initializedSignatureDetails == true){
                srAttachment.Customer_Signed__c = 'N/A';
                srAttachment.Partner_Signed__c = 'N/A';
                srAttachment.SunRun_Signed__c = 'N/A';
            }  
        }
    }

    public static List<SelectOption> getDocumentsTypesToVoidESignRequests(String proposalId, Id salesPartnerId, Id installPartnerId){
        Set<String> modes = new Set<String>();
        String categoryType = EDPDocumentSettings.REQUIRES_SIGNATURE;
        String mandatoryRequirements = null;
        modes.add('Edit');
        Map<String, Document_Classification__c> documentTypesRequireSignature = EDPDocumentSettings.getDocumentClassificationByCategroy(categoryType, mandatoryRequirements, modes, 
        																																						salesPartnerId, installPartnerId);
        List<SelectOption> signedDocumentTypes = new List<SelectOption>();
        signedDocumentTypes.add(new SelectOption('', '--None--'));

		String soqlStr = SRAttachmentManager.getSRAttachmentSOQL();
		Set<String> documentTypes = documentTypesRequireSignature.keySet();
		soqlStr += ' where Proposal__c =:proposalId ' ;
		soqlStr += ' AND Document_Type_Name__c in :documentTypes ' ;
		for(SR_Attachment__c srAttachmentObj : Database.query(soqlStr)){
            if(srAttachmentObj.Envelop_Id__c != null && srAttachmentObj.Envelop_Id__c != ''){
                signedDocumentTypes.add(new SelectOption(srAttachmentObj.Document_Type_Name__c, srAttachmentObj.Document_Type_Name__c));
            }
        }
        return signedDocumentTypes;
    }    
    
    public static void testMethod1(){
    	
    	String categoryType = null;
    	String requiredForSubmission = MANDATORY_REQUIREMENTS;
    	Set<String> modes = new Set<String>();
		modes.add('Read');
		modes.add('Edit');
		modes.add('None');
		Id salesPartnerId = '0016000000HhqcQ';
		Id installPartnerId = '0016000000M0Wux';
		documentClassificationMap = getDocumentClassificationByCategroy(categoryType, 
    																							requiredForSubmission,
    																							modes,
                                                                                                salesPartnerId, installPartnerId);
       System.debug('documentClassificationMap: ' + documentClassificationMap);
    }
    
    public static Map<String, Proposal_Document_Type__c> getProposalDocumentTypes(Set<String> proposalDocumentTypes){
    	Map<String, Proposal_Document_Type__c> ProposalDocumentMap = new Map<String, Proposal_Document_Type__c>();
    	for(Proposal_Document_Type__c proposalDocTypeObj : [Select Id, name, Proposal_Document_Type_Name__c, Document_Classification__c, Document_Classification__r.Id, 
    															Document_Classification__r.Document_Name__c from Proposal_Document_Type__c
    															where Proposal_Document_Type_Name__c in :proposalDocumentTypes]){
    		ProposalDocumentMap.put(proposalDocTypeObj.Proposal_Document_Type_Name__c, proposalDocTypeObj);
    	}
    	return ProposalDocumentMap;
    }

	public static void updateDocumentType(Set<SR_Attachment__C> srAttachments){
		Set<String> proposalDocumentTypes = new Set<String>();
		proposalDocumentTypes.add('proposal');
		proposalDocumentTypes.add('Proposal');
        for(SR_Attachment__c srAttachment:srAttachments){
        	if(srAttachment.Proposal_Document_Type__c != null && srAttachment.Proposal_Document_Type__c != ''){
        		proposalDocumentTypes.add(srAttachment.Proposal_Document_Type__c);
        	}
        }
		
		if(proposalDocumentTypes.size() > 0){
	    	Map<String, Proposal_Document_Type__c> ProposalDocumentMap = getProposalDocumentTypes(proposalDocumentTypes);
	    	for(SR_Attachment__C srAttachmentObj : srAttachments){
				Proposal_Document_Type__c docType = ProposalDocumentMap.get(srAttachmentObj.Proposal_Document_Type__c);
				if(docType != null){
					srAttachmentObj.Document_Classification__c = docType.Document_Classification__c;
				}
				System.debug('srAttachmentObj.Proposal_Document_Type__c : ' + srAttachmentObj.Proposal_Document_Type__c);
				System.debug('srAttachmentObj.Document_Classification__c : ' + srAttachmentObj.Document_Classification__c);
	    	}
		}
    }
 
	public static String getPartnerLocations(){
		String locations = '';
		Contact lognContact = PRMContactUtil.getLoginUserContact();
		locations = ' (\'Headquarters\', \'Franchise\') ' ;
		if(lognContact != null && lognContact.Location__r != null 
			&& lognContact.Location__r.Headquarters__c == true){
			locations = ' (\'Headquarters\') ' ;
		}else if(lognContact != null && lognContact.Location__r != null 
			&& lognContact.Location__r.Headquarters__c == false){
			locations = ' (\'Franchise\') ' ;
		}
		System.debug('Partner Locations: ' + locations);
		return  locations;
	}
    
	//public static Set<String> getPartnerLocations(){
	//	Set<String> ptrLocations = new Set<String>();
		//ptrLocations.add(EDPUtil.HEADQUARTERS);
	//	ptrLocations.add(EDPUtil.FRANCHISE);
	//	return ptrLocations;
	//}
	
	public static Map<String, Map<String, Set<String>>> getDocumentTypesToCopyFromParent(){
		
		if(docClassificationMap != null && docClassificationMap.size() > 0){
			return docClassificationMap;
		}
		docClassificationMap = new Map<String, Map<String, Set<String>>>();
		Set<String> documentCategories = new Set<String>();
		documentCategories.add(ProposalUtil.SIGNED_DOCS);
		documentCategories.add(ProposalUtil.UN_SIGNED_DOCS);
		documentCategories.add(ProposalUtil.PROPOSAL_TOOL_GEN_DOCS);

		Set<String> proposalTypes = new Set<String>();
		proposalTypes.add(ProposalUtil.FULL_PROPOSAL);
		proposalTypes.add(ProposalUtil.NO_SIGNATURES_REQUIRED);
		proposalTypes.add(ProposalUtil.CUSTOMER_CHANGE_ORDER);
		proposalTypes.add(ProposalUtil.EPC_CHANGE_ORDER);
		proposalTypes.add(ProposalUtil.CUSTOMER_EPC_CHANGE_ORDER);
		proposalTypes.add(ProposalUtil.SALES_PARTNER_CHANGE_ORDER);
		
		for(Document_Classification__c docClassificationObj : [Select Document_Name__c, Id, ESignature_allowed__c, Source_System__c From Document_Classification__c  order by name]){
			Map<String, Set<String>> documentsMapByProposalType;
			Set<String> documentNames;
			Set<String> unSignedDocs;
			Set<String> proposalToolDocs;
			 
			for(String proposalType : proposalTypes){
				documentsMapByProposalType = docClassificationMap.containsKey(proposalType) ? docClassificationMap.get(proposalType) : new Map<String, Set<String>>();
				for(String documentCategory : documentCategories){
					System.debug('documentCategory: ' + documentCategory);
					documentNames = documentsMapByProposalType.containsKey(documentCategory) ? documentsMapByProposalType.get(documentCategory) : new Set<String>();
				
					//if(docClassificationObj.Document_Name__c == 'Design Plans' && proposalType == ProposalUtil.NO_SIGNATURES_REQUIRED){
					//	System.debug('documentCategory: ' + docClassificationObj.Document_Name__c );
					//	System.debug('proposalType: ' + proposalType );
					//	System.debug('documentNames: Before ' + documentNames );
					//}
					
					System.debug('docClassificationObj: ' + docClassificationObj);
					if(documentCategory == ProposalUtil.UN_SIGNED_DOCS 
						&& docClassificationObj.ESignature_allowed__c == false
						&& docClassificationObj.Source_System__c.contains(EDPUtil.MANUAL_UPLOAD_SOURCE)){
						documentNames.add(docClassificationObj.Document_Name__c);
					}
					
					if(documentCategory == ProposalUtil.PROPOSAL_TOOL_GEN_DOCS && proposalType != ProposalUtil.FULL_PROPOSAL){
						if(docClassificationObj.Document_Name__c == EDPUtil.CUSTOMER_AGREEMENT){
							documentNames.add(docClassificationObj.Document_Name__c);
						}else if(docClassificationObj.Document_Name__c == EDPUtil.EPC && 
							(proposalType == ProposalUtil.CUSTOMER_CHANGE_ORDER || proposalType == ProposalUtil.NO_SIGNATURES_REQUIRED || proposalType == ProposalUtil.SALES_PARTNER_CHANGE_ORDER)) {
							documentNames.add(docClassificationObj.Document_Name__c);
						}else if(docClassificationObj.Document_Name__c == EDPUtil.CHANGE_ORDER_COVER_SHEET && 
							(proposalType == ProposalUtil.EPC_CHANGE_ORDER || proposalType == ProposalUtil.NO_SIGNATURES_REQUIRED || proposalType == ProposalUtil.SALES_PARTNER_CHANGE_ORDER)) {
							documentNames.add(docClassificationObj.Document_Name__c);
						}else if(docClassificationObj.Source_System__c != null && docClassificationObj.Source_System__c.contains(EDPUtil.PROPOSAL_TOOL_SOURCE)){
							documentNames.add(docClassificationObj.Document_Name__c);
						}
					}
					
					
					if(documentCategory == ProposalUtil.SIGNED_DOCS && docClassificationObj.ESignature_allowed__c == true){
						if(proposalType != ProposalUtil.FULL_PROPOSAL){
							if(docClassificationObj.Document_Name__c == EDPUtil.EPC){
								if(proposalType == ProposalUtil.CUSTOMER_CHANGE_ORDER || proposalType == ProposalUtil.NO_SIGNATURES_REQUIRED || proposalType == ProposalUtil.SALES_PARTNER_CHANGE_ORDER) {
									documentNames.add(docClassificationObj.Document_Name__c);
								}
							}else if(docClassificationObj.Document_Name__c == EDPUtil.CHANGE_ORDER_COVER_SHEET){ 
								if(proposalType == ProposalUtil.EPC_CHANGE_ORDER || proposalType == ProposalUtil.NO_SIGNATURES_REQUIRED || proposalType == ProposalUtil.SALES_PARTNER_CHANGE_ORDER) {
									documentNames.add(docClassificationObj.Document_Name__c);
								}
							}else if(docClassificationObj.Document_Name__c == 'Customer Approved Plans'){ 
								if(proposalType == ProposalUtil.NO_SIGNATURES_REQUIRED || proposalType == ProposalUtil.SALES_PARTNER_CHANGE_ORDER) {
									documentNames.add(docClassificationObj.Document_Name__c);
								}
							}else if(docClassificationObj.Document_Name__c == 'Design Plans'){ 
								//if(proposalType == ProposalUtil.NO_SIGNATURES_REQUIRED || proposalType == ProposalUtil.SALES_PARTNER_CHANGE_ORDER) {
									documentNames.add(docClassificationObj.Document_Name__c);
								//}
							}else{
								documentNames.add(docClassificationObj.Document_Name__c);
							}
						}else if(proposalType == ProposalUtil.FULL_PROPOSAL){
							if(docClassificationObj.Document_Name__c == 'Home Improvement Contract' 
								|| docClassificationObj.Document_Name__c == 'Utility Relationship Letter'){
								documentNames.add(docClassificationObj.Document_Name__c);
							}
						}											
					}
					documentsMapByProposalType.put(documentCategory, documentNames);
					
					//if(docClassificationObj.Document_Name__c == 'Design Plans' && proposalType == ProposalUtil.NO_SIGNATURES_REQUIRED){
					//	System.debug('documentCategory: ' + docClassificationObj.Document_Name__c );
					//	System.debug('proposalType: ' + proposalType );
					//	System.debug('documentNames: After ' + documentNames );
					//}
				}
				docClassificationMap.put(proposalType, documentsMapByProposalType);
			}
		}
		System.debug('docClassificationMap: ' + docClassificationMap);
		return docClassificationMap;
	}
	
	public static void processSugevitySRAttchments(List<SR_Attachment__c> sungevitySRAttachments, Set<String> proposalNames, Set<Id> proposalIds){
		Map<String, Proposal__c> proposalMap = new Map<String, Proposal__c>();
		for(Proposal__c proposalObj : [Select Id, name from Proposal__c where name in :proposalNames]){
			proposalMap.put(proposalObj.Name, proposalObj);
		}
		
		for(SR_Attachment__c srAttachmentObj : sungevitySRAttachments){
			if(proposalMap.containsKey(srAttachmentObj.Parent_Proposal_Name__c)){
				srAttachmentObj.Proposal__c = proposalMap.get(srAttachmentObj.Parent_Proposal_Name__c).Id;
				proposalIds.add(srAttachmentObj.Proposal__c);
				if(srAttachmentObj.Proposal_Document_Type__c == 'Customer Agreement') {
					srAttachmentObj.Proposal_Document_Type__c = 'agreement-custom';
					srAttachmentObj.Document_Source__c = 'Proposal Tool';
					srAttachmentObj.Customer_Signed__c = 'Completed';
					srAttachmentObj.partner_signed__c = 'Completed';
					srAttachmentObj.SunRun_Signed__c = 'Wet Signed';
				}
				srAttachmentObj.active__C = true;
			}
		}
	}
	
	public static void setDefaultValuesForSugevitySRAttchments(List<SR_Attachment__c> sungevitySRAttachments){
		for(SR_Attachment__c srAttachmentObj : sungevitySRAttachments){
			srAttachmentObj.Document_Source__c = 'Proposal Tool';
			srAttachmentObj.Customer_Signed__c = 'Completed';
			srAttachmentObj.partner_signed__c = 'Completed';
			srAttachmentObj.SunRun_Signed__c = 'Wet Signed';
			srAttachmentObj.active__C = true;

		}
	}
}