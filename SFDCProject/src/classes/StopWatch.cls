/**
 * Class implements the functionality to capture the elapsed time to measure the method execution
 * times.
 * 
 * There are two times. Main elapsed time and one sub-elapsed time. Main time can be used to capture
 * overall execution time and sub-elapsed time can be used to capture various methods executing during
 * that overall request.
 */
public class StopWatch {
	
    public DateTime startTime {get;set;}
    public DateTime subStartTime {get;set;}
    public List<ElapsedTimeEntry> timeEntries = new List<ElapsedTimeEntry>();
    
    public class ElapsedTimeEntry {
        public String code {get;set;}
        public Integer elapsedTime {get;set;}
        
        public ElapsedTimeEntry(String code, Integer elapsedTime) {
            this.code = code;
            this.elapsedTime = elapsedTime;
        }
    }
    
    public StopWatch() {
        startTime = DateTime.now();
        subStartTime = startTime;
    }
    
    /**
     * Returns the number of milli seconds which are elapsed since this object was created or since last reset.
     */ 
    public Integer elapsedTime() {
        return (Integer) (DateTime.now().getTime() - startTime.getTime());
    }
	
    /**
     * Returns the number of milliseconds elapsed since creation of this object, or since last rest or since
     * last marking of subelapsed time.
     */
    public Integer subElapsedTime() {
        return (Integer) (DateTime.now().getTime() - subStartTime.getTime());
    }
    
    /**
     * Resets the main elapsed and sub elapsed time.
     */
    public void reset() {
        startTime = DateTime.now();
        subStartTime = DateTime.now();
    }
    
    /**
     * Saves the current sub-elapsed time and resets it. This doesn't change the main elapsed time.
     */
    public void markSubElapsedTime() {
        timeEntries.add(new ElapsedTimeEntry(getCurrentClassMethodName(), subElapsedTime()));
        subStartTime = DateTime.now();
    }
    
    public String getCurrentClassMethodName() {
        try {
            String classMethodLine = new SystemException().getStackTraceString().split('\n')[2];
            String[] tokens = classMethodLine.split(':');
            String[] subTokens = tokens[0].split('\\.');
            if (subTokens.size() <= 1) {
                return 'Unknown';
            } else if (subTokens.size() <= 2) {
                return subTokens[1];
            } else {
                return subTokens[1]  + '.' + subTokens[2];
            }
        } catch (Exception e) {
        	System.debug('Exception while getting the current class and method name ' + e + ' ' + e.getStackTraceString());
            return 'Unknown';
        }
    }
}