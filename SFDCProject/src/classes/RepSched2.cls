public with sharing class RepSched2 {
    
    private integer counter=0;  //Offset counter
    private integer list_size= 20 ; //Number of rows per page
    public integer total_size; //Total number of record to be displayed
    
    Public Date StartDate;
    Public Date EndDate;
    Public Date TempDate;
    Public List<Date> ListOfDates {get;set;}
    Public Integer LengthDays;
    Public Integer j;
    
    Public Integer StartSlot;
    Public Integer EndSlot;
        
    Public DateTime EventsStartTime;
    Public DateTime EventsEndTime;
    
    Public Integer[] Flags = new Integer[18];
    Public Integer r; 
    Public DateTime FirstSlot;
    Public DateTime LastSlot;
    Public DateTime FirstSlot1;
    Public DateTime LastSlot1;
    Public DateTime ActualFirstSlot;
    Public DateTime EventStartTime;
    Public DateTime EventEndTime;
    Public DateTime TimeToStart;
    Public Decimal Milliseconds;
    Public Decimal Minuteconvert;
    Public Integer Remainder;
    Public Integer FlagstartMinutes;
    Public Integer FlagstopMinutes;
    Public Integer FlagStart;
    Public Integer FlagStop;
    Public Integer FlagStart1;
    Public Integer FlagStop1;
    Public String tempstr1;
    Public String tempend1;
    Public String tempstrld1;
    Public String tempendld1;

    Public String temsklevel;
    Public List<Event> EventCheckValidity;
    
    Public Boolean Table {get;set;}
    
    Public Time tempstart {get;set;}
    Public Time tempend {get;set;}
    Public String tzoneln;
    Public dateTime tempst {get;set;}
    Public dateTime tempen {get;set;}
    Public dateTime tempslot {get;set;}
    Public dateTime tempslot1 {get;set;}
    Public DateTime dateTimeValue { get; set; }
    Public List<AvailableSlots> Slot1 {get;set;}
    Public List<Date> Listofdays {get;set;}
    Public List<Contact_Skill__c> Contactids {get;set;}
    Public List<Event> EventCheckValidity11 {get;set;}
    public Contact_Skill__c conskills {get;set;}
    Public Event E{Set;get;}
    Public Map<String,List<Event>> MapSalesRepEvents;
    Private final Opportunity op;
    Public Opportunity oppa{Set;get;}
    Private String Division;
    public boolean displayPopup {get; set;}
    public Appointment__c appt {get;set;}
    public string Branch{get;set;}
    public String ContactPhone {get;set;}
    public dateTime paramstdate {get;set;}
    public dateTime parameddate {get;set;}
    public String timezone {get;set;}
    public string paramcontact {get;set;}
    public string paramopportunity {get;set;}
    Public Boolean Branchflag {get;set;}
    Public Boolean Salesrepflag {get;set;}
    Public Boolean SalesrepDisp {get;set;}
    Public Boolean Noconsalesrep = false;
    Public String selectedSlot {get;set;}
    Private Integer TimeSelectInt;
    public boolean isSaved{get;set;}
    public Id opptyId;
    public string baseURL{get;set;}
    public string parentURL{get;set;}
    Public List<SelectOption> TimeSlots{
        get{
            List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption('1','1'));
            options.add(new SelectOption('2','2'));
            options.add(new SelectOption('3','3'));         
            return options;
        }
        set;
    }
    Public Class AvailableSlots{
        Public dateTime datetimestart {get;set;}
        Public dateTime datetimeend {get;set;}
        Public String datetimess {get;set;}
        Public String datetimeed {get;set;}
        Public String datetimess1 {get;set;}
        Public String datetimeed1 {get;set;}
        Public String datetimessldisply1 {get;set;}
        Public String datetimeedldisply1 {get;set;}
        
        public AvailableSlots(dateTime tstart, dateTime tend,String tstartss,String tendss,String tstartss1,String tendss1,String tstartld, String tendld) {
            this.datetimestart = tstart;
            this.datetimeend = tend;
            this.datetimess =  tstartss; 
            this.datetimeed =  tendss;
            this.datetimess1 =  tstartss1; 
            this.datetimeed1 =  tendss1;
            this.datetimessldisply1 = tstartld;
            this.datetimeedldisply1 = tendld;
        }
    }
    
    Public List<ListDateWithSlots>  ListDateSlots1 {get;set;}
    
    Public Class ListDateWithSlots{
        Public Date Dateslot {get;set;}
        Public List<AvailableSlots> Availslot {get;set;}
        
        public ListDateWithSlots(Date temped, List<AvailableSlots> tempavail) {
            this.Dateslot = temped;
            this.Availslot = tempavail;
        }
    }
    
    Public List<FinalListofSlots>  FinallistSl {get;set;}
    Public Class FinalListofSlots{
        Public id Contactid {get;set;}
        Public String Contactname  {get;set;}
        Public String Skilllevel  {get;set;}
        Public String Tzonelocal {get;set;}
        Public List<ListDateWithSlots> FinalSlt {get;set;}
        
        public FinalListofSlots(id condid,String tempen, String tempsk, List<ListDateWithSlots> templsl,String tzonel) {
            this.Contactid = condid;
            this.Contactname = tempen;
            this.Skilllevel = tempsk;
            this.FinalSlt = templsl;
            this.Tzonelocal = tzonel;
        }
    }
    
    Public List<AvailabilityByDay> Availbd {get;set;}
    
    Public Class AvailabilityByDay{
        Public Date dateavailbility {get;set;}
        Public List<Integer> availabletimeslots {get;set;}
        
        public AvailabilityByDay(Date tdate, List<Integer> tavail) {
            this.dateavailbility = tdate;
            this.availabletimeslots = tavail;
        }
    }
    
    public RepSched2(ApexPages.StandardController stdController){
        this.op = (Opportunity)stdController.getRecord();
        E = New Event();
        conSkills = new Contact_Skill__c();
        Salesrepflag = false;
        SalesrepDisp = true;
        TimeSelectInt=1;
        FromOpportunityTab();
        displayPopup = false; 
        appt = new Appointment__c();
        opptyId = op.Id;
        baseURL = EDPUtil.getBaseURL();
        parentURL = baseURL + '/' + opptyId;
    }
    
    Public void FromOpportunityTab()
        {
            //Function called from 'Create Appointment' button in opportunity tab
            oppa = [SELECT id,AccountId,State__c,Phone__c,Sales_Branch__c,Address__c,Name,Homeowner_Full_Name__c,Homeowner_Email__c,Appointment_Type_Requested_del__c,SalesRep__c from Opportunity WHERE id =:op.Id];
            String tempsrepid = oppa.SalesRep__c; 
                if((oppa.Appointment_Type_Requested_del__c != null && oppa.Appointment_Type_Requested_del__c != 'No Preference') || (tempsrepid != null && tempsrepid != '')){
                    if (oppa.Appointment_Type_Requested_del__c == 'Phone Consultation'){
                        //Setting branchflag true to ensure SOQL query does not include the where Branch = 'x' clause
                        Branchflag = true;
                    }
                    if (oppa.Appointment_Type_Requested_del__c != 'Phone Consultation'){
                        //Branchflag remains false to ensure SOQL query includes the where Branch = 'x' clause
                        Branch = oppa.Sales_Branch__c;
                    }
                    
                    conSkills.Skill_Type__c = 'Sales';
                    conSkills.Skill_Level__c = null;
                    Division = 'Field Sales';
                    
                    //Set start date to today and end date 5 days from now; Set startdatetime as 6:00 AM on startdate and enddatetime as 11:00 PM on enddate 
                    //to search events within this time frame
                    StartDate = date.today();
                    EndDate = StartDate.addDays(5);
                    EventsStartTime  = dateTime.newInstance(StartDate,time.newInstance(6,0,0,0));
                    EventsEndTime    = dateTime.newInstance(EndDate,time.newInstance(23,0,0,0));
                    conSkills.StartDateTime__c = EventsStartTime;
                    conSkills.EndDateTime__c = EventsEndTime;
                    if (Branchflag == true){
                        Division = 'Inside Sales';
                        //Query to get the list of contacts that match the given search criteria;
                        if(conSkills.Skill_Level__c == null || conSkills.Skill_Level__c == ''){
                            total_size   = [SELECT COUNT() FROM Contact_Skill__c WHERE Skill_Type__c =:conSkills.Skill_Type__c AND Contact__r.Division__c=:Division  AND Skill_Level__c!=Null];
                        }
                        else{
                            total_size = [SELECT COUNT() FROM Contact_Skill__c WHERE Skill_Type__c =:conSkills.Skill_Type__c AND Contact__r.Division__c=:Division AND Skill_Level__c =:conSkills.Skill_Level__c];
                        }
                    }
                    else if(conSkills.Skill_Level__c == null || conSkills.Skill_Level__c == ''){
                        total_size = [SELECT COUNT() FROM Contact_Skill__c WHERE  Contact__r.Branch_location__c =:Branch AND Skill_Type__c =:conSkills.Skill_Type__c AND Contact__r.Division__c=:Division  AND Skill_Level__c!=Null];
                    }
                    else{
                        total_size = [SELECT COUNT() FROM Contact_Skill__c WHERE Contact__r.Branch_location__c =:Branch AND Skill_Level__c =:conSkills.Skill_Level__c AND Skill_Type__c =:conSkills.Skill_Type__c AND Contact__r.Division__c =:Division];
                    }
                    
                    List<OpportunityContactRole> OpportunityContactList = [Select Id,Contactid,isPrimary,Role,OpportunityId from opportunitycontactrole  WHERE OpportunityId =:oppa.Id AND role='Homeowner' AND isPrimary=true];
                    Map <Id,Id> OpportunityContactMap = New  Map <Id,Id>();
                    if(!OpportunityContactList.isEmpty()){
                    For (OpportunityContactRole ocr: OpportunityContactList){
                        OpportunityContactMap.put(ocr.ContactId,ocr.OpportunityId);
                        }
                    }
                    List<Contact>ContactList =[Select Id, AccountId ,Phone from Contact where Id IN: OpportunityContactMap.keySet() limit 1];
                    If (!ContactList.isEmpty()){
                        for ( Contact con1: ContactList){
                           ContactPhone = ContactList[0].Phone;
                             }
                    }   
                   
                    //system.debug('Sales Rep Id is No1  '+oppa.SalesRep__c);
                    if(tempsrepid != null && tempsrepid != '')
                    {
                        //system.debug('Sales Rep Id is No2  '+oppa.SalesRep__c);
                        Salesrepflag = true;
                        SalesrepDisp = false;
                        total_size = 1;
                        list_size = 1;
                        counter = 1;
                    }
                    MainFunction();
                }
            else{
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL,'No Appointment Type Selected!');
                    ApexPages.addMessage(myMsg);
                    Table=false;
                }
        }
    
    Public void CheckAvailability(){ 
        counter=0;  //Reset offset counter
        list_size=20; //Reset Number of rows per page
        total_size=2000; //Reset Total number of record to be displayed
        TimeSelectInt=integer.valueof(selectedSlot);
         if(Test.isRunningTest()){
            list_size=1;   
            total_size=1;
        }
            
        if(conskills.StartDatetime__c!=null && conSkills.EndDateTime__c!=null)
        {
            StartDate = conSkills.StartDateTime__c.Date();
            EndDate = conSkills.EndDateTime__c.Date();
            EventsStartTime = conSkills.StartDateTime__c;        
            EventsEndTime  = conSkills.EndDateTime__c;
            MainFunction();
        }
        else{
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL,'Please check the Start / End Date and Time');
            ApexPages.addMessage(myMsg);
            Table=false;
        }
    }
    
    public PageReference CancelButton(){
        String selectedRecordType = ApexPages.currentPage().getParameters().get('RecordType');
        Id id = selectedRecordType;
        PageReference p = new PageReference('/00Q/e?retURL=%2F00Q%2Fo&RecordType='+id+'&ent=Opportunity');
        return p;
    }
    
    Public Void MainFunction(){   
        
        Scheduling_Page_Limit__c schedlimit = Scheduling_Page_Limit__c.getValues('SalesReps displayed');
        // Integer replimit = (Integer)schedlimit.Number_of_Sales_Reps__c;
        Integer replimit = 20;
        if(Test.isRunningTest()){
            replimit = 1;   
        }
        
        if(StartDate.daysBetween(Enddate) > 5){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL,'Please select dates within 6 days');
            ApexPages.addMessage(myMsg);
            Table=false;   
        }
        else{
            List<Contact_Skill__c> Contactids = new List<Contact_Skill__c>();
            if(Salesrepflag == true )
            {
                List<Contact> ConSalesRepId = [SELECT Id from Contact WHERE Sunrun_User__c =:oppa.SalesRep__c and  Sunrun_User__r.IsActive = true limit 1]; 
                if(!ConSalesRepId.Isempty()){
                    String tempconid = ConSalesRepId[0].Id;
                    Contact_Skill__c tempconskills = new Contact_Skill__c();
                    tempconskills.Contact__c = tempconid;
                    Contactids.add(tempconskills);
                } else {
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL,'The Sales Rep on the Opportunity is not set up as a Sales Rep in the Scheduling Tool');
                    ApexPages.addMessage(myMsg);
                    Table=false;                    
                    Noconsalesrep = true;
                }
            }
            
            else{
                if (Branchflag == true){
                    Division = 'Inside Sales';
                    //Query to get the list of contacts that match the given search criteria;
                    if(conSkills.Skill_Level__c == null || conSkills.Skill_Level__c == ''){
                        Contactids   = [SELECT Contact__c,Skill_Level__c FROM Contact_Skill__c WHERE Skill_Type__c =:conSkills.Skill_Type__c AND Contact__r.Division__c=:Division  AND Contact__r.Sunrun_User__r.IsActive = true AND Skill_Level__c!=Null ORDER BY Skill_Level__c ASC  LIMIT :list_size offset :counter];
                    }
                    else{
                        Contactids = [SELECT Contact__c,Skill_Level__c FROM Contact_Skill__c WHERE Skill_Type__c =:conSkills.Skill_Type__c AND Contact__r.Division__c=:Division AND Contact__r.Sunrun_User__r.IsActive = true  AND Skill_Level__c =:conSkills.Skill_Level__c ORDER BY Skill_Level__c ASC limit :list_size offset :counter];
                    }
                }
                else if(conSkills.Skill_Level__c == null || conSkills.Skill_Level__c == ''){
                    Contactids = [SELECT Contact__c,Skill_Level__c FROM Contact_Skill__c WHERE  Contact__r.Branch_location__c =:Branch AND Contact__r.Branch_location__c!=NULL  AND Skill_Type__c =:conSkills.Skill_Type__c AND Contact__r.Division__c=:Division AND Contact__r.Sunrun_User__r.IsActive = true  AND Skill_Level__c!=Null ORDER BY Skill_Level__c ASC  limit :list_size offset :counter];
                }
                else{
                    Contactids = [SELECT Contact__c,Skill_Level__c FROM Contact_Skill__c WHERE Contact__r.Branch_location__c =:Branch AND Contact__r.Branch_location__c!=NULL AND Skill_Level__c =:conSkills.Skill_Level__c AND Skill_Type__c =:conSkills.Skill_Type__c AND Contact__r.Division__c =:Division AND Contact__r.Sunrun_User__r.IsActive = true  ORDER BY Skill_Level__c ASC limit :list_size offset :counter];
                }
            }
            
            List<Id> Listofids  = new List<Id>();
            if(!Contactids.isEmpty()){
                for(Contact_Skill__c CSK:Contactids){
                    Listofids.add(CSK.Contact__c);
                }
            }
            
            if(StartDate != null && EndDate != Null && conSkills.Skill_Type__c != Null && conSkills.Skill_Type__c != 'None' && Contactids.size() > 0 && Noconsalesrep == false)
            {
                //EventsStartTime = conSkills.StartDateTime__c;        
                //EventsEndTime  = conSkills.EndDateTime__c;
                
                FirstSlot = dateTime.newInstance(StartDate,time.newInstance(6,0,0,0)); 
                LastSlot = dateTime.newInstance(EndDate,time.newInstance(23,0,0,0));                
                          
                //Set slots to between 6 AM to 11 PM if not entered right
                
                Milliseconds = EventsStartTime.getTime() - FirstSlot.getTime(); 
                Minuteconvert = Milliseconds / (1000.0*60.0);
                FlagstartMinutes = (integer)(Minuteconvert);
                                
                if(FlagstartMinutes < 0){
                    EventsStartTime = FirstSlot;
                    //system.debug('Setting slots right if not entered right starttime -6:00 AM '+EventsStartTime);
                }
                
                Milliseconds = LastSlot.getTime() - EventsEndTime.getTime();  
                Minuteconvert = Milliseconds / (1000.0*60.0);
                FlagstopMinutes = (integer)(Minuteconvert);
                
                if(FlagstopMinutes < 0){
                    EventsEndTime = LastSlot;
                    //system.debug('Setting slots right if not entered right endtime +11:00 PM '+EventsEndTime);
                }
                
                Map<Id,Contact> ContactNameMap = new Map<Id,Contact>([Select Id,Name,(Select Skill_Level__c FROM Contact_Skills__r),Sunrun_User__r.TimeZoneSidKey FROM Contact WHERE Id IN:Listofids]);
                List<Event> EventCheckValidity = [Select id,Subject,StartDateTime,EndDateTime,who.name,who.id,IsAllDayEvent,ActivityDate FROM event WHERE ((StartDateTime <= :EventsStartTime AND EndDateTime > :EventsStartTime) OR (StartDateTime >= :EventsStartTime AND EndDateTime <= :EventsEndTime) OR (StartDateTime < :EventsEndTime AND EndDateTime >= :EventsEndTime) OR 
                                                                                                                                                           (ActivityDate >= :StartDate AND ActivityDate <= :EndDate AND IsAllDayEvent = true)) AND who.id IN:Listofids]; 
                Map<Id,Map<Date,List<Event>>> ContactDateEventMap = new Map<Id,Map<Date,List<Event>>>();
                
                if(!EventCheckValidity.isEmpty()){
                    for(Event etemp:EventCheckValidity){
                        Map<Date,List<Event>> ChildMap = ContactDateEventMap.get(etemp.WhoId);
                        if(ChildMap == null){
                            ChildMap = new Map<Date,List<Event>>();
                            List<Event> ChildList = new List<Event>();
                            
                            TempDate = etemp.StartDateTime.date();
                            if(etemp.IsAllDayEvent == true){
                                TempDate = etemp.ActivityDate;
                                etemp.StartDateTime = dateTime.newInstance(TempDate,time.newInstance(6,0,0,0));
                                etemp.EndDateTime = dateTime.newInstance(TempDate,time.newInstance(23,0,0,0));
                            }
                            ChildList.add(etemp); 
                            ChildMap.put(TempDate,ChildList);
                            ContactDateEventMap.put(etemp.WhoId,ChildMap);
                        }
                        else{
                            TempDate = etemp.StartDateTime.date();
                            if (etemp.IsAllDayEvent == true){
                                TempDate = etemp.ActivityDate;
                                etemp.StartDateTime = dateTime.newInstance(TempDate,time.newInstance(6,0,0,0));
                                etemp.EndDateTime = dateTime.newInstance(TempDate,time.newInstance(23,0,0,0));
                            }                            
                            List<Event> ChildList = ChildMap.get(tempdate);
                            if(ChildList == null){
                                ChildList = new List<Event>();
                                ChildList.add(etemp);
                                ChildMap.put(TempDate,ChildList);
                                ContactDateEventMap.put(etemp.WhoId,ChildMap);
                            }else{
                                ChildList.add(etemp);
                                ChildMap.put(TempDate,ChildList);
                                ContactDateEventMap.put(etemp.WhoId,ChildMap);
                            }
                        }
                    }
                }
                
                //List of dates between startdate and enddate
                ListOfDates = new List<Date>();
                LengthDays = StartDate.daysBetween(EndDate);
                for(j=0;j<=LengthDays;j++){
                    ListOfDates.add(StartDate.addDays(j));
                }

                if(Branch == null || Branch == ''){
                    Branch = 'Not Requested';
                }
                FinallistSl = new List<FinalListofSlots>();
                for(Contact_Skill__c CST:Contactids){
                    tzoneln = Contactnamemap.get(CST.Contact__c).Sunrun_user__r.TimeZoneSidKey;
                    if(tzoneln == null){
                        tzoneln = 'Not Available';
                    }
                    Map<Date,List<Event>> ChildMap = ContactDateEventMap.get(CST.Contact__c);
                    if(ChildMap == null){
                        
                        
                        //Set all time slots for the contact as available 
                        ListDateSlots1 = new List<ListDateWithSlots>();
                        for(j=0;j<=LengthDays;j++){ 
                            Slot1 = new List<AvailableSlots>();
                           
                                //Setting available slots for first day
                                if( j == 0 && j != LengthDays ){
                                    system.debug('Setting all slots available starting with first day for contact');
                                    FirstSlot = dateTime.newInstance(StartDate.addDays(j),time.newInstance(6,0,0,0)); 
                                    
                                    //Get flag start index
                                    Milliseconds = EventsStartTime.getTime() - FirstSlot.getTime(); 
                                    Minuteconvert = Milliseconds / (1000.0*60.0);
                                    FlagstartMinutes = (integer)(Minuteconvert);
                                    FlagStart = FlagstartMinutes / 60;
                                    Remainder = math.mod(FlagstartMinutes,60);
                                    if(Remainder != 0){
                                        FlagStart = FlagStart + 1;
                                    }
                                    
                                    //system.debug('Flag start for setting all slots available starting with first day for CONTACT '+FlagStart);
                                    
                                    //Get flag end index
                                    FlagStop = 16;
                                    //system.debug('Flag stop for setting all slots available starting with first day for CONTACT '+FlagStop);
                                } 
                                
                                //Setting available slots for last day
                                if( j != 0 && j == LengthDays ){
                                    
                                    FirstSlot = dateTime.newInstance(StartDate.addDays(j),time.newInstance(6,0,0,0)); 
                                    
                                    //Get flag start index
                                    FlagStart = 0;
                                    //system.debug('Flag start for setting all slots available for last day for CONTACT '+FlagStart);
                                    
                                    //Get flag end index
                                    Milliseconds = EventsEndTime.getTime() - FirstSlot.getTime(); 
                                    Minuteconvert = Milliseconds / (1000.0*60.0);   
                                    FlagstopMinutes = (integer)(Minuteconvert);
                                    FlagStop = FlagstopMinutes / 60;
                                    Remainder = math.mod(FlagstopMinutes,60);
                                    if(Remainder >= 0 && FlagStop != 0){
                                        FlagStop = FlagStop - 1;
                                    }
                                    //system.debug('Flag stop for setting all slots available for last day for CONTACT '+FlagStop);
                                } 
                                
                                //Setting available slots when first day is the last day
                                if( j == 0 && j == LengthDays ){
                                    
                                    FirstSlot = dateTime.newInstance(StartDate.addDays(j),time.newInstance(6,0,0,0)); 
                                    
                                    //Get flag start index
                                    Milliseconds = EventsStartTime.getTime() - FirstSlot.getTime(); 
                                    Minuteconvert = Milliseconds / (1000.0*60.0);
                                    FlagstartMinutes = (integer)(Minuteconvert);
                                    FlagStart = FlagstartMinutes / 60;
                                    Remainder = math.mod(FlagstartMinutes,60);
                                    if(Remainder != 0){
                                        FlagStart = FlagStart + 1;
                                    }
                                   
                                    //system.debug('Flag start for setting all slots available for when first = last day for CONTACT '+FlagStart);
                                    
                                    //Get flag end index
                                    Milliseconds = EventsEndTime.getTime() - FirstSlot.getTime(); 
                                    Minuteconvert = Milliseconds / (1000.0*60.0);
                                    FlagstopMinutes = (integer)(Minuteconvert);
                                    FlagStop = FlagstopMinutes / 60;
                                    Remainder = math.mod(FlagstopMinutes,60);
                                    if(Remainder >= 0 && FlagStop != 0){
                                        FlagStop = FlagStop - 1;
                                    }
                                    //system.debug('Flag stop for setting all slots available for when first = last day for CONTACT '+FlagStop);
                                } 
                                
                                if( j != 0 && j != LengthDays ){
                                    
                                    //Setting available slots for in between day with CONTACT
                                    FlagStart = 0; 
                                    FlagStop = 16;
                                    //system.debug('Flag start and stop for setting all slots available for in between days for CONTACT '+FlagStart +' & '+FlagStop);
                                }    
                            datetime finalen = dateTime.newInstance(StartDate.addDays(j),time.newInstance(23,0,0,0));                                    
                            for(r=FlagStart;r<=FlagStop;r++){
                                datetime tempst = dateTime.newInstance(StartDate.addDays(j),time.newInstance((6+r),0,0,0));
                                datetime tempen = tempst.addMinutes(60*TimeSelectInt);                                
                                String tempstr = tempst.format(); 
                                String tempend = tempen.format(); 
                                if(tzoneln != 'Not Available'){
                                    //tempstr1 = tempst.format('hh:mm a',tzoneln); 
                                    //tempend1 = tempen.format('hh:mm a',tzoneln);
                                    tempstr1 = tempst.format('hh:mm a');
                                    tempend1 = tempen.format('hh:mm a');
                                    //tempstrld1 = tempst.format('M/d/yyyy hh:mm a',tzoneln);
                                    //tempendld1 = tempen.format('M/d/yyyy hh:mm a',tzoneln);
                                }else{
                                    tempstr1 = tempst.format('hh:mm a'); 
                                    tempend1 = tempen.format('hh:mm a');
                                    //tempstrld1 = tempst.format();
                                    //tempendld1 = tempst.format();
                                }
                                if(tempen<=finalen){
                                AvailableSlots tempslot =  new AvailableSlots(tempst,tempen,tempstr,tempend,tempstr1,tempend1,tempstrld1,tempendld1);
                                Slot1.add(tempslot);
                                }
                                
                            }
                            ListDateWithSlots templist = new ListDateWithSlots(StartDate.addDays(j),Slot1);
                            ListDateSlots1.add(templist);
                        }
                        if(Salesrepflag == true){
                            if(!ContactNameMap.get(CST.Contact__c).Contact_Skills__r.isEmpty()){
                                if(ContactNameMap.get(CST.Contact__c).Contact_Skills__r[0].Skill_Level__c != null){ 
                                       temsklevel = ContactNameMap.get(CST.Contact__c).Contact_Skills__r[0].Skill_Level__c;
                                         system.debug('Skill Level is     --->'+ContactNameMap.get(CST.Contact__c).Contact_Skills__r[0].Skill_Level__c);
                                   }
                                else{
                                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL,'The Sales Rep on the Lead is not set up as a Sales Rep in the Scheduling Tool');
                                    ApexPages.addMessage(myMsg);
                                    Table=false;
                                    break;
                                }
                            }else {
                                
                                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL,'The Sales Rep on the Lead is not set up as a Sales Rep in the Scheduling Tool');
                                ApexPages.addMessage(myMsg);
                                Table=false;
                                break;
                            }  
                            
                        }
                        else {
                            temsklevel = ContactNameMap.get(CST.Contact__c).Contact_Skills__r[0].Skill_Level__c;   
                        }

                        FinalListofSlots tempfinal = new FinalListofSlots(CST.Contact__c,ContactNameMap.get(CST.Contact__c).Name,temsklevel,ListDateSlots1,tzoneln);
                        FinallistSl.add(tempfinal);
                    }else
                        {
                            ListDateSlots1 = new List<ListDateWithSlots>();
                            for(j=0;j<=LengthDays;j++){
                            Slot1 = new List<AvailableSlots>();
                            List<Event> ChildList = ChildMap.get(StartDate.addDays(j));
                            if(ChildList == null){
                            
                                //Setting available slots for first day when no events found
                                if( j == 0 && j != LengthDays ){
                                    system.debug('Setting all slots as available for first day when no events found');
                                    FirstSlot = dateTime.newInstance(StartDate.addDays(j),time.newInstance(6,0,0,0)); 
                                    
                                    //Get flag start index
                                    Milliseconds = EventsStartTime.getTime() - FirstSlot.getTime(); 
                                    Minuteconvert = Milliseconds / (1000.0*60.0);
                                    FlagstartMinutes = (integer)(Minuteconvert);
                                    FlagStart = FlagstartMinutes / 60;
                                    Remainder = math.mod(FlagstartMinutes,60);
                                    if(Remainder != 0){
                                        FlagStart = FlagStart + 1;
                                    }
                                    system.debug('Flag start for setting all slots available for first day when no events found '+FlagStart);
                                    
                                    //Get flag end index
                                    FlagStop = 16;
                                    system.debug('Flag stop for setting all slots available for first day when no events found '+FlagStop);
                                } 
                                
                                //Setting available slots for last day when no events found
                                if( j != 0 && j == LengthDays ){
                                    
                                    FirstSlot = dateTime.newInstance(StartDate.addDays(j),time.newInstance(6,0,0,0)); 
                                    
                                    //Get flag start index
                                    FlagStart = 0;
                                    system.debug('Flag start for setting all slots available for last day when no events found  '+FlagStart);
                                    
                                    //Get flag end index
                                    Milliseconds = EventsEndTime.getTime() - FirstSlot.getTime(); 
                                    Minuteconvert = Milliseconds / (1000.0*60.0);   
                                    FlagstopMinutes = (integer)(Minuteconvert);
                                    FlagStop = FlagstopMinutes / 60;
                                    Remainder = math.mod(FlagstopMinutes,60);
                                    if(Remainder >= 0 && FlagStop != 0){
                                        FlagStop = FlagStop - 1;
                                    }
                                    system.debug('Flag stop for setting all slots available for last day when no events found  '+FlagStop);
                                } 
                                
                                //Setting available slots when first day = last day with no events found
                                if( j == 0 && j == LengthDays ){
                                    
                                    FirstSlot = dateTime.newInstance(StartDate.addDays(j),time.newInstance(6,0,0,0)); 
                                    
                                    //Get flag start index
                                    Milliseconds = EventsStartTime.getTime() - FirstSlot.getTime(); 
                                    Minuteconvert = Milliseconds / (1000.0*60.0);
                                    FlagstartMinutes = (integer)(Minuteconvert);
                                    FlagStart = FlagstartMinutes / 60;
                                    Remainder = math.mod(FlagstartMinutes,60);
                                    if(Remainder != 0){
                                        FlagStart = FlagStart + 1;
                                    }
                                    system.debug('Flag start for setting all slots available for when first = last day with no events found '+FlagStart);
                                    
                                    //Get flag end index
                                    Milliseconds = EventsEndTime.getTime() - FirstSlot.getTime(); 
                                    Minuteconvert = Milliseconds / (1000.0*60.0);
                                    FlagstopMinutes = (integer)(Minuteconvert);
                                    FlagStop = FlagstopMinutes / 60;
                                    Remainder = math.mod(FlagstopMinutes,60);
                                    if(Remainder >= 0 && FlagStop != 0){
                                        FlagStop = FlagStop - 1;
                                    }
                                    system.debug('Flag stop for setting all slots available for when first = last day with no events found '+FlagStop);
                                } 
                                
                                if( j != 0 && j != LengthDays ){
                                    
                                    //Setting available slots for in between day when no events found
                                    FlagStart = 0; 
                                    FlagStop = 16;
                                    system.debug('Flag start and stop for setting all slots available for in between days when no events found '+FlagStart +' & '+FlagStop);
                                }    
                                
                                datetime finalen = dateTime.newInstance(StartDate.addDays(j),time.newInstance(23,0,0,0));
                                for(r=FlagStart;r<=FlagStop;r++){
                                    datetime tempst = dateTime.newInstance(StartDate.addDays(j),time.newInstance((6+r),0,0,0));
                                    datetime tempen = tempst.addMinutes(60*TimeSelectInt);                                                                        
                                    String tempstr = tempst.format(); 
                                    String tempend = tempen.format(); 
                                    if(tzoneln != 'Not Available'){
                                        tempstr1 = tempst.format('hh:mm a');
                                        tempend1 = tempen.format('hh:mm a');
                                    }else{
                                        tempstr1 = tempst.format('hh:mm a'); 
                                        tempend1 = tempen.format('hh:mm a');
                                    }
                                    if(tempen<=finalen){
                                    AvailableSlots tempslot =  new AvailableSlots(tempst,tempen,tempstr,tempend,tempstr1,tempend1,tempstrld1,tempendld1);
                                    Slot1.add(tempslot);
                                    TimeToStart = tempen;
                                    }
                                }   
                                ListDateWithSlots templist = new ListDateWithSlots(StartDate.addDays(j),Slot1);
                                ListDateSlots1.add(templist);
                            }
                            
                            else{
                                ResetFlags();

                                //Setting available slots for first day when events found
                                if( j == 0 && j != LengthDays ){
                                    system.debug('Setting available slots for first day when events found');
                                    FirstSlot = dateTime.newInstance(StartDate.addDays(j),time.newInstance(6,0,0,0)); 
                                    
                                    //Get flag start index
                                    Milliseconds = EventsStartTime.getTime() - FirstSlot.getTime(); 
                                    Minuteconvert = Milliseconds / (1000.0*60.0);
                                    FlagstartMinutes = (integer)(Minuteconvert);
                                    FlagStart = FlagstartMinutes / 60;
                                    Remainder = math.mod(FlagstartMinutes,60);
                                    if(Remainder != 0){
                                        FlagStart = FlagStart + 1;
                                    }
                                    
                                    system.debug('Flag start for first day when events found '+FlagStart);
                                    
                                    //Get flag end index
                                    FlagStop = 16;
                                    system.debug('Flag stop for first day when events found '+FlagStop);
                                } 
                                
                                //Setting available slots for last day with event list
                                if( j != 0 && j == LengthDays ){
                                    
                                    FirstSlot = dateTime.newInstance(StartDate.addDays(j),time.newInstance(6,0,0,0)); 
                                    
                                    //Get flag start index
                                    FlagStart = 0;
                                    system.debug('Flag start for last day when events found '+FlagStart);
                                    
                                    //Get flag end index
                                    Milliseconds = EventsEndTime.getTime() - FirstSlot.getTime(); 
                                    Minuteconvert = Milliseconds / (1000.0*60.0);   
                                    FlagstopMinutes = (integer)(Minuteconvert);
                                    FlagStop = FlagstopMinutes / 60;
                                    Remainder = math.mod(FlagstopMinutes,60);
                                    if(Remainder >= 0 && FlagStop != 0){
                                        FlagStop = FlagStop - 1;
                                    }
                                    system.debug('Flag stop for last day when events found  '+FlagStop);
                                } 
                                
                                //Setting available slots when first = last day with events found
                                if( j == 0 && j == LengthDays ){
                                    
                                    FirstSlot = dateTime.newInstance(StartDate.addDays(j),time.newInstance(6,0,0,0)); 
                                    
                                    //Get flag start index
                                    Milliseconds = EventsStartTime.getTime() - FirstSlot.getTime(); 
                                    Minuteconvert = Milliseconds / (1000.0*60.0);
                                    FlagstartMinutes = (integer)(Minuteconvert);
                                    FlagStart = FlagstartMinutes / 60;
                                    Remainder = math.mod(FlagstartMinutes,60);
                                    if(Remainder != 0){
                                        FlagStart = FlagStart + 1;
                                    }
                                    system.debug('Flag start for when first day = last day with events found '+FlagStart);
                                    
                                    //Get flag end index
                                    Milliseconds = EventsEndTime.getTime() - FirstSlot.getTime(); 
                                    Minuteconvert = Milliseconds / (1000.0*60.0);
                                    FlagstopMinutes = (integer)(Minuteconvert);
                                    FlagStop = FlagstopMinutes / 60;
                                    Remainder = math.mod(FlagstopMinutes,60);
                                    if(Remainder >= 0 && FlagStop != 0){
                                        FlagStop = FlagStop - 1;
                                    }
                                    system.debug('Flag stop for when first day = last day with events found '+FlagStop);
                                } 
                                
                                if( j != 0 && j != LengthDays ){
                                    
                                    //Setting available slots for in between day & with event list
                                    FlagStart = 0; 
                                    FlagStop = 16;
                                    system.debug('Flag start and stop in between & with events found '+FlagStart +' & '+FlagStop);
                                }    
                                
                                FirstSlot1 = dateTime.newInstance(StartDate.addDays(j),time.newInstance(6,0,0,0));
                                LastSlot1 = dateTime.newInstance(StartDate.addDays(j),time.newInstance(23,0,0,0));
                                
                                //system.debug('FirstSlot1 is '+FirstSlot1);
                                //system.debug('LastSlot1 is '+LastSlot1);
                                
                                for(Event ete1:ChildList){
                                EventStartTime = ete1.StartDateTime;
                                EventEndTime = ete1.EndDateTime;
                                
                                //system.debug('EventStartTime before '+EventStartTime);
                                //system.debug('EventEndTime before '+EventEndTime);
                                    
                                if(EventStartTime < FirstSlot1){
                                    EventStartTime = FirstSlot1;
                                }
                                if(EventEndTime > LastSlot1){
                                    EventEndTime = LastSlot1;
                                }
                                
                                //system.debug('EventStartTime Again '+EventStartTime);
                               // system.debug('EventEndTime Again '+EventEndTime);
                                    
                                //Get flag start index
                                Milliseconds = EventStartTime.getTime() - FirstSlot1.getTime(); 
                                Minuteconvert = Milliseconds / (1000.0*60.0);
                                FlagstartMinutes = (integer)(Minuteconvert);
                                System.debug('FlagStartMinutes before Remainder '+FlagstartMinutes);
                                FlagStart1 = FlagstartMinutes / 60;
                                Remainder = math.mod(FlagstartMinutes,60);
                                //system.debug('Remainder is '+Remainder);
                                //system.debug('FlagStart1 after remainder '+FlagStart1);
                                
                                //Get flag end index
                                Milliseconds = EventEndTime.getTime() - FirstSlot1.getTime(); 
                                Minuteconvert = Milliseconds / (1000.0*60.0);
                                FlagstopMinutes = (integer)(Minuteconvert);
                                //system.debug('FlagstopMinutes before FlagStop1 '+FlagstopMinutes);
                                FlagStop1 = FlagstopMinutes / 60;
                                //system.debug('Flagstop1 before remainder '+FlagStop1);
                                Remainder = math.mod(FlagstopMinutes,60);
                                //system.debug('Remainder is '+Remainder);
                                if(Remainder == 0){
                                FlagStop1 = FlagStop1 - 1;
                                }  
                                    
                                //system.debug('Flagstop1 after remainder '+FlagStop1);
                                if(FlagStart1 < 0){
                                    FlagStart1 = 0;
                                }
                                if(FlagStop1 > 16){
                                    FlagStop1 = 16;
                                }
                                //system.debug('FlagStop1 '+FlagStop1);
                                //system.debug('FlagStart1 '+FlagStart1);
                                
                                If(FlagStart1 != 16 || FlagStop1 != 16)
                                { 
                                for(r=FlagStart1;r<=FlagStop1;r++){
                                    Flags[r] = 1;
                                   // if(r == 15 && FlagStop1 == 16){
                                   //     Flags[16] = 1;
                                   // }
                                }
                                }else{
                                Flags[16] = 1;
                                }
                            }
                            //System.debug('Print r'+r);
                            //System.debug('Print FlagStart'+FlagStart);
                            //System.debug('Print FlagStop'+FlagStop);
                            for(r=FlagStart;r<=FlagStop;r++){
                                if(Flags[r] == 0){
                                    datetime tempst = dateTime.newInstance(StartDate.addDays(j),time.newInstance((6+r),0,0,0));                                   
                                    datetime tempen = tempst.addMinutes(60*TimeSelectInt);
                                    String tempstr = tempst.format(); 
                                    String tempend = tempen.format(); 
                                    if(tzoneln != 'Not Available'){
                                        tempstr1 = tempst.format('hh:mm a');
                                        tempend1 = tempen.format('hh:mm a');
                                    }else{
                                        tempstr1 = tempst.format('hh:mm a'); 
                                        tempend1 = tempen.format('hh:mm a');
                                    }                                                                      
                                    if(TimeSelectInt==2){                                       
                                            if(r<16&&Flags[r+1] == 0&&tempen<=LastSlot1){                                          
                                            AvailableSlots tempslot =  new AvailableSlots(tempst,tempen,tempstr,tempend,tempstr1,tempend1,tempstrld1,tempendld1);
                                            Slot1.add(tempslot);
                                            }                                                                              
                                    } 
                                    else if(TimeSelectInt==3){
                                            if(r<15&&Flags[r+1] == 0&&Flags[r+2] == 0&&tempen<=LastSlot1){                                                                                     
                                            AvailableSlots tempslot =  new AvailableSlots(tempst,tempen,tempstr,tempend,tempstr1,tempend1,tempstrld1,tempendld1);
                                            Slot1.add(tempslot);
                                            }   
                                    }
                                    else{
                                    AvailableSlots tempslot =  new AvailableSlots(tempst,tempen,tempstr,tempend,tempstr1,tempend1,tempstrld1,tempendld1);
                                    Slot1.add(tempslot);
                                    }
                                }
                            }
                            ListDateWithSlots templist = new ListDateWithSlots(StartDate.addDays(j),Slot1);
                            ListDateSlots1.add(templist);
                        }   
                        }
                    
                        if(Salesrepflag == true){
                            if(!ContactNameMap.get(CST.Contact__c).Contact_Skills__r.isEmpty()){
                                if(ContactNameMap.get(CST.Contact__c).Contact_Skills__r[0].Skill_Level__c != null){ 
                                       temsklevel = ContactNameMap.get(CST.Contact__c).Contact_Skills__r[0].Skill_Level__c;
                                       system.debug('Skill Level is  2nd loop   --->'+ContactNameMap.get(CST.Contact__c).Contact_Skills__r[0].Skill_Level__c);
                                   }
                                else{
                                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL,'The Sales Rep on the Opportunity is not set up as a Sales Rep in the Scheduling Tool');
                                    ApexPages.addMessage(myMsg);
                                    Table=false;
                                    break;
                                }
                            }else {
                                
                                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL,'The Sales Rep on the Opportunity is not set up as a Sales Rep in the Scheduling Tool');
                                ApexPages.addMessage(myMsg);
                                Table=false;
                                break;
                            }  
                            
                        }
                        else {
                            temsklevel = ContactNameMap.get(CST.Contact__c).Contact_Skills__r[0].Skill_Level__c;   
                        }
                        FinalListofSlots tempfinal = new FinalListofSlots(CST.Contact__c,ContactNameMap.get(CST.Contact__c).Name,ContactNameMap.get(CST.Contact__c).Contact_Skills__r[0].Skill_Level__c,ListDateSlots1,tzoneln);
                        FinallistSl.add(tempfinal);
                    }
                    Table=true;
                }            
                
            }
            else
            {
                if(Noconsalesrep == true){
                    return;
                }
                if(StartDate == Null){
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL,'Please enter "Availability From" date to search!');
                    ApexPages.addMessage(myMsg);
                }
                
                if(EndDate == Null){
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL,'Please enter "Availability To" date to search!');
                    ApexPages.addMessage(myMsg);
                }
                
                if(conSkills.Skill_Type__c  == Null){
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL,'Please enter skill type to search!');
                    ApexPages.addMessage(myMsg);
                }
                
                if(conSkills.Contact__r.Branch_Location__c == Null && oppa.Appointment_Type_Requested_del__c=='Site Visit'){
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL,'No contact found since the Sales Branch is '+Branch);
                    ApexPages.addMessage(myMsg);
                }
                
                if(conSkills.Skill_Type__c  != Null && conSkills.Contact__r.Branch_Location__c != Null){
                    if(Contactids.size() == 0 || Contactids.size() == Null){
                        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL,'No Sales rep found for given criteria!');
                        ApexPages.addMessage(myMsg);
                    }
                }
                Table=false; 
            }
        }
    }
    
    Public void ResetFlags(){
        for(r=0;r<17;r++){
            Flags[r] = 0;
        }
    }
    
