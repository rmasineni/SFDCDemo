public interface NearbyCustomersViewerService {
    List<NearbyCustomersViewerServiceDto.ContractWithDistance> findContractsWithinDistance(Integer maxRecords, Double withinDistanceInMiles, Decimal lat, Decimal lng);
    List<NearbyCustomersViewerServiceDto.ContractWithDistance> findContractsWithinDistance(Decimal lat, Decimal lng);
    List<NearbyCustomersViewerServiceDto.OptyWithDistance> findOptiesWithinDistance(Integer maxRecords, Double withinDistanceInMiles, Decimal lat, Decimal lng);
    List<NearbyCustomersViewerServiceDto.LeadWithDistance> findLeadsWithinDistance(Integer maxRecords, Double withinDistanceInMiles, Decimal lat, Decimal lng, String ignoreLeadId);
    Opportunity queryOptyWithAddressDetails(String optyId);
    Lead queryLeadWithAddressDetails(String leadId);
}