public with sharing class wfTaskObjFeildCmpController  {

//'Service_Contract_Partner_Rel__c',
    set<string> objectNames = new set<string>{'history','tag','share','feed'};
    set<string> myObjectNames = new set<string>{'Account','Contact','Lead','Opportunity','ServiceContract','Service_Contract_Event__c','Proposal__c','Project__c','Service_Contract_Partner_Rel__c'};
    public string req {get; set;}
    public Integer RowNum {get;set;}
    public string field1 {get;set;}
    public string field2 {get;set;}
    public string field3 {get;set;}
    public string field4 {get;set;}
    public string field5 {get;set;}
    public string object1 {get;set;} 
    public string object2 {get;set;}
    public string object3 {get;set;}
    public string object4 {get;set;}
    public string object5 {get;set;}
    public string dataType1 {get;set;}
    public string dataType2 {get;set;}
    public string dataType3 {get;set;}
    public string dataType4 {get;set;}
    public string dataType5 {get;set;}
    Map<String, Schema.SObjectType> allObjects;
    public boolean editMode {get;set;}
     public Boolean req1 {get;set;}
    public Boolean req2 {get;set;}
    public Boolean req3 {get;set;}
    public Boolean req4 {get;set;}
    public Boolean req5 {get;set;}
    public boolean showDataType {get;set;}
    public string SaveOption{get;set;}
     public Task_Template__c tskObj{get;set;}
     public ID id;
     private ApexPages.StandardController sController;
     public integer numOfRows {get;set;}
     
     public wfTaskObjFeildCmpController () {
         numOfRows = 2;
         /*
        object1 = 'Account';
        field1 = 'Name';
        object2 = 'Account';
        field2 = 'Name';
        object3 = 'Account';
        field3 = 'Name';
        object4 = 'Account';
        field4 = 'Name';
        object5 = 'Account';
        field5 = 'Name';
        */

        object1 = '';
        field1 = '';
        object2 = '';
        field2 = '';
        object3 = '';
        field3 = '';
        object4 = '';
        field4 = '';
        object5 = '';
        field5 = ''; 
        
        req1= false;
        req2= false;
        req3= false;
        req4= false;
        req5= false; 
        
        editMode = false;
        SaveOption = 'Default';
        showDataType = true;
       
        //this.sController = controller;
       // this.tskObj = (Task_Template__c )controller.getRecord();
         id = ApexPages.currentPage().getParameters().get('id');
        tskObj =  [SELECT Id, Name, Object_Name1__c ,Object_Name2__c ,Object_Name3__c ,Object_Name4__c ,Object_Name5__c ,Field_Name1__c,Field_Name2__c,Field_Name3__c, 
                    Field_Name4__c, Field_Name5__c,DataType1__c,DataType2__c,DataType3__c,DataType4__c,DataType5__c, Req1__c, Req2__c,Req3__c,Req4__c,Req5__c, Display_Object1__c, 
                   Display_Object2__c,Display_Object3__c,Display_Object4__c, Display_Object5__c, Display_Field1__c, Display_Field2__c, Display_Field3__c,Display_Field4__c,
                   Display_Field5__c FROM Task_Template__c 
                    WHERE Id = :id LIMIT 1];
        if(tskObj != null){
        System.debug('>>>>>>>>>>>>>>showdatatype'+showDataType);
       
        }

          List <string> objNamesList = new List < String> {tskObj.Object_Name1__c ,tskObj.Object_Name2__c ,tskObj.Object_Name3__c ,tskObj.Object_Name4__c ,tskObj.Object_Name5__c } ;
        System.debug('>>>>>>>>> objNamesList' + objNamesList);
        allObjects = Schema.getGlobalDescribe();
       // obj = 
        map<string,DisplayFieldSettings__c> tskProp = DisplayFieldSettings__c.getAll();
        system.debug('>>>>>>>>> Task Template Name ' + tskobj.name);
       if(tskProp.containsKey(tskObj.name) && tskProp.get(tskObj.name) != null){
             numOfRows =  integer.valueOf(tskProp.get(tskObj.name).Number_of_Fields__c);
             system.debug('>>>>>>>>> Number of rows ' + numOfRows );
       }
       else {
            numOfRows = 5;
       }
    }
    
     public list<selectOption> getFieldNames1(){    
       return selectOptionsFromSet(object1);
    }
    
    public list<selectOption> getFieldNames2(){    
        return selectOptionsFromSet(object2);
    }
    
    public list<selectOption> getFieldNames3(){    
        return selectOptionsFromSet(object3);
    }
    
    public list<selectOption> getFieldNames4(){    
        return selectOptionsFromSet(object4);
    }
    
    public list<selectOption> getFieldNames5(){    
        return selectOptionsFromSet(object5);
    }
  /*  
    public string getfieldDataType1(){
        system.debug('>>>><<<Dtype1');
        dataType1 = loadFieldType(object1, field1);
        return dataType1;
    }
    
    public string getfieldDataType2(){
        system.debug('>>>><<<Dtype2');
        dataType2 = loadFieldType(object2, field2);
        return dataType2;
    }
    
    public string getfieldDataType3(){
        system.debug('>>>><<<Dtype3');
        dataType3 = loadFieldType(object3, field3);
        return dataType3;
    }
    
    public string getfieldDataType4(){
        system.debug('>>>><<<Dtype4');
        dataType4 = loadFieldType(object4, field4);
        return dataType4;
    }
    
    public string getfieldDataType5(){
        system.debug('>>>><<<Dtype5');
        dataType5 = loadFieldType(object5, field5);
        return dataType5;   
    }
    */
    public List<SelectOption> getObjectNames() {
        list<SelectOption> objectOptions = new list<SelectOption>();
        //objectOptions.add(new SelectOption('N/A', 'N/A'));
        objectOptions.add(new SelectOption('', ''));
        for(string obj: loadObjects().keySet()) {
            objectOptions.add(new SelectOption(obj, loadObjects().get(obj)));           
        }
        objectOptions.sort();
        return objectOptions;
    }
    
    
     public PageReference customSave(){
        system.debug('NOW Saving>>>>>>>>>>>'  );
         System.debug('>>>> values' +object1 +object2 +object3 +object4 +object5 );
        if (SaveOption == 'Default') {
        tskObj.Object_Name1__c = object1;
        tskObj.Object_Name2__c= object2;
        tskObj.Object_Name3__c = object3;
        tskObj.Object_Name4__c = object4;
        tskObj.Object_Name5__c = object5;
        tskObj.Field_Name1__c= field1;
        tskObj.Field_Name2__c= field2;
        tskObj.Field_Name3__c= field3;
        tskObj.Field_Name4__c= field4;
        tskObj.Field_Name5__c= field5;
        /*tskObj.DataType1__c= dataType1;
        tskObj.DataType2__c= dataType2;
        tskObj.DataType3__c= dataType3;
        tskObj.DataType4__c= dataType4;
        tskObj.DataType5__c= dataType5; */
        tskObj.Req1__c= req1;
        tskObj.Req2__c= req2;
        tskObj.Req3__c= req3;
        tskObj.Req4__c= req4;
        tskObj.Req5__c= req5;
        //String all_value = Object1+Object2+Object3+Object4+Object5+' -qwerty- '+field1+field2+field3+field4+field5+'-----'+dataType1+dataType2+dataType3+dataType4+dataType5;
        system.debug('BEFORE-UPDATE:'+tskObj);
        //system.debug('BEFORE-UPDATE:'+all_value);
            upsert(tskObj);
            }
       else{
       
        tskObj.Display_Object1__c= object1;
        tskObj.Display_Object2__c= object2;
        tskObj.Display_Object3__c= object3;
        tskObj.Display_Object4__c= object4;
        tskObj.Display_Object5__c= object5;
        tskObj.Display_Field1__c= field1;
        tskObj.Display_Field2__c= field2;
        tskObj.Display_Field3__c= field3;
        tskObj.Display_Field4__c= field4;
        tskObj.Display_Field5__c= field5;
        upsert(tskObj);
       
       }
           
        //sController.save();
        return null;

    }
    
   public pageReference editRecord(){
        editMode = true;
        
         if(showDataType){
         
              if (tskObj.Object_Name1__c!= null)
                object1 = tskObj.Object_Name1__c;
              if (tskObj.Field_Name1__c!= null)
                field1 = tskObj.Field_Name1__c;
              if (tskObj.Object_Name2__c!= null)
                object2 = tskObj.Object_Name2__c ;
              if (tskObj.Field_Name2__c!= null)
                field2 = tskObj.Field_Name2__c;
              if (tskObj.Object_Name3__c!= null)
                object3 = tskObj.Object_Name3__c ;
              if (tskObj.Field_Name3__c!= null)
                field3 = tskObj.Field_Name3__c;
              if (tskObj.Object_Name4__c!= null)
                object4 = tskObj.Object_Name4__c ;
              if (tskObj.Field_Name4__c!= null)
                field4 = tskObj.Field_Name4__c;
              if (tskObj.Object_Name5__c!= null)
                object5 = tskObj.Object_Name5__c ;
              if (tskObj.Field_Name5__c!= null)
                field5 = tskObj.Field_Name5__c;
              if (tskObj.Req1__c!= null)
                req1= tskObj.Req1__c;
              if (tskObj.Req2__c!= null)
                req2= tskObj.Req2__c;
              if (tskObj.Req3__c!= null)
                req3= tskObj.Req3__c;
              if (tskObj.Req4__c!= null)
                req4= tskObj.Req4__c;
              if (tskObj.Req5__c!= null)
                 req5= tskObj.Req5__c;
   
     }   else {
               if (tskObj.Display_Object1__c!= null)
                object1 = tskObj.Display_Object1__c;
               if (tskObj.Display_Field1__c!= null)
                field1 = tskObj.Display_Field1__c;
               if (tskObj.Display_Object2__c!= null)
                object2 = tskObj.Display_Object2__c;
               if (tskObj.Display_Field2__c!= null)
                field2 = tskObj.Display_Field2__c;
               if (tskObj.Display_Object3__c!= null)
                object3 = tskObj.Display_Object3__c;
               if (tskObj.Display_Field3__c!= null)
                field3 = tskObj.Display_Field3__c;
               if (tskObj.Display_Object4__c!= null)
                object4 = tskObj.Display_Object4__c;
               if (tskObj.Display_Field4__c!= null)
                field4 = tskObj.Display_Field4__c;
               if (tskObj.Display_Object5__c!= null)
                object5 = tskObj.Display_Object5__c;
               if (tskObj.Display_Field5__c!= null)
                field5 = tskObj.Display_Field5__c;
               
       }             
        
        return null;
    }
    
    private map<string,string> loadObjects(){
        //Map<String, Schema.SObjectType> allObjects = Schema.getGlobalDescribe();
        map<string,string> objectMap = new map<string,string>();
         for (Schema.SObjectType item1: allObjects.values()) {
             String name = item1.getDescribe().getName();
            if (!item1.getDescribe().isCustomSetting() && item1.getDescribe().getRecordTypeInfos().size() > 0 && item1.getDescribe().isCreateable() && !objectNames.contains(name) && myObjectNames.contains(name)) {
                objectMap.put(item1.getDescribe().getName(), item1.getDescribe().getLabel());
                system.debug('-objectMap-'+objectMap);
            }
        }
        
        return objectMap;   
    }
    
    private map<string,string> loadFields(string parentObject){
        map<string,string> fieldsMap = new map<string,string>();
        system.debug('parentObject213231 --N/A>>'+parentObject);
        if (parentObject == null  || parentObject == '')  
        {
            system.debug('parentObject --N/A>>'+parentObject);
            fieldsMap.put('', '');
        }else if (parentObject == 'N/A')
        {
            system.debug('parentObject --N/A>>'+parentObject);
            fieldsMap.put('N/A', 'N/A');
        }
        else {
        system.debug('parentObject>>'+parentObject);
        
        //Map<String, Schema.SObjectType> allObjects = Schema.getGlobalDescribe();
        Schema.SObjectType ObjectSchema = allObjects.get(parentObject);
        Map<String, Schema.SObjectField> fieldMap = ObjectSchema.getDescribe().fields.getMap();
        for(Schema.SObjectField objField : fieldMap.values()){
            schema.describefieldresult dfield = objField.getDescribe();
            fieldsMap.put(dfield.getName(),dfield.getLabel());
            system.debug('------------fieldMap-'+fieldsMap);
            }
        }      
        return fieldsMap;
    }
    
   /* private string loadFieldType(string objName, string fieldName){
        //Map<String, Schema.SObjectType> allObjects = Schema.getGlobalDescribe();
        system.debug('>>>>bjName' +objName +fieldName);
        if (objName == null  || objName == '' || fieldName == null || fieldName == ''){  
            system.debug('>>>>N/A');
            return ''; 
        }else if (objName == 'N/A' || fieldName == 'N/A'){  
            system.debug('>>>>N/A');
            return 'N/A'; 
        }else { 
            map<string,string> fieldTypes = new map<string,string>();
            Schema.SObjectType ObjectSchema = allObjects.get(objName);
            Map<String, Schema.SObjectField> fieldMap = ObjectSchema.getDescribe().fields.getMap();
            Schema.SObjectField sobjField = fieldMap.get(fieldName);
            System.Debug('>>>>>>>>>>ObjName'+objName);
            System.Debug('>>>>>>>>>>fieldName'+fieldName);
            schema.describefieldresult dfield = sobjField.getDescribe();
            Schema.DisplayType dtype = dfield.getType();
            return string.valueOf(dtype);
        }    
    } */
    
    private List<SelectOption> selectOptionsFromSet(string str) {
        List<SelectOption> options = new List<SelectOption>();
        system.debug('INSIDE SelectOption-- objectName:: '+str);
       /* if( str == 'N/A') { 
            System.debug('>>> ObjectName == N/A');
            options.add(new SelectOption('N/A', 'N/A')); }
        else { */
                map<string,string> fieldValuesMap = loadFields(str);
                list<string> optionsList = new list<string>();
                optionsList.addAll(fieldValuesMap.keySet());
                optionsList.sort();
                for (String s : optionsList) {
                    options.add(new SelectOption(s, fieldValuesMap.get(s)));
                }
               
        return options;
    }  
    public pagereference cancel(){
        
        editMode = false;
        return null;
    } 
    
}