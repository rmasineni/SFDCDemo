@isTest(SeeAllData=true)
public class UnitTest_SunRunS3RestConnection {

	public static testmethod void testRestConnection(){
		SunRunS3RestConnection tempObj = new SunRunS3RestConnection(); 
		SunRunS3RestConnection restConnectionObj = new SunRunS3RestConnection(SunRunS3RestConnection.UPLOADED_DOCS_SETTINGS_NAME);
		restConnectionObj.makeRequest('GET', 'P3223DGSADSDGSD-I' , 'TestFile.pdf');
	}

	public static testmethod void testPUTConnection(){
		SunRunS3RestConnection restConnectionObj2 = new SunRunS3RestConnection(SunRunS3RestConnection.UPLOADED_DOCS_SETTINGS_NAME);
		Blob responseBlob; 
		restConnectionObj2.makeRequest('PUT', 'P3223DGSADSDGSD-I',  'TestFile.pdf', responseBlob, new Map<String, String>{'content-type'=>'application/pdf'});
		HTTPResponse response = restConnectionObj2.getResponse();
		try{
			restConnectionObj2.makeRequest('PUT', 'P3223DGSADSDGSD-I',  'TestFile.pdf', responseBlob, new Map<String, String>{'test'=>'application/pdf'});
			response = restConnectionObj2.getResponse();
		}catch(Exception expObj){
			
		}	
	}
	
	public static testmethod void testProxymethods(){
		SunRunS3RestConnection.getProposalNameForMasterDocs('P3223DGSADSDGSD-I');
		SunRunS3RestConnection.make_sunrunProxysig('TestScring-1', 'Secret-1');
		SunRunS3RestConnection.getExpirationTime();
		SunRunS3RestConnection.getEncodedPathForSignature('TestFolder', 'P5325325345-I', 'TestFile.pdf');
		SunRunS3RestConnection.getEncodedPathForSignature('TestFolder', 'P5325325345-I', 'TestFile.pdf');
		SunRunS3RestConnection.getServiceEndPoint('TestFolder', 'P5325325345-I', 'TestFile.pdf');
		SunRunS3RestConnection.getSignedURL('GET', SunRunS3RestConnection.UPLOADED_DOCS_SETTINGS_NAME, 'P5325325345-I', 'TestFile.pdf');
	}

}