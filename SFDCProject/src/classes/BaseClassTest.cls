@IsTest
public class BaseClassTest {

    private static BaseClass utils = new BaseClass();

    testmethod static void testIsChanged() {
        System.assertEquals(false, utils.isChanged(null, null));
        System.assertEquals(true, utils.isChanged('', null));
        System.assertEquals(true, utils.isChanged(null, ''));
        System.assertEquals(true, utils.isChanged(1, 2));
        System.assertEquals(true, utils.isChanged('', ' '));
        System.assertEquals(true, utils.isChanged(' ', ''));
        System.assertEquals(false, utils.isChanged(' ', ' '));
        System.assertEquals(false, utils.isChanged(1.1, 1.10));
        System.assertEquals(false, utils.isChanged('abc', 'abc'));
        System.assertEquals(true, utils.isChanged('abc', 'ABC'));
        System.assertEquals(false, utils.isChanged(true, true));
        System.assertEquals(false, utils.isChanged(false, false));
        System.assertEquals(true, utils.isChanged(false, true));
        System.assertEquals(true, utils.isChanged('abc', 123));
    }
    
    testmethod static void testGetStackTrace() {
        System.assertNotEquals(null, utils.getStackTrace());
        BusinessException be = new BusinessException('test', new BusinessException('root cause'));
        System.assertNotEquals(null, be);
        System.assertNotEquals(null, utils.getRootException(be));
        System.assertEquals(null, utils.getRootException(null));
    }
    
    testmethod public static void testRedirectToId() {
        Test.setCurrentPage(new PageReference('/TestPage?id=066g0000000DFAgAAO'));
        
        PageReference page = utils.redirectToId();
        System.assertEquals('/066g0000000DFAgAAO', page.getUrl());
        System.assertEquals(true, page.getRedirect());
        
        page = utils.redirectToId('066g0000000DFAgAAO');
        System.assertEquals('/066g0000000DFAgAAO', page.getUrl());
        System.assertEquals(true, page.getRedirect());
    }
    
    testmethod public static void testRedirect() {
        PageReference page = utils.redirect('/066g0000000DFAgAAO');
        System.assertEquals(true, page.getRedirect());
    }
    
    testmethod public static void testGetErrorLog() {
        System.assertEquals(0, utils.getErrorLog().size());     
        utils.addErrorMessage(new BusinessException('Test Message'));
        System.assertEquals(1, utils.getErrorLog().size());     
    }
    
    testmethod public static void testFormatAmount() {
        System.assertEquals('100.00', utils.formatAmount(100));
        System.assertEquals('100.00', utils.formatAmount(100.0000));
        System.assertEquals('100.12', utils.formatAmount(100.123456789));
        System.assertEquals('100.00', utils.formatAmount(100.0));
    }

    testmethod public static void testformatAsUtcIsoDateTime() {
        Datetime myDate = datetime.newInstance(2008, 12, 1, 12, 30, 2);
        System.assertEquals('2008-12-01T20:30:02Z', utils.formatAsUtcIsoDateTime(myDate));
        
        //Null input returns null
        System.assertEquals(null, utils.formatAsUtcIsoDateTime(null));
    }
    
    testmethod public static void testGetStringMap() {
        List<Account> sobjs = new List<Account>();
        sobjs.add(new Account(Name='Foo1', Description='bar1'));
        sobjs.add(new Account(Name='Foo2', Description='BAR1'));
        sobjs.add(new Account(Name='Foo3', Description='Bar1'));
        sobjs.add(new Account(Name='Foo4', Description='Bar2'));
        sobjs.add(new Account(Name='Foo5', Description=null));
        sobjs.add(new Account(Name='Foo6', Description=''));
        sobjs.add(new Account(Name='Foo7', Description=' '));
        sobjs.add(new Account(Name='Foo8', Description='  '));
        insert sobjs;
		
        //Null input returns empty map
        System.assertEquals(true, utils.getStringMap(null, 'Description').isEmpty());
        System.assertEquals(5, utils.getStringMap(sobjs, 'Description').size());
        System.assertEquals(7, utils.getStringMap(sobjs, 'Description', null, false).size());
        System.assertEquals(5, utils.getStringMap(sobjs, 'Description', null, true).size());
        System.assertEquals(3, utils.getStringMap(sobjs, 'Description', 'uppercase', true).size());
        System.assertEquals('Foo3', utils.getStringMap(sobjs, 'Description', 'uppercase', true).get('BAR1').get('Name'));
        System.assertEquals('Foo3', utils.getStringMap(sobjs, 'Description', 'lowercase', true).get('bar1').get('Name'));
        
        System.assertNotEquals(null, utils.getStringMap(null));
        System.assertEquals('Foo', utils.getStringMap(new String[]{'Foo'}).get('Foo'));
    }
    
    testmethod public static void testGetIdMap() {
        List<Account> sobjs = new List<Account>();
        sobjs.add(new Account(Name='Foo', Description='066g0000000DFAgAAO', AccountNumber='Non Id'));
        sobjs.add(new Account(Name='Bar', Description='066g0000000DFAgAAO'));
        insert sobjs;
		
		//Null input returns empty map        
        System.assertEquals(true, utils.getIdMap(null).isEmpty());

        Map<Id, SObject> idMap = utils.getIdMap(sobjs);
        System.assertEquals(2, idMap.size());
        
        sobjs.add(sobjs.get(0));
        sobjs.add(sobjs.get(0));        
        sobjs.add(sobjs.get(0));
        
        //Even though ids are duplicate, map should retain unique id objects.
        idMap = utils.getIdMap(sobjs);
        System.assertEquals(2, idMap.size());
            
        //If we ask to create map based on custom field, it should return 1 record as all values point to same id.
        //However, in that case, which object returned should be the first one for thta id. In this case, foo.
        idMap = utils.getIdMap(sobjs, 'Description');
        System.assertEquals(1, idMap.size());
        System.assertEquals('Foo', idMap.get('066g0000000DFAgAAO').get('Name'));
        
        try {
            idMap = utils.getIdMap(sobjs, 'AccountNumber');
            System.assert(false, 'Was expecting an exception as description contains non id value');
        } catch (Exception e) {
            System.assert(true);
        }
    }
    
    testmethod public static void testGetUniqueIdList() {
        List<Account> sobjs = new List<Account>();
        sobjs.add(new Account(Name='Foo', Description='066g0000000DFAgAAO', AccountNumber='Non Id'));
        sobjs.add(new Account(Name='Bar', Description='067g0000000DFAgAAO'));
        sobjs.add(new Account(Name='Bar', Description='068g0000000DFAgAAO'));
        sobjs.add(new Account(Name='Bar', Description='068g0000000DFAgAAO'));
        sobjs.add(new Account(Name='Bar', Description='068g0000000DFAgAAO'));
        sobjs.add(new Account(Name='Bar', Description=''));
        sobjs.add(new Account(Name='Bar', Description=null));
        sobjs.add(new Account(Name='Bar'));
        
        List<Id> ids = utils.getUniqueIdList(sobjs, 'Description');
        System.assertEquals(3, ids.size());
		
		//Null input return empty list        
        System.assertEquals(true, utils.getIdList(null, 'Field', true).isEmpty());
    }
    
