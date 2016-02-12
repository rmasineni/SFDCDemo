@isTest
private class CoreLogicCalloutTest {
   @isTest static void coreLogicTest1(){
            SingleRequestMock fakeResponse = new SingleRequestMock(200,
                                                                   'Ok',
                                                                   '{ "authKey": "e7FAzFVMgDB7qAIhpQ2m1hLSI8l9gItvSjwqquWkNjhLZmzZLH" }',
                                                                   null);
            SingleRequestMock fakeResponse1 = new SingleRequestMock(200,
                                                                    'Ok',
                                                                    '{ "pageInfo": { "actualPageSize": 1, "length": 1, "maxPageSize": 50, "page": 1, "pageSize": 4 }, "parcels": [ { "STATE_CODE": "48", "CNTY_CODE": "453", "APN": "548319", "APN2": "0258080103", "ADDR": "11902 BURNET RD", "CITY": "AUSTIN", "STATE": "TX", "ZIP": "78758", "STD_ADDR": "11902 BURNET RD", "STD_CITY": "AUSTIN", "STD_STATE": "TX", "STD_ZIP": "78758", "STD_PLUS": "2972", "GEOM": "POLYGON ((-97.715786491 30.4065235620001, -97.7165355989999 30.4068866170001, -97.71678793 30.4064954570001, -97.71682536 30.4065335490001, -97.716856884 30.406575466, -97.7168819889999 30.406620522, -97.71690141 30.4066619540001, -97.7169158739999 30.406689667, -97.716932772 30.40671632, -97.7169520039999 30.4067417570001, -97.716973461 30.4067658280001, -97.7176225809999 30.405759527, -97.7168902349999 30.4054046110001, -97.7164489529999 30.4060840880001, -97.716310637 30.4061380630001, -97.715854523 30.4059170370001, -97.715829489 30.4060371740001, -97.715810141 30.4061580970001, -97.715796511 30.4062796050001, -97.715788623 30.4064014950001, -97.715786491 30.4065235620001))", "FIPS_CODE": "48453", "UNFRM_APN": "548319", "APN_SEQ_NO": 1, "FRM_APN": "548319", "ORIG_APN": "548319", "MAP_REF1": "150-B4", "MAP_REF2": "2N", "CENSUS_TR": "0018491007", "LOT_NBR": "2", "LAND_USE": "244", "PROP_IND": "27", "SUB_NAME": "NORTH LOOP BUS PARK SEC 01-A", "OWN_CP_IND": "Y", "OWN1_LAST": "CH REALTY VI/O AUSTIN STONECRE", "MAIL_NBR": "3819", "MAIL_STR": "MAPLE", "MAIL_MODE": "AVE", "MAIL_CITY": "DALLAS", "MAIL_STATE": "TX", "MAIL_ZIP": "752193913", "MAIL_CC": "C041", "TOT_VAL": 11290040, "LAN_VAL": 1572950, "IMP_VAL": 9717090, "TOT_VAL_CD": "M", "LAN_VAL_CD": "M", "ASSD_VAL": 11290040, "ASSD_LAN": 1572950, "ASSD_IMP": 9717090, "MKT_VAL": 11290040, "MKT_LAN": 1572950, "MKT_IMP": 9717090, "APPR_VAL": 11290040, "APPR_LAN": 1572950, "APPR_IMP": 9717090, "TAX_AMT": 268680.37, "TAX_YR": 2014, "ASSD_YR": 2014, "TAX_AREA": "0A", "DOC_NBR": "126750", "LAND_ACRES": 3.611, "LAND_SQ_FT": 157295, "LOT_AREA": "LAND", "UBLD_SQ_FT": 77450, "BLD_SQ_IND": "B", "BLD_SQ_FT": 77450, "LIV_SQ_FT": 77450, "GF_SQ_FT": 18725, "GR_SQ_FT": 77450, "YR_BLT": 1984, "BLD_CODE": "C60", "CONSTR_TYP": "001", "FOUNDATION": "SLB", "ROOF_COVER": "003", "ROOF_TYP": "F00", "STORY_CD": "040", "STORY_NBR": 4, "BLD_UNITS": 1, "UNITS_NBR": 5, "LEGAL1": "LOT 2 NORTH LOOP BUSINESS PARK SEC 1-A " } ] }',
                                                                    null);
            Test.setMock(HttpCalloutMock.class, fakeResponse);
            Test.setMock(HttpCalloutMock.class, fakeResponse1);
            CoreLogicSecondResponse csr = new CoreLogicSecondResponse();
            List <Account> acclist = new list<Account>();
            Account a = new Account (Name ='Test', Latitude__c= 30.406001, Longitude__c =97.716578);
            //insert a;
            acclist.add(a);
            insert acclist;
            Test.startTest();
            CoreLogicFromJsonResponse cfr = CoreLogicCallouts.authKeyMethod();
            csr = CoreLogicCallouts.corelogicSecondCallout('30.406001', '97.716578', 'e7FAzFVMgDB7qAIhpQ2m1hLSI8l9gItvSjwqquWkNjhLZmzZLH');
            
            CoreLogicCallouts.enrichAccounts(acclist);
            
            Test.stopTest();
            
            
        }
        @isTest static void coreLogictest2(){
            SingleRequestMock fakeResponse = new SingleRequestMock(200,
                                                                   'Ok',
                                                                   '{ "authKey": "e7FAzFVMgDB7qAIhpQ2m1hLSI8l9gItvSjwqquWkNjhLZmzZLH" }',
                                                                   null);
            SingleRequestMock fakeResponse1 = new SingleRequestMock(400,
                                                                    'error',
                                                                    '{ "errors": [ { "code": 10030, "message": "Parameter lat is missing, empty or invalid", "documentationUrl": "http://sws.corelogic.com/v3.0.0/reference/api.error.messages#10030" }, { "code": 10040, "message": "Parameter lon is missing, empty or invalid", "documentationUrl": "http://sws.corelogic.com/v3.0.0/reference/api.error.messages#10040" } ] }',
                                                                    null);
            Test.setMock(HttpCalloutMock.class, fakeResponse);
            Test.setMock(HttpCalloutMock.class, fakeResponse1);
            CoreLogicSecondResponse csr = new CoreLogicSecondResponse();
            new CoreLogicSecondResponse.cls_pageInfo();
            new CoreLogicSecondResponse.cls_parcels();
            List <Account> acclist = new list<Account>();
            Account a = new Account (Name ='Test', Latitude__c=null  , Longitude__c = null);
            //insert a;
            acclist.add(a);
            insert acclist;
            Test.startTest();
            CoreLogicFromJsonResponse cfr = CoreLogicCallouts.authKeyMethod();
            csr = CoreLogicCallouts.corelogicSecondCallout(null, null, 'e7FAzFVMgDB7qAIhpQ2m1hLSI8l9gItvSjwqquWkNjhLZmzZLH');
            
            CoreLogicCallouts.enrichAccounts(acclist);
            
            Test.stopTest();
        }
        @isTest static void testmethod3(){
            SingleRequestMock fakeResponse = new SingleRequestMock(400,
                                                                   'Error',
                                                                   ' { "errors": [ { "code": 10220, "message": "Username and password cannot be null, empty, or blank", "documentationUrl": "http://sws.corelogic.com/v3.0.0/reference/api.error.messages#10220" } ] }',
                                                                   null);
            SingleRequestMock fakeResponse1 = new SingleRequestMock(400,
                                                                    'error',
                                                                    '{ "errors": [ { "code": 10030, "message": "Parameter lat is missing, empty or invalid", "documentationUrl": "http://sws.corelogic.com/v3.0.0/reference/api.error.messages#10030" }, { "code": 10040, "message": "Parameter lon is missing, empty or invalid", "documentationUrl": "http://sws.corelogic.com/v3.0.0/reference/api.error.messages#10040" } ] }',
                                                                    null);
            Test.setMock(HttpCalloutMock.class, fakeResponse);
            Test.setMock(HttpCalloutMock.class, fakeResponse1);
            CoreLogicSecondResponse.cls_parcels csr = new CoreLogicSecondResponse.cls_parcels();
            csr.OWN1_FRST = 'TEST';
            CoreLogicErrorfromJSON ce = new CoreLogicErrorfromJSON();
            
            
            new CoreLogicSecondResponse.cls_parcels();
            new CoreLogicErrorfromJSON.cls_errors();
            List <Account> acclist = new list<Account>();
            Account a = new Account (Name ='Test', Latitude__c=null  , Longitude__c = null);
            //insert a;
            acclist.add(a);
            insert acclist;
            Sunrun_Error_Message__c sr = new Sunrun_Error_Message__c();
            sr.Error_Code__c = '400';
            sr.Error_Description__c = 'error';
            sr.Error_Message__c = 'this is not valid';
            Insert sr;  
            // Test.startTest();
            Try{
                CoreLogicFromJsonResponse cfr = CoreLogicCallouts.authKeyMethod();
            }
            catch(Exception e){
                
            }
        }
        
}