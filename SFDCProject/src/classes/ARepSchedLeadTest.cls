@isTest (SeeAllData = true)
global class ARepSchedLeadTest {
    
   /* global static testmethod void Repsched(){
        Lead l=new Lead(Override_CDYNE__c  = true,Address_Standardization_Override__c =true,lastname='Test',company='Home',firstname='Test',email='tset@yopmail.com',channel__c='3rd Party',Custom_Lead_Source__c=' 3rd Party: Clean Energy Authority');        
        insert l;
        Pagereference repsch = new Pagereference('/apex/RepSchedLead?scontrolCaching=1&id='+l.id);
        Test.setCurrentPage(repsch);
        RepSchedLead controller1 = new RepSchedLead(new ApexPages.StandardController(l));
        ApexPages.Message[] msgrep = ApexPages.getMessages();
        // system.assertNotEquals(null,msgrep);
        // system.assertEquals(false,controller1.Table);
        // system.assertEquals(null,controller1.Branchflag);
    }
    
   /* global static testmethod void Repsched1(){
        Lead l=new Lead(Override_CDYNE__c =true,Address_Standardization_Override__c =true,lastname='Test',company='Home',firstname='Test',email='tset@yopmail.com',channel__c='3rd Party',Custom_Lead_Source__c=' 3rd Party: Clean Energy Authority'); 
        insert l;
        l.Sales_Contact_Method__c = 'Phone Consultation';
        update l;
        Pagereference repsch = new Pagereference('/apex/RepSchedLead?scontrolCaching=1&id='+l.id);
        Test.setCurrentPage(repsch);
        try{
            RepSchedLead controller1 = new RepSchedLead(new ApexPages.StandardController(l));
        }catch(exception e){}
        ApexPages.Message[] msgrep = ApexPages.getMessages();
        // system.assertNotEquals(null,msgrep);
        // system.assertEquals(true,controller1.Table);
        // system.assertEquals(true,controller1.Branchflag);
    }
    
    global static testmethod void Repsched2(){
        Lead l=new Lead(Override_CDYNE__c =true,Address_Standardization_Override__c =true,lastname='Test',company='Home',firstname='Test',email='tset@yopmail.com',channel__c='3rd Party',Custom_Lead_Source__c=' 3rd Party: Clean Energy Authority');         insert l;
        String strRecordTypeId = [Select Id From RecordType Where SobjectType = 'Contact' and Name = 'Employee'].Id;
        Pagereference repsch1 = new Pagereference('/apex/RepSchedLead?scontrolCaching=1&id='+l.id);
        RepSchedLead controller1 = new RepSchedLead(new ApexPages.StandardController(l));
        Date Eventstart  = date.today();
        Date Eventend = Eventstart.addDays(5);
        dateTime start = dateTime.newInstance(Eventstart,time.newInstance(10,0,0,0));
        dateTime endt =  dateTime.newInstance(Eventend,time.newInstance(12,0,0,0));
        controller1.conskills.StartDateTime__c = start;
        controller1.conskills.EndDateTime__c = endt;
        controller1.conskills.Skill_Type__c = 'Sales';
        controller1.conskills.Skill_Level__c = '1';
        controller1.CheckAvailability();     
        controller1.Beginning();
        controller1.getDisablePrevious();
        controller1.getDisableNext();
        controller1.Previous();
        controller1.Next();
        controller1.End();
        controller1.getPageNumber();
        controller1.getTotal_size();
        controller1.getTotalPages();
        // system.assertEquals(l.Id, repsch1.getParameters().get('id')); 
    }
    global static testmethod void Repsched3(){
        
        // Setting up data
        Lead l=new Lead(Override_CDYNE__c =true,Address_Standardization_Override__c =true,lastname='Test',company='Home',firstname='Test',email='tset@yopmail.com',channel__c='3rd Party',Custom_Lead_Source__c=' 3rd Party: Clean Energy Authority'); 
        insert l;
        l.Sales_Contact_Method__c = 'Phone Consultation';
        update l;
        String strRecordTypeId = [Select Id From RecordType Where SobjectType = 'Contact' and Name = 'Employee'].Id;
        
        Contact c = [SELECT lastname,id,email,name FROM contact where name = 'Sara Jones' AND RecordTypeId=:strRecordTypeId limit 1];
        // c.Lead__c = l.Id;
        c.Division__c = 'Inside Sales';
        update c;
        
        Contact_Skill__c cs = new Contact_Skill__c();
        cs.Contact__c = c.Id;
        cs.EndDatetime__c = system.now();
        cs.StartDatetime__c = system.now();
        cs.Skill_Type__c = 'Sales';
        insert cs;
        
        Date Eventstart  = date.today();
        Date Eventend = Eventstart.addDays(4);
        dateTime start = dateTime.newInstance(Eventstart,time.newInstance(10,0,0,0));
        dateTime endt =  dateTime.newInstance(Eventstart,time.newInstance(12,0,0,0));
        dateTime start1 = dateTime.newInstance(Eventstart.addDays(1),time.newInstance(10,0,0,0));
        dateTime endt1 =  dateTime.newInstance(Eventstart.addDays(1),time.newInstance(12,0,0,0));
        
        
        /*Test for flow from button on opportunity with error condition - No Appointment Type Selected*/
      /*  Pagereference repsch1 = new Pagereference('/apex/RepSchedLead?scontrolCaching=1&id='+l.id);
        Test.setCurrentPage(repsch1);
        RepSchedLead controller1 = new RepSchedLead(new ApexPages.StandardController(l));
        controller1.conskills.StartDateTime__c = start;
        controller1.conskills.EndDateTime__c = endt;
        controller1.conskills.Skill_Type__c = 'Sales';
        controller1.conskills.Skill_Level__c = '1';
        controller1.CheckAvailability();  
        controller1.Beginning();
        controller1.Previous();
        controller1.Next();
        controller1.getDisablePrevious();
        controller1.getDisableNext();
        controller1.End();
        controller1.getPageNumber();
        controller1.getTotal_size();
        controller1.getTotalPages();   
        // system.assertEquals(l.Id, repsch1.getParameters().get('id'));    
    }
    
    global static testmethod void Repsched4(){
        Account acc = New Account(Name='Test12');
        insert acc;
        
        Lead l=new Lead(Override_CDYNE__c = true,Address_Standardization_Override__c =true,lastname='Test',company='Home',firstname='Test',email='tset@yopmail.com',channel__c='3rd Party',Custom_Lead_Source__c=' 3rd Party: Clean Energy Authority'); 
        insert l;
        
        l.Sales_Contact_Method__c = 'Site Visit';
        update l;
        
        Pagereference repsch1 = new Pagereference('/apex/RepSchedLead?scontrolCaching=1&id='+l.id);
        RepSchedLead controller1 = new  RepSchedLead(new ApexPages.StandardController(l));
        
        dateTime StartDatetime = null;
        dateTime EndDatetime = null;
        controller1.conskills.StartDateTime__c = null;
        controller1.conskills.EndDateTime__c = null;
        controller1.conskills.Skill_Type__c = null;
        controller1.conskills.Skill_Level__c = null;
        controller1.CheckAvailability();    
        controller1.getDisablePrevious();
        controller1.getDisableNext();
        controller1.getPageNumber();
        controller1.getTotal_size();
        controller1.getTotalPages();
        // system.assertEquals(l.Id, repsch1.getParameters().get('id'));  
    } */
    
    global static testmethod void Repsched5(){
        Account acc = New Account(Name='Test12');
        insert acc;
        Profile p = [SELECT Id FROM Profile WHERE Name='Sales' ]; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='test1231232@testorg1234.com');
        
        
        Lead l=new Lead(state='CA',city='San Francisco',street='123 street',postalcode='12345',Address_Standardization_Override__c =true,lastname='Test',channel__c='Test',company='Home',average_Monthly_Electric_Bill__c=100,firstname='Test',email='tset@yopmail.com',alternate_phone__c='(111)-(111)-(1234)',phone='(123)-(123)-(1234)');        
        insert l;
        String strRecordTypeId = [Select Id From RecordType Where SobjectType = 'Contact' and Name = 'Employee'].Id;
        
        Contact c = [SELECT lastname,id,email,name FROM contact where name = 'Sara Jones' AND RecordTypeId=:strRecordTypeId limit 1];
        c.AccountId = acc.id;
        c.Sunrun_User__c =u.Id;
        c.Division__c = 'Inside Sales';
        update c;
        
        Contact_Skill__c cs = new Contact_Skill__c();
        cs.Contact__c = c.Id;
        cs.EndDatetime__c = system.now();
        cs.StartDatetime__c = system.now();
        cs.Skill_Type__c = 'Sales';
        cs.Skill_Level__c='1';
        insert cs;
        
        Pagereference repsch1 = new Pagereference('/apex/RepSchedLead?scontrolCaching=1&id='+l.id);
        RepSchedlead controller1 = new RepSchedlead(new ApexPages.StandardController(l));
        Date Eventstart  = date.today();
        Date Eventend = Eventstart.addDays(4);
        dateTime start = dateTime.newInstance(Eventstart,time.newInstance(10,0,0,0));
        dateTime endt =  dateTime.newInstance(Eventstart,time.newInstance(12,0,0,0));
        dateTime start1 = dateTime.newInstance(Eventstart.addDays(1),time.newInstance(10,0,0,0));
        dateTime endt1 =  dateTime.newInstance(Eventstart.addDays(1),time.newInstance(12,0,0,0));
        
        controller1.conskills.StartDateTime__c = start;
        controller1.conskills.EndDateTime__c = endt;
        controller1.conskills.Skill_Type__c = 'Sales';
        controller1.conskills.Skill_Level__c = '1';
        controller1.CancelButton();
        
        ApexPages.Message[] msgrep = ApexPages.getMessages();
    }
    
}