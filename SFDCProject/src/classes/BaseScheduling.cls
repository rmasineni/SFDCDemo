public with sharing virtual class  BaseScheduling extends BaseClass {
	
	public static Map<String, Map<Date, Integer>> tzOffsetMap = new Map<String, Map<Date, Integer>>();
	
	public String getLoginUserTimezone(){
		TimeZone tz = UserInfo.getTimeZone();
		String timezoneId = tz.getID();
		return timezoneId;
	}
			
	public Timezone getTimezone(String  tzIdStr){
		return TimeZone.getTimeZone(tzIdStr);
	}

	public Integer getOffset(Date dtVal, String tzIdStr){
		Integer result = 0;
		if(dtVal != null && !String.isEmpty(tzIdStr)){
			Timezone ltz = getTimezone(tzIdStr);
			result = ltz.getOffset(dtVal);
			result = result / (1000*60*60);
		}
		return result;
	}

	public Integer getOffset(Datetime dtVal, String tzIdStr){
		Integer result = 0;
		if(dtVal != null && !String.isEmpty(tzIdStr)){
			Timezone ltz = getTimezone(tzIdStr);
			result = ltz.getOffset(dtVal);
			result = result / (1000*60*60);
		}
		return result;
	}
    public String getCustomerTimeZone(Account accountObj){
    	Boolean hasDaylightSavings = (accountObj.HasDaylightSavings__c == 'true') ? true : false;
		return getCustomerTimeZone(accountObj.TimeZone__c, hasDaylightSavings);
    }
    
    public String getCustomerTimeZone(Opportunity optyObj){
    	Boolean hasDaylightSavings = (optyObj.Account.HasDaylightSavings__c == 'true') ? true : false;
		return getCustomerTimeZone(optyObj.Account.TimeZone__c, hasDaylightSavings);
    }
	public String getCustomerTimeZone(String timezoneStr, Boolean hasDaylightSavings){
    	String customerTimeZone = '';
		if(timezoneStr == 'PST' || timezoneStr == 'PST-2'){
			customerTimeZone = (hasDaylightSavings == true) ? 'America/Los_Angeles' : 'America/Los_Angeles';
		}else if(timezoneStr == 'EST'){
			customerTimeZone = (hasDaylightSavings == true) ? 'America/New_York' : 'America/Panama';
		}else if(timezoneStr == 'CST'){
			customerTimeZone = (hasDaylightSavings == true) ? 'America/Chicago' : 'America/El_Salvador';
		}else if(timezoneStr == 'MST'){
			customerTimeZone = (hasDaylightSavings == true) ? 'America/Denver' : 'America/Phoenix';
		}else if(timezoneStr == 'HST'){
			customerTimeZone = (hasDaylightSavings == true) ? 'America/Adak' : 'Pacific/Honolulu';
		}
		System.debug('customerTimeZone: ' + customerTimeZone);
		return customerTimeZone;
    }

	public String getTimezoneName(String timezoneId) {
        if (timezoneId == 'America/Los_Angeles') {
            return 'Pacific';
            
        } else  if (timezoneId == 'America/New_York' || timezoneId == 'America/Panama') {
            return 'Eastern';

        } else  if (timezoneId == 'America/Chicago' || timezoneId == 'America/El_Salvador') {
            return 'Central';

        } else  if (timezoneId == 'America/Denver' || timezoneId == 'America/Phoenix') {
            return 'Mountain';

        } else  if (timezoneId == 'America/Adak' || timezoneId == 'America/Honolulu') {
            return 'Hawaii';
        } else {
            return 'Name not configured (' + timezoneId + ')';
        }

    }
    
	public String getFormattedTime(Datetime dateTimeVal, String timeZonVal){
		return (String.isEmpty(timeZonVal)) ? dateTimeVal.format('hh:mm a') : dateTimeVal.format('hh:mm a', timeZonVal);
	}

	public String getFormattedDatetime(Datetime dateTimeVal, String timeZonVal){
		return (String.isEmpty(timeZonVal)) ? dateTimeVal.format() : dateTimeVal.format('MM/dd/yyyy hh:mm a', timeZonVal);
	}

    public Integer getTimezoneOffSet(Datetime dateTimeVal, String timezoneStr){
    	return getTimezoneOffSet(dateTimeVal.date(), timezoneStr);
    }
    
	public Integer getTimezoneOffSet(Date dateVal, String timezoneStr){
		Integer result = 0;
		Boolean hasValue = false;
		if(tzOffsetMap.containskey(timezoneStr)){
			Map<Date, Integer> tempMap = tzOffsetMap.get(timezoneStr);
			if(tempMap.containsKey(dateVal)){
				result = tempMap.get(dateVal);
				hasValue = true;
			}
		}
		
		if(hasValue == false){
			result = getOffset(dateVal, timezoneStr);
			Map<Date, Integer> tempMap = tzOffsetMap.containskey(timezoneStr) ? tzOffsetMap.get(timezoneStr) : new Map<Date, Integer>();
			tempMap.put(dateVal, result);
			tzOffsetMap.put(timezoneStr, tempMap);
		}
		return result;
	}

	public Boolean hasValidLatLong(Account accountObj){
		Boolean result = true;
		if(accountObj.Latitude__c == null || accountObj.Latitude__c == 0 || accountObj.Longitude__c == null || accountObj.Longitude__c == 0){
			result = false;
		}
		return result;
	}
	
	public Boolean hasValidLatLong(Opportunity optyObj){
		Boolean result = true;
		if(optyObj.Account.Latitude__c == null || optyObj.Account.Latitude__c == 0 || optyObj.Account.Longitude__c == null || optyObj.Account.Longitude__c == 0){
			result = false;
		}
		return result;
	}
	public String getStringValue(String inputStr){
		return (String.isEmpty(inputStr)) ? '' : inputStr;
	}
}