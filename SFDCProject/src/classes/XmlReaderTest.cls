@IsTest
public class XmlReaderTest {
	
    testmethod public static void testGetText() {
        System.assertEquals('bar', new XmlReader('<root><foo>bar</foo></root>').getString('foo'));
        System.assertEquals(null, new XmlReader('<root><foo>bar</foo></root>').getString('foo.key2'));
    }

    testmethod public static void testArray() {
        System.assertEquals(1, new XmlReader('<root><foo>bar</foo></root>').getChildrenSize(''));
        System.assertEquals(4, new XmlReader('<root><foo>bar0</foo><foo>bar1</foo><foo>bar2</foo><foo>bar3</foo></root>').getChildrenSize(''));
        System.assertEquals('bar0', new XmlReader('<root><foo>bar0</foo><foo>bar1</foo><foo>bar2</foo><foo>bar3</foo></root>').getString('foo'));
        System.assertEquals('bar1', new XmlReader('<root><foo>bar0</foo><foo>bar1</foo><foo>bar2</foo><foo>bar3</foo></root>').getString('foo[1]'));
        System.assertEquals(null, new XmlReader('<root><foo>bar0</foo><foo>bar1</foo><foo>bar2</foo><foo>bar3</foo></root>').getString('foo[5]'));
    }
    
    testmethod public static void testAttribute() {
        System.assertEquals('bar', new XmlReader('<root><foo bob="alice">bar</foo></root>').getString('foo'));
        System.assertEquals('alice', new XmlReader('<root><foo bob="alice" velma="fred">bar</foo></root>').getAttribute('foo.bob'));
        System.assertEquals('fred', new XmlReader('<root><foo bob="alice" velma="fred">bar</foo></root>').getAttribute('foo.velma'));
    }
}