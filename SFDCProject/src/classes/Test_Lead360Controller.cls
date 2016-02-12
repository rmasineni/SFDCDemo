@isTest(SeeAllData=true)
public with sharing class Test_Lead360Controller {
	public static testmethod void Test_Lead360Controller(){
		Lead l=new Lead(state='CA',city='San Francisco',street='123 street',postalcode='12345',lastname='Test',channel__c='Test',company='Home',average_Monthly_Electric_Bill__c=100,firstname='Test',email='tset@yopmail.com',alternate_phone__c='(111)-(111)-(1234)',phone='(123)-(123)-(1234)');        
        insert l;
        ApexPages.StandardController controller = new Apexpages.Standardcontroller(l);
        ApexPages.currentPage().getParameters().put('msg',null); 
        lead360Controller ldctr = new lead360Controller(controller);
        Pagereference pg=ldctr.send();
	}
	
	public static testmethod void Test_Lead360Controller1(){
		Lead l=new Lead(state='CA',city='San Francisco',street='123 street',postalcode='12345',lastname='Test',channel__c='Test',company='Home',average_Monthly_Electric_Bill__c=100,firstname='Test',email='tset@yopmail.com',alternate_phone__c='(111)-(111)-(1234)',phone='(123)-(123)-(1234)');        
        insert l;
        Lead360_Int_Mapping__c l360intmap  =new Lead360_Int_Mapping__c(name = 'l360intmap name',Lead360_Value__c='',Lookup_Field__c='other value');
        insert l360intmap;
        
     	ApexPages.StandardController controller = new Apexpages.Standardcontroller(l);
        ApexPages.currentPage().getParameters().put('msg',l.id); 
        lead360Controller ldctr = new lead360Controller(controller);
        
        Pagereference pg=ldctr.send();     
        pg=ldctr.cancel();
        ldctr.sendNotification(l.id,'error message1');
        
        
        
	}

}