@isTest
public class BaseclassTest2{  
    private static BaseClass utils = new BaseClass();  
    static testmethod void BaseclassTest2(){
    utils.getErrorLog();
    utils.getStringMap(new List<String>{'1'});
    Lead l=new lead(lastname='aaaadfd',company='sfsf');
    insert l;
    utils.getIdMap(new List<Sobject>{l});
    utils.getIdMap(new List<Sobject>{l},'id');
    utils.getStringMap(new List<Sobject>{l},'lastname');
    utils.getStringMap(new List<Sobject>{l},'lastname','uppercase',true);
    utils.getStringMap(new List<Sobject>{l},'lastname','lowercase',true);
    utils.getUniqueIdList(new List<Sobject>{l},'id');
    utils.getUniqueStringList(new List<Sobject>{l},'lastname');
    utils.getStringList(new List<Sobject>{l},'lastname',true);
    utils.addInfoMessage('err');
    utils.addErrorMessage('err');
    utils.getErrorMessages();
    utils.getHasErrorMessages();
    utils.getHasErrorMessagesContains('');
    utils.getParameter('','');
    utils.firstNonNull(l,l);
    utils.getStackTrace();
    utils.formatAmount(1.2);
    utils.getCurrentDateTime();
    utils.getCurrentDate();
    utils.getCurrentUtcIsoDateTime();
    //utils.parseAsUtcIsoDateTime(''+system.now());
    utils.getDateTimeFormattedForId();
    utils.getDateTimeFormattedForId(system.now());
    utils.parseIsoDate('');
    utils.getRandomString();
    utils.getRandomLongString();
    utils.getRandomString(1);
    utils.join(new List<String>{'122-11'},'-');
    utils.joinWithNulls(new List<String>{'122-11'},'-');
    utils.joinIfNotEmpty('','','','');
    utils.joinIfNotEmpty('','','');
    utils.isAllBlank('','');
    utils.isNullorZero(1.2);
    utils.equalsIc('','','');
    utils.equalsIcAny('',new list<String>{''});
    utils.joinMap(new Map<String,String>{});
    }
    }