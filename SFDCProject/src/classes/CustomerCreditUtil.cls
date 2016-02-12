public class CustomerCreditUtil {
	public static String CUSTOMER_OWNED = 'Customer Owned';
    public static String Conditional_Approval_From_Partner = 'Conditional Approval From Partner';
    public static String PARTNER_GUARANTEE = 'Partner Guarantee';
    private static Set<String> stateList = new Set<String>();
	public static String FAIL = 'FAIL' ;
	public static String PASS = 'PASS' ;
	public static String CPASS = 'CPASS' ;
	public static String MANUAL = 'MANUAL' ;
	public static String PROCEED = 'PROCEED' ;
    	
	public static void processCreditEmail(Map<Id, Customer_Credit__c> newMap, Map<Id, Customer_Credit__c> oldMap){
		Set<String> DealCreditSet = New Set<String>();
	    List<Opportunity> OppDealIdList = New List<Opportunity>();
	    //Profile ProfileName = [Select Name from profile where Id =: Userinfo.getProfileId()];
	    String financeCreditProfileId = Label.Finance_Credit_Id;
	    String loginProfileId = UserInfo.getProfileId();
	    List<Customer_Credit__c> CreditUpdateList = New List<Customer_Credit__c>();
	    Map<String,Id> DealIdvsOppIdMap = New Map<String,Id>();
	    for(Customer_Credit__c ccObj: newMap.values()){
	        Customer_Credit__c oldCCObj;
            oldCCObj = oldMap.get(ccObj.Id);
	        if(ccObj.Deal_Id__c != null && 
	           ((((ccObj.Sunrun_Credit_Status__c == PASS && oldCCObj.Sunrun_Credit_Status__c != PASS) ||(ccObj.Sunrun_Credit_Status__c == CPASS && oldCCObj.Sunrun_Credit_Status__c != CPASS) || (ccObj.Sunrun_Credit_Status__c == MANUAL && oldCCObj.Sunrun_Credit_Status__c != MANUAL) || (ccObj.Sunrun_Credit_Status__c == FAIL && oldCCObj.Sunrun_Credit_Status__c != FAIL)) && 
	             (ccObj.Status__c == 'N/A' || ccObj.Status__c == CPASS || ccObj.Status__c == PASS || ccObj.Status__c == FAIL || ccObj.Status__c == MANUAL)) ||
	            
	            (((ccObj.Status__c == 'N/A' || ccObj.Status__c == CPASS || ccObj.Status__c == PASS || ccObj.Status__c == FAIL || ccObj.Status__c ==MANUAL) &&
	              (oldCCObj.Status__c != 'N/A' || oldCCObj.Status__c != CPASS || oldCCObj.Status__c != PASS || oldCCObj.Status__c != FAIL  || oldCCObj.Status__c!= MANUAL)) &&
	             ((ccObj.Sunrun_Credit_Status__c == PASS && oldCCObj.Sunrun_Credit_Status__c != PASS) ||(ccObj.Sunrun_Credit_Status__c == CPASS && oldCCObj.Sunrun_Credit_Status__c != CPASS) || (ccobj.Sunrun_Credit_Status__c == MANUAL && oldCCObj.Sunrun_Credit_Status__c != MANUAL) ||(ccObj.Sunrun_Credit_Status__c == FAIL && oldCCObj.Sunrun_Credit_Status__c !=FAIL)))) &&
	           (!loginProfileId.contains(financeCreditProfileId)) 
              &&(ccObj.Credit_Email_Sent__c != True))
	        {
	            CreditUpdateList.add(ccObj);
	            DealCreditSet.add(ccObj.Deal_Id__c);
	            System.debug('Inside ...');
	        }
	       
	    }
	    if(!DealCreditSet.isEmpty()){
	        OppDealIdList = [Select Id,Deal_Id__c,Sales_Representative__r.Email from Opportunity where Deal_Id__c IN :DealCreditSet];
	        
	        if(!OppDealIdList.isEmpty()){
	            for(Opportunity opp : OppDealIdList ){
	                DealIdvsOppIdMap.put(opp.Deal_Id__c,opp.Id);  
	            }
	            
	            SendEmailClass SMail = New SendEmailClass();
                SMail.SendEmailCredit(CreditUpdateList,DealIdvsOppIdMap,oldMap);
	        }
	    }		
	}
	
	public static Integer getCreditExpirationDays(){
		String expirationDaysStr = System.Label.Credit_Expiry_Days; 
		Integer expirationDays = (expirationDaysStr == null || expirationDaysStr == '') ? 90 : integer.valueof(expirationDaysStr);
		return expirationDays;
	}
	
    static
    {              
        Map<String, Customer_Credit_State__c> customerCreditStates = Customer_Credit_State__c.getAll();
		stateList  = customerCreditStates.keySet();  
    }
	
	public Static Map<String, CustomerCreditAutomationInfo__c> creditAutomationInfo = CustomerCreditAutomationInfo__c.getAll();

	public static Set<String> excludedFicoScores; 
	static
	{
		excludedFicoScores = new Set<String>();
		excludedFicoScores.add('9000');
		excludedFicoScores.add('9001');
		excludedFicoScores.add('9002');
		excludedFicoScores.add('9003');
	}
	
	public static void copyFicoScore(LeaseDimensionsWebService.CreditInformation CustomerCreditInfo, Customer_Credit__c cc){
		
		if((CustomerCreditInfo.Fico == null || CustomerCreditInfo.Fico == '') && 
			(CustomerCreditInfo.FailedScore != null || CustomerCreditInfo.FailedScore != '')){
			cc.Fico__c = CustomerCreditInfo.FailedScore;
		}else{
			cc.Fico__c = CustomerCreditInfo.Fico;
		}
	}
	
	public static void copyFicoScore(Customer_Credit__c cc){
		if((cc.Fico__c == null || cc.Fico__c == '') && 
			(cc.Failed_Score__c != null || cc.Failed_Score__c != '')){
			cc.Fico__c = cc.Failed_Score__c;
		}
	}
	
	public static void copyFicoInfoToExperianData(Customer_Credit__c cc){
		cc.Bureau1__c = 'Experian' ;
		cc.Decisioning_Bureau__c = cc.Bureau1__c;
		cc.Date_Run1__c = cc.Date_Pulled__c;
		cc.fico1__c = cc.fico__c;
		cc.Experian_Reason__c = cc.Reason__c;
		
		cc.Experian_Banky_Outcome__c = cc.Banky_Outcome__c;
		cc.Experian_Mortgage_Outcome__c = cc.Mortgage_Outcome__c;
		
		cc.Experian_BKFilingCode__c = cc.BKFilingCode__c;
		cc.Experian_BKFilingDate__c = cc.BKFilingDate__c;
		cc.Experian_BKNumMonths__c = cc.BKNumMonths__c;
		cc.Experian_BKOver60months__c = cc.BKOver60months__c;
		
		cc.Experian_Adverse_Action_Reason1__c = cc.Adverse_Action_Reason1__c;
		cc.Experian_Adverse_Action_Reason2__c = cc.Adverse_Action_Reason2__c;
		cc.Experian_Adverse_Action_Reason3__c = cc.Adverse_Action_Reason3__c;
		cc.Experian_Adverse_Action_Reason4__c = cc.Adverse_Action_Reason4__c;
		cc.Experian_Adverse_Action_Reason5__c = cc.Adverse_Action_Reason5__c;		
	}
	
	public static void copyExperianData(Customer_Credit__c cc){
		System.debug('cc.fico__c: ' + cc.fico__c);
		cc.Decisioning_Bureau__c = cc.Bureau1__c;
		cc.Date_Pulled__c = cc.Date_Run1__c;
		cc.fico__c = cc.fico1__c;
		cc.Reason__c = cc.Experian_Reason__c;
			
		cc.Banky_Outcome__c = cc.Experian_Banky_Outcome__c ;
		cc.Mortgage_Outcome__c = cc.Experian_Mortgage_Outcome__c ;

		cc.BKFilingCode__c = cc.Experian_BKFilingCode__c;
		cc.BKFilingDate__c = cc.Experian_BKFilingDate__c;
		cc.BKNumMonths__c = cc.Experian_BKNumMonths__c;
		cc.BKOver60months__c = cc.Experian_BKOver60months__c;
			
		cc.Adverse_Action_Reason1__c = cc.Experian_Adverse_Action_Reason1__c;
		cc.Adverse_Action_Reason2__c = cc.Experian_Adverse_Action_Reason2__c;
		cc.Adverse_Action_Reason3__c = cc.Experian_Adverse_Action_Reason3__c;
		cc.Adverse_Action_Reason4__c = cc.Experian_Adverse_Action_Reason4__c;
		cc.Adverse_Action_Reason5__c = cc.Experian_Adverse_Action_Reason5__c;	
		System.debug('cc.fico__c: ' + cc.fico__c);	
		System.debug('cc.fico1__c: ' + cc.fico1__c);	
	}

	public static void copyEquifaxData(Customer_Credit__c cc){
		cc.Decisioning_Bureau__c = cc.Bureau3__c;
		cc.Date_Pulled__c = cc.Date_Run3__c;
		cc.fico__c = cc.fico3__c;
		cc.Reason__c = cc.Equifax_Reason__c;

		cc.Banky_Outcome__c = cc.Equifax_Banky_Outcome__c ;
		cc.Mortgage_Outcome__c = cc.Equifax_Mortgage_Outcome__c ;
			
		cc.BKFilingCode__c = null;
		cc.BKFilingDate__c = null;
		cc.BKNumMonths__c = null;
		cc.BKOver60months__c = null;
	
		cc.Adverse_Action_Reason1__c = cc.Equifax_Adverse_Action_Reason1__c;
		cc.Adverse_Action_Reason2__c = cc.Equifax_Adverse_Action_Reason2__c;
		cc.Adverse_Action_Reason3__c = cc.Equifax_Adverse_Action_Reason3__c;
		cc.Adverse_Action_Reason4__c = cc.Equifax_Adverse_Action_Reason4__c;
		cc.Adverse_Action_Reason5__c = cc.Equifax_Adverse_Action_Reason5__c;		
	}

	public static void copyTransUnionData(Customer_Credit__c cc){
		cc.Decisioning_Bureau__c = cc.Bureau2__c;
		cc.Date_Pulled__c = cc.Date_Run2__c;
		cc.fico__c = cc.fico2__c;
		cc.Reason__c = cc.Transunion_Reason__c;
		//modifying
		cc.Banky_Outcome__c = cc.Transunion_Banky_Outcome__c ;
		cc.Mortgage_Outcome__c = cc.Transunion_Mortgage_Outcome__c ;

		cc.BKFilingCode__c = null;
		cc.BKFilingDate__c = null;
		cc.BKNumMonths__c = null;
		cc.BKOver60months__c = null;

		cc.Adverse_Action_Reason1__c = cc.Transunion_Adverse_Action_Reason1__c;
		cc.Adverse_Action_Reason2__c = cc.Transunion_Adverse_Action_Reason2__c;
		cc.Adverse_Action_Reason3__c = cc.Transunion_Adverse_Action_Reason3__c;
		cc.Adverse_Action_Reason4__c = cc.Transunion_Adverse_Action_Reason4__c;
		cc.Adverse_Action_Reason5__c = cc.Transunion_Adverse_Action_Reason5__c; 		
	}
	
	public static void calculateCreditScore(List<Customer_Credit__c> customerCreditList){
		for(Customer_Credit__c cc : customerCreditList){
            system.debug('cccc>>>' +  cc);
			calculateCreditScore(cc);
            
		}
	}
		
	public static void calculateCreditScore(Customer_Credit__c cc){
		
		if((cc.fico1__c == null || cc.fico1__c == '') && (cc.fico2__c == null || cc.fico2__c == '') && (cc.fico3__c == null || cc.fico3__c == ''))
			return;
		
		if(cc.type__c == 'Sunrun'){
			return;
		}
		
		//if(cc.Status__c != null && (cc.Status__c == CPASS || cc.Status__c == PASS || cc.Status__c == FAIL)){ //Refer: BSKY-3524	
			Integer ficoNumber1 = getFicoNumber(cc.fico1__c);
			Integer ficoNumber2 = getFicoNumber(cc.fico2__c);
			Integer ficoNumber3 = getFicoNumber(cc.fico3__c);
        
        	system.debug('ficoNumber1>>' + ficoNumber1);
        system.debug('ficoNumber2>>' + ficoNumber2);
        system.debug('ficoNumber3>>' + ficoNumber3);
			
			if(ficoNumber1 > ficoNumber2){
				if(ficoNumber1 >= ficoNumber3){
					System.debug('Experian Data: ficoNumber1 > ficoNumber2 & 3');
 					copyExperianData(cc);
				}else{
					System.debug('Equifax Data: ficoNumber3 > ficoNumber1 & 2');
					copyEquifaxData(cc);
				}
				
			}else if(ficoNumber2 > ficoNumber1){
				if(ficoNumber2 >= ficoNumber3){
					System.debug('Transunion Data: ficoNumber2 > ficoNumber1 & 3');
					copyTransUnionData(cc);
				}else{
					System.debug('Equifax Data: ficoNumber3 > ficoNumbe2 & 1');
					copyEquifaxData(cc);
				}
			}else{
				if((ficoNumber2 == ficoNumber1) && ficoNumber3 > ficoNumber1){
					System.debug('Experian Data: ficoNumber3 > ficoNumber1=2');
					copyEquifaxData(cc);				
				}else{
					System.debug('Experian Data: ficoNumber1 == ficoNumber2 & 3');
					copyExperianData(cc);					
				}
			}
		//}

	}

	public static Integer getFicoNumber(String ficoStr){
		Integer ficoNumber = 0;
		if(ficoStr != null && ficoStr != '' && !excludedFicoScores.contains(ficoStr)){
			if(ficoStr.isNumeric()){
				ficoNumber = Integer.valueOf(ficoStr);
			}			
		}	
		return 	ficoNumber;
	}
	
	public static Boolean checkForExlusionCriteria(Customer_Credit__c creditStatusObj){
		Boolean result = false;
		if(creditStatusObj != null){
			if(creditStatusObj.Fico__c != null 
				&& (creditStatusObj.Fico__c == '9000' || creditStatusObj.Fico__c == '9001' || creditStatusObj.Fico__c == '9002' || creditStatusObj.Fico__c == '9003')){
				creditStatusObj.Sunrun_Credit_Status__c = MANUAL ;
				creditStatusObj.Sunrun_Reason_Recorded__c = '900X';
				System.debug('creditStatusObj.Sunrun_Reason_Recorded__c: ' + creditStatusObj.Sunrun_Reason_Recorded__c);
				System.debug('creditStatusObj.Sunrun_Credit_Status__c: ' + creditStatusObj.Sunrun_Credit_Status__c);
				result = true;
			}else if(creditStatusObj.status__c != null &&  creditStatusObj.status__c == 'N/A'){
				creditStatusObj.Sunrun_Credit_Status__c = MANUAL;
				System.debug('creditStatusObj.status__c: ' + creditStatusObj.status__c);
				System.debug('creditStatusObj.Sunrun_Credit_Status__c: ' + creditStatusObj.Sunrun_Credit_Status__c);
				result = true;	
			}else if(creditStatusObj.Reason__c != null &&  (creditStatusObj.Reason__c == 'SSN-FRAUDSHIELD-05' || creditStatusObj.Reason__c == 'SSN-FRAUDSHIELD-06' || creditStatusObj.Reason__c == '900X CODE')){
				creditStatusObj.Sunrun_Credit_Status__c = MANUAL;
				System.debug('creditStatusObj.Reason__c: ' + creditStatusObj.Reason__c);
				System.debug('creditStatusObj.Sunrun_Credit_Status__c: ' + creditStatusObj.Sunrun_Credit_Status__c);
				result = true;	
			}
			
			//if(creditStatusObj.Banky_Outcome__c == null || creditStatusObj.Banky_Outcome__c == ''){
			//	creditStatusObj.Sunrun_Credit_Status__c = MANUAL;
			//	result = true;					
			//}
			//else if(creditStatusObj.Banky_Outcome__c !=null && creditStatusObj.Banky_Outcome__c != '' && 
			//	PROCEED != creditStatusObj.Banky_Outcome__c){
			//	creditStatusObj.Sunrun_Reason_Recorded__c = '';
				//creditStatusObj.Sunrun_Reason_Recorded__c = 'BANKY';
			//	creditStatusObj.Sunrun_Credit_Status__c = FAIL;
			//	result = true;				
			//}
			
			//if(creditStatusObj.Mortgage_Outcome__c != null &&  creditStatusObj.Mortgage_Outcome__c == 'N/A'){
			//	creditStatusObj.Sunrun_Credit_Status__c = MANUAL;
			//	result = true;	
			//}

			/*
			if(creditStatusObj.Mortgage_Outcome__c == null || creditStatusObj.Mortgage_Outcome__c == ''){
				creditStatusObj.Sunrun_Credit_Status__c = MANUAL;
				result = true;					
			}else if(creditStatusObj.Mortgage_Outcome__c != null 
				//&& (creditStatusObj.Mortgage_Outcome__c == 'YES' || creditStatusObj.Mortgage_Outcome__c == PASS)){
				&& (creditStatusObj.Mortgage_Outcome__c.toUpperCase() == FAIL)){
				creditStatusObj.Sunrun_Reason_Recorded__c = 'DELINQ';
				creditStatusObj.Sunrun_Credit_Status__c = FAIL;
				result = true;				
			}
			*/
			
			//if(creditStatusObj.Sunrun_Credit_Status__c == null || creditStatusObj.Sunrun_Credit_Status__c != FAIL){
			//	creditStatusObj.Sunrun_Reason_Recorded__c = ''; 
			//}

		}
		return result;
	}
	
	
	
	public static void updateCreditStatus(List<Customer_Credit__c> customerCreditList){
		for(Customer_Credit__c creditStatusObj : customerCreditList){
			if(creditStatusObj.type__c == 'Sunrun'){
				continue;
			}
			
			Set<String> excludedStatusValues = new Set<String>();
			excludedStatusValues.add(CPASS);
			excludedStatusValues.add(PASS);
			excludedStatusValues.add(FAIL);
			excludedStatusValues.add('N/A');
			
			System.debug('creditStatusObj.Status__c: ' + creditStatusObj.Status__c);
			if(creditStatusObj.Status__c != null && !excludedStatusValues.contains(creditStatusObj.Status__c) && creditStatusObj.Status__c != 'N/A'){ //BSKY-3582
				creditStatusObj.Sunrun_Credit_Status__c = creditStatusObj.Status__c;
				continue;
			}else if(creditStatusObj.Status__c != null && creditStatusObj.Status__c == 'N/A'){
				creditStatusObj.Sunrun_Credit_Status__c = MANUAL;
				System.debug('creditStatusObj.status__c: ' + creditStatusObj.status__c);
				System.debug('creditStatusObj.Sunrun_Credit_Status__c: ' + creditStatusObj.Sunrun_Credit_Status__c);	
				continue;			
			}
			
			String ficoStr = (creditStatusObj.Fico__c != null) ? creditStatusObj.Fico__c : '';
			Integer ficoNumber = 0;
			if(ficoStr.isNumeric()){
				ficoNumber = Integer.valueOf(ficoStr);
			}
			
			Integer ficoScorePass = Integer.valueOf(creditAutomationInfo.get('FICO_PASS').Field_Value__c);
			Integer ficoScoreCPass = Integer.valueOf(creditAutomationInfo.get('FICO_CPASS').Field_Value__c);
			Integer ficoScoreFail = Integer.valueOf(creditAutomationInfo.get('FICO_FAIL').Field_Value__c);
			
			System.debug('1. creditStatusObj.Sunrun_Credit_Status__c: ' + creditStatusObj.Sunrun_Credit_Status__c);
			System.debug('1. creditStatusObj.Status__c: ' + creditStatusObj.Status__c);
			system.debug('creditStatusObj.Banky_Outcome__c>>' +  creditStatusObj.Banky_Outcome__c);
            system.debug('ficoNumber>>' +  ficoNumber);
              system.debug('ficoScoreFail>>' +  ficoScoreFail);
              system.debug('creditStatusObj.Mortgage_Outcome__c>>' +  creditStatusObj.Mortgage_Outcome__c);
              //adding logic for BSKY-6722
            if(ficoNumber <= ficoScoreFail &&( creditStatusObj.Banky_Outcome__c==FAIL || creditStatusObj.Mortgage_Outcome__c==FAIL)){
                creditStatusObj.Sunrun_Credit_Status__c = MANUAL;
            }
            
            
			//Lucid chart & BSKY-3582
			else if(ficoNumber <= ficoScoreFail){
				creditStatusObj.Sunrun_Credit_Status__c = FAIL;
				creditStatusObj.Sunrun_Reason_Recorded__c = 'SCORE';	
				System.debug('creditStatusObj.Sunrun_Credit_Status__c: ' + creditStatusObj.Sunrun_Credit_Status__c);			
			}else{
				if(checkForExlusionCriteria(creditStatusObj) == true){
					continue;
				}else{
					if(ficoNumber > ficoScorePass){  // > 700
						creditStatusObj.Sunrun_Credit_Status__c = PASS;
						System.debug('PASS 1: ' + PASS);
					}else{ // > 650	
						if((creditStatusObj.State__c != null && creditStatusObj.State__c != '' 
								&& stateList.contains(creditStatusObj.State__c)) || 
								(ficoNumber > ficoScoreCPass)){ 
							creditStatusObj.Sunrun_Credit_Status__c = CPASS;
							System.debug('PASS 2.1: ' + CPASS);
						}
					}
				}				
			}

			if(creditStatusObj.Sunrun_Credit_Status__c == null || creditStatusObj.Sunrun_Credit_Status__c != FAIL){
				creditStatusObj.Sunrun_Reason_Recorded__c = ''; 
			}
			
			System.debug('2. creditStatusObj.Sunrun_Credit_Status__c: ' + creditStatusObj.Sunrun_Credit_Status__c);	
		}
		
	}

	public static void copyCreditInformation(Customer_Credit__c cc, LeaseDimensionsWebService.CreditInformation CustomerCreditInfo){

        system.debug('>>>CustomerCreditInfo'+CustomerCreditInfo);
		cc.First_Name__c = CustomerCreditInfo.FirstName;
		cc.Last_Name__c = CustomerCreditInfo.LastName;
		cc.MI__c = CustomerCreditInfo.MI;
		cc.Street__c = CustomerCreditInfo.Street;
		cc.City__c = CustomerCreditInfo.City;
		cc.State__c = CustomerCreditInfo.State;
		cc.Country__c = CustomerCreditInfo.Country;
		cc.Zip__c = CustomerCreditInfo.Zip;
	    cc.DateOfBirth__c = CustomerCreditInfo.DOB;
		cc.Customer_Email__c = CustomerCreditInfo.CustomerEmail;
	    cc.Home_Phone__c = CustomerCreditInfo.HomePhone;
		cc.Employment_Status__c = CustomerCreditInfo.EmploymentStatus;
		cc.Household_Income__c = CustomerCreditInfo.HouseholdIncome;
		cc.Size_of_Household__c = CustomerCreditInfo.SizeOfHousehold;
		cc.Years_at_Home__c = CustomerCreditInfo.YearsAtHome;				

	    cc.Installer__c = CustomerCreditInfo.Installer;
	    cc.Sales_Rep_Email__c = CustomerCreditInfo.SalesRepEmail;
	    cc.Status__c = CustomerCreditInfo.Status;
		
		cc.Home_Equity1__c = CustomerCreditInfo.HomeEquity1;
	    cc.Home_Equity2__c = CustomerCreditInfo.HomeEquity2;
	    cc.Home_Equity_Amt1__c = CustomerCreditInfo.HomeEquityAmt1;
	    cc.Home_Equity_Amt2__c = CustomerCreditInfo.HomeEquityAmt2;
	    cc.Home_Equity_OpenDate2__c = CustomerCreditInfo.HomeEquityOpenDate1;
	    cc.Home_Equity_OpenDate2__c = CustomerCreditInfo.HomeEquityOpenDate2;

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
		
		//Experian Data
		cc.Bureau1__c = CustomerCreditInfo.Bureau1;
		cc.Date_Run1__c = CustomerCreditInfo.X1DatePulled;
		cc.FICO1__c = CustomerCreditInfo.X1Fico;
		cc.Experian_Reason__c = CustomerCreditInfo.X1Reason;
		
		cc.Experian_Banky_Outcome__c = CustomerCreditInfo.X1BankyOutcome;	
		cc.Experian_Mortgage_Outcome__c = CustomerCreditInfo.X1MortgageOutcome;	
		cc.Experian_BKFilingCode__c = CustomerCreditInfo.X1BKFilingCode;   //This field is not present for TransUnion & Equifax
		cc.Experian_BKFilingDate__c = CustomerCreditInfo.X1BKFilingDate;   //This field is not present for TransUnion & Equifax
		cc.Experian_BKOver60months__c = CustomerCreditInfo.X1BKOver60months;  //This field is not present for TransUnion & Equifax
		cc.Experian_BKNumMonths__c = CustomerCreditInfo.X1BKNumMonths;  //This field is not present for TransUnion & Equifax
		
		cc.Experian_Adverse_Action_Reason1__c = CustomerCreditInfo.X1AdverseActionReason1;
		cc.Experian_Adverse_Action_Reason2__c = CustomerCreditInfo.X1AdverseActionReason2;
		cc.Experian_Adverse_Action_Reason3__c = CustomerCreditInfo.X1AdverseActionReason3;
		cc.Experian_Adverse_Action_Reason4__c = CustomerCreditInfo.X1AdverseActionReason4;
		cc.Experian_Adverse_Action_Reason5__c = CustomerCreditInfo.X1AdverseActionReason5;

		//TransUnion Data
		cc.Bureau2__c = CustomerCreditInfo.Bureau2;
		cc.Date_Run2__c = CustomerCreditInfo.X2DatePulled;
		cc.FICO2__c = CustomerCreditInfo.X2Fico;
		cc.TransUnion_Reason__c = CustomerCreditInfo.X2Reason;
		cc.TransUnion_Banky_Outcome__c = CustomerCreditInfo.X2BankyOutcome;	
		cc.TransUnion_Mortgage_Outcome__c = CustomerCreditInfo.X2MortgageOutcome;	
		
		cc.TransUnion_Adverse_Action_Reason1__c = CustomerCreditInfo.X2AdverseActionReason1;
		cc.TransUnion_Adverse_Action_Reason2__c = CustomerCreditInfo.X2AdverseActionReason2;
		cc.TransUnion_Adverse_Action_Reason3__c = CustomerCreditInfo.X2AdverseActionReason3;
		cc.TransUnion_Adverse_Action_Reason4__c = CustomerCreditInfo.X2AdverseActionReason4;
		cc.TransUnion_Adverse_Action_Reason5__c = CustomerCreditInfo.X2AdverseActionReason5;

		//Equifax Data
		cc.Bureau3__c = CustomerCreditInfo.Bureau3;
		cc.Date_Run3__c = CustomerCreditInfo.X3DatePulled;
		cc.FICO3__c = CustomerCreditInfo.X3Fico;
		cc.Equifax_Reason__c = CustomerCreditInfo.X3Reason;
		cc.Equifax_Banky_Outcome__c = CustomerCreditInfo.X3BankyOutcome;	
		cc.Equifax_Mortgage_Outcome__c = CustomerCreditInfo.X3MortgageOutcome;	
		
		cc.Equifax_Adverse_Action_Reason1__c = CustomerCreditInfo.X3AdverseActionReason1;
		cc.Equifax_Adverse_Action_Reason2__c = CustomerCreditInfo.X3AdverseActionReason2;
		cc.Equifax_Adverse_Action_Reason3__c = CustomerCreditInfo.X3AdverseActionReason3;
		cc.Equifax_Adverse_Action_Reason4__c = CustomerCreditInfo.X3AdverseActionReason4;
		cc.Equifax_Adverse_Action_Reason5__c = CustomerCreditInfo.X3AdverseActionReason5;
 		//new field added for Ofac Status
 		system.debug('>>>>>CustomerCreditInfo.Ofac:'+ CustomerCreditInfo.Ofac);
        cc.OFAC_Status__c=CustomerCreditInfo.Ofac;
        
		//TODO: Following fields are missing in the WSDL
		cc.Failed_Score__c = CustomerCreditInfo.FailedScore; 
		cc.Gen__c = CustomerCreditInfo.Gen;
		cc.Other_Phone__c = CustomerCreditInfo.OtherPhone;
		cc.Date_Approved__c = CustomerCreditInfo.DateApproved;
		Datetime currentTime = Datetime.now();
	    cc.Date_Submitted__c = (CustomerCreditInfo.DatePulled == null) ? currentTime : CustomerCreditInfo.DatePulled ;
	    cc.Employer__c = CustomerCreditInfo.Employer;
	    cc.Estimated_Home_Value__c = CustomerCreditInfo.EstimatedHomeValue;
	    if(CustomerCreditInfo.HomeOwnerSigned != null)
	    {
	      cc.Home_Owner_Signed__c = CustomerCreditInfo.HomeOwnerSigned;
	    }
		cc.Income__c = CustomerCreditInfo.Income;
		cc.LTV__c = CustomerCreditInfo.LTV;	
		cc.Deal_Id__c = (CustomerCreditInfo.DealId != null && CustomerCreditInfo.DealId != '') ? CustomerCreditInfo.DealId : cc.Deal_Id__c;	 
	}

}