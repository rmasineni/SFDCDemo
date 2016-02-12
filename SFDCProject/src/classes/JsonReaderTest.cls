@IsTest
public class JsonReaderTest {

    testmethod public static void testJsonReader() {
        System.assertEquals(null, new JsonReader('{}').getString('key1'));
        System.assertEquals(null, new JsonReader('{}').getString('key1.key2'));
        System.assertEquals(null, new JsonReader('{}').getString('key[0].value'));
        System.assertEquals(null, new JsonReader('{}').getString('[0].value'));
        System.assertEquals(null, new JsonReader('{}').getString('key.value[0]'));
        System.assertEquals(null, new JsonReader('[]').getString('key.value[0]'));
        System.assertEquals(null, new JsonReader('{"key1":["value1","value2"]}').getString('key1.value[0]'));
        
        System.assertEquals('value1', new JsonReader('{"key1":"value1"}').getString('key1'));
        System.assertEquals('value2', new JsonReader('{"key1":"value1", "key2":"value2"}').getString('key2'));
        System.assertEquals('value3', new JsonReader('{"key1":"value1", "key2":"value2", "key3": {"key4":"value3"}}').getString('key3.key4'));
        System.assertEquals('value4', new JsonReader('{"key1":"value1", "key2":"value2", "key3": {"key4":"value3"}, "key5": ["value4", "value5"]}')
                            .getString('key5[0]'));
        
        System.assertEquals('value6', new JsonReader('{"key1":"value1", "key2":"value2", "key3": {"key4":"value3"}, "key5": ["value4", "value5", {"key6": "value6"}]}')
                            .getString('key5[2].key6'));

        System.assertEquals('value1', new JsonReader('["value1", "value2"]').getString('[0]'));
        System.assertEquals('value2', new JsonReader('["value1", "value2"]').getString('[1]'));
        
        JsonReader reader = new JsonReader('{"key0":true, "key1":"value1", "key2":"value2", "key3": {"key4":"value3"}, "key5": ["value4", "value5", {"key6": "value6"}], "key7": 123, "key8": 123.45}');
        JsonReader reader2 = reader.getReader('key3');
        System.assertEquals('value3', reader2.getString('key4'));
        System.assertEquals(3, reader.getList('key5').size());
        System.assertEquals(true, reader.getReader('key5').isArray());
        System.assertEquals('value3', reader.getMap('key3').get('key4'));
        
        //System.assertEquals(null, reader.getBoolean('keynotexist'));
        System.assertEquals(true, reader.getBoolean('key0'));

        System.assertEquals(null, reader.getInteger('keynotexist'));
        System.assertEquals(123, reader.getInteger('key7'));

        System.assertEquals(null, reader.getDecimal('keynotexist'));
        System.assertEquals(123.45, reader.getDecimal('key8'));
        
        System.assert(reader.getObject() != null);
    }

    testmethod public static void testGetDateTime() {
        JsonReader reader = new JsonReader('{"dateTimeKey": "2015-12-20T09:20:30Z"}');
        System.assertEquals(DateTime.newInstanceGmt(2015, 12, 20, 09, 20, 30), reader.getDateTime('dateTimeKey'));
    }
    
    testmethod public static void testRootList() {
        System.assertEquals(0, new JsonReader('[]').getList(null).size());
        System.assertEquals(1, new JsonReader('[""]').getList(null).size());
    }

    testmethod public static void testContainsKey() {
        JsonReader reader = new JsonReader('{"foo":"bar"}');
        System.assertEquals(true, reader.containsKey('foo'));
        System.assertEquals(false, reader.containsKey('bar'));
        System.assertEquals(false, reader.containsKey('foo.bar'));
    }

    testmethod public static void testToJson() {
        JsonReader reader = new JsonReader('{"foo":"bar"}');
        System.assertEquals('{"foo":"bar"}', reader.toJson());
        System.assertEquals('{\n  "foo" : "bar"\n}', reader.toPrettyJson());

        reader = new JsonReader((Object) null);
        System.assertEquals('{ }', reader.toPrettyJson());
    }

    testmethod public static void testSetString() {
        JsonReader reader = new JsonReader('{"foo":"bar"}');
        System.assertEquals(null, reader.getString('foo1'));

        reader.setString('foo1', 'bar1');
        System.assertEquals('bar1', reader.getString('foo1'));
    }

    testmethod public static void testGetBoolean() {
        JsonReader reader = new JsonReader('{"foo":true}');
        System.assertEquals(false, reader.getBoolean('foo1'));
        System.assertEquals(true, reader.getBoolean('foo'));
    }
    
    testmethod public static void testWith() {
        JsonReader reader = new JsonReader('{"foo":"bar"}');
        System.assertEquals('bar', reader.getWithKey('bar'));
        
        reader.with(0);
        System.assertEquals('[0].bar', reader.getWithKey('bar'));

        reader.with(1);
        System.assertEquals('[0].[1].bar', reader.getWithKey('bar'));
		
        reader.endWith();
        System.assertEquals('[0].bar', reader.getWithKey('bar'));
        
        reader.newWith(1);
        System.assertEquals('[1].bar', reader.getWithKey('bar'));

        reader.newWith('foo');
        System.assertEquals('foo.bar', reader.getWithKey('bar'));

        reader.clearWith();
        System.assertEquals('bar', reader.getWithKey('bar'));
    }
    
    testmethod public static void testGetString() {
        JsonReader reader = new JsonReader('{"foo":"bar", "bob":"alice"}');
        System.assertEquals('bar', reader.getString('foo'));
        System.assertEquals('foo2', reader.getString('foo2', 'foo2'));
    }

    testmethod public static void testGetStringList() {
        JsonReader reader = new JsonReader('{"foo":["foo1", "foo2"]}');
        System.assertEquals(2, reader.getStringList('foo').size());
       
    }
}