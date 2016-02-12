public without sharing class ReferralMetricsController {

public Double numcust{get;set;}
public Double numcustreferring{get;set;}
public Double percentreferring{get;set;}
public Set<Id> CustomerIds{get;set;}
public Set<Id> ReferringCustomerIds{get;set;}
public Promotion__c therange{get;set;}

public void ReferralMetricsController(){}

public void init(){
	numcust = 0.0;
	numcustreferring = 0.0;
	Set<Id> setCustomerIds = new Set<Id>();
	Set<Id> setReferringCustomerIds = new Set<Id>();
	therange = new Promotion__c();
	//
	String fDate = ApexPages.CurrentPage().getparameters().get('fromDate');
    String tDate = ApexPages.CurrentPage().getparameters().get('toDate');
    //
    if(fDate != null && tDate != null)
    {
       therange.Start_Date__c = date.newInstance(Integer.valueOf(fDate.substring(0,4)), Integer.valueOf(fDate.substring(5,7)), Integer.valueOf(fDate.substring(8))); 
       therange.End_Date__c = date.newInstance(Integer.valueOf(tDate.substring(0,4)), Integer.valueOf(tDate.substring(5,7)), Integer.valueOf(tDate.substring(8)));
    }
    else
    {  
       therange.Start_Date__c = date.newInstance(2000,1,1);
       therange.End_Date__c = date.newInstance(2050,1,1);
    }    
	/*
	  AggregateResult[] gacust = [select count(customer_Contact__c) custcount
	                             from Generation_Assets__c 
	                            where SR_Signoff__c <> null 
	                              and Date_Cancelled__c =  null];
   
      for(AggregateResult ar: gacust)
      {
         numcust = Double.ValueOf(ar.get('custcount'));     
      }  
    */
   
   for(Generation_Assets__c ga:[select customer_Contact__c
	                             from Generation_Assets__c 
	                            where SR_Signoff__c <> null 
	                              and Date_Cancelled__c =  null])
   {
	  if(!setCustomerIds.Contains(ga.Customer_Contact__c))
	  {
	  	numcust++;
	  	setCustomerIds.add(ga.Customer_Contact__c);
	  }	  
   }    
   CustomerIds = setCustomerIds;

   for(Referral_Input__c ri:[Select Id, Source_Contact_Id__c, CreatedDate 
                               FROM Referral_Input__c 
                              where Source_Contact_Id__c in :CustomerIds
                                ])
   {
   	   if(!setReferringCustomerIds.Contains(ri.Source_Contact_Id__c))
   	   {
   	   	  if(ri.CreatedDate >= therange.Start_Date__c && ri.CreatedDate <= therange.End_Date__c)
   	   	  {
   	         numcustreferring++;
   	         setReferringCustomerIds.add(ri.Source_Contact_Id__c);
   	   	  }
   	   }   	
   }
   percentreferring = (numcustreferring/numcust)*100;

}

public pageReference refreshData() {
  PageReference pr = new PageReference('/apex/ReferralMetrics?fromDate=' + String.ValueOf(therange.Start_Date__c).substring(0,10) + '&toDate=' + String.ValueOf(therange.End_Date__c).substring(0,10));
  pr.setRedirect(true);
  return pr;
}

}