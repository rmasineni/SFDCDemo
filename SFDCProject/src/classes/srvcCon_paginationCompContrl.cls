public class srvcCon_paginationCompContrl {

    
    public List<sObject> sObjLst {get;set;}
    public List<String> objFields {get;set;}
    public List<String> hdrValue {get;set;}
    public string refreshFlag {get;set;}
    public set<String> redirectColNames =  new Set<String>();
    list<sobject> sobj {get;set;}
    
    public set<string> getRedirectColNames (){
        if(redirectColNames.isEmpty()  ){
            redirectColNames.add('Name');
            redirectColNames.add('Case Number');  
        }
        return redirectColNames;
    }
    
  /*  list<sobject> sobj {get{
        if (sObj == null) {
            sobj = new list<sObject>();
            return sobj;
        }
        else 
            return  sobj;
    } set;} */
    
    public srvcCon_paginationCompContrl(){
       
        if(refreshFlag == 'true'){
            getSobjRecords();
            refreshFlag = 'false';
        }
            
    }
    

  public ApexPages.StandardSetController con {
   get {

      if(sObjLst != Null)
			System.debug('>> sObjLst' + sObjLst.size());
       
           if(con == null)
             if(sObjLst != Null){
                 System.debug('>> sObjLst' + sObjLst.size());
               con = new ApexPages.StandardSetController(sObjLst);
              
           //Setting the pagination size
           con.setPageSize(5);
            }
           return con;
       

           
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