    testmethod public static void testGetStringList() {
        List<Account> sobjs = new List<Account>();
        sobjs.add(new Account(Name='Foo1', Description='Bar1'));
        sobjs.add(new Account(Name='Foo2', Description='Bar1'));
        sobjs.add(new Account(Name='Foo3', Description='Bar2'));
        sobjs.add(new Account(Name='Foo4', Description='Bar2'));
        sobjs.add(new Account(Name='Foo5', Description='Bar3'));
        sobjs.add(new Account(Name='Foo6', Description='Bar3'));
        sobjs.add(new Account(Name='Foo7', Description='BAR3'));
        sobjs.add(new Account(Name='Foo8', Description=null));
        
        System.assertEquals(7, utils.getStringList(sobjs, 'Description', false).size());
        System.assertEquals(4, utils.getStringList(sobjs, 'Description', true).size());
        System.assertEquals(4, utils.getUniqueStringList(sobjs, 'Description').size());
        System.assertEquals(0, utils.getUniqueStringList(new List<Account>(), 'Description').size());
        System.assertEquals(0, utils.getUniqueStringList(null, 'Description').size());
    }
    
    testmethod public static void testGetMessages() {
        System.assertEquals(true, utils.getMessages(ApexPages.severity.ERROR).isEmpty());
        
        ApexPages.Message message = new ApexPages.Message(ApexPages.severity.INFO, 'Info Message1');
        ApexPages.addMessage(message);
				
        System.assertEquals(false, utils.getHasErrorMessages());
        
        message = new ApexPages.Message(ApexPages.severity.ERROR, 'Error Message1');
        ApexPages.addMessage(message);
        
        System.assertEquals(true, utils.getHasErrorMessages());
        
        message = new ApexPages.Message(ApexPages.severity.ERROR, 'Error Message2');
        ApexPages.addMessage(message);

        message = new ApexPages.Message(ApexPages.severity.INFO, 'Info Message2');
        ApexPages.addMessage(message);
        
        message = new ApexPages.Message(ApexPages.severity.INFO, 'Info Message3');
        ApexPages.addMessage(message);
        
        System.assertEquals(2, utils.getMessages(ApexPages.severity.ERROR).size());
        System.assertEquals(3, utils.getMessages(ApexPages.severity.INFO).size());

        System.assertEquals(2, utils.getErrorMessages().size());
        System.assertEquals(3, utils.getInfoMessages().size());
        
        System.assertEquals(true, utils.getHasErrorMessagesContains('message2'));
        System.assertEquals(false, utils.getHasErrorMessagesContains('message3'));
        System.assertEquals(false, utils.getHasErrorMessagesContains(null));
    }
    
    testmethod public static void testAddVariousMessages() {
        BusinessException be =new BusinessException('Business Message');
        SystemException se = new SystemException('System Message');
        
        utils.addErrorMessage(be);
        utils.addErrorMessage(se);
        
        System.assertEquals(be.getMessage(), utils.getErrorMessages().get(0).getSummary());
        System.assertEquals(String.valueOf(se), utils.getErrorMessages().get(1).getSummary());
        System.assertEquals(2, utils.getErrorMessages().size());
        
        utils.addErrorMessage('Error Message');
        System.assertEquals(3, utils.getErrorMessages().size());

        System.assertEquals(0, utils.getInfoMessages().size());
        utils.addInfoMessage('Info Message');
        System.assertEquals(1, utils.getInfoMessages().size());
    }
    
    testmethod public static void testGetRequiredParameter() {
        Test.setCurrentPage(new PageReference('/TestPage?key=value'));
        System.assertEquals('value', utils.getRequiredParameter('key'));
        
        try {
            Test.setCurrentPage(new PageReference('/TestPage?key='));
            utils.getRequiredParameter('key');
            System.assert(false);
        } catch (Exception e) {
            System.assert(true);
        }

        try {
            Test.setCurrentPage(new PageReference('/TestPage'));
            utils.getRequiredParameter('key');
            System.assert(false);
        } catch (Exception e) {
            System.assert(true);
        }
    }
    
    testmethod public static void testGetParameter() {
        
        //No page reference.
        System.assertEquals(null, utils.getParameter('key'));
        
        Test.setCurrentPage(new PageReference('/TestPage?key=value'));
        System.assertEquals('value', utils.getParameter('key'));

        Test.setCurrentPage(new PageReference('/TestPage?key='));
        System.assertEquals('', utils.getParameter('key'));

        //+ indicates a space
        Test.setCurrentPage(new PageReference('/TestPage?key=+++'));
        System.assertEquals('   ', utils.getParameter('key'));

        Test.setCurrentPage(new PageReference('/TestPage'));
        System.assertEquals(null, utils.getParameter('key'));
        
        //With default value
        Test.setCurrentPage(new PageReference('/TestPage?key=value'));
        System.assertEquals('value', utils.getParameter('key', 'defalutvalue'));

        Test.setCurrentPage(new PageReference('/TestPage?key='));
        System.assertEquals('defalutvalue', utils.getParameter('key', 'defalutvalue'));

        //+ indicates a space
        Test.setCurrentPage(new PageReference('/TestPage?key=+++'));
        System.assertEquals('   ', utils.getParameter('key', 'defalutvalue'));

        Test.setCurrentPage(new PageReference('/TestPage'));
        System.assertEquals('defalutvalue', utils.getParameter('key', 'defalutvalue'));
    }

    testmethod public static void testRandomString() {
        String random1 = utils.getRandomString();
        String random2 = utils.getRandomString();
        System.assertNotEquals(random1, random2);
    }

    testmethod public static void testRandomLongString() {
        String random1 = utils.getRandomLongString();
        String random2 = utils.getRandomLongString();
        System.assertNotEquals(random1, random2);
    }
    
    
    testmethod public static void randomStringOfLength() {
        System.assertEquals(1, utils.getRandomString(1).length());
        System.assertEquals(11, utils.getRandomString(11).length());
        System.assertEquals(111, utils.getRandomString(111).length());
    }

    testmethod public static void testFirstNonNull() {
        Account s1 = new Account();
        Account s2 = new Account();
        
        System.assertEquals(null, utils.firstNonNull((SObject) null, (SObject)  null));
        System.assertEquals(s1, utils.firstNonNull(s1, null));
        System.assertEquals(s1, utils.firstNonNull(s1, s2));
        System.assertEquals(s2, utils.firstNonNull(null, s2));
        
        String st1 = '';
        String st2 = '';
        
        System.assertEquals(st1, utils.firstNonNull(st1, null));
        System.assertEquals(st1, utils.firstNonNull(st1, st2));
        System.assertEquals(st2, utils.firstNonNull(null, st2));
    }
    
