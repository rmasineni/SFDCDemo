@IsTest
public class BaseClassTempTestDoNotDeployToProd {
    private static BaseClass utils = new BaseClass();

    testmethod public static void testGetValue() {
        System.assertEquals(null, utils.getValue(null, 'Id'));
        User user = [
            select id, lastmodifiedby.name from user where id = :UserInfo.getUserId()
        ];
        
        System.assertEquals(user.id, utils.getValue(user, 'Id'));
        System.assertEquals(user.LastModifiedBy.name, utils.getValue(user, 'LastModifiedBy.Name'));
    }   
    
}