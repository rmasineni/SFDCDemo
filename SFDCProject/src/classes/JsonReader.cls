public virtual class JsonReader {
    
    private Object jsonObj = null;
    private String withPrefix = null;
        
    public JsonReader(String jsonString) {
        this(Json.deserializeUntyped(jsonString));
    }

	public JsonReader(Object jsonObj) {
        this.jsonObj = jsonObj;
    }

    public JsonReader getReader(String key) {
    	return new JsonReader(getValue(key));
    }
    
    public Boolean isArray() {
        return (jsonObj instanceof List<Object>);
    }

    public String toPrettyJson() {
		return toJson(true);
    }

    public String toJson() {
		return toJson(false);
    }

    public String toJson(Boolean pretty) {
        if (jsonObj == null) {
	        jsonObj = new Map<String, Object>();
        }
        
        if (pretty) {
			return Json.serializePretty(jsonObj);
        } else {
			return Json.serialize(jsonObj);
        }
    }
	
    public JsonReader with(Integer arrayIndex) {
        return with('[' + arrayIndex + ']');
    }
    
    public JsonReader newWith(Integer arrayIndex) {
        return newWith('[' + arrayIndex + ']');
    }

    public JsonReader newWith(String withPrefix) {
		this.withPrefix = null;
        return with(withPrefix);
    }
    
    public JsonReader with(String withPrefix) {
        if (this.withPrefix != null) {
            this.withPrefix = this.withPrefix + '.' + withPrefix;
        } else {
            this.withPrefix = withPrefix;
        }
        
        return this;
    }
    
    public JsonReader endWith() {
        if (withPrefix != null) {
            if (withPrefix.indexOf('.') < 0) {
                withPrefix = null;
            } else {
                withPrefix = withPrefix.substringBeforeLast('.');
            }
        }
        return this;
    }
    
    public JsonReader clearWith() {
        withPrefix = null;
        return this;
    }
    
    public String getWithKey(String key) {
        if (withPrefix != null) {
            key = withPrefix + '.' + key;
        }
        
        return key;
    }
    
    public Object getObject() {
        return jsonObj;
    }

    public List<Object> getList(String key) {
        if (String.isBlank(key)) {
            return (List<Object>) jsonObj;
        }
        return (List<Object>) getValue(key);
    }

    public List<String> getStringList(String key) {
        List<Object> values = null;
        if (String.isBlank(key)) {
            values = (List<Object>) jsonObj;
        } else {
            values = (List<Object>) getValue(key);
        }
        List<String> stringValues = null;
        if (values != null) {
            stringValues = new List<String>();
            for (Object obj : values) {
                stringValues.add(String.valueOf(obj));
            }
        }
        
        return stringValues;
    }

    public Map<String, Object> getMap(String key) {
        return (Map<String, Object>) getValue(key);
    }

    public JsonReader setString(String key, String value) {
        
        Map<String, Object> jsonSetObj = (Map<String, Object>) getContainingObject(key);
        
        jsonSetObj.put(getFinalSegment(key), value);
        
        return this;
    }

    public String getString(String key, String defaultValue) {
        String value = getString(key);
        if (value == null) {
            value = defaultValue;
        }
        
        return value;
    }

    public String getString(String key) {
        Object value = getValue(key);
        if (value == null) {
            return null;
        }
        
        return String.valueOf(value);
    }

    public Integer getInteger(String key) {
        Object value = getValue(key);
        if (value == null) {
            return null;
        }
        
        return Integer.valueOf(value);
    }

    public DateTime getDateTime(String key) {
        String value = getString(key);
        if (value == null) {
            return null;
        }
        
        return (DateTime)Json.deserialize('"' + value + '"', DateTime.class);
    }

    public Boolean getBoolean(String key) {
        Object value = getValue(key);
        if (value == null) {
            return false;
        }
        
        return Boolean.valueOf(value);
    }

    public Decimal getDecimal(String key) {
        Object value = getValue(key);
        if (value == null) {
            return null;
        }
        
        return Double.valueOf(value);
    }

    public Boolean containsKey(String key) {
        Object parentObj =  getContainingObject(key);
        if (parentObj == null) {
            return false;
        }
        
        String field = getFinalSegment(key);
        if (isArrayField(field)) {
            if (parentObj instanceof List<Object>) {
                List<Object> listObj = (List<Object>) parentObj;
                Integer arrayIndex = Integer.valueOf(field.substringBetween('[', ']'));
                if (arrayIndex < listObj.size()) {
                    return true;
                }
            }
        } else {
            if (parentObj instanceof Map<String, Object>) {
                Map<String, Object> mapObj = (Map<String, Object>) parentObj;
                return mapObj.containsKey(field);
            }
        }
        
        return false;
    }
    
    public Object getValue(String key) {
        Object containingObj = getContainingObject(key);
        if (containingObj == null) {
            return null;
        }
        
        return getSegmentValue(containingObj, getFinalSegment(key));
    }

    public String getFinalSegment(String key) {
        key = getWithKey(key);
        String[] segments = key.split('\\.');
        return segments.get(segments.size() - 1);
    }
    
    /**
     * Returns the object which contains the final field which we will need to return the value for.
     * 
     * For ex., if key is foo.bar.bob.alice, this will return the object the key "foo.bar.bob" points to. Then calling
     * method can look for key "alice" in returned object.
     *
     * For If it is an array, the index is considered part of the value. For ex., if you have foo.bar[1].bob then
     * returned object points to "foo.bar[1]". If key is "foo.bar[1]" then return object points to "foo"
     */
    public Object getContainingObject(String key) {
        key = getWithKey(key);
        
        Object currentObj = jsonObj;
        
        String[] segments = key.split('\\.');

        for (Integer segmentIndex = 0; segmentIndex < (segments.size() - 1); segmentIndex++) {
            if (currentObj == null) {
                return null;
            }

            currentObj = getSegmentValue(currentObj, segments.get(segmentIndex));
        }
        
        return currentObj;
    }

    public Boolean isArrayField(String field) {
        return field.indexOf('[') >= 0;
    }

    public Object getSegmentValue(Object currentObj, String keySegment) {
        if (isArrayField(keySegment)) {
            return getArraySegmentValue(currentObj, keySegment);
        } else {
            if (!(currentObj instanceof Map<String, Object>)) {
                return null;
            }
            return ((Map<String, Object>)currentObj).get(keySegment);
        }
    }

    /**
     * Parses the key segment containing array index, and returns the appropriate value from passed in array object.
     * 
     * If passed in object is not an array, then returns null.
     */
    public Object getArraySegmentValue(Object arrayContainingObj, String arrayKeySegment) {

        String arrayField = arrayKeySegment.substringBefore('[');
        Integer arrayIndex = Integer.valueOf(arrayKeySegment.substringBetween('[', ']'));

        //First we need to find the array object and then we will return the value with required index.
        List<Object> arrayObj = null;

        if (String.isBlank(arrayField)) {
            //This is the case of when we have root array without any field prefix. For ex., 
            //"[]"

            if (!(arrayContainingObj instanceof List<Object>)) {
                //If containing object is not actually an array, then we have a mismatch. So return null.
                return null;
            }
            arrayObj = (List<Object>) arrayContainingObj;

        } else {
            if (!(arrayContainingObj instanceof Map<String, Object>)) {
                return null;
            }
            Object objTemp = ((Map<String, Object>)arrayContainingObj).get(arrayField);
            if (!(objTemp instanceof List<Object>)) {
                return null;
            }

            arrayObj = (List<Object>) objTemp;
        }
        
        if (arrayObj == null) {
            return null;
        }

        if (arrayIndex >= arrayObj.size()) {
            return null;
        }

        return arrayObj.get(arrayIndex);
    }
}