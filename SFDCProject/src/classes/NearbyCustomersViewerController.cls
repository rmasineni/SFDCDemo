public class NearbyCustomersViewerController extends BaseClass {
	
    public List<NearbyCustomersViewerServiceDto.LeadWithDistance> leads {get;set;}
    public List<NearbyCustomersViewerServiceDto.OptyWithDistance> opties {get;set;}
    public List<NearbyCustomersViewerServiceDto.ContractWithDistance> contracts {get;set;}
    
    public Decimal referenceLat {get;set;}
    public Decimal referenceLng {get;set;}
    public String referenceObjName {get;set;}
    public String referenceObjRecordId {get;set;}
    public String referenceObjRecordName {get;set;}
    public String referenceStreet {get;set;}
    public String referenceCity {get;set;}
    public String referenceState {get;set;}
    public String referencePostalCode {get;set;}
    public Double withInDistance {get;set;}
    public Boolean validReference {get;set;}
    public Integer maxRecords {get;set;}
    
    public NearbyCustomersViewerController() {
        try {
            referenceObjRecordId = getRequiredParameter('id');
            referenceObjName = getSobjectName(referenceObjRecordId);
            withInDistance = Decimal.valueOf(getParameter('distance', Sf.settingsService.getString('NearbyCustomersViewerMaxDistance', '15')));
            maxRecords = Integer.valueOf(getParameter('maxRecords', Sf.settingsService.getString('NearbyCustomersViewerMaxRecords', '100')));
            
            validReference = false;
            
            if (referenceObjName == 'Lead') {
    			Lead lead = Sf.nearbyCustomersViewerService.queryLeadWithAddressDetails(referenceObjRecordId);
                
                info('Reference lead ' +lead);
                
                referenceLat = lead.Latitude__c;
                referenceLng = lead.Longitude__c;
                referenceObjRecordName = lead.name;
                referenceStreet = lead.Street;
                referenceCity = lead.City;
                referenceState = lead.State;
                referencePostalCode = lead.PostalCode;

            } else if (referenceObjName == 'Opportunity') {
    			Opportunity opty = Sf.nearbyCustomersViewerService.queryOptyWithAddressDetails(referenceObjRecordId);
                
                info('Reference opty ' +opty);
                
                referenceLat = opty.Account.Latitude__c;
                referenceLng = opty.Account.Longitude__c;
                referenceObjRecordName = opty.name;
                referenceStreet = opty.Account.BillingStreet;
                referenceCity = opty.Account.BillingCity;
                referenceState = opty.Account.BillingState;
                referencePostalCode = opty.Account.BillingPostalCode;
            }
            
            if (isNullOrZero(referenceLat) || isNullOrZero(referenceLng)) {
                throw new BusinessException('Latidue/Longitude co-ordinates are not avaiable or invalid for selected record [' + referenceObjRecordId + ']');
            }

            loadContracts();
            validReference = true;
        } catch (Exception e) {
            addErrorMessage(e);
        }
    }
    
    public String getLeadsJson() {
        return Json.serialize(leads);
    }

    public String getOptiesJson() {
        return Json.serialize(opties);
    }
    
    public String getContractsJson() {
        return Json.serialize(contracts);
    }

    public PageReference loadOpportunities() {
        try {
            if (opties == null) {
                opties = Sf.nearbyCustomersViewerService.findOptiesWithinDistance(maxRecords, withInDistance, referenceLat, referenceLng);
            }
        } catch (Exception e) {
            addErrorMessage(getStackTrace(e));
        }
        return null;
    }

    public PageReference loadContracts() {
        try {
            if (contracts == null) {
				contracts = Sf.nearbyCustomersViewerService.findContractsWithinDistance(maxRecords, withInDistance, referenceLat, referenceLng);
            }
        } catch (Exception e) {
            addErrorMessage(getStackTrace(e));
        }
        return null;
    }

    public PageReference loadLeads() {
        try {
            if (leads == null) {
				leads = Sf.nearbyCustomersViewerService.findLeadsWithinDistance(maxRecords, withInDistance, referenceLat, referenceLng, referenceObjRecordId);
            }
        } catch (Exception e) {
            addErrorMessage(getStackTrace(e));
        }
        return null;
    }
    
    public Boolean getShowCustomerPII() {
        return !isRoleMatchesWildcard('Consultant*Sales*');
    }
}