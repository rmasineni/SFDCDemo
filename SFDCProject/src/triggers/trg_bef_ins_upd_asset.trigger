trigger trg_bef_ins_upd_asset on Asset__c (before insert, before update) {
    Set<String>uniqueset = new Set<String>(); 
    Set<Id>RecordTypeSet = new Set<Id>();
    //Added by Suneetha
     Set<String>monSiteIDset = new Set<String>(); 
     Map<String, Asset__c> monSiteIDMap= new Map<String, Asset__c>();
    Map<String, Asset__c> assetMap = new Map<String, Asset__c>();
   
    Id RectypeId = Schema.SObjectType.Asset__c.RecordTypeInfosByName.get('Meter').RecordTypeId;
    
        for (Asset__c asset : System.Trigger.new) {
            
             //+'+'+asset.Vendor__c
             if ((asset.Monitoring_Site_ID__c != null)&& (asset.Vendor__c != null) && (System.Trigger.isInsert ||
                (asset.Monitoring_Site_ID__c != System.Trigger.oldMap.get(asset.Id).Monitoring_Site_ID__c) && (System.Trigger.isInsert ||
                (asset.Vendor__c != System.Trigger.oldMap.get(asset.Id).Vendor__c)))) 
                {
                if ( monSiteIDMap.containsKey(asset.Monitoring_Site_ID__c+'+'+asset.Vendor__c)) {
                    asset.addError('Duplicate Site id within batch file not allowed');
                   //   asset.addError('2--'+ asset.Monitoring_Site_ID__c+'+'+asset.Vendor__c); 
                } else {
                  monSiteIDMap.put(asset.Monitoring_Site_ID__c+'+'+asset.Vendor__c, asset); 
                  monSiteIDset.add(asset.Monitoring_Site_ID__c);
                 //  asset.addError('1--'+ asset.Monitoring_Site_ID__c+'+'+asset.Vendor__c); 
                }
            }
            if ((asset.Unique_Asset__c != null) && (System.Trigger.isInsert ||
                (asset.Unique_Asset__c != System.Trigger.oldMap.get(asset.Id).Unique_Asset__c))) {
                if (assetMap.containsKey(asset.Unique_Asset__c)) {
                    asset.addError('Duplicate Asset within batch file not allowed');
                } else {
                    assetMap.put(asset.Unique_Asset__c, asset);     
                }
            }
        }
        
          for (Asset__c asset : [SELECT Monitoring_Site_ID__c,Vendor__c FROM Asset__c WHERE type__c='Monitoring Service' and Status__c='Active' and Monitoring_Site_ID__c IN : monSiteIDset]) {  
                        
            Asset__c newasset =  monSiteIDMap.get(asset.Monitoring_Site_ID__c+'+'+asset.Vendor__c);
           // monSiteIDMap.get(asset.Monitoring_Site_ID__c).addError('Can not create duplicate records with  Monitoring Site Id' + asset.Monitoring_Site_ID__c +'+' +asset.Vendor__c ); 
          //   newasset.addError('Can not create duplicate records with  Monitoring Site Id--vv--' + asset.Monitoring_Site_ID__c +'+' +asset.Vendor__c ); 
            if (newasset != null){         
            newasset.addError('Duplicate value found:The Monitoring Site ID you have entered is already associated with this Vendor ' );
            }    
        } 
        
        for (Asset__c asset : [SELECT Unique_Asset__c FROM Asset__c WHERE (type__c='Meter' or recordtypeid=:RectypeId) and Unique_Asset__c!=null and serial_number__c!=null and Status__c='Active' and Unique_Asset__c IN :assetMap.KeySet()]) {                  
            Asset__c newasset = assetMap.get(asset.Unique_Asset__c);
            if (newasset != null){         
            newasset.addError('Can not create duplicate records with Meter type and Serial Number When RecordType= Meter or Type = Meter and Status = Active');
            }    
        }                     
}