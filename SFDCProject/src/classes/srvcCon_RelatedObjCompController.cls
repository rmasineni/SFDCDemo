public class srvcCon_RelatedObjCompController {

    //  public list<sObject> comList {get;set;}
    public list<sObject> accList {get;set;}
    //public list<Contact> conList {get;set;}
    //public list<Case> caseList {get;set;}
    public string objTitle {get;set;}
    public list<String> objHeaderValue{get; set;}
  //  public list<String> colNames{get; set;}
    public string objectType {get;set;}
    public list<sObject> childRecrds {get;Set;}
    public string childObjType {get;set;}
    
// ----------------------------------------
    //public List<sObject> sObjLst {get;set;}
    public List<String> objFields {get;set;}
    public List<String> hdrValue {get;set;}
    public string refreshFlag {get;set;}
    public set<String> redirectColNames =  new Set<String>();
    //list<sobject> sobj {get;set;}
    public static boolean PageRefresh{get; set;}
    public list<sObject> childConRecList {get;set;}
    
    public set<string> getRedirectColNames (){
        if(redirectColNames.isEmpty()  ){
            redirectColNames.add('Name');
            redirectColNames.add('CaseNumber');  
        }
        return redirectColNames;
    }
    
 //----------------------------------------------------------------------------
  public list<sobject> sobj {get{
        if (sObj == null) {
            sobj = new list<sObject>();
            return sobj;
        }
        else 
            return  sobj;
    } set;} 
    
    
    
    public ApexPages.StandardSetController con {
   get {
       // if(PageRefresh==true){con=null;}
    //initializing con with the records.
    //System.debug('>> sObjLst' + sObjLst.size());
     
       
           if(con == null)
             if(childRecrds != Null){
                 System.debug('>> childRecrds2' + childRecrds.size());
               con = new ApexPages.StandardSetController(childRecrds);
              System.debug('>> con.hasPrevious' + con.getHasPrevious());
           //Setting the pagination size
           con.setPageSize(5);
            }
           return con;
       
        //   }
     //  else return null;
           
   }
   set;
  }
    
  
   
  //Method which returns subset of records from the sObjLst.
  public List<sobject> getSobjRecords() {  
  
      if(con != null){
          
          sobj =  (List<sobject>)con.getRecords();
          system.debug('>>Child sobjSeize' + sobj.size()  );
          System.debug('>> con.hasPrevious' + con.getHasPrevious());
System.debug('>> con.getHasNext' + con.getHasNext());
      }
      
          return sobj;
   //Type Casing the records and returning to display on the page.
    
  }


      //----------------------------------------
    
    
    public class Key {
        public String sob {get; set;}
        public String field {get; set;}
        public String header{get;Set;}
        Key(String sob, String field, string header) {
            this.sob = sob;
            this.field = field;
            this.header = header;
        }
    }
    public List<Map<String, SObject>> items {
        get {
            List<Map<String, SObject>> sobjLst = new List<Map<String, SObject>>();
          if( srvcConsoleUtil.Account.equalsIgnoreCase(objectType) || srvcConsoleUtil.Contact.equalsIgnoreCase(objectType) || srvcConsoleUtil.Cases.equalsIgnoreCase(objectType)   || 
             srvcConsoleUtil.Opportunity.equalsIgnoreCase(objectType) ||  srvcConsoleUtil.ServiceContract.equalsIgnoreCase(objectType) ||  srvcConsoleUtil.FSDispatch.equalsIgnoreCase(objectType) ) {
             sobjLst = getObjectList(srvcConsoleUtil.Account, acclist);
           // system.debug('here--'+sObjLst);
          }
            return sobjLst; 
        }
    }
    
    public List<Map<String, SObject>> ParentObjLst() {
        return items;
    }
    
    public Integer getRecCount (){
        return childRecrds.size();
    }
       public List<Map<String, SObject>> childitems {
             get {
            List<Map<String, SObject>> sobjLst = new List<Map<String, SObject>>();
             childConRecList = getSobjRecords() ;
            if(childConRecList.size() > 0 && !childConRecList.isEmpty() )
            sobjLst = getObjectList(childObjType, childConRecList);
            return sobjLst; 
             }
    }
    
    
    public List<Map<String, SObject>> getObjectList ( string objType, list<sobject> objlist ){
        List<Map<String, SObject>> lstSobj = new List<Map<String, SObject>>(); 
       // list<contact> conList = new list<contact> ();
        for (Integer i = 0; i < objlist.size() ; i++) {
                Map<String, SObject> m = new Map<String, SObject>();
                m.put(objType , objlist[i]);
                lstSobj.add(m);
            }

        system.debug('>>lstSobj' + lstSobj );
        return lstSobj;
        
    }
        
    
    public Key[] pAccntKeys {
        get {
            return new Key[] {
                    new Key(srvcConsoleUtil.Account, 'Name', 'Account Name'),
                    new Key(srvcConsoleUtil.Account, 'Phone', 'Phone'),
                    new Key(srvcConsoleUtil.Account, 'Owner.name', 'Owner Name')
                    };
        }
    }
    
     
    
      public Key[] contKeys {
        get {
            return new Key[] {
                    new Key(srvcConsoleUtil.Contact, 'Name', 'Contact Name'),
                    new Key(srvcConsoleUtil.Contact, 'Phone', 'Phone'),
                    new Key(srvcConsoleUtil.Contact, 'Account.Name', 'Account Name'),
                    new Key(srvcConsoleUtil.Contact, 'Owner.name', 'Owner Name')
                    };
        }
    }
    
        public Key[] caseKeys {
        get {
            return new Key[] { //'Customer_Name__c','Reason','Status','LastModifiedDate'
                	new Key(srvcConsoleUtil.Cases, 'CaseNumber', 'Case Number'),
                    new Key(srvcConsoleUtil.Cases, 'Customer_Name__c', 'Customer Name'),
                    new Key(srvcConsoleUtil.Cases, 'Reason', 'Case Reason'),
                    new Key(srvcConsoleUtil.Cases, 'Status', 'Status'),
                    new Key(srvcConsoleUtil.Cases, 'LastModifiedDate', 'Date of Last Activity ')

                    };
        }
    }
    
    public Key[] oppKeys {
        get {
            return new Key[] {
                    new Key(srvcConsoleUtil.Opportunity, 'Name' , 'Opty Name'),
                    new Key(srvcConsoleUtil.Opportunity, 'StageName', 'Status'),
                    new Key(srvcConsoleUtil.Opportunity, 'Owner.name', 'Owner Name')
                    };
        }
    }
    
    public Key[] scKeys {
        get {
            return new Key[] { 
                new Key(srvcConsoleUtil.ServiceContract, 'Name', 'Contract Name'),
                new Key(srvcConsoleUtil.ServiceContract, 'Customer_Name__c', 'Customer Name'),
                new Key(srvcConsoleUtil.ServiceContract, 'Agreement_Number__c', 'Agreement Number'),
                new Key(srvcConsoleUtil.ServiceContract, 'Home_Address__c', 'Home Address'),
                new Key(srvcConsoleUtil.ServiceContract, 'City__c', 'City'),
                new Key(srvcConsoleUtil.ServiceContract, 'State__c', 'State'),
                new Key(srvcConsoleUtil.ServiceContract, 'Status__c', 'Status')
               // new Key(srvcConsoleUtil.ServiceContract, 'Description', 'Description')
                    };
        }
    }
    
      public Key[] fsdKeys {
        get {
            return new Key[] {  
                    new Key(srvcConsoleUtil.FSDispatch, 'Name', 'FSD Name'),
                    new Key(srvcConsoleUtil.FSDispatch, 'FS_Customer_Name__c', 'Customer Name'),
                    new Key(srvcConsoleUtil.FSDispatch, 'Case_Reason__c', 'Case Reason'),
               		new Key(srvcConsoleUtil.FSDispatch, 'Subreason__c', 'Case Subreason'),
                    new Key(srvcConsoleUtil.FSDispatch, 'LastModifiedDate', 'Last Modified Date')
                    };
        }
    }
    
   /* public Key[] sceKeys {
        get {
            return new Key[] { 
                new Key(srvcConsoleUtil.SCE, 'Name', 'Name'),
                    new Key(srvcConsoleUtil.SCE, 'M1_Status__c', 'M1 Status'),
                    new Key(srvcConsoleUtil.SCE, 'M2_Status__c', 'M2 Status'),
                    new Key(srvcConsoleUtil.SCE, 'M3_Status__c', 'M3 Status'),
                    new Key(srvcConsoleUtil.SCE, 'Opportunity__c', 'Opportunity Name')
                    };
                        }
    } */
    
       public Key[] sTransferKeys {
        get {
            return new Key[] { 
                new Key(srvcConsoleUtil.ServiceTransfer, 'Name', 'Name'),
                    new Key(srvcConsoleUtil.ServiceTransfer, 'Credit_Approved_On__c', 'Credit Approved On'),
                    new Key(srvcConsoleUtil.ServiceTransfer, 'Original_Annual_Increase__c', 'Original Annual Increase')
                    };
                        }
    }
    
    public Key[] getChildObjCols() {
        if(childObjType == srvcConsoleUtil.Cases){
            return caseKeys;
        }
        else if(childObjType == srvcConsoleUtil.Contact){
            return contKeys;
        }
        else if(childObjType == srvcConsoleUtil.Opportunity){
            return oppKeys;
        }
        else if(childObjType == srvcConsoleUtil.ServiceContract){
            return scKeys;
        }
         else if(childObjType == srvcConsoleUtil.FSDispatch){
            return fsdKeys;
        }
      /*   else if(childObjType == srvcConsoleUtil.SCE){
            return sceKeys;
        } */
         else if(childObjType == srvcConsoleUtil.ServiceTransfer){
            return sTransferKeys;
        }
        return null;
    }
     
    public Key[] getParentObjCols() {
        if(srvcConsoleUtil.Account.equalsIgnoreCase(objectType) || srvcConsoleUtil.Contact.equalsIgnoreCase(objectType) || srvcConsoleUtil.Cases.equalsIgnoreCase(objectType)   || 
             srvcConsoleUtil.Opportunity.equalsIgnoreCase(objectType) ||  srvcConsoleUtil.ServiceContract.equalsIgnoreCase(objectType) || srvcConsoleUtil.FSDispatch.equalsIgnoreCase(objectType) ){
            return pAccntKeys;
        }
       /* else if(objectType == srvcConsoleUtil.Contact){
            return contKeys;
        } */
        
        return null;
    }
   
   
}