@istest(seeAllData=true)
public with sharing class Test_ServiceContractCreateCase {
 public static testMethod void Test_ServiceContractCreateCase(){
    Test.starttest();
    Recordtype r=[select id from recordtype where sobjecttype='Account' limit 1];
    Account a= [select id,name from account where office_location__c='Headquarters' and Ultimate_Parent_Account__c=null limit 1];
    Contact cont= new Contact (firstname='Test',LastName='TestCt',Accountid=a.Id,Ultimate_Parent_Account__c=a.id);
    insert cont;
    String name='Test'+system.now();
    ServiceContract sc= new ServiceContract(name=name.substring(0, 10),Accountid=a.id,Agreement_Number__c='123',TE_Fund_Name__c='Fund',install_partner__c=a.name); 
        insert sc;
        Service_Contract_Event__c sce = new Service_Contract_Event__c (Service_Contract__c=sc.id) ;
        insert sce;
        Case c=new case(status='Open',Service_Contract__c=sc.id,Reason='Customer',Subset_Reasons__c='Panel Washing',Amount__c=10);
        insert c;
        ApexPages.StandardController controller = new Apexpages.Standardcontroller(c);         
        SC_CreateCase cas=new SC_CreateCase(controller);
        cas.getInvRec();
        cas.cancel();
        cas.saveCreate(); 
        system.currentPageReference().getParameters().put('scid',sc.id);
        SC_CreateCase cas1=new SC_CreateCase(controller);
        Case c1=new case();  
        ApexPages.StandardController controller1 = new Apexpages.Standardcontroller(c1);   
        SC_CreateCase cas2=new SC_CreateCase(controller1);      
    
        Test.stoptest();
 }
}