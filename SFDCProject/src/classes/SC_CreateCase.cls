public with sharing class SC_CreateCase {
public id scid{set;get;}
public ServiceContract sc{set;get;}
public case c {get;set;}
public string scname{set;get;}
public string tefund{set;get;}
public string cucont{set;get;}
public string acname{set;get;}
public string installpartner{set;get;}
public boolean disableInv{set;get;}
public string picklist{set;get;}
public date prepaydate{set;get;}
private id recid;
    public SC_CreateCase(ApexPages.StandardController controller) {
    	recid=[select id from recordtype where SobjectType='Case' and name='Invoice' limit 1].id;    
        this.c= (Case)controller.getRecord(); 
    if(c!=null){
         try{  
         	c=[SELECT Service_Contract__r.id,AccountId,Account_Name__c,subject,Amount__c,CaseNumber,ClosedDate,CreatedById,CreatedDate,Customer_Contact__c,Description,External_ID__c,Service_Contract__c,LastModifiedById,LastModifiedDate,Partner_Recepient__c,Reason,RecordTypeId,Related_To__c,Prepayment_Date__c,Status,Subset_Reasons__c,TE_Fund_Name__c,Transaction_Date__c,Install_Partner__c,Upload_Date__c FROM Case
                where id=:controller.getId() ]; 
                }
         catch(exception e){
            system.debug(e);
             }
         }
         else{
         c=new case();
         }
         
         scid=ApexPages.currentPage().getParameters().get('scid');
         if(scid!=null){
         	sc=[select id,Name,Account.name,Account.id,Contact.name,Install_Partner__c,TE_Fund_name__c,(select prepayment_date__c from service_contract_events__r) from ServiceContract where id=:scid];
            c.Service_Contract__c=sc.id; 
            if(sc.service_contract_events__r.size()>0){
            	prepaydate=sc.service_contract_events__r[0].prepayment_date__c;
            }  
            scname=sc.name;   
            tefund=sc.TE_Fund_name__c;
            cucont=sc.Contact.name;
            acname=sc.Account.name;
            if(sc.Install_Partner__c!=null){
            	account a=[select id,name from account where name=:sc.Install_Partner__c and Ultimate_Parent_Account__c=null limit 1];
				if(a!=null)            	
            	installpartner=a.name;
            }        	
         }  
         else if(c!=null&&c.Service_Contract__c!=null){
         sc=[select id,Name,Account.name,Account.id,Contact.name,Install_Partner__c,TE_Fund_name__c from ServiceContract where id=:c.Service_Contract__c];
            c.Service_Contract__c=sc.id;   
            if(sc.service_contract_events__r.size()>0){
            	prepaydate=sc.service_contract_events__r[0].prepayment_date__c;
            }  
            scname=sc.name;   
            tefund=sc.TE_Fund_name__c;
            cucont=sc.Contact.name;
            acname=sc.Account.name;
            if(sc.Install_Partner__c!=null){
            	account a=[select id,name from account where name=:sc.Install_Partner__c and Ultimate_Parent_Account__c=null limit 1];
				if(a!=null)            	
            	installpartner=a.name;
                  }
              }
    }
              
      public pagereference getInvRec(){        
        system.debug('----reason'+c.Reason);
        system.debug('----param'+picklist);

    if(c.Reason=='Partner'){
    if(sc.Install_Partner__c!=null){
    	account a=[select id,name from account where name=:sc.Install_Partner__c and Ultimate_Parent_Account__c=null limit 1];
    System.debug('sc.Install_Partner__c: ' + a.id);
    c.partner_Recepient__c= a.id;

    }
    }
       
    else{
    c.partner_Recepient__c=null;
  
    }
    system.debug('----id'+c.partner_Recepient__c);
    return null;
   }
   
   public pagereference saveCreate(){           
    if(c.Reason=='--None--' ||c.Reason== null)
    {    
     c.Reason.addError('You must enter a value');
     return null;     
      }                 
   
    if(c.Subset_Reasons__c=='' ||c.Subset_Reasons__c== null){
    c.Subset_Reasons__c.addError('You must enter a value');
                return null;                    
    }
    if(c.Amount__c== null){
    c.Amount__c.addError('You must enter a value');
                return null;                    
    }else {     	   	   
        
    c.recordtypeid=recid;
    c.service_contract__c=sc.id;
    c.Install_Partner__c=sc.Install_Partner__c;
    c.Prepayment_Date__c=prepaydate;
    upsert c;
    PageReference redirect = new PageReference('/'+c.id);
        redirect.setRedirect(true);
        return redirect;        
    }
    return null;
    }
    public PageReference cancel(){
        if(c.id !=null){
        PageReference redirect = new PageReference('/'+c.id);
        redirect.setRedirect(true);
        return redirect;        
        }else{
        PageReference redirect = new PageReference('/'+scid);
        redirect.setRedirect(true);
        return redirect;
        }
        }
         	
         }