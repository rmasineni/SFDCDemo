trigger trg_task_bf_insert_sungevity on Task (before insert) {
    Schema.DescribeSObjectResult genAssetResult = Generation_Assets__c.sObjectType.getDescribe();
    Schema.DescribeSObjectResult caseResult = case.sObjectType.getDescribe();
    Schema.DescribeSObjectResult scResult = ServiceContract.sObjectType.getDescribe();
    Schema.DescribeSObjectResult scEventResult = Service_Contract_Event__c.sObjectType.getDescribe();
    
    String genAssetKeyPrefix = genAssetResult.getKeyPrefix();
    String caseKeyPrefix = caseResult.getKeyPrefix();  
    String scKeyPrefix = scResult.getKeyPrefix();
    String scEventKeyPrefix = scEventResult.getKeyPrefix();  
    
    Set<string> genassets=new Set<String>();
    Set<string> cases=new Set<String>();
    Set<string> serviceContracts=new Set<String>();
    Set<string> serviceContractEvents=new Set<String>();
    
    for(task t:trigger.new){        
        String temp=(String)t.whatid;
        if(temp!=null&&t.type=='Email'){
            if(temp.substring(0,3)==genAssetKeyPrefix){
                genassets.add(t.whatid);
            }else if(temp.substring(0,3)==caseKeyPrefix){
                cases.add(t.whatid);
            }else if(temp.substring(0,3)==scKeyPrefix){
                serviceContracts.add(t.whatid);
            }else if(temp.substring(0,3)==scEventKeyPrefix){
                serviceContractEvents.add(t.whatid);
            }
        }
    }
    system.debug('---genassets'+genassets);
    Map<string,string> caseIdInstallPartner=new Map<string,string>();
    if(!cases.isempty()){
    for(case c:[select id,Generation_Asset__c,Service_Contract__r.install_partner__c, Generation_Asset__r.install_partner__c from case where id in:cases]){
        if(c.Generation_Asset__r.install_partner__c=='Sungevity'){
            caseIdInstallPartner.put(c.id,c.Generation_Asset__r.install_partner__c);
        }
        if(c.Service_Contract__r.install_partner__c =='Sungevity'){
            caseIdInstallPartner.put(c.id,c.Service_Contract__r.install_partner__c);
        }
    }
    }
    Map<String,String> GenIdInstallPartner=new Map<String,String>();
    Map<String,String> scIdInstallPartner=new Map<String,String>();
    Map<String,String> scEventIdInstallPartner=new Map<String,String>();
    if(!genassets.isempty()){
    for(Generation_Assets__c gen:[select Id, install_partner__c from Generation_Assets__c where id in:genassets]){
        if(gen.Install_Partner__c=='Sungevity'){
            GenIdInstallPartner.put(gen.id,gen.Install_Partner__c); 
        }
    }
    }

    if(!serviceContracts.isempty()){
        for(ServiceContract scObj:[select Id, install_partner__c from ServiceContract where id in:serviceContracts]){
            if(scObj.Install_Partner__c=='Sungevity'){
                scIdInstallPartner.put(scObj.id,scObj.Install_Partner__c); 
            }
        }
    }
    if(!serviceContractEvents.isempty()){
        for(Service_Contract_Event__c scEventObj:[select Id, Service_Contract__r.install_partner__c from Service_Contract_Event__c where id in:serviceContractEvents]){
            if(scEventObj.Service_Contract__r.Install_Partner__c=='Sungevity'){
                scEventIdInstallPartner.put(scEventObj.id, scEventObj.Service_Contract__r.Install_Partner__c); 
            }
        }
    }
    
   for(task t:system.trigger.new){
        String temp=(String)t.whatid;
        if(temp!=null&&t.type=='Email'){
        if(GenIdInstallPartner.containsKey(t.whatid)&&t.description!=null){
            if((!(t.description.toLowerCase().contains('sungevity')||t.Subject.tolowerCase().contains('sungevity'))))
            t.adderror('<font color="Red"><b>Please select a sungevity asset template</b></font>');
        }else if(scIdInstallPartner.containsKey(t.whatid)&&t.description!=null){
            if((!(t.description.toLowerCase().contains('sungevity')||t.Subject.tolowerCase().contains('sungevity'))))
            t.adderror('<font color="Red"><b>Please select a sungevity asset template</b></font>');
        }
        else if(temp.substring(0,3)==genAssetKeyPrefix&&!GenIdInstallPartner.containsKey(t.whatid)&&t.description!=null) {                       
                if(t.description.toLowerCase().contains('sungevity')||t.Subject.tolowerCase().contains('sungevity'))
                t.adderror('<font color="Red"><b>Please select a non sungevity asset templates</b></font>');
            
        }else if(((temp.substring(0,3)==scKeyPrefix&&!scIdInstallPartner.containsKey(t.whatid)) || 
                (temp.substring(0,3)==scEventKeyPrefix&&!scEventIdInstallPartner.containsKey(t.whatid)))&&t.description!=null) {                       
                if(t.description.toLowerCase().contains('sungevity')||t.Subject.tolowerCase().contains('sungevity'))
                t.adderror('<font color="Red"><b>Please select a non sungevity asset templates</b></font>');
            
        }
        else if(caseIdInstallPartner.containsKey(t.whatid)&&t.description!=null){
            if(!(t.description.toLowerCase().contains('sungevity')||t.Subject.tolowerCase().contains('sungevity')))
            t.adderror('<font color="Red"><b>Please select a sungevity asset template</b></font>'); 
        }
        else if(temp.substring(0,3)==caseKeyPrefix&&!caseIdInstallPartner.containsKey(t.whatid)&&t.description!=null){
                if(t.description.toLowerCase().contains('sungevity')||t.Subject.tolowerCase().contains('sungevity'))                      
                t.adderror('<font color="Red"><b>Please select a non sungevity asset templates</b></font>');            
        }
        }
    }               
    
}