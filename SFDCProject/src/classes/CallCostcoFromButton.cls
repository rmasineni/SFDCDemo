public without sharing class CallCostcoFromButton extends BaseClass{
    public void CallCostco(List<Lead> lead_list){
        enqueueJobWithCheck(new CostcoLeadSyncJob(getUniqueIdList(lead_list)));
    }
}