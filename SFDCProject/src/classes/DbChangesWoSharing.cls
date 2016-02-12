public without sharing class DbChangesWoSharing extends DbChanges {

    public override void updateChanges(List<Sobject> sobjs) {
		Database.update(sobjs, true);
    }

    public override void insertChanges(List<Sobject> sobjs) {
		Database.insert(sobjs, true);
    }

    public override void deleteChanges(List<Sobject> sobjs) {
        //For delete we will go with partial success as it can errors out if entity is already
        //delete.
		Database.delete(sobjs, false);
    }

    public static void save(List<Sobject> sobjs) {
        new DbChangesWoSharing().add(sobjs).save();
    }

    public static void saveIgnoreExceptions(List<Sobject> sobjs) {
        try {
			save(sobjs);            
        } catch (Exception e) {
            System.debug('Exception while saving the records ' + sobjs + ' ' + e.getStackTraceString());
        }
    }

    public static void save(Sobject sobj) {
        new DbChanges().add(sobj).save();
    }
}