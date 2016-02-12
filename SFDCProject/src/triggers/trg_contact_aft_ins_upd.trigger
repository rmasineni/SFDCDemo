trigger trg_contact_aft_ins_upd on Contact (after insert, after update) {
Boolean skipValidations = False;
skipValidations = SkipTriggerValidation.performTriggerValidations();
if(skipValidations == false){
  
Map<Id, Id> mapConIdToSPOCId = new Map<Id, Id>();
Map<Id, String> mapConIdToSPOCEmail = new Map<Id, String>();
Set<Id> ConIds = new Set<Id>();
Map<Id, Id> mapConIdToAcctId = new Map<Id, Id>();
Map<Id, String> mapConIdName = new Map<Id, String>();
String headerURL;
String footerURL;
for(Contact c:Trigger.New)
{
    if((c.Application_Status__c == 'Received' 
        && c.Sells_Sunrun__c == 'Yes'
        && c.Sells_in_CA__c == 'Yes'
        && c.active__c == true)
        && (Trigger.isInsert    
            || (Trigger.isUpdate 
                && (   Trigger.oldMap.get(c.Id).Application_Status__c == null
                    || Trigger.oldMap.get(c.Id).Application_Status__c == ''
                    || c.Application_Status__c != Trigger.oldMap.get(c.Id).Application_Status__c))))
    {    
       ConIds.add(c.Id);
       mapConIdToAcctId.put(c.Id, c.AccountId);
       //
    }      
}
//
if(!ConIds.isEmpty())
{   
       for(Document d:[select id, Body, Name, Url from Document 
                        where Name in ('hearder-cslb','footer-cslb')
                          and FolderId in (select id from Folder where Name = 'Letterheads')])
       {
          if(d.Name == 'hearder-cslb')
          {
              //headerURL = d.Url;
              headerURL = d.Id;  //EncodingUtil.base64encode(d.Body);             
          }
          if(d.Name == 'footer-cslb')
          {
              footerURL = d.Id; //EncodingUtil.base64encode(d.Body);
          }          
       }    
       
      for(Contact c:[select id, Name, Account.Single_Point_of_Contact__c, active__c,Application_Status__c, Account.Single_Point_of_Contact__r.Email from Contact where id in :ConIds])
      {
        if(c.active__c == FALSE && c.Application_Status__c == 'Received')
            continue;
         
         mapConIdToSPOCEmail.put(c.Id, c.Account.Single_Point_of_Contact__r.Email);
         mapConIdToSPOCId.put(c.Id, c.Account.Single_Point_of_Contact__c);
         mapConIdName.put(c.Id, c.Name);
      } 
    
      Id emailfromid = null;
      for(OrgWideEmailAddress owea:[select Id from OrgWideEmailAddress where Address = 'sunrunhelp@sunrunhome.com'])
      {
         emailfromid = owea.Id;
      }         
    
      /*Map<String, Id> mapTemplateNameToId = new Map<String, Id>();
      //
      for(EmailTemplate et:[Select Id, Name From EmailTemplate where Name in ('CSLB Application Receipt Email to SPOC')])
      {
          mapTemplateNameToId.put(et.Name, et.Id);
      }*/   
    
    for(Id conid:mapConIdToSPOCId.keySet())
    {       
       Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();               
       //mail.setTemplateId(mapTemplateNameToId.get('CSLB Application Receipt Email to SPOC'));  
       // Target must be user, contact, or lead id.
       mail.setOrgWideEmailAddressId(emailfromid);        
       // DO NOT USE TARGET OBJECT ID
       // System.Debug('Target Object ID: ' + mapConIdToSPOCId.get(conid));
       // mail.setTargetObjectId(conid); //mapConIdToSPOCId.get(conid));                      
       String conname = '';
       if(mapConIdName.get(conid) != null)
       {
          conname = mapConIdName.get(conid);
       }
       String strHtmlBody = '';
       //
       String instanceurl = System.URL.getSalesforceBaseUrl().toExternalForm();
       String orgid = UserInfo.getOrganizationId();
       //
       strHtmlBody += '<img src="' + instanceurl + '/servlet/servlet.ImageServer?id=' + headerURL + '&oid=' + orgid + '"></img>';
       strHtmlBody += '<p>Hello,</p>'; 
       strHtmlBody += '<p>Thank you for providing the CSLB application, coversheet, and check for ' + conname + '.<br/>';
       strHtmlBody += 'This e-mail confirms that ' + conname + ' now has access to the Sunrun Proposal Tool and<br/>';
       strHtmlBody += 'has two weeks to pass the accreditation exam.</p>'; 
       strHtmlBody += '<p>Best,<br/>';
       strHtmlBody += 'Sunrun Partner Concierge</p>';
       strHtmlBody += '<img src="' + instanceurl + '/servlet/servlet.ImageServer?id=' + footerURL + '&oid=' + orgid + '"></img>';
       mail.setHtmlBody(strHtmlBody);
       //   <img src="data:image/jpeg:base64, {!theBody}"/>
       //   https://c.cs17.content.force.com/servlet/servlet.ImageServer?id=015g00000000aWW&oid=00Dg00000004s0t&lastMod=1354744371000
       //
       // To assist in getting the merge fields, set the what id.
       mail.setWhatId(mapConIdToAcctId.get(conid));
       mail.setSaveAsActivity(true);
       mail.setSubject('Sunrun received CSLB application for ' + conname + '.');
       String emailaddr = '';
       System.Debug('EMAIL ADDR: ' + mapConIdToSPOCEmail.get(conid));
       if(mapConIdToSPOCEmail.get(conid) != null)
       {
              emailaddr = mapConIdToSPOCEmail.get(conid);
              List<String> listEmail = new List<String>();
              listEmail.add(emailaddr);
              //mail.setToAddresses(listEmail);
              mail.setTargetObjectId(mapConIdToSPOCId.get(conid)); //mapConIdToSPOCId.get(conid));  
       }
       //           
       try{
          if(!PRMContactUtil.emailidssent.Contains(conid))
          {
             Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});
             PRMContactUtil.emailidssent.add(conid);
          }                  
       }
       catch(Exception e){     
          System.Debug('Invalid email address: ' + emailaddr);
       }        
        
    }       
}
//

