@istest
public with sharing class UnitTest_LeadPageExtension {
static testmethod void testLeadPageExtension(){
    Id sunrunid=Label.Sunrun_Inc_Id;
    market__c mar=new market__c(state__c='CA',utility_company__c='PG&E');
    insert mar;
    Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Account; 
    Map<String,Schema.RecordTypeInfo> AccountRecordTypeInfo = cfrSchema.getRecordTypeInfosByName();
    Id r = AccountRecordTypeInfo .get('Branch').getRecordTypeId();
    Account acc= new Account(name='TestSunRun', lead_eligible__c=true, recordtypeid=r,Parentid=sunrunid,Ultimate_Parent_Account__c=sunrunid);
    insert acc;
    Market_assignment__c ma=new Market_assignment__c(partner__c=sunrunid,market__c=mar.id,role__c='Sales;Install');
    insert ma;
    List<lead> ldlist=new list<lead>();
    Lead ld=new lead(install_Branch_Id__c=acc.id,Market_Assignment_Sales__c=ma.id,Market_Assignment_install__c=ma.id,lead_qualifier__c=userinfo.getuserid(),email='testesrs@yopmail.com',Sales_partner__c=sunrunid,install_partner__c=sunrunid,channel__c='3rd Party',custom_lead_source__c='3rd Party: Clean Energy Authority',lastname='TEst',Synchronous_Assignment__c=true,Company='Test',firstname='Test',score__c=8,street='170 diamond st',city='San Francisco',state='CA',postalcode='94114');
    //insert ld;
    Lead ld2=new lead(install_Branch_Id__c=acc.id,Market_Assignment_Sales__c=ma.id,Market_Assignment_install__c=ma.id,lead_qualifier__c=userinfo.getuserid(),email='testesrs@yopmail.com',Sales_partner__c=sunrunid,install_partner__c=sunrunid,channel__c='3rd Party',custom_lead_source__c='3rd Party: Clean Energy Authority',lastname='TEst',Synchronous_Assignment__c=true,Company='Test',firstname='Test',score__c=8,street='170 diamond st',city='San Francisco',state='CA',postalcode='94114');
    //insert ld2;
    ldlist.add(ld);
    ldlist.add(ld2);
    insert ldlist;
    Lead_Fields__c lf=new Lead_Fields__c(name='AnnualRevenue');
    insert lf;
    lead l=new lead(lastname='test',phone='123');
    ApexPages.StandardController controller = new Apexpages.Standardcontroller(ld);
    system.currentPageReference().getParameters().put('Id',ld.id);
    system.currentPageReference().getParameters().put('LeadEdit','false');
    LeadPageExtension ldExt = new LeadPageExtension(controller);
    ldExt.leadId=ld.id;
    Pagereference p= ldExt.onLoad();
    ldExt.leadValidations();
    //ldExt.doConvert();
    ldExt.Save();
    ldExt.editLead();
    ldExt.doClone();
    ldExt.shareLead();
    ldExt.findDuplicates();
    ldExt.cancel();
    ldExt.closePopup();
    ldExt.showPopup();
    ldExt.doConvert();
    //ldExt.SaveConvert();
    LeadPageExtension ldExt2 = new LeadPageExtension(new Apexpages.Standardcontroller(l));   
    ldExt2.save();   
    //ldExt2.SaveConvert(); 
    ConvertLead.doConvert(ld.id);
    LeadPageExtension ldExt3 = new LeadPageExtension(new Apexpages.Standardcontroller(ld2)); 
    ldExt3.leadObj=ld2;
    ldExt3.onLoad();
    ldExt3.cancel();
    ldExt3.SaveConvert();
    ldExt3.iscloned=true;
    ldExt3.Save();
    lead l4=new lead(lastname='test',mobilephone='232',status='Out of Market');
    LeadPageExtension ldExt4= new LeadPageExtension(new Apexpages.Standardcontroller(l4));
    ldExt4.leadValidations();
    ldExt4.convertValidations();
    lead l5=new lead(lastname='test',mobilephone='232',install_partner__c=label.sunrun_inc_id);
    LeadPageExtension ldExt5= new LeadPageExtension(new Apexpages.Standardcontroller(l5));    
    ldExt5.convertValidations();
    lead l6=new lead(lastname='test',mobilephone='232');
    LeadPageExtension ldExt6= new LeadPageExtension(new Apexpages.Standardcontroller(l6));    
    ldExt6.convertValidations();           
    
}
}