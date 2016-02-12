@istest(seealldata=true)
public with sharing class UnitTest_OpportunityPageExtension {
static testmethod void method1(){
    id sunrunid=system.label.sunrun_inc_id;
    Opportunity optyObj1 = TestPRMLibrary.insertOpportunity('ResidentialAccount-3', 'Residential',
                                                                'ResOpty-3', 'Platinum');
    OpportunityShare os=new OpportunityShare(rowcause='Manual',opportunityid=optyObj1.id,userorgroupid=System.Label.SunRun_CRM,OpportunityAccessLevel='Edit');
    insert os;
    ApexPages.StandardController controller2 = new Apexpages.Standardcontroller(optyObj1);
    system.currentPageReference().getParameters().put('Id',optyObj1.id);
    system.currentPageReference().getParameters().put('OpptyEdit','false');
    OpportunityPageExtension oppExt2 = new OpportunityPageExtension(controller2);  
    oppExt2.onLoad();
    oppExt2.save();
    oppExt2.cancel();
    oppExt2.selecteddesign='Saved Project';
    oppExt2.redirectDesignTool();      
    market__c mar=new market__c(state__c='CA',utility_company__c='PG&E');
    insert mar;
    Market_assignment__c ma=new Market_assignment__c(partner__c=sunrunid,market__c=mar.id,role__c='Sales;Install');
    insert ma;   
    Opportunity_Fields__c optyfld=new Opportunity_Fields__c(name='ExpectedRevenue');
    insert optyfld;
    optyObj1.Sales_Partner__c=sunrunid;
    optyObj1.install_partner__c=sunrunid;
    optyObj1.Market_Assignment_Sales__c=ma.id;
    optyObj1.Market_Assignment_Install__c=ma.id;
    optyObj1.Opportunity_Source_Type__c='BB';
    Decimal d1= 5000;
    optyObj1.Square_footage__c=d1;
    optyObj1.channel_2__c ='3rd Party';
    optyObj1.Lead_Source_2__c='3rd Party';
    optyObj1.Utility_Company__c='PG&E';
    optyObj1.territory__c='NA';
    optyObj1.home_type__c='Single Family';
    optyObj1.Usage_Option__c='Basic';  
    update optyObj1;   
    //Contact userCont=new Contact(Contact_Type__c='Employee',lastname='test',email=userinfo.getUserEmail(),sunrun_user__c=userinfo.getuserid()); 
    //insert userCont;                                                        
    Contact cont=TestPRMLibrary.insertContact(optyobj1.accountid, 'Residential','fname',
                                                                'ResOpty-3', 'testdfsfsf@yopmail.com');
    OpportunityContactRole ocr=new OpportunityContactRole(isprimary=true,opportunityid=optyObj1.id,contactid=cont.id,role='Homeowner');
    insert ocr;                                                                
    Appointment__c appointObj=new Appointment__c(opportunity__c=optyObj1.id,Appointment_Date_Time__c=system.now(),Appointment_End_Date_Time__c=system.now());
    insert appointObj;
    Partner_role__c salesPr=new Partner_role__c(opportunity__c=optyObj1.id,Partner_Name__c=sunrunid,role__c='Sales',Sales_Rep_Division__c='Inside Sales',SalesRep__c=userinfo.getuserid(),sales_rep_email__c='testsss@yopmail.com');                                                            
    Partner_role__c installPr=new Partner_role__c(opportunity__c=optyObj1.id,Partner_Name__c=sunrunid,role__c='Install',Sales_Rep_Division__c='Inside Sales',SalesRep__c=userinfo.getuserid(),sales_rep_email__c='testsss@yopmail.com');
    List<Partner_role__c> prlist=new List<Partner_role__c>();
    prList.add(salesPr);
    prList.add(installPr);
    insert prList;
    ApexPages.StandardController controller = new Apexpages.Standardcontroller(optyObj1);
    system.currentPageReference().getParameters().put('Id',optyObj1.id);
    system.currentPageReference().getParameters().put('OpptyEdit','false');
    OpportunityPageExtension oppExt = new OpportunityPageExtension(controller);  
    oppExt.onLoad();   
    oppExt.save();
    oppExt.selectedDesign='New Project';
    oppExt.editOppty();
    oppExt.createAppointment();
    oppExt.cancel();
    oppExt.shareOppty();  
    oppExt.doReferral();
    oppExt.doOffer(); 
    oppExt.doClone(); 
    oppExt.redirectDesignTool();  
    oppExt.getPartnerTermsConditions();
    oppExt.acceptTermsandConditions();
    oppExt.declineTermsandConditions();  
    List<Contact> contacts =[select id, T_C_Accepted__c from Contact where Sunrun_User__c=:userinfo.getUserId() AND Email= :userinfo.getUserEmail() AND Contact_Type__c='Employee'];
    if(!contacts.isEmpty()){
    contacts.get(0).T_C_Accepted__c =false;
    update contacts.get(0);
    }                               
    oppExt.redirectDesignTool();
    salesPr.Sales_Rep_Email__c=null;
    update salesPr;
    ApexPages.StandardController controller3 = new Apexpages.Standardcontroller(optyObj1);
    system.currentPageReference().getParameters().put('Id',optyObj1.id);
    system.currentPageReference().getParameters().put('OpptyEdit','false');
    OpportunityPageExtension oppExt3 = new OpportunityPageExtension(controller); 
    oppExt3.redirectDesignTool();
    oppExt3.selecteddesign='New Project';
    oppExt3.redirectDesignTool();  
    oppExt3.isCloned=true;
    oppExt3.Save();     
    Set<id> contactids=new Set<id>();
    contactids.add(cont.id);
    
    Set<id> opptyids=new Set<id>();
    opptyids.add(optyObj1.id);
    ContactShareByOppty.doContactSharing(contactids,opptyids);      
}
}