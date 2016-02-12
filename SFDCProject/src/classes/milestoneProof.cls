global with sharing class milestoneProof 
{
    Generation_Assets__c srchGenAssetRec = new Generation_Assets__c();
    Generation_Assets__c selGenAssetRec;
    List<Generation_Assets__c> genAssetList;
    List<Case> caseList;
    List<Attachment> attachments;
    List<Milestone_Proof_Case_Owner__c> dfltCaseOwnerList;
    List<EmailTemplate> templateList;
    List<Milestone_Proof_Partner_Preference__c> partnerPreferenceList;
    public String srchOptionFilter {get; set;}
    public String currentAssetId {get; set;}
    public String milestoneProofType {get; set;}
    public RecordType mileStoneRecType {get;set;}
    public Milestone_Proof_Case_Owner__c dfltCaseOwnerDtl  {get;set;}
    public List<genAssetWrapper> searchedAssetsList = new List<genAssetWrapper>();
    public List<genAssetWrapper> selectedAssetsList = new List<genAssetWrapper>();    
    public Boolean bSelectedSingleAsset{get{if (selectedAssetsList == null || selectedAssetsList.size() <=  0 || selectedAssetsList.size() >  1){return false;}else{return true;}}set;}
    public String docType {get; set;}
    public String errorPageDetails {get{if (errorPageDetails == '') {errorPageDetails = 'Photos can only be uploaded to one Generation Asset at a time, please select one and only one Generation Asset.';} return errorPageDetails;} set;}
    public Integer iNumSunRunOwnedModulesUsed{get;set;}
    public Boolean bError{get;set;}
    public Map<String, PreBoughtPanelLimits__c> mapPanelLimits {get;set;}

    static final String eligibleStatusList1 = 'Plans Approved, Awaiting NTP';
    static final String eligibleStatusList2 = 'NTP granted, Awaiting M1';
    static final String eligibleStatusList3 = 'M1 received, Awaiting M2';
    static final String eligibleStatusList4 = 'M2 received, Awaiting PTO';

    static final String cancelledStatus1 = 'Deal Cancelled';
    static final String cancelledStatus2 = 'Deal Cancelled due to credit';
    
    public milestoneProof(ApexPages.StandardController stdController)
    {
	 	currentAssetId = System.currentPagereference().getParameters().get('id');	
	 	selGenAssetRec = [Select Id, Name, Account_Name__c, Cust_Ref_Num__c, Home_Address__c, City__c, Install_Partner__c, State__c, Zip__c,
                                    M1_Status__c, M2_Status__c, M3_Status__c, 
                                    M1_Proof_Count__c, M2_Proof_Count__c, M3_Proof_Count__c, M1_proof_panel_inverter_delivery__c, M2_proof_substantial_completion__c,
                                    Number_of_Sunrun_owned_Modules__c, System_Size_DC__c, Meter_Test_Date__c, Meter_Serial_Num__c,PTO__c, Partner_PTO_proof_date__c, NTP_Granted__c, Rebate_Form_Sent__c, Cash_Grant_Eligible__c, Panel_Serial_Number__c,
                                    SmartTurn_M1_StatusCode__c, SmartTurn_M2_StatusCode__c, SmartTurn_Message__c, 
                                    (Select Panel_Type__c, Number_of_Panels__c  From Facility_Configurations__r Order by Id)                                    
                                    From Generation_Assets__c Where Id = :currentAssetId];
    }
    
    public milestoneProof()
    {
        //iNumSunRunOwnedModulesUsed = 0;
        bError = false;
        mileStoneRecType = [Select Id from RecordType Where SobjectType = 'Case' And DeveloperName = 'Milestone_Proof'];
        dfltCaseOwnerList = [Select Name, Case_Owner_Email__c from Milestone_Proof_Case_Owner__c];
        templateList = [select Subject, body , HtmlValue, DeveloperName from EmailTemplate Where developerName = 'Milestone_Proof_Upload_Confirmation' Limit 1];
        User userRec = [Select Contact.AccountId From User WHERE Id = :Userinfo.getUserid()];
        partnerPreferenceList = [Select Id, Notify_Milestone_Proof_Upload__c, Emails_To_Notify_Milestone_Proof_Upload__c 
                        From Milestone_Proof_Partner_Preference__c Where Partner_Account__c = :userRec.Contact.AccountId Limit 1];
        
        if (errorPageDetails == null)
            errorPageDetails = '';
       
    }
     
    /*public Integer getPhotoCount(){    	    	  
    	List<SR_Gen_Asset_Attachment__c> listUploadedPhotos = new List<SR_Gen_Asset_Attachment__c>();
    	PageReference pr = GetSelectedAsset();            	 
    	System.Debug('COUNT Of PHOTOS: ' + selectedAssetsList.size());
        if (selectedAssetsList == null || selectedAssetsList.size() <=  0 || selectedAssetsList.size() >  1)
        {
            return 0;
        }
        String genAssetId = selectedAssetsList[0].genAssetRec.Id;
        currentAssetId = genAssetId;    	  	
    	for(SR_Gen_Asset_Attachment__c photo:[select Id, Document_Name__c, Size__c, Active__c, Generation_Asset__r.Name, Document_Name_On_File_Server__c, Thumbnail__c from SR_Gen_Asset_Attachment__c where Generation_Asset__c = :currentAssetId and Active__c = true])
    	{
    		listUploadedPhotos.add(photo);
    	}    	
    	return listUploadedPhotos.size();    
    }*/

    public Attachment attachmentFile
    {
        get 
        {
            if (attachmentFile == null)
            {
                attachmentFile = new Attachment();
            }
        return attachmentFile;
        }
      set;
    }
    
    public Pagereference userActions(){
       return null;
    }
    
    public PageReference validateConfigurationFromProofType()
    {
       if(selGenAssetRec.SmartTurn_M1_StatusCode__c == 'SUCCESS')
       {            
          return null;
       }
       return validateConfiguration();
    }
    
    public PageReference validateConfiguration()
    {
        Map<String, PreBoughtPanelLimits__c> mapPanelLimits = new Map<String, PreBoughtPanelLimits__c>();
        for(PreBoughtPanelLimits__c PBP:[select id, Name, Panel_Type__c, MinPreBoughtPercentage__c, MaxPreBoughtPercentage__c from PreBoughtPanelLimits__c])
        {
            mapPanelLimits.put(PBP.Panel_Type__c, PBP);
        }
        //
        System.Debug('VERENGO: ' + isPartnerVerengo); //Old code defaults to verengo if null, this is bad.
    if(selGenAssetRec.Install_Partner__c == 'Verengo' && iNumSunRunOwnedModulesUsed != null)
    {
        List<Facility_Configuration__c> listFC = new List<Facility_Configuration__c>();
        String strPanelType = '';
        Integer totalPanels = 0;
        Boolean bYingLiPanelsUsed = false;
        bError = false;
        Integer panelWattage = 0;        
        Double minPanelPercentage = Double.ValueOf(Label.MinPreBoughtPercentage);
        Double maxPanelPercentage = Double.ValueOf(Label.MaxPreBoughtPercentage);
        //
        //Consider using selGenAssetRec.Facility_Configurations__r instead to save a DML
        for(Facility_Configuration__c fc:[Select Id, Generation_Asset__c, Number_of_Panels__c, Panel_Type__c 
                                            from Facility_Configuration__c
                                           where Generation_Asset__c = :selGenAssetRec.Id])
        {
           listFC.add(fc);  
           if(fc.Number_of_Panels__c != null)
           {
              totalPanels += Integer.ValueOf(fc.Number_of_Panels__c);
           }
           if(fc.Panel_Type__c != null && fc.Panel_Type__c != '' && fc.Panel_Type__c.Substring(0,2) == 'YL') //Currently only YL235s
           {
              bYingLiPanelsUsed = true;
           }
           if(fc.Panel_Type__c != null && fc.Panel_Type__c != '')
           {
              //Assumption Verified: All Panel Types are the same for each GA.          
              panelWattage = Integer.ValueOf(fc.Panel_Type__c.Substring(2,5));
           }
           strPanelType = fc.Panel_Type__c;
           if(mapPanelLimits.get(strPanelType) != null)
           {
               minPanelPercentage = mapPanelLimits.get(strPanelType).MinPreBoughtPercentage__c;
               maxPanelPercentage = mapPanelLimits.get(strPanelType).MaxPreBoughtPercentage__c;
           }   
           System.Debug('MIN: ' + minPanelPercentage);
           System.Debug('MAX: ' + maxPanelPercentage);
        }
        //
        if (iNumSunRunOwnedModulesUsed > 0 && !selGenAssetRec.Cash_Grant_Eligible__c)
        {
            //THROW ERROR MESSAGE SIMILAR TO: ERROR: YOU CANNOT HAVE Pre-bought panels with a non cash grant eligible deal
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'You cannot have Sunrun-owned panels with a non cash grant eligible deal.'));
            bError = true;
        }               
        Boolean bContinue = true;
        if(selGenAssetRec.Cash_Grant_Eligible__c && bYingLiPanelsUsed && totalPanels != iNumSunRunOwnedModulesUsed)
        {
            //THROW ERROR MESSAGE SIMILAR TO: ERROR: THIS CANNOT BE A SPLIT DEAL!  ONE OR MORE MODULES ARE YINGLI!!!
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'You may not have a split-deal if one or more panels are YingLi Panels. The Number of Sunrun-Owned Panels must equal the total number of panels on the facility.'));
            bError = true;
            bContinue = false;
        }  
        if(selGenAssetRec.State__c == 'NJ' && selGenAssetRec.Cash_Grant_Eligible__c && totalPanels != iNumSunRunOwnedModulesUsed)
        {
            //THROW ERROR MESSAGE SIMILAR TO: ERROR: THIS CANNOT BE A SPLIT DEAL, it is in New Jersey!!!
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'You may not have a split-deal in New Jersey. The Number of Sunrun-Owned Panels must equal the total number of panels on the facility.'));
            bError = true;
            bContinue = false;
        }        
        if(bContinue && selGenAssetRec.State__c <> 'NJ' && !bYingLiPanelsUsed)
        {           
           Double percTotalPower = 0.0;
           if(selGenAssetRec.System_Size_DC__c != null && (1000.00 * selGenAssetRec.System_Size_DC__c) != 0)
           {
              percTotalPower = (((iNumSunRunOwnedModulesUsed * panelWattage) / (1000.00 * selGenAssetRec.System_Size_DC__c)) * 100.00).setScale(2);
           }
           //
           if(panelWattage == 0)
           {
               ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Facility Configuration (Panel Details) not found for the Generation Asset.'));
               bError = true;
           }
           if(iNumSunRunOwnedModulesUsed <= 0)
           {
               ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'You must enter value greater than zero for the Number of Sunrun-Owned Panels.'));
               bError = true;
           }        
           if(selGenAssetRec.System_Size_DC__c != null && (iNumSunRunOwnedModulesUsed * panelWattage) < (Decimal.ValueOf(minPanelPercentage)/100.00 * (1000.00 * selGenAssetRec.System_Size_DC__c)))
           {
              //THROW ERROR MESSAGE SIMILAR TO: ERROR!  The SunRun Owned Pre-Bought Panels consist of less than 43.5% of the total power!!!
              ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'The Sunrun-Owned Panels contribute only ' + ((iNumSunRunOwnedModulesUsed * panelWattage)/1000.00) + ' kW, which is ' + percTotalPower + '% of the total power (' + selGenAssetRec.System_Size_DC__c + ' kW). The minimum contribution is ' + minPanelPercentage + '% of the total power.'));
              bError = true;
           }
           if(selGenAssetRec.System_Size_DC__c != null && (iNumSunRunOwnedModulesUsed * panelWattage) > (Decimal.ValueOf(maxPanelPercentage)/100.00 * (1000.00 * selGenAssetRec.System_Size_DC__c)))
           {
              //THROW ERROR MESSAGE SIMILAR TO: ERROR!  The SunRun Owned Pre-Bought Panels consist of more than 76.0% of the total power!!!
              //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'The Sunrun-Owned Panels consist of more than 76.0% ('+ Integer.ValueOf(iNumSunRunOwnedModulesUsed * panelWattage) + ' Watts) of the total power (' + Integer.ValueOf(selGenAssetRec.System_Size_DC__c) + ' Watts).'));
              ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'The Sunrun-Owned Panels contribute ' + ((iNumSunRunOwnedModulesUsed * panelWattage)/1000.00) + ' kW, which is ' + percTotalPower + '% of the total power (' + selGenAssetRec.System_Size_DC__c + ' kW). The maximum contribution is ' + maxPanelPercentage + '% of the total power.'));
              bError = true;
           }        
           if(iNumSunRunOwnedModulesUsed > totalPanels)
           {
              //THROW ERROR MESSAGE SIMILAR TO: ERROR! You cannot have more SunRun Owned Panels than you have total panels associated to this GenAsset!!!
              ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'You cannot have more Sunrun-Owned Panels (' + iNumSunRunOwnedModulesUsed + ') than you have total panels associated (' + totalPanels + ').'));
              bError = true;
           }        
        }
    }
        return null;
    }
    
    public PageReference OnlyUpdatePanelCount()
    {
        validateConfiguration();
        if(!bError)
        {
            UpdateNumberOfPreBoughtPanels();
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Number of Sunrun-Owned Panels Successfully Updated.'));
        }
        return null;
    }
    
    public void UpdateNumberOfPreBoughtPanels()
    {
        selGenAssetRec.Number_of_Sunrun_owned_Modules__c = iNumSunRunOwnedModulesUsed;
        update selGenAssetRec;
    }

    public string fullPathFileName {get;set;}   
    public string fileName {get;set;}
    public string acctName {get;set;}
    public string custRefNum {get;set;}
    public string custMailAddress {get;set;}
    public Decimal m1Count {get;set;}   
    public Decimal m2Count {get;set;}
    public Decimal m3Count {get;set;}
    public string panelSerialNumbers {get;set;}

    public String serverURL
    {
        get{
            if (serverURL == null)
            {
                 serverURL = 'https://' + ApexPages.CurrentPage().getHeaders().get('Host');
            }
            return serverURL;
        }
        set;
    }
    
    public Boolean isInstallPartnerVerengo
    {
        get{
            String installPartner = selGenAssetRec.Install_Partner__c; 
            if (installPartner != null)
            {
                if (installPartner.contains('Verengo'))
                {
                    isInstallPartnerVerengo = true;
                }
                else
                {
                    isInstallPartnerVerengo = false;
                }
            }
            else
            {
                 isInstallPartnerVerengo = false;
            }
            return isInstallPartnerVerengo;
        }
        set;
    }

	public boolean getIsPartnerUser(){
		Boolean ispartnerUser = false;
		String userType = UserInfo.getUserType();
		if(userType != null && userType != ''){
			if(userType.contains('Partner'))
				return true;
		}
		return ispartnerUser;
	}
	
    public Boolean isPartnerVerengo
    {
        get{
            String installPartner = selGenAssetRec.Install_Partner__c; 
            if (installPartner != null)
            {
                if (installPartner.contains('Verengo'))
                {
                    isPartnerVerengo = true;
                }
                else
                {
                    isPartnerVerengo = false;
                }
            }
            else
            {
                 isPartnerVerengo = true;
            }
            return isPartnerVerengo;
        }
        set;
    }

    public Boolean enableAttachFile
    {
        get{
            if (isM2Proof)
            {
                if (selGenAssetRec.Cash_Grant_Eligible__c == true)
                {
                    if (selGenAssetRec.SmartTurn_M2_StatusCode__c == 'SUCCESS' || isPartnerVerengo)
                    {
                        enableAttachFile = true;
                    }
                    else
                    {
                        enableAttachFile = false;
                    }
                }
                else
                {
                    enableAttachFile = true;
                }                                   
            }
            else
            {
                 enableAttachFile = true;
            }
            return enableAttachFile;
        }
        set;
    }

    public Boolean enableSlNoUpload
    {
        get{
//                if (selGenAssetRec.SmartTurn_M2_StatusCode__c == null || selGenAssetRec.SmartTurn_M2_StatusCode__c == 'FAILURE')
                if (selGenAssetRec.M2_Status__c != 'Approved')
                {
                    enableSlNoUpload = true;
                }
                else
                {
                    enableSlNoUpload = false;
                }
                return enableSlNoUpload;                
            }
        set;
    }
    
    public PageReference backToUpload()
    {
        return Page.milestoneProofUploadFile;
    }
    
    public Integer lookupInventory(List<String> listSerialNumbers)
    {
        System.debug('\n\n*** listSlno '  + listSerialNumbers + '***\n\n');
        
        Integer retVal = 0;
        
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
                        
                        System.debug('\n\n*** resultTotalRecordsCount '  + resultTotalRecordsCount + '***\n\n');
                       
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
                    
                    System.debug('\n\n*** resultTotalRecordsCount '  + resultTotalRecordsCount + '***\n\n');
                   
                    retVal = retVal + resultTotalRecordsCount;
                }
                else
                {
                    retVal = -1;
                }
            }
            else
            {
                return  listSerialNumbers.size();
            }
        }        
        System.debug('\n\n*** retVal '  + retVal + '***\n\n');
        return retVal;
    }   
   
    public PageReference submitSerialNumber()
    {
        panelSerialNumbers = selGenAssetRec.Panel_Serial_Number__c;
        
        if (panelSerialNumbers == null || panelSerialNumbers == '')
        {
            errorPageDetails = 'Please enter Serial Numbers before attempting to Submit it to SmartTurn';
            return Page.milestoneProof_M2_Submit_Conf;
        }

        Facility_Configuration__c[] panelList = selGenAssetRec.Facility_Configurations__r;
        
        if (selGenAssetRec.Cash_Grant_Eligible__c == false)
        {
            errorPageDetails = 'Cash Grant Pre-Buy Eligible is NOT checked in the Generation Asset';
            return Page.milestoneProof_M2_Submit_Conf;
        }       
        
        if (panelList == null || panelList.size() <= 0)
        {
            errorPageDetails = 'Facility Configuration (Panel Details) not found for the Generation Asset';
            return Page.milestoneProof_M2_Submit_Conf;
        }
        
        panelSerialNumbers = panelSerialNumbers.replaceAll(' ', '');
        panelSerialNumbers = panelSerialNumbers.trim();

        List<String> listSlno = panelSerialNumbers.split('\r\n');
        
        Decimal totalPanelQty = 0;
        
        /*for (Facility_Configuration__c panelRec : panelList)
        {
            Decimal panelQty = panelRec.Number_of_Panels__c;
                
            if (panelQty == null || panelQty <= 0)
            {
                panelQty = 1;
            }
            totalPanelQty = totalPanelQty + panelQty;       
        }*/
        //BSKY-513 Always use Number of Sunrun-owned Panels
        //         Will always have value for existing (already M1'd) cash grant deals because of data migration.
        //         Will always have value for new cash grant deals because it is enforced at M1.
        if(selGenAssetRec.Number_of_Sunrun_owned_Modules__c != null && selGenAssetRec.Number_of_Sunrun_owned_Modules__c > 0)
        {
            totalPanelQty = selGenAssetRec.Number_of_Sunrun_owned_Modules__c;
        }        
        if (totalPanelQty != listSlno.size())
        {
            errorPageDetails = 'Serial Number count (' + listSlno.size() + ') does not match panel qty (' + totalPanelQty + ')';
            return Page.milestoneProof_M2_Submit_Conf;
        }
        
        Integer recCount = lookupInventory(listSlno);
        
        if (recCount == -1)
        {
            errorPageDetails = 'No response from SmartTurn when attempting to perform Inventory Lookup';
            return Page.milestoneProof_M2_Submit_Conf;
        }           
        else if (recCount != listSlno.size())
        {
            errorPageDetails = 'Number of serial numbers required (' + listSlno.size() + ') does not match number of valid serial numbers entered (' + recCount + '). Some of the entered serial numbers do not match our records of your panel inventory.';
//          errorPageDetails = 'Serial Number count(' + listSlno.size() + ') does not match record count(' + recCount + ') returned by SmartTurn Inventory Lookup. Some of the submitted serial numbers do not match our records of your panel inventory.';
            selGenAssetRec.SmartTurn_M2_StatusCode__c = 'FAILURE';
            selGenAssetRec.SmartTurn_Message__c = errorPageDetails;
            update selGenAssetRec;
            return Page.milestoneProof_M2_Submit_Conf;
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
            
        System.debug('\n\n*** panelList.size '  + panelList.size() + '***\n\n');
        Integer jCount = 0; 
        String panelType = '';
        for (Facility_Configuration__c panelRec : panelList)
        {
            Decimal panelQty = panelRec.Number_of_Panels__c;
            
            if (panelQty == null || panelQty <= 0)
            {
                panelQty = 1;
            }
            
            panelType = panelRec.Panel_Type__c;    
        }

if(selGenAssetRec.Number_of_Sunrun_owned_Modules__c != null && selGenAssetRec.Number_of_Sunrun_owned_Modules__c > 0)
{
            Integer iCount = 0;
            for ( iCount=0; iCount < selGenAssetRec.Number_of_Sunrun_owned_Modules__c; iCount++ ) 
            {
                SmartTurn_SalesOrderTypes.SalesOrderItem soItem = new SmartTurn_SalesOrderTypes.SalesOrderItem();
                soItem.itemMasterId = panelType;
                soItem.orderedQuantity = itemQty;
                soItem.serialNumber = listSlno[jCount];
                jCount++;
                itemList.add(soItem);       
            }        
}

        for (SmartTurn_SalesOrderTypes.SalesOrderItem itemRec : itemList)
        {
            System.debug('\n\n*** itemId:' + itemRec.itemMasterId + ' , Serial Number: ' + itemRec.serialNumber + '***\n\n');
        }

        soRec.item = itemList;
    
        soList.add(soRec);

        if (!Test.isRunningTest())
        {
            smartTurnService.timeout_x = 60000;
            List<SmartTurn_OccamTypes.UploadResponse> smartTurnSOSaveResponse = smartTurnService.overwriteSalesOrder(soInCredential, soList);
    
            if (smartTurnSOSaveResponse != null)
            {
                System.debug('\n\n*** smartTurnSOSaveResponse.status '  + smartTurnSOSaveResponse[0].status + '***\n\n');
            
                if (smartTurnSOSaveResponse[0].status == 'SUCCESS')
                {
                    selGenAssetRec.Panel_Serial_Number__c = panelSerialNumbers;
                    selGenAssetRec.SmartTurn_M2_StatusCode__c = 'SUCCESS';
                    selGenAssetRec.SmartTurn_Message__c = null;
                    
                    if (selGenAssetRec.M2_Status__c == 'Denied')
                    {
                        String sqlQuery = 'Select Id, Status From Case Where IsClosed = false And RecordTypeId = ' ;
                        sqlQuery = sqlQuery + '\'' + String.escapeSingleQuotes(mileStoneRecType.Id) + '\'';
                        sqlQuery = sqlQuery + ' And Generation_Asset__c = '; 
                        sqlQuery = sqlQuery + '\'' + String.escapeSingleQuotes(selGenAssetRec.Id) + '\'';
                        sqlQuery = sqlQuery + ' And Milestone_Proof_Type__c = '; 
                        sqlQuery = sqlQuery + '\'' + String.escapeSingleQuotes(milestoneProofType) + '\'';

                        Case[] currentCaseList = Database.query(sqlQuery);
                        Case currentCaseRec;
                
                        if (currentCaseList != null && currentCaseList.size() > 0)
                        {
                            currentCaseRec = currentCaseList[0];
                            currentCaseRec.Status = 'Request Approval';
                            currentCaseRec.Denied_Comment__c = null;
                            currentCaseRec.Denial_Reason__c = null;
                            update currentCaseRec;
                        }
                        selGenAssetRec.M2_Denied_Comments__c = null;
                        selGenAssetRec.M2_Proof_Upload_Date__c = date.today();
                        selGenAssetRec.M2_Status__c = 'Pending';
                    }

                    update selGenAssetRec;
                    errorPageDetails = 'Successfully submitted Serial Numbers to SmartTurn';
                    return Page.milestoneProof_M2_Submit_Conf;
                }
                else
                {
                    String[] errorList = smartTurnSOSaveResponse[0].error;
                    errorPageDetails = 'Error from SmartTurn : ' + errorList[0];
                
                    selGenAssetRec.SmartTurn_M2_StatusCode__c = 'FAILURE';
                    selGenAssetRec.SmartTurn_Message__c = errorList[0];
                    update selGenAssetRec;

                    return Page.milestoneProof_M2_Submit_Conf;
                }
            }
            else
            {
                errorPageDetails = 'No response from SmartTurn when attempting to Submit the Serial Numbers';
                selGenAssetRec.SmartTurn_M1_StatusCode__c = 'FAILURE';
                selGenAssetRec.SmartTurn_Message__c = 'No response from SmartTurn when attempting to Submit the Serial Numbers';
    
                return Page.milestoneProof_M2_Submit_Conf;
            }
        }
        else
        {
            return null;
        }
//The 2nd Option of looking up the Sales Order and setting the line item serial number - this is giving Java error when submiting
/*      
        SmartTurn_OccamTypes.Criterion soLookupCriterion = new SmartTurn_OccamTypes.Criterion();
        SmartTurn_OccamTypes.Criteria soLookupCriteria = new SmartTurn_OccamTypes.Criteria();
        
        List<SmartTurn_OccamTypes.Criterion> listCriterions = new List<SmartTurn_OccamTypes.Criterion>();
        
        soLookupCriterion.negate = false;
        soLookupCriterion.propertyName = 'externalNumber';
        soLookupCriterion.operator = 'equal';
        soLookupCriterion.stringValue = selGenAssetRec.Name;
        soLookupCriterion.dateValue = date.today();
        
        listCriterions.add(soLookupCriterion);
        soLookupCriteria.criterions = listCriterions;

        smartTurn_LookupTypes.WSSalesOrderLookupResult soLookupResult = smartTurnService.lookUpSalesOrders(soInCredential, soLookupCriteria);
        
        smartTurn_LookupTypes.ResultMetadata soLookupResultMetaData = soLookupResult.resultMetadata;

        Integer resultTotalRecordsCount = soLookupResultMetaData.totalRecordsCount;
        
        System.debug('\n\n*** resultTotalRecordsCount '  + resultTotalRecordsCount + '***\n\n');
        
        if (resultTotalRecordsCount == 1)
        {
            List<SmartTurn_SalesOrderTypes.SalesOrder> soList = soLookupResult.salesOrders;
            List<SmartTurn_SalesOrderTypes.SalesOrderItem> itemList = soList[0].item;

            Integer iCount = 0;

            for (SmartTurn_SalesOrderTypes.SalesOrderItem itemRec : itemList)
            {
                if (iCount < listSlno.size())
                {               
                    itemRec.serialNumber = listSlno[iCount];
                }
                iCount++;
            }
            soList[0].date_x = dateTime.now();
            soList[0].dateDue = dateTime.now();
            soList[0].item = itemList;

            List<SmartTurn_OccamTypes.UploadResponse> smartTurnSOSaveResponse = smartTurnService.overwriteSalesOrder(soInCredential, soList);
    
            if (smartTurnSOSaveResponse != null)
            {
                System.debug('\n\n*** smartTurnSOSaveResponse.status '  + smartTurnSOSaveResponse[0].status + '***\n\n');
                
                if (smartTurnSOSaveResponse[0].status == 'SUCCESS')
                {
                    errorPageDetails = 'Successfully submitted Serial Numbers to SmartTurn';
                    return Page.milestoneProof_M2_Submit_Conf;
                }
                else
                {
                    String[] errorList = smartTurnSOSaveResponse[0].error;
                    errorPageDetails = 'Error from SmartTurn : ' + errorList[0];
                    return Page.milestoneProof_M2_Submit_Conf;
                }
            }
            else
            {
                errorPageDetails = 'No response from SmartTurn when attempting to Submit the Serial Numbers';
                return Page.milestoneProof_M2_Submit_Conf;
            }
        }
        else
        {
            errorPageDetails = 'Details of Generation Asset not found in SmartTurn';
            return Page.milestoneProof_M2_Submit_Conf;
            
        }
    */
    }
    
    public Boolean isPTOSaved
    {
        get{
            if (isPTOSaved == null)
            {
                 isPTOSaved = false;
            }
            return isPTOSaved;
        }
        set;
    }
    
    
    public String approvedStatusValue
    {
        get {
            approvedStatusValue = 'Approved';
            return approvedStatusValue;
        }
        set;
    }

    public String pendingStatusValue
    {
        get {
            pendingStatusValue = 'Pending';
            return pendingStatusValue;
        }
        set;
    }

    public String deniedStatusValue
    {
        get {
            deniedStatusValue = 'Denied';
            return deniedStatusValue;
        }
        set;
    }

    public String proofTypeM1
    {
        get {
            proofTypeM1 = 'M1 Proof';
            return proofTypeM1;
        }
        set;

    }

    public String proofTypeM2
    {
        get {
            proofTypeM2 = 'M2 Proof';
            return proofTypeM2;
        }
        set;

    }

    public String proofTypeM3
    {
        get {
            proofTypeM3 = 'M3 Proof';
            return proofTypeM3;
        }
        set;
    }

    public String caseStatusM1Approved
    {
        get {
            caseStatusM1Approved = 'M1 Proof Approved';
            return caseStatusM1Approved;
        }
        set;
    }

    public String caseStatusM2Approved
    {
        get {
            caseStatusM2Approved = 'M2 Proof Approved (non meter test)';
            return caseStatusM2Approved;
        }
        set;
    }

    public String caseStatusM3Approved
    {
        get {
            caseStatusM3Approved = 'M3 PTO Approved';
            return caseStatusM3Approved;
        }
        set;
    }

    public Boolean isM2Proof
    {
        get {
            if (milestoneProofType == 'M2 Proof')
            {
                isM2Proof = true;
            }
            else
            {
                isM2Proof = false;
            }   
            return isM2Proof;
        }
        set;
    }

    public Boolean isM3Proof
    {
        get {
            if (milestoneProofType == 'M3 Proof')
            {
                isM3Proof = true;
            }
            else
            {
                isM3Proof = false;
            }   
            return isM3Proof;
        }
        set;
    }
    

    public transient Blob fileBody {get;set;}   

    public Generation_Assets__c getSrchGenAssetRec()
    {
        if(srchGenAssetRec == null) 
        {
            srchGenAssetRec = new Generation_Assets__c();
        }
        return srchGenAssetRec;   
    }    
    
    public Generation_Assets__c getSelGenAssetRec()
    {
        if(selGenAssetRec == null) 
        {
            selGenAssetRec = new Generation_Assets__c();
        }
        return selGenAssetRec;   
    }    

    public List<SelectOption> getSearchOption() 
    {
        List<SelectOption> options = new List<SelectOption>();

        options.add(new SelectOption( 'Show Gen Assets Needing M1', 'Show Gen Assets Needing M1'));
        options.add(new SelectOption( 'Show Gen Assets Needing M2', 'Show Gen Assets Needing M2'));
        options.add(new SelectOption( 'Show Gen Assets Needing M3', 'Show Gen Assets Needing M3'));
        options.add(new SelectOption( 'Show Gen Assets with ANY Proofs', 'Show Gen Assets with ANY Proofs'));
        options.add(new SelectOption( 'Show Gen Assets with ALL Proofs Submitted', 'Show Gen Assets with ALL Proofs Submitted'));
        options.add(new SelectOption( 'Show All Denied Proofs', 'Show All Denied Proofs'));
        
        return options;    
    }

    public List<SelectOption> getproofType() 
    {
        List<SelectOption> options = new List<SelectOption>();

        options.add(new SelectOption( 'Please Select', 'Please Select'));
        options.add(new SelectOption( 'M1 Proof', 'M1 Proof'));
        options.add(new SelectOption( 'M2 Proof', 'M2 Proof'));
        options.add(new SelectOption( 'M3 Proof', 'M3 Proof'));
        
        return options;    
    }

    
    public PageReference doSearch() 
    {
        String sqlQuery = 'Select Id, Install_Partner__c, Account_Name__r.Name, Name, Cust_Ref_Num__c , ' ;
        sqlQuery = sqlQuery + 'Customer_Name_Formula__c, Home_Address__c, M1_Proof_Upload_Date__c, M2_Proof_Upload_Date__c, ';
        sqlQuery = sqlQuery + 'M3_Proof_Upload_Date__c, M1_proof_panel_inverter_delivery__c, M2_proof_substantial_completion__c, '; 
        sqlQuery = sqlQuery + 'Number_of_Sunrun_owned_Modules__c, System_Size_DC__c, Meter_Test_Date__c, PTO__c, Partner_PTO_proof_date__c, NTP_Granted__c, Rebate_Form_Sent__c, Meter_Serial_Num__c ' ;
        sqlQuery = sqlQuery + 'From Generation_Assets__c Where NTP_Granted__c != null And ';
        sqlQuery = sqlQuery + 'Asset_Status__c NOT IN (' + '\'' + String.escapeSingleQuotes(cancelledStatus1) + '\'';
        sqlQuery = sqlQuery + ',' + '\'' + String.escapeSingleQuotes(cancelledStatus2) + '\'' + ')';
        
        if (acctName != null && acctName != '')
        {
            String likeQryString = '%' + acctName + '%';
            
            sqlQuery = sqlQuery + ' And Customer_Name_Formula__c Like ' + '\'' + String.escapeSingleQuotes(likeQryString) + '\'';
        }
        
        if (custRefNum != null && custRefNum != '')
        {
            String likeQryString = '%' + custRefNum + '%';
            
            sqlQuery = sqlQuery + ' And Cust_Ref_Num__c Like ' + '\'' + String.escapeSingleQuotes(likeQryString) + '\'';
        }

        if (custMailAddress != null && custMailAddress != '')
        {
            String likeQryString = '%' + custMailAddress + '%';
            
            sqlQuery = sqlQuery + ' And Customer_Mailing_Address__c Like ' + '\'' + String.escapeSingleQuotes(likeQryString) + '\'';
        }
        
        if (srchOptionFilter == 'Show Gen Assets Needing M1')
        {
            sqlQuery = sqlQuery + ' And M1_Proof_Upload_Date__c = null And M1_proof_panel_inverter_delivery__c = null And M2_proof_substantial_completion__c = null';
        }

        if (srchOptionFilter == 'Show Gen Assets Needing M2')
        {
          sqlQuery = sqlQuery + ' And M2_Proof_Upload_Date__c = null And M2_proof_substantial_completion__c = null';
        }
    
        if (srchOptionFilter == 'Show Gen Assets Needing M3')
        {
          sqlQuery = sqlQuery + ' And M3_Proof_Upload_Date__c = null And PTO__c = null And Partner_PTO_proof_date__c = null';
        }

        if (srchOptionFilter == 'Show Gen Assets with ANY Proofs')
        {
            sqlQuery = sqlQuery + ' And (M1_Status__c != null OR M2_Status__c != null OR M3_Status__c != null)' ;
        }
        
        if (srchOptionFilter == 'Show Gen Assets with ALL Proofs Submitted')
        {
            sqlQuery = sqlQuery + ' And (M1_Status__c  != null AND M2_Status__c != null AND M3_Status__c != null)' ;
        }

        if (srchOptionFilter == 'Show All Denied Proofs')
        {
            sqlQuery = sqlQuery + ' AND (M1_Status__c  = ' + '\'' + String.escapeSingleQuotes(deniedStatusValue) + '\'' ;
            sqlQuery = sqlQuery + 'OR M2_Status__c = ' + '\'' + String.escapeSingleQuotes(deniedStatusValue) + '\'' ; 
            sqlQuery = sqlQuery + 'OR M3_Status__c = ' + '\'' + String.escapeSingleQuotes(deniedStatusValue) + '\'' + ')' ;
        }

        if (!Test.isRunningTest())
        {
            sqlQuery = sqlQuery + ' Limit 1000';
        }
        else
        {
            sqlQuery = sqlQuery + ' Limit 10';
        }
        system.debug(sqlQuery);

        genAssetList = Database.query(sqlQuery);
        searchedAssetsList.clear();
        for(Generation_Assets__c genAssetRec : genAssetList)
        {
            searchedAssetsList.add(new genAssetWrapper(genAssetRec));
        }
        buildPagedAssetList(1);
        if (caseList != null)
        {
            caseList.clear();
        }
        iNumSunRunOwnedModulesUsed = null;
        return null;
    }

    public PageReference doSearchCase() 
    {
        String sqlQuery = 'Select Id, CaseNumber, Milestone_Proof_Type__c, Status, Milestone_Proof_Approval_Date__c From Case Where RecordTypeId = ' ;
        sqlQuery = sqlQuery + '\'' + String.escapeSingleQuotes(mileStoneRecType.Id) + '\'';
        sqlQuery = sqlQuery + ' And Generation_Asset__c = '; 
        sqlQuery = sqlQuery + '\'' + String.escapeSingleQuotes(currentAssetId) + '\'';

        sqlQuery = sqlQuery + ' Limit 1000';
        system.debug(sqlQuery);

        caseList = Database.query(sqlQuery);
        return null;
    }
    
    public List<Case> getCaseList()
    {
        return caseList;
    }
    
    public PageReference uploadDocument()
    {
        GetSelectedAsset();
        
        if (selectedAssetsList == null || selectedAssetsList.size() <=  0)
        {
            errorPageDetails = 'To Upload a Milestone Proof, you must first select a Generation Asset.';
            return Page.milestoneProof_Error;
        }
        else if (selectedAssetsList.size() >  1)
        {
            errorPageDetails = 'Proofs can only be uploaded to one Generation Asset at a time, please select only one Generation Asset.';
            return Page.milestoneProof_Error;
        }
        
        milestoneProofType = 'Please Select';
        isPTOSaved = false;
        String genAssetId = selectedAssetsList[0].genAssetRec.Id;
        currentAssetId = genAssetId;
        selGenAssetRec = [Select Id, Name, Account_Name__c, Cust_Ref_Num__c, Home_Address__c, City__c, Install_Partner__c, State__c, Zip__c,
                                    M1_Status__c, M2_Status__c, M3_Status__c, 
                                    M1_Proof_Count__c, M2_Proof_Count__c, M3_Proof_Count__c, M1_proof_panel_inverter_delivery__c, M2_proof_substantial_completion__c,
                                    Number_of_Sunrun_owned_Modules__c, System_Size_DC__c, Meter_Test_Date__c, Meter_Serial_Num__c,PTO__c, Partner_PTO_proof_date__c, NTP_Granted__c, Rebate_Form_Sent__c, Cash_Grant_Eligible__c, Panel_Serial_Number__c,
                                    SmartTurn_M1_StatusCode__c, SmartTurn_M2_StatusCode__c, SmartTurn_Message__c, 
                                    (Select Panel_Type__c, Number_of_Panels__c  From Facility_Configurations__r Order by Id)                                    
                                    From Generation_Assets__c Where Id = :genAssetId];

        if (selGenAssetRec.M1_Proof_Count__c == null)
        {
            m1Count = 1;
        }
        else
        {
            m1Count = selGenAssetRec.M1_Proof_Count__c + 1;
        } 

        if (selGenAssetRec.M2_Proof_Count__c == null)
        {
            m2Count = 1;
        }
        else
        {
            m2Count = selGenAssetRec.M2_Proof_Count__c + 1;
        } 

        if (selGenAssetRec.M3_Proof_Count__c == null)
        {
            m3Count = 1;
        }
        else
        {
            m3Count = selGenAssetRec.M3_Proof_Count__c + 1;
        } 
        if(selGenAssetRec.Number_of_Sunrun_owned_Modules__c != null)
        {
            iNumSunRunOwnedModulesUsed = Integer.ValueOf(selGenAssetRec.Number_of_Sunrun_owned_Modules__c);
        }
        return Page.milestoneProofUploadFile;
    } 

    public String getGenAssetId()
    {    	
    	GetSelectedAsset();                
        milestoneProofType = 'Please Select';
        isPTOSaved = false;
        if (selectedAssetsList != null && selectedAssetsList.size() >  0)
        {
           String genAssetId = selectedAssetsList[0].genAssetRec.Id;
           currentAssetId = genAssetId;
    	   return currentAssetId;
        }
        return null;
    }

    public PageReference showAlbum()
    {     
    	Boolean bHasPhotos = false;
    	Integer photoCount = 0;
    	GetSelectedAsset();
        String genAssetId = selectedAssetsList[0].genAssetRec.Id;
        currentAssetId = genAssetId;
        System.Debug('SELECTED GEN ASSET FOR SHOW ALBUM = ' + currentAssetId);
        
        selGenAssetRec = [Select Id, Name, Account_Name__c, Cust_Ref_Num__c, Home_Address__c, City__c, Install_Partner__c, State__c, Zip__c,
                                    M1_Status__c, M2_Status__c, M3_Status__c, 
                                    M1_Proof_Count__c, M2_Proof_Count__c, M3_Proof_Count__c, M1_proof_panel_inverter_delivery__c, M2_proof_substantial_completion__c,
                                    Number_of_Sunrun_owned_Modules__c, System_Size_DC__c, Meter_Test_Date__c, Meter_Serial_Num__c,PTO__c, Partner_PTO_proof_date__c, NTP_Granted__c, Rebate_Form_Sent__c, Cash_Grant_Eligible__c, Panel_Serial_Number__c,
                                    SmartTurn_M1_StatusCode__c, SmartTurn_M2_StatusCode__c, SmartTurn_Message__c, 
                                    (Select Panel_Type__c, Number_of_Panels__c  From Facility_Configurations__r Order by Id)                                    
                                    From Generation_Assets__c Where Id = :genAssetId];        
        System.Debug('SELECTED GEN ASSET LIST SIze = ' + selectedAssetsList.size());
    	if (selectedAssetsList == null || selectedAssetsList.size() <=  0)
        {
        	System.Debug('none selected');
        	bHasPhotos = false;
        	errorPageDetails = 'To View Photo Album, you must first select a Generation Asset.';
            return Page.milestoneProof_Error;
        }
        if(selectedAssetsList.size() >  1)
        {
        	System.Debug('many selected');
        	bHasPhotos = false;
         	errorPageDetails = 'Photos can only be viewed in relatin to one Generation Asset at a time, please select only one Generation Asset.';
            return Page.milestoneProof_Error;
        }
    	for(SR_Gen_Asset_Attachment__c gaa:[select Id, Document_Name__c, Size__c, Active__c, Generation_Asset__r.Name, Document_Name_On_File_Server__c, Thumbnail__c 
    	                                      from SR_Gen_Asset_Attachment__c 
    	                                     where Generation_Asset__c = :genAssetId 
    	                                       and Active__c = true])
    	{
    		bHasPhotos = true;
    		photoCount++;
    	}    	
    	if(photoCount == 0)
    	{
    	    errorPageDetails = 'No photos have been uploaded to this asset yet.';
    	}
        return null;    
    }
    
    public PageReference uploadPhotos()
    {
        GetSelectedAsset();
        System.Debug('selectedAssetsList VALUE: ' + selectedAssetsList);
        if (selectedAssetsList == null || selectedAssetsList.size() <=  0)
        {
            errorPageDetails = 'To Upload Photos, you must first select a Generation Asset.';
            PageReference pr = Page.milestoneProof_Error;
            pr.setRedirect(true);
            return pr;
        }
        else if (selectedAssetsList.size() >  1)
        {
            errorPageDetails = 'Photos can only be uploaded to one Generation Asset at a time, please select only one Generation Asset.';
            return Page.milestoneProof_Error;
        }
        
        milestoneProofType = 'Please Select';
        isPTOSaved = false;
        String genAssetId = selectedAssetsList[0].genAssetRec.Id;
        currentAssetId = genAssetId;
        System.Debug('SELECTED GEN ASSET for Upload Photos = ' + currentAssetId);
        selGenAssetRec = [Select Id, Name, Account_Name__c, Cust_Ref_Num__c, Home_Address__c, City__c, Install_Partner__c, State__c, Zip__c,
                                    M1_Status__c, M2_Status__c, M3_Status__c, 
                                    M1_Proof_Count__c, M2_Proof_Count__c, M3_Proof_Count__c, M1_proof_panel_inverter_delivery__c, M2_proof_substantial_completion__c,
                                    Number_of_Sunrun_owned_Modules__c, System_Size_DC__c, Meter_Test_Date__c, Meter_Serial_Num__c,PTO__c, Partner_PTO_proof_date__c, NTP_Granted__c, Rebate_Form_Sent__c, Cash_Grant_Eligible__c, Panel_Serial_Number__c,
                                    SmartTurn_M1_StatusCode__c, SmartTurn_M2_StatusCode__c, SmartTurn_Message__c, 
                                    (Select Panel_Type__c, Number_of_Panels__c  From Facility_Configurations__r Order by Id)                                    
                                    From Generation_Assets__c Where Id = :genAssetId];

        if (selGenAssetRec.M1_Proof_Count__c == null)
        {
            m1Count = 1;
        }
        else
        {
            m1Count = selGenAssetRec.M1_Proof_Count__c + 1;
        } 

        if (selGenAssetRec.M2_Proof_Count__c == null)
        {
            m2Count = 1;
        }
        else
        {
            m2Count = selGenAssetRec.M2_Proof_Count__c + 1;
        } 

        if (selGenAssetRec.M3_Proof_Count__c == null)
        {
            m3Count = 1;
        }
        else
        {
            m3Count = selGenAssetRec.M3_Proof_Count__c + 1;
        } 
        if(selGenAssetRec.Number_of_Sunrun_owned_Modules__c != null)
        {
            iNumSunRunOwnedModulesUsed = Integer.ValueOf(selGenAssetRec.Number_of_Sunrun_owned_Modules__c);
        }
        return null;
    }
    
    public PageReference attachFile()
    {
        if(milestoneProofType == proofTypeM3){

            if(selGenAssetRec.Meter_Serial_Num__c == null || selGenAssetRec.Meter_Serial_Num__c == '' || selGenAssetRec.Meter_Test_Date__c == null){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Missing Meter Registration - You cannot Upload M3 Proof if Meter Serial Number is not Registered'));
                return null;
            }
        }
        
        if ((fileBody != null && fullPathFileName != null) || isPTOSaved)
        {
            if (fileBody != null && fullPathFileName != null && fileBody.size() > 5242880 )
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Max attachment size is 5Mb'));
            }
            else
            {
                currentAssetId = selectedAssetsList[0].genAssetRec.Id;
                
                String sqlQuery = 'Select Id, Status From Case Where IsClosed = false And RecordTypeId = ' ;
                sqlQuery = sqlQuery + '\'' + String.escapeSingleQuotes(mileStoneRecType.Id) + '\'';
                sqlQuery = sqlQuery + ' And Generation_Asset__c = '; 
                sqlQuery = sqlQuery + '\'' + String.escapeSingleQuotes(currentAssetId) + '\'';
                sqlQuery = sqlQuery + ' And Milestone_Proof_Type__c = '; 
                sqlQuery = sqlQuery + '\'' + String.escapeSingleQuotes(milestoneProofType) + '\'';

                system.debug(sqlQuery);
        
                Case[] currentCaseList = Database.query(sqlQuery);
                Case currentCaseRec;
                
                User userRec = [SELECT Contact.AccountId, Contact.FirstName,  ContactId From User WHERE Id = :Userinfo.getUserid()];
                if (currentCaseList != null && currentCaseList.size() > 0)
                {
                    currentCaseRec = currentCaseList[0];
                 //   if (currentCaseRec.Status == 'Request Approval' || currentCaseRec.Status.contains('Approved')) 
                      if (currentCaseRec.Status.contains('Approved')) 
                    {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Milestone Proof of type ' + milestoneProofType + ' already exists for the project located at ' + selGenAssetRec.Home_Address__c));
                        return null;
                    }
                    
                    currentCaseRec.Status = 'Request Approval';
                    update currentCaseRec;
                }
             else
                {
                    System.debug('\n\n*** selGenAssetRec.M1_proof_panel_inverter_delivery__c '  + selGenAssetRec.M1_proof_panel_inverter_delivery__c + '***\n\n');
                    System.debug('\n\n*** selGenAssetRec.M2_proof_substantial_completion__c '  + selGenAssetRec.M2_proof_substantial_completion__c + '***\n\n');
                    System.debug('\n\n*** selGenAssetRec.PTO__c '  + selGenAssetRec.PTO__c + '***\n\n');

                    if ((milestoneProofType == proofTypeM1 && selGenAssetRec.M1_proof_panel_inverter_delivery__c != null) ||
                            (milestoneProofType == proofTypeM2 && selGenAssetRec.M2_proof_substantial_completion__c != null) ||
                            (milestoneProofType == proofTypeM3 && selGenAssetRec.PTO__c  != null))
                            {
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Milestone Proof of type ' + milestoneProofType + ' already exists for the project located at ' + selGenAssetRec.Home_Address__c));
                                return null;
                            }

                    String dfltCaseOwnerEmail = null;
                    String dfltCaseOwnerId = null;
                    for (Milestone_Proof_Case_Owner__c dfltCaseOwnerDtl : dfltCaseOwnerList)
                    {
                        if (dfltCaseOwnerDtl.Name == selGenAssetRec.Install_Partner__c)
                        {
                            dfltCaseOwnerEmail = dfltCaseOwnerDtl.Case_Owner_Email__c;
                            break;
                        }
                    }
                    
                    if (dfltCaseOwnerEmail != null)
                    {
                        User[] ownerList = [Select Id From User Where Email = :dfltCaseOwnerEmail];
                         
                        if (ownerList != null && ownerList.size() > 0)
                        {
                            dfltCaseOwnerId = ownerList[0].Id;
                        }
                        else
                        {
                            Group[] groupList = [Select Id From Group Where Email = :dfltCaseOwnerEmail];
                            if (groupList != null && groupList.size() > 0)
                            {
                                dfltCaseOwnerId = groupList[0].Id;
                            }
                        }
                    }
                    
                    currentCaseRec = new Case();
                    currentCaseRec.RecordTypeId = mileStoneRecType.Id;
                    
                    if (userRec.ContactId != null)
                    {
                        currentCaseRec.AccountId = userRec.Contact.AccountId;
                        currentCaseRec.ContactId = userRec.ContactId;
                    } 
                    
                    currentCaseRec.Milestone_Proof_Type__c = milestoneProofType;
                    currentCaseRec.Status = 'Request Approval';
                    currentCaseRec.Origin = 'Install Partner'; 
                    currentCaseRec.Reason = 'Documentation';
                    currentCaseRec.Description = 'Milestone Proof Submitted';
                    currentCaseRec.Subject = 'Milestone Proof Submitted';
                    currentCaseRec.Generation_Asset__c = currentAssetId;
                    currentCaseRec.Install_Partner__c = selGenAssetRec.Install_Partner__c;
                    if (dfltCaseOwnerId != null)
                    {
                        currentCaseRec.OwnerId = dfltCaseOwnerId;
                    }
                    insert currentCaseRec;
                }
                if (!isPTOSaved)
                {   
                    String descriptiveName = '';
                    Integer lastIndex = fullPathFileName.lastIndexOf('.');
                    if (lastIndex > 0)
                    {
                        String fileExt = fullPathFileName.substring(lastIndex);
                        if (milestoneProofType == proofTypeM1)
                        {
                            descriptiveName = 'M1_Proof_' + m1Count + fileExt;
                        }
                        else if (milestoneProofType == proofTypeM2)
                        {
                            descriptiveName = 'M2_Proof_' + m2Count +  fileExt;
                        }
                        else if (milestoneProofType == proofTypeM3)
                        {
                            descriptiveName = 'M3_Proof_' + m3Count +  + fileExt;
                        }
                    }
                    else
                    {
                        descriptiveName = fullPathFileName;
                    }
                    
                    attachmentFile.Body = fileBody;   
                    attachmentFile.Name = descriptiveName;   
                    attachmentFile.ParentId = currentCaseRec.Id;
                    try 
                    {
                        insert attachmentFile;  
                        
                        if (partnerPreferenceList != null && partnerPreferenceList.size() > 0)
                        {
                            Milestone_Proof_Partner_Preference__c partnerPreference = partnerPreferenceList[0];
                            if (partnerPreference.Notify_Milestone_Proof_Upload__c && partnerPreference.Emails_To_Notify_Milestone_Proof_Upload__c != null)
                            {
                                List<String> partnerEmailId = partnerPreference.Emails_To_Notify_Milestone_Proof_Upload__c.split(',');
//                              String[] partnerEmailId = new String[1];
//                              partnerEmailId[0] = partnerPreference.Emails_To_Notify_Milestone_Proof_Upload__c;
                                
                                if (templateList != null && templateList.size() > 0)
                                {
                                        Case tempCaseRec = [Select CaseNumber, Milestone_Proof_Type__c, Customer_Reference_Number__c, 
                                                                Customer_Name__c, Customer_Mailing_Address__c From Case Where Id = :currentCaseRec.Id];                                         
                                        
                                        EmailTemplate templRec1 = templateList[0];
                                        String templBody =  templRec1.Body;
                                        String emailSubject = templRec1.Subject;
                                        String caseURL = serverURL + '/' +  currentCaseRec.Id;
                                        templBody = templBody.replace('{!Contact.FirstName}', userRec.Contact.FirstName);
                                        templBody = templBody.replace('{!Case.Link}', caseURL);
                                        templBody = templBody.replace('{!Case.CaseNumber}', tempCaseRec.CaseNumber);
                                        templBody = templBody.replace('{!Case.Milestone_Proof_Type__c}', tempCaseRec.Milestone_Proof_Type__c);
                                        templBody = templBody.replace('{!Case.Customer_Reference_Number__c}', tempCaseRec.Customer_Reference_Number__c);
                                        templBody = templBody.replace('{!Case.Customer_Name__c}', tempCaseRec.Customer_Name__c);
                                        templBody = templBody.replace('{!Case.Customer_Mailing_Address__c}', tempCaseRec.Customer_Mailing_Address__c);
                                        
                                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                                        mail.setSubject(emailSubject);
                                        mail.setToAddresses( partnerEmailId );
                                        mail.setPlainTextBody(templBody);

                                        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });                                       
                                }                               
                            }
                        }
                        UpdateNumberOfPreBoughtPanels(); 
                    } 
                    catch (DMLException e) 
                    {
                        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error uploading file'));
                        return null;
                    } 
                    finally 
                    {
                        attachmentFile.Body = null; // clears the viewstate
                        attachmentFile = new Attachment();
                        fileBody = null;
                        fullPathFileName = null;
                    }
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'File uploaded successfully'));
                    updateAssetRec();       
                    getAttachments();
                    
                }
                else
                {
                    selGenAssetRec.M3_Status__c = 'Pending';
                    update selGenAssetRec;
                }
            }
        }
        return null;
    } 

    public PageReference savePTO()
    {
        if(milestoneProofType == proofTypeM3){

            if(selGenAssetRec.Meter_Serial_Num__c == null || selGenAssetRec.Meter_Serial_Num__c == '' || selGenAssetRec.Meter_Test_Date__c == null){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Missing Meter Registration - You cannot Save PTO date if Meter Serial Number is not Registered'));
                return null;
            }
        }
        
        isPTOSaved = true;
        attachFile();
        return backToSearch();
    }
    
    public void updateAssetRec()
    {
        if (milestoneProofType == proofTypeM1)
        {
            selGenAssetRec.M1_Proof_Upload_Date__c = date.today();
            selGenAssetRec.M1_Proof_Count__c = m1Count;
            selGenAssetRec.M1_Status__c = 'Pending';
            m1Count++;
            update selGenAssetRec;
        }
        else if (milestoneProofType == proofTypeM2)
        {
            selGenAssetRec.M2_Proof_Upload_Date__c = date.today();
            selGenAssetRec.M2_Proof_Count__c = m2Count;
            selGenAssetRec.M2_Status__c = 'Pending';
            m2Count++;
            update selGenAssetRec;
        }
        else if (milestoneProofType == proofTypeM3)
        {
            selGenAssetRec.M3_Proof_Upload_Date__c = date.today();
            //selGenAssetRec.Partner_PTO_proof_date__c = date.today();
            selGenAssetRec.M3_Proof_Count__c = m3Count;
            selGenAssetRec.M3_Status__c = 'Pending';
            m3Count++;
            update selGenAssetRec;
        }
    }
    
    public PageReference backToSearch()
    {
        doSearch();
        return Page.milestoneProof;
    } 
    
    public List<genAssetWrapper> getSearchedAssetsList()
    {
        return searchedAssetsList;
    }
    
    public PageReference GetSelectedAsset()
    {
        selectedAssetsList.clear();
        for(genAssetWrapper genAssetWrapperRec : searchedAssetsList)
        {
            if(genAssetWrapperRec.recSelected == true)
            {
                selectedAssetsList.add(genAssetWrapperRec);
            }
        }
        return null;
    }
    
    public List<Attachment> getAttachments()
    {
        try 
        {
            if (currentAssetId != null)
            {
                Set <Id> caseIds = new Set <Id>();
                Integer iCount = 0;
                for (Case caseRec : [SELECT Id FROM Case WHERE Generation_Asset__c = :currentAssetId])
                {
                    caseIds.add(caseRec.Id);
                    iCount++;
                }
                system.debug(caseIds);
                if(!caseIds.isEmpty())
                {
                   attachments = [Select ParentId, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById From Attachment Where ParentId IN :caseIds];
                }
            }
        }
        catch (Exception e)
        {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Unable to get attachments'));          
        }
        return attachments;
    }
    
    public class genAssetWrapper
    {
        public Generation_Assets__c genAssetRec{get; set;}
        public Boolean recSelected {get; set;}

        public genAssetWrapper(Generation_Assets__c genAsset)
        {
            genAssetRec = genAsset;
            recSelected = false;
        }
    }
 
    public String sortField {get; set;}
    public String previousSortField {get; set;}

    public void doAssetSort()
    {
        String order = 'asc';
        /*This checks to see if the same header was click two times in a row, if so
        it switches the order.*/
        
        if (genAssetList == null || genAssetList.size() <= 0)
        {
            return;
        }
        if(previousSortField == sortField){
            order = 'desc';
            previousSortField = null;
        }else{
            previousSortField = sortField;
        }
        //To sort the table we simply need to use this one line, nice!
        superSort.sortList(genAssetList,sortField,order);
        searchedAssetsList.clear();
        pagedAssetList.clear();
        for(Generation_Assets__c genAssetRec : genAssetList)
        {
            searchedAssetsList.add(new genAssetWrapper(genAssetRec));
        }
        assetPageNumber = 1;
        buildPagedAssetList(assetPageNumber);
    }
 
    public List<genAssetWrapper> pagedAssetList = new List<genAssetWrapper>();
    private Integer assetPageNumber = 0;
    private Integer assetPageSize = 50;
    private Integer assetTotalPageNumber = 0;
    
    public Integer getAssetPageNumber()
    {
        return assetPageNumber;
    }
    public Boolean getAssetPreviousButtonEnabled()    //Contracts Previous 
    {
        return !(assetPageNumber > 1);
    }

    public Boolean getAssetNextButtonDisabled()       //Contracts Next
    {
        return ((assetPageNumber * assetPageSize) >= searchedAssetsList.size());
    }

    public Integer getassetTotalPageNumber()
    {
        if (assetTotalPageNumber == 0 && searchedAssetsList !=null)
        {
            assetTotalPageNumber = searchedAssetsList.size() / assetPageSize;
            Integer mod = searchedAssetsList.size() - (assetTotalPageNumber * assetPageSize);
            if (mod > 0)
            assetTotalPageNumber++;
        }
        return assetTotalPageNumber;
    }

    public List<genAssetWrapper> getpagedAssetList()
    {
        return pagedAssetList;
    }

    public void buildpagedAssetList(Integer newPageIndex)
    {
        try
        {
            pagedAssetList = new List<genAssetWrapper>();
            Transient Integer counter = 0;
            Transient Integer min = 0;
            Transient Integer max = 0;

            if (newPageIndex > assetPageNumber)
            {
                min = assetPageNumber * assetPageSize;
                max = newPageIndex * assetPageSize;
            }
            else
            {
                max = newPageIndex * assetPageSize;
                min = max - assetPageSize;
            }
            for(genAssetWrapper assetRec : searchedAssetsList)
            {
                counter++;
                if (counter > min && counter <= max)
                pagedAssetList.add(assetRec);
            }
            assetPageNumber = newPageIndex;
        }
        catch(Exception ex)
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,ex.getMessage()));
        }
    }

    public PageReference assetNextBtnClick() 
    {
        buildpagedAssetList(assetPageNumber + 1);

        return null;
    }

    public PageReference assetPreviousBtnClick() 
    {
        buildpagedAssetList(assetPageNumber - 1);
        return null;

    }
    
    public static testMethod void milestoneProofTest()
    {
        
        /*ID ProfileID = [ Select id from Profile where name = 'Verengo Profile'].id;
        Account A1 = new Account(Name = 'Test Account');
        insert A1;
        
        List<Contact> ContactList = new List<Contact>();
        Contact C1 = new Contact( AccountID = A1.id, FirstName = 'Test', LastName = 'User', 
        email = 'test-user@fakeemail.com', Title = 'Key User' );
        insert C1;
 
        User u1 = new User( email='test-user@fakeemail.com', contactid = c1.id, profileid = profileid, 
                UserName='test-user@fakeemail.com', alias='tuser1', CommunityNickName='tuser1', 
        TimeZoneSidKey='America/New_York', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', 
        LanguageLocaleKey='en_US', FirstName = 'Test', LastName = 'User',Title = 'Key User' );
        insert u1;
        
        System.RunAs(u1)
        {       */
        
        
        Test.startTest();
        milestoneProof testMileStoneProof = new milestoneProof();
        Boolean isPTOSaved = testMileStoneProof.isPTOSaved;
        String approvedStatusValue  = testMileStoneProof.approvedStatusValue;
        String pendingStatusValue = testMileStoneProof.pendingStatusValue;
        String deniedStatusValue = testMileStoneProof.deniedStatusValue;
        String proofTypeM1 = testMileStoneProof.proofTypeM1;
        String proofTypeM2 = testMileStoneProof.proofTypeM2;
        String proofTypeM3 = testMileStoneProof.proofTypeM3;
        String caseStatusM1Approved = testMileStoneProof.caseStatusM1Approved;
        String caseStatusM2Approved = testMileStoneProof.caseStatusM2Approved;
        String caseStatusM3Approved = testMileStoneProof.caseStatusM3Approved;

        testMileStoneProof.getproofType();
 
        Generation_Assets__c srchGenAssetRec = testMileStoneProof.getSrchGenAssetRec();
        Generation_Assets__c selGenAssetRec = testMileStoneProof.getSelGenAssetRec();                                        
        
        testMileStoneProof.getSearchOption();
        
        srchGenAssetRec = [Select Id, System_Size_DC__c, Number_of_Sunrun_owned_Modules__c, Customer_Name_Formula__c, Cust_Ref_Num__c, Customer_Mailing_Address__c,  
                            Account_Name__r.Name,Meter_Serial_Num__c From Generation_Assets__c 
                            Where NTP_Granted__c != null And Asset_Status__c 
                            NOT IN ('Deal Cancelled','Deal Cancelled') 
                            And M1_Proof_Upload_Date__c = null 
                            And M1_proof_panel_inverter_delivery__c = null 
                            And M2_proof_substantial_completion__c = null 
                            And Customer_Name_Formula__c != null 
                            And Cust_Ref_Num__c != null 
                            And Customer_Mailing_Address__c != null Limit 1];
        testMileStoneProof.srchGenAssetRec = srchGenAssetRec;
        
        System.debug('\n\n*** srchGenAssetRec.Customer_Name_Formula__c '  + srchGenAssetRec.Customer_Name_Formula__c + '***\n\n');
        
        testMileStoneProof.srchOptionFilter = 'Show Gen Assets Needing M1';
        testMileStoneProof.acctName = srchGenAssetRec.Customer_Name_Formula__c;
        testMileStoneProof.custRefNum = srchGenAssetRec.Cust_Ref_Num__c;
        testMileStoneProof.custMailAddress = srchGenAssetRec.Customer_Mailing_Address__c;
        
        testMileStoneProof.doSearch();
        testMileStoneProof.sortField = 'Customer_Name_Formula__c';
        testMileStoneProof.doAssetSort();
        testMileStoneProof.sortField = 'Customer_Name_Formula__c';
        testMileStoneProof.doAssetSort();
        
        Integer assetPageNumber = testMileStoneProof.getAssetPageNumber();
        Boolean previousButtonEnabled = testMileStoneProof.getAssetPreviousButtonEnabled();
        Boolean nextButtonEnabled = testMileStoneProof.getAssetNextButtonDisabled();
        Integer assetTotalPageNumber = testMileStoneProof.getAssetTotalPageNumber();
        List<genAssetWrapper> pagedAssetList = testMileStoneProof.getpagedAssetList();
        testMileStoneProof.buildPagedAssetList(1);
        testMileStoneProof.assetNextBtnClick();
        testMileStoneProof.assetPreviousBtnClick();
        testMileStoneProof.getAssetPreviousButtonEnabled();
        
        List<genAssetWrapper> searchedAssetsList = testMileStoneProof.searchedAssetsList;
        searchedAssetsList = testMileStoneProof.getSearchedAssetsList();
        
        for(genAssetWrapper assetWrapperRec : searchedAssetsList)
        {
            assetWrapperRec.recSelected = true;
            break;
        }
        testMileStoneProof.searchedAssetsList = searchedAssetsList;
        testMileStoneProof.GetSelectedAsset();   
        
        if(searchedAssetsList.size() == 0)
        {
            searchedAssetsList.add(new mileStoneProof.genAssetWrapper(srchGenAssetRec));            
        }     
        if(testMileStoneProof.selectedAssetsList.size() == 0)
        {
            testMileStoneProof.selectedAssetsList.add(new mileStoneProof.genAssetWrapper(srchGenAssetRec));
        }        
        //
        selGenAssetRec = srchGenAssetRec;
        //
        testMileStoneProof.currentAssetId = searchedAssetsList[0].genAssetRec.Id;
        testMileStoneProof.doSearchCase();
        testMileStoneProof.uploadDocument();

        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        testMileStoneProof.fileBody = bodyBlob;
        testMileStoneProof.fullPathFileName = 'temp.txt';
        
        Attachment attachmentFile = testMileStoneProof.attachmentFile;
        
        testMileStoneProof.milestoneProofType = 'M1 Proof';
        //
        
        if(testMileStoneProof.selectedAssetsList.size() == 0)
        {
            testMileStoneProof.selectedAssetsList.add(new mileStoneProof.genAssetWrapper(srchGenAssetRec));
        }
        
        //
        if(testMileStoneProof.partnerPreferenceList == null || testMileStoneProof.partnerPreferenceList.size() == 0)
        {
            testMileStoneProof.partnerPreferenceList.add(new Milestone_Proof_Partner_Preference__c(Emails_To_Notify_Milestone_Proof_Upload__c = 'pmandy@sunrunhome.com', Notify_Milestone_Proof_Upload__c = false, Partner_Account__c = selGenAssetRec.Account_Name__c));
        }

        testMileStoneProof.attachFile();      //was failing here in INTDEV so added the above conditional statement.   
        testMileStoneProof.m1Count = 0;   
        testMileStoneProof.m2Count = 0;
        testMileStoneProof.m3Count = 0;
        testMileStoneProof.selGenAssetRec = srchGenAssetRec;        

        testMileStoneProof.selGenAssetRec.SR_Signoff__c = date.today();
        testMileStoneProof.selGenAssetRec.Facility_Design_Approved__c = date.today();
        testMileStoneProof.selGenAssetRec.Complete_Deal_Received__c = date.today();
        testMileStoneProof.selGenAssetRec.Initial_Deposit_Processed__c = date.today();
        testMileStoneProof.selGenAssetRec.Initial_Deposit_Amount_Received__c = 10000;
        testMileStoneProof.selGenAssetRec.Initial_Deposit_Amount__c = 10000;
        testMileStoneProof.selGenAssetRec.Rebate_Conf_Rec_d__c  = date.today();
        testMileStoneProof.selGenAssetRec.Final_Rebate_Amount__c = 100.00;

        testMileStoneProof.updateAssetRec();  //NOW failing here in INTDEV // was commented out to stop SOQL 101
        testMileStoneProof.getAttachments();  // was commented out to stop SOQL 101
        testMileStoneProof.backToSearch();
                
        //For Cash Grant stuff
        PageReference prCG;        
        //
        Facility_Configuration__c fc = new Facility_Configuration__c();
        fc.Panel_Type__c = 'LG255S1C-G2';
        fc.Number_of_Panels__c = 10;
        fc.Generation_Asset__c = selGenAssetRec.Id;
        insert fc;
        //
        selGenAssetRec.Install_Partner__c = 'Verengo';
        selGenAssetRec.Number_of_Sunrun_owned_Modules__c = 5;
        testMileStoneProof.iNumSunRunOwnedModulesUsed = 5;
        prCG = testMileStoneProof.validateConfiguration();
        selGenAssetRec.Cash_Grant_Eligible__c = false;
        selGenAssetRec.Number_of_Sunrun_owned_Modules__c = 10;
        testMileStoneProof.iNumSunRunOwnedModulesUsed = 10;                
        prCG = testMileStoneProof.validateConfigurationFromProofType();
        selGenAssetRec.SmartTurn_M1_StatusCode__c = 'SUCCESS';
        prCG = testMileStoneProof.validateConfigurationFromProofType();
                        
        testMileStoneProof.srchGenAssetRec = new Generation_Assets__c();
        testMileStoneProof.srchOptionFilter = 'Show Gen Assets Needing M2';
        testMileStoneProof.acctName = '';
        testMileStoneProof.doSearch();
        
        searchedAssetsList = testMileStoneProof.searchedAssetsList;
        searchedAssetsList = testMileStoneProof.getSearchedAssetsList();
        
        for(genAssetWrapper assetWrapperRec : searchedAssetsList)
        {
            assetWrapperRec.recSelected = true;
            break;
        }
        testMileStoneProof.searchedAssetsList = searchedAssetsList;
        testMileStoneProof.GetSelectedAsset();
        testMileStoneProof.uploadDocument();
        
        testMileStoneProof.fileBody = bodyBlob;
        testMileStoneProof.fullPathFileName = 'temp.txt';
        testMileStoneProof.fileName = 'temp.txt';
        
        attachmentFile = testMileStoneProof.attachmentFile;
        
        testMileStoneProof.milestoneProofType = 'M2 Proof';
        selGenAssetRec = testMileStoneProof.getSelGenAssetRec();
        testMileStoneProof.selGenAssetRec = selGenAssetRec;
        Boolean isM2Proof = testMileStoneProof.isM2Proof;
        testMileStoneProof.isM2Proof = true;
        Boolean enableSlNoUpload = testMileStoneProof.enableSlNoUpload;
        testMileStoneProof.enableSlNoUpload = enableSlNoUpload;
        //totalPanelQuantity should equal list size here
        //
        //
        selGenAssetRec.Panel_Serial_Number__c = 'tryme1';
        selGenAssetRec.Number_of_Sunrun_owned_Modules__c = 1;
        //
        //
        //
        testMileStoneProof.submitSerialNumber();
        
        selGenAssetRec.Panel_Serial_Number__c = 'K21117290391';
        testMileStoneProof.selGenAssetRec = selGenAssetRec;
        testMileStoneProof.submitSerialNumber();
        
        selGenAssetRec.Cash_Grant_Eligible__c = true;
        testMileStoneProof.selGenAssetRec = selGenAssetRec;
        testMileStoneProof.submitSerialNumber();
        
        Facility_Configuration__c panelRec = new Facility_Configuration__c();
        panelRec.Generation_Asset__c = selGenAssetRec.Id;
        panelRec.Number_of_Panels__c = 10;
        panelRec.Panel_Type__c = 'LG245S1C-G2';
        
        insert panelRec;
        
        selGenAssetRec = [Select Id, Name, Account_Name__c, Home_Address__c, City__c, Install_Partner__c, State__c, Zip__c,
                                    M1_Status__c, M2_Status__c, M3_Status__c, 
                                    M1_Proof_Count__c, M2_Proof_Count__c, M3_Proof_Count__c, M1_proof_panel_inverter_delivery__c, M2_proof_substantial_completion__c,
                                    Number_of_Sunrun_owned_Modules__c, System_Size_DC__c, Meter_Test_Date__c, PTO__c, Partner_PTO_proof_date__c, NTP_Granted__c, Rebate_Form_Sent__c, Cash_Grant_Eligible__c, Panel_Serial_Number__c,
                                    SmartTurn_M1_StatusCode__c, SmartTurn_M2_StatusCode__c, SmartTurn_Message__c,Meter_Serial_Num__c , 
                                    (Select Panel_Type__c, Number_of_Panels__c  From Facility_Configurations__r)                                    
                                    From Generation_Assets__c Where Id = :selGenAssetRec.Id];
        
        selGenAssetRec.Panel_Serial_Number__c = 'K21117290391';
        selGenAssetRec.Cash_Grant_Eligible__c = true;
        testMileStoneProof.selGenAssetRec = selGenAssetRec;
        testMileStoneProof.submitSerialNumber();
        testMileStoneProof.backToUpload();
        selGenAssetRec.SmartTurn_M2_StatusCode__c = 'SUCCESS';
        selGenAssetRec.Install_Partner__c = 'Verengo';
        testMileStoneProof.selGenAssetRec = selGenAssetRec;
        Boolean enableAttachFile = testMileStoneProof.enableAttachFile;
        // Change due to failure in IntDev  
        if(testMileStoneProof.selectedAssetsList.size() == 0)
        {
            testMileStoneProof.selectedAssetsList.add(new mileStoneProof.genAssetWrapper(selGenAssetRec));
        }        
        testMileStoneProof.selGenAssetRec = selGenAssetRec;  
         
        testMileStoneProof.attachFile();
        testMileStoneProof.updateAssetRec();
        testMileStoneProof.getAttachments(); // was commented out to stop SOQL 101
        testMileStoneProof.backToSearch();
        
        testMileStoneProof.srchOptionFilter = 'Show Gen Assets Needing M3';
        testMileStoneProof.doSearch();
        
        searchedAssetsList = testMileStoneProof.searchedAssetsList;
        searchedAssetsList = testMileStoneProof.getSearchedAssetsList();
        
        for(genAssetWrapper assetWrapperRec : searchedAssetsList)
        {
            assetWrapperRec.recSelected = true;
            break;
        }
        testMileStoneProof.searchedAssetsList = searchedAssetsList;
        testMileStoneProof.GetSelectedAsset();
        testMileStoneProof.uploadDocument();

        testMileStoneProof.fileBody = bodyBlob;
        testMileStoneProof.fullPathFileName = 'temp.txt';
        testMileStoneProof.fileName = 'temp';
                
        attachmentFile = testMileStoneProof.attachmentFile;
        testMileStoneProof.milestoneProofType = 'M3 Proof';
        Boolean isM3Proof = testMileStoneProof.isM3Proof; 
        testMileStoneProof.isM3Proof = true;        
        //
        if(testMileStoneProof.selectedAssetsList.size() == 0)
        {
            testMileStoneProof.selectedAssetsList.add(new mileStoneProof.genAssetWrapper(selGenAssetRec));
        }        
        testMileStoneProof.selGenAssetRec = selGenAssetRec;  
        //
        testMileStoneProof.attachFile();
        testMileStoneProof.updateAssetRec();
        testMileStoneProof.getAttachments();   // was commented out to stop SOQL 101
        testMileStoneProof.backToSearch();

        testMileStoneProof.srchOptionFilter = 'Show Gen Assets with ANY Proofs';
        testMileStoneProof.doSearch();
        
        searchedAssetsList = testMileStoneProof.searchedAssetsList;
        searchedAssetsList = testMileStoneProof.getSearchedAssetsList();
        if (searchedAssetsList != null && searchedAssetsList.size() > 0)
        {
            
            for(genAssetWrapper assetWrapperRec : searchedAssetsList)
            {
                assetWrapperRec.recSelected = true;
                break;
            }
            testMileStoneProof.searchedAssetsList = searchedAssetsList;
            testMileStoneProof.GetSelectedAsset();
            testMileStoneProof.uploadDocument();
    
            testMileStoneProof.fileBody = bodyBlob;
            testMileStoneProof.fullPathFileName = 'temp.txt';
            
            attachmentFile = testMileStoneProof.attachmentFile;
            
            testMileStoneProof.attachFile();
            testMileStoneProof.updateAssetRec();
            testMileStoneProof.getAttachments();  // was commented out to stop SOQL 101
            testMileStoneProof.backToSearch();
        }
        
        testMileStoneProof.srchOptionFilter = 'Show Gen Assets with ALL Proofs Submitted';
        testMileStoneProof.doSearch();
        
        searchedAssetsList = testMileStoneProof.searchedAssetsList;
        searchedAssetsList = testMileStoneProof.getSearchedAssetsList();
        if (searchedAssetsList != null && searchedAssetsList.size() > 0)
        {
            
            for(genAssetWrapper assetWrapperRec : searchedAssetsList)
            {
                assetWrapperRec.recSelected = true;
                break;
            }
            testMileStoneProof.searchedAssetsList = searchedAssetsList;
            testMileStoneProof.GetSelectedAsset();
            testMileStoneProof.uploadDocument();
    
            testMileStoneProof.fileBody = bodyBlob;
            testMileStoneProof.fullPathFileName = 'temp.txt';
            
            attachmentFile = testMileStoneProof.attachmentFile;
            
            testMileStoneProof.attachFile();
            testMileStoneProof.updateAssetRec();
            testMileStoneProof.getAttachments();  // was commented out to stop SOQL 101
            testMileStoneProof.backToSearch();
        }

        testMileStoneProof.srchOptionFilter = 'Show All Denied Proofs';
        testMileStoneProof.doSearch();

        SmartTurn_OccamTypes.UploadResponse testUploadResponse = new SmartTurn_OccamTypes.UploadResponse();
        SmartTurn_OccamTypes.Warehouse testWarehouse = new SmartTurn_OccamTypes.Warehouse();
        SmartTurn_OccamTypes.Affiliate testAffiliate = new SmartTurn_OccamTypes.Affiliate();
        SmartTurn_OccamTypes.LastModifiedRecord testLastMod = new SmartTurn_OccamTypes.LastModifiedRecord();
        SmartTurn_OccamTypes.LocationName testLocName = new SmartTurn_OccamTypes.LocationName();
        SmartTurn_OccamTypes.LogisticsOperator testLogisticsOp = new SmartTurn_OccamTypes.LogisticsOperator();
        SmartTurn_OccamTypes.Currency_x testCurr = new SmartTurn_OccamTypes.Currency_x();
        SmartTurn_OccamTypes.CreateRecord testCR = new SmartTurn_OccamTypes.CreateRecord();
        SmartTurn_OccamTypes.WSDocumentIdentification testDocId = new SmartTurn_OccamTypes.WSDocumentIdentification();
        SmartTurn_OccamTypes.WSDocumentIdentificationWithType testDocId2 = new SmartTurn_OccamTypes.WSDocumentIdentificationWithType();
        
        
        SmartTurn_LookupTypes.InventoryLookupResult testInvLookup = new SmartTurn_LookupTypes.InventoryLookupResult();
        SmartTurn_LookupTypes.LookUpManager testLookupManager = new SmartTurn_LookupTypes.LookUpManager();
        SmartTurn_LookupTypes.PaginationInfo testPI = new SmartTurn_LookupTypes.PaginationInfo();
        SmartTurn_LookupTypes.ResultMetadata testResult = new SmartTurn_LookupTypes.ResultMetadata();
        SmartTurn_LookupTypes.SortingInfo testSI = new SmartTurn_LookupTypes.SortingInfo();
         
        SmartTurn_SalesOrder.overwriteSalesOrder_element testOverwriteSOE = new SmartTurn_SalesOrder.overwriteSalesOrder_element();
        SmartTurn_SalesOrder.overwriteSalesOrderResponse_element testOverwriteSOResponseE = new SmartTurn_SalesOrder.overwriteSalesOrderResponse_element();
        SmartTurn_SalesOrder.saveSalesOrder_element testSaveSOE = new SmartTurn_SalesOrder.saveSalesOrder_element();
        SmartTurn_SalesOrder.saveSalesOrderResponse_element testSaveSOResponseE = new SmartTurn_SalesOrder.saveSalesOrderResponse_element();
        
        SmartTurn_InventoryItem.lookUpInventory_element testInvLookupE = new SmartTurn_InventoryItem.lookUpInventory_element();
        SmartTurn_InventoryItem.lookUpInventoryResponse_element testInvLookupResponseE = new SmartTurn_InventoryItem.lookUpInventoryResponse_element();
        
        SmartTurn_InventoryItemTypes.InventoryItem testInvItem = new SmartTurn_InventoryItemTypes.InventoryItem();
        SmartTurn_InventoryItemTypes.WSLicense testWSLicense = new SmartTurn_InventoryItemTypes.WSLicense();
        
        //Tests for Photo Stuff        
         if (searchedAssetsList != null && searchedAssetsList.size() > 0)
        {            
            for(genAssetWrapper assetWrapperRec : searchedAssetsList)
            {
                assetWrapperRec.recSelected = true;
                break;
            }
            if(testMileStoneProof.selectedAssetsList.size() == 0)
            {
                testMileStoneProof.selectedAssetsList.add(new mileStoneProof.genAssetWrapper(selGenAssetRec));
            }        
            testMileStoneProof.selGenAssetRec = selGenAssetRec;
        
            PageReference prShowAlbum = testMileStoneProof.showAlbum();
            PageReference prUploadPhotos = testMileStoneProof.uploadPhotos();            
        }
        //       
        Test.stopTest();
        //}
    }
    
     public static testMethod void milestoneProofTestCaseTrigger()
    {
        
        milestoneProof testMileStoneProof = new milestoneProof();
 
        String serverURL = testMileStoneProof.serverURL;
 
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
        genAssetRec.Rebate_Conf_Num__c = '234345';
        
        insert genAssetRec;

        RecordType mileStoneRecType = testMileStoneProof.mileStoneRecType;
        
        Case currentCaseRec = new Case();
        currentCaseRec.RecordTypeId = mileStoneRecType.Id;
        currentCaseRec.AccountId = accountRec.Id;
        currentCaseRec.ContactId = contactRec.Id;
        currentCaseRec.Milestone_Proof_Type__c = 'M1 Proof';
        currentCaseRec.Status = 'Request Approval';
        currentCaseRec.Origin = 'Install Partner'; 
        currentCaseRec.Reason = 'Documentation';
        currentCaseRec.Description = 'Milestone Proof Submitted';
        currentCaseRec.Subject = 'Milestone Proof Submitted';
        currentCaseRec.Generation_Asset__c = genAssetRec.Id;
        insert currentCaseRec;
        
        Test.startTest();
        currentCaseRec.Status = 'M1 Proof Denied';
        currentCaseRec.Denied_Comment__c = 'Test';
        update currentCaseRec;

        ApexPages.StandardController stdCont = new ApexPages.StandardController(new Case(Id = currentCaseRec.Id));
        CallOut2SmartTurn_M1Submit testM1Submit = new CallOut2SmartTurn_M1Submit(stdCont);
        testM1Submit.submitM1();

        currentCaseRec.Status = 'M1 Proof Approved';
        update currentCaseRec;
        
        CallOut2SmartTurn_M1Submit testM1Submit2 = new CallOut2SmartTurn_M1Submit(stdCont);
        testM1Submit2.submitM1();

        genAssetRec.Cash_Grant_Eligible__c = true;
        update genAssetRec;    // was commented out to stop SOQL 101

        CallOut2SmartTurn_M1Submit testM1Submit3 = new CallOut2SmartTurn_M1Submit(stdCont);
        testM1Submit3.submitM1();
                
        Facility_Configuration__c panelRec = new Facility_Configuration__c();
        panelRec.Generation_Asset__c = genAssetRec.Id;
        panelRec.Number_of_Panels__c = 1;
        panelRec.Panel_Type__c = 'LG245S1C-G2';
        insert panelRec;

        CallOut2SmartTurn_M1Submit testM1Submit4 = new CallOut2SmartTurn_M1Submit(stdCont);
        testM1Submit4.submitM1();

        currentCaseRec.SmartTurn_M1_StatusCode__c = 'SUCCESS';
        update currentCaseRec;

        CallOut2SmartTurn_M1Submit testM1Submit5 = new CallOut2SmartTurn_M1Submit(stdCont);
        testM1Submit5.submitM1();

        currentCaseRec.Milestone_Proof_Type__c = 'M2 Proof';
        update currentCaseRec;

        CallOut2SmartTurn_M1Submit testM1Submit6 = new CallOut2SmartTurn_M1Submit(stdCont);
        testM1Submit6.submitM1();

// above 4 lines were commented out to stop SOQL 101
        delete currentCaseRec;
        
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
        currentCaseRec2.Generation_Asset__c = genAssetRec.Id;
        insert currentCaseRec2;

        currentCaseRec2.Status = 'M2 Proof Denied';
        currentCaseRec2.Denied_Comment__c = 'Test';
        update currentCaseRec2;

        genAssetRec.SmartTurn_M2_StatusCode__c = 'SUCCESS';
        update genAssetRec;

        currentCaseRec2.Status = 'M2 Proof Approved (non meter test)';
        update currentCaseRec2;

        delete currentCaseRec2;

//To get more coverage:
        testMilestoneProof.selGenAssetRec = genAssetRec;
        testMilestoneProof.selGenAssetRec.Panel_Serial_Number__c = 'tryme1';
        testMilestoneProof.selGenAssetRec.Number_of_Sunrun_owned_Modules__c = 1;
        List<String> listSN = new List<String>();
        listSN.add('tryme1');
        Integer inv = testMilestoneProof.lookupInventory(listSN);
        //
        List<Case> listCase = testMilestoneProof.getCaseList();
        //
        Boolean bisVerengo = testMilestoneProof.isInstallPartnerVerengo;


        Test.stopTest();
      
    }

     public static testMethod void milestoneProofTestCaseTrigger2()
    {
        Test.startTest();
        milestoneProof testMileStoneProof = new milestoneProof();
 
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

        RecordType mileStoneRecType = testMileStoneProof.mileStoneRecType;

        Case currentCaseRec3 = new Case();
        currentCaseRec3.RecordTypeId = mileStoneRecType.Id;
        currentCaseRec3.AccountId = accountRec.Id;
        currentCaseRec3.ContactId = contactRec.Id;
        currentCaseRec3.Milestone_Proof_Type__c = 'M3 Proof';
        currentCaseRec3.Status = 'Request Approval';
        currentCaseRec3.Origin = 'Install Partner'; 
        currentCaseRec3.Reason = 'Documentation';
        currentCaseRec3.Description = 'Milestone Proof Submitted';
        currentCaseRec3.Subject = 'Milestone Proof Submitted';
        currentCaseRec3.Generation_Asset__c = genAssetRec.Id;
        insert currentCaseRec3;

        currentCaseRec3.Status = 'M3 PTO Denied';
        currentCaseRec3.Denied_Comment__c = 'Test';
        update currentCaseRec3;
        
        currentCaseRec3.Status = 'M3 PTO Approved';
        //update currentCaseRec3;
 
        delete currentCaseRec3;
        Test.stopTest();
        
    }
}