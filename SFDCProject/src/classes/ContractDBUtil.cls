public class ContractDBUtil {
   
    public static void updateContractDBInfo(set<String> agreementNos) {
       If(!agreementNos.isEmpty()){
             ContractDBService.processContractDB(agreementNos);
        }
        
    }
}