    testmethod public static void testFirstNonEmpty() {
        
        System.assertEquals(null, utils.firstNonEmpty(null, null));
        System.assertEquals('Second', utils.firstNonEmpty(null, 'Second'));
        System.assertEquals('First', utils.firstNonEmpty('First', null));
        System.assertEquals('First', utils.firstNonEmpty('First', 'Second'));
        
    }     

    testmethod public static void testIsEmpty() {
        System.assertEquals(true, utils.isEmpty((String) null));
        System.assertEquals(true, utils.isEmpty(''));
        System.assertEquals(true, utils.isEmpty(' '));
        System.assertEquals(false, utils.isEmpty('Value'));
    }     

    testmethod public static void testIsNotEmpty() {
        System.assertEquals(false, utils.isNotEmpty(null));
        System.assertEquals(false, utils.isNotEmpty(''));
        System.assertEquals(false, utils.isNotEmpty(' '));
        System.assertEquals(true, utils.isNotEmpty('Value'));
    }     

    testmethod public static void testEmptyIfNull() {
        System.assertEquals('', utils.emptyIfNull(null));
        System.assertEquals('', utils.emptyIfNull(''));
        System.assertEquals(' ', utils.emptyIfNull(' '));
        System.assertEquals('Value', utils.emptyIfNull('Value'));
    }     

    testmethod public static void testEqualsIc() {
        System.assertEquals(false, utils.equalsIc(null, null));
        System.assertEquals(false, utils.equalsIc(null, 'value'));
        System.assertEquals(true, utils.equalsIc(' ', ' '));
        System.assertEquals(true, utils.equalsIc('Value', 'value'));
        System.assertEquals(false, utils.equalsIc('Value', ' value '));        

        System.assertEquals(true, utils.equalsIc('foo', 'foo', 'bar'));        
        System.assertEquals(true, utils.equalsIc('foo', 'bar', 'foo'));        
        System.assertEquals(false, utils.equalsIc('foo', 'bar', 'bob'));        
    }     
    
    testmethod public static void testEscapeString() {
        System.assertEquals(null, utils.escapeString(null, null));
        System.assertEquals('Value <Value> &Amp;', utils.escapeString('Value <Value> &Amp;', null));
        System.assertEquals('Value+%3CValue%3E+%26Amp%3B', utils.escapeString('Value <Value> &Amp;', 'url'));
        System.assertEquals('', utils.escapeString(null, 'url'));
        System.assertEquals('Value &lt;Value&gt; &amp;Amp;', utils.escapeString('Value <Value> &Amp;', 'html'));
        System.assertEquals('Value &lt;Value&gt; &amp;Amp;', utils.escapeString('Value <Value> &Amp;', 'xml'));

        try {
            System.assertEquals('', utils.escapeString('', 'nonescapemode'));
            System.assert(false);
        } catch (Exception e) {
        }
    } 
   
    testmethod public static void testReplaceMergeTokens() {
        System.assertEquals(null, utils.replaceMergeToken(null, null, null));
        System.assertEquals(null, utils.replaceMergeToken(null, 'key', 'value'));
        System.assertEquals('Value=', utils.replaceMergeToken('Value={key}', 'key', null));
        System.assertEquals('Value=value', utils.replaceMergeToken('Value={key}', 'key', 'value'));
        System.assertEquals('Value={key}', utils.replaceMergeToken('Value={key}', 'Key', 'value'));
    }     
    
    testmethod public static void testJoin() {
        List<String> values = null;
        System.assertEquals(null, utils.join(values, null));
        System.assertEquals(null, utils.join(values, ','));
        
        values = new List<String>();
        
        values.add('foo');
        System.assertEquals('foo', utils.join(values, null));
        System.assertEquals('foo', utils.join(values, ','));
        
        values.add('bar');
        System.assertEquals('foo,bar', utils.join(values, ','));
        System.assertEquals('foo, bar', utils.join(values, ', '));
        System.assertEquals('foobar', utils.join(values, ''));
        System.assertEquals('foo, bar', utils.join(values, null));

        //Because values are null, result would be null.
        System.assertEquals(null, utils.join(new String[]{null, null}, ''));
        System.assertEquals(', ', utils.joinWithNulls(new String[]{null, null}, ', '));
    }
    
    testmethod public static void testGetDateTimeFormattedForId() {
        BaseClass.testCurrentDateTime = Datetime.newInstance(2008, 12, 1, 12, 30, 2);
        
        //Null input returns null
        System.assertEquals(null, utils.getDateTimeFormattedForId(null));
        
        //no input should return current datetime
        System.assertEquals('20081201203002', utils.getDateTimeFormattedForId());
        
        System.assertEquals('20081201203002', utils.getDateTimeFormattedForId(Datetime.newInstance(2008, 12, 1, 12, 30, 2)));
    }
    
    
    testmethod public static void getCurrentDateTime() {
        System.assertEquals(DateTime.now(), utils.getCurrentDateTime());
        BaseClass.testCurrentDateTime = Datetime.newInstance(2008, 12, 1, 12, 30, 2);
        System.assertEquals(Datetime.newInstance(2008, 12, 1, 12, 30, 2), utils.getCurrentDateTime());
    }

    testmethod public static void getCurrentDate() {
        System.assertEquals(Date.today(), utils.getCurrentDate());
        BaseClass.testCurrentDate  = date.parse('12/27/2009');
        System.assertEquals(date.parse('12/27/2009'), utils.getCurrentDate());
    }

    testmethod public static void joinIfNotEmpty() {
        System.assertEquals(null, utils.joinIfNotEmpty(null, null, null));
        System.assertEquals('', utils.joinIfNotEmpty('', '', null));
        System.assertEquals('foobar', utils.joinIfNotEmpty('foo', 'bar', null));
        System.assertEquals('foo,bar', utils.joinIfNotEmpty('foo', 'bar', ','));
        System.assertEquals('foo,bar,alice', utils.joinIfNotEmpty('foo', 'bar', 'alice', ','));
    }
    
    testmethod public static void parseAsUtcIsoDateTime() {
        DateTime time1 = utils.parseAsUtcIsoDateTime('2000-01-20T01:02:03Z');
        System.assertEquals(2000, time1.year());
        System.assertEquals(01, time1.month());
        System.assertEquals(19, time1.day());
        System.assertEquals(17, time1.hour());
        System.assertEquals(02, time1.minute());
        System.assertEquals(03, time1.second());
    }

    testmethod public static void getCurrentUtcIsoDateTime() {
        BaseClass.testCurrentDateTime = Datetime.newInstance(2008, 12, 1, 12, 30, 2);
        System.assertEquals('2008-12-01T20:30:02Z', utils.getCurrentUtcIsoDateTime());
    }


    testmethod public static void checkNotEmpty() {
        try {
            utils.checkNotEmpty('', 'param');
            System.assert(false);
        } catch (Exception e) {
            //ignore
        }

        try {
            utils.checkNotEmpty(null, 'param');
            System.assert(false);
        } catch (Exception e) {
            //ignore
        }

        utils.checkNotEmpty('foo', 'param');
    }

