public without sharing class GenerateReferralDataController {

public GenerateReferralDataController(){}

public List<ReferralData> listReferralData = new List<ReferralData>();

public String fromDate {get;set;}
public String toDate {get;set;}
    
public List<ReferralData> getRefData(){
    return listReferralData;    
}

public Promotion__c RP{get;set;}

public Boolean bExcel{get;set;}

public PageReference genExcel() {
    bExcel = true;
    PageReference pr = new PageReference('/apex/GenerateReferralData?fromDate=' + String.ValueOf(RP.Start_Date__c).substring(0,10) + '&toDate=' + String.ValueOf(RP.End_Date__c).substring(0,10) + '&excel=Y');
    pr.setRedirect(true);
    return pr;
}

public pageReference refreshData2() {
    getReferralData();
    getthousandBlocks();    
    return null;
}

public pageReference refreshData() {
    PageReference pr = new PageReference('/apex/GenerateReferralData?fromDate=' + String.ValueOf(RP.Start_Date__c).substring(0,10) + '&toDate=' + String.ValueOf(RP.End_Date__c).substring(0,10) + '&excel=N');
    pr.setRedirect(true);
    return pr;
}

//Handling VF 1000 Limit on Page Rendering Issue
public limitWrapper[] thousandBlocks = new limitWrapper[]{};
public final integer listLimit = 999;
public class limitWrapper{
        public ReferralData[] refdata {get;set;}
        public integer blockNumber {get;set;}
        public limitWrapper(ReferralData[] refList, integer i)
        {
            refdata = refList;
            blockNumber = i;
        }
}

public limitWrapper[] getthousandBlocks(){
        //
        thousandBlocks = new limitWrapper[]{};
        
        integer counter = 0;
        integer loopCount = 0;
        ReferralData[] tmpRefData = new ReferralData[]{};
        
        for(ReferralData ref:listReferralData)
        {
            if(counter < listLimit)
            {
               tmpRefData.add(ref);
               counter++;
            }
            else
            {
                //System.Debug('Current Running Total = ' + counter + ' and the loop count = ' + loopCount);
                loopCount++;
                thousandBlocks.add(new limitWrapper(tmpRefData,loopCount));
                tmpRefData = new ReferralData[]{};
                tmpRefData.add(ref);
                counter = 0;
            }            
        }
        
        if(tmpRefData.size() > 0)   //thousandBlocks.size() == 0)
        {
            loopCount++;
            thousandBlocks.add(new limitWrapper(tmpRefData,loopCount));
        }
        return thousandBlocks;
}
// End of new code for 1000 limit

public void init(){
    bExcel = false;
    RP = new Promotion__c();    
    //
    String fDate = ApexPages.CurrentPage().getparameters().get('fromDate');
    String tDate = ApexPages.CurrentPage().getparameters().get('toDate');
    String strExcel = ApexPages.CurrentPage().getparameters().get('excel');
    if(strExcel == 'Y')
    {
        bExcel = true;
    }
    if(fDate != null && tDate != null)
    {
       RP.Start_Date__c = date.newInstance(Integer.valueOf(fDate.substring(0,4)), Integer.valueOf(fDate.substring(5,7)), Integer.valueOf(fDate.substring(8))); 
       RP.End_Date__c = date.newInstance(Integer.valueOf(tDate.substring(0,4)), Integer.valueOf(tDate.substring(5,7)), Integer.valueOf(tDate.substring(8)));
    }
    else
    {  
       RP.Start_Date__c = date.newInstance(2000,1,1);
       RP.End_Date__c = date.newInstance(2050,1,1);
    }    
    getReferralData();
}

public void getReferralData() {
//    
    fromDate = String.ValueOf(RP.Start_Date__c).substring(0,10); 
    toDate = String.ValueOf(RP.End_Date__c).substring(0,10); 
    Integer i = 1;
    //SOQL for new Data Model
    //Relies on Event based model that updates status to "Qualified for Payment"
    Set<Id> setSourceContactIds = new Set<Id>();
    Map<Id, Generation_Assets__c> mapSourceGenAsset = new Map<Id, Generation_Assets__c>();
    List<Referral_Input__c> listReferrals = new List<Referral_Input__c>();
    for(Referral_Input__c r:[Select Id, Name, Milestone_1_Status__c, Milestone_2_Status__c, Milestone_3_Status__c,Referrer_Status_1__c,Referrer_Status_2__c,Referrer_Status_3__c,
                                    Paid_Date_Milestone_1__c, Paid_Date_Milestone_2__c, Paid_Date_Milestone_3__c,
                                    LastModifiedDate,Referee_Status_1__c,Referee_Status_2__c,Referee_Status_3__c,
                                    Promotion__r.Name,
                                    Promotion__r.Referrer_Payment_Option1__c, Promotion__r.Referee_Payment_Option1__c, Promotion__r.Referee_Payment_Amount1__c, Promotion__r.Referrer_Payment_Amount1__c, Promotion__r.At_Stage1__c, Promotion__r.Referral_Payout_on1__c, 
                                    Promotion__r.Referrer_Payment_Option2__c, Promotion__r.Referee_Payment_Option2__c, Promotion__r.Referee_Payment_Amount2__c, Promotion__r.Referrer_Payment_Amount2__c, Promotion__r.At_Stage2__c, Promotion__r.Referral_Payout_on2__c, 
                                    Promotion__r.Referrer_Payment_Option3__c, Promotion__r.Referee_Payment_Option3__c, Promotion__r.Referee_Payment_Amount3__c, Promotion__r.Referrer_Payment_Amount3__c, Promotion__r.At_Stage3__c, Promotion__r.Referral_Payout_on3__c,
                                    Source_Contact_Id__c, Source_Contact_Id__r.Name, Source_Contact_Id__r.MailingStreet, Source_Contact_Id__r.ERP_Contact_of_Record__c,
                                    Target_Contact_Id__c, Target_Contact_Id__r.Name, Target_Contact_Id__r.MailingStreet, Target_Contact_Id__r.ERP_Contact_of_Record__c,
                                    Generation_Asset__r.PTO_Recorded_Date__c,
                                    Generation_Asset__r.PTO__c,Generation_Asset__r.Asset_Status__c,Generation_Asset__r.M1_proof_panel_inverter_delivery__c,
                                    Generation_Asset__r.Name,
                                    Generation_Asset__r.Utility_Company__c,
                                    Generation_Asset__r.Install_Partner__c,
                                    Generation_Asset__r.Channel__c,
                                    Generation_Asset__r.Agreement_Type__c,
                                    Generation_Asset__r.ERP_Utility__c,
                                    Generation_Asset__r.Billing_Method__c,
                                    Generation_Asset__r.TE_Fund_Name__c                
                               from Referral_Input__c         
                              where (   Referrer_Status_1__c = :Label.ReferralReadyForPayment                         
                                     or Referrer_Status_2__c = :Label.ReferralReadyForPayment
                                     or Referrer_Status_3__c = :Label.ReferralReadyForPayment
                                     or Referee_Status_1__c = :Label.ReferralReadyForPayment
                                     or Referee_Status_2__c = :Label.ReferralReadyForPayment
                                     or Referee_Status_3__c = :Label.ReferralReadyForPayment)    
                                    ])
    {       
        setSourceContactIds.add(r.Source_Contact_Id__c);
        listReferrals.add(r); 
                                          
    }
   
    for(Generation_Assets__c ga:[select id, PTO_Recorded_Date__c,PTO__c,Name,Utility_Company__c,Install_Partner__c,
                                        Channel__c,Agreement_Type__c,ERP_Utility__c,Billing_Method__c,
                                        Customer_Contact__c, TE_Fund_Name__c,Upfront_Payment_Amount__c,
                                        Upfront_Payment_Amount_Rec_d__c,Initial_Deposit_Amount__c,Initial_Deposit_Amount_Received__c,asset_status__c,M1_proof_panel_inverter_delivery__c
                                   from Generation_Assets__c 
                                  where Customer_Contact__c in :setSourceContactIds
                                    and Date_Cancelled__c = null                            
                                  order by PTO__c])
    {
    	 if(((ga.Upfront_Payment_Amount__c == ga.Upfront_Payment_Amount_Rec_d__c) || ((ga.Upfront_Payment_Amount__c ==0 && ga.Upfront_Payment_Amount_Rec_d__c==null)||(ga.Upfront_Payment_Amount__c ==null && ga.Upfront_Payment_Amount_Rec_d__c==0)))
    	 && (ga.Initial_Deposit_Amount__c == ga.Initial_Deposit_Amount_Received__c) || ((ga.Initial_Deposit_Amount__c ==0 && ga.Initial_Deposit_Amount_Received__c ==null)||(ga.Initial_Deposit_Amount__c ==null&& ga.Initial_Deposit_Amount_Received__c ==0)))
        mapSourceGenAsset.put(ga.Customer_Contact__c, ga);      
   }
    
    System.Debug('number of referrals queried: '+listReferrals.size());
    System.Debug('source contacts: '+setSourceContactIds);
    
    for(Referral_Input__c r:listReferrals)
    {
        Date dtTxn = date.newinstance(r.LastModifiedDate.year(), r.LastModifiedDate.month(), r.LastModifiedDate.day());
        Generation_Assets__c sourcega = new Generation_Assets__c();
        if(mapSourceGenAsset.get(r.Source_Contact_Id__c) != null)
        {
            sourcega = mapSourceGenAsset.get(r.Source_Contact_Id__c);
        }
        
        if((r.Referrer_Status_1__c == Label.ReferralReadyForPayment) &&(r.Generation_Asset__r.Asset_Status__c !='Deal Cancelled' || r.Generation_Asset__r.Asset_Status__c !='Deal Cancelled due to credit') &&(r.Generation_Asset__r.M1_proof_panel_inverter_delivery__c != null) && (r.Generation_Asset__r.TE_Fund_name__c!=null))
        {
            if(RP.Start_Date__c <= dtTxn && RP.End_Date__c >= dtTxn && r.Source_Contact_Id__r.ERP_Contact_of_Record__c && r.Promotion__r.Referrer_Payment_Amount1__c != null && r.Promotion__r.Referrer_Payment_Amount1__c > 0)
            {
               listReferralData.add(new ReferralData(r, sourcega, i, 'Source', 1));
               i++;
               system.debug('source loop');
            }
            
        }
        if((r.Referee_Status_1__c == Label.RefereeReadyForPayment) &&(r.Generation_Asset__r.Asset_Status__c !='Deal Cancelled' || r.Generation_Asset__r.Asset_Status__c !='Deal Cancelled due to credit') &&(r.Generation_Asset__r.M1_proof_panel_inverter_delivery__c != null) && (r.Generation_Asset__r.TE_Fund_name__c!=null))
        {  
            if(RP.Start_Date__c <= dtTxn && RP.End_Date__c >= dtTxn && r.Target_Contact_Id__r.ERP_Contact_of_Record__c && r.Promotion__r.Referee_Payment_Amount1__c != null && r.Promotion__r.Referee_Payment_Amount1__c > 0)
            {
               listReferralData.add(new ReferralData(r, sourcega, i, 'Target', 1));
               i++;
               system.debug('target loop');
            }           
        }
        if((r.Referrer_Status_2__c == Label.ReferralReadyForPayment) &&(r.Generation_Asset__r.Asset_Status__c !='Deal Cancelled' || r.Generation_Asset__r.Asset_Status__c !='Deal Cancelled due to credit') &&(r.Generation_Asset__r.M1_proof_panel_inverter_delivery__c != null) && (r.Generation_Asset__r.TE_Fund_name__c!=null))
        {
            if(RP.Start_Date__c <= dtTxn && RP.End_Date__c >= dtTxn && r.Source_Contact_Id__r.ERP_Contact_of_Record__c && r.Promotion__r.Referrer_Payment_Amount2__c != null && r.Promotion__r.Referrer_Payment_Amount2__c > 0)
            {
               listReferralData.add(new ReferralData(r, sourcega, i, 'Source', 2));
               i++;
            }
            
        }
        if((r.Referee_Status_2__c == Label.RefereeReadyForPayment) &&(r.Generation_Asset__r.Asset_Status__c !='Deal Cancelled' || r.Generation_Asset__r.Asset_Status__c !='Deal Cancelled due to credit') &&(r.Generation_Asset__r.M1_proof_panel_inverter_delivery__c != null) && (r.Generation_Asset__r.TE_Fund_name__c!=null) ) {  
            if(RP.Start_Date__c <= dtTxn && RP.End_Date__c >= dtTxn && r.Target_Contact_Id__r.ERP_Contact_of_Record__c && r.Promotion__r.Referee_Payment_Amount2__c != null && r.Promotion__r.Referee_Payment_Amount2__c > 0)
            {
               listReferralData.add(new ReferralData(r, sourcega, i, 'Target', 2));
               i++;
            }           
        }
        if((r.Referrer_Status_3__c == Label.ReferralReadyForPayment) &&(r.Generation_Asset__r.Asset_Status__c !='Deal Cancelled' || r.Generation_Asset__r.Asset_Status__c !='Deal Cancelled due to credit') &&(r.Generation_Asset__r.M1_proof_panel_inverter_delivery__c != null) && (r.Generation_Asset__r.TE_Fund_name__c!=null))
        {
            if(RP.Start_Date__c <= dtTxn && RP.End_Date__c >= dtTxn && r.Source_Contact_Id__r.ERP_Contact_of_Record__c && r.Promotion__r.Referrer_Payment_Amount3__c != null && r.Promotion__r.Referrer_Payment_Amount3__c > 0)
            {
               listReferralData.add(new ReferralData(r, sourcega, i, 'Source', 3));
               i++;
            }
        }
        if((r.Referee_Status_3__c == Label.RefereeReadyForPayment) &&(r.Generation_Asset__r.Asset_Status__c !='Deal Cancelled' || r.Generation_Asset__r.Asset_Status__c !='Deal Cancelled due to credit') &&(r.Generation_Asset__r.M1_proof_panel_inverter_delivery__c != null) && (r.Generation_Asset__r.TE_Fund_name__c!=null)){   
            if(RP.Start_Date__c <= dtTxn && RP.End_Date__c >= dtTxn && r.Target_Contact_Id__r.ERP_Contact_of_Record__c && r.Promotion__r.Referee_Payment_Amount3__c != null && r.Promotion__r.Referee_Payment_Amount3__c > 0)
            {
               listReferralData.add(new ReferralData(r, sourcega, i, 'Target', 3));
               i++;
            }           
        }       
    } 
  
}
public Class ReferralData{
    public String refid{get; set;}
    public String refname{get; set;}
    public String trxid{get; set;}
    public String statid{get; set;}
    public Date trxdate{get; set;}
    public Double creditamount{get; set;}
    public String creditreason{get; set;}
    public String textforcustomerinvoice{get; set;}
    public String genassetnumber{get; set;}
    public String ppd{get; set;}
    public String utility{get; set;}
    public String channel{get; set;}
    public String salespartner{get; set;}
    public String tefundname{get;set;}
    public String contactname{get;set;}
    public String getPPDValue(String BillingMethod){
        String strPPDValue = 'No';
        if(BillingMethod == 'Full Upfront'
           || BillingMethod == 'Prepay')
        {           
           strPPDValue = 'Yes';
        }
        else
        {           
           /*
           None
           One-time
           Pay by Check
           Recurring          
           */
           strPPDValue = 'No';
        }
        return strPPDValue;
    }  
    
    public ReferralData(Referral_Input__c r, Generation_Assets__c sourceGA, Integer txn, String direction, Integer MilestoneNumber)
    {	
    	statid=string.valueof(MilestoneNumber);
        if(direction == 'Source')
        {
            refid = r.Id;
            refname = r.Name;
            trxid = String.ValueOf(txn); //make sure that this will not repeat in the next running or if it matters!            
            trxdate = date.newinstance(r.LastModifiedDate.year(), r.LastModifiedDate.month(), r.LastModifiedDate.day());
            if(MilestoneNumber == 1)
            {
                creditamount = r.Promotion__r.Referrer_Payment_Amount1__c;               
                creditreason = 'Milestone 1 Reached for ' + r.Promotion__r.Name + ': ' + r.Promotion__r.Referral_Payout_on1__c + ' reached ' + r.Promotion__r.At_Stage1__c + ' State and earned a ' + r.Promotion__r.Referrer_Payment_Option1__c;                
            }
            if(MilestoneNumber == 2)
            {
                creditamount = r.Promotion__r.Referrer_Payment_Amount2__c;
                creditreason = 'Milestone 2 Reached for ' + r.Promotion__r.Name + ': ' + r.Promotion__r.Referral_Payout_on2__c + ' reached ' + r.Promotion__r.At_Stage2__c + ' State and earned a ' + r.Promotion__r.Referrer_Payment_Option2__c;
            }            
            if(MilestoneNumber == 3)
            {
                creditamount = r.Promotion__r.Referrer_Payment_Amount3__c;
                creditreason = 'Milestone 3 Reached for ' + r.Promotion__r.Name + ': ' + r.Promotion__r.Referral_Payout_on3__c + ' reached ' + r.Promotion__r.At_Stage3__c + ' State and earned a ' + r.Promotion__r.Referrer_Payment_Option3__c;
            }            
            //
            textforcustomerinvoice = 'Referral to ' + r.Target_Contact_Id__r.Name + ' @ ' + r.Target_Contact_Id__r.MailingStreet;
           system.debug('--sourceGA'+sourceGA);
           genassetnumber = sourceGA.Name;
            ppd = getPPDValue(sourcega.Billing_Method__c);
            utility = sourcega.ERP_Utility__c;
            channel = sourcega.Channel__c;
            salespartner = sourcega.Install_Partner__c;    
            contactname = r.Source_Contact_Id__r.Name;    
            tefundname = sourceGA.TE_Fund_Name__c;
        }
        if(direction == 'Target')
        {
            refid = r.Id;
            refname = r.Name;
            trxid = String.ValueOf(txn); //make sure that this will not repeat in the next running or if it matters!
            trxdate = date.newinstance(r.LastModifiedDate.year(), r.LastModifiedDate.month(), r.LastModifiedDate.day());
            if(MilestoneNumber == 1)
            {
                creditamount = r.Promotion__r.Referee_Payment_Amount1__c;
                creditreason = 'Milestone 1 Reached for ' + r.Promotion__r.Name + ': ' + r.Promotion__r.Referral_Payout_on1__c + ' reached ' + r.Promotion__r.At_Stage1__c + ' State and earned a ' + r.Promotion__r.Referee_Payment_Option1__c;
            }
            if(MilestoneNumber == 2)
            {
                creditamount = r.Promotion__r.Referee_Payment_Amount2__c;
                creditreason = 'Milestone 2 Reached for ' + r.Promotion__r.Name + ': ' + r.Promotion__r.Referral_Payout_on2__c + ' reached ' + r.Promotion__r.At_Stage2__c + ' State and earned a ' + r.Promotion__r.Referee_Payment_Option2__c;
            }            
            if(MilestoneNumber == 3)
            {
                creditamount = r.Promotion__r.Referee_Payment_Amount3__c;
                creditreason = 'Milestone 3 Reached for ' + r.Promotion__r.Name + ': ' + r.Promotion__r.Referral_Payout_on3__c + ' reached ' + r.Promotion__r.At_Stage3__c + ' State and earned a ' + r.Promotion__r.Referee_Payment_Option3__c;
            }            
            textforcustomerinvoice = 'Referred by ' + r.Source_Contact_Id__r.Name + ' @ ' + r.Source_Contact_Id__r.MailingStreet;            
            genassetnumber = r.Generation_Asset__r.Name;
            ppd = getPPDValue(r.Generation_Asset__r.Billing_Method__c);
            utility = r.Generation_Asset__r.ERP_Utility__c;
            channel = r.Generation_Asset__r.Channel__c;
            salespartner = r.Generation_Asset__r.Install_Partner__c;    
            contactname = r.Target_Contact_Id__r.Name;    
            tefundname = r.Generation_Asset__r.TE_Fund_Name__c; 
        }               
    }        
}

}