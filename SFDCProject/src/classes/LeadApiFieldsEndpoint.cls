@RestResource(urlMapping='/v2/leads/fields')
global class LeadApiFieldsEndpoint {

    @HttpGet
    global static void httpGet() {
        
        try {
            List<RestServiceDto.Field> fields = new List<RestServiceDto.Field>();

            Map<String, String> dynamicMapping = LeadApiDto.getLeadApiLeadFieldMapping();
            for (String key : dynamicMapping.keySet()) {
                fields.add(new RestServiceDto.Field(key, dynamicMapping.get(key), 'CRUD'));
            }

            //Add the hard coded fields.
            fields.add(new RestServiceDto.Field(LeadApiDto.RestField_consultationDateTime, 'Consultation_Date_and_Time__c and Consultation_Time__c', 'C'));
            fields.add(new RestServiceDto.Field(LeadApiDto.RestField_leadOrgLocationName, dynamicMapping.get(LeadApiDto.RestField_leadOrgLocationId), 'CRUD'));
            
            //This reverse sorts the fields as they will be sorted correctly in json output
            fields.sort();
            
            JsonWriter writer = new JsonWriter();
            writer.ignoreNulls = true;
            
            for (RestServiceDto.Field field : fields) {
                writer.write(field.restField + '.sfdcField', field.sfdcField);
            }
            
            RestContext.response.responseBody = Blob.valueOf(writer.toPrettyJson());
        } catch (Exception e) {
            throw new BusinessException(new BaseClass().getStackTrace(e));
        }
    }

}