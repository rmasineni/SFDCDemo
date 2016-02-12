public with sharing class sfLead {

    public static LeadDeDupService leadDeDupService {get {
        if (leadDeDupService == null) {
            leadDeDupService =  (LeadDeDupService) createInstance('LeadDeDupServiceImpl');
        }
        return leadDeDupService;
    }private set;}

    @TestVisible
    private static Object createInstance(String clz) {
        Type typ = Type.forName(clz);
        Object instance = null;
        if (typ != null) {
            instance = typ.newInstance();
        }
        
        if (instance == null) {
            throw new BusinessException('Couldn\'t successfully instantiate an object for class ' + clz + '. Please check if Class name is correct, is compilable and current user has access.');
        }
        
        return instance;
    }
   
}