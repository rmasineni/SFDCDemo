public class CaseUtil {

	public static Map<String, RecordType> caseRecordTypes = new Map<String, RecordType>();
	public static RecordType getCaseRecordTypeByName(String name){
		RecordType recordTypeObj;
		if(name != null && name != ''){
			if(!caseRecordTypes.containsKey(name)){
				for(RecordType caseRecordTypeObj : [Select Id, name from RecordType where SobjectType = 'Case']){
					caseRecordTypes.put(caseRecordTypeObj.Name, caseRecordTypeObj);
				}
			}
			recordTypeObj = caseRecordTypes.get(name);
		}
		return recordTypeObj;
	}
}