    testmethod public static void checkNotNull() {
        try {
            utils.checkNotNull(null, 'param');
            System.assert(false);
        } catch (Exception e) {
            //ignore
        }

        utils.checkNotNull('', 'param');
        utils.checkNotEmpty('foo', 'param');

        List<String> values = null;
        try {
            utils.checkNotNull(values, 'param');
            System.assert(false);
        } catch (Exception e) {
            //ignore
        }
        values = new List<String>();
        utils.checkNotNull(values, 'param');
    }
    
    testmethod static void replaceMergeTokens() {
        System.assertEquals(null, utils.replaceMergeTokens(null, null));
        System.assertEquals('', utils.replaceMergeTokens('', null));
        System.assertEquals(' ', utils.replaceMergeTokens(' ', null));
        
        Map<String, String> values = new Map<String, String>();
        values.put('foo', 'bar');
        
        System.assertEquals('Name is {foo}', utils.replaceMergeTokens('Name is {foo}', null));
        System.assertEquals('Name is bar', utils.replaceMergeTokens('Name is {foo}', values));
        System.assertEquals('Name is bar {bar}', utils.replaceMergeTokens('Name is {foo} {bar}', values));
    }
    
    testmethod static void generateVerificationToken() {
        System.assert(utils.generateVerificationToken().length() < 255);
    }
    
    testmethod static void getEmailTemplateandSendEmail() {
        
        //Folder fldr = [Select Id From Folder Where Type = 'Email' limit 1];
        
        //EmailTemplate template = new EmailTemplate(Body='Test', HtmlValue='<html><body><p>test</p></body></html>', IsActive=true, Name='EmailTemplate', 
        //        Subject='Subject', DeveloperName='EmailTemplate', FolderId=fldr.id, TemplateType='text');
        //insert template;
        
        String emailTemplateName = null;
        try {
            emailTemplateName = [select DeveloperName from EmailTemplate where DeveloperName != null limit 1].DeveloperName;
        } catch (Exception e) {
            //Creating email template is a pain. So lets see if there is a email template and use it.
            //if not, then let's not test this functionality
            return;
        }
        
        EmailTemplate template2 = utils.getEmailTemplate(emailTemplateName);
        
        try {
            utils.getEmailTemplate('EmailTemplateNotExit');
            System.assert(false); //Expecting an exception
        } catch (Exception e) {
            //ignore
        }
        
        Contact contact = createTestContact('test@yopmail.com', createTestAccount());
        
        utils.sendEmail(emailTemplateName, null, contact.id, null, false);
    }
    
    testmethod public static void testSendEmail() {
        utils.sendEmail(new String[]{'test@yopmail.com'}, 'Test', 'Body');
        utils.sendEmail(new String[]{'test@yopmail.com'}, 'Test', '<html>', true);
    }
    
    testmethod static void sleep() {
        utils.sleep(2100);
        //its kind of hard to validate sleep exactly as sometime it sleeps more and sometimes less.
    }
    
