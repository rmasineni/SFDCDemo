public with sharing class batchProcessM2SerialNumber {
    public static void processM2SerialNumber()    
    {
		Generation_Assets__c[] genAssetList = [Select Id From Generation_Assets__c 
												Where Process_Serial_Numbers_in_Batch__c = true 
												And SmartTurn_M2_StatusCode__c = null Limit 5];
		for (Generation_Assets__c genAsseetRec : genAssetList)
       	{
       		submitSerialNumber(genAsseetRec.Id);
       	}
    }

	@future (callout=true)
	public static void submitSerialNumber(String genAssetId)
	{
		Generation_Assets__c selGenAssetRec = [Select Id, Name, Account_Name__c, Cust_Ref_Num__c, Home_Address__c, City__c, 
									Install_Partner__c, State__c, Zip__c, M2_Status__c, 
									Cash_Grant_Eligible__c, Panel_Serial_Number__c,
                                    SmartTurn_M2_StatusCode__c, SmartTurn_Message__c,
                                    M2_Serial_Number_Submitted_UserId__c, 
            						(Select Panel_Type__c, Number_of_Panels__c 
            						From Facility_Configurations__r) From Generation_Assets__c Where Id = :genAssetId];

		Facility_Configuration__c[] panelList = selGenAssetRec.Facility_Configurations__r;

		Case caseRec;
		List<Case> caseRecList = [Select Id, Status, Denied_Comment__c, Denial_Reason__c, Generation_Asset__c, 
						Generation_Asset__r.Cust_Ref_Num__c, Customer_Reference_Number__c,
						Customer_Name__c,Customer_Mailing_Address__c
						From Case Where IsClosed = false And 
						RecordTypeId IN (Select Id from RecordType Where SobjectType = 'Case' And DeveloperName = 'Milestone_Proof')
						And Generation_Asset__c = :genAssetId And Milestone_Proof_Type__c = 'M2 Proof'];
		
		if(caseRecList.size() == 0)
			return;						
        
        caseRec = caseRecList[0];
        String panelSerialNumbers = selGenAssetRec.Panel_Serial_Number__c;
        panelSerialNumbers.replaceAll(' ', '');
        panelSerialNumbers = panelSerialNumbers.trim();

		System.debug('\n\n*** panelSerialNumbers '  + panelSerialNumbers + '***\n\n');

        List<String> listSerialNumbers = panelSerialNumbers.split('\r\n');
		List<String> listSlno = new List<String>();
		
		System.debug('\n\n*** listSerialNumbers '  + listSerialNumbers + '***\n\n');
		
    	Decimal totalPanelQty = 0;
    	
        for (Facility_Configuration__c panelRec : panelList)
        {
        	Decimal panelQty = panelRec.Number_of_Panels__c;
	        	
        	if (panelQty == null || panelQty <= 0)
        	{
        		panelQty = 1;
        	}
			totalPanelQty = totalPanelQty + panelQty;   	
        }
    	
    	if (totalPanelQty != listSerialNumbers.size())
    	{
            selGenAssetRec.SmartTurn_M2_StatusCode__c = 'FAILURE';
            selGenAssetRec.SmartTurn_Message__c = 'Serial Number count (' + listSerialNumbers.size() + ') does not match panel qty (' + totalPanelQty + ')';
			update selGenAssetRec;
			
			sendM2Email(caseRec, selGenAssetRec, true, 'Serial Number count (' + listSerialNumbers.size() + ') does not match panel qty (' + totalPanelQty + ')');
        	return;
    	}
    	
    	Integer recCount = 0;
        SmartTurn_OccamService.OccamService smartTurnService = new SmartTurn_OccamService.OccamService();
        smartTurnService.timeout_x = 60000;
        
        SmartTurn_OccamTypes.OccamPasswordCredential lookupInCredential = new SmartTurn_OccamTypes.OccamPasswordCredential();
        lookupInCredential.UserId = 'dsg@sunrunhome.com';
        lookupInCredential.Password = 'Test.123';
		
        SmartTurn_OccamTypes.Criterion invLookupCriterion = new SmartTurn_OccamTypes.Criterion();
        SmartTurn_OccamTypes.Criteria invLookupCriteria = new SmartTurn_OccamTypes.Criteria();
        
        List<SmartTurn_OccamTypes.Criterion> listCriterions = new List<SmartTurn_OccamTypes.Criterion>();
        
        invLookupCriterion.negate = false;
        invLookupCriterion.propertyName = 'serialNumber';
        invLookupCriterion.operator = 'in';
        invLookupCriterion.dateValue = date.today();

		SmartTurn_OccamTypes.arrayValueType slnoArray = new SmartTurn_OccamTypes.arrayValueType();
		
       	for ( Integer iCount=0; iCount < listSerialNumbers.size(); iCount++ ) 
       	{
       		if (iCount == 100)
       		{
       			slnoArray.stringValue = listSlno;
       			invLookupCriterion.arrayValue = slnoArray;
		        listCriterions.add(invLookupCriterion);
		        invLookupCriteria.criterions = listCriterions;
		        
				if (!Test.isRunningTest())
				{
			        smartTurn_LookupTypes.InventoryLookupResult invLookupResult = smartTurnService.lookUpInventory(lookupInCredential, invLookupCriteria);
			        
			        if (invLookupResult != null)
			        {
				        smartTurn_LookupTypes.ResultMetadata invLookupResultMetaData =  invLookupResult.resultMetadata;
				        
				        Integer resultTotalRecordsCount = invLookupResultMetaData.totalRecordsCount;
				        
			        	recCount = recCount + resultTotalRecordsCount;
			        }
			        else
			        {
			        	recCount = -1;
			        }
				}
				else
				{
					recCount = listSerialNumbers.size();					
				}
       			listSlno.clear();		
       		}
       		listSlno.add(listSerialNumbers[iCount]);
       	}
       	
		if (listSlno != null && listSlno.size() > 0)
		{
			slnoArray.stringValue = listSlno;
	        invLookupCriterion.arrayValue = slnoArray;
	        listCriterions.add(invLookupCriterion);
	        invLookupCriteria.criterions = listCriterions;
			if (!Test.isRunningTest())
			{
	        
		        smartTurn_LookupTypes.InventoryLookupResult invLookupResult = smartTurnService.lookUpInventory(lookupInCredential, invLookupCriteria);
		        
		        if (invLookupResult != null)
		        {
			        smartTurn_LookupTypes.ResultMetadata invLookupResultMetaData =  invLookupResult.resultMetadata;
			        
			        Integer resultTotalRecordsCount = invLookupResultMetaData.totalRecordsCount;
			        
//			        System.debug('\n\n*** resultTotalRecordsCount '  + resultTotalRecordsCount + '***\n\n');
			       
		        	recCount = recCount + resultTotalRecordsCount;
		        }
		        else
		        {
		        	recCount = -1;
		        }
			}
			else
			{
				recCount = listSerialNumbers.size();
			}
		}

		if (recCount == -1)
		{
            selGenAssetRec.SmartTurn_M2_StatusCode__c = 'FAILURE';
            selGenAssetRec.SmartTurn_Message__c = 'No response from SmartTurn when attempting to perform Inventory Lookup.';
			update selGenAssetRec;
			
			sendM2Email(caseRec, selGenAssetRec, true, 'No response from SmartTurn when attempting to perform Inventory Lookup');
			
        	return;
		}    	    
		else if (recCount != listSlno.size())
		{
            selGenAssetRec.SmartTurn_M2_StatusCode__c = 'FAILURE';
            selGenAssetRec.SmartTurn_Message__c = 'Number of serial numbers required (' + listSlno.size() + ') does not match number of valid serial numbers entered (' + recCount + '). Some of the entered serial numbers do not match our records for your panel inventory.';
			update selGenAssetRec;

			sendM2Email(caseRec, selGenAssetRec, true, 'Number of serial numbers required (' + listSlno.size() + ') does not match number of valid serial numbers entered (' + recCount + '). Some of the entered serial numbers do not match our records for your panel inventory.');

        	return;
		}    	    

        smartTurnService = new SmartTurn_OccamService.OccamService();
        smartTurnService.timeout_x = 60000;
        
        SmartTurn_OccamTypes.OccamPasswordCredential soInCredential = new SmartTurn_OccamTypes.OccamPasswordCredential();
        soInCredential.UserId = 'dsg@sunrunhome.com';
        soInCredential.Password = 'Test.123';

        List<SmartTurn_SalesOrderTypes.SalesOrder> soList = new List<SmartTurn_SalesOrderTypes.SalesOrder>(); 
        List<SmartTurn_SalesOrderTypes.SalesOrderItem> itemList = new List<SmartTurn_SalesOrderTypes.SalesOrderItem>();
	        
        SmartTurn_OccamTypes.Address shipTo = new SmartTurn_OccamTypes.Address(); 
        
        shipTo.addressLine1 =  selGenAssetRec.Home_Address__c;
        shipTo.city = selGenAssetRec.City__c;
        shipTo.state = selGenAssetRec.State__c;
        shipTo.postalCode = selGenAssetRec.Zip__c;
	
        SmartTurn_OccamTypes.Quantity itemQty= new SmartTurn_OccamTypes.Quantity();
        itemQty.value = 1.00;
        itemQty.unitAbbreviation = 'ea';
	
        SmartTurn_SalesOrderTypes.SalesOrder soRec = new SmartTurn_SalesOrderTypes.SalesOrder();
        soRec.externalNumber = selGenAssetRec.Name;
        soRec.type_x = 'EXTERNAL';
        soRec.date_x = date.today();
        soRec.dateDue = date.today();
        soRec.customerName = selGenAssetRec.Install_Partner__c;
        soRec.shipToContact = selGenAssetRec.Cust_Ref_Num__c;
        soRec.useShipToAsBillAddress = false;
        soRec.ShipTo = shipTo;
        soRec.priority = selGenAssetRec.Name;
	        
//        System.debug('\n\n*** panelList.size '  + panelList.size() + '***\n\n');
	    Integer jCount = 0; 
        for (Facility_Configuration__c panelRec : panelList)
        {
        	Decimal panelQty = panelRec.Number_of_Panels__c;
        	
        	if (panelQty == null || panelQty <= 0)
        	{
        		panelQty = 1;
        	}
	        	
        	Integer iCount = 0;
        	for ( iCount=0; iCount < panelQty; iCount++ ) 
        	{
		        SmartTurn_SalesOrderTypes.SalesOrderItem soItem = new SmartTurn_SalesOrderTypes.SalesOrderItem();
		        soItem.itemMasterId = panelRec.Panel_Type__c;
		        soItem.orderedQuantity = itemQty;
        		soItem.serialNumber = listSlno[jCount];
        		jCount++;
        		itemList.add(soItem);		
        	}
		}

        soRec.item = itemList;
	
        soList.add(soRec);

		if (!Test.isRunningTest())
		{
			List<SmartTurn_OccamTypes.UploadResponse> smartTurnSOSaveResponse = smartTurnService.overwriteSalesOrder(soInCredential, soList);
    
			if (smartTurnSOSaveResponse != null)
			{
            	System.debug('\n\n*** smartTurnSOSaveResponse.status '  + smartTurnSOSaveResponse[0].status + '***\n\n');
            
            	if (smartTurnSOSaveResponse[0].status == 'SUCCESS')
            	{
		            selGenAssetRec.SmartTurn_M2_StatusCode__c = 'SUCCESS';
		            selGenAssetRec.SmartTurn_Message__c = null;
		            
		            if (selGenAssetRec.M2_Status__c == 'Denied')
		            {
                		caseRec.Status = 'Request Approval';
                		caseRec.Denied_Comment__c = null;
                		caseRec.Denial_Reason__c = null;
                		update caseRec;

                		selGenAssetRec.M2_Denied_Comments__c = null;
			            selGenAssetRec.M2_Proof_Upload_Date__c = date.today();
			            selGenAssetRec.M2_Status__c = 'Pending';
		            }

		            update selGenAssetRec;
	
	        	    sendM2Email(caseRec, selGenAssetRec, false, '');

	    			return;
	            }
    	        else
        	    {
            	    String[] errorList = smartTurnSOSaveResponse[0].error;
	                selGenAssetRec.SmartTurn_M2_StatusCode__c = 'FAILURE';
    	            selGenAssetRec.SmartTurn_Message__c = errorList[0];
	        	    update selGenAssetRec;

					sendM2Email(caseRec, selGenAssetRec, true, errorList[0]);

	    			return;
            	}
        	}
        	else
        	{
    	        selGenAssetRec.SmartTurn_M1_StatusCode__c = 'FAILURE';
        	    selGenAssetRec.SmartTurn_Message__c = 'No response from SmartTurn when attempting to Submit the Serial Numbers';
        	    update selGenAssetRec;
        	    
        	    sendM2Email(caseRec, selGenAssetRec, true, 'No response from SmartTurn when attempting to Submit the Serial Numbers');
        	    
    			return;
        	}
		}
		else
		{
			return;
		}
	}
	
	public static void sendM2Email(Case caseRec, Generation_Assets__c genAssetRec, Boolean isError, String errorMessage)
	{
        if (genAssetRec.M2_Serial_Number_Submitted_UserId__c != null && genAssetRec.M2_Serial_Number_Submitted_UserId__c != '')
        {
	        User[] userList = [Select Contact.AccountId, Contact.FirstName, ContactId From User WHERE Id = :genAssetRec.M2_Serial_Number_Submitted_UserId__c Limit 1];
	        
	        if (userList != null && userList.size() > 0)
	        {
		        List<Milestone_Proof_Partner_Preference__c> partnerPreferenceList = [Select Id, Notify_Milestone_Proof_Upload__c, Emails_To_Notify_Milestone_Proof_Upload__c 
		                        From Milestone_Proof_Partner_Preference__c Where Partner_Account__c = :userList[0].Contact.AccountId Limit 1];
		
				if (partnerPreferenceList != null && partnerPreferenceList.size() > 0)
				{
					if (partnerPreferenceList[0].Emails_To_Notify_Milestone_Proof_Upload__c != null)
					{
						List<String> partnerEmailId = partnerPreferenceList[0].Emails_To_Notify_Milestone_Proof_Upload__c.split(',');
						System.debug('\n\n*** partnerEmailId '  + partnerEmailId + '***\n\n');
						if (partnerEmailId != null)
						{
							EmailTemplate[] templateList = null;
							
							if (isError)
							{
								templateList = [select Subject, body , HtmlValue, DeveloperName from EmailTemplate Where developerName = 'M2_Serial_Number_Submit_Error' Limit 1];
							}
							else
							{
								templateList = [select Subject, body , HtmlValue, DeveloperName from EmailTemplate Where developerName = 'M2_Serial_Number_Submit_Success' Limit 1];
							}
							if (templateList != null && templateList.size() > 0)
							{
								EmailTemplate templRec1 = templateList[0];
								String templBody =  templRec1.Body;
								String emailSubject = templRec1.Subject;
								templBody = templBody.replace('{!Contact.FirstName}', userList[0].Contact.FirstName);
								templBody = templBody.replace('{!Case.Customer_Reference_Number__c}', caseRec.Customer_Reference_Number__c);
								templBody = templBody.replace('{!Case.Customer_Name__c}', caseRec.Customer_Name__c);
								templBody = templBody.replace('{!Case.Customer_Mailing_Address__c}', caseRec.Customer_Mailing_Address__c);
		                        if (isError)
		                        {
		                        	templBody = templBody.replace('{!errorMessage}', errorMessage);
		                        }        
								Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
								mail.setSubject(emailSubject);
								mail.setToAddresses( partnerEmailId );
								mail.setPlainTextBody(templBody);
		
								Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });                                       
								
							}
						}
					}
				}
	        }
        }			
	}
	
	public static testMethod void batchM2SlNoFileUploadTest()
    {
        Test.startTest();
        
        milestoneM2SlNoFileUpload testMilestoneM2SlNoFileUpload = new milestoneM2SlNoFileUpload();
        
        Account accountRec = new Account();
        accountRec.Name = 'Test Class';
        insert accountRec;
 
        Contact contactRec = new Contact();
        contactRec.FirstName = 'DSG';
        contactRec.LastName = 'Test';
        contactRec.AccountId = accountRec.Id;
        contactRec.Email = 'test@test.com';
        insert contactRec;

//		Contact contactRec = [Select Id,AccountId From Contact Where isDeleted = false Limit 1];
		
//		Account accountRec = [Select Id From Account Where Id = :contactRec.AccountId];
		
        Generation_Assets__c genAssetRec = new Generation_Assets__c();
        genAssetRec.Account_Name__c = accountRec.Id;
        genAssetRec.Customer_Contact__c = contactRec.Id;
        genAssetRec.Home_Address__c = 'Test Class';
        genAssetRec.City__c = 'Los Gatos';
        genAssetRec.Zip__c = '95032';
        genAssetRec.Asset_Status__c = 'Plans Approved, Awaiting NTP';
        genAssetRec.Facility_Design_Approved__c = date.today();
        genAssetRec.NTP_Granted__c = date.today();
		genAssetRec.Cash_Grant_Eligible__c = true;
		genAssetRec.Process_Serial_Numbers_in_Batch__c = true;

        genAssetRec.SR_Signoff__c = date.today();
        genAssetRec.Facility_Design_Approved__c = date.today();
        genAssetRec.Complete_Deal_Received__c = date.today();
 		genAssetRec.Initial_Deposit_Processed__c = date.today();
 		genAssetRec.Initial_Deposit_Amount_Received__c = 10000;
		genAssetRec.Initial_Deposit_Amount__c = 10000;
		genAssetRec.Rebate_Conf_Rec_d__c  = date.today();
		genAssetRec.Final_Rebate_Amount__c = 100.00;
		genAssetRec.Rebate_Conf_Num__c = '234533';
        insert genAssetRec;

        Generation_Assets__c genAssetRec2 = new Generation_Assets__c();
        genAssetRec2.Account_Name__c = accountRec.Id;
        genAssetRec2.Customer_Contact__c = contactRec.Id;
        genAssetRec2.Home_Address__c = 'Test Class';
        genAssetRec2.City__c = 'Los Gatos';
        genAssetRec2.Zip__c = '95032';
        genAssetRec2.Asset_Status__c = 'Plans Approved, Awaiting NTP';
        genAssetRec2.Facility_Design_Approved__c = date.today();
        genAssetRec2.NTP_Granted__c = date.today();
		genAssetRec2.Cash_Grant_Eligible__c = true;
		genAssetRec2.Process_Serial_Numbers_in_Batch__c = true;

        genAssetRec2.SR_Signoff__c = date.today();
        genAssetRec2.Facility_Design_Approved__c = date.today();
        genAssetRec2.Complete_Deal_Received__c = date.today();
 		genAssetRec2.Initial_Deposit_Processed__c = date.today();
 		genAssetRec2.Initial_Deposit_Amount_Received__c = 10000;
		genAssetRec2.Initial_Deposit_Amount__c = 10000;
		genAssetRec2.Rebate_Conf_Rec_d__c  = date.today();
		genAssetRec2.Final_Rebate_Amount__c = 100.00;
		genAssetRec2.Rebate_Conf_Num__c = '234533';
        insert genAssetRec2;

        Generation_Assets__c genAssetRec3 = new Generation_Assets__c();
        genAssetRec3.Account_Name__c = accountRec.Id;
        genAssetRec3.Customer_Contact__c = contactRec.Id;
        genAssetRec3.Home_Address__c = 'Test Class';
        genAssetRec3.City__c = 'Los Gatos';
        genAssetRec3.Zip__c = '95032';
        genAssetRec3.Asset_Status__c = 'Plans Approved, Awaiting NTP';
        genAssetRec3.Facility_Design_Approved__c = date.today();
        genAssetRec3.NTP_Granted__c = date.today();
		genAssetRec3.Cash_Grant_Eligible__c = true;
		genAssetRec3.Process_Serial_Numbers_in_Batch__c = true;

        genAssetRec3.SR_Signoff__c = date.today();
        genAssetRec3.Facility_Design_Approved__c = date.today();
        genAssetRec3.Complete_Deal_Received__c = date.today();
 		genAssetRec3.Initial_Deposit_Processed__c = date.today();
 		genAssetRec3.Initial_Deposit_Amount_Received__c = 10000;
		genAssetRec3.Initial_Deposit_Amount__c = 10000;
		genAssetRec3.Rebate_Conf_Rec_d__c  = date.today();
		genAssetRec3.Final_Rebate_Amount__c = 100.00;
		genAssetRec3.Rebate_Conf_Num__c = '234533';
        insert genAssetRec3;

        Generation_Assets__c genAssetRec4 = new Generation_Assets__c();
        genAssetRec4.Account_Name__c = accountRec.Id;
        genAssetRec4.Customer_Contact__c = contactRec.Id;
        genAssetRec4.Home_Address__c = 'Test Class';
        genAssetRec4.City__c = 'Los Gatos';
        genAssetRec4.Zip__c = '95032';
        genAssetRec4.Asset_Status__c = 'Plans Approved, Awaiting NTP';
        genAssetRec4.Facility_Design_Approved__c = date.today();
        genAssetRec4.NTP_Granted__c = date.today();
		genAssetRec4.Cash_Grant_Eligible__c = true;
		genAssetRec4.Process_Serial_Numbers_in_Batch__c = true;

        genAssetRec4.SR_Signoff__c = date.today();
        genAssetRec4.Facility_Design_Approved__c = date.today();
        genAssetRec4.Complete_Deal_Received__c = date.today();
 		genAssetRec4.Initial_Deposit_Processed__c = date.today();
 		genAssetRec4.Initial_Deposit_Amount_Received__c = 10000;
		genAssetRec4.Initial_Deposit_Amount__c = 10000;
		genAssetRec4.Rebate_Conf_Rec_d__c  = date.today();
		genAssetRec4.Final_Rebate_Amount__c = 100.00;
		genAssetRec4.Rebate_Conf_Num__c = '234533';
        insert genAssetRec4;

        Generation_Assets__c genAssetRec5 = new Generation_Assets__c();
        genAssetRec5.Account_Name__c = accountRec.Id;
        genAssetRec5.Customer_Contact__c = contactRec.Id;
        genAssetRec5.Home_Address__c = 'Test Class';
        genAssetRec5.City__c = 'Los Gatos';
        genAssetRec5.Zip__c = '95032';
        genAssetRec5.Asset_Status__c = 'Plans Approved, Awaiting NTP';
        genAssetRec5.Facility_Design_Approved__c = date.today();
        genAssetRec5.NTP_Granted__c = date.today();
		genAssetRec5.Cash_Grant_Eligible__c = true;
		genAssetRec5.Process_Serial_Numbers_in_Batch__c = true;

        genAssetRec5.SR_Signoff__c = date.today();
        genAssetRec5.Facility_Design_Approved__c = date.today();
        genAssetRec5.Complete_Deal_Received__c = date.today();
 		genAssetRec5.Initial_Deposit_Processed__c = date.today();
 		genAssetRec5.Initial_Deposit_Amount_Received__c = 10000;
		genAssetRec5.Initial_Deposit_Amount__c = 10000;
		genAssetRec5.Rebate_Conf_Rec_d__c  = date.today();
		genAssetRec5.Final_Rebate_Amount__c = 100.00;
		genAssetRec5.Rebate_Conf_Num__c = '234533';
        insert genAssetRec5;

        Generation_Assets__c genAssetRec6 = new Generation_Assets__c();
        genAssetRec6.Account_Name__c = accountRec.Id;
        genAssetRec6.Customer_Contact__c = contactRec.Id;
        genAssetRec6.Home_Address__c = 'Test Class';
        genAssetRec6.City__c = 'Los Gatos';
        genAssetRec6.Zip__c = '95032';
        genAssetRec6.Asset_Status__c = 'Plans Approved, Awaiting NTP';
        genAssetRec6.Facility_Design_Approved__c = date.today();
        genAssetRec6.NTP_Granted__c = date.today();
		genAssetRec6.Cash_Grant_Eligible__c = true;
		genAssetRec6.Process_Serial_Numbers_in_Batch__c = true;

        genAssetRec6.SR_Signoff__c = date.today();
        genAssetRec6.Facility_Design_Approved__c = date.today();
        genAssetRec6.Complete_Deal_Received__c = date.today();
 		genAssetRec6.Initial_Deposit_Processed__c = date.today();
 		genAssetRec6.Initial_Deposit_Amount_Received__c = 10000;
		genAssetRec6.Initial_Deposit_Amount__c = 10000;
		genAssetRec6.Rebate_Conf_Rec_d__c  = date.today();
		genAssetRec6.Final_Rebate_Amount__c = 100.00;
		genAssetRec6.Rebate_Conf_Num__c = '234533';
        insert genAssetRec6;

        Generation_Assets__c selGenAssetRec = [Select Cust_Ref_Num__c From Generation_Assets__c Where Id = :genAssetRec.Id];
		Generation_Assets__c selGenAssetRec2 = [Select Cust_Ref_Num__c From Generation_Assets__c Where Id = :genAssetRec2.Id];
		Generation_Assets__c selGenAssetRec3 = [Select Cust_Ref_Num__c From Generation_Assets__c Where Id = :genAssetRec3.Id];
		Generation_Assets__c selGenAssetRec4 = [Select Cust_Ref_Num__c From Generation_Assets__c Where Id = :genAssetRec4.Id];
		Generation_Assets__c selGenAssetRec5 = [Select Cust_Ref_Num__c From Generation_Assets__c Where Id = :genAssetRec5.Id];
		Generation_Assets__c selGenAssetRec6 = [Select Cust_Ref_Num__c From Generation_Assets__c Where Id = :genAssetRec6.Id];
		
        testMilestoneM2SlNoFileUpload.fullPathFileName = 'temp.csv';
			
        Blob bodyBlob=null;

        String headerLine = 'Verengo Job #,Partner Reference #,Module Part #,Module Serial #' + '\n';
        String lineValue = 'Test-1,' +  selGenAssetRec.Cust_Ref_Num__c + ',LG245S1C-G2,K21117290391' + '\n';
        lineValue+= 'Test-1,' +  selGenAssetRec2.Cust_Ref_Num__c + ',LG245S1C-G2,K21117290391' + '\n';
        lineValue+= 'Test-1,' +  selGenAssetRec3.Cust_Ref_Num__c + ',LG245S1C-G2,K21117290391' + '\n';
        lineValue+= 'Test-1,' +  selGenAssetRec4.Cust_Ref_Num__c + ',LG245S1C-G2,K21117290391' + '\n';
        lineValue+= 'Test-1,' +  selGenAssetRec5.Cust_Ref_Num__c + ',LG245S1C-G2,K21117290391' + '\n';
        lineValue+= 'Test-1,' +  selGenAssetRec6.Cust_Ref_Num__c + ',LG245S1C-G2,K21117290391' + '\n';
        
		String fileContent = headerLine + lineValue;

        bodyBlob=Blob.valueOf(fileContent);
        testMilestoneM2SlNoFileUpload.fileBody = bodyBlob;

		List<Facility_Configuration__c> insFacility = new List<Facility_Configuration__c>();
		
		Facility_Configuration__c panelRec = new Facility_Configuration__c();
		panelRec.Generation_Asset__c = genAssetRec.Id;
		panelRec.Number_of_Panels__c = 1;
		panelRec.Panel_Type__c = 'LG245S1C-G2';
		
		insFacility.add(panelRec);

		Facility_Configuration__c panelRec2 = new Facility_Configuration__c();
		panelRec2.Generation_Asset__c = genAssetRec2.Id;
		panelRec2.Number_of_Panels__c = 1;
		panelRec2.Panel_Type__c = 'LG245S1C-G2';
		
		insFacility.add(panelRec2);
		
		Facility_Configuration__c panelRec3 = new Facility_Configuration__c();
		panelRec3.Generation_Asset__c = genAssetRec3.Id;
		panelRec3.Number_of_Panels__c = 1;
		panelRec3.Panel_Type__c = 'LG245S1C-G2';
		
		insFacility.add(panelRec3);

		Facility_Configuration__c panelRec4 = new Facility_Configuration__c();
		panelRec4.Generation_Asset__c = genAssetRec4.Id;
		panelRec4.Number_of_Panels__c = 1;
		panelRec4.Panel_Type__c = 'LG245S1C-G2';
		
		insFacility.add(panelRec4);

		Facility_Configuration__c panelRec5 = new Facility_Configuration__c();
		panelRec5.Generation_Asset__c = genAssetRec5.Id;
		panelRec5.Number_of_Panels__c = 1;
		panelRec5.Panel_Type__c = 'LG245S1C-G2';
		
		insFacility.add(panelRec5);

		Facility_Configuration__c panelRec6 = new Facility_Configuration__c();
		panelRec6.Generation_Asset__c = genAssetRec6.Id;
		panelRec6.Number_of_Panels__c = 1;
		panelRec6.Panel_Type__c = 'LG245S1C-G2';
		
		insFacility.add(panelRec6);
		
		insert insFacility;

//     	batchProcessM2SerialNumber.processM2SerialNumber();
        
        RecordType mileStoneRecType = testMilestoneM2SlNoFileUpload.mileStoneRecType;
        
        List<Case> insCase = new List<Case>();
        
        Case currentCaseRec = new Case();
        currentCaseRec.RecordTypeId = mileStoneRecType.Id;
        currentCaseRec.AccountId = accountRec.Id;
        currentCaseRec.ContactId = contactRec.Id;
        currentCaseRec.Milestone_Proof_Type__c = 'M2 Proof';
        currentCaseRec.Status = 'Request Approval';
        currentCaseRec.Origin = 'Install Partner'; 
        currentCaseRec.Reason = 'Documentation';
        currentCaseRec.Description = 'Milestone Proof Submitted';
        currentCaseRec.Subject = 'Milestone Proof Submitted';
        currentCaseRec.Generation_Asset__c = genAssetRec.Id;
        insCase.add(currentCaseRec);
        
        Case currentCaseRec2 = new Case();
        currentCaseRec2.RecordTypeId = mileStoneRecType.Id;
        currentCaseRec2.AccountId = accountRec.Id;
        currentCaseRec2.ContactId = contactRec.Id;
        currentCaseRec2.Milestone_Proof_Type__c = 'M2 Proof';
        currentCaseRec2.Status = 'Request Approval';
        currentCaseRec2.Origin = 'Install Partner'; 
        currentCaseRec2.Reason = 'Documentation';
        currentCaseRec2.Description = 'Milestone Proof Submitted';
        currentCaseRec2.Subject = 'Milestone Proof Submitted';
        currentCaseRec2.Generation_Asset__c = genAssetRec2.Id;
        insCase.add(currentCaseRec2);

        Case currentCaseRec3 = new Case();
        currentCaseRec3.RecordTypeId = mileStoneRecType.Id;
        currentCaseRec3.AccountId = accountRec.Id;
        currentCaseRec3.ContactId = contactRec.Id;
        currentCaseRec3.Milestone_Proof_Type__c = 'M2 Proof';
        currentCaseRec3.Status = 'Request Approval';
        currentCaseRec3.Origin = 'Install Partner'; 
        currentCaseRec3.Reason = 'Documentation';
        currentCaseRec3.Description = 'Milestone Proof Submitted';
        currentCaseRec3.Subject = 'Milestone Proof Submitted';
        currentCaseRec3.Generation_Asset__c = genAssetRec3.Id;
        insCase.add(currentCaseRec3);

        Case currentCaseRec4 = new Case();
        currentCaseRec4.RecordTypeId = mileStoneRecType.Id;
        currentCaseRec4.AccountId = accountRec.Id;
        currentCaseRec4.ContactId = contactRec.Id;
        currentCaseRec4.Milestone_Proof_Type__c = 'M2 Proof';
        currentCaseRec4.Status = 'Request Approval';
        currentCaseRec4.Origin = 'Install Partner'; 
        currentCaseRec4.Reason = 'Documentation';
        currentCaseRec4.Description = 'Milestone Proof Submitted';
        currentCaseRec4.Subject = 'Milestone Proof Submitted';
        currentCaseRec4.Generation_Asset__c = genAssetRec4.Id;
        insCase.add(currentCaseRec4);

        Case currentCaseRec5 = new Case();
        currentCaseRec5.RecordTypeId = mileStoneRecType.Id;
        currentCaseRec5.AccountId = accountRec.Id;
        currentCaseRec5.ContactId = contactRec.Id;
        currentCaseRec5.Milestone_Proof_Type__c = 'M2 Proof';
        currentCaseRec5.Status = 'Request Approval';
        currentCaseRec5.Origin = 'Install Partner'; 
        currentCaseRec5.Reason = 'Documentation';
        currentCaseRec5.Description = 'Milestone Proof Submitted';
        currentCaseRec5.Subject = 'Milestone Proof Submitted';
        currentCaseRec5.Generation_Asset__c = genAssetRec5.Id;
        insCase.add(currentCaseRec5);
        
        Case currentCaseRec6 = new Case();
        currentCaseRec6.RecordTypeId = mileStoneRecType.Id;
        currentCaseRec6.AccountId = accountRec.Id;
        currentCaseRec6.ContactId = contactRec.Id;
        currentCaseRec6.Milestone_Proof_Type__c = 'M2 Proof';
        currentCaseRec6.Status = 'Request Approval';
        currentCaseRec6.Origin = 'Install Partner'; 
        currentCaseRec6.Reason = 'Documentation';
        currentCaseRec6.Description = 'Milestone Proof Submitted';
        currentCaseRec6.Subject = 'Milestone Proof Submitted';
        currentCaseRec6.Generation_Asset__c = genAssetRec6.Id;
        insCase.add(currentCaseRec6);
                
        insert insCase;

     	testMilestoneM2SlNoFileUpload.uploadSlNo();

		batchProcessM2SerialNumber.processM2SerialNumber();
 
        SchedulableContext ctx;
        scheduleBatchProcessM2SerialNumber testObj = new scheduleBatchProcessM2SerialNumber();
        testObj.execute(ctx);
 
 		Test.stopTest();    	
    }	
}