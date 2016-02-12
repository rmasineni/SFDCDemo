/**
This class is used to truncate the Employee master data and to invoke the deactivate the terminated Users method.
Date: 12/2/2015 IST
**/

public class Employee_MasterUtil {

     //The below variables are used to avoid the governal limit of maximun list size (1000)
     private transient limitWrapper[] thousandBlocks = new limitWrapper[]{};
     private final integer listLimit;
     
     //The below variables are used for pagination
     private integer counter_pagination=0;  //keeps track of the offset
     private integer list_size=20; //sets the page size or number of rows
     public integer total_size; //used to show user the total size of the list
          
    //Constructor
     public Employee_MasterUtil() 
     {
         //Setting the list size limit such that it doesnt hit the governal limit
         listLimit = 999;
         //Setting the count of the records to be shown in pagination
         total_size = [select count() from Employee_Master__c]; 
     }
      
     //Pagination code to display the records in the VF page
     public limitWrapper[] getthousandBlocks()
     {
        thousandBlocks = new limitWrapper[]{};
       
        //Setting the counters to zero such that we track the number of records added to the List
        integer counter= 0;
        integer loopCount = 0;
        transient  Employee_Master__c[] tmpcase = new Employee_Master__c[]{};
          
        //Using limit anf offset for pagination        
        for(Employee_Master__c EM:[SELECT EMAIL_ADDRESS__c,Deactivate__c,Termination_Status__c FROM Employee_Master__c limit:list_size offset:counter_pagination])
        {
            if(counter < listLimit)
            {
                tmpcase.add(EM);
                counter++;
            }
            else
            {
                loopCount++;
                thousandBlocks.add(new limitWrapper(tmpcase,loopCount));
                tmpcase = new Employee_Master__c[]{};
                tmpcase.add(EM);
                counter = 0;
            }           
        }
       
        if(thousandBlocks.size() == 0)
        {
            loopCount++;
            thousandBlocks.add(new limitWrapper(tmpcase,loopCount));
        }
         
        return thousandBlocks;
    }
   
   //Wrapper class to display the Employee Master records in batches
    public class limitWrapper
    {
        public Employee_Master__c[] employeeMaster{get;set;}
        public integer blockNumber {get;set;}
        public limitWrapper(Employee_Master__c[] EM, integer i)
        {
            employeeMaster = EM;
            blockNumber = i;
        }
       
    }
    
    //Method used for pagination
    public PageReference Beginning() { //user clicked beginning
      counter_pagination= 0;
      return null;
   }

    //Method used for pagination
    public PageReference Previous() { //user clicked previous button
      counter_pagination-= list_size;
      return null;
   }

    //Method used for pagination
    public PageReference Next() { //user clicked next button
      counter_pagination+= list_size;
      return null;
   }
   
   //Method used for pagination
   public PageReference End() { //user clicked end
      counter_pagination= total_size - math.mod(total_size, list_size);
      return null;
   }
   
   //Method used for pagination
   public Boolean getDisablePrevious() { 
      //this will disable the previous and beginning buttons
      if (counter_pagination>0) return false; else return true;
   }

   //Method used for pagination
   public Boolean getDisableNext() { //this will disable the next and end buttons
      if (counter_pagination+ list_size < total_size) return false; else return true;
   }
   
   //Method used for pagination
   public Integer getTotal_size() {
      return total_size;
   }

   //Method used for pagination
   public Integer getPageNumber() {
      return counter_pagination/list_size + 1;
   }


   //Method used for pagination
   public Integer getTotalPages() {
      if (math.mod(total_size, list_size) > 0) {
         return total_size/list_size + 1;
      } else {
         return (total_size/list_size);
      }
   }
      //Method to truncate all the data in Employee_Master__c object before import
      public void truncateAllData()
           {
                      
                     List<Employee_Master__c> SobjLst = [select id from Employee_Master__c];
                     if(SobjLst!= null && SobjLst.size() > 0) 
                     {
                          delete SobjLst;    
                          thousandBlocks.clear();
                          counter_pagination = 0;
                          total_size = 0; 
                                 
                     }
                     
                     
                    
           }
           
            //Method to invoke the batch class to Deactivate the User
              
           public void deactivateUser() 
           {
                                 
                 Employee_MasterDeactivatedUsers EMdeactivate = new Employee_MasterDeactivatedUsers();
                 
                 EMdeactivate.DeactivatedUser();
                
                  
            }
  
}