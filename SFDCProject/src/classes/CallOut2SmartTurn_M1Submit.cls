public with sharing class CallOut2SmartTurn_M1Submit {

    public final Case currentRecord;
    public Case caseRec {get;set;}
    public Generation_Assets__c assetRec {get;set;}
    public String errorPageDetails {get;set;}

    public CallOut2SmartTurn_M1Submit (ApexPages.StandardController stdController) 
    {
        this.currentRecord = (Case) stdController.getRecord();
        if (caseRec == null)
        {
            caseRec = [Select Id, RecordTypeId, Status, Generation_Asset__c, Milestone_Proof_Type__c, SmartTurn_M1_StatusCode__c, SmartTurn_Message__c  From Case Where Id = :currentRecord.Id];
        }
        
        if (assetRec == null && caseRec.Generation_Asset__c != null)
        {
            assetRec = [Select ID, Name, Cust_Ref_Num__c, Home_Address__c, City__c, State__c, Zip__c, Install_Partner__c, Cash_Grant_Eligible__c, 
            				SmartTurn_M1_StatusCode__c, SmartTurn_Message__c, Number_of_Sunrun_owned_Modules__c,
            				(Select Panel_Type__c, Number_of_Panels__c  From Facility_Configurations__r)
            				From Generation_Assets__c Where Id = :caseRec.Generation_Asset__c];
        }
        errorPageDetails = System.currentPageReference().getParameters().get('msg') ;
        if (errorPageDetails == null)
            errorPageDetails = '';
    }

    public PageReference submitM1()
    {
        String crlf = '\r\n';
        
		Facility_Configuration__c[] panelList = assetRec.Facility_Configurations__r;
		
//		if ((panelList == null || panelList.size() <= 0) || caseRec.Milestone_Proof_Type__c != 'M1 Proof' || 
//			caseRec.Status != 'M1 Proof Approved' || caseRec.SmartTurn_M1_StatusCode__c == 'SUCCESS' || assetRec.Cash_Grant_Eligible__c == false)
		if ((panelList == null || panelList.size() <= 0) || caseRec.Milestone_Proof_Type__c != 'M1 Proof' || 
			caseRec.Status != 'M1 Proof Approved' || assetRec.Cash_Grant_Eligible__c == false)
		{
			errorPageDetails += 'The following validations failed before Submitting M1 details to SmartTurn: ' + crlf  + crlf; 

			if (assetRec.Cash_Grant_Eligible__c == false)
			{
				errorPageDetails += 'Cash Grant Pre-Buy Eligible is NOT checked in the Generation Asset'  + crlf + crlf;
			}		
			if (panelList == null || panelList.size() <= 0)
			{
				errorPageDetails += 'Facility Configuration (Panel Details) not found for the Generation Asset'  + crlf + crlf;
			}		
			if (caseRec.SmartTurn_M1_StatusCode__c == 'SUCCESS')
			{
				errorPageDetails += 'M1 already Submitted to SmartTurn for this Generation Asset'  + crlf + crlf;
			}		
			if (caseRec.Milestone_Proof_Type__c != 'M1 Proof')
			{
				errorPageDetails += 'Only M1 Proofs can be submitted to SmartTurn using this option'  + crlf + crlf;
			}		
			if (caseRec.Status != 'M1 Proof Approved')
			{
				errorPageDetails += 'Case is not in M1 Proof Approved Status.'  + crlf;
			}		
		}

        if (errorPageDetails == '')
        {
	        SmartTurn_OccamService.OccamService smartTurnService = new SmartTurn_OccamService.OccamService();
	        smartTurnService.timeout_x = 60000;
	        
	        SmartTurn_OccamTypes.OccamPasswordCredential soInCredential = new SmartTurn_OccamTypes.OccamPasswordCredential();
	        soInCredential.UserId = Label.Sunrun_DSG_Email;
	        soInCredential.Password = Label.Sunrun_DSG_Password;
	
	        List<SmartTurn_SalesOrderTypes.SalesOrder> soList = new List<SmartTurn_SalesOrderTypes.SalesOrder>(); 
	        List<SmartTurn_SalesOrderTypes.SalesOrderItem> itemList = new List<SmartTurn_SalesOrderTypes.SalesOrderItem>();
	        
	        SmartTurn_FlexFieldTypes.CustomField[] custFieldList = new SmartTurn_FlexFieldTypes.CustomField[1];
	        SmartTurn_FlexFieldTypes.CustomFields custFields = new SmartTurn_FlexFieldTypes.CustomFields();
			SmartTurn_FlexFieldTypes.CustomField custField = new SmartTurn_FlexFieldTypes.CustomField();
			
			custField.name = 'SRH #';
			custField.textValue = assetRec.Name;
			custFieldList[0] = custField;
			
	        custFields.field = custFieldList;


	        SmartTurn_OccamTypes.Address shipTo = new SmartTurn_OccamTypes.Address(); 
	        
	        shipTo.addressLine1 =  assetRec.Home_Address__c;
	        shipTo.city = assetRec.City__c;
	        shipTo.state = assetRec.State__c;
	        shipTo.postalCode = assetRec.Zip__c;
	
	        SmartTurn_OccamTypes.Quantity itemQty= new SmartTurn_OccamTypes.Quantity();
	        itemQty.value = 1.00;
	        itemQty.unitAbbreviation = 'ea';
	
	        SmartTurn_SalesOrderTypes.SalesOrder soRec = new SmartTurn_SalesOrderTypes.SalesOrder();
	        soRec.externalNumber = assetRec.Name;
	        soRec.type_x = 'EXTERNAL';
	        soRec.date_x = date.today();
	        soRec.dateDue = date.today();
	        soRec.customerName = assetRec.Install_Partner__c;
	        soRec.shipToContact = assetRec.Cust_Ref_Num__c;
	        soRec.useShipToAsBillAddress = false;
	        soRec.ShipTo = shipTo;
	        soRec.priority = assetRec.Name;
//	        soRec.soCustomFields = custFields;
	        System.debug('\n\n*** panelList.size '  + panelList.size() + '***\n\n');
	        	       	        
            SmartTurn_SalesOrderTypes.SalesOrderItem soItem = new SmartTurn_SalesOrderTypes.SalesOrderItem();         	       	        
	        for (Facility_Configuration__c panelRec : panelList)
	        {
		        soItem.itemMasterId = panelRec.Panel_Type__c;
		        soItem.orderedQuantity = itemQty;

	        	Decimal panelQty = panelRec.Number_of_Panels__c;

	        	if (panelQty == null || panelQty <= 0)
	        	{
	        		panelQty = 1;
	        	}	        	
	        }
	        
                // BSKY-441: Added for Sunrun-owned Panels (and fixed for BSKY-513)
	            if(assetRec.Number_of_Sunrun_owned_Modules__c != null && assetRec.Number_of_Sunrun_owned_Modules__c > 0)
	            {
	        	   Integer iCount = 0;
	        	   for ( iCount=0; iCount < assetRec.Number_of_Sunrun_owned_Modules__c; iCount++ ) 
	        	   {
	        		  itemList.add(soItem);		
	        	   }
	        	}	        	        
	        
	        System.debug('\n\n*** itemList.size '  + itemList.size() + '***\n\n');
	
	        soRec.item = itemList;
	
	        soList.add(soRec);
	        
	        List<SmartTurn_OccamTypes.UploadResponse> smartTurnSOSaveResponse = null;
	        
	        if (!Test.isRunningTest())
        	{
		        smartTurnSOSaveResponse = smartTurnService.saveSalesOrder(soInCredential, soList);
        	}
	        if (smartTurnSOSaveResponse != null)
	        {
	            System.debug('\n\n*** smartTurnSOSaveResponse.status '  + smartTurnSOSaveResponse[0].status + '***\n\n');
	            
	            if (smartTurnSOSaveResponse[0].status == 'SUCCESS')
	            {
	                errorPageDetails = 'Successfully submitted M1 details to SmartTurn';
	                caseRec.SmartTurn_M1_StatusCode__c = 'SUCCESS';
	                caseRec.SmartTurn_Message__c = null;
	                assetRec.SmartTurn_M1_StatusCode__c = 'SUCCESS';
	                assetRec.SmartTurn_Message__c = null;
	                update caseRec;
	                update assetRec;
	            }
	            else
	            {
	                String[] errorList = smartTurnSOSaveResponse[0].error;
	                String errorCheck = 'A Sales Order with the external id "' + smartTurnSOSaveResponse[0].externalRefId + '" already exists and the Sales Order is not canceled.';
	                
	                if (errorList[0] == errorCheck)
					{
						List<SmartTurn_OccamTypes.UploadResponse> smartTurnOverWriteSOResponse = smartTurnService.overwriteSalesOrder(soInCredential, soList);
			    
			            if (smartTurnOverWriteSOResponse[0].status == 'SUCCESS')
			            {
			                errorPageDetails = 'Successfully submitted M1 details to SmartTurn';
			                caseRec.SmartTurn_M1_StatusCode__c = 'SUCCESS';
			                caseRec.SmartTurn_Message__c = null;
			                assetRec.SmartTurn_M1_StatusCode__c = 'SUCCESS';
			                assetRec.SmartTurn_Message__c = null;
			                update caseRec;
			                update assetRec;
			            }
						else
						{
							String[] errorList2 = smartTurnOverWriteSOResponse[0].error;
			                errorPageDetails = 'Error from SmartTurn : ' + errorList2[0];
			                caseRec.SmartTurn_M1_StatusCode__c = 'FAILURE';
			                caseRec.SmartTurn_Message__c = errorList2[0];
			                assetRec.SmartTurn_M1_StatusCode__c = 'FAILURE';
			                assetRec.SmartTurn_Message__c = errorList2[0];
			                update caseRec;
			                update assetRec;
						}
					}
	                else
	                {
		                errorPageDetails = 'Error from SmartTurn : ' + errorList[0];
		                caseRec.SmartTurn_M1_StatusCode__c = 'FAILURE';
		                caseRec.SmartTurn_Message__c = errorList[0];
		                assetRec.SmartTurn_M1_StatusCode__c = 'FAILURE';
		                assetRec.SmartTurn_Message__c = errorList[0];
		                update caseRec;
		                update assetRec;
	                }	                
	            }
	        }
	        else
	        {
	            caseRec.SmartTurn_M1_StatusCode__c = 'FAILURE';
	            caseRec.SmartTurn_Message__c = 'No response from SmartTurn';
	            
	            assetRec.SmartTurn_M1_StatusCode__c = 'FAILURE';
	            assetRec.SmartTurn_Message__c = 'No response from SmartTurn';
	            
	            update caseRec;
	            update assetRec;
	        }
        	
        }
        PageReference retPage = Page.CallOut2SmartTurn_Submit_M1_Conf;
        retPage.setRedirect(true);
        retPage.getParameters().put('id',caseRec.id);
        retPage.getParameters().put('msg', errorPageDetails);
        return retPage;
    }
    
   static testmethod void testCallOut2SmartTurn_M1Submit(){
    //
    Account a = new Account(name='Test Source',Zip_6__c='12345123456');
    insert a;
    //
    Opportunity Opp = new Opportunity();
    Opp.Name = 'TestOppty';
    Opp.StageName = 'Qualified';
    Opp.CloseDate = Date.Today().addDays(18);    
    Opp.AccountId = a.Id;
    insert Opp; 
    //Contact
    List<Contact> listCon = new List<Contact>();
    Contact con = new Contact();
    con.AccountId = a.Id;
    con.LastName = 'Smith';
    con.FirstName = 'Smitty';
    con.Email = 'Smith@smitty.com.xyz';
    insert con;
    //
    List<Generation_Assets__c> listGA = new List<Generation_Assets__c>();
    Generation_Assets__c ga = new Generation_Assets__c();
    ga.Opportunity_Name__c = Opp.Id;
    ga.Name = '99999';
    ga.Home_Address__c = '123 Main St';
    ga.City__c = 'Sunrunville';
    ga.Zip__c = '12345';
    ga.Customer_Contact__c = con.Id;
    ga.Account_Name__c = a.Id;
    ga.Welcome_Call__c = Date.Today();
    ga.SR_Signoff__c = Date.Today().addDays(-19);   
    ga.Home_Address__c = '160 Happy Path';
    ga.City__c = 'San Clownita';
    ga.State__c = 'CA';
    ga.Zip__c = '99999';
    ga.Install_Partner__c = 'Verengo';
    ga.Cash_Grant_Eligible__c = true;
    ga.SmartTurn_M1_StatusCode__c = '';
    ga.SmartTurn_Message__c = '';
    ga.Number_of_Sunrun_owned_Modules__c = 10;
    ga.System_Size_DC__c = 2.45;
    listGA.add(ga);
    Generation_Assets__c ga2 = new Generation_Assets__c();
    ga2.Opportunity_Name__c = Opp.Id;
    ga2.Name = '99999';
    ga2.Home_Address__c = '123 Main St';
    ga2.City__c = 'Sunrunville';
    ga2.Zip__c = '12345';
    ga2.Customer_Contact__c = con.Id;
    ga2.Account_Name__c = a.Id;
    ga2.Welcome_Call__c = Date.Today();
    ga2.SR_Signoff__c = Date.Today().addDays(-19);   
    ga2.Home_Address__c = '160 Happy Path';
    ga2.City__c = 'San Clownita';
    ga2.State__c = 'CA';
    ga2.Zip__c = '99999';
    ga2.Install_Partner__c = 'Verengo';
    ga2.Cash_Grant_Eligible__c = false;
    ga2.SmartTurn_M1_StatusCode__c = '';
    ga2.SmartTurn_Message__c = '';
    ga2.Number_of_Sunrun_owned_Modules__c = 0;
    ga2.System_Size_DC__c = 0.0;
    listGA.add(ga2);    
    insert listGA;      
    //
    Facility_Configuration__c fc = new Facility_Configuration__c();
    fc.Generation_Asset__c = ga.id;
    fc.Panel_Type__c = 'LG245M1C-G2';
    fc.Number_of_Panels__c = 10;
    insert fc;
    //
    RecordType rt = [select id from RecordType where sObjectType = 'Case' and Name = 'Milestone Proof' LIMIT 1];
    //
    List<Case> listCase = new List<Case>();
    Case c = new Case();
    c.Status = 'M1 Proof Approved';
    c.Generation_Asset__c = ga.id;
    c.Milestone_Proof_Type__c = 'M1 Proof';
    c.SmartTurn_M1_StatusCode__c = '';
    c.SmartTurn_Message__c = '';
    c.RecordTypeId = rt.id;
    listCase.add(c);
    Case c2 = new Case();
    c2.Status = 'M2 Meter Test Approved';
    c2.Generation_Asset__c = ga2.id;
    c2.Milestone_Proof_Type__c = 'M2 Proof';
    c2.SmartTurn_M1_StatusCode__c = '';
    c2.SmartTurn_Message__c = '';
    c2.RecordTypeId = rt.id;
    listCase.add(c2);    
    //
    insert listCase;
    //
    ApexPages.StandardController sc = new ApexPages.StandardController(c);
    CallOut2SmartTurn_M1Submit CO2STM1S = new CallOut2SmartTurn_M1Submit(sc);
    //
    PageReference pr = CO2STM1S.submitM1();
    //
    ApexPages.StandardController sc2 = new ApexPages.StandardController(c2);
    CallOut2SmartTurn_M1Submit CO2STM1S2 = new CallOut2SmartTurn_M1Submit(sc2);
    //
    PageReference pr2 = CO2STM1S2.submitM1();
    //
   }    
}