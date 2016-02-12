@IsTest
public class JsonWriterTest {
    
    testmethod public static void testJsonWriter() {
        System.assertEquals('{}', new JsonWriter().toJson());
        System.assertEquals('[]', new JsonWriter(true).toJson());
        System.assertEquals('{"key1":"value1"}', new JsonWriter().write('key1', 'value1').toJson());
        System.assertEquals('{"key1":{"key2":["value2"]}}', new JsonWriter().write('key1.key2[0]', 'value2').toJson());
        System.assertEquals('["value1","value2"]', new JsonWriter().write('[0]', 'value1').write('[1]', 'value2') .toJson());
        System.assertEquals('{\n  "key1" : "value1"\n}', new JsonWriter().write('key1', 'value1').toPrettyJson());
        //System.assertEquals('{"foo":{"bar":{"bob":"alice"},"fred":"velma"},"tom":"jerry"}', new JsonWriter().with('foo').with('bar').write('bob', 'alice').endWith().write('fred', 'velma').endWith().write('tom', 'jerry').toJson());
        
        try {
            //This should generate an error as first level we are trying to make an arry as well as object
            new JsonWriter().write('[0]', 'foo').write('foo', 'bar');
            System.assert(false, 'Supposed to throw an exception!');
        } catch (SystemException e) {
            //ignore
        }
    }
}