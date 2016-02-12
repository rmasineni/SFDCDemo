/**
 * Convenient wrapper over Salesforce Xml Dom classes. This supports reading the various types of
 * values from given xml or document. It ignores the namespace completely and only goes by the node name.
 * 
 * It doesn't yet support multiple list elements of same name (aka array)
 */ 
public class XmlReader {
	private Dom.Document doc;
    private DOM.XMLNode rootNode;
    
    public XmlReader (String xml) {
		doc = new DOM.Document();     
	    doc.load(xml);
        rootNode = doc.getRootElement();
    }

    public String toXml() {
		return doc.toXmlString();  
    }
    
    public XmlReader (Dom.Document doc) {
    	this.doc = doc;   
        this.rootNode = doc.getRootElement();
    }
    
    /**
     * Returns the number of child elements in the given key.
     */
    public Integer getChildrenSize(String key) {
        Dom.XmlNode node = getNode(key);
        if (node == null) {
            return 0;
        }
        return node.getChildElements().size();
    }
    
    public String getText(String key) {
        return getString(key);
    }
    
    /**
     * The key should not include the root xml name.
     */
    public String getString(String key) {
        Dom.XmlNode node = getNode(key);
        if (node == null) {
            return null;
        }
        
        return getText(node);
    }
    
    public String getAttribute(String key) {
        Dom.XmlNode node = getNode(key.substringBeforeLast('.'));
        if (node == null) {
            return null;
        }
        
        String attName = key.substringAfterLast('.');
        for (Integer i = 0; i < node.getAttributeCount(); i++) {
            String name = node.getAttributeKeyAt(i);
            if (name == attName) {
                return node.getAttributeValue(name, node.getAttributeKeyNsAt(i));
            }
        }
        
        return null;
    }

    public String getText(Dom.XmlNode node) {
        
        if (node.getNodeType() == Dom.XmlNodeType.TEXT) {
			return node.getText();
        }

        if (node.getNodeType() == Dom.XmlNodeType.ELEMENT) {
            
            for (Dom.XmlNode child : node.getChildren ()) {
                if (child.getNodeType() == Dom.XmlNodeType.TEXT) {
                    return child.getText();
                }
            }
        }
        
        return null;
    }

    /**
     * Returns the Xml node corresponding to the given key. If given key doesn't exist, then returns null.
     */
    public Dom.XmlNode getNode(String key) {
        System.debug('Getting node for key ' + key);
        
        //If key is null or empty, then they are looking for root node.
        if (key == null || String.isBlank(key)) {
            return rootNode;
        }
        
        Dom.XmlNode currentObj = rootNode;
         
        String[] segments = key.split('\\.');
		System.debug('Segments after split are ' + segments + ' and current obj ' + currentObj);
        
        for (Integer segmentIndex = 0; segmentIndex < segments.size(); segmentIndex++) {
            System.debug('Getting node for segment index ' + segmentIndex + ' and name ' + segments.get(segmentIndex) +' from current obj ' + currentObj);
            if (currentObj == null) {
                System.debug('Current object is null so returning null');
                return null;
            }

            currentObj = getSegmentValue(currentObj, segments.get(segmentIndex));
        }
        
        System.debug('Returning the matched node ' + currentObj);
        return currentObj;
    }
    
    public Dom.XmlNode getSegmentValue(Dom.XmlNode currentObj, String keySegment) {
		System.debug('getSegmentValue for segment ' + keysegment + ' from ' + currentObj.getName() + ' ' + currentObj);        
        
		//By default we will return first found element matching the name.
		//If it is array, then we will find the specified indexed matching element.
        Integer elementIndex = 0;
        if (keySegment.indexOf('[') >= 0) {
            elementIndex = Integer.valueOf(keySegment.substringBetween('[', ']'));
            keySegment = keySegment.substringBefore('[');
        }
        
		Integer foundElementsCount = 0;
        System.debug('currentObj.getNodeType() ' + currentObj.getNodeType());
        if (currentObj.getNodeType() == Dom.XmlNodeType.ELEMENT) {
            for (Dom.XmlNode child : currentObj.getChildElements()) {
                System.debug('Processing child ' + child.getName() + ' and comparing with key segment ' + keySegment + ' ' + child);
                if (child.getName() == keySegment) {
                    if (foundElementsCount == elementIndex) {
                    	System.debug('Returning matching node ' + child);
	                   	return child;
                    }
                    foundElementsCount++;
                }
            }
        }
        
        return null;
    }
}