public class sendEmailInstallComplete {
    
    public Id EventId {get;set;}
    public Id ContractId{get;set;}
    public Id ProposalId{get;set;}
    public Id RecordId{get;set;}
    
    public sendEmailInstallComplete()
    {}


    public List<Asset_Information__c> getevents()
    {
        List<Asset_Information__c> event;
        
        Service_Contract_Event__c ServiceEvent;
        ServiceContract ServiceCon;
       
        ServiceEvent = [SELECT Service_Contract__c from Service_Contract_Event__c where Id = :EventId];
        ContractId = ServiceEvent.Service_Contract__c;
        
        ServiceCon = [SELECT Proposal__c from ServiceContract where Id = :ContractId];
        
        ProposalId = ServiceCon.Proposal__c;
        
        event = [SELECT Manufacturer__c,Model__c FROM Asset_Information__c WHERE ProposalName__c = :ProposalId AND Type__c = 'Inverter'];
        return event;
    }
    public Asset_Information__c getPanels()
    {
        Asset_Information__c AssetPanel;
        ServiceContract ServiceCon;
        Service_Contract_Event__c ServiceEvent;
        
       
        ServiceEvent = [SELECT Service_Contract__c from Service_Contract_Event__c where Id = :EventId];
        ContractId = ServiceEvent.Service_Contract__c;
        ServiceCon = [SELECT Proposal__c from ServiceContract where Id = :ContractId];
        ProposalId = ServiceCon.Proposal__c;
        AssetPanel = [SELECT Manufacturer__c,Model__c FROM Asset_Information__c WHERE ProposalName__c = :ProposalId AND Type__c = 'Panel' LIMIT 1];
        return AssetPanel;
    }
 
}