global class doMarketAssignmentsSynchronous {
    webservice static void doMarketAssignments(Id leadid){
         Set<Id> leadSet=new Set<Id>();
         leadSet.add(leadid);
         checkRecursive.leadsetIds.add(leadid);
         Lead_Assignment.Lead_Assignment_Immediate(leadSet);
    }
}