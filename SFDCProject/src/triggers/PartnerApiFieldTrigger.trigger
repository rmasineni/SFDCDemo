trigger PartnerApiFieldTrigger on Partner_Api_Field__c (before insert, before update) {
	
    //Make sure the Sobject and Name matches.
    BaseClass utils = new BaseClass();
    
    for (Partner_Api_Field__c field : Trigger.new) {
        if (field.Api__c == null) {
            throw new BusinessException('Value missing for required field "Api"');
        }
        
		field.Sobject__c = utils.describeSobject(field.Sobject__c).getName();
		field.Sfdc_Field__c = validateAndNormalizeField(field.Sobject__c, field.Sfdc_Field__c);
        field.Read_Only__c = field.Sfdc_Field__c.split('\\.').size() > 1;
		field.Unique_Token__c = field.Api__c + '-' + field.Rest_Field__c;
    }
    
    /**
     * Validates the field specified by user to make sure that field exists. This takes care of 
     * validating both simple fields as well as relationship fields like Account__r.Name.
     * 
     * If validation fails, will throw BusinessException. Else, returns the normalized field name.
     */
    public static String validateAndNormalizeField(String sobj, String field) {
        //If this is simple field, that object's specific field then just describing would be good enough.
        List<String> segments = field.split('\\.');
		
        //This seems like a relationship field with __r references. We will have to split all
        //of these segments and describe sobject for each of those segments.
        List<String> validatedSegments = new List<String>();
        //throw new BusinessException('field=' + field + ', segmentssize=' + segments.size() + ', segments=' + String.valueOf(segments));
        
        for (integer i = 0; i < segments.size() - 1; i++) {
            String segment = segments.get(i).toLowerCase();
            if (segment.endsWith('__r')) {
                Schema.DescribeFieldResult fieldDescribe = utils.describeField(sobj, segment.replace('__r', '__c'));
                Schema.sObjectType parentSobj = fieldDescribe.getReferenceTo().get(0);
                
                //We need to change the sobj to this new sobj.
                sobj = parentSobj.getDescribe().getName();
                
                //Field is valid for sobject so let's change to __r and add to segments.
                validatedSegments.add(fieldDescribe.getName().replace('__c', '__r'));
            } else {
                //This is standard field and they usually have Id for id field.
                Schema.DescribeFieldResult fieldDescribe = utils.describeField(sobj, segment + 'Id');
                Schema.sObjectType parentSobj = fieldDescribe.getReferenceTo().get(0);
                
                //We need to change the sobj to this new sobj.
                sobj = parentSobj.getDescribe().getName();
                
                //Field is valid for sobject so let's change to __r and add to segments.
                validatedSegments.add(fieldDescribe.getName().substringBefore('Id'));
            }
        }
        
		validatedSegments.add(utils.describeField(sobj, segments.get(segments.size() - 1)).getName());
        
        return utils.join(validatedSegments, '.');
    }
}