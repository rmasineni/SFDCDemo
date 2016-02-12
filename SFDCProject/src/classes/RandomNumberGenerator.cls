public class RandomNumberGenerator {

        public static Integer Length = 10;
        
        public static String generateRandomNumber() {
            String randomStringWithTime = '';
            String randomNumber = generate();
            while(randomNumber.length() < Length) {
                String randomNumber2 = generate();
                randomNumber = randomNumber + randomNumber2.substring(0, Length - randomNumber.length());
            }
            
            if(randomNumber.length() > Length){
                randomNumber = randomNumber.substring(0,Length);
            }
            randomStringWithTime =  randomNumber;
            return randomStringWithTime;
        }

        public static String generateRandomNumber(Double startNumber, Double endNumber) {
            String randomStringWithTime = '';
            String randomNumber = generate();
            Double randomNumberVal = Double.valueOf(randomNumber);

            do{
                while(randomNumber.length() < Length) {
                    String randomNumber2 = generate();
                    randomNumber = randomNumber + randomNumber2.substring(0, Length - randomNumber.length());
                }
                if(randomNumber.length() > Length){
                    randomNumber = randomNumber.substring(0,Length);
                }
                randomNumberVal = Double.valueOf(randomNumber);
                if(randomNumberVal > endNumber){
                    randomNumber = generate();
                }
            }while(randomNumberVal < startNumber || randomNumberVal > endNumber);
            
            randomStringWithTime =  randomNumber;
            randomNumberVal = Double.valueOf(randomNumber);
            return randomStringWithTime;
        }

        public static String generateRandomNumber(Integer aliasLength) {
            String randomStringWithTime = '';
            String randomNumber = generate();
            while(randomNumber.length() < aliasLength) {
                String randomNumber2 = generate();
                if(randomNumber2.length() < aliasLength){
                    randomNumber = randomNumber + '-' + randomNumber2;
                }else{
                    randomNumber = randomNumber + '-' + randomNumber2.substring(0, aliasLength - randomNumber.length());
                }
            }
            
            if(randomNumber.length() > aliasLength){
                randomNumber = randomNumber.substring(0,aliasLength);
            }
            return randomNumber;
        }
        
        private static String generate() {
            return String.valueOf(Math.abs(Crypto.getRandomInteger()));
        }
        
        public static List<String> getUniqueServiceContractNumbers(Integer size){
            List<String> generatedSCNumbers = new List<String>();
            List<ServiceContract> scList = new List<ServiceContract>(); 
            Double startNumber = 1000000000;
            Double endNumber =  2147483647;     
            do{
                for(Integer counter = 0; counter < size;  counter++){
                    generatedSCNumbers.add(RandomNumberGenerator.generateRandomNumber(startNumber, endNumber));
                }
                if(!Test.isRunningTest()){
                	scList = [Select Name, Id from ServiceContract where Name in :generatedSCNumbers];
                }
                
            }while(scList != null && !scList.isEmpty());
            return generatedSCNumbers;      
        }

         public static List<String> getUniqueDelId(Integer size){
            List<String> generatedDealIds = new List<String>();
            List<ServiceContract> scList = new List<ServiceContract>();     
            do{
                for(Integer counter = 0; counter < size;  counter++){
                    String randomNumberStr = RandomNumberGenerator.generateRandomNumber().subString(0,8);
                    System.debug('randomNumberStr: ' + randomNumberStr);
                    String formattedNumber = '1000-' + randomNumberStr.subString(0,2) + '-' + randomNumberStr.subString(2,4) + '-' + randomNumberStr.subString(4,8);
                    generatedDealIds.add(formattedNumber);
                }
                if(!Test.isRunningTest()){
                    scList = [Select Name, Deal_ID__c from ServiceContract where Deal_ID__c in :generatedDealIds];
                }
                
            }while(scList != null && !scList.isEmpty());
            return generatedDealIds;      
        }
        
        @istest
        public static void testGenerateRandomNumber(){
            RandomNumberGenerator.Length = 10;
            RandomNumberGenerator.generateRandomNumber(10);
            RandomNumberGenerator.Length = 10;
            RandomNumberGenerator.generateRandomNumber();
            
            List<String> dealIds = RandomNumberGenerator.getUniqueDelId(2);
            List<String> uniqueSCNumbers = RandomNumberGenerator.getUniqueDelId(2);
            ServiceContract scObj = new ServiceContract();
            insert scObj;
        }

}