/*    public void appointmentOpen(){
        displayPopup = true;
        appt.Appointment_Date_time__c = paramstdate;
        appt.Appointment_End_Date_Time__c = paramstdate;
        appt.Event_Assigned_To__c = paramcontact;
        appt.Opportunity__c = paramopportunity;
        appt.Appointment_Description__c = oppa.name +'\r\n' +' Please Find the Link For More Details  '+'\r\n' + System.URL.getSalesforceBaseUrl().toExternalForm() +'/'+paramopportunity;     
    }
*/ 
   
    public void appointmentOpen(){
        displayPopup = true;
        if(ContactPhone == null || ContactPhone=='' ){
            ContactPhone='No Phone';
        }
        if (oppa.Homeowner_Email__c==null || oppa.Homeowner_Email__c==''){
            oppa.Homeowner_Email__c = 'No Email';
        }
        appt.Name__c ='APPT: '+oppa.Homeowner_Full_Name__c+' '+'/'+' '+oppa.State__c+' '+'/'+' '+ContactPhone;
        appt.Appointment_Date_time__c = paramstdate;
        appt.Appointment_End_Date_Time__c = parameddate;
        appt.Event_Assigned_To__c = paramcontact;
        appt.Opportunity__c = paramopportunity;
        appt.Appointment_Description__c = oppa.Homeowner_Full_Name__c +'\r\n' +oppa.Address__c +'\r\n' + ContactPhone+'\r\n'+oppa.Homeowner_Email__c+'\r\n'+System.URL.getSalesforceBaseUrl().toExternalForm() +'/'+paramopportunity;  
    }
    
    public void closePopup(){
        displayPopup = false;     
        paramstdate = null;
        parameddate = null;
        paramopportunity = null;
        paramcontact= null;
        //timezone = null;
    }
    
    public void saveAppointment(){
        /*String userTimeZoneSidId = UserInfo.getTimeZone().getID();
        Timezone userTimeZone = Timezone.getTimeZone(userTimeZoneSidId);
        Integer offsetToUserTimeZone = customerTimeZone.getOffset(Datetime.now());
        Integer offsetToUser = offsetToUserTimeZone / (1000 * 60 *60);   
        String tzcon = timezone;
        TimeZone contactTimeZone = TimeZone.getTimeZone(timezone);
        TimeZone tz = UserInfo.getTimeZone();
        
        Integer i =  tz.getOffset(DateTime.now());
        system.debug('Id    '+tz.getID());
        system.debug('Integer'+i);
        
        
        string customerTimeZoneSidId = 'Pacific/Honolulu';
        TimeZone tz1 = TimeZone.getTimeZone(customerTimeZoneSidId);
        Integer i1 =  tz1.getOffset(DateTime.now());
        system.debug('Integer'+i1);
        
        Integer offsettime = (i - i1)/(1000*60*60);
        System.debug('Integer'+offsettime);*/
        
        insert appt;
        isSaved = true;
        displayPopup = false;  
        appt.clear();  
    }
    
    public PageReference Beginning() { //user clicked beginning
        counter = 0;
        MainFunction();
        return null;
    }   
    
    public PageReference Previous() { //user clicked previous button
        counter -= list_size;
        if(counter >= 0){
        MainFunction();    
        }
        else{
        counter = 0;        
        }
        return null;
    }
    
    public PageReference Next() { //user clicked next button
        counter += list_size;
        if(counter <= total_size){
        MainFunction();    
        }
        else{
        counter = total_size - math.mod(total_size, list_size);
        }
        return null;
    }
    
    public PageReference End() { //user clicked end
        counter = total_size - math.mod(total_size, list_size);
        MainFunction();
        return null;
    }
    
    public Boolean getDisablePrevious() { 
        //this will disable the previous and beginning buttons
        if (counter > 0) return false; else return true;
    }
    
    public Boolean getDisableNext() { //this will disable the next and end buttons
        if (counter + list_size < total_size) return false; else return true;
    }
    
    public Integer getTotal_size() {
        return total_size;
    }
    
    public Integer getlist_size() {
        return list_size;
    }
    
    public Integer getPageNumber() {
        return counter/list_size + 1;
    }
    
    public Integer getTotalPages() {
        if (math.mod(total_size, list_size) > 0) {
            return total_size/list_size + 1;
        } else {
            return (total_size/list_size);
        }
    }
    
}