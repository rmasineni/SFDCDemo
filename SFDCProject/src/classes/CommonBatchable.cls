public interface CommonBatchable {
	List<List<Id>> getBatches(Integer maxBatches);
    void setBatch(List<Id> batchIds);
}