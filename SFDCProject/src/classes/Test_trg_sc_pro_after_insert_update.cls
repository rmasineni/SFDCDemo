@isTest(SeeAllData=true)
public class Test_trg_sc_pro_after_insert_update {
    
    public static TestMethod void testMileStone(){
     Test.startTest();
      List<ServiceContract> ScList = new  List<ServiceContract>();
  	  for (ServiceContract sc :[select Id,Install_Partner_Id__c, M1_Terms__c, M2_Terms__c,M3_Terms__c,Customer_Signoff__c 
                                from ServiceContract where Service_Contract_Event__c!=null and Marked_For_Deletion__c != 'Yes' 
                                and Canceling_Party__c != null limit 4 ])
      {
		 sc.Install_Partner_Id__c='00160000016H1EqAAK';      
          ScList.add(sc);
      }
      update ScList;
      Map<id, ServiceContract> mapSer =  new  Map<id, ServiceContract>();
        for(ServiceContract sc: ScList) {
            mapSer.put(sc.id, sc);
        }
      
      ServiceContractMilestoneProof.updateMileStoneDetails(ScList, mapSer, mapser);
         Test.stopTest();
     }

}