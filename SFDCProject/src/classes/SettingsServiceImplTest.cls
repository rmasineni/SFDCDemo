@IsTest
public class SettingsServiceImplTest {
    
    private static SettingsService settings = Sf.settingsService;
	private static BaseClass utils = new BaseClass();	
    
    testmethod public static void testSetString() {
        settings.setString('StringSetting', 'foo');
        System.assertEquals('foo', settings.getString('StringSetting'));

        settings.setString('StringSetting', 'bar');
        System.assertEquals('bar', settings.getString('StringSetting'));

        settings.setString('StringSetting', null);
        System.assertEquals('bob', settings.getString('StringSetting', 'bob'));
    }
    
    testmethod public static void testGetString() {
        
        try {
            settings.getString('StringSetting');            
            System.assert(false);
        } catch (BusinessException e) {
        }
        
        Settings__c setting = new Settings__c(Name='StringSetting');
        insert setting;
        
        try {
            settings.getString('StringSetting');
            System.assert(false);
        } catch (BusinessException e) {
        }
        System.assertEquals('DefaultValue', settings.getString('StringSetting', 'DefaultValue'));
        
        setting.VAlue1__c = 'StringValue';
        update setting;
        
        System.assertEquals('StringValue', settings.getString('StringSetting'));
        System.assertEquals('StringValue', settings.getString('StringSetting', 'DefaultValue'));
    }

    testmethod public static void testSetInteger() {
        settings.setInteger('IntegerSetting', 10);
        System.assertEquals(10, settings.getInteger('IntegerSetting'));

        settings.setInteger('IntegerSetting', 20);
        System.assertEquals(20, settings.getInteger('IntegerSetting'));

        settings.setInteger('IntegerSetting', null);
        System.assertEquals(30, settings.getInteger('IntegerSetting', 30));
    }

    testmethod public static void testGetInteger() {
        
        try {
            settings.getInteger('IntegerSetting');
            System.assert(false);
        } catch (BusinessException e) {
        }
        
        Settings__c setting = new Settings__c(Name='IntegerSetting');
        insert setting;
        
        try {
            settings.getInteger('IntegerSetting');
            System.assert(false);
        } catch (BusinessException e) {
        }
        System.assertEquals(10, settings.getInteger('IntegerSetting', 10));
        
        setting.VAlue1__c = '115';
        update setting;
        
        System.assertEquals(115, settings.getInteger('IntegerSetting'));
        System.assertEquals(115, settings.getInteger('IntegerSetting', 10));
    }

    testmethod public static void testSetBoolean() {
        settings.setBoolean('BooleanSetting', true);
        System.assertEquals(true, settings.getBoolean('BooleanSetting'));

        settings.setBoolean('BooleanSetting', false);
        System.assertEquals(false, settings.getBoolean('BooleanSetting'));

        settings.setBoolean('BooleanSetting', null);
        System.assertEquals(false, settings.getBoolean('BooleanSetting', false));
    }

    testmethod public static void testGetBoolean() {
        
        try {
            settings.getBoolean('BooleanSetting');
            System.assert(false);
        } catch (BusinessException e) {
        }
        
        Settings__c setting = new Settings__c(Name='BooleanSetting');
        insert setting;
        
        try {
            settings.getBoolean('BooleanSetting');
            System.assert(false);
        } catch (BusinessException e) {
        }
        System.assertEquals(true, settings.getBoolean('BooleanSetting', true));
        
        setting.VAlue1__c = 'false';
        update setting;
        
        System.assertEquals(false, settings.getBoolean('BooleanSetting'));
        System.assertEquals(false, settings.getBoolean('BooleanSetting', true));
    }

    testmethod public static void testSetDate() {
        settings.setDate('DateSetting', Date.valueOf('2014-11-20'));
        System.assertEquals(Date.valueOf('2014-11-20'), settings.getDate('DateSetting'));

        settings.setDate('DateSetting', Date.valueOf('2015-11-20'));
        System.assertEquals(Date.valueOf('2015-11-20'), settings.getDate('DateSetting'));

        settings.setDate('DateSetting', null);
        System.assertEquals(Date.valueOf('2014-11-20'), settings.getDate('DateSetting', Date.valueOf('2014-11-20')));
    }
    
