public with sharing class srvcCon_CustomSearchController{
    
    public List<List<sObject>> results {get;set;}
    public List<List<sObject>> relatedRec {get;set;}
    public String searchString {get;set;}
    public Integer countContacts {get;set;}
    public Integer countAccounts {get;set;}
    public Integer countCases {get;set;}
    public Integer countOpp {get;set;}
    public Integer countSC {get;set;}
    public Integer countFSD {get;set;}
    public Integer totalCount {get;set;}
    public String recId {get;set;}
    public String objType {get;set;}
    //public String recName {get;set;}
    public list <contact> childConList {get;set;}
    public list <case> childCaseList {get;set;}
    public list <Opportunity> childOppList {get;set;}
    public list <ServiceContract> childSCList {get;set;}
    public  List<FS_Dispatch__c> childFSDList {get; set;} 
    public  List<Service_Contract_Event__c> childSCEList {get; set;} 
    public  List<Reassignment__c> childSTransferList {get; set;} 
    public  List<FS_Dispatch__c> FsdList {get; set;} 
    //public  List<Service_Contract_Event__c> sceList {get; set;} 
    public  List<Reassignment__c> sTransferList {get; set;}
    
    
    public String childType {get;Set;}
    public list<sObject> accSearchList {get;set;}
    public list<sObject> cntSearchList {get;set;}
    public list<sObject> oppSearchList {get;set;}
    public list<sObject> scSearchList {get;set;}
    public list<sObject> caseSearchList {get;set;}
    public list<sObject> FSDSearchList {get;set;}
      
    public list <string> accSearchFieldLst {get; set;}
    public list <string> cntSearchFieldLst {get; set;}
    public list <string> oppSearchFieldLst {get; set;}
    public list <string> scSearchFieldLst {get; set;}
    public list <string> caseSearchFieldLst {get; set;} 
     public list <string> FSDSearchFieldLst {get; set;} 
    
    public list <string> accSearchHeaderNames {get; set;}
    public list <string> cntSearchHeaderNames {get; set;}
    public list <string> oppSearchHeaderNames  {get; set;}
    public list <string> scSearchHeaderNames  {get; set;}
    public list <string> caseSearchHeaderNames  {get; set;} 
    public list <string> FSDSearchHeaderNames  {get; set;} 
    
   // ----------------------------------------
    public List<sObject> sObjLst {get;set;}
    public List<String> objFields {get;set;}
    public List<String> hdrValue {get;set;}
    public string refreshFlag {get;set;}
    public set<String> redirectColNames =  new Set<String>();
    list<sobject> sobj {get;set;}
    public static boolean PageRefresh{get; set;}
    
    public set<string> getRedirectColNames (){
        if(redirectColNames.isEmpty()  ){
            redirectColNames.add('Name');
            redirectColNames.add('CaseNumber');  
        }
        return redirectColNames;
    }
      //----------------------------------------
       public srvcCon_CustomSearchController() {
        countContacts = 0;
        countAccounts = 0;
        countCases = 0;
        countOpp = 0;
        countSc = 0;
        countFSD = 0;
        getRelatedRecords();
           PageRefresh= false;   
         //  integer total_size = 100 ; 
    }
    
    public pageReference searchsObject() {
        if(!String.isblank(searchString)) {
            results = new List<List<sObject>>();
            String srch = '*'+searchString+'*';
            results = [FIND :srch IN ALL FIELDS
                       RETURNING Contact(Id, Phone,name, FirstName, LastName,Account.Name, Owner.Name LIMIT 100 ),
                       Lead(Id, Phone, FirstName, LastName LIMIT 5), Account(Id, Phone, Name, Owner.Name,AccountNumber LIMIT 100 ), 
                       Case(CaseNumber, Subject,Id, Owner.Name,Customer_Name__c,Reason,Status,LastModifiedDate LIMIT 100 ),
                       Opportunity(Id,Amount, Name, StageName,Account.Name, Owner.Name LIMIT 100 ),
                       ServiceContract(Id,name, status,Account.Name,Contact.Name, Owner.Name, TotalPrice, Customer_Name__c,Agreement_Number__c,Home_Address__c,City__c,State__c,Description,Status__c LIMIT 100 ),
                      FS_Dispatch__c(id,name,FS_Service_Contract__r.Name, FS_Dispatch_Phase__c,FS_Dispatch_State__c,FS_Customer_Name__c,Case_Reason__c,Subreason__c,LastModifiedDate LIMIT 100)];

            countContacts = results[0].size();
            countAccounts = results[2].size();
            countCases = results[3].size();
            countOpp = results[4].size();
            countSc = results[5].size();
            countFSD = results[6].size();
            totalCount = countContacts + countAccounts+ countCases + countOpp + countSc +countFSD;
            
            
            
            cntSearchList = results[0];
            accSearchList = results[2];
            caseSearchList  = results[3];
			oppSearchList = results[4];
			scSearchList  = results[5];
            FSDSearchList = results[6];
            
            system.debug('>>cntSearchList'  + cntSearchList.size() );
            system.debug('>>results'  +  results[0].size());
			// List of Columns to display on the search Page for each Objects
			
            accSearchFieldLst = new list<String>{'id','Name','Phone','Owner.Name','AccountNumber'};
            cntSearchFieldLst = new list<String>{'id','Name','Phone', 'Account.Name','Owner.Name'};
            caseSearchFieldLst = new list<String>{'id','CaseNumber', 'Customer_Name__c','Reason','Status','LastModifiedDate' };
            scSearchFieldLst = new list<String>{'id','Name','Customer_Name__c','Agreement_Number__c','Home_Address__c','City__c','State__c','Status__c'};
            oppSearchFieldLst = new list<String>{'id','Name','StageName','Owner.Name'};
                FSDSearchFieldLst = new list<String>{'id','Name','FS_Customer_Name__c', 'Case_Reason__c','Subreason__c', 'LastModifiedDate'};
             // List of Column header Names on the Search page fro each Objects
              
                accSearchHeaderNames = new list<String>{'id','Name','Phone','Owner Name', 'Account Number'};
                cntSearchHeaderNames = new list<String>{'id','Name','Phone', 'Account Name','Owner Name'};
               	caseSearchHeaderNames  = new list<String>{'id','Case Number','Customer Name', 'Case Reason','Status','Date of Last Activity' };
                scSearchHeaderNames = new list<String>{'id','Contract Name','Customer Name','Agreement Number','Home Address','City','State','Status'};
              	oppSearchHeaderNames = new list<String>{'id','Name','Stage Name','Owner Name'};
				FSDSearchHeaderNames = new list<String>{'id','Name','Customer Name', 'Case Reason','Case Subreason','Last Modified Date'};                 
                PageRefresh =true;
        }
        return null;
        
    }
    
   /* public list<sObject> getObjectList(string objType) {
        if (objType.containsIgnoreCase(srvcConsoleUtil.Account)){
           return results[2];
        }
        return null;
    }*/
    public pageReference redirectToRelations() {
        pageReference pageNew = new PageReference('/apex/srvcConsole_OnSelectRelatedSearch');
        getRelatedRecords();
        // pageNew.setRedirect(true);
        return pageNew;
    }
    
    public list<Account> accList {get;set;}
    public list<Contact> conList {get;set;}
    public list<Case> caseList {get;set;}
    public list<String> headerValue {get;set;}
    public list<String> colNames {get;set;}
    public list<contact> childRecs {get;Set;}
    
    
    public void getRelatedRecords() {
        
        accList = new List<Account> ();
        conlist = new List<Contact>();
        caseList = new List<Case>();
        childConList = new List<Contact>();
        childCaseList = new List<Case>();
        childOppList = new List<Opportunity>();
        childSCList = new List<ServiceContract>();
        set<id> scid = new set<id>();
        childFSDList = new list<FS_Dispatch__c>();
        childSCEList = new list<Service_Contract_Event__c>();
        childSTransferList = new list<Reassignment__c>();
        //try{
        objType = ApexPages.currentPage().getParameters().get('objType');
        System.debug('ObjectType' + objType + ApexPages.currentPage().getParameters().get('RecId'));
        if(srvcConsoleUtil.Account.equalsIgnoreCase(ApexPages.currentPage().getParameters().get('objType'))) {
            System.debug('>> ObjType'+ objType);
            /*accList = new List<Account> ();
            conlist = new List<Contact>();
            caseList = new List<Case>();
            childOppList = new List<Opportunity>();
            childSCList = new List<ServiceContract>();
            set<id> scid = new set<id>();
            childFSDList = new list<FS_Dispatch__c>(); */
            // Account acc = [Select Id, Phone, Name, Owner.Name, (Select Id, FirstName, LastName, Phone, owner.Name, Account.Name
            //  from Contacts limit 5), (Select Name, StageName, Id from Opportunities),
            //   (Select CaseNumber, Subject,Id, Owner.Name from Cases limit 5) from Account where Id=:ApexPages.currentPage().getParameters().get('RecId') limit 1];
            //   accList.add(acc);
            // system.debug('>>accList[0].Contacts' + accList[0].Contacts.size());
            
            For ( account ac : [Select Id, Phone, Name, Owner.Name, (Select Id,Name, FirstName, LastName, Phone, owner.Name, Account.Name
                                                                     from Contacts ), (Select Name, StageName, Id, Owner.Name from Opportunities ),
                                (Select id, name,  Customer_Name__c,Agreement_Number__c,Home_Address__c,City__c,State__c,Description,Status__c  from ServiceContracts ),
                                (Select CaseNumber, Subject,Id, Owner.Name, Customer_Name__c,Reason,Status,LastModifiedDate from Cases ) from Account where Id=:ApexPages.currentPage().getParameters().get('RecId') limit 1]  ) {
                                    accList.add(ac);
                                    childConList= ac.Contacts;
                                    childCaseList = ac.Cases;
                                    childOppList = ac.Opportunities;
                                    childSCList = ac.ServiceContracts;
                                    //childRecs[1] = ac.Cases;
                                }
            scid = getScIdSet(childSCList);
            childFSDList = getFSDList(scid);
           // childSCEList = getSCEList(scid);
            childSTransferList =  getSTransferList(scid);
            //system.debug('>>accList[0].Contacts' + accList[0].Contacts.size());           
            headerValue = new list<String>{'Account Name','Phone','Owner'};
                colNames = new list<String>{'id','Phone','Owner.Name'};
                       
                    }
        	else if(srvcConsoleUtil.Contact.equalsIgnoreCase(ApexPages.currentPage().getParameters().get('objType'))) {
            /*childConList = new List<Contact>();
            accList = new List<Account> ();
            conlist = new List<Contact>();
            caseList = new List<Case>();
            childOppList = new List<Opportunity>();
            childSCList = new List<ServiceContract>();
           	set<id> scid = new set<id>();
            childFSDList = new list<FS_Dispatch__c>(); */
            Contact con = [SELECT Name,Phone, FirstName, LastName, Id,AccountId, Account.name,Account.Phone,Account.Owner.Name, 
                           owner.name, (Select CaseNumber,Subject,Id, Owner.Name,Customer_Name__c,Reason,Status,LastModifiedDate  from Cases)  ,   
                           (Select id, name,  Customer_Name__c,Agreement_Number__c,Home_Address__c,City__c,State__c,Description,Status__c  from ServiceContracts )
                           FROM Contact  where Id=:ApexPages.currentPage().getParameters().get('RecId') limit 1];
            
            childCaseList = con.Cases; 
            childConList.add(con);
            if(con.ServiceContracts!=null && con.ServiceContracts.size()>0)
                childSCList = con.ServiceContracts;
            accList.add(new Account(Id=con.AccountId,Name=con.Account.Name,phone=con.Account.Phone));
            for(Opportunity opp: [Select Name, StageName, Id, Owner.Name from Opportunity where AccountId =: con.AccountId ]) {
                childOppList.add(opp) ;
            }
                scid = getScIdSet(childSCList);
                childFSDList = getFSDList(scid);
               // childSCEList = getSCEList(scid);
                childSTransferList =  getSTransferList(scid);
            system.debug(accList);
            headerValue = new list<String>{'Account Name','Phone','Owner'};
                colNames = new list<String>{'id','Phone','Owner.Name'};
                    
                    }
        else if(srvcConsoleUtil.Cases.equalsIgnoreCase(ApexPages.currentPage().getParameters().get('objType'))) {
           /* accList = new List<Account> ();
            childConList = new List<Contact>();
            conlist = new List<Contact>();
            caseList = new List<Case>();
            childOppList = new List<Opportunity>();
            childCaseList = new List<Case>();
            childSCList = new List<ServiceContract>();
             set<id> scid = new set<id>();
            childFSDList = new list<FS_Dispatch__c>(); */
            case cas  = [Select CaseNumber,account.name,accountid,contactid,contact.lastname,contact.AccountId,Account.Phone,Account.Owner.Name,
                         contact.firstName, contact.name, Subject,Id, Owner.Name  ,contact.phone, contact.owner.name,Customer_Name__c,Reason,Status,LastModifiedDate 
                         from case where Id=:ApexPages.currentPage().getParameters().get('RecId') limit 1];
            childCaseList.add(cas); 
            accList = getAccList(cas.AccountId);
           	
            for (account ac: accList){
                childConList = ac.contacts; 
                childSCList = ac.ServiceContracts;
                childOppList= ac.Opportunities;
            }
             scid = getScIdSet(childSCList);
            childFSDList = getFSDList(scid);	
           // childSCEList = getSCEList(scid);
             childSTransferList =  getSTransferList(scid);
            
            
        }
        else if(srvcConsoleUtil.Opportunity.equalsIgnoreCase(ApexPages.currentPage().getParameters().get('objType'))) {
           /* accList = new List<Account> ();
            conlist = new List<Contact>();
            childConList = new List<Contact>();
            caseList = new List<Case>();
            childOppList = new List<Opportunity>();
            childSCList = new List<ServiceContract>();
            childCaseList = new List<Case>();
             set<id> scid = new set<id>();
            childFSDList = new list<FS_Dispatch__c>(); */
            Opportunity opp = [Select Id,Amount, Name, StageName,Account.Name, AccountId, Owner.Name,Account.Phone from Opportunity 
                               where Id=:ApexPages.currentPage().getParameters().get('RecId') limit 1];
            childOppList.add(opp);
            accList = getAccList(opp.AccountId);
            
            for (account ac: accList){
                childConList = ac.contacts; 
                childSCList = ac.ServiceContracts;
                childCaseList = ac.cases;
            }
             scid = getScIdSet(childSCList);
            childFSDList = getFSDList(scid);	
           // childSCEList = getSCEList(scid);
             childSTransferList =  getSTransferList(scid);
            
        }
        else if(srvcConsoleUtil.ServiceContract.equalsIgnoreCase(ApexPages.currentPage().getParameters().get('objType'))) {
          /*  accList = new List<Account> ();
            conlist = new List<Contact>();
            caseList = new List<Case>();
            childOppList = new List<Opportunity>();
            childSCList = new List<ServiceContract>();
            childConList = new List<Contact>();
            childCaseList = new List<Case>();
             set<id> scid = new set<id>();
            childFSDList = new list<FS_Dispatch__c>(); */
            ServiceContract sc =  [Select id, name, Status, owner.Name,
                                   AccountId, Account.Name, Account.phone, Customer_Name__c,Agreement_Number__c,Home_Address__c,City__c,State__c,Description ,Status__c
                                   from ServiceContract where Id=:ApexPages.currentPage().getParameters().get('RecId') limit 1];
            childSCList.add(sc);
            accList = getAccList(sc.AccountId);
            for(account acc: accList){
                childConList = acc.contacts;
                childCaseList= acc.cases; 
                childOppList = acc.Opportunities; 
            }
             scid = getScIdSet(childSCList);
            childFSDList = getFSDList(scid);
            //childSCEList = getSCEList(scid);
             childSTransferList =  getSTransferList(scid);
            
        }
        else if(srvcConsoleUtil.FSDispatch.equalsIgnoreCase(ApexPages.currentPage().getParameters().get('objType'))) {
           /* accList = new List<Account> ();
            conlist = new List<Contact>();
            caseList = new List<Case>();
            childOppList = new List<Opportunity>();
            childSCList = new List<ServiceContract>();
            childConList = new List<Contact>();
            childCaseList = new List<Case>();
             set<id> scid = new set<id>();
            childFSDList = new list<FS_Dispatch__c>(); */
            FS_Dispatch__c fsd =  [Select id,name,FS_Service_Contract__r.Name,FS_Service_Contract__r.AccountId, FS_Dispatch_Phase__c,FS_Dispatch_State__c ,FS_Customer_Name__c,Case_Reason__c,Subreason__c,LastModifiedDate
                                   from FS_Dispatch__c where Id=:ApexPages.currentPage().getParameters().get('RecId') limit 1];
            childFSDList.add(fsd);
            accList = getAccList(fsd.FS_Service_Contract__r.AccountId);
            for(account acc: accList){
                childConList = acc.contacts;
                childCaseList= acc.cases; 
                childOppList = acc.Opportunities; 
                childSCList = acc.ServiceContracts;
                scid = getScIdSet(childSCList);
               // childSCEList = getSCEList(scid);
                childSTransferList =  getSTransferList(scid);
            }
            
        } 
                    /*  }
            catch(Exception e){
            
            }*/
    }
    
  /*  public pageReference goBack() {
        return new PageReference('/apex/srvcConsole_CustomSearch');
        return null;
    } */
    
    public list<Account> getAccList (id accId ) {
        accList = new List<Account> ();
        if(accId != null){
            For ( account acnt : [Select Id, Phone, Name, Owner.Name, (Select Id, Name, FirstName, LastName, Phone, owner.Name, Account.Name
                                                                       from Contacts ), (Select Name, StageName, Id, Owner.Name from Opportunities ),
                                  (Select id, name, Status, owner.Name, Customer_Name__c,Agreement_Number__c,Home_Address__c,City__c,State__c,Description,Status__c  from ServiceContracts ),
                                  (Select CaseNumber, Subject,Id, Owner.Name,Customer_Name__c,Reason,Status,LastModifiedDate from Cases ) 
                                  from Account where Id=:accId limit 1] ){
                                      accList.add(acnt);         
                                  }
        }
        system.debug('Acc Opty List' + accList );
        return accList;
        
    }

    Public set<id> getScIdSet ( list<ServiceContract> scObj ) {
        set<id> scIdSet = new set<id>();
        for( ServiceContract sc : scObj  ){
            scIdSet.add(sc.id);
        }
        return scIdSet;
    }
      
    
    public list<FS_Dispatch__c> getFSDList (set<Id> scID ) {
        fsdList = new List<FS_Dispatch__c > ();
        
        if(scID != null){
            For ( FS_Dispatch__c fsd :  [Select id,name,FS_Service_Contract__r.Name,FS_Service_Contract__r.AccountId, FS_Dispatch_Phase__c,
                                         FS_Dispatch_State__c,FS_Customer_Name__c,Case_Reason__c,Subreason__c,LastModifiedDate 
                                         from FS_Dispatch__c where FS_Service_Contract__r.id in :scID ] ){
                                             fsdList.add(fsd);         
                                         }
        }
        
        return fsdList;
        
    }
    
       /* public list<Service_Contract_Event__c> getSCEList (set<Id> scID ) {
        sceList = new List<Service_Contract_Event__c > ();
        
        if(scID != null){
            For ( Service_Contract_Event__c sce :  [Select id,name,M1_Status__c,M2_Status__c,M3_Status__c,Opportunity__c from Service_Contract_Event__c
                                                    where Service_Contract__r.id in :scID ] ){
                                             sceList.add(sce);         
                                         }
        }
    
        return sceList;
        
    } */

    
        public list<Reassignment__c> getSTransferList (set<Id> scID ) {
        sTransferList = new List<Reassignment__c > ();
        
        if(scID != null){
            For ( Reassignment__c SCTransfer :  [Select id,name,Credit_Approved_On__c,Original_Annual_Increase__c  from Reassignment__c
                                                    where Service_Contract__r.id in :scID ] ){
                                             sTransferList.add(SCTransfer);         
                                         }
        }
    
        return sTransferList;
        
    }
    
    //Pagination for tables----------------------------------------------------------------------------
    public ApexPages.StandardSetController con {
        get {
            if(PageRefresh==true){
                con=null;
            }

            if(sObjLst != Null)
                System.debug('>> sObjLst' + sObjLst.size());
            
            if(con == null)
                if(sObjLst != Null){
                    
                    con = new ApexPages.StandardSetController(sObjLst);
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
        sobj =new list<sobject>();
        if(con != null){
            system.debug('>> con' + sobj.size()  );
            sobj =  (List<sobject>)con.getRecords();
        }
        
        return sobj;
        //Type Casing the records and returning to display on the page.
        
    }
    
    class DataTableWrapper {
        
        public String fields { get; set; }
        public String Header { get; set;}
        
        public DataTableWrapper(String fields, String Header) {
            this.fields = fields;
            this.Header = Header;
        } 
    }  
    
    
    public DataTableWrapper[] getSobjColumnHeader() {
        
        integer i = 0;
        DataTableWrapper[] colHeaderWrapper =   new DataTableWrapper[]{};
            if(objFields.size() > 0 && hdrValue.size()>0 ){
                
                for (i=0; i<objFields.size() ; i++){
                    colHeaderWrapper.add(new DataTableWrapper( objFields[i], hdrValue[i]));
                }     
            }
        return colHeaderWrapper;
    }
 
    
}