@isTest(SeeAllData=true)
public with sharing class UnitTest_trg_task_bf_insert_sungevity {
    public static testmethod void UnitTest_trg_task_bf_insert_sungevity(){
    Generation_assets__c gen=new Generation_Assets__c(name='Test',Home_Address__c='123 Street',City__c='San Francisco',Zip__c='90090',install_partner__c='Sungevity');
    Generation_assets__c gen2=new Generation_Assets__c(name='Test',Home_Address__c='123 Street',City__c='San Francisco',Zip__c='90090',install_partner__c='Solar City');
    List<Generation_assets__c> genList=new List<Generation_assets__c>();
    genList.add(gen);
    genList.add(gen2);
    insert genList;
    Account a = New Account(Name = 'TestAccount2');
    insert a;
    ServiceContract sc = New ServiceContract(Name = 'Sunrun Contract',AccountId =a.Id,Legacy_Asset_Number__c = '12222006',Install_Partner__c = 'Sungevity');        
    List<ServiceContract> scList = new List<ServiceContract>();
    scList.add(sc);
    insert scList;
    Service_Contract_Event__c sce = New Service_Contract_Event__c(service_Contract__c=sc.id);
    insert sce;
    contact c=[select id from contact where email!=null order by createddate limit 1 ];
    case ca=new case(Reason='Billing',  Cause_of_Issue__c='Sunrun/No Fault',Origin='Internal',generation_asset__c=genList[0].id);
    case ca1=new case(Reason='Billing', Cause_of_Issue__c='Sunrun/No Fault',Origin='Internal',generation_asset__c=genList[1].id);
    case ca2=new case(Reason='Billing', Cause_of_Issue__c='Sunrun/No Fault',Origin='Internal',Service_Contract_Event__c=sce.id);
    case ca3=new case(Reason='Billing', Cause_of_Issue__c='Sunrun/No Fault',Origin='Internal',Service_Contract__c=scList[0].id);
    List<case> caseList=new List<case>();
    caseList.add(ca);
    caseList.add(ca1);
    caseList.add(ca2);
    caseList.add(ca3);
    insert caseList;
    
       
    task t2=new task(whatid=caseList[0].id,subject='dfdfass',description='abc',whoid=c.id,type='Email');
    task t3=new task(whatid=genList[0].id,subject='dfdfass',description='abc',whoid=c.id,type='Email');
    task t4=new task(whatid=genList[1].id,subject='Sungevity',description='abc',whoid=c.id,type='Email');
    task t5=new task(whatid=caseList[1].id,subject='Sungevity',description='abc',whoid=c.id,type='Email');
    task t6= new task(whatid=sc.id,subject='Sungevity',description='abc',whoid=c.id,type='Email');
    task t7= new task(whatid=caseList[3].id,subject='Sungevity',description= 'abc',whoid=c.id,type='Email'); 
    task t8= new task(whatid=sce.id,subject='Sungevity',description= 'abc',whoid=c.id,type='Email'); 
    List<task> listTask=new List<task>();
    listTask.add(t2);
    listTask.add(t3);
    listTask.add(t4);
    listTask.add(t5);
    listTask.add(t6);
    listTask.add(t7);
    listTask.add(t8);
    try{
    insert listTask;
    }
    catch(exception e){
        system.debug(e);
    }
    
        }
    
    
}