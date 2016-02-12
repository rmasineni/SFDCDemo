@RestResource(urlMapping='/v2/opportunities/fields')
global class OptyApiFieldsEndpoint {

    @HttpGet
    global static void httpGet() {
        
        try {
            JsonWriter writer = new JsonWriter();
            
            addFieldMapping('opportunity', OptyApiDto.getOptyApiOptyFieldMapping(), writer);
            addFieldMapping('account', OptyApiDto.getOptyApiAccountFieldMapping(), writer);
            addFieldMapping('contact', OptyApiDto.getOptyApiContactFieldMapping(), writer);
            
            RestContext.response.responseBody = Blob.valueOf(writer.toPrettyJson());
        } catch (Exception e) {
            throw new BusinessException(new BaseClass().getStackTrace(e));
        }
    }
    
    public static void addFieldMapping(String fieldsGroup, Map<String, String> dynamicMapping, JsonWriter writer) {
        List<RestServiceDto.Field> fields = new List<RestServiceDto.Field>();
        
        for (String key : dynamicMapping.keySet()) {
            fields.add(new RestServiceDto.Field(key, dynamicMapping.get(key), 'CRUD'));
        }
        
        //This reverse sorts the fields as they will be sorted correctly in json output
        fields.sort();
        
        for (RestServiceDto.Field field : fields) {
            writer.writeIfNotEmpty(fieldsGroup + '.' + field.restField + '.sfdcField', field.sfdcField);
        }
    }
}