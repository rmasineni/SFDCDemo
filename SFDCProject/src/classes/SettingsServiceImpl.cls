public without sharing class SettingsServiceImpl extends BaseClass implements SettingsService {
	
    private static final Integer MAX_VALUES = 10;
    private static final Integer MaxValueLength = 255;
    
	public void setString(String key, String value) {
        
        Settings__c setting = Settings__c.getValues(key);
        
        if (setting == null) { 
            setting = new Settings__c();
        }
        setting.name = key;
        setting.value1__c = emptyIfNull(value);
        
        upsert setting;
    }
    
    public String getString(String key) {
        String value = getString(key, null);
        if (value == null) {
            throw new BusinessException('String setting is null for key "' + key + '"');
        }

        return value;
    }

    public String getString(String key, String defaultValue) {
        Settings__c setting = Settings__c.getValues(key);
        
        if (setting == null) {
        	debug('Setting is null for key ' + key + ' so returning default');
            return defaultValue;
        }
        
        String keyValue = null;
        
        //Setting values could be stroed under 5 values. We will need to concatenate all of them into one.
        for (Integer i = 1; i <= MAX_VALUES; i++) {
            String value = (String) setting.get('Value' + i + '__c');
            if (value == null) {
                continue;
            }
            
            if (keyValue == null) {
                keyValue = value;
            } else {
                keyValue += value;
            }
        }
		
        if (keyValue == null) {
            keyValue = defaultValue;
        }
        
        debug('Returning the String Setting ' + key + '=' + keyValue);        

        return keyValue;
    }

    public void setInteger(String key, Integer value) {
        setString(key, value==null?null:String.valueOf(value));
    }

    public Integer getInteger(String key) {
        Integer value = getInteger(key, null);
        if (value == null) {
            throw new BusinessException('Integer setting is null for key "' + key + '"');
        }
        
        return value;
    }

    public Integer getInteger(String key, Integer defaultValue) {
        String stringValue = getString(key, null);
        Integer value = defaultValue;
        
        if (isNotEmpty(stringValue)) {
            value = Integer.valueOf(stringValue);
        }
        
        debug('Returning the Integer setting for ' + key + ' as ' + value);
        return value;
    }
    
    public void setDouble(String key, Double value) {
        setString(key, value==null?null:String.valueOf(value));
    }

    public Double getDouble(String key) {
        Double value = getDouble(key, null);
        if (value == null) {
            throw new BusinessException('Double setting is null for key "' + key + '"');
        }
        
        return value;
    }

    public Double getDouble(String key, Double defaultValue) {
        String stringValue = getString(key, null);
        Double value = defaultValue;
        
        if (isNotEmpty(stringValue)) {
            value = Double.valueOf(stringValue);
        }
        
        debug('Returning the Double setting for ' + key + ' as ' + value);
        return value;
    }

    public void setBoolean(String key, Boolean value) {
        setString(key, value==null?null:String.valueOf(value));
    }
    
    public Boolean getBoolean(String key) {
        Boolean value = getBoolean(key, null);
        if (value == null) {
            throw new BusinessException('Boolean setting is null for key "' + key + '"');
        }
        
        return value;
    }

    public Boolean getBoolean(String key, Boolean defaultValue) {
        String stringValue = getString(key, null);
        
        Boolean value = defaultValue;
        
        if (isNotEmpty(stringValue)) {
            value = Boolean.valueOf(stringValue);
        }
        
        debug('Returning the Boolean setting for ' + key + ' as ' + value);
        return value;
    }
    
    public void setDate(String key, Date value) {
        setString(key, value==null?null:String.valueOf(value));
    }

    public Date getDate(String key) {
        Date value = getDate(key, null);
        if (value == null) {
            throw new BusinessException('Date setting is null for key "' + key + '"');
        }
        
        return value;
    }

    public Date getDate(String key, Date defaultValue) {
        String stringValue = getString(key, null);
        
        Date value = defaultValue;
        
        if (isNotEmpty(stringValue)) {
            value = Date.valueOf(stringValue);
        }
        
        debug('Returning the Date setting for ' + key + ' as ' + value);
        return value;
    }

    public void setDateTime(String key, DateTime value) {
        setString(key, value==null?null:value.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss\'Z\''));
    }

    public DateTime getDateTime(String key) {
        DateTime value = getDateTime(key, null);
        if (value == null) {
            throw new BusinessException('DateTime setting is null for key "' + key + '"');
        }
        
        return value;
    }

    public DateTime getDateTime(String key, DateTime defaultValue) {
        String stringValue = getString(key, null);
        
        DateTime value = defaultValue;
        
        if (isNotEmpty(stringValue)) {
            value = (DateTime)json.deserialize('"' + stringValue + '"', DateTime.class);
        }
        
        debug('Returning the DateTime setting for ' + key + ' as ' + value);
        return value;
    }
    
    public Map<String, String> getStringMap(String key) {
        Map<String, String> value = getStringMap(key, null);
        if (value == null) {
            throw new BusinessException('String Map setting is null for key "' + key + '"');
        }
        
        return value;
    }
    
    public Map<String, String> getStringMap(String key, Map<String, String> defaultValue) {
        Map<String, String> mapSetting = null;
        
        //Map settings should be stored as follows.
        //key1=value1,key2=value2,key3=
        String stringValue = getString(key, null);
		
        try {
            if (isEmpty(stringValue)) {
                mapSetting = defaultValue;
                
            } else {
                mapSetting = new Map<String, String>();
                
                String[] pairs = stringValue.split(',');
                for(String pair : pairs) {
                    String[] keyValues = pair.split('=');
                    mapSetting.put(keyValues[0], keyValues[1]);
                }
            }
        } catch (Exception e) {
            throw new BusinessException('Exception while getting the StringMap setting for key ' + key + ' and decoding its value ' + stringValue);
        }
        
        return mapSetting;
    }

    public List<String> getStringList(String key) {
        List<String> value = getStringList(key, null);
        if (value == null) {
            throw new BusinessException('String List setting is null for key "' + key + '"');
        }
        
        return value;
    }
    
    public List<String> getStringList(String key, List<String> defaultValue) {
        List<String> listSetting = null;
        
        //List settings should be stored as follows.
        //value1,value2,value3 etc
        String stringValue = getString(key, null);
		
        try {
            if (isEmpty(stringValue)) {
                listSetting = defaultValue;
                
            } else {
                listSetting = new List<String>();
                
                String[] values = stringValue.split(',');
                for(String value : values) {
                    listSetting.add(value);
                }
            }
        } catch (Exception e) {
            throw new BusinessException('Exception while getting the String List setting for key ' + key + ' and decoding its value ' + stringValue);
        }
        
        return listSetting;
    }
    
    public String getStringMapEntry(String settingsKey, String mapKey) {
        Map<String, String> stringMap = getStringMap(settingsKey);
        if (stringMap.containsKey(mapKey)) {
            return stringMap.get(mapKey);
        }
        
        throw new BusinessException('Map entry is not defined for key "' + mapKey + '" in Settings "' + settingsKey + '"');
    }
    
    public String getStringMapEntry(String settingsKey, String mapKey, String defaultValue) {
        Map<String, String> stringMap = getStringMap(settingsKey, null);

        if (stringMap != null && stringMap.containsKey(mapKey)) {
            return stringMap.get(mapKey);
        }

        return defaultValue;
    }
    
    public void clearEnvironmentSpecificSettings() {
        
        String soql = null;
        for (Integer i = 1; i <= MAX_VALUES; i++) {
            if (soql == null) {
            	soql = 'select Value' + i + '__c';
            } else {
                soql += ', Value' + i + '__c';
            }
        }
        
        soql += ' from Settings__c where Environment_Specific__c = true';
        
        List<Settings__c> settings = Database.query(soql);
        
        for (Settings__c setting : settings) {
        	for (Integer i = 1; i <= MAX_VALUES; i++) {
            	setting.put('Value' + i + '__c', '');
            }
        }
        
        update settings;
    }
	
	/**
	 * Sometimes when settings are copied from one env to another, the ValueN__c fieds will have value 'null'
	 * which is a problem. This script removes such values.
	 * 
	 * I hope nobody wants to specify 'null' as legitemate value.
	 */    
    public void removeNullValues() {
        List<Settings__c> settings = [
            SELECT 
	            Value1__c,Value2__c,Value3__c,Value4__c,Value5__c,Value6__c,Value7__c,Value8__c,Value9__c,Value10__c 
           	FROM Settings__c
       	];
        
        for (Settings__c setting : settings) {
            for (Integer i = 1; i <= MAX_VALUES; i++) {
                if (setting.get('Value' + i + '__c') == 'null') {
                    setting.put('Value' + i + '__c', null);
                }
            }
        }
        
        update settings;        
    }    
    
    /**
     * Breaks the given value into strings of 255 chars and sets to various values.
     */
    public void splitAndSetString(String key, String value) {
        value = value.trim();
		List<String> values = new List<String>();
        while(value.length() > 0) {
            if (value.length() <= MaxValueLength) {
                values.add(value);
                break;
            }
            
            values.add(value.substring(0, MaxValueLength));
            value = value.substring(MaxValueLength);
        }
        
        Settings__c setting = Settings__c.getValues(key);
        
        if (setting == null) { 
            setting = new Settings__c();
        }
        setting.name = key;
        
        for (Integer i = 1; i <= MAX_VALUES; i++) {
            setting.put('Value' + i + '__c', null);
        }
        
        for (Integer i = 1; i <= values.size(); i++) {
            setting.put('Value' + i + '__c', values.get(i - 1));
        }

        upsert setting;
    }

    /**
     * Breaks the given value into strings of 255 chars and sets to various values.
     */
    public void splitAndSetMap(String key, String value) {
        value = value.trim();
		List<String> values = new List<String>();
		List<String> pairs = value.split(',');
        String currentPairValue = '';
        
        for (String pair : pairs) {
            String newValue = currentPairValue.trim() + ',' + pair.trim();
            if (newValue.length() > MaxValueLength) {
                if (values.isEmpty()) {
	                values.add(currentPairValue);
                } else {
                    values.add(',' + currentPairValue);
                }
                currentPairValue = '';
            }
            
            if (!String.isBlank(currentPairValue)) {
                currentPairValue += ',';
            }
            
            currentPairValue += pair.trim();
        }
        
        if (!String.isBlank(currentPairValue)) {
            if (values.isEmpty()) {
                values.add(currentPairValue);
            } else {
                values.add(',' + currentPairValue);
            }
        }
        
        Settings__c setting = Settings__c.getValues(key);
        
        if (setting == null) { 
            setting = new Settings__c();
        }
        setting.name = key;
        
        for (Integer i = 1; i <= MAX_VALUES; i++) {
            setting.put('Value' + i + '__c', null);
        }
        
        for (Integer i = 1; i <= values.size(); i++) {
            setting.put('Value' + i + '__c', values.get(i - 1));
        }

        upsert setting;
    }
}