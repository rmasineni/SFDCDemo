@isTest(SeeAllData=true)
global class RepSchedAppOppTest {
    
    global static testmethod void Repsched(){
        
        Account acc = New Account(Name='Test12');
        insert acc;
                           
        Opportunity opty = New Opportunity(Sales_Branch__c='Bakersfield',AccountId=acc.Id,Name='Testopp1',StageName='2. Appointment Process',Opportunity_Status__c='Open',CloseDate=system.today()+90);
        insert opty;

        Pagereference repsch = new Pagereference('/apex/RepSchedAppOpp?scontrolCaching=1&id='+opty.id);
        Test.setCurrentPage(repsch);
        RepSchedAppOpp controller1 = new RepSchedAppOpp(new ApexPages.StandardController(opty));
        ApexPages.Message[] msgrep = ApexPages.getMessages();
       // system.assertNotEquals(null,msgrep);
      //  System.assertEquals(false,controller1.Table);
      //  system.assertEquals(null,controller1.Branchflag);
    }
    
    global static testmethod void Repsched1(){
        
        Account acc = New Account(Name='Test12');
        insert acc;
                           
        Opportunity opty = New Opportunity(Sales_Branch__c='Bakersfield',AccountId=acc.Id,Name='Testopp1',StageName='2. Appointment Process',Opportunity_Status__c='Open',CloseDate=system.today()+90);
        insert opty;
        opty.Appointment_Type_Requested_del__c = 'Phone Consultation';
        update opty;
        
        Pagereference repsch = new Pagereference('/apex/RepSchedAppOpp?scontrolCaching=1&id='+opty.id);
        Test.setCurrentPage(repsch);
        RepSchedAppOpp controller1 = new RepSchedAppOpp(new ApexPages.StandardController(opty));
        ApexPages.Message[] msgrep = ApexPages.getMessages();
      //  system.assertNotEquals(null,msgrep);
      // System.assertEquals(true,controller1.Table);
     //   system.assertEquals(true,controller1.Branchflag);
    }
    
    global static testmethod void Repsched2(){
        
        Account acc = New Account(Name='Test12');
        insert acc;
                           
        Opportunity opty = New Opportunity(Sales_Branch__c='Bakersfield',AccountId=acc.Id,Name='Testopp1',StageName='2. Appointment Process',Opportunity_Status__c='Open',CloseDate=system.today()+90);
        insert opty;
        String strRecordTypeId = [Select Id From RecordType Where SobjectType = 'Contact' and Name = 'Employee'].Id;
      
        Pagereference repsch1 = new Pagereference('/apex/RepSchedAppOpp?scontrolCaching=1&id='+opty.id);
        RepSchedAppOpp controller1 = new RepSchedAppOpp(new ApexPages.StandardController(opty));
        
        Date Eventstart  = date.today();
        Date Eventend = Eventstart.addDays(7);
        dateTime start = dateTime.newInstance(Eventstart,time.newInstance(10,0,0,0));
        dateTime endt =  dateTime.newInstance(Eventend,time.newInstance(12,0,0,0));
        
        controller1.conskills.StartDateTime__c = start;
        controller1.conskills.EndDateTime__c = endt;
        controller1.conskills.Skill_Type__c = 'Sales';
        controller1.conskills.Skill_Level__c = '1';
        controller1.NewFunctionButton();     
       // system.assertEquals(opty.Id, repsch1.getParameters().get('id')); 
    }
        
    global static testmethod void Repsched3(){
        
        //Setting up data
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
        Pagereference repsch1 = new Pagereference('/apex/RepSchedAppOpp?scontrolCaching=1&id='+opty.id);
        Test.setCurrentPage(repsch1);
        RepSchedAppOpp controller1 = new RepSchedAppOpp(new ApexPages.StandardController(opty));
        controller1.conskills.StartDateTime__c = start;
        controller1.conskills.EndDateTime__c = endt;
        controller1.conskills.Skill_Type__c = 'Sales';
        controller1.conskills.Skill_Level__c = '1';
        controller1.NewFunctionButton();     
        //system.assertEquals(opty.Id, repsch1.getParameters().get('id'));    
    }

    global static testmethod void Repsched4(){
        Account acc = New Account(Name='Test12');
        insert acc;
                           
        Opportunity opty = New Opportunity(Sales_Branch__c='Bakersfield',AccountId=acc.Id,Name='Testopp1',StageName='2. Appointment Process',Opportunity_Status__c='Open',CloseDate=system.today()+90);
        insert opty;
        opty.Sales_Contact_Method__c = 'Site Visit';
        update opty;
        
        Pagereference repsch1 = new Pagereference('/apex/RepSchedAppOpp?scontrolCaching=1&id='+opty.id);
        RepSchedAppOpp controller1 = new RepSchedAppOpp(new ApexPages.StandardController(opty));

        dateTime StartDatetime = null;
        dateTime EndDatetime = null;
        controller1.conskills.StartDateTime__c = null;
        controller1.conskills.EndDateTime__c = null;
        controller1.conskills.Skill_Type__c = null;
        controller1.conskills.Skill_Level__c = null;
        controller1.NewFunctionButton();     
      //  system.assertEquals(opty.Id, repsch1.getParameters().get('id'));  
    }
                      
}