public class RepSchedAppOpp {

    Public datetime StartDatetime {get;set;}
    Public datetime EndDatetime   {get;set;}
    Public date StartDate {get;set;}
    Public date EndDate   {get;set;}
    Public time myTime {get;set;}
    Public List<Date>  ListDate {get;set;}
    Public List<Event> EventCheckValidity;
    Public List<Date>  ListDate1 {get;set;}
    Public Map<String,Map<String,List<Event>>>  MapEvent {get;set;}
    Public Map<String,Map<String, Map<String,String>>> AvailabilityTime {get;set;}
    Public Boolean Table {get;set;}
    Public DateTime EndDateTimeSelectStart {get;set;}
    Public DateTime EndDateTimeSelectEnd {get;set;}
    Public DateTime StartCounter {get;set;}
    Public DateTime StartCounterTime {get;set;}
    Public DateTime StartCounterMapTime {get;set;}
    Public time StartTimeForMap {get;set;}
    Public Integer i {get;set;}
    Public Integer j {get;set;}
    Public Integer c {get;set;}
    Public Integer mapstart;
    Public Integer mapend;
    Public Boolean cflag {get;set;}
    Public Integer count {get;set;}
    Public Date startday {get;set;}
    Public Date endday {get;set;}
    Public Date incrementday {get;set;}
    Public Date mapdate {get;set;}
    Public Integer LengthDays {get;set;}
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
    public dateTime paramstdate {get;set;}
    public dateTime parameddate {get;set;}
    public string paramcontact {get;set;}
    public string paramopportunity {get;set;}
    Public Boolean Branchflag {get;set;}
    Public Boolean rendercomp {get;set;}
    
    Public Class AvailableSlots{
        Public dateTime datetimestart {get;set;}
        Public dateTime datetimeend {get;set;}
        Public String datetimess {get;set;}
        Public String datetimeed {get;set;}
        Public String datetimess1 {get;set;}
        Public String datetimeed1 {get;set;}
        
        public AvailableSlots(dateTime tstart, dateTime tend,String tstartss,String tendss,String tstartss1,String tendss1) {
            this.datetimestart = tstart;
            this.datetimeend = tend;
            this.datetimess =  tstartss; 
            this.datetimeed =  tendss;
            this.datetimess1 =  tstartss1; 
            this.datetimeed1 =  tendss1;
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
    
    public RepSchedAppOpp(ApexPages.StandardController stdController){
        this.op = (Opportunity)stdController.getRecord();
        E=New Event();
        conSkills = new Contact_Skill__c();
        CheckAvailabilityOppty();
        displayPopup = false; 
        appt = new Appointment__c();
        rendercomp = false;
    }
    
    public String getTimeZoneValue(){
        if(dateTimeValue != null){
            String localeFormatDT = dateTimeValue.format();
            return localeFormatDT;
        }
        return null;
    }
      
    Public void CheckAvailabilityOppty()
        {
            oppa = [SELECT id,Name,Sales_Branch__c,Appointment_Type_Requested_del__c from Opportunity WHERE id =:op.Id];
                if(oppa.Appointment_Type_Requested_del__c != null && oppa.Appointment_Type_Requested_del__c != 'No Preference'){
                       if (oppa.Appointment_Type_Requested_del__c == 'Phone Consultation'){
                           Branchflag = true;
                         }
                       if (oppa.Appointment_Type_Requested_del__c!= 'Phone Consultation'){
                       Branch = oppa.Sales_Branch__c;
                       }
                       conSkills.Skill_Type__c = 'Sales';
                       Division = 'Field Sales';
                       conSkills.Skill_Level__c = null;
                       StartDate = date.today();
                       EndDate = StartDate.addDays(2);
                       EndDateTimeSelectStart  = dateTime.newInstance(StartDate,time.newInstance(0,0,0,0));
                       EndDateTimeSelectEnd    = dateTime.newInstance(EndDate.addDays(1),time.newInstance(2,0,0,0));
                       StartDateTime = dateTime.newInstance(StartDate,time.newInstance(6,0,0,0));
                       conSkills.StartDateTime__c = dateTime.newInstance(StartDate,time.newInstance(6,0,0,0));
                       conSkills.EndDateTime__c = dateTime.newInstance(EndDate,time.newInstance(23,0,0,0));
                       EndDateTime = dateTime.newInstance(EndDate.addDays(1),time.newInstance(2,0,0,0));
                       MainFunction();
                }
            else{
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL,'No Appointment Type Selected!');
                ApexPages.addMessage(myMsg);
                Table=false; 
            }
        }
    
    Public void NewFunctionButton(){ 
        if(conskills.StartDatetime__c!=null && conSkills.EndDateTime__c!=null)
        {
            StartDate = conSkills.StartDateTime__c.Date();
            EndDate = conSkills.EndDateTime__c.Date();
            EndDateTimeSelectStart = conSkills.StartDateTime__c;        
            EndDateTimeSelectEnd  = conSkills.EndDateTime__c;
            MainFunction();
        }
        else{
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL,'Pleases check the start / end date and time');
            ApexPages.addMessage(myMsg);
            Table=false;
        }
    }
    