Set<Id> payableConIds = new Set<Id>();
Set<Id> notPayableConIds = new Set<Id>();
Map<Id, Boolean> mapConIdStopPayment = new Map<Id, Boolean>();

for(Contact contObj:Trigger.New){
    if(Trigger.isInsert || 
    (Trigger.isUpdate && contObj.Stop_Payment__c != Trigger.oldMap.get(contObj.Id).Stop_Payment__c)){
        if(contObj.Stop_Payment__c == false){
            payableConIds.add(contObj.Id);
            mapConIdStopPayment.put(contObj.Id, false);
        }else if(contObj.Stop_Payment__c == true){
            notPayableConIds.add(contObj.Id);
            mapConIdStopPayment.put(contObj.Id, true);
        }
    }
}

List<Referral_Input__c> ReferralList = new List<Referral_Input__c>();

//Payable
if(!mapConIdStopPayment.isEmpty()){
    for(Referral_Input__c Referral : [select id, Name, Milestone_1_Status__c, Milestone_2_Status__c, Milestone_3_Status__c,Referrer_Status_1__c,Referrer_Status_2__c,Referrer_Status_3__c,
                                        Referee_Status_1__c,Referee_Status_2__c,Referee_Status_3__c,Source_Contact_Id__c,Target_Contact_Id__c from Referral_Input__c 
                                        where (Source_Contact_Id__c in :mapConIdStopPayment.keyset() OR Target_Contact_Id__c in :mapConIdStopPayment.keyset()) and (Milestone_1_Status__c = :Label.ReferralReadyForPayment OR  
                                                                                             Milestone_2_Status__c = :Label.ReferralReadyForPayment OR 
                                                                                             Milestone_3_Status__c = :Label.ReferralReadyForPayment )]){
        //Qualify for payment
        if(mapConIdStopPayment.get(Referral.Source_Contact_Id__c) == false && Referral.Milestone_1_Status__c == Label.ReferralReadyForPayment && (Referral.Referrer_Status_1__c == null || Referral.Referrer_Status_1__c == Label.ReferralReadyForPayment || Referral.Referrer_Status_1__c == Label.ReferralStopPayment)){
            Referral.Referrer_Status_1__c = Label.ReferralReadyForPayment;
        }   
    
        if(mapConIdStopPayment.get(Referral.Source_Contact_Id__c) == false && Referral.Milestone_2_Status__c == Label.ReferralReadyForPayment && (Referral.Referrer_Status_2__c == null  || Referral.Referrer_Status_2__c == Label.ReferralReadyForPayment  || Referral.Referrer_Status_2__c == Label.ReferralStopPayment)){
            Referral.Referrer_Status_2__c = Label.ReferralReadyForPayment;
        }
        
        if(mapConIdStopPayment.get(Referral.Source_Contact_Id__c) == false && Referral.Milestone_3_Status__c == Label.ReferralReadyForPayment && (Referral.Referrer_Status_3__c == null  || Referral.Referrer_Status_3__c == Label.ReferralReadyForPayment  || Referral.Referrer_Status_3__c == Label.ReferralStopPayment)){
            Referral.Referrer_Status_3__c = Label.ReferralReadyForPayment;
        }
        
        if(mapConIdStopPayment.get(Referral.Target_Contact_Id__c) == false && Referral.Milestone_1_Status__c == Label.ReferralReadyForPayment && (Referral.Referee_Status_1__c == null  || Referral.Referee_Status_1__c == Label.ReferralReadyForPayment  || Referral.Referee_Status_1__c == Label.ReferralStopPayment)){
            Referral.Referee_Status_1__c = Label.ReferralReadyForPayment;
        }
        
        if(mapConIdStopPayment.get(Referral.Target_Contact_Id__c) == false && Referral.Milestone_2_Status__c == Label.ReferralReadyForPayment && (Referral.Referee_Status_2__c == null  || Referral.Referee_Status_2__c == Label.ReferralReadyForPayment  || Referral.Referee_Status_2__c == Label.ReferralStopPayment)){
            Referral.Referee_Status_2__c = Label.ReferralReadyForPayment;
        }
        
        if(mapConIdStopPayment.get(Referral.Target_Contact_Id__c) == false && Referral.Milestone_3_Status__c == Label.ReferralReadyForPayment && (Referral.Referee_Status_3__c == null  || Referral.Referee_Status_3__c == Label.ReferralReadyForPayment  || Referral.Referee_Status_3__c == Label.ReferralStopPayment)){
            Referral.Referee_Status_3__c = Label.ReferralReadyForPayment;
        }
        
        //stop payment
        if(mapConIdStopPayment.get(Referral.Source_Contact_Id__c) == true && Referral.Milestone_1_Status__c == Label.ReferralReadyForPayment && (Referral.Referrer_Status_1__c == null || Referral.Referrer_Status_1__c == Label.ReferralReadyForPayment || Referral.Referrer_Status_1__c == Label.ReferralStopPayment)){
            Referral.Referrer_Status_1__c = Label.ReferralStopPayment;
        }
        
        if(mapConIdStopPayment.get(Referral.Source_Contact_Id__c) == true && Referral.Milestone_2_Status__c == Label.ReferralReadyForPayment && (Referral.Referrer_Status_2__c == null || Referral.Referrer_Status_2__c == Label.ReferralReadyForPayment || Referral.Referrer_Status_2__c == Label.ReferralStopPayment)){
            Referral.Referrer_Status_2__c = Label.ReferralStopPayment;
        }
        
        if(mapConIdStopPayment.get(Referral.Source_Contact_Id__c) == true && Referral.Milestone_3_Status__c == Label.ReferralReadyForPayment && (Referral.Referrer_Status_3__c == null || Referral.Referrer_Status_3__c == Label.ReferralReadyForPayment || Referral.Referrer_Status_3__c == Label.ReferralStopPayment)){
            Referral.Referrer_Status_3__c = Label.ReferralStopPayment;
        }
        
        if(mapConIdStopPayment.get(Referral.Target_Contact_Id__c) == true && Referral.Milestone_1_Status__c == Label.ReferralReadyForPayment && (Referral.Referee_Status_1__c == null  || Referral.Referee_Status_1__c == Label.ReferralReadyForPayment  || Referral.Referee_Status_1__c == Label.ReferralStopPayment)){
             Referral.Referee_Status_1__c = Label.ReferralStopPayment;
        }
        
        if(mapConIdStopPayment.get(Referral.Target_Contact_Id__c) == true && Referral.Milestone_2_Status__c == Label.ReferralReadyForPayment && (Referral.Referee_Status_2__c == null  || Referral.Referee_Status_2__c == Label.ReferralReadyForPayment  || Referral.Referee_Status_2__c == Label.ReferralStopPayment)){
             Referral.Referee_Status_2__c = Label.ReferralStopPayment;
        }
        
        if(mapConIdStopPayment.get(Referral.Target_Contact_Id__c) == true && Referral.Milestone_3_Status__c == Label.ReferralReadyForPayment && (Referral.Referee_Status_3__c == null  || Referral.Referee_Status_3__c == Label.ReferralReadyForPayment  || Referral.Referee_Status_3__c == Label.ReferralStopPayment)){
            Referral.Referee_Status_3__c = Label.ReferralStopPayment;
        }
        
        ReferralList.add(Referral);
            
    }
    
}

List<Referral_Input__c> updateReferral = new List<Referral_Input__c>();
Set<Referral_Input__c> updReferralset = new Set<Referral_Input__c>();

if(ReferralList.size() > 0){
    for(Referral_Input__c referral : ReferralList){
        if(updReferralset.add(referral)){
            updateReferral.add(referral);
        }
    }
    if(updateReferral.size() > 0){
        update updateReferral;
    }
}

}
}