/******************************************************************************
    Class Name:CreateCase
    Date: 3/27/2014
    Author:Karthik Ariharapakam
    Description: Creates Case from Generation Asset on click of " Generate Invoice " button. 
*******************************************************************************/
public with sharing class CreateCase {
    public id genid{set;get;}
public Generation_Assets__c gen{set;get;}
public case c {get;set;}
public string genname{set;get;}
public string tefund{set;get;}
public string cucont{set;get;}
public string acname{set;get;}
public date prepaydate{set;get;}
public string installer{set;get;}
public boolean disableInv{set;get;}
public string picklist{set;get;}
private id recid;
    public CreateCase(ApexPages.StandardController controller) {
    recid=[select id from recordtype where SobjectType='Case' and name='Invoice' limit 1].id;    
    this.c= (Case)controller.getRecord(); 
    if(c!=null){
         try{   
         c=[SELECT Generation_Asset__r.id,AccountId,Account_Name__c,Amount__c,CaseNumber,ClosedDate,CreatedById,CreatedDate,Customer_Contact__c,Description,External_ID__c,Generation_Asset__c,LastModifiedById,LastModifiedDate,OwnerId,Partner_Recepient__c,Prepayment_Date__c,Reason,RecordTypeId,Related_To__c,Status,Subset_Reasons__c,TE_Fund_Name__c,Transaction_Date__c,Upload_Date__c FROM Case
         where id=:controller.getId() ];
         }
         catch(exception e){
            system.debug(e);
         }
         }
         else{
         c=new case();
         }  
    genid=ApexPages.currentPage().getParameters().get('genid');
    if(genid!=null){
            gen=[select id,Account_Name__r.id,Customer_Contact__r.name,Installer__r.id,Account_Name__r.name,customer_Contact__c,Account_Name__c,Prepayment_Date__c,TE_Fund_name__c,Installer__c,Installer__r.name,name from Generation_Assets__c where id=:genid];
            //c.Generation_Asset__c=gen.id;
            c.Generation_Asset__c=gen.id;   
            genname=gen.name;   
            tefund=gen.TE_Fund_name__c;
            cucont=gen.Customer_Contact__r.name;
            acname=gen.Account_Name__r.name;
            prepaydate=gen.Prepayment_Date__c;
            installer=gen.Installer__r.name;
            
         } 
          else if(c!=null&&c.Generation_Asset__c!=null){
         gen=[select id,Account_Name__r.id,Customer_Contact__r.name,Installer__r.id,Account_Name__r.name,customer_Contact__c,Account_Name__c,Prepayment_Date__c,TE_Fund_name__c,Installer__c,Installer__r.name,name from Generation_Assets__c where id=:c.Generation_Asset__c];
            //c.Generation_Asset__c=gen.id;
            c.Generation_Asset__c=gen.id;   
            genname=gen.name;   
            tefund=gen.TE_Fund_name__c;
            cucont=gen.Customer_Contact__r.name;
            acname=gen.Account_Name__r.name;
            prepaydate=gen.Prepayment_Date__c;
            installer=gen.Installer__r.name;
         }
    }
    public pagereference getInvRec(){
        
        system.debug('----reason'+c.Reason);
        system.debug('----param'+picklist);
   /* if(c.Reason=='Customer'){
    c.partner_Recepient__c=gen.Account_Name__c;
    disableInv=true;
    }
   
    else if(c.Reason=='Fund'){    
    c.partner_Recepient__c=tefund;
    disableInv=true;
    }
    */
    if(c.Reason=='Partner'){
    c.partner_Recepient__c=gen.Installer__c;
    }
       
    else{
    c.partner_Recepient__c=null;
  
    }
    system.debug('----'+c.partner_Recepient__c);
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
    c.generation_asset__c=gen.id;
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
        PageReference redirect = new PageReference('/'+genid);
        redirect.setRedirect(true);
        return redirect;
        }
        }
     
}