    testmethod public static void testGetDate() {
        
        try {
            settings.getDate('DateSetting');
            System.assert(false);
        } catch (BusinessException e) {
        }
        
        Settings__c setting = new Settings__c(Name='DateSetting');
        insert setting;
        
        try {
            settings.getDate('DateSetting');
            System.assert(false);
        } catch (BusinessException e) {
        }
        System.assertEquals(Date.valueOf('2014-11-20'), settings.getDate('DateSetting', Date.valueOf('2014-11-20')));
        
        setting.VAlue1__c = '2010-09-28';
        update setting;
        
        System.assertEquals(Date.valueOf('2010-09-28'), settings.getDate('DateSetting'));
        System.assertEquals(Date.valueOf('2010-09-28'), settings.getDate('DateSetting', Date.valueOf('2014-11-20')));
    }
    
    testmethod public static void testDateTime() {
        DateTime dt = DateTime.now();
        settings.setDateTime('DateTimeSetting', dt);
        System.assertEquals(dt, settings.getDateTime('DateTimeSetting'));

        settings.setDateTime('DateTimeSetting', null);
        System.assertEquals(null, settings.getDateTime('DateTimeSetting', null));
    }

    testmethod public static void testGetDateTime() {
        
        try {
            settings.getDate('DateTimeSetting');
            System.assert(false);
        } catch (BusinessException e) {
        }
        
        Settings__c setting = new Settings__c(Name='DateTimeSetting');
        insert setting;
        
        try {
            settings.getDate('DateTimeSetting');
            System.assert(false);
        } catch (BusinessException e) {
        }
        DateTime currentTime = DateTime.now();
        System.assertEquals(currentTime, settings.getDateTime('DateTimeSetting', currentTime));
        
        setting.Value1__c = '2015-11-26T05:52:39Z';
        update setting;
        
        System.assertEquals(utils.parseAsUtcIsoDateTime('2015-11-26T05:52:39Z'), settings.getDateTime('DateTimeSetting'));
    }

    testmethod public static void testGetStringList() {
        try {
            settings.getStringList('StringList');
            System.assert(false);
        } catch (BusinessException e) {
        }
        
        Settings__c setting = new Settings__c(Name='StringList');
        insert setting;
        
        try {
            settings.getStringList('StringList');
            System.assert(false);
        } catch (BusinessException e) {
        }
        
        System.assertEquals('Value1', settings.getStringList('StringList', new String[]{'Value1'}).get(0));
        
        setting.Value1__c = 'Value1,Value2';
        update setting;
        
        System.assertEquals(2, settings.getStringList('StringList').size());
        System.assertEquals('Value2', settings.getStringList('StringList').get(1));
    }
    
    testmethod public static void testGetStringMap() {
        String settingName = 'StringMap';
        try {
            settings.getStringMap(settingName);
            System.assert(false);
        } catch (BusinessException e) {
        }
        
        Settings__c setting = new Settings__c(Name=settingName);
        insert setting;
        
        try {
            settings.getStringMap(settingName);
            System.assert(false);
        } catch (BusinessException e) {
        }
        
        System.assertEquals('Value1', settings.getStringMap(settingName, new Map<String,String>{'Key1'=>'Value1'}).get('Key1'));
        
        setting.Value1__c = 'Key1=Value1,Key2=Value2';
        update setting;
        
        System.assertEquals(2, settings.getStringMap(settingName).size());
        System.assertEquals('Value2', settings.getStringMap(settingName).get('Key2'));
    }
    
    testmethod public static void testClearEnvironmentSpecificSettings() {
        
        String settingName = 'Key';
        
        Settings__c setting = new Settings__c(Name=settingName, Value1__c='Value', Environment_Specific__c=true);
        insert setting;
        
        settings.clearEnvironmentSpecificSettings();
        
        System.assertEquals(null, settings.getString(settingName, null));
    }
    
    testmethod public static void testRemoveNullValues() {
        Settings__c setting = new Settings__c(Name='Test', Value1__c='null');
        insert setting;
        
        new SettingsServiceImpl().removeNullValues();
		
        System.assertEquals(null, settings.getString('Test', null));
		
    }

