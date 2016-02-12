@isTest(SeeAllData=true)
public with sharing class UnitTest_trg_aft_inst_UpdateCampaignNum {
      static testmethod void UnitTest_trg_aft_inst_UpdateCampaignNum(){     
      Lead l=new lead(lastname='Testvvs',company='test');
      insert l;
      Test.starttest();
      //CampaignMember cm=new CampaignMember(leadid=l.id,campaignid=system.label.Five9_CampaignId);
      //insert cm;
      task t=new task(type='Call',whoid=l.id,Five9__Five9Campaign__c='Campaign');
      insert t;
      Test.stoptest();
      }
    }