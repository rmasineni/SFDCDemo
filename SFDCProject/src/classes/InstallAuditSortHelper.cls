public class InstallAuditSortHelper {     // <ID, Position>
    private Map<String, Integer> listPosition = null;    // <FieldName, <FieldValues>>
    private Map<String, List<String>> sortedFieldValuesPerFieldName = null;     // <FieldName, <FieldValue, <IDs>>>
    private Map<String, Map<String, List<String>>> sObjectIDsPerFieldNames = null;
    
// Properties
    public List<sObject> originalList {get; set;}
    
// Constructor
    public InstallAuditSortHelper () {
        originalList = null;
    }// Public Method
    public List<sObject> getSortedList(String fieldName, Boolean ascending) {
        if (originalList == null) {
            // Assume that originalList has a not NULL value.
            // If the class who uses this method has not assigned a value it will get an Exception which
            //    needs to be handled by the calling class.            // Force the exception...
            originalList.clear();
        }        // Make field name uppercase
        fieldName = fieldName.toUpperCase();        // Get sorted list
        return makeSortedList(fieldName, ascending);
    }
    public List<sObject> getSortedList(List<sObject> originalList, String fieldName, Boolean ascending) {
        this.originalList = originalList;
        sortedFieldValuesPerFieldName = null;
        return getSortedList(fieldName, ascending);
    }
    
// Private Methods
    private void InitializeFieldName(String fieldName) {
        String sObjectID;
        Integer position;
        String fieldValue;
        List<String> sObjectIDs = null;
        Set<String> valuesForFieldSet = null;    // Sets automatically omit duplicate values 
        List<String> valuesForFieldList = null;
        Map<String, List<String>> sObjectIDsPerFieldValues = null;
        
        // Make sortedFieldValuesPerFieldName
        if (sortedFieldValuesPerFieldName == null) {
            listPosition = new Map<String, Integer>();
            sortedFieldValuesPerFieldName = new Map<String, List<String>>();
            sObjectIDsPerFieldNames = new Map<String, Map<String, List<String>>>();
        }
        
        // Get (or create) map of sObjectIDsPerFieldValues
        sObjectIDsPerFieldValues = sObjectIDsPerFieldNames.get(fieldName);
        if (sObjectIDsPerFieldValues == null) {
            sObjectIDsPerFieldValues = new Map<String, List<String>>();
            sObjectIDsPerFieldNames.put(fieldName, sObjectIDsPerFieldValues);
        }
        if (!sortedFieldValuesPerFieldName.keySet().contains(fieldName)) {
            // Objects need to be initialized
            position = 0;
            valuesForFieldSet = new Set<String>();
            listPosition = new Map<String, Integer>();
            
            for (sObject sObj : originalList) {
                sObjectID = sObj.ID;
                fieldValue = getValue(sObj, fieldName);
                
                // Add position to list
                listPosition.put(sObjectID, position++);
                
                // Add the value to the set (sets rather than lists to prevent duplicates)
                valuesForFieldSet.add(fieldValue);
                
                // Get (or create) map of sObjectIDs
                sObjectIDs = sObjectIDsPerFieldValues.get(fieldValue);
                if (sObjectIDs == null) {
                    sObjectIDs = new List<String>();
                    sObjectIDsPerFieldValues.put(fieldValue, sObjectIDs);
                }
                
                // Add ID to sObjectIDs
                sObjectIDs.add(sObjectID);
            }
            
            // Sort set items (Need to convert to list)
            valuesForFieldList = new List<String>();
            valuesForFieldList.addAll(valuesForFieldSet);
            valuesForFieldList.sort();
            
            // Now add it to the map.
            sortedFieldValuesPerFieldName.put(fieldName, valuesForFieldList);
        }
    }
    private List<sObject> makeSortedList(String fieldName, Boolean ascending) {
        Integer position;
        List<String> sObjectIDs = null;
        List<String> valuesForFieldList = null;        // Initialize objects
        InitializeFieldName(fieldName);        // Get a list of the same type as the "originalList"
        List<sObject> outputList = originalList.clone();
        outputList.clear();        // Get a list of sorted values
        valuesForFieldList = sortedFieldValuesPerFieldName.get(fieldName);
        
        // for each sorted value
        for (String fieldValue : valuesForFieldList) {
            // Get lisft of IDs
            sObjectIDs = sObjectIDsPerFieldNames.get(fieldName).get(fieldValue);
            
            // for each ID
            for (String ID : sObjectIDs) {
                // Get position in originalList
                position = listPosition.get(ID);                // Add each sObject to the list.
                if ((ascending) || (outputList.size()==0)) {
                    outputList.add(originalList[position]);
                } else {
                    outputList.add(0, originalList[position]);
                }
            }
        }
        return outputList;
    }
    private static String getValue(sObject sObj, String fieldName) {
        // This returns the sObject desired in case the fieldName refers to a linked object.
        Integer pieceCount;
        String[] fieldNamePieces;
        
        fieldNamePieces = fieldName.split('\\.');
        pieceCount = fieldNamePieces.size();
        for (Integer i = 0; i < (pieceCount-1); i++) {
            sObj = sObj.getSObject(fieldNamePieces[i]);
        }
        if(sObj == null)
            return '';
        return String.valueOf(sObj.get(fieldNamePieces[pieceCount-1]));
    }
    

}