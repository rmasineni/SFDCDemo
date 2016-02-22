public with sharing class PartnerUserShare {
	@future
	public static void doPartnerSharing(Set<String> userSet,Boolean fromTrigger){
		Map<id,id> userAccMap=new map<id,id>();
        List<user> userList=[select id,contact.accountid from user where id in:userSet];
        for(User userObj:userList){
        	userAccMap.put(userObj.id,userObj.contact.accountid);
        }
        Map<id,Set<user>> accUserMap=new Map<id,Set<user>>();
        for(user userObj:[select id,contact.accountid from user where contact.accountid in:userAccMap.values()]){
        	if(accUserMap.containskey(userObj.contact.accountid)){
        		accUserMap.get(userObj.contact.accountid).add(userObj);
        	}
        	else{
        		accUserMap.put(userObj.contact.accountid,new set<user>{userObj});
        	}
        }
        List<UserShare> usersharelist=new List<UserShare>();
        for(user userObj:userList){
        	for(user userO:accUserMap.get(userObj.contact.accountid)){
        		if(userObj.id!=userO.id){
        		UserShare ushare=new UserShare();
        		ushare.userid=userO.id;
        		ushare.UserOrGroupId = userObj.id;
        		ushare.UserAccessLevel='Edit';  
        		usersharelist.add(ushare); 
        		if(fromTrigger){
        		UserShare ushareT=new UserShare();
        		ushareT.userid=userObj.id;
        		ushareT.UserOrGroupId = userO.id;
        		ushareT.UserAccessLevel='Edit';
        		usersharelist.add(ushareT); 	
        		}    
        		} 		
        	}
        }
        system.debug('--->usersharelist'+usersharelist);
        if(!usersharelist.isempty()){
    	try {
         
            Database.SaveResult[] results = Database.insert(usersharelist,false);
            if (results != null){
                for (Database.SaveResult result : results) {
                    if (!result.isSuccess()) {
                        Database.Error[] errs = result.getErrors();
                        for(Database.Error err : errs)
                            System.debug(err.getStatusCode() + ' - ' + err.getMessage());
         
                    }
                }
            }
         
            } 
          catch (Exception e) {
            System.debug(e.getTypeName() + ' - ' + e.getCause() + ': ' + e.getMessage());
          } 
    	}
	}
}