    testmethod public static void testSplitAndSetString() {
        SettingsServiceImpl impl = new SettingsServiceImpl();
        
    	String longString = 'MIIFDjBABgkqhkiG9w0BBQ0wMzAbBgkqhkiG9w0BBQwwDgQIKLElcSzA2+QCAggAMBQGCCqGSIb3DQMHBAg2RWlGOaenXgSCBMi9vDTjDJBM3sNbLez125f7rCJM152V7M9Di9VeGOtWL4hBRQxJekraXvI+5UpDEgTsHWXKYGvSOfvf4I/PCGEyoSR0UN2mxgtu/k4HEgsg3yPYpFJrvbr03WxR7xeKuNmlDW60ut9zUAReNNxZTSIh+LcxFBtyGmgZtN/ST/iO6Cv455Ts6f0EXxCwoqR9EpauwpDhXNsZQCZ8NZMkiDI6dZZpAhLHUNJeljuKCFoVrywBVypUKtF3wXeINsOKeAAgrkFijFznFhe/m2mFAk8tfvz7xk4hfCp3koO8A+gQJwNzZ6XoT7hprWbfFcgmusDOO95Lj/Kjs9wRvdHDcjcxQDXXYrpD2Lu0FS30XON+dYKEuFQjrAvGCyXcYo/JYjYkTi8S691JCZs99mXsR6KpT8blSdLpj8RkG2NNdwB9iQNVdJweIfSFXwfzHW5/BzjkQb2rLHZiMBjz449YImYD6qZ4pbTyg7C1lra5Ed6+PLmSCOxgeWiNBrU1qQd9gULhWDIJdxpUbHjxjX4gAacf0+qHbotUm+om/rR54KE35KwNBOwYrFIV1gPM+Fa4JvPO+Pd9pyBGxTsucwIt+Gs0EQA2ilw8Gvq41J56MQ7louSkPXSS2CJVJeXmkbb/YAHBMaEpp1arOxWT4SAB0r5PLy2tETzcrPEuL8sQLBWjuuKtIrK1qNvc5SjgGAyY3SHSGluqaQPL+BEyKVsQT3kOhcxhTHL+tTqooqyBBr+M4sz8bDgrOjKfCaFQ1wz0u0zNrYxkJElNmUaMciGy5MyTDN9MdzuU9qLeM/PNQ32/2msMIuawqn5E0oGRiljPXpkEqp18q/RLrnA2xYrkbjGuG3+1Mh+iLrz1o6Pqzg5mMo0uvzr2KQ9ddBgrcgzEQc0xUO0GpITjGxGRzzB3fXQqtv7FyjP/Sq9FRXp7v3crdSEpADTFnHuqRHPxQwNylLuH6nDPbxz236QTuU1edGKfGfgxd/2gnXH1F75Nd8VDWq7RXXqUjsrCiIsOvV7/O8+jYaVrCdiVqYUVATdt1UP3y5wNNj8exLzRIO9MCrLTPhUsvrnClRUL3mgr5MEomwsdt+vLHcMRJ71ZR1kkCEfTAkaXZIiXbkfJhaRRHhSzIMRwv1DvWsD0pSfgsjN+bh//1chOlsPuGumZ7QLLQX/HKvMWnUIZ2dLeU1hdEgWcIKdD8GhiYk+YxpW391lXTTy51FxVlve/L41YkqS56MBlMC2dHfj3vIBBmuoAasvwUvkFcqe6cQ25rheyEo4kjU0+lehYjf5a8cGhpVhmNJRcOZXjd2QQUILLnpWSFqHOxwRsX8n8CW+AHDzdFnlg8cxMQPQvK+xGVit8o6g63KR05RiscWUsjC5Asnc5yo7gmgr973y4bKmgCoJZv7MhXT08HwChIcwM9v+Kajl2N2mBVACu/12ATVeEQCXDCN7ObV6J1L2jgw6gcp0fmLk7YVEVyNIWf7rNWVOFZSoZ06s1cQTLVuTl0hzZweNI2PJqCW/slmE7FRV1ySJ3mSq+XzbscQbjl/Dq7CK95uQv6rxRES9o05/I1Om9Y71mD3Opf+MGOAfojQIk1B94aFQdlftKjexx8/2NSCk/M3vH0RUHOPQa4JzuRfo=';
		impl.splitAndSetString('DemoKey', longString);
        System.assertEquals(longString, impl.getString('DemoKey'));

        String shortString = 'MIIFDjBABgkqhkiG9w0BBQ0wMzAbBgkq';
		impl.splitAndSetString('DemoKey', shortString);
        System.assertEquals(shortString, impl.getString('DemoKey'));
    }

    testmethod public static void testSplitAndSetMap() {
        SettingsServiceImpl impl = new SettingsServiceImpl();
		
		impl.splitAndSetMap('DemoKey', 'foo=' + utils.createText('1', 250) + ',bob=' + utils.createText('1', 200));
        System.assertEquals(utils.createText('1', 200), impl.getStringMap('DemoKey').get('bob'));
    }
}