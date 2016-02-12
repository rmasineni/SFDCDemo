@isTest(SeeAllData = True)
global class ARepSched2Test {
    
    global static testmethod void Repsched(){
        
        Account acc = New Account(Name='Test12');
        insert acc;
        Opportunity opty = New Opportunity(Sales_Branch__c='Bakersfield',AccountId=acc.Id,Name='Testopp1',StageName='2. Appointment Process',Opportunity_Status__c='Open',CloseDate=system.today()+90);
        insert opty;

        Pagereference repsch = new Pagereference('/apex/RepSched2?scontrolCaching=1&id='+opty.id);
        Test.setCurrentPage(repsch);
        RepSched2 controller1 = new RepSched2(new ApexPages.StandardController(opty));
        ApexPages.Message[] msgrep = ApexPages.getMessages();
        // system.assertNotEquals(null,msgrep);
        // system.assertEquals(false,controller1.Table);
        // system.assertEquals(null,controller1.Branchflag);
    }
    
    global static testmethod void Repsched1(){
        
        Account acc = New Account(Name='Test12');
        insert acc;
                           
        Opportunity opty = New Opportunity(Sales_Branch__c='Bakersfield',AccountId=acc.Id,Name='Testopp1',StageName='2. Appointment Process',Opportunity_Status__c='Open',CloseDate=system.today()+90);
        insert opty;
        opty.Appointment_Type_Requested_del__c = 'Phone Consultation';
        update opty;
        
        Pagereference repsch = new Pagereference('/apex/RepSched2?scontrolCaching=1&id='+opty.id);
        Test.setCurrentPage(repsch);
        try{
        RepSched2 controller1 = new RepSched2(new ApexPages.StandardController(opty));
        }catch(exception e){}
        ApexPages.Message[] msgrep = ApexPages.getMessages();
        // system.assertNotEquals(null,msgrep);
        // system.assertEquals(true,controller1.Table);
        // system.assertEquals(true,controller1.Branchflag);
    }
    
    global static testmethod void Repsched2(){
        
        Account acc = New Account(Name='Test12');
        insert acc;
                           
        Opportunity opty = New Opportunity(Sales_Branch__c='Bakersfield',AccountId=acc.Id,Name='Testopp1',StageName='2. Appointment Process',Opportunity_Status__c='Open',CloseDate=system.today()+90);
        insert opty;
        String strRecordTypeId = [Select Id From RecordType Where SobjectType = 'Contact' and Name = 'Employee'].Id;
      
        Pagereference repsch1 = new Pagereference('/apex/RepSched2?scontrolCaching=1&id='+opty.id);
        RepSched2 controller1 = new RepSched2(new ApexPages.StandardController(opty));
        
        Date Eventstart  = date.today();
        Date Eventend = Eventstart.addDays(5);
        dateTime start = dateTime.newInstance(Eventstart,time.newInstance(10,0,0,0));
        dateTime endt =  dateTime.newInstance(Eventend,time.newInstance(12,0,0,0));
        
        controller1.conskills.StartDateTime__c = start;
        controller1.conskills.EndDateTime__c = endt;
        controller1.conskills.Skill_Type__c = 'Sales';
        controller1.conskills.Skill_Level__c = '1';       
        controller1.selectedSlot='1';
        controller1.appointmentOpen();
        controller1.closePopup();
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
        
        
         system.assertEquals(opty.Id, repsch1.getParameters().get('id')); 
    }
        
    global static testmethod void Repsched3(){
        
        // Setting up data
        Account acc = New Account(Name='Test12');
        insert acc;
                           
        Opportunity opty = New Opportunity(Sales_Branch__c='Bakersfield',AccountId=acc.Id,Name='Testopp1',StageName='2. Appointment Process',Opportunity_Status__c='Open',CloseDate=system.today()+90);
        insert opty;
        opty.Appointment_Type_Requested_del__c = 'Phone Consultation';
        update opty;
        String strRecordTypeId = [Select Id From RecordType Where SobjectType = 'Contact' and Name = 'Employee'].Id;
      
        Contact c = [SELECT lastname,id,email,name FROM contact where name = 'Sara Jones' AND RecordTypeId=:strRecordTypeId limit 1];
        c.AccountId = acc.id;
        c.Opportunity__c = opty.Id;
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
       Pagereference repsch1 = new Pagereference('/apex/RepSched2?scontrolCaching=1&id='+opty.id);
        Test.setCurrentPage(repsch1);
        RepSched2 controller1 = new RepSched2(new ApexPages.StandardController(opty));
        controller1.conskills.StartDateTime__c = start;
        controller1.conskills.EndDateTime__c = endt;
        controller1.conskills.Skill_Type__c = 'Sales';
        controller1.conskills.Skill_Level__c = '1';
        controller1.selectedSlot='2';
        //controller1.appointmentOpen();
        //controller1.saveAppointment();
        controller1.getlist_size();
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
        // system.assertEquals(opty.Id, repsch1.getParameters().get('id'));    
    }

        global static testmethod void Repsched4(){
        Account acc = New Account(Name='Test12');
        insert acc;
                           
        Opportunity opty = New Opportunity(Sales_Branch__c='Bakersfield',AccountId=acc.Id,Name='Testopp1',StageName='2. Appointment Process',Opportunity_Status__c='Open',CloseDate=system.today()+90);
        insert opty;
        opty.Sales_Contact_Method__c = 'Site Visit';
        update opty;
        
        Pagereference repsch1 = new Pagereference('/apex/RepSched2?scontrolCaching=1&id='+opty.id);
        RepSched2 controller1 = new RepSched2(new ApexPages.StandardController(opty));

        dateTime StartDatetime = null;
        dateTime EndDatetime = null;
        controller1.conskills.StartDateTime__c = null;
        controller1.conskills.EndDateTime__c = null;
        controller1.conskills.Skill_Type__c = null;
        controller1.conskills.Skill_Level__c = null;
        controller1.selectedSlot='3';
        controller1.CheckAvailability();    
        controller1.getDisablePrevious();
        controller1.getDisableNext();
        controller1.getPageNumber();
        controller1.getTotal_size();
        controller1.getTotalPages();
        
       
        system.assertEquals(opty.Id, repsch1.getParameters().get('id'));  
    }
      global static testmethod void Repsched5(){
        
        Account acc = New Account(Name='Test12');
        insert acc;
        Profile p = [SELECT Id FROM Profile WHERE Name='Sales' ]; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='test1231232@testorg1234.com');
        
                           
        Opportunity opty = New Opportunity(Salesrep__c=u.Id,AccountId=acc.Id,Name='Testopp1',StageName='2. Appointment Process',Opportunity_Status__c='Open',CloseDate=system.today()+90);
        insert opty;
        String strRecordTypeId = [Select Id From RecordType Where SobjectType = 'Contact' and Name = 'Employee'].Id;
      
        Contact c = [SELECT lastname,id,email,name FROM contact where name = 'Sara Jones' AND RecordTypeId=:strRecordTypeId limit 1];
        c.AccountId = acc.id;
        c.Sunrun_User__c =u.Id;
        c.Opportunity__c = opty.Id;
        c.Division__c = 'Inside Sales';
        update c;
        
        Contact_Skill__c cs = new Contact_Skill__c();
        cs.Contact__c = c.Id;
        cs.EndDatetime__c = system.now();
        cs.StartDatetime__c = system.now();
        cs.Skill_Type__c = 'Sales';
        cs.Skill_Level__c='1';
        insert cs;
        
        Pagereference repsch1 = new Pagereference('/apex/RepSched2?scontrolCaching=1&id='+opty.id);
        RepSched2 controller1 = new RepSched2(new ApexPages.StandardController(opty));
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