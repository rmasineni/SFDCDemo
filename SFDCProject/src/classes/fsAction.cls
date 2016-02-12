public with sharing class fsAction 
{
	public final FS_Action__c editFSAction;
	public FS_Action_Code__c actionCodeRec {get;set;}
	public FS_Component_Code__c componentCodeRec {get;set;}
	
	public fsAction (ApexPages.StandardController stdController)
	{
		this.editFSAction = (FS_Action__c)stdController.getRecord();
	}


	public FS_Action__c fsActionRec
    {
        get{
            
	        if (fsActionRec == null)
    		{
				if (editFSAction.Id != null)
				{
	    			String sqlQueryFields = getFSActionFields();
	    			String sqlQuery = 'Select ' + sqlQueryFields + ' From FS_Action__c Where Id = ' + '\'' + String.escapeSingleQuotes(editFSAction.Id) + '\'';
	            	fsActionRec = Database.query(sqlQuery);
	            	refreshSectionHeaders();
				}
				else
				{
					fsActionRec = new 	FS_Action__c();
//					FS_Dispatch__c dispatchRec = [select Id from FS_Dispatch__c Where id = :ApexPages.currentPage().getParameters().get('CF00NR0000000zwpj_lkid')];
					FS_Dispatch__c dispatchRec = [select Id from FS_Dispatch__c Where id = :editFSAction.FS_Dispatch__c];
					fsActionRec.FS_Dispatch__c = dispatchRec.Id;
				}
	            	
    		}
            return fsActionRec;            
        }
        set;
    }
	
    public String informationSectionHdr
    {
        get{
            informationSectionHdr = 'Information -  REQUIRED FIELDS: Action Code, Component Code';
            return informationSectionHdr;            
        }
        set;
    }

	public PageReference refreshSectionHeaders()
	{
		if (fsActionRec.FS_Action_Code__c != null)
		{
			actionCodeRec = [Select FS_Get_Old_Info__c, FS_Get_New_Info__c, FS_Get_Hours_Info__c, FS_Get_Dollars_Info__c From FS_Action_Code__c 
								Where FS_Act_Code_Active__c = true And Id = :fsActionRec.FS_Action_Code__c];
		}							

		if (fsActionRec.FS_Component_Code__c != null)
		{
			componentCodeRec = [Select FS_Get_Signal_Strength__c, FS_Get_Serial__c, FS_Get_Model__c, FS_Get_Manufacturer__c, 
									FS_Get_KwH__c, FS_Get_Desc__c, FS_GET_Qty__c, 
									FS_Get_Signal_Strength_Code__c, FS_Get_Voltage_Test__c From FS_Component_Code__c
								Where FS_Component_Active__c = true And Id = :fsActionRec.FS_Component_Code__c];
		}
		return null;
	}

    public String addDetailsSectionHdr
    {
        get{
            addDetailsSectionHdr = 'Additional Details ' ;
            if (actionCodeRec != null || componentCodeRec != null)
            {
            	addDetailsSectionHdr += ' - REQUIRED FIELDS: ';
            	
            	String strFields = '';
            	if (actionCodeRec != null)
            	{
            		if (actionCodeRec.FS_Get_Dollars_Info__c)
            		{
            			if (strFields == '')
            			{
            				strFields = 'Material Cost';
            			}
            			else
            			{
            				strFields += ', Material Cost';
            			}
            		}
            		if (actionCodeRec.FS_Get_Hours_Info__c)
            		{
            			if (strFields == '')
            			{
            				strFields = 'Labor Hours';
            			}
            			else
            			{
            				strFields += ', Labor Hours';
            			}
            		}
            	}
            	if (componentCodeRec != null)
            	{
            		if (componentCodeRec.FS_GET_Qty__c)
            		{
            			if (strFields == '')
            			{
            				strFields = 'Quantity';
            			}
            			else
            			{
            				strFields += ', Quantity';
            			}
            		}
            		if (componentCodeRec.FS_Get_Desc__c)
            		{
            			if (strFields == '')
            			{
            				strFields = 'Notes';
            			}
            			else
            			{
            				strFields += ', Notes';
            			}
            		}
/*
            		if (componentCodeRec.FS_Get_Signal_Strength_Code__c)
            		{
            			if (strFields == '')
            			{
            				strFields = 'Energy Reading(kWh)';
            			}
            			else
            			{
            				strFields += ', Energy Reading(kWh)';
            			}
            		}
*/            		
            		if (componentCodeRec.FS_Get_Voltage_Test__c)
            		{
            			if (strFields == '')
            			{
            				strFields = 'Voltage Test';
            			}
            			else
            			{
            				strFields += ', Voltage Test';
            			}
            		}
            	}
            	addDetailsSectionHdr += strFields;
            }
            return addDetailsSectionHdr;            
        }
        set;
    }

    public String oldComponentSectionHdr
    {
        get{
            oldComponentSectionHdr = 'Existing or Removed Component Details';
            if (actionCodeRec != null && componentCodeRec != null)
            {
	            String strFields = '';
	            if (actionCodeRec.FS_Get_Old_Info__c)
	            {
            		if (componentCodeRec.FS_Get_Manufacturer__c)
            		{
            			if (strFields == '')
            			{
            				strFields = 'Manufacturer';
            			}
            			else
            			{
            				strFields += ', Manufacturer';
            			}
            		}
            		if (componentCodeRec.FS_Get_Model__c)
            		{
            			if (strFields == '')
            			{
            				strFields = 'Model';
            			}
            			else
            			{
            				strFields += ', Model';
            			}
            		}
            		if (componentCodeRec.FS_Get_Serial__c)
            		{
            			if (strFields == '')
            			{
            				strFields = 'Serial Number';
            			}
            			else
            			{
            				strFields += ', Serial Number';
            			}
            		}
            		if (componentCodeRec.FS_Get_KwH__c)
            		{
            			if (strFields == '')
            			{
            				strFields = 'KwHr Reading';
            			}
            			else
            			{
            				strFields += ', KwHr Reading';
            			}
            		}
            		if (componentCodeRec.FS_Get_Signal_Strength__c)
            		{
            			if (strFields == '')
            			{
            				strFields = 'Signal Strength';
            			}
            			else
            			{
            				strFields += ', Signal Strength';
            			}
            		}
		            if (strFields != '')
		            {
			            oldComponentSectionHdr += ' - REQUIRED FIELDS: ' + strFields;
		            }
	            }
            }


            return oldComponentSectionHdr;            
        }
        set;
    }
    
    public String newComponentSectionHdr
    {
        get{
            newComponentSectionHdr = 'New or Replacement Component ';
            if (actionCodeRec != null && componentCodeRec != null)
            {
	            String strFields = '';
	            if (actionCodeRec.FS_Get_New_Info__c)
	            {
            		if (componentCodeRec.FS_Get_Manufacturer__c)
            		{
            			if (strFields == '')
            			{
            				strFields = 'Manufacturer';
            			}
            			else
            			{
            				strFields += ', Manufacturer';
            			}
            		}
            		if (componentCodeRec.FS_Get_Model__c)
            		{
            			if (strFields == '')
            			{
            				strFields = 'Model';
            			}
            			else
            			{
            				strFields += ', Model';
            			}
            		}
            		if (componentCodeRec.FS_Get_Serial__c)
            		{
            			if (strFields == '')
            			{
            				strFields = 'Serial Number';
            			}
            			else
            			{
            				strFields += ', Serial Number';
            			}
            		}
            		if (componentCodeRec.FS_Get_KwH__c)
            		{
            			if (strFields == '')
            			{
            				strFields = 'KwHr Reading';
            			}
            			else
            			{
            				strFields += ', KwHr Reading';
            			}
            		}
            		if (componentCodeRec.FS_Get_Signal_Strength__c)
            		{
            			if (strFields == '')
            			{
            				strFields = 'Signal Strength';
            			}
            			else
            			{
            				strFields += ', Signal Strength';
            			}
            		}
		            if (strFields != '')
		            {
			            newComponentSectionHdr += ' - REQUIRED FIELDS: ' + strFields;
		            }
	            }
            }
            return newComponentSectionHdr;            
        }
        set;
    }
    
	public String getFSActionFields() 
	{   
		String qryFields = '';
		List<SelectOption> options = new List<SelectOption>();   
		Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
		Schema.SObjectType fsActionSchema = schemaMap.get('FS_Action__c');
		Map<String, Schema.SObjectField> fieldMap = fsActionSchema.getDescribe().fields.getMap();
		for (String fieldName: fieldMap.keySet()) 
		{    
			if (qryFields == '')
			{
				qryFields = fieldName;
			}
			else
			{
				qryFields = qryFields + ',' + fieldName; 
			}
		}   
		return qryFields;
	}

 	public List<SelectOption> getActionCode() 
    {
		List<SelectOption> options = new List<SelectOption>();
		for (FS_Action_Code__c actionCode : [select Id, Name from FS_Action_Code__c where FS_Act_Code_Active__c = true Order by Name] )
		{
			options.add(new SelectOption(actionCode.Id,actionCode.Name));
		}
        return options;    
    }	

 	public List<SelectOption> getComponentCode() 
    {
		List<SelectOption> options = new List<SelectOption>();
		for (FS_Component_Code__c componentCode : [select Id, Name from FS_Component_Code__c where FS_Component_Active__c = true Order by Name] )
		{
			options.add(new SelectOption(componentCode.Id,componentCode.Name));
		}
		return options;    
    }	
	
	public PageReference save() 
	{
		try
		{
			if (fsActionRec.Id == null)
			{
				insert fsActionRec;
			}
			else
			{
				update fsActionRec;
			}
			FS_Dispatch__c fsDispatchRec = [Select Id From FS_Dispatch__c Where Id = :fsActionRec.FS_Dispatch__c];
	        PageReference fsDispatchPage = new ApexPages.StandardController(fsDispatchRec).view();
	        fsDispatchPage.setRedirect(true);
	        return fsDispatchPage;
			
//	        PageReference fsActionPage = new ApexPages.StandardController(fsActionRec).view();
//	        fsActionPage.setRedirect(true);
		}
		catch(Exception ex)
		{
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,ex.getMessage()));
			return null;
		}
	}	

/*
	public PageReference saveAndNew() 
	{
		try
		{
			if (fsActionRec.Id == null)
			{
				insert fsActionRec;
			}
			else
			{
				update fsActionRec;
			}
			system.debug('RAJU');
			FS_Action__c newFSActionRec = new FS_Action__C();
	        PageReference fsActionPage = new ApexPages.StandardController(newFSActionRec).edit();
	        fsActionPage.setRedirect(true);
	        return fsActionPage;
		}
		catch(Exception ex)
		{
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,ex.getMessage()));
			return null;
		}
	}	
*/	
    public static testMethod void fsActionTest()
    {
        Test.startTest();

        FS_Action_Code__c actionCodeRec1 = new FS_Action_Code__c();
        actionCodeRec1.FS_Act_Code_Active__c = true;
        actionCodeRec1.Name = 'Test2';
        actionCodeRec1.FS_Get_Hours_Info__c = true;
        actionCodeRec1.FS_Get_New_Info__c = true;
        actionCodeRec1.FS_Get_Old_Info__c = true;
        insert actionCodeRec1;
        
        FS_Component_Code__c componentCodeRec1 = new FS_Component_Code__c();
        componentCodeRec1.FS_Component_Active__c = true;
        componentCodeRec1.Name = 'Test2';
        componentCodeRec1.FS_Get_Manufacturer__c = true;
        insert componentCodeRec1;
        
        FS_Dispatch__c fsDispatchRec = new FS_Dispatch__c();
        insert fsDispatchRec;
        
        FS_Action__c fsActionRec = new FS_Action__c();
        fsActionRec.FS_Dispatch__c = fsDispatchRec.Id;
		fsActionRec.FS_Action_Code__c = actionCodeRec1.Id;
		fsActionRec.FS_Component_Code__c = componentCodeRec1.Id;
        fsActionRec.FS_Amount__c = 1.00;
        fsActionRec.FS_Hours__c = 1;
        fsActionRec.FS_New_Unit_Manufacturer__c = 'Test';
        fsActionRec.FS_Old_Unit_Manufacturer__c = 'Test';
        insert fsActionRec;
        
        ApexPages.StandardController stdCont = new ApexPages.StandardController(new FS_Action__c(Id = fsActionRec.Id));
        fsAction testFSAction = new fsAction(stdCont);
        FS_Action__c testFSActionRec = testFSAction.fsActionRec;
        testFSAction.refreshSectionHeaders();
	 																				        		
		testFSAction.getActionCode();
		testFSAction.getComponentCode();
		testFSAction.getFSActionFields();

        String informationSectionHdr = testFSAction.informationSectionHdr;
        String addDetailsSectionHdr = testFSAction.addDetailsSectionHdr;
        String oldComponentSectionHdr = testFSAction.oldComponentSectionHdr;
        String newComponentSectionHdr = testFSAction.newComponentSectionHdr;
        
        FS_Action_Code__c actionCodeRec2 = new FS_Action_Code__c();
        actionCodeRec2.FS_Act_Code_Active__c = true;
        actionCodeRec2.Name = 'Test2';
        actionCodeRec2.FS_Get_Hours_Info__c = true;
        actionCodeRec2.FS_Get_New_Info__c = true;
        actionCodeRec2.FS_Get_Old_Info__c = true;
        insert actionCodeRec2;
        
        FS_Component_Code__c componentCodeRec2 = new FS_Component_Code__c();
        componentCodeRec2.FS_Component_Active__c = true;
        componentCodeRec2.Name = 'Test2';
        componentCodeRec2.FS_Get_Manufacturer__c = true;
        insert componentCodeRec2;
        
        testFSActionRec.FS_Action_Code__c = actionCodeRec2.Id;
        testFSActionRec.FS_Component_Code__c = componentCodeRec2.Id;
		testFSAction.refreshSectionHeaders();		 																				        		
        informationSectionHdr = testFSAction.informationSectionHdr;
        addDetailsSectionHdr = testFSAction.addDetailsSectionHdr;
        oldComponentSectionHdr = testFSAction.oldComponentSectionHdr;
        newComponentSectionHdr = testFSAction.newComponentSectionHdr;
		testFSAction.save();

        FS_Component_Code__c componentCodeRec3 = new FS_Component_Code__c();
        componentCodeRec3.FS_Component_Active__c = true;
        componentCodeRec3.Name = 'Test2';
        componentCodeRec3.FS_Get_Model__c = true;
        insert componentCodeRec3;
        
        testFSActionRec.FS_Component_Code__c = componentCodeRec3.Id;
		testFSAction.refreshSectionHeaders();		 																				        		
        informationSectionHdr = testFSAction.informationSectionHdr;
        addDetailsSectionHdr = testFSAction.addDetailsSectionHdr;
        oldComponentSectionHdr = testFSAction.oldComponentSectionHdr;
        newComponentSectionHdr = testFSAction.newComponentSectionHdr;

        FS_Component_Code__c componentCodeRec4 = new FS_Component_Code__c();
        componentCodeRec4.FS_Component_Active__c = true;
        componentCodeRec4.Name = 'Test2';
        componentCodeRec4.FS_Get_Serial__c = true;
        testFSActionRec.FS_Component_Code__c = componentCodeRec4.Id;
		insert componentCodeRec4;
		
		testFSAction.refreshSectionHeaders();		 																				        		
        informationSectionHdr = testFSAction.informationSectionHdr;
        addDetailsSectionHdr = testFSAction.addDetailsSectionHdr;
        oldComponentSectionHdr = testFSAction.oldComponentSectionHdr;
        newComponentSectionHdr = testFSAction.newComponentSectionHdr;

        FS_Component_Code__c componentCodeRec5 = new FS_Component_Code__c();
        componentCodeRec5.FS_Component_Active__c = true;
        componentCodeRec5.Name = 'Test2';
        componentCodeRec5.FS_Get_Signal_Strength__c = true;
		insert componentCodeRec5;

        testFSActionRec.FS_Component_Code__c = componentCodeRec5.Id;
		testFSAction.refreshSectionHeaders();		 																				        		
        informationSectionHdr = testFSAction.informationSectionHdr;
        addDetailsSectionHdr = testFSAction.addDetailsSectionHdr;
        oldComponentSectionHdr = testFSAction.oldComponentSectionHdr;
        newComponentSectionHdr = testFSAction.newComponentSectionHdr;
        
        FS_Component_Code__c componentCodeRec6 = new FS_Component_Code__c();
        componentCodeRec6.FS_Component_Active__c = true;
        componentCodeRec6.Name = 'Test2';
        componentCodeRec6.FS_Get_KwH__c = true;
        insert componentCodeRec6;
        
        testFSActionRec.FS_Component_Code__c = componentCodeRec6.Id;
		testFSAction.refreshSectionHeaders();		 																				        		
        informationSectionHdr = testFSAction.informationSectionHdr;
        addDetailsSectionHdr = testFSAction.addDetailsSectionHdr;
        oldComponentSectionHdr = testFSAction.oldComponentSectionHdr;
        newComponentSectionHdr = testFSAction.newComponentSectionHdr;

        FS_Component_Code__c componentCodeRec7 = new FS_Component_Code__c();
        componentCodeRec7.FS_Component_Active__c = true;
        componentCodeRec7.Name = 'Test2';
        componentCodeRec7.FS_Get_Desc__c = true;
        insert componentCodeRec7;

        FS_Component_Code__c componentCodeRec8 = new FS_Component_Code__c();
        componentCodeRec8.FS_Component_Active__c = true;
        componentCodeRec8.Name = 'Test2';
        componentCodeRec8.FS_GET_Qty__c = true;
        insert componentCodeRec8;
        
        actionCodeRec2.FS_Get_Dollars_Info__c = false;
        actionCodeRec2.FS_Get_Hours_Info__c = false;
        update actionCodeRec2;
        
        testFSActionRec.FS_Action_Code__c = actionCodeRec2.Id;
        testFSActionRec.FS_Component_Code__c = componentCodeRec8.Id;
		testFSAction.refreshSectionHeaders();		 																				        		
        informationSectionHdr = testFSAction.informationSectionHdr;
        addDetailsSectionHdr = testFSAction.addDetailsSectionHdr;
        oldComponentSectionHdr = testFSAction.oldComponentSectionHdr;
        newComponentSectionHdr = testFSAction.newComponentSectionHdr;
        
        componentCodeRec8.FS_Get_Desc__c = true;
        componentCodeRec8.FS_GET_Qty__c = false;
        update componentCodeRec8;

        testFSActionRec.FS_Component_Code__c = componentCodeRec8.Id;
		testFSAction.refreshSectionHeaders();		 																				        		
        informationSectionHdr = testFSAction.informationSectionHdr;
        addDetailsSectionHdr = testFSAction.addDetailsSectionHdr;
        oldComponentSectionHdr = testFSAction.oldComponentSectionHdr;
        newComponentSectionHdr = testFSAction.newComponentSectionHdr;
        

        FS_Action__c fsActionRec2 = new FS_Action__c();
        fsActionRec2.FS_Dispatch__c = fsDispatchRec.Id;
		fsActionRec2.FS_Action_Code__c = actionCodeRec1.Id;
		fsActionRec2.FS_Component_Code__c = componentCodeRec1.Id;
        fsActionRec2.FS_Amount__c = 1.00;
        fsActionRec2.FS_Hours__c = 1;
        fsActionRec2.FS_New_Unit_Manufacturer__c = 'Test';
        fsActionRec2.FS_Old_Unit_Manufacturer__c = 'Test';

		stdCont = new ApexPages.StandardController(fsActionRec2);
        fsAction testFSAction2 = new fsAction(stdCont);
        testFSAction2.refreshSectionHeaders();
		testFSAction2.save();
        Test.stopTest();
    }	
}