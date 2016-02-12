@isTest(SeeAllData=true)
public with sharing class UnitTest_trg_after_ins_resetCountOnLead{
    static testmethod void UnitTest_trg_after_ins_resetCountOnLead(){
    lead l=new lead(lastname='tedsfdsdfs',company='sfsfs');
    insert l;
    Campaign c=[select id from campaign limit 1];
    CampaignMember cm=new CampaignMember(campaignid=c.id,leadid=l.id);
    insert cm;
    }
    }