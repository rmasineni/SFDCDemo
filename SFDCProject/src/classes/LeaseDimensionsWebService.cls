global class LeaseDimensionsWebService {
    public static String sunrunCreditStr = ProposalUtil.SUNRUN_CUSTOMER_CREDIT;
  global class CreditInformation{
    //Homeowner Info
      webservice String FirstName{get;set;}
      webservice String LastName{get;set;}
      webservice String MI{get;set;}
      webservice String Street{get;set;}
      webservice String City{get;set;}
      webservice String State{get;set;}
      webservice String Country{get;set;}
      webservice String Zip{get;set;}
      webservice Date DOB{get;set;}
      webservice String CustomerEmail{get;set;}
      webservice String HomePhone{get;set;}
      webservice String EmploymentStatus{get;set;}
      webservice String HouseholdIncome{get;set;}
      webservice Integer SizeOfHousehold{get;set;}
      webservice String YearsAtHome{get;set;}
      
      //Dealer Info
      webservice String Installer{get;set;}
      webservice String SalesRepEmail{get;set;}
      
      //Score card
      webservice String ContactNumber{get;set;}  //TODO: CustomerNumber
      webservice String CustomerNumber{get;set;}  
      webservice String Status{get;set;}
      
      //EXPERIAN DATA
      webservice String Bureau1{get;set;}
      webservice Datetime X1DatePulled{get;set;} 
      webservice String X1Fico{get;set;} 
      webservice String X1Reason{get;set;}
      
      //Experian mortgage review
      webservice String HomeEquity1{get;set;}
      webservice String HomeEquity2{get;set;}
      webservice Double HomeEquityAmt1{get;set;}
      webservice Double HomeEquityAmt2{get;set;}
      webservice Date HomeEquityOpenDate1{get;set;}
      webservice Date HomeEquityOpenDate2{get;set;}
      webservice Double X1stMortgageAmt{get;set;}
      webservice Double X1stMortgageAmt2{get;set;}
      webservice Double X1stMortgageAmt3{get;set;}
      webservice Double X1stMortgageAmt4{get;set;}
      webservice Double X1stMortgageAmt5{get;set;}
      webservice String X1stMortgageName{get;set;}
      webservice String X1stMortgageName2{get;set;}
      webservice String X1stMortgageName3{get;set;}
      webservice String X1stMortgageName4{get;set;}
      webservice String X1stMortgageName5{get;set;}
      webservice Date X1stMortgageOpenDate{get;set;}
      webservice Date X1stMortgageOpenDate2{get;set;}
      webservice Date X1stMortgageOpenDate3{get;set;}
      webservice Date X1stMortgageOpenDate4{get;set;}
      webservice Date X1stMortgageOpenDate5{get;set;}  
      webservice Double X2ndMortgageAmt{get;set;}
      webservice String X2ndMortgageName{get;set;}
      webservice Date X2ndMortgageDate{get;set;}
      webservice Double X2ndMortgageAmt2{get;set;}
      webservice String X2ndMortgageName2{get;set;}
      webservice Date X2ndMortgageDate2{get;set;}
      
      //Experain banky review and adverse action reasons
      webservice String X1BankyOutcome{get;set;}      
      webservice String X1MortgageOutcome{get;set;}     
      webservice String X1BKFilingCode{get;set;}
      webservice DateTime X1BKFilingDate{get;set;}
      webservice String X1BKOver60months{get;set;}
      webservice String X1BKNumMonths{get;set;}
      webservice String X1AdverseActionReason1{get;set;}
      webservice String X1AdverseActionReason2{get;set;}     
      webservice String X1AdverseActionReason3{get;set;}
      webservice String X1AdverseActionReason4{get;set;}      
      webservice String X1AdverseActionReason5{get;set;}
      
      //TU DATA
      webservice String Bureau2{get;set;}
      webservice Datetime X2DatePulled{get;set;} 
      webservice String X2Fico{get;set;} 
      webservice String X2Reason{get;set;}
      
      //Transunion banky review and adverse action reasons
      webservice String X2BankyOutcome{get;set;}      
      webservice String X2MortgageOutcome{get;set;}     
      webservice String X2BKNumMonths{get;set;}
      webservice String X2AdverseActionReason1{get;set;}
      webservice String X2AdverseActionReason2{get;set;}     
      webservice String X2AdverseActionReason3{get;set;}
      webservice String X2AdverseActionReason4{get;set;}      
      webservice String X2AdverseActionReason5{get;set;}
      
      //EQUIFAX DATA
      webservice String Bureau3{get;set;}
      webservice Datetime X3DatePulled{get;set;} 
      webservice String X3Fico{get;set;} 
      webservice String X3Reason{get;set;}
      
      //EQUIFAX banky review and adverse action reasons
      webservice String X3BankyOutcome{get;set;}      
      webservice String X3MortgageOutcome{get;set;}     
      webservice String X3BKNumMonths{get;set;}
      webservice String X3AdverseActionReason1{get;set;}
      webservice String X3AdverseActionReason2{get;set;}     
      webservice String X3AdverseActionReason3{get;set;}
      webservice String X3AdverseActionReason4{get;set;}      
      webservice String X3AdverseActionReason5{get;set;}
      
      webservice Datetime DateApproved{get;set;}
      webservice Datetime DatePulled{get;set;}
      webservice String Employer{get;set;}
      webservice String EstimatedHomeValue{get;set;}
      webservice String FailedScore{get;set;}
      webservice String Fico{get;set;}
      webservice String Reason{get;set;}
      
      webservice String Gen{get;set;}
      webservice Boolean HomeOwnerSigned{get;set;}
      webservice String Income{get;set;}
      webservice Double LTV{get;set;}
      webservice String OtherPhone{get;set;}
      
      webservice Integer Decline_Score{get;set;}
      webservice String AdverseActionReason1{get;set;}
      webservice String AdverseActionReason2{get;set;}     
      webservice String AdverseActionReason3{get;set;}
      webservice String AdverseActionReason4{get;set;}      
      webservice String AdverseActionReason5{get;set;}
      webservice String BankyOutcome{get;set;}      
      webservice String MortgageOutcome{get;set;}     
      webservice String BKFilingCode{get;set;}
      webservice DateTime BKFilingDate{get;set;}
      webservice String BKOver60months{get;set;}
      webservice String BKNumMonths{get;set;}
      
      webservice String DealId{get;set;}
      webservice String ProposalId{get;set;}    
      //added new field to get actual credit report details when it is 'yes'
      webservice String Ofac{get;set;}
      
    public CreditInformation(){}
  }

  webservice static String SendCreditResponse(CreditInformation CustomerCreditInfo)
  {
    System.debug('CustomerCreditInfo: ' + CustomerCreditInfo);
    System.debug('CustomerCreditInfo.CustomerNumber: ' + CustomerCreditInfo.CustomerNumber);
    System.debug('CustomerCreditInfo.ContactNumber: ' + CustomerCreditInfo.ContactNumber);
    System.debug('CustomerCreditInfo.X1Fico: ' + CustomerCreditInfo.X1Fico);
    System.debug('CustomerCreditInfo.X1Fico: ' + CustomerCreditInfo.X2Fico);
    System.debug('CustomerCreditInfo.X1Fico: ' + CustomerCreditInfo.X3Fico);

    System.debug('CustomerCreditInfo.Bureau1: ' + CustomerCreditInfo.Bureau1);
    System.debug('CustomerCreditInfo.Bureau2: ' + CustomerCreditInfo.Bureau2);
    System.debug('CustomerCreditInfo.Bureau3: ' + CustomerCreditInfo.Bureau3);  
        String result = '';
    if(CustomerCreditInfo != null && CustomerCreditInfo.Fico != null 
      && ((CustomerCreditInfo.X1Fico == null || CustomerCreditInfo.X1Fico == '' ) 
        && (CustomerCreditInfo.X2Fico == null || CustomerCreditInfo.X2Fico == '' ) 
        && (CustomerCreditInfo.X3Fico == null || CustomerCreditInfo.X3Fico == '' ))){
      result = SendCreditResponseOld(CustomerCreditInfo);    
    }else{
      result = SendCreditResponseNew(CustomerCreditInfo);
    } 
    return result;
  }
  
  static String SendCreditResponseNew(CreditInformation CustomerCreditInfo)
  {
    //String sunrunCreditStr = ProposalUtil.SUNRUN_CUSTOMER_CREDIT;
    List<Customer_Credit__c> listCC = new List<Customer_Credit__c>();
      Boolean bContactExists = false;
      Integer expirationDays = Integer.valueOf(CustomerCreditUtil.getCreditExpirationDays()) * -1;
      Date datePulled = Date.today().addDays(expirationDays); 
      String custReferenceNumber = (CustomerCreditInfo.ContactNumber != null && CustomerCreditInfo.ContactNumber != '') ? CustomerCreditInfo.ContactNumber : CustomerCreditInfo.CustomerNumber ;
      try{
      if(custReferenceNumber != null && custReferenceNumber != ''){
                String soqlStr1 = getCustomerCreditSOQLStr();
                String soqlStr = soqlStr1 + ' where type__c != :sunrunCreditStr and (Id = :custReferenceNumber or (Contact__c = :custReferenceNumber and Contact__c != null)) and Approved__c = null and Date_Submitted__c != null and (Date_Pulled__c = null or Date_Pulled__c >= :datePulled) order by Date_Submitted__c desc limit 1 ';
                for(Customer_Credit__c cc : Database.query(soqlStr)){                               
                    bContactExists = true;
                    CustomerCreditUtil.copyCreditInformation(cc, CustomerCreditInfo);
                    CustomerCreditUtil.calculateCreditScore(cc);
          update cc;
          return custReferenceNumber;
                }
            }
    }catch(Exception e){
      bContactExists = false;  
    }
    
    if(!bContactExists){
        Id conId = null;
        Id accId = null;  
        try{
        for(Customer_Credit__c ccApproved:[select id, Account__c, Contact__c, type__c from Customer_Credit__c where (Id = :custReferenceNumber
                                                   or Contact__c = :custReferenceNumber) and Approved__c != null
                                                   and type__c != :sunrunCreditStr]){
          conId = ccApproved.Contact__c;
          accId = ccApproved.Account__c;            
        }
            /*****If Customer Credit object is not associated with contact information, we will find the contact information based
				on custReferenceNumber provided by leasedimensions response and associate with customer credit object *****/
            system.debug('conIdconId' + conId);
            system.debug('accId' + accId);
            system.debug('custReferenceNumber::'+ custReferenceNumber);
            If(conId==null && accId==null){
                for(Contact conInfo: [select Id, accountId from contact where id= :custReferenceNumber ]){
                    conId = conInfo.Id;
                    accId = conInfo.accountId;  
                }
            }
                  
      }catch(Exception e){
        conId = null;
        accId = null;
      }
        Customer_Credit__c cc = new Customer_Credit__c();
        cc.Contact__c = conId;
        cc.Account__c = accId;      
    
      CustomerCreditUtil.copyCreditInformation(cc, CustomerCreditInfo);    
      CustomerCreditUtil.calculateCreditScore(cc);
      insert cc;
      System.debug('cc.Id: ' + cc.Id);
      return String.ValueOf(cc.Id);
    }        
    return '0';
  }

  static String SendCreditResponseOld(CreditInformation CustomerCreditInfo){
   // String sunrunCreditStr = ProposalUtil.SUNRUN_CUSTOMER_CREDIT;
    List<Customer_Credit__c> listCC = new List<Customer_Credit__c>();
    Boolean bContactExists = false;
    Integer expirationDays = Integer.valueOf(CustomerCreditUtil.getCreditExpirationDays()) * -1;
    Date datePulled = Date.today().addDays(expirationDays); 
    String custReferenceNumber = (CustomerCreditInfo.ContactNumber != null && CustomerCreditInfo.ContactNumber != '') ? CustomerCreditInfo.ContactNumber : CustomerCreditInfo.CustomerNumber ;

    try{
      if(custReferenceNumber != null && custReferenceNumber != ''){
        String soqlStr1 = getCustomerCreditSOQLStr();
        String soqlStr = soqlStr1 + 'where type__c != :sunrunCreditStr and (Id = :custReferenceNumber or (Contact__c = :custReferenceNumber and Contact__c != null)) and Approved__c = null and Date_Submitted__c != null and (Date_Pulled__c = null or Date_Pulled__c >= :datePulled) order by Date_Submitted__c desc limit 1 ';
        for(Customer_Credit__c cc : Database.query(soqlStr)){
          bContactExists = true;
            cc.City__c = CustomerCreditInfo.City;
            cc.Country__c = CustomerCreditInfo.Country;
            cc.Customer_Email__c = CustomerCreditInfo.CustomerEmail;
            cc.Date_Approved__c = CustomerCreditInfo.DateApproved;
            cc.Date_Pulled__c = CustomerCreditInfo.DatePulled;
            cc.Employer__c = CustomerCreditInfo.Employer;
            cc.Estimated_Home_Value__c = CustomerCreditInfo.EstimatedHomeValue;
            cc.Failed_Score__c = CustomerCreditInfo.FailedScore;
            //cc.Fico__c = CustomerCreditInfo.Fico;
          CustomerCreditUtil.copyFicoScore(CustomerCreditInfo, cc);
            cc.First_Name__c = CustomerCreditInfo.FirstName;
            cc.Gen__c = CustomerCreditInfo.Gen;
            cc.Home_Equity_Amt1__c = CustomerCreditInfo.HomeEquityAmt1;
            cc.Home_Equity_Amt2__c = CustomerCreditInfo.HomeEquityAmt2;
            cc.Home_Equity_OpenDate2__c = CustomerCreditInfo.HomeEquityOpenDate1;
            cc.Home_Equity_OpenDate2__c = CustomerCreditInfo.HomeEquityOpenDate2;
            cc.Home_Equity1__c = CustomerCreditInfo.HomeEquity1;
            cc.Home_Equity2__c = CustomerCreditInfo.HomeEquity2;
            //
            if(CustomerCreditInfo.HomeOwnerSigned != null)
            {
              cc.Home_Owner_Signed__c = CustomerCreditInfo.HomeOwnerSigned;
            }
            //
            cc.Home_Phone__c = CustomerCreditInfo.HomePhone;
            cc.Income__c = CustomerCreditInfo.Income;
            cc.Installer__c = CustomerCreditInfo.Installer;
            cc.Last_Name__c = CustomerCreditInfo.LastName;
            cc.LTV__c = CustomerCreditInfo.LTV;
            cc.MI__c = CustomerCreditInfo.MI;
            cc.Other_Phone__c = CustomerCreditInfo.OtherPhone;
            cc.Reason__c = CustomerCreditInfo.Reason;
            cc.Sales_Rep_Email__c = CustomerCreditInfo.SalesRepEmail;
            cc.State__c = CustomerCreditInfo.State;
            cc.Status__c = CustomerCreditInfo.Status;
            cc.Street__c = CustomerCreditInfo.Street;
            cc.X1st_Mortgage_Amt__c = CustomerCreditInfo.X1stMortgageAmt;
            cc.X1st_Mortgage_Amt2__c = CustomerCreditInfo.X1stMortgageAmt2;
            cc.X1st_Mortgage_Amt3__c = CustomerCreditInfo.X1stMortgageAmt3;
            cc.X1st_Mortgage_Amt4__c = CustomerCreditInfo.X1stMortgageAmt4;
            cc.X1st_Mortgage_Amt5__c = CustomerCreditInfo.X1stMortgageAmt5;
            cc.X1st_Mortgage_Name__c = CustomerCreditInfo.X1stMortgageName;
            cc.X1st_Mortgage_Name2__c = CustomerCreditInfo.X1stMortgageName2;
            cc.X1st_Mortgage_Name3__c = CustomerCreditInfo.X1stMortgageName3;
            cc.X1st_Mortgage_Name4__c = CustomerCreditInfo.X1stMortgageName4;
            cc.X1st_Mortgage_Name5__c = CustomerCreditInfo.X1stMortgageName5;
            cc.X1st_Mortgage_OpenDate__c = CustomerCreditInfo.X1stMortgageOpenDate;
            cc.X1st_Mortgage_OpenDate2__c = CustomerCreditInfo.X1stMortgageOpenDate2;
            cc.X1st_Mortgage_OpenDate3__c = CustomerCreditInfo.X1stMortgageOpenDate3;
            cc.X1st_Mortgage_OpenDate4__c = CustomerCreditInfo.X1stMortgageOpenDate4;
            cc.X1st_Mortgage_OpenDate5__c = CustomerCreditInfo.X1stMortgageOpenDate5;
          cc.X2nd_Mortgage_name__c = CustomerCreditInfo.X2ndMortgageName;
          cc.X2nd_Mortgage_OpenDate__c = CustomerCreditInfo.X2ndMortgageDate;
            cc.X2nd_Mortgage_Amt__c = CustomerCreditInfo.X2ndMortgageAmt;
            cc.X2nd_Mortgage_name2__c = CustomerCreditInfo.X2ndMortgageName2;
          cc.X2nd_Mortgage_OpenDate2__c = CustomerCreditInfo.X2ndMortgageDate2;
            cc.X2nd_Mortgage_Amt2__c = CustomerCreditInfo.X2ndMortgageAmt2;
            cc.DateOfBirth__c = CustomerCreditInfo.DOB;
            cc.Employment_Status__c = CustomerCreditInfo.EmploymentStatus;
            cc.Household_Income__c = CustomerCreditInfo.HouseholdIncome;
            cc.Size_of_Household__c = CustomerCreditInfo.SizeOfHousehold;
            cc.Zip__c = CustomerCreditInfo.Zip;
            cc.Years_at_Home__c = CustomerCreditInfo.YearsAtHome;        
          cc.Adverse_Action_Reason1__c = CustomerCreditInfo.AdverseActionReason1;
          cc.Adverse_Action_Reason2__c = CustomerCreditInfo.AdverseActionReason2;
          cc.Adverse_Action_Reason3__c = CustomerCreditInfo.AdverseActionReason3;
          cc.Adverse_Action_Reason4__c = CustomerCreditInfo.AdverseActionReason4;
          cc.Adverse_Action_Reason5__c = CustomerCreditInfo.AdverseActionReason5;
          cc.Banky_Outcome__c = CustomerCreditInfo.BankyOutcome;
          cc.Mortgage_Outcome__c = CustomerCreditInfo.MortgageOutcome;
        
          cc.BKFilingCode__c = CustomerCreditInfo.BKFilingCode;
          cc.BKFilingDate__c = CustomerCreditInfo.BKFilingDate;
          cc.BKNumMonths__c = CustomerCreditInfo.BKNumMonths;
          cc.Deal_Id__c = (CustomerCreditInfo.DealId != null && CustomerCreditInfo.DealId != '') ? CustomerCreditInfo.DealId : cc.Deal_Id__c;  
          cc.BKOver60months__c = CustomerCreditInfo.BKOver60months;
          cc.OFAC_Status__c =  CustomerCreditInfo.Ofac;    
          CustomerCreditUtil.copyFicoInfoToExperianData(cc);
        
            update cc;
            return custReferenceNumber;            
        }
      }
    }catch(Exception e){
      bContactExists = false;  
    }      

    if(!bContactExists){
        Id conId = null;
        Id accId = null;  
        try{
          for(Customer_Credit__c ccApproved:[select id, Account__c, Contact__c, type__c
                                           from Customer_Credit__c
                              where (Id = :custReferenceNumber
                                     or Contact__c = :custReferenceNumber)
                                and type__c != :sunrunCreditStr     
                                and Approved__c != null])  
        {
          conId = ccApproved.Contact__c;
          accId = ccApproved.Account__c;            
        }
         /*****If Customer Credit object is not associated with contact information, we will find the contact information based
						on custReferenceNumber provided by leasedimensions response and associate with customer credit object *****/
                
                If(conId==null && accId==null){
                    for(Contact conInfo: [select Id, accountId from contact where id= :custReferenceNumber ]){
                        conId = conInfo.Id;
                        accId = conInfo.accountId;  
                    }
                }   
            
               
      }catch(Exception e){
        conId = null;
        accId = null;
        }
        Customer_Credit__c cc = new Customer_Credit__c();
        cc.City__c = CustomerCreditInfo.City;
        cc.Country__c = CustomerCreditInfo.Country;
        cc.Customer_Email__c = CustomerCreditInfo.CustomerEmail;
        cc.Date_Approved__c = CustomerCreditInfo.DateApproved;
        Datetime currentTime = Datetime.now();
        cc.Date_Submitted__c = (CustomerCreditInfo.DatePulled == null) ? currentTime : CustomerCreditInfo.DatePulled ;
        cc.Date_Pulled__c = CustomerCreditInfo.DatePulled;
        cc.Employer__c = CustomerCreditInfo.Employer;
        cc.Estimated_Home_Value__c = CustomerCreditInfo.EstimatedHomeValue;
        cc.Failed_Score__c = CustomerCreditInfo.FailedScore;
        //cc.Fico__c = CustomerCreditInfo.Fico;
        CustomerCreditUtil.copyFicoScore(CustomerCreditInfo, cc);
        cc.First_Name__c = CustomerCreditInfo.FirstName;
        cc.Gen__c = CustomerCreditInfo.Gen;
        cc.Home_Equity_Amt1__c = CustomerCreditInfo.HomeEquityAmt1;
        cc.Home_Equity_Amt2__c = CustomerCreditInfo.HomeEquityAmt2;
        cc.Home_Equity_OpenDate2__c = CustomerCreditInfo.HomeEquityOpenDate1;
        cc.Home_Equity_OpenDate2__c = CustomerCreditInfo.HomeEquityOpenDate2;
        cc.Home_Equity1__c = CustomerCreditInfo.HomeEquity1;
        cc.Home_Equity2__c = CustomerCreditInfo.HomeEquity2;
        //
        if(CustomerCreditInfo.HomeOwnerSigned != null)
        {
          cc.Home_Owner_Signed__c = CustomerCreditInfo.HomeOwnerSigned;
        }
        //
        cc.Home_Phone__c = CustomerCreditInfo.HomePhone;
        cc.Income__c = CustomerCreditInfo.Income;
        cc.Installer__c = CustomerCreditInfo.Installer;
        cc.Last_Name__c = CustomerCreditInfo.LastName;
        cc.LTV__c = CustomerCreditInfo.LTV;
        cc.MI__c = CustomerCreditInfo.MI;
        cc.Other_Phone__c = CustomerCreditInfo.OtherPhone;
        cc.Reason__c = CustomerCreditInfo.Reason;
        cc.Sales_Rep_Email__c = CustomerCreditInfo.SalesRepEmail;
        cc.State__c = CustomerCreditInfo.State;
        cc.Status__c = CustomerCreditInfo.Status;
        cc.Street__c = CustomerCreditInfo.Street;
        cc.X1st_Mortgage_Amt__c = CustomerCreditInfo.X1stMortgageAmt;
        cc.X1st_Mortgage_Amt2__c = CustomerCreditInfo.X1stMortgageAmt2;
        cc.X1st_Mortgage_Amt3__c = CustomerCreditInfo.X1stMortgageAmt3;
        cc.X1st_Mortgage_Amt4__c = CustomerCreditInfo.X1stMortgageAmt4;
        cc.X1st_Mortgage_Amt5__c = CustomerCreditInfo.X1stMortgageAmt5;
        cc.X1st_Mortgage_Name__c = CustomerCreditInfo.X1stMortgageName;
        cc.X1st_Mortgage_Name2__c = CustomerCreditInfo.X1stMortgageName2;
        cc.X1st_Mortgage_Name3__c = CustomerCreditInfo.X1stMortgageName3;
        cc.X1st_Mortgage_Name4__c = CustomerCreditInfo.X1stMortgageName4;
        cc.X1st_Mortgage_Name5__c = CustomerCreditInfo.X1stMortgageName5;
        cc.X1st_Mortgage_OpenDate__c = CustomerCreditInfo.X1stMortgageOpenDate;
        cc.X1st_Mortgage_OpenDate2__c = CustomerCreditInfo.X1stMortgageOpenDate2;
        cc.X1st_Mortgage_OpenDate3__c = CustomerCreditInfo.X1stMortgageOpenDate3;
        cc.X1st_Mortgage_OpenDate4__c = CustomerCreditInfo.X1stMortgageOpenDate4;
        cc.X1st_Mortgage_OpenDate5__c = CustomerCreditInfo.X1stMortgageOpenDate5;
      cc.X2nd_Mortgage_name__c = CustomerCreditInfo.X2ndMortgageName;
      cc.X2nd_Mortgage_OpenDate__c = CustomerCreditInfo.X2ndMortgageDate;
        cc.X2nd_Mortgage_Amt__c = CustomerCreditInfo.X2ndMortgageAmt;
        cc.X2nd_Mortgage_name2__c = CustomerCreditInfo.X2ndMortgageName2;
      cc.X2nd_Mortgage_OpenDate2__c = CustomerCreditInfo.X2ndMortgageDate2;
        cc.X2nd_Mortgage_Amt2__c = CustomerCreditInfo.X2ndMortgageAmt2;
        cc.DateOfBirth__c = CustomerCreditInfo.DOB;
        cc.Employment_Status__c = CustomerCreditInfo.EmploymentStatus;
        cc.Household_Income__c = CustomerCreditInfo.HouseholdIncome;
        cc.Size_of_Household__c = CustomerCreditInfo.SizeOfHousehold;
        cc.Zip__c = CustomerCreditInfo.Zip;
        cc.Years_at_Home__c = CustomerCreditInfo.YearsAtHome;        
        //
        cc.Contact__c = conId;
        cc.Account__c = accId;
        
      cc.Adverse_Action_Reason1__c = CustomerCreditInfo.AdverseActionReason1;
      cc.Adverse_Action_Reason2__c = CustomerCreditInfo.AdverseActionReason2;
      cc.Adverse_Action_Reason3__c = CustomerCreditInfo.AdverseActionReason3;
      cc.Adverse_Action_Reason4__c = CustomerCreditInfo.AdverseActionReason4;
      cc.Adverse_Action_Reason5__c = CustomerCreditInfo.AdverseActionReason5;
      cc.Banky_Outcome__c = CustomerCreditInfo.BankyOutcome;
      cc.Mortgage_Outcome__c = CustomerCreditInfo.MortgageOutcome;

      cc.BKFilingCode__c = CustomerCreditInfo.BKFilingCode;
      cc.BKFilingDate__c = CustomerCreditInfo.BKFilingDate;
      cc.BKNumMonths__c = CustomerCreditInfo.BKNumMonths;
      cc.Deal_Id__c = (CustomerCreditInfo.DealId != null && CustomerCreditInfo.DealId != '') ? CustomerCreditInfo.DealId : cc.Deal_Id__c;  
      cc.BKOver60months__c = CustomerCreditInfo.BKOver60months;            
         cc.OFAC_Status__c =  CustomerCreditInfo.Ofac;       
        CustomerCreditUtil.copyFicoInfoToExperianData(cc);
        insert cc;
      return String.ValueOf(cc.Id);
    }        
      return '0';
  }
  
  
  public static String getCustomerCreditSOQLStr(){
    String customerCreditSOQLStr = 'select id, type__c, Zip__c, Years_at_Home__c, X2nd_Mortgage_name__c, X2nd_Mortgage_OpenDate__c, X2nd_Mortgage_Amt__c, X2nd_Mortgage_name2__c, X2nd_Mortgage_OpenDate2__c, X2nd_Mortgage_Amt2__c, ' ;
         customerCreditSOQLStr += ' X1st_Mortgage_name5__c, X1st_Mortgage_name4__c,X1st_Mortgage_name3__c, X1st_Mortgage_name2__c, X1st_Mortgage_OpenDate__c,X1st_Mortgage_OpenDate5__c, X1st_Mortgage_OpenDate4__c, X1st_Mortgage_OpenDate3__c,X1st_Mortgage_OpenDate2__c, X1st_Mortgage_Name__c, X1st_Mortgage_Amt__c,X1st_Mortgage_Amt5__c, X1st_Mortgage_Amt4__c, X1st_Mortgage_Amt3__c,X1st_Mortgage_Amt2__c, Total_Solar_Prepay_Required__c, Street__c, Status__c, State__c,Size_of_Household__c, Sales_Rep_Email__c, SRH_Customer_Number__c, Reason__c, Pending_Reason__c, Partner_Financed__c, OwnerId, Other_Phone__c, Notes__c, Name,Mailing_Address__c, MI__c, Last_Name__c, LTV__c, Installer__c, Income__c,Household_Income__c, Home_Phone__c, Home_Owner_Signed__c, Home_Equity_OpenDate2__c,Home_Equity_OpenDate1__c, Home_Equity_Amt2__c, Home_Equity_Amt1__c, Home_Equity2__c,Home_Equity1__c, Gen__c, First_Name__c, Fico__c, Failed_Score__c, Estimated_Home_Value__c,Employment_Status__c, Employer__c, Date_Submitted__c, Date_Pulled__c, Date_Approved__c,DateOfBirth__c, Customer_Number__c, Customer_Email__c, Country__c,Contact__r.Contact_Number__c, Contact__c, Contact_Address_Match__c,Adverse_Action_Reason1__c, Adverse_Action_Reason2__c, Adverse_Action_Reason3__c,Adverse_Action_Reason4__c, Adverse_Action_Reason5__c, Experian_Adverse_Action_Reason1__c, Experian_Adverse_Action_Reason2__c, Experian_Adverse_Action_Reason3__c,Experian_Adverse_Action_Reason4__c, Experian_Adverse_Action_Reason5__c,Equifax_Adverse_Action_Reason1__c, Equifax_Adverse_Action_Reason2__c, Equifax_Adverse_Action_Reason3__c,Equifax_Adverse_Action_Reason4__c, Equifax_Adverse_Action_Reason5__c,Transunion_Adverse_Action_Reason1__c, Transunion_Adverse_Action_Reason2__c, Transunion_Adverse_Action_Reason3__c,Transunion_Adverse_Action_Reason4__c, Transunion_Adverse_Action_Reason5__c,Bureau1__c, Bureau2__c, Bureau3__c, Fico1__c, Fico2__c, Fico3__c, Date_Run1__c, Date_Run2__c, Date_Run3__c,Experian_Reason__c, TransUnion_Reason__c, Equifax_Reason__c, Experian_Banky_Outcome__c, Experian_Mortgage_Outcome__c, TransUnion_Banky_Outcome__c, TransUnion_Mortgage_Outcome__c,Equifax_Banky_Outcome__c, Equifax_Mortgage_Outcome__c, Experian_BKFilingCode__c, Experian_BKFilingDate__c,Experian_BKOver60months__c, Experian_BKNumMonths__c, Banky_Outcome__c, Mortgage_Outcome__c,Conditional_Approval__c, Conditional_Approval_Amount__c, City__c, Approved__c, Approved_By__c, Age__c, Account__c, ACH_Required__c, BKFilingCode__c, BKFilingDate__c, BKNumMonths__c, BKOver60months__c from Customer_Credit__c ' ;
    return customerCreditSOQLStr;                               
  }
}