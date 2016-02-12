public interface SettingsService {
    void setString(String key, String value);
    String getString(String key);
    String getString(String key, String defaultValue);

    void setInteger(String key, Integer value);
    Integer getInteger(String key);
    Integer getInteger(String key, Integer defaultValue);

    void setDouble(String key, Double value);
    Double getDouble(String key);
    Double getDouble(String key, Double defaultValue);

    void setBoolean(String key, Boolean value);
    Boolean getBoolean(String key);
    Boolean getBoolean(String key, Boolean defaultValue);
    
    void setDate(String key, Date value);
    Date getDate(String key);
    Date getDate(String key, Date defaultValue);

    void setDateTime(String key, DateTime value);
    DateTime getDateTime(String key);
    DateTime getDateTime(String key, DateTime defaultValue);

    List<String> getStringList(String key);
    List<String> getStringList(String key, List<String> defaultValue);

    Map<String, String> getStringMap(String key);
    Map<String, String> getStringMap(String key, Map<String, String> defaultValue);
    
    String getStringMapEntry(String settingsKey, String mapKey);
    String getStringMapEntry(String settingsKey, String mapKey, String defaultValue);

    /**
     * Clears out all environment specific settings values. It doesn't delete the keys but just 
     * sets the values to empty. This method needs to be called after post-production-refresh of a 
     * sandbox to make sure no sensitive production environment variables are not maintained in any
     * of the sandboxes.
     */
    void clearEnvironmentSpecificSettings();
}