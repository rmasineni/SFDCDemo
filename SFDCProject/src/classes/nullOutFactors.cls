public class nullOutFactors{

public static void nullOutFactors(Lead l){

if(l.Install_Partner__c!=null && l.Install_Partner__c!=System.Label.Sunrun_Inc_Id){
l.Install_Branch__c = null;
l.Install_Branch_Id__c = null;

l.Local_Branch_Constant__c = null;
l.Over_Head_Per_Watt__c = null;
l.Over_Head_Per_Project__c = null;
l.Local_System_Size_Exponent__c = null;
l.System_Size_Exponent__c = null;
l.National_Branch_Constant__c = null;
l.EPC_Adjustment__c = null;
system.debug('Nulling out');
}


}

}