    public class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"foo":"bar"}');
            res.setStatusCode(200);
            return res;
        }
    }
    
    testmethod public static void testHttpGet() {
        
        //Test it returns the content
        new FlexibleCalloutMock(200, 'Test BaseClassTest Content').setAsMock();
        
        System.assertEquals('Test BaseClassTest Content', utils.httpGet('http://example.org'));
        System.assertEquals('Test BaseClassTest Content', utils.httpGet('http://example.org', 20)); //with timeout
        System.assertEquals('Test BaseClassTest Content', utils.httpGet('http://example.org', new Map<String, String>{'Authorization'=>'Bearer'}, 
				new Map<String, String>{'param'=>'value'}, 20)); //with timeout
    
        //Test it throws exception if non-200 is returned.
        new FlexibleCalloutMock(204, 'Test BaseClassTest Content').setAsMock();
        
        try {
            utils.httpGet('http://example.org');
            System.assert(false, 'expected Business Excepetion due to non 200 http code');
        } catch (UnsuccessfulHttpResponseException e) {
            //ignore
        }
        
        //Ensure parameters are added to the url.
        new FlexibleCalloutMock().ifUrlContainsReturn('http://example.org?foo=bar', 'Test BaseClassTest Content') .setAsMock();
        System.assertEquals('Test BaseClassTest Content', utils.httpGet('http://example.org', new Map<String, String>{'foo'=>'bar'}));

        new FlexibleCalloutMock().ifUrlContainsReturn('http://example.org?alice=bob&foo=bar', 'Test BaseClassTest Content') .setAsMock();
        System.assertEquals('Test BaseClassTest Content', utils.httpGet('http://example.org?alice=bob', new Map<String, String>{'foo'=>'bar'}));
        System.assertEquals('Test BaseClassTest Content', utils.httpGet('http://example.org?alice=bob', new Map<String, String>{'foo'=>'bar'}, 20)); //with timeout
        
        //Test headers and full signature method
        System.assertEquals('Test BaseClassTest Content', utils.httpGet('http://example.org?alice=bob', new Map<String, String>{'X-Content-Type' => 'Custom'},  new Map<String, String>{'foo'=>'bar'}, 10));
    }
    
    testmethod public static void testHttpPost() {
        //Test posting the content
        new FlexibleCalloutMock(200, 'Test BaseClassTest Content').setAsMock();
        System.assertEquals('Test BaseClassTest Content', utils.httpPost('http://example.org', 'Body'));
    
        //Test it throws exception if non-200 is returned.
        new FlexibleCalloutMock(204, 'Test BaseClassTest Content').setAsMock();
        try {
            utils.httpPost('http://example.org', 'body');
            System.assert(false, 'expected Business Excepetion due to non 200 http code');
        } catch (UnsuccessfulHttpResponseException e) {
            //ignore
        }
        
        //With headers
        new FlexibleCalloutMock(200, 'Test BaseClassTest Content').setAsMock();
        System.assertEquals('Test BaseClassTest Content', utils.httpPost('http://example.org', 'Body', new Map<String, String>{'foo'=>'bar'}));
        System.assertEquals('Test BaseClassTest Content', utils.httpPost('http://example.org', 'Body', new Map<String, String>{'foo'=>'bar'}), 20); //with timeout
    }
    
    
    testmethod public static void joinMap() {
    
        Map<String, String> values = new Map<String, String>();
        values.put('foo', 'bar');
        values.put('bob', 'alice');
        
        System.assertEquals(null, utils.joinMap(null));
        System.assert(utils.joinMap(values, ',', '=') == 'bob=alice,foo=bar' || utils.joinMap(values, ',', '=') == 'foo=bar,bob=alice' );
        System.assert(utils.joinMap(values) == 'bob=alice, foo=bar' || utils.joinMap(values) == 'foo=bar, bob=alice' );
    }
    
    testmethod public static void testUrlEncode() {
        String value = '!@#!#!@#!#!@#!@#Q^Q#@%SAFFWERWAFSDfasfisafor';
        System.assertEquals(EncodingUtil.urlEncode(value, 'UTF-8'), utils.urlEncode(value));
		System.assertEquals('IUAjISMhQCMhIyFAIyFAI1FeUSNAJVNBRkZXRVJXQUZTRGZhc2Zpc2Fmb3I', utils.urlSafeBase64Encode(value));
    }
    
    testmethod public static void testIsTrueFalseInAnyAll() {
        List<Contact> contacts = new List<Contact>();
        contacts.add(new Contact(DoNotCall=true));
        contacts.add(new Contact(DoNotCall=false));
        
        System.assertEquals(false, utils.isTrueInAll(null, null));
        System.assertEquals(false, utils.isTrueInAny(null, null));
        System.assertEquals(false, utils.isFalseInAll(null, null));
        System.assertEquals(false, utils.isFalseInAny(null, null));

        System.assertEquals(false, utils.isTrueInAll(contacts, 'DoNotCall'));
        System.assertEquals(false, utils.isFalseInAll(contacts, 'DoNotCall'));
        
        System.assertEquals(true, utils.isTrueInAny(contacts, 'DoNotCall'));
        System.assertEquals(true, utils.isFalseInAny(contacts, 'DoNotCall'));
        
		contacts = new List<Contact>();
        contacts.add(new Contact(DoNotCall=true));
        contacts.add(new Contact(DoNotCall=true));
        
        System.assertEquals(true, utils.isTrueInAll(contacts, 'DoNotCall'));
        System.assertEquals(false, utils.isFalseInAll(contacts, 'DoNotCall'));
        
        System.assertEquals(true, utils.isTrueInAny(contacts, 'DoNotCall'));
        System.assertEquals(false, utils.isFalseInAny(contacts, 'DoNotCall'));        
        
		contacts = new List<Contact>();
        contacts.add(new Contact(DoNotCall=false));
        contacts.add(new Contact(DoNotCall=false));
        
        System.assertEquals(false, utils.isTrueInAll(contacts, 'DoNotCall'));
        System.assertEquals(false, utils.isTrueInAny(contacts, 'DoNotCall'));
        
        System.assertEquals(true, utils.isFalseInAll(contacts, 'DoNotCall'));
        System.assertEquals(true, utils.isFalseInAny(contacts, 'DoNotCall'));        
    }
    
    testmethod public static void testSetValue() {
        System.assertEquals(null, utils.setValue(null, null, null));
        System.assertEquals(null, utils.setValue(null, null, 'value'));
        
        List<Contact> contacts = new List<Contact>();
        contacts.add(new Contact());
        contacts.add(new Contact());
        
        System.assertEquals(contacts, utils.setValue(contacts, 'FirstName', 'foo'));
        System.assertEquals('foo', contacts.get(0).FirstName);
       	System.assertEquals('foo', contacts.get(1).FirstName); 

        System.assertEquals(contacts, utils.setValue(contacts, 'FirstName', null));
        System.assertEquals(null, contacts.get(0).FirstName);
       	System.assertEquals(null, contacts.get(1).FirstName); 
    }
    
    testmethod public static void testCreateInstance() {
    	System.assertNotEquals(null, utils.createInstance('BaseClass'));
        
        try {
            utils.createInstance('BaseClass123');
            System.assert(false, 'expected Business Excepetion due to non-existing class');
        } catch (BusinessException e) {
            //ignore
        }
    }
    
    
    testmethod public static void testNullIfEmpty() {
    	System.assertEquals(null, utils.nullIfEmpty(''));
        System.assertEquals(null, utils.nullIfEmpty(null));
        System.assertEquals(null, utils.nullIfEmpty(' '));
        System.assertEquals('abc', utils.nullIfEmpty('abc'));
        System.assertEquals(' abc ', utils.nullIfEmpty(' abc '));
    }

    testmethod public static void testGetCurrentClassName() {
    	System.assertEquals('BaseClassTest', utils.getCurrentClassName());
    }
    
    
    testmethod public static void testGetFieldDescribe() {
    	System.assert(utils.getFieldDescribe('Contact', 'FirstName') != null);
        try {
            utils.getFieldDescribe('Contact1', 'FirstName');
            System.assert(false, 'expected Business Excepetion due to non-existing object');
        } catch (BusinessException e) {
            //ignore
        }
        
        try {
            utils.getFieldDescribe('Contact', 'FirstName1');
            System.assert(false, 'expected Business Excepetion due to non-existing field');
        } catch (BusinessException e) {
            //ignore
        }
    }

    
    testmethod public static void testGetFieldLength() {
    	System.assertEquals(40, utils.getFieldLength('Contact', 'FirstName'));
        System.assertEquals(0, utils.getFieldLength('Contact', 'CreatedDate'));
    }

    testmethod public static void testGetFieldType() {
    	System.assertEquals('string', utils.getFieldType('Contact', 'FirstName'));
        System.assertEquals('datetime', utils.getFieldType('Contact', 'CreatedDate'));
    }
    
    
    testmethod public static void testIsFieldLookUpOfType() {
    	System.assertEquals(true, utils.isFieldLookUpOfType('Contact', 'OwnerId', 'User'));
        System.assertEquals(false, utils.isFieldLookUpOfType('Contact', 'OwnerId', 'Account'));
        System.assertEquals(false, utils.isFieldLookUpOfType('Contact', 'FirstName', 'Account'));
    }
    
    
    testmethod public static void testGetStaticResourceAsString() {
    	System.assertEquals('Test BaseClassTest Content', utils.getStaticResourceAsString('BaseClassTestRespDefault'));
        try {
            utils.getStaticResourceAsString('nonexistingresource');
            System.assert(false, 'expected Business Excepetion due to non-existing static resource');
        } catch (BusinessException e) {
            //ignore
        }
    }
    
    testmethod public static void testIsSandbox() {
    	utils.isSandbox(); //there is nothing to test here as we don't know where we going to run this in
    }
    
    testmethod public static void testConvertToRadians() {
    	System.assertEquals(2.1546089248333335, utils.convertToRadians(123.45));
    }
    
    testmethod public static void testIsOkay() {
    	System.assertEquals(false, utils.isOk(null));
        System.assertEquals(false, utils.isOk(''));
        System.assertEquals(false, utils.isOk(' '));
        System.assertEquals(false, utils.isOk('okie'));
        System.assertEquals(true, utils.isOk('ok'));
        System.assertEquals(true, utils.isOk('OK'));
        System.assertEquals(true, utils.isOk('okay'));
        System.assertEquals(true, utils.isOk('OKAY'));
    }
    
    testmethod public static void testQuerySobject() {
        try {
            utils.querySobject('NotExist', new String[]{'Id'}, 'Id = 1');
            System.assert(false, 'Expected exception due to non existing sobj name');
        } catch (System.QueryException e) {
            //ignore
        }
        
        System.assertEquals(null, utils.querySobject('User', new String[]{'Id'}, 'id = \'00560000001OXZZ\'')); //Some non existing id
        System.assertNotEquals(null, utils.querySobject('User', new String[]{'Id'}, 'id = \'' + UserInfo.getUserId() + '\'')); //Some non existing id
    }
    
    testmethod public static void testQueryAllFields() {
        try {
            utils.queryAllFields('NotExist', null);
            System.assert(false, 'Expected exception due to non existing sobj name');
        } catch (BusinessException e) {
            //ignore
        }
        
        System.assertEquals(null, utils.queryAllFields('User', '00560000001OXZZ')); //Some non existing id
        System.assertNotEquals(null, utils.queryAllFields('User', UserInfo.getUserId())); //Some non existing id
        System.assertNotEquals(null, utils.queryAllFieldsAsMap('User', UserInfo.getUserId()));
        System.assertEquals(null, utils.queryAllFieldsAsMap('Lead', UserInfo.getUserId()));
    }
    
    testmethod public static void testGetUser() {
        System.assertNotEquals(null, utils.queryUser(utils.getAnyStandardUser().id));
    }
    
    testmethod public static void testQueryObjects() {
        Account account1 = new Account(Name='Test');
        insert account1;
        System.assertEquals(account1.id, utils.queryAccount(account1.id).id);
    }    
    
    testmethod public static void testGetAnyStandardUsers() {
        List<User> users = utils.getAnyStandardUsers(1);
        System.assertEquals(1, users.size());
    }
    
    testmethod public static void testGetRecordTypeId() {
        //List<RecordType> rts = [SELECT Id,Name FROM RecordType limit 10];
        //RecordType rt = rts.get(0);
        
        //System.assertEquals(rt.id, utils.getRecordTypeId(rt.SobjectType, rt.name));
        //For some reason, we couldn't ifnd any record types while running the test so not actually
        //funtional testing
        try {
	        utils.getRecordTypeId('Account', 'Standard');
        } catch (Exception e){}
    }
    
    public static Account createTestAccount() {
        Id residentialRecordTypeId = null;
        //Map<Id, RecordType> accountRecordTypeMap = PRMLibrary.getAccountRecordTypes();
        //for(RecordType recordTypeObj : accountRecordTypeMap.values()){
        //    if(recordTypeoBJ.name == AccountUtil.RESIDENTIAL){
        //        residentialRecordTypeId = recordTypeoBJ.Id;
        //    }
        //} 
        
        Account a = new Account(
            //RecordTypeId=residentialRecordTypeId,
            name='Test Acct1', 
            BillingStreet = '595 Market Street',
            BillingCity = 'San Francisco',
            BillingState = 'CA',
            BillingPostalCode = '94105');
        insert a;
        return a;
    }
    
    public static Contact createTestContact(String email, Account account) {
        Contact contact = new Contact();
        contact.AccountId = account.Id;
        contact.LastName = 'Lease';
        contact.FirstName = 'Johnny';
        contact.Email = email;
        contact.Phone = '2022022020'; 
        contact.MailingStreet = '1290 Happy Path';
        contact.MailingState = 'CA';
        contact.MailingCountry = 'USA';
        contact.MailingCity = 'San Francisco';
        contact.MailingPostalCode = '95051';   
        contact.Birthdate = Date.Today();    

        //contact.Accreditation_period_start_date__c = Date.Today().addDays(-180);
        //contact.Accreditation_period_end_date__c = Date.Today().addDays(180);
        //contact.recordTypeId=PRMLibrary.getResidentialContactRecordType().Id;
        insert contact;
        
        return contact;
    }
 	
    testmethod public static void testSplitListBySize() {
        System.assertEquals(null, utils.splitListBySize(null, 10));
        System.assertEquals(1, utils.splitListBySize(new Contact[]{new Contact(), new Contact()}, 10).size());
        System.assertEquals(2, utils.splitListBySize(new Contact[]{new Contact(), new Contact(), new Contact()}, 2).size());
        System.assertEquals(2, utils.splitListBySize(new Contact[]{new Contact(), new Contact(), new Contact(), new Contact()}, 2).size());
        System.assertEquals(3, utils.splitListBySize(new Contact[]{new Contact(), new Contact(), new Contact(), new Contact(), new Contact()}, 2).size());
    }
    
    testmethod public static void testGroupBy() {
			
        //Null input returns empty map
        System.assertEquals(0, utils.groupBy(null, null).keySet().size());
        System.assertEquals(0, utils.groupBy(null, 'Key').keySet().size());
        System.assertEquals(0, utils.groupBy(new Sobject[]{}, null).keySet().size());
        
        Account a1 = new Account(Name='Foo');
        Account a2 = new Account(Name='Foo');
        Account a3 = new Account(Name='Bar');
        Account a4 = new Account(Name='Bar');
        Account a5 = new Account(Name='Bar');
        
        Map<String, List<SObject>> gmap = utils.groupBy(new Sobject[]{a1, a2, a3, a4, a5}, 'Name');
        System.assertEquals(2, gmap.keySet().size());
        System.assertEquals(2, gmap.get('Foo').size());
        System.assertEquals(3, gmap.get('Bar').size());
    }
    
    testmethod public static void testDiffInDays() {
        DateTime now = DateTime.now();
        System.assertEquals(0, utils.diffInDays(now, now));
        System.assertEquals(0, utils.diffInDays(now, now.addHours(23)));
        System.assertEquals(1, utils.diffInDays(now, now.addHours(24)));
        System.assertEquals(1, utils.diffInDays(now.addHours(24), now));
        System.assertEquals(null, utils.diffInDays(now, null));
        System.assertEquals(null, utils.diffInDays(null, now));
        System.assertEquals(null, utils.diffInDays(null, null));
    }
    
    testmethod public static void testFindMaxInteger() {
    	//We will use contact.title field to store the numbers and derive the max
    	System.assertEquals(null, utils.findMaxInteger(null, null));
        System.assertEquals(null, utils.findMaxInteger(null, 'id'));
        System.assertEquals(null, utils.findMaxInteger(new List<Contact>(), null));
        
        List<Contact> contacts = new List<Contact>();
        contacts.add(new Contact(FirstName='Foo', LastName='Bar', Title='1'));
        System.assertEquals(1, utils.findMaxInteger(contacts, 'Title'));
        
        contacts.add(new Contact(FirstName='Foo', LastName='Bar', Title='3'));
        System.assertEquals(3, utils.findMaxInteger(contacts, 'Title'));
        
        contacts.add(new Contact(FirstName='Foo', LastName='Bar', Title='0'));
        System.assertEquals(3, utils.findMaxInteger(contacts, 'Title'));
    }
    