    public PageReference CancelButton(){
        String selectedRecordType = ApexPages.currentPage().getParameters().get('RecordType');
        Id id=selectedRecordType;
        PageReference p = new PageReference('/00Q/e?retURL=%2F00Q%2Fo&RecordType='+id+'&ent=Opportunity');
        return p;
    }
    
    Public Void MainFunction(){   
        
        Scheduling_Page_Limit__c schedlimit = Scheduling_Page_Limit__c.getValues('SalesReps displayed');
        Integer replimit = (Integer)schedlimit.Number_of_Sales_Reps__c;
        if(Test.isRunningTest()){
            replimit = 1;   
        }
        
        if(StartDate.daysBetween(Enddate) > 4){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL,'Please select schedule dates within 4 days!');
            ApexPages.addMessage(myMsg);
            Table=false;   
        }
        else{
            if (Branchflag == true){
                Division = 'Inside Sales';
               
                if(conSkills.Skill_Level__c == null || conSkills.Skill_Level__c == ''){
                    Contactids   = [SELECT Contact__c,Skill_Level__c FROM Contact_Skill__c WHERE Skill_Type__c =:conSkills.Skill_Type__c AND Contact__r.Division__c=:Division  AND Skill_Level__c!=Null ORDER BY Skill_Level__c ASC  LIMIT :replimit];
                    system.debug('Contact IDs ....'+Contactids);
                }
                else{
                    Contactids = [SELECT Contact__c,Skill_Level__c FROM Contact_Skill__c WHERE Skill_Type__c =:conSkills.Skill_Type__c AND Contact__r.Division__c=:Division AND Skill_Level__c =:conSkills.Skill_Level__c ORDER BY Skill_Level__c ASC LIMIT :replimit];
                    system.debug('Contact IDs ....'+Contactids);
                }
            }
            else if(conSkills.Skill_Level__c == null || conSkills.Skill_Level__c == ''){
                Contactids = [SELECT Contact__c,Skill_Level__c FROM Contact_Skill__c WHERE  Contact__r.Branch_location__c =:Branch AND Skill_Type__c =:conSkills.Skill_Type__c AND Contact__r.Division__c=:Division  AND Skill_Level__c!=Null ORDER BY Skill_Level__c ASC  LIMIT :replimit];
                system.debug('Contact IDs ....'+Contactids);
            }
            else{
                Contactids = [SELECT Contact__c,Skill_Level__c FROM Contact_Skill__c WHERE Contact__r.Branch_location__c =:Branch AND Skill_Level__c =:conSkills.Skill_Level__c AND Skill_Type__c =:conSkills.Skill_Type__c AND Contact__r.Division__c =:Division  ORDER BY Skill_Level__c ASC LIMIT :replimit];
                system.debug('Contact IDs ....'+Contactids);
            }
            
            List<Id> Listofids  = new List<Id>();
            for(Contact_Skill__c CSK:Contactids)
            {
                Listofids.add(CSK.Contact__c);
            }
            
            system.debug('Everything  '+StartDate+' '+EndDate+' '+conSkills.Skill_Type__c+' '+Branch+' '+Contactids.size());
            if(StartDate!=null && EndDate!=Null && conSkills.Skill_Type__c !=Null  && conSkills.Skill_Type__c != 'None' && Contactids.size() > 0)
            {
                Map<Integer,Time> Lookuptable = new Map<Integer,Time>();
                Map<Id,Contact> Contactnamemap = new Map<Id,Contact>([Select Id,Name,(Select Skill_Level__c FROM Contact_Skills__r),Sunrun_User__r.TimeZoneSidKey FROM Contact WHERE Id IN:Listofids]);
                Map<Id,String>  Skilllevelmap = new Map<Id,String>();
                
                for(Contact_Skill__c CSK:Contactids)
                {
                    Skilllevelmap.put(CSK.Contact__c,CSK.Skill_Level__c);
                }
                
                Map<String,List<Event>> MapSalesRepEvents = new Map<String,List<Event>>();
                
                List<Event> EventCheckValidity = [Select id,Subject,StartDateTime,EndDateTime,who.name,who.id,IsAllDayEvent,ActivityDate FROM event WHERE ((EndDateTime > :EndDateTimeSelectStart AND EndDateTime < :EndDateTimeSelectEnd) OR (StartDateTime > :EndDateTimeSelectStart AND StartDateTime < :EndDateTimeSelectEnd)) AND who.id IN:Listofids];
                
                for(Contact_Skill__c CST:Contactids){
                    if(EventCheckValidity.size()>0)
                    {
                        List<Event> TempEventList = new List<Event>();
                        for(Event ET:EventCheckValidity)
                        {
                            if(CST.Contact__c == ET.who.id)
                            {
                                TempEventList.add(ET);
                            }
                        }
                        MapSalesRepEvents.put(CST.Contact__c,TempEventList);
                    }
                    else{
                        List<Event> TempEventList = new List<Event>(); 
                        MapSalesRepEvents.put(CST.Contact__c,TempEventList);
                    }
                }
                
                StartTimeForMap = time.newinstance(6,0,0,0);
                for(i=0;i<=1082;i++)
                {   
                    Lookuptable.put(i,StartTimeForMap);
                    StartTimeForMap = StartTimeForMap.addMinutes(1);
                }
                
                FinallistSl = new List<FinalListofSlots>();
                for(Contact_Skill__c CST:Contactids)
                {
                    List<Event> EventCheckValidity11 = new List<Event>();
                    EventCheckValidity11 = MapSalesRepEvents.get(CST.Contact__c);
                    
                    startday     =      EndDateTimeSelectStart.date();
                    endday       =      EndDateTimeSelectEnd.date();
                    LengthDays   =      startday.daysBetween(endday);
                    incrementday =      StartDate;
                    mapdate      =      StartDate;
                    ListDate1    =      new List<Date>();
                    
                    for(j=0;j<=LengthDays;j++)
                    {
                        ListDate1.add(incrementday);
                        incrementday = incrementday.addDays(1);
                    }
                    
                    incrementday            = StartDate;
                    StartCounterTime        = dateTime.newInstance(incrementday,time.newInstance(6,0,0,0)); 
                    Availbd  = new List<AvailabilityByDay>();
                    count = 0;
                    
                    for(j=0;j<=LengthDays;j++)
                    {      
                        Integer[] myFlags = new Integer[1020];
                        Integer counter = 1020;
                        if(Test.isRunningTest()){
                            counter = 10;
                        }
                        
                        for(i=0;i<counter;i++)
                        {          
                            if(EventCheckValidity11.size()>0)
                            {
                                for(Event ET:EventCheckValidity11)
                                {
                                    if(ET.IsAllDayEvent == true)
                                    {
                                        ET.StartDateTime    = dateTime.newInstance(ET.ActivityDate,time.newInstance(6,0,0,0)); 
                                        ET.EndDateTime      = dateTime.newInstance(ET.ActivityDate.addDays(1),time.newInstance(2,0,0,0));
                                    }    
                                    
                                    if(StartCounterTime >= ET.StartDateTime && StartCounterTime <= ET.EndDateTime)
                                    {
                                        myFlags[i] = 1;
                                    }
                                    else
                                    {
                                        if(myFlags[i] != 1)
                                        {
                                            myFlags[i] = 0;
                                        }
                                    }
                                }
                            }
                            else
                            {
                                myFlags[i] = 0;
                            }
                            StartCounterTime = StartCounterTime.addMinutes(1);
                        }
                        AvailabilityByDay Availabilitytemp = new AvailabilityByDay(StartCounterTime.date(),myFlags);
                        Availbd.add(Availabilitytemp);
                        incrementday = incrementday.adddays(1); 
                        StartCounterTime  = dateTime.newInstance(incrementday,time.newInstance(6,0,0,0)); 
                    }
                    
                    ListDateSlots1 = new List<ListDateWithSlots>();
                    c = 1;
                    
                    for(AvailabilityByDay AD:Availbd)
                    {
                        Slot1 = new List<AvailableSlots>();
                        
                        mapstart = 0;
                        mapend = 1020; 
                        If(AD.dateavailbility == Startdate)
                        {
                            datetime StartTime = datetime.newinstance(Startdate,time.newinstance(6,0,0,0));
                            If(StartTime > EndDateTimeSelectStart)
                            {
                                mapstart = 0;
                            }
                            else
                            {    
                                Decimal Milliseconds = EndDateTimeSelectStart.getTime() - StartTime.getTime() ; 
                                Decimal Minuteconvert = Milliseconds / (1000.0*60.0);
                                mapstart = (integer)(Minuteconvert);
                                if(mapstart > 1020){mapstart = 1020;}
                            }
                        }
                        
                        If(AD.dateavailbility == Enddate)
                        {
                            datetime StartTime = datetime.newinstance(Enddate.addDays(1),time.newinstance(2,0,0,0));
                            If(EndDateTimeSelectEnd >= StartTime)
                            {
                                mapend = 1020;
                            }
                            else
                            {    
                                Decimal Milliseconds = StartTime.getTime() - EndDateTimeSelectEnd.getTime(); 
                                Decimal Minuteconvert = Milliseconds / (1000.0*60.0);
                                mapend = (1020 - (integer)(Minuteconvert));
                                if(mapend < 0){mapend = 0;}
                            }
                        }

                        for(i=mapstart;i<mapend;i++)
                        {
                            if(AD.availabletimeslots[i]==0)
                            {
                                if(i == 0 || i == mapstart)
                                {
                                    tempstart = Lookuptable.get(i);    
                                }
                                else{
                                    tempstart = Lookuptable.get(i-1);    
                                }
                                do 
                                {
                                    i++;
                                    Integer remainder = math.mod(i,60);
                                    if(remainder ==0){break;}
                                    if(i==mapend){break;}
                                } while (AD.availabletimeslots[i]==0);
                                
                                tempend = Lookuptable.get(i);
                                
                                datetime tempst = datetime.newInstance(AD.dateavailbility,tempstart);
                                datetime tempen = datetime.newInstance(AD.dateavailbility,tempend);
                                tzoneln = Contactnamemap.get(CST.Contact__c).Sunrun_user__r.TimeZoneSidKey;
                                system.debug('Time Zone'+tzoneln);
                                String tempstr = tempst.format(); 
                                String tempend = tempen.format(); 
                                //String tempstr1 = tempst.format('M/d/yyyy H:mm a',tzoneln); 
                                //String tempend1 = tempen.format('M/d/yyyy H:mm a',tzoneln); 
                                String tempstr1 = tempst.format(); 
                                String tempend1 = tempen.format(); 
                                
                                AvailableSlots tempslot =  new AvailableSlots(tempst,tempen,tempstr,tempend,tempstr1,tempend1);
                                Slot1.add(tempslot);
                                c = c + 1;
                            }
                        }
                        if(Slot1.size() == 0){
                            system.debug(slot1);   
                        }
                        
                        ListDateWithSlots templist = new ListDateWithSlots(AD.dateavailbility,Slot1);
                        ListDateSlots1.add(templist);
                        mapdate = mapdate.addDays(1);
                    }
                    
                    FinalListofSlots tempfinal = new FinalListofSlots(CST.Contact__c,Contactnamemap.get(CST.Contact__c).Name,Skilllevelmap.get(CST.Contact__c),ListDateSlots1,tzoneln);
                    FinallistSl.add(tempfinal);
                }    
                
                Table=true;
            }
            else
            {
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
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL,'No contact found for the given branch '+Branch);
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
    
    public void appointmentOpen(){
        displayPopup = true;
        appt.Appointment_Date_time__c= paramstdate ;
        appt.Appointment_End_Date_Time__c= parameddate ;
        appt.Event_Assigned_To__c=paramcontact;
        appt.Opportunity__c=paramopportunity;
        appt.Appointment_Description__c = oppa.name +'\r\n' +' Please Find the Link For More Details  '+'\r\n' + System.URL.getSalesforceBaseUrl().toExternalForm() +'/'+paramopportunity;     
    }
    
    public void closePopup(){
        displayPopup = false;     
        paramstdate =null;
        parameddate =null;
        paramopportunity =null;
        paramcontact=null;
    }
    
    public void saveAppointment(){
        insert appt;
        displayPopup = false;  
        appt.clear();  
    }
    
}