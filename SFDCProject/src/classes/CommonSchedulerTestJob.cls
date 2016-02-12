public class CommonSchedulerTestJob implements Queueable, CommonSchedulable {
	
    public String value {get;set;}
    
    public void execute(QueueableContext context) {
        new BaseClass().sendEmail(new String[]{'santhosh.kumar@sunrun.com'}, value, value);
    }
    
    public void setParameter(String key, String value) {
    	this.value = value;    
    }
}