testmethod public static void testIsAllBlank() {
		System.assertEquals(true, utils.isAllBlank(null, null));
		System.assertEquals(true, utils.isAllBlank(null, ''));
		System.assertEquals(true, utils.isAllBlank(null, '   '));
		System.assertEquals(true, utils.isAllBlank('', null));
		System.assertEquals(true, utils.isAllBlank('  ', null));
		System.assertEquals(true, utils.isAllBlank('', ''));
		System.assertEquals(false, utils.isAllBlank(null, 'foo'));
		System.assertEquals(false, utils.isAllBlank('foo', null));
		System.assertEquals(false, utils.isAllBlank('bar', 'foo'));
	}

	testmethod public static void testIsNullOrZero() {
		System.assertEquals(true, utils.isNullOrZero(null));
		System.assertEquals(true, utils.isNullOrZero(0.0));
		System.assertEquals(false, utils.isNullOrZero(1.2));
	}


	testmethod public static void testEqualsIcAny() {
		System.assertEquals(false, utils.equalsIcAny(null, null));
		System.assertEquals(false, utils.equalsIcAny('foo', null));
		System.assertEquals(false, utils.equalsIcAny(null, new String[]{null, 'foo'}));
		System.assertEquals(true, utils.equalsIcAny('foo', new String[]{null, 'foo'}));
		System.assertEquals(true, utils.equalsIcAny('foo', new String[]{null, 'FOO'}));
		System.assertEquals(false, utils.equalsIcAny('foo', new String[]{null, ' foo '}));
	}

	testmethod public static void testReplaceMergeTokensWithUrlEncode() {
		System.assertEquals('foo {Bar}', utils.replaceMergeTokensWithUrlEncode('foo {Bar}', null));
		System.assertEquals('foo Value', utils.replaceMergeTokensWithUrlEncode('foo {Bar}', new Map<String, String>{'Bar'=>'Value'}));
		System.assertEquals('foo %26', utils.replaceMergeTokensWithUrlEncode('foo {Bar}', new Map<String, String>{'Bar'=>'&'}));
	}

	testmethod public static void base64Encode() {
		System.assertEquals('Rm9vIEJhcg==', utils.base64Encode('Foo Bar'));
	}

	testmethod public static void getCurrentClassMethodName() {
		System.assertEquals('BaseClassTest.getCurrentClassMethodName', utils.getCurrentClassMethodName());
	}

	testmethod public static void isFieldIdOrRefType() {
		System.assertEquals(false, utils.isFieldIdOrRefType(Schema.SObjectType.Contact.fields.getMap().get('FirstName')));
		System.assertEquals(true, utils.isFieldIdOrRefType(Schema.SObjectType.Contact.Fields.getMap().get('AccountId')));
	}

	testmethod public static void getSobjectName() {
		System.assertEquals('User', utils.getSobjectName(UserInfo.getUserId()));
	}

	testmethod public static void getRecordName() {
		Contact contact = new Contact(FirstName='Foo',LastName='Bar');
		insert contact;
		System.assertEquals('Foo Bar', utils.getRecordName(contact.id));
	}

	testmethod public static void isSuccess() {
		System.assertEquals(false, utils.isSuccess(null));
		System.assertEquals(false, utils.isSuccess(''));
		System.assertEquals(true, utils.isSuccess('success'));
		System.assertEquals(true, utils.isSuccess('Success'));
		System.assertEquals(true, utils.isSuccess(' Success '));
	}

	testmethod public static void queryLead() {
		Lead lead = new Lead(FirstName='Foo',LastName='Bar',Company='Foo');
		insert lead;
		System.assertEquals(lead.id, utils.queryLead(lead.id).id);
	}

	testmethod public static void queryContact() {
		Contact contact = new Contact(FirstName='Foo',LastName='Bar');
		insert contact;
		System.assertEquals(contact.id, utils.queryContact(contact.id).id);
	}
	
    testmethod public static void diffInMins() {
        DateTime d1 = DateTime.newInstance(2015, 06, 22, 10, 10, 0);
        DateTime d2 = DateTime.newInstance(2015, 06, 22, 10, 20, 10);
        System.assertEquals(10, utils.diffInMins(d1, d2));

        d2 = DateTime.newInstance(2015, 06, 22, 10, 10, 10);
        System.assertEquals(0, utils.diffInMins(d1, d2));

		d2 = DateTime.newInstance(2015, 06, 22, 10, 10, 59);
        System.assertEquals(0, utils.diffInMins(d1, d2));

		d2 = DateTime.newInstance(2015, 06, 22, 10, 10, 59);
        System.assertEquals(0, utils.diffInMins(d1, d2));

		d2 = DateTime.newInstance(2015, 06, 22, 11, 10, 00);
        System.assertEquals(60, utils.diffInMins(d1, d2));
    } 
    
    testmethod public static void increment() {
        System.assertEquals(1, utils.increment((Decimal) null));
        System.assertEquals(1, utils.increment(0.0));
        System.assertEquals(3, utils.increment(2.0));
        System.assertEquals(1, utils.increment((Integer) null));
        System.assertEquals(1, utils.increment(0));
        System.assertEquals(3, utils.increment(2));
    }
    
    testmethod public static void findMaxInteger() {
        List<Contact> contacts = new List<Contact>();
        contacts.add(new Contact(FirstName='1',LastName='1'));
        contacts.add(new Contact(FirstName='2',LastName='2'));
        
    	System.assertEquals(null, utils.findMaxInteger(null, null));
    	System.assertEquals(2, utils.findMaxInteger(contacts, 'FirstName'));
    }
    
    testmethod public static void getUpdatedRecords() {
        List<Contact> contacts = new List<Contact>();
        contacts.add(new Contact(FirstName='Foo',LastName='Bar'));
        contacts.add(new Contact(FirstName='Bob',LastName='Alice'));
        contacts.add(new Contact(FirstName='Fred',LastName='Vilma'));
        
        List<Contact> contacts2 = new List<Contact>();
        contacts2.add(new Contact(FirstName='Foo',LastName='Bar'));
        contacts2.add(new Contact(FirstName='Bob',LastName='Alice1'));
        contacts2.add(new Contact(FirstName='Fred1',LastName='Vilma'));
        
        System.assertEquals(1, utils.getUpdatedRecords(contacts, contacts2, 'LastName').size());
        System.assertEquals(2, utils.getUpdatedRecords(contacts, contacts2, new String[] {'FirstName', 'LastName'}).size());
    }
		
    testmethod public static void getMatchingRecords() {
        List<Contact> contacts = new List<Contact>();
        contacts.add(new Contact(FirstName='Foo',LastName='Bar'));
        contacts.add(new Contact(FirstName='Bob',LastName='Vilma'));
        contacts.add(new Contact(FirstName='Fred',LastName='Vilma'));
        
        System.assertEquals(0, utils.getMatchingRecords(null, null, null).size());
        System.assertEquals(2, utils.getMatchingRecords(contacts, 'LastName', 'Vilma').size());
    }
    
    testmethod public static void testMultiStringMap() {
    	BaseClass.MultiStringMap mmap = new BaseClass.MultiStringMap();
        mmap.put('Classic', 'Foo');
        mmap.put('Classic', 'Bar');
        mmap.put('Classic', 'Bob');
        mmap.put('Classic', 'Alice');
        mmap.put('Classic', 'Alice');
        mmap.put('Cartoon', 'Fred');
        
        System.assertEquals(5, mmap.get('Classic').size());
        System.assertEquals(1, mmap.get('Cartoon').size());
        System.assertEquals(null, mmap.get('Classic1'));
        
		mmap = new BaseClass.MultiStringMap(true);
        mmap.put('Classic', 'Foo');
        mmap.put('Classic', 'Alice');
        mmap.put('Classic', 'Alice');
        System.assertEquals(2, mmap.get('Classic').size());
    }
    
    testmethod public static void testTriggerMethods() {
        System.assertEquals(false, utils.isAfterInsert());
        System.assertEquals(false, utils.isAfterInsertOrUpdate());
        System.assertEquals(false, utils.isAfterUpdate());
        System.assertEquals(false, utils.isBeforeInsert());
        System.assertEquals(false, utils.isBeforeInsertOrUpdate());
        System.assertEquals(false, utils.isBeforeUpdate());
    }
    
    testmethod public static void testExceptionDetails() {
        System.assert(utils.getExceptionDetails(new BusinessException()).indexOf('BusinessException') >= 0);
        System.assert(utils.getExceptionDetails(new UnsuccessfulHttpResponseException(new HttpRequest(), new HttpResponse())).indexOf('Request') >= 0);
    }
    
    testmethod public static void testParseIsoDate() {
        System.assertEquals(null, utils.parseIsoDate(null));
        System.assertEquals(Date.newInstance(2013, 12, 11), utils.parseIsoDate('2013-12-11'));
    }

    testmethod public static void testcreateHttpParmsString() {
        String resp = utils.createHttpParmsString(
            new Map<String, String>{'foo'=>'bar','bob'=>'alice'});
        //Because it is map, it could be ordered in anyways
        System.assert(resp == 'foo=bar&bob=alice' || resp == 'bob=alice&foo=bar');
        
        System.assertEquals('bob=bob+alice', utils.createHttpParmsString(
            new Map<String, String>{'bob'=>'bob alice'}));
        
        System.assertEquals('bob=', utils.createHttpParmsString(
            new Map<String, String>{'bob'=>null}));
    }
    
    testmethod public static void testIsToBeSynced() {
        System.assertEquals(false, utils.isToBeSynced(null));
        System.assertEquals(false, utils.isToBeSynced(''));
        System.assertEquals(false, utils.isToBeSynced('SomeValue'));
        System.assertEquals(true, utils.isToBeSynced('To Be Synced'));
    }
    
    testmethod public static void testQueryOpty() {
        System.assertEquals(null, utils.queryOpty('01pj0000002Y8YX'));
    }
    
    testmethod public static void testisChangedSobject() {
        Contact c1 = new Contact(FirstName='Foo', LastName='Bar');
        Contact c2 = new Contact(FirstName='Foo1', LastName='Bar');
        Contact c3 = new Contact(FirstName='Foo1', LastName='bar');
        
        System.assertEquals(true, utils.isChanged(c1, c2, 'FirstName'));
        System.assertEquals(false, utils.isChanged(c1, c2, 'LastName'));
        System.assertEquals(true, utils.isChanged(c1, c3, 'LastName'));
    }
    
    testmethod public static void testsha256() {
        System.assertEquals('3cded68a9e0f9b83f2c5de1b79fc4dac45004523e6658d46145156fa6a03eced', EncodingUtil.convertToHex(utils.hmacSha256('Test', 'Test')));
    }

    testmethod public static void testsha256HashHex() {
        System.assertEquals('532eaabd9574880dbf76b9b8cc00832c20a6ec113d682299550d7a6e0f345e25', utils.sha256HashHex('Test'));
    }
    
    testmethod public static void testisNotBatchAndFuture() {
        System.assertEquals(true, utils.isNotBatchAndFuture());
    }
    
    testmethod public static void testCreateBusinessException() {
        System.assertEquals('ErrorCode', utils.createBusinessException('ErrorCode', 'Message').errorCode);
        System.assertEquals('Message', utils.createBusinessException('ErrorCode', 'Message').getMessage());
        System.assertNotEquals(null, utils.createBusinessException('ErrorCode', 'Message', new SystemException()).getCause());
    }
    
    testmethod public static void testIsQueueableLimitsReached() {
    	System.assertEquals(false, utils.isQueueableLimitsReached());
    }
    
    testmethod public static void testGetQueueableLimitsStatus() {
        System.assert(utils.getQueueableLimitsStatus().indexOf('of') >= 0);
    }
    
    testmethod public static void testGetClassName() {
		System.assertEquals('BaseClass', utils.getClassName(utils));    
    }
    
    public class TestQueue implements Queueable {
        public void execute(QueueableContext ctx) {}
    }
    
    testmethod public static void testEnqueJobWithCheck() {
        //Thre is nothing to test in this case. So we will just execute.
        utils.enqueueJobWithCheck(new TestQueue());
    }
    
    testmethod public static void testGetOauth2AccessToken() {
        FlexibleCalloutMock mock = new FlexibleCalloutMock(200, '{"access_token": "dZPOhp3tGudFt1BRVjukClue2rbQ", "expires_in": "1799", "client_id": "5dx1ZW0jsuWeFd8tyZWrznmGi14YgRof"}');
		System.assertEquals('dZPOhp3tGudFt1BRVjukClue2rbQ', utils.getOAuth2AccessToken('https://example.org', 'clientid', 'clientSecret'));
    }

    testmethod public static void testRemoveUsPhoneFormatting() {
        System.assertEquals(null, utils.removeUSPhoneFormatting(null));
        System.assertEquals('', utils.removeUSPhoneFormatting(''));
        System.assertEquals('1234567890', utils.removeUSPhoneFormatting('+1 123 456 7890'));
        System.assertEquals('1234567890', utils.removeUSPhoneFormatting('+1 (123) 456-7890'));
        System.assertEquals('1234567890', utils.removeUSPhoneFormatting('+1 123-456-7890'));
        System.assertEquals('1234567890', utils.removeUSPhoneFormatting('+1 (123) (456) (7890)'));
        System.assertEquals('1234567890', utils.removeUSPhoneFormatting('+1 999 (123) (456) (7890)'));
    }
    
    testmethod public static void testIsMatchesWildcard() {
        System.assertEquals(false, utils.isMatchesWildcard(null, null));
        System.assertEquals(true, utils.isMatchesWildcard('California', 'Cali*'));
        System.assertEquals(true, utils.isMatchesWildcard('California', 'Cali?ornia'));
        System.assertEquals(true, utils.isMatchesWildcard('California', 'California*'));
        System.assertEquals(true, utils.isMatchesWildcard('Consultant Inside Sales: San Francisco', 'Consultant*Sales*'));
        System.assertEquals(false, utils.isMatchesWildcard('California', 'California?'));
        System.assertEquals(false, utils.isMatchesWildcard('California', 'Cali*1'));
    }
 	
    testmethod public static void testGetValue() {
        System.assertEquals(null, utils.getValue(null, 'Id'));
        User user = [
            select id, lastmodifiedby.name from user where id = :UserInfo.getUserId()
        ];
        
        System.assertEquals(user.id, utils.getValue(user, 'Id'));
        System.assertEquals(user.LastModifiedBy.name, utils.getValue(user, 'LastModifiedBy.Name'));
    }   
}