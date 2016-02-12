@ isTest (seeAllData = true)
public class testWfObjectFieldCompController {

    public static testmethod void wfObjectFieldCompController_test(){
                
            project_template__c prjTemplate = new project_template__c ( name = 'test project Template', Type__c= 'Direct' , Start_Date__c= Date.Today(), End_Date__c =Date.Today().addDays(18)); 
            insert prjTemplate;
            
            Phase_Template__c phaseTemplate = new phase_Template__c( name = 'Project Initiation' , Project_Template__c = prjTemplate.id, Phase_Number__c = '1.0', Start_Date__c= Date.Today(), End_Date__c =Date.Today().addDays(18) );
            insert phaseTemplate;
            
            Task_Template__c taskTemplate = new Task_Template__c( name = 'Verification Call' , Project_Template2__c = prjTemplate.id, Phase_Template__c = phaseTemplate.id, Group_Name__c = 'Barnch Manager',
                                                     Category__c= 'Required', Type__c = 'Standdard', SLA_In_Hours__c = 40 ,Start_Date__c= Date.Today(), End_Date__c =Date.Today().addDays(18) );
            insert taskTemplate;
            
        
            system.debug(logginglevel.WARN, 'YOUR tmpltId' +  taskTemplate.id);
            
            ApexPages.currentPage().getParameters().put('id',taskTemplate.id);
            wfTaskObjFeildCmpController  obj1 = new wfTaskObjFeildCmpController();
            system.debug(logginglevel.WARN, 'YOUR VARIABLENAME' + obj1.id);
            System.debug('>> Id' + obj1.id);
            obj1.showDataType = true;
            obj1.editRecord();
            obj1.getObjectNames();
            obj1.getFieldNames1();
            obj1.getFieldNames2();
            obj1.getFieldNames3();
            obj1.getFieldNames4();
            obj1.getFieldNames5();
        	obj1.object1 = 'Account';
            obj1.object2 = 'Opportunity';
            obj1.object3 = 'Contact';
            obj1.object4 = 'Lead';
            obj1.object5 = '';
            obj1.field1 = 'Account Number';
            obj1.field2 = 'Project Planner';
            obj1.field3 = 'Address';
            obj1.field4 = 'HOA';
            obj1.field5 = '';
        	obj1.req1 = true;
            obj1.req2 = false;
            obj1.req3 = false;
            obj1.req4 = true;
            obj1.req5 = false;
        	obj1.SaveOption = 'Default';
           /*obj1.getfieldDataType1();
            obj1.getfieldDataType2();
            obj1.getfieldDataType3();
            obj1.getfieldDataType4();
            obj1.getfieldDataType5();*/

        	
         obj1.customSave();
      
		system.assertEquals('Account', obj1.tskObj.Object_Name1__c) ; 
        system.assertEquals('Opportunity', obj1.tskObj.Object_Name2__c) ; 
        system.assertEquals('Contact', obj1.tskObj.Object_Name3__c) ; 
        system.assertEquals('Lead', obj1.tskObj.Object_Name4__c) ; 
        system.assertEquals('', obj1.tskObj.Object_Name5__c) ; 
        system.assertEquals('Account Number', obj1.tskObj.Field_Name1__c) ; 
        system.assertEquals('Project Planner', obj1.tskObj.Field_Name2__c) ; 
        system.assertEquals('Address', obj1.tskObj.Field_Name3__c) ; 
        system.assertEquals('HOA', obj1.tskObj.Field_Name4__c) ; 
        system.assertEquals('', obj1.tskObj.Field_Name5__c) ; 
        system.assertEquals(true, obj1.tskObj.Req1__c) ; 
        system.assertEquals(false, obj1.tskObj.Req2__c) ;
        system.assertEquals(false, obj1.tskObj.Req3__c) ;
        system.assertEquals(true, obj1.tskObj.Req4__c) ;
        system.assertEquals(false, obj1.tskObj.Req5__c) ; 
        
        obj1.showDataType = false;
        obj1.editRecord();
        
        obj1.getObjectNames();
        	obj1.getFieldNames1();
        	obj1.getFieldNames2();
            obj1.getFieldNames3();
            obj1.getFieldNames4();
            obj1.getFieldNames5();
        	obj1.object1 = 'Account';
            obj1.object2 = 'Opportunity';
            obj1.object3 = 'Contact';
            obj1.object4 = 'Lead';
            obj1.object5 = '';
            obj1.field1 = 'Account Number';
            obj1.field2 = 'Project Planner';
            obj1.field3 = 'Address';
            obj1.field4 = 'HOA';
            obj1.field5 = '';
        	obj1.req1 = true;
            obj1.req2 = false;
            obj1.req3 = false;
            obj1.req4 = true;
            obj1.req5 = false;
        	obj1.showDataType = false;
        	obj1.SaveOption = 'Display';
         	obj1.customSave();
        
		/*system.assertEquals('Account', obj1.tskObj.Display_Object1__c) ; 
        system.assertEquals('Opportunity', obj1.tskObj.Display_Object2__c) ; 
        system.assertEquals('Contact', obj1.tskObj.Display_Object3__c) ; 
        system.assertEquals('Lead', obj1.tskObj.Display_Object4__c) ; 
        system.assertEquals('', obj1.tskObj.Display_Object5__c) ; 
        system.assertEquals('Account Number', obj1.tskObj.Display_Field1__c) ; 
        system.assertEquals('Project Planner', obj1.tskObj.Display_Field2__c) ; 
        system.assertEquals('Address', obj1.tskObj.Display_Field3__c) ; 
        system.assertEquals('HOA', obj1.tskObj.Display_Field4__c) ; 
        system.assertEquals('', obj1.tskObj.Display_Field5__c) ;  */
       
         obj1.editRecord();
         obj1.cancel(); 
                    
       }  
    

}