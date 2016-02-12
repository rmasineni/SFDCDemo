/*
 *  The purpose of this class is to provide a VF Page in which the user will upload 
 *  a CSV file in a specific format. After performing all validations, the serial numbers
 *  in the file will be updated into the external system SMARTTURN using webservices.
*/

public with sharing class milestoneM2SlNoFileUpload 
{
    public string fullPathFileName {get;set;}   
	public transient Blob fileBody {get;set;}  
	public RecordType mileStoneRecType {get;set;}
	public string errormsg {get; set;}
	public string validationMsg {get; set;}
	public string submitMsg {get; set;}
	public string finalMsg {get; set;}
	public integer jobColIndex {get; set;}
	public integer custRefColIndex {get; set;}
	public integer partNumColIndex {get; set;}
	public integer slNoColIndex {get; set;}
	List<string> custRefSlNoMap = new List<string>();
	List<string> custRefSlNoMapForM2Submit = new List<string>();
	public Map<String, Generation_Assets__c> genAssetMap = new Map<String, Generation_Assets__c>();
	public Map<String, Case> caseMap = new Map<String, Case>();
	static final string crlf = '<br/>'; 		
		
	public milestoneM2SlNoFileUpload()
	{
        mileStoneRecType = [Select Id from RecordType Where SobjectType = 'Case' And DeveloperName = 'Milestone_Proof'];
		
	}

	public PageReference uploadSlNo()
	{
		finalMsg = null;
		validationMsg = null;
		submitMsg = null;
		if (validateFile())
		{
			List<Generation_Assets__c> assetsToUpdate = new List<Generation_Assets__c>();
			List<Case> casesToUpdate = new List<Case>();
			if (custRefSlNoMapForM2Submit != null && custRefSlNoMapForM2Submit.size() <= 5)
			{
				for (String custRefSlNo : custRefSlNoMapForM2Submit)
				{
		            String[] custRefSlNoValues = new String[]{};
		            custRefSlNoValues = custRefSlNo.split(':');
		            
		            String custRefNum = custRefSlNoValues[0];
		            String slNo = custRefSlNoValues[1];
					
					System.debug('\n\n*** custRefNum '  + custRefNum + '***\n\n');				
					System.debug('\n\n*** slNo '  + slNo + '***\n\n');
					
					List<string> listSlno = slNo.split(',');
		            
		            Generation_Assets__c genAssetRec = genAssetMap.get(custRefNum);
					Case caseRec = caseMap.get(custRefNum);
					
					submitSerialNumber(genAssetRec, caseRec, listSlno, slNo, assetsToUpdate, casesToUpdate);
				}
				if (assetsToUpdate != null && assetsToUpdate.size() > 0)
				{
					update assetsToUpdate;
				}
				if (casesToUpdate != null && casesToUpdate.size() > 0)
				{
					update casesToUpdate;
				}
			}
			else
			{
				for (String custRefSlNo : custRefSlNoMapForM2Submit)
				{
		            String[] custRefSlNoValues = new String[]{};
		            custRefSlNoValues = custRefSlNo.split(':');
		            
		            String custRefNum = custRefSlNoValues[0];
		            String slNo = custRefSlNoValues[1];
					
					System.debug('\n\n*** custRefNum '  + custRefNum + '***\n\n');				
					System.debug('\n\n*** slNo '  + slNo + '***\n\n');
					
		            slNo = slNo.replaceAll(',', '\r\n');
		            
		            Generation_Assets__c genAssetRec = genAssetMap.get(custRefNum);
		            genAssetRec.Panel_Serial_Number__c = slNo;
		            genAssetRec.Process_Serial_Numbers_in_Batch__c = true;
		            genAssetRec.M2_Serial_Number_Submitted_UserId__c = Userinfo.getUserid();
		            genAssetRec.SmartTurn_M2_StatusCode__c = null;
		            assetsToUpdate.add(genAssetRec);
				}
				if (assetsToUpdate != null && assetsToUpdate.size() > 0)
				{
					update assetsToUpdate;
					submitMsg = 'Partner portal users will be notified by email when Serial Numbers have been processed.';
				}
			}
			if (validationMsg == null)
			{
				validationMsg = '';
			}
			if (submitMsg == null)
			{
				submitMsg = '';
			}
			finalMsg = validationMsg + crlf + submitMsg;
		}
		return null;
	}

	public Boolean validateFile()
	{
		
		if (fileBody == null || fileBody.size() <= 0)
		{
			errormsg = 'Uploaded file is empty or does not have any content';
			setErrorMsg();
			return false;
		}
		
		String[] fileLines = new String[]{};	
		String fileContentString = fileBody.toString();
		fileLines = fileContentString.split('\n');

		String headerLine = fileLines[0];
		
		if (headerLine == null || headerLine == '' || headerLine == '\n')
		{
			errormsg = 'Header Line is missing in the file';
			setErrorMsg();
			return false;
		}
		
//		System.debug('\n\n*** headerLineBefore '  + headerLine + '***\n\n');
		
		headerLine = headerLine.replaceAll('\n', '');
		headerLine = headerLine.trim();
		
		jobColIndex = getHeaderColumnIndex(headerLine, 'Verengo Job #');
		
		custRefColIndex = getHeaderColumnIndex(headerLine, 'Partner Reference #');
		
		partNumColIndex = getHeaderColumnIndex(headerLine, 'Module Part #');
														 
		slNoColIndex = getHeaderColumnIndex(headerLine, 'Module Serial #');
		
		if (jobColIndex == -1 && custRefColIndex == -1 && partNumColIndex == -1 && slNoColIndex == -1)
		{
			errormsg = 'Header Line is missing in the file';
			setErrorMsg();
			return false;
		}

		String retVal = getInvalidHeaderColumn(headerLine);
		
		if (retVal != null)
		{
			errormsg = 'Invalid column "' + retVal + '" in Header Line. The valid column headers are: "Verengo Job #", "Partner Reference #", "Module Part #", "Module Serial #".';
			setErrorMsg();
			return false;
			
		}

		if (jobColIndex == -1 || custRefColIndex == -1 || partNumColIndex == -1 || slNoColIndex == -1)
		{
			errormsg = 'The valid column headers are: "Verengo Job #", "Partner Reference #", "Module Part #", "Module Serial #".';
			setErrorMsg();
			return false;
		}
		
		if (fileLines.size() == 1)	//contains just header and no data
		{
			errormsg = 'Uploaded file is empty or does not have any content';
			setErrorMsg();
			return false;
		}
		
		String oldCustRefNo = '';
		List<string> custRefNoList = new List<string>();
		List<string> genAssetIdList = new List<string>();
		
		for (Integer i=1;i<fileLines.size();i++)
        {
            String[] lineValues = new String[]{};
            lineValues = fileLines[i].split(',');
            
            String custRefNum = lineValues[custRefColIndex];
            String slNo = lineValues[slNoColIndex];
            
            if (custRefNum == null || custRefNum == '' || custRefNum == '\r') 
            {
				errormsg = 'Partner Reference # is missing in line ' + (i+1) ;
    			setErrorMsg();
				return false;
            }
            if (slNo == null || slNo == '' || slNo == '\r')
            {
				errormsg = 'Module Serial # is missing in line ' + (i+1);
    			setErrorMsg();
    			return false;
            }
            
            if (custRefNum != oldCustRefNo)
            {
            	custRefNoList.add(custRefNum);
            	oldCustRefNo = custRefNum;
            }
        }		

		System.debug('\n\n*** custRefNoList '  + custRefNoList + '***\n\n');
		
		Generation_Assets__c[] genAssetList = [Select Id, Name, Account_Name__c, Cust_Ref_Num__c, Home_Address__c, City__c, 
									Install_Partner__c, State__c, Zip__c, M2_Status__c, 
									Cash_Grant_Eligible__c, Panel_Serial_Number__c,
                                    SmartTurn_M2_StatusCode__c, SmartTurn_Message__c, 
            						(Select Panel_Type__c, Number_of_Panels__c  From Facility_Configurations__r) From Generation_Assets__c Where Cust_Ref_Num__c IN :custRefNoList];
		
		List<Case> caseList = [Select Id, Status, Denied_Comment__c, Denial_Reason__c, Generation_Asset__c, Generation_Asset__r.Cust_Ref_Num__c From Case Where IsClosed = false And RecordTypeId = :mileStoneRecType.Id
		               			And Generation_Asset__r.Cust_Ref_Num__c IN :custRefNoList And Milestone_Proof_Type__c = 'M2 Proof'];
            						 

		for (Generation_Assets__c genAssetRec : genAssetList)
		{
			genAssetMap.put(genAssetRec.Cust_Ref_Num__c, genAssetRec);
		}

		for (Case caseRec : caseList)
		{
			caseMap.put(caseRec.Generation_Asset__r.Cust_Ref_Num__c, caseRec);
		}
		 
		for (String custRefNo : custRefNoList)
		{
			Generation_Assets__c genAssetRec = genAssetMap.get(custRefNo);
			if (genAssetRec == null)
			{
				errormsg = 'Partner Reference # ' + custRefNo + ' not found in Salesforce. None of the records in this file were processed.';
    			setErrorMsg();
    			return false;
			}						
		}	
		
		oldCustRefNo = '';
		String custRefSlNoString = '';
		if (custRefSlNoMap != null || custRefSlNoMap.size() > 0)
		{
			custRefSlNoMap.clear();
		}
		for (Integer i=1;i<fileLines.size();i++)
        {
            String[] lineValues = new String[]{};
            lineValues = fileLines[i].split(',');
            
            String custRefNum = lineValues[custRefColIndex];
            String slNo = lineValues[slNoColIndex];
			slNo = slNo.trim();
            if (custRefNum != oldCustRefNo && oldCustRefNo != '')
            {
            	custRefSlNoMap.add(custRefSlNoString);
            	oldCustRefNo = '';
            	custRefSlNoString = '';
            }

        	if (oldCustRefNo == '')
        	{
        		oldCustRefNo = custRefNum; 
        	}
            if (custRefSlNoString == '')
            {
            	custRefSlNoString = custRefNum + ':' + slNo;
            }
            else
            {
            	custRefSlNoString = custRefSlNoString + ',' + slNo;
            }
        }
        if (custRefSlNoString != '')
        {
        	custRefSlNoMap.add(custRefSlNoString);
        }

		if (custRefSlNoMapForM2Submit != null || custRefSlNoMapForM2Submit.size() > 0)
		{
			custRefSlNoMapForM2Submit.clear();
		}

		for (String custRefSlNo : custRefSlNoMap)
		{
            Boolean validForM2 = true;
            String[] custRefSlNoValues = new String[]{};
            custRefSlNoValues = custRefSlNo.split(':');
            
            String custRefNum = custRefSlNoValues[0];
            
            Generation_Assets__c genAssetRec = genAssetMap.get(custRefNum);
            Facility_Configuration__c[] panelList = genAssetRec.Facility_Configurations__r;
            if (genAssetRec.Cash_Grant_Eligible__c == false)
            {
            	if (validationMsg != null)
            	{
            		validationMsg = validationMsg + 'Partner Reference # ' + custRefNum + ' : This facility is not participating in the SunRun-owned modules program.' + crlf;
            	}
            	else
            	{
					validationMsg = 'Partner Reference # ' + custRefNum + ' : This facility is not participating in the SunRun-owned modules program.' + crlf;
            	}
            	validForM2 = false;
            }
			if (panelList == null || panelList.size() <= 0)
			{
            	if (validationMsg != null)
            	{
            		validationMsg = validationMsg + 'Partner Reference # ' + custRefNum + ' : Facility Configuration (Panel Details) not found for the Generation Asset.' + crlf;
            	}
            	else
            	{
					validationMsg = 'Partner Reference # ' + custRefNum + ' : Facility Configuration (Panel Details) not found for the Generation Asset.' + crlf;
            	}
            	validForM2 = false;
			}
			
			Case caseRec = caseMap.get(custRefNum);
            if (caseRec == null)
            {
            	if (validationMsg != null)
            	{
            		validationMsg = validationMsg + 'Partner Reference # ' + custRefNum + ' : Please upload proofs for M2 before uploading serial numbers.' + crlf;
            	}
            	else
            	{
					validationMsg = 'Partner Reference # ' + custRefNum + ' : Please upload proofs for M2 before uploading serial numbers.' + crlf;
            	}
            	validForM2 = false;
            }			
			if (validForM2)
			{
				custRefSlNoMapForM2Submit.add(custRefSlNo);				
			}
		}

		return true;		               			
	}

    public Integer lookupInventory(List<String> listSerialNumbers)
    {
        Integer retVal = 0;
        
        SmartTurn_OccamService.OccamService smartTurnService = new SmartTurn_OccamService.OccamService();
        
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

		List<String> listSlno = new List<String>(); 
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
				        
			        	retVal = retVal + resultTotalRecordsCount;
			        }
			        else
			        {
			        	retVal = -1;
			        }
				}
				else
				{
					return listSerialNumbers.size();					
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
			       
		        	retVal = retVal + resultTotalRecordsCount;
		        }
		        else
		        {
		        	retVal = -1;
		        }
			}
			else
			{
				return 	listSerialNumbers.size();
			}
		}        
//		System.debug('\n\n*** retVal '  + retVal + '***\n\n');
        return retVal;
    }   
   
    public void submitSerialNumber(Generation_Assets__c selGenAssetRec, Case caseRec, List<String> listSlno, String slNo, List<Generation_Assets__c> assetsToUpdate, List<Case> casesToUpdate)
    {
		slNo = slNo.replaceAll(',', '\n');
		
		String custRefNum = selGenAssetRec.Cust_Ref_Num__c;
		         
		Facility_Configuration__c[] panelList = selGenAssetRec.Facility_Configurations__r;
		
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
    	
    	if (totalPanelQty != listSlno.size())
    	{
        	if (submitMsg != null)
        	{
        		submitMsg = submitMsg + 'Partner Reference # ' + custRefNum + ' : Serial Number count (' + listSlno.size() + ') does not match panel qty (' + totalPanelQty + ')' + crlf;
        	}
        	else
        	{
				submitMsg = 'Partner Reference # ' + custRefNum + ' : Serial Number count (' + listSlno.size() + ') does not match panel qty (' + totalPanelQty + ')' + crlf;
        	}
        	return;
    	}
    	
    	Integer recCount = lookupInventory(listSlno);
		
		if (recCount == -1)
		{
        	if (submitMsg != null)
        	{
        		submitMsg = submitMsg + 'Partner Reference # ' + custRefNum + ' : No response from SmartTurn when attempting to perform Inventory Lookup' + crlf;
        	}
        	else
        	{
				submitMsg = 'Partner Reference # ' + custRefNum + ' : No response from SmartTurn when attempting to perform Inventory Lookup' + crlf;
        	}
        	return;
		}    	    
		else if (recCount != listSlno.size())
		{
        	if (submitMsg != null)
        	{
        		submitMsg = submitMsg + 'Partner Reference # ' + custRefNum + ' : Number of serial numbers required (' + listSlno.size() + ') does not match number of valid serial numbers entered (' + recCount + '). Some of the entered serial numbers do not match our records for your panel inventory.' + crlf;
        	}
        	else
        	{
				submitMsg = 'Partner Reference # ' + custRefNum + ' : Number of serial numbers required (' + listSlno.size() + ') does not match number of valid serial numbers entered (' + recCount + '). Some of the entered serial numbers do not match our records for your panel inventory.' + crlf;
        	}
            selGenAssetRec.Panel_Serial_Number__c = slNo;
            selGenAssetRec.SmartTurn_M2_StatusCode__c = 'FAILURE';
            selGenAssetRec.SmartTurn_Message__c = 'Number of serial numbers required (' + listSlno.size() + ') does not match number of valid serial numbers entered (' + recCount + '). Some of the entered serial numbers do not match our records for your panel inventory.';
            assetsToUpdate.add(selGenAssetRec);
        	return;
		}    	    
		
        SmartTurn_OccamService.OccamService smartTurnService = new SmartTurn_OccamService.OccamService();
        
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
		        	if (submitMsg != null)
		        	{
		        		submitMsg = submitMsg + 'Partner Reference # ' + custRefNum + ' : Serial Numbers successfully submitted to SmartTurn.' + crlf;
		        	}
		        	else
		        	{
						submitMsg = 'Partner Reference # ' + custRefNum + ' : Serial Numbers successfully submitted to SmartTurn.' + crlf;
		        	}
				
		            selGenAssetRec.Panel_Serial_Number__c = slNo;
		            selGenAssetRec.SmartTurn_M2_StatusCode__c = 'SUCCESS';
		            selGenAssetRec.SmartTurn_Message__c = null;
		            
		            if (selGenAssetRec.M2_Status__c == 'Denied')
		            {
                		caseRec.Status = 'Request Approval';
                		caseRec.Denied_Comment__c = null;
                		caseRec.Denial_Reason__c = null;
                		casesToUpdate.add(caseRec);

                		selGenAssetRec.M2_Denied_Comments__c = null;
			            selGenAssetRec.M2_Proof_Upload_Date__c = date.today();
			            selGenAssetRec.M2_Status__c = 'Pending';
		            }

		            assetsToUpdate.add(selGenAssetRec);
	    			return ;
	            }
    	        else
        	    {
            	    String[] errorList = smartTurnSOSaveResponse[0].error;
		        	if (submitMsg != null)
		        	{
		        		submitMsg = submitMsg + 'Partner Reference # ' + custRefNum + ' : Error from SmartTurn : ' + errorList[0] + crlf;
		        	}
		        	else
		        	{
						submitMsg = 'Partner Reference # ' + custRefNum + ' : Error from SmartTurn : ' + errorList[0] + crlf;
		        	}
	        		selGenAssetRec.Panel_Serial_Number__c = slNo;
	                selGenAssetRec.SmartTurn_M2_StatusCode__c = 'FAILURE';
    	            selGenAssetRec.SmartTurn_Message__c = errorList[0];
		            assetsToUpdate.add(selGenAssetRec);
	    			return ;
            	}
        	}
        	else
        	{
	        	if (submitMsg != null)
	        	{
	        		submitMsg = submitMsg + 'Partner Reference # ' + custRefNum + ' : No response from SmartTurn when attempting to Submit the Serial Numbers.' + crlf;
	        	}
	        	else
	        	{
					submitMsg = 'Partner Reference # ' + custRefNum + ' : No response from SmartTurn when attempting to Submit the Serial Numbers.' + crlf;
	        	}
				selGenAssetRec.Panel_Serial_Number__c = slNo;
    	        selGenAssetRec.SmartTurn_M1_StatusCode__c = 'FAILURE';
        	    selGenAssetRec.SmartTurn_Message__c = 'No response from SmartTurn when attempting to Submit the Serial Numbers';
	            assetsToUpdate.add(selGenAssetRec);
    			return ;
        	}
		}
		else
		{
			return;
		}
    }

	public string getInvalidHeaderColumn(String headerLine)
	{
        String retVal = null;
        String[] headerLineValues = new String[]{};
        headerLineValues = headerLine.split(',');
		for (String headerLineValue : headerLineValues) 	
		{
			if (headerLineValue != 'Verengo Job #' && headerLineValue != 'Partner Reference #' &&
				headerLineValue != 'Module Part #' && headerLineValue != 'Module Serial #')
			{
				retVal = headerLineValue;
				break;
			}
		}
		return retVal;
	}

 	public integer getHeaderColumnIndex(String headerLine, String columnName)
 	{
 		integer retval = -1;
        String[] headerLineValues = new String[]{};
        headerLineValues = headerLine.split(',');
		Integer iCount = 0;
//		System.debug('\n\n*** columnName '  + columnName + '***\n\n');
		for (String headerLineValue : headerLineValues) 	
		{
//			System.debug('\n\n*** headerLineValue '  + headerLineValue + '***\n\n');
			if (headerLineValue == columnName)
			{
				retVal = iCount;
				break;
			}
			iCount++;
		}	
		return retVal;
 	}

	public void setErrorMsg()
    {
        ApexPages.Message msg = new ApexPages.Message(Apexpages.Severity.ERROR, errormsg);
        ApexPages.addMessage(msg);
    }
    
    
	public static testMethod void milestoneM2SlNoFileUploadTest()
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
        insert contactRec;

        Generation_Assets__c genAssetRec = new Generation_Assets__c();
        genAssetRec.Account_Name__c = accountRec.Id;
        genAssetRec.Customer_Contact__c = contactRec.Id;
        genAssetRec.Home_Address__c = 'Test Class';
        genAssetRec.City__c = 'Los Gatos';
        genAssetRec.Zip__c = '95032';
        genAssetRec.Asset_Status__c = 'Plans Approved, Awaiting NTP';
        genAssetRec.Facility_Design_Approved__c = date.today();
        genAssetRec.NTP_Granted__c = date.today();
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

        Generation_Assets__c selGenAssetRec = [Select Cust_Ref_Num__c From Generation_Assets__c Where Id = :genAssetRec.Id];

        testMilestoneM2SlNoFileUpload.fullPathFileName = 'temp.csv';
			
        Blob bodyBlob=null;
        testMilestoneM2SlNoFileUpload.fileBody = bodyBlob;

		testMilestoneM2SlNoFileUpload.uploadSlNo();
		
        String fileContent = '';
        bodyBlob=Blob.valueOf(fileContent);
        testMilestoneM2SlNoFileUpload.fileBody = bodyBlob;

        testMilestoneM2SlNoFileUpload.uploadSlNo();
        
        String headerLine = '\n';
        String lineValue = 'Test-1,' +  selGenAssetRec.Cust_Ref_Num__c + ',LG245S1C-G2,K21117290391' + '\n';
		fileContent = headerLine + lineValue;

        bodyBlob=Blob.valueOf(fileContent);
        testMilestoneM2SlNoFileUpload.fileBody = bodyBlob;

     	testMilestoneM2SlNoFileUpload.uploadSlNo();

        headerLine = 'Test Job #,Partner Reference #,Module Part #,Module Serial #' + '\n';
        lineValue = 'Test-1,' +  selGenAssetRec.Cust_Ref_Num__c + ',LG245S1C-G2,K21117290391' + '\n';
		fileContent = headerLine + lineValue;

        bodyBlob=Blob.valueOf(fileContent);
        testMilestoneM2SlNoFileUpload.fileBody = bodyBlob;

     	testMilestoneM2SlNoFileUpload.uploadSlNo();

        headerLine = 'Verengo Job #,Partner Reference #,Module Part #,Module Serial #' + '\n';
        lineValue = 'Test-1,,LG245S1C-G2,K21117290391' + '\n';
		fileContent = headerLine + lineValue;

        bodyBlob=Blob.valueOf(fileContent);
        testMilestoneM2SlNoFileUpload.fileBody = bodyBlob;

     	testMilestoneM2SlNoFileUpload.uploadSlNo();

        headerLine = 'Verengo Job #,Partner Reference #,Module Part #,Module Serial #' + '\n';
        lineValue = 'Test-1,' +  selGenAssetRec.Cust_Ref_Num__c + ',LG245S1C-G2,\r' + '\n';
		fileContent = headerLine + lineValue;

        bodyBlob=Blob.valueOf(fileContent);
        testMilestoneM2SlNoFileUpload.fileBody = bodyBlob;

     	testMilestoneM2SlNoFileUpload.uploadSlNo();

        headerLine = 'Verengo Job #,Partner Reference #,Module Part #,Module Serial #' + '\n';
        lineValue = 'Test-1,' +  selGenAssetRec.Cust_Ref_Num__c + 'ZZZ' +  ',LG245S1C-G2,K21117290391' + '\n';
		fileContent = headerLine + lineValue;

        bodyBlob=Blob.valueOf(fileContent);
        testMilestoneM2SlNoFileUpload.fileBody = bodyBlob;

     	testMilestoneM2SlNoFileUpload.uploadSlNo();

        headerLine = 'Verengo Job #,Partner Reference #,Module Part #,Module Serial #' + '\n';
        lineValue = 'Test-1,' +  selGenAssetRec.Cust_Ref_Num__c + ',LG245S1C-G2,K21117290391' + '\n';
		fileContent = headerLine + lineValue;

        bodyBlob=Blob.valueOf(fileContent);
        testMilestoneM2SlNoFileUpload.fileBody = bodyBlob;

     	testMilestoneM2SlNoFileUpload.uploadSlNo();
 

		genAssetRec.Cash_Grant_Eligible__c = true;
		update genAssetRec;

     	testMilestoneM2SlNoFileUpload.uploadSlNo();

		Facility_Configuration__c panelRec = new Facility_Configuration__c();
		panelRec.Generation_Asset__c = genAssetRec.Id;
		panelRec.Number_of_Panels__c = 1;
		panelRec.Panel_Type__c = 'LG245S1C-G2';
		insert panelRec;

     	testMilestoneM2SlNoFileUpload.uploadSlNo();
        
        RecordType mileStoneRecType = testMilestoneM2SlNoFileUpload.mileStoneRecType;
        
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
        insert currentCaseRec;

     	testMilestoneM2SlNoFileUpload.uploadSlNo();

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

        Generation_Assets__c selGenAssetRec2 = [Select Cust_Ref_Num__c From Generation_Assets__c Where Id = :genAssetRec.Id];

		Facility_Configuration__c panelRec2 = new Facility_Configuration__c();
		panelRec2.Generation_Asset__c = genAssetRec2.Id;
		panelRec2.Number_of_Panels__c = 1;
		panelRec2.Panel_Type__c = 'LG245S1C-G2';
		insert panelRec2;
		 
 
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
        insert currentCaseRec2;

        lineValue = lineValue + 'Test-1,' +  selGenAssetRec2.Cust_Ref_Num__c + ',LG245S1C-G2,K21117290391' + '\n';
		fileContent = headerLine + lineValue;

        bodyBlob=Blob.valueOf(fileContent);
        testMilestoneM2SlNoFileUpload.fileBody = bodyBlob;

     	testMilestoneM2SlNoFileUpload.uploadSlNo();
 
 		Test.stopTest();    	
    }
}