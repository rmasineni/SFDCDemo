@isTest
private class Test_Performance_Guarantee {

    public static ServiceContract scObj;
    public static Service_Contract_Event__C scEventObj;
    
    static testMethod void myUnitTest() {
        //Creating an Opportunity record
          List<Opportunity> oppList = New List<Opportunity>();
             Opportunity Opp = new Opportunity();
          Opp.Name = 'TestOpp';
             Opp.CloseDate = date.today();
            Opp.StageName = 'Closed Won';
            oppList.add(Opp);
            insert oppList;
             System.debug('Created an Opportunity ' + Opp.Id);
      //Creating a proposal record
          List<Proposal__c> proList = new List<Proposal__c>();
          Proposal__c p = New Proposal__c();
          p.Upfront_Payment__c = 70000;
          p.System_Size_STC_DC__c = 25;
          p.Sales_Rep_Email__c = 'testrep@yopmail.com';
          p.Name = 'Testproposal';
          p.Opportunity__c = Opp.Id;
          p.Date_Issued__c = date.today();
          p.Mode_Name__c  = 'Modetest';
          p.Stage__c  = 'SR Approved';
          p.Sunrun_Credit_Status__c = 'SR Credit Approved';
          proList.add(p);
          insert proList;
            System.debug('Created an Proposal ' + p.Id);
        //Create a Proposal Performance Guaranteed record.
          List<Proposal_Performance_Guarantee__c> ppgList = new List<Proposal_Performance_Guarantee__c>();
          Proposal_Performance_Guarantee__c ppg = New Proposal_Performance_Guarantee__c();
          ppg.Year__c = '2000' ;
          ppg.Refund_Rate__c = 500;
          ppg.Guranteed_Output__c = 10;
          ppg.Proposal__c = p.Id;
          ppgList.add(ppg);
          insert ppgList;
          System.debug('Created an Proposal Performance Guaranteed' +ppg.Id);
          
       /*   Proposal_Performance_Guarantee__c ppg2 = New Proposal_Performance_Guarantee__c();
          ppg2.Year__c = '2001' ;
          ppg.Refund_Rate__c = 600;
          ppg.Guranteed_Output__c = 10;
          ppg.Proposal__c = p.Id;
          ppgList.add(ppg2);
          insert ppgList;
          System.debug('Created an Proposal Performance Guaranteed' +ppg2.Id); */
          
          //Creating an Account
           List<Account> accList = New List<Account>();
           Account a = New Account();
           a.Name = 'TestAccount'; 
           accList.add(a);
           insert accList;
            System.debug('created an Account ' + a.Id); 
          
         //Create a ServiceContract Record.
            List<ServiceContract> scList = New List<ServiceContract>();
           ServiceContract sc = New ServiceContract();
           sc.Name = 'Testsc';
           sc.AccountId = a.Id;
           sc.Name = 'Testservicecontract';
           sc.Proposal__c = p.Id;
           sc.Legacy_Asset_Number__c = '10082004';
           scList.add(sc);
           insert scList;
           System.debug('Created an ServiceContract ' + sc.Id);
           
        /*   ServiceContract sc2 = New ServiceContract();
            sc.Name = 'Testsc2';
            sc.AccountId = a.Id;
            sc.Name = 'Testservicecontract2';
            sc.Proposal__c = p.Id;
            sc.Legacy_Asset_Number__c = '07132009'; 
            scList.add(sc2);
            insert scList;
            System.debug('Created an ServiceContract ' + sc2.Id); */
            
           List<Contract_Performance_Guarantee__c> cpgList = new List<Contract_Performance_Guarantee__c>();
             Contract_Performance_Guarantee__c cpg = new Contract_Performance_Guarantee__c();
              cpg.Service_Contract__c = sc.id;
                cpg.Guaranteed_Output__c = ppg.Guranteed_Output__c;
                cpg.Refund_Rate__c = ppg.Refund_Rate__c;
                cpg.Year__c =ppg.Year__c;  
                cpgList.add(cpg);                                                       
                                                                       
               insert cpgList;
    }
    
     static testMethod void myUnitTest2() {
       
        //Creating an Opportunity record
    	    List<Opportunity> oppList = New List<Opportunity>();
       	    Opportunity Opp = new Opportunity();
        	Opp.Name = 'TestOpp';
       	    Opp.CloseDate = date.today();
            Opp.StageName = 'Closed Won';
            oppList.add(Opp);
            insert oppList;
             System.debug('Created an Opportunity ' + Opp.Id);
    	//Creating a proposal record
    	    List<Proposal__c> proList = new List<Proposal__c>();
    	    Proposal__c p = New Proposal__c();
    	    p.Upfront_Payment__c = 70000;
    	    p.System_Size_STC_DC__c = 25;
    	    p.Sales_Rep_Email__c = 'testrep@yopmail.com';
    	    p.Name = 'Testproposal';
    	    p.Opportunity__c = Opp.Id;
    	    p.Date_Issued__c = date.today();
    	    p.Mode_Name__c  = 'Modetest';
    	    p.Stage__c  = 'SR Approved';
    	    p.Sunrun_Credit_Status__c = 'SR Credit Approved';
        	p.Change_Order_Information__c = 'FULL PROPOSAL';
        	p.Proposal_Source__c = 'BB';
    	    proList.add(p);
    	    insert proList;
    	      System.debug('Created an Proposal ' + p.Id);
    	  //Create a Proposal Performance Guaranteed record.
    	    List<Proposal_Performance_Guarantee__c> ppgList = new List<Proposal_Performance_Guarantee__c>();
    	    Proposal_Performance_Guarantee__c ppg = New Proposal_Performance_Guarantee__c();
    	    ppg.Year__c = '2000' ;
    	    ppg.Refund_Rate__c = 500;
    	    ppg.Guranteed_Output__c = 10;
    	    ppg.Proposal__c = p.Id;
    	    ppgList.add(ppg);
    	    insert ppgList;
    	    System.debug('Created an Proposal Performance Guaranteed' +ppg.Id);
    	    
    	 /*   Proposal_Performance_Guarantee__c ppg2 = New Proposal_Performance_Guarantee__c();
    	    ppg2.Year__c = '2001' ;
    	    ppg.Refund_Rate__c = 600;
    	    ppg.Guranteed_Output__c = 10;
    	    ppg.Proposal__c = p.Id;
    	    ppgList.add(ppg2);
    	    insert ppgList;
    	    System.debug('Created an Proposal Performance Guaranteed' +ppg2.Id); */
    	    
    	    //Creating an Account
            List<Account> accList = New List<Account>();
            Account a = New Account();
            a.Name = 'TestAccount'; 
            accList.add(a);
            insert accList;
            System.debug('created an Account ' + a.Id); 
  
    	    
    	   //Create a ServiceContract Record.
            List<ServiceContract> scList = New List<ServiceContract>();
            ServiceContract sc = New ServiceContract();
            sc.Name = 'Testsc';
            sc.AccountId = a.Id;
            sc.Name = 'Testservicecontract';
            sc.Proposal__c = p.Id;
            sc.Legacy_Asset_Number__c = '10082004';    
            scList.add(sc);
            insert scList;
        	Map <id, id> serviceContractToProposal = new map<id, id>();
            for (ServiceContract src: scList )	{
                serviceContractToProposal.put(src.id, src.Proposal__c );
            }
            System.debug('Created an ServiceContract ' + sc.Id);
        	 
        	map<id, proposal__c> proposalMp = new map<id, proposal__c> ([SELECT Id, Service_Contract__c, Proposal_Scenarios__c,
                                                                          Proposal_Source__c, Change_Order_Information__c, Last_Customer_Signed_Proposal__c,Signed__c,Original_Proposal_ID__c,
                                                                          Original_Proposal_ID__r.Last_Customer_Signed_Proposal__c, Original_Proposal_ID__r.signed__c,
                                                           				(SELECT  Id,Proposal__c,Guranteed_Output__c,Year__c,Refund_Rate__c From Proposal_Performance_Guarantee__r) 
                                                                          FROM Proposal__c WHERE id IN :serviceContractToProposal.values() ]);
    	     
			
            PerformanceGuaranteeUtil.performanceguaranteeservicecontract(true,false,scList,null, serviceContractToProposal, proposalMp);
        	PerformanceGuaranteeUtil.performanceGuaranteeServiceContractForBB(true,false,scList,null, serviceContractToProposal, proposalMp, serviceContractToProposal);
        	list <Proposal_Performance_Guarantee__c> prpg = new  list <Proposal_Performance_Guarantee__c> ([select Id from Proposal_Performance_Guarantee__c 
                                                                                                           where Proposal__c in :serviceContractToProposal.values() ]);	
       	 	list <Contract_Performance_Guarantee__c> cnpg = new  list <Contract_Performance_Guarantee__c> ([select Id from Contract_Performance_Guarantee__c 
                                                                                                            where Service_Contract__c in :serviceContractToProposal.keySet()  ]);	
        	system.debug('Assertvalues ' +prpg.size() + cnpg.size() );
        	system.assertEquals(prpg.size() , cnpg.size());
                //system.assertEquals(expected, actual)
        	// PerformanceGuaranteeUtil.performanceguaranteeservicecontract(trigger.isInsert,trigger.isupdate,Trigger.new,Trigger.oldMap, serviceContractToProposal, proposalMp);
           
            /*List<Contract_Performance_Guarantee__c> cpgList = new List<Contract_Performance_Guarantee__c>();
            Contract_Performance_Guarantee__c cpg = new Contract_Performance_Guarantee__c();
            cpg.Service_Contract__c = sc.id;
            cpg.Guaranteed_Output__c = ppg.Guranteed_Output__c;
            cpg.Refund_Rate__c = ppg.Refund_Rate__c;
            cpg.Year__c =ppg.Year__c;  
            cpgList.add(cpg);                                               	      
    	          	                                                     
    	   	insert cpgList; */
    }

}