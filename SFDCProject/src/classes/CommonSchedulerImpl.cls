/**
 * We have more and more batch jobs which needs to be executed every 5 minutes. Each time such job needs to be executed, we would need 12 scheduled jobs
 * and hence this common scheduler was created to be able to kick off multiple batch jobs depending on their needs.
 */
public class CommonSchedulerImpl implements Schedulable, CommonScheduler {
	
    //This helps to identify which minute run we are currently under. This is required
    //because there may be a delay before salesforce kicks off a job. For ex., instead of 0th min
    //if salesforce kicks off at 1 min, then all jobs depending on time 0 will not run.
    //
    //Using this we can ensure that if a job is scheduled to run at 0th min, it will run
    //as part of that common scheduler job. By default it will be -1, meaning time calculation
    //is based on the current minute.
    private Integer minsScheduler = -1;
    
    public static Map<String, Integer> NameToValueMap = new Map<String, Integer>{
        'JAN' => 1,
        'FEB' => 2,
        'MAR' => 3,
        'APR' => 4,
        'MAY' => 5,
        'JUN' => 6,
        'JUL' => 7,
        'AUG' => 8,
        'SEP' => 9,
        'OCT' => 10,
        'NOV' => 11,
        'DEC' => 12,
        'SUN' => 1,
        'MON' => 2,
        'TUE' => 3,
        'WED' => 4,
        'THU' => 5,
        'FRI' => 6,
        'SAT' => 7
    };
    
    public CommonSchedulerImpl() {
    }
    
    public CommonSchedulerImpl(Integer minsScheduler) {
        this.minsScheduler = minsScheduler;
    }
    
    public void execute(SchedulableContext sc) {
        System.debug('Statring the ' + minsScheduler + ' minute Common Scheduler Job');
		Map<String, Common_Scheduler__c> jobs = Common_Scheduler__c.getAll();
		
        DateTime currentDateTime = DateTime.now();
        
        //Set the minutes to the current minute interval.
        DateTime triggerDateTime = DateTime.newInstanceGmt(currentDateTime.yearGmt(), 
			currentDateTime.monthGmt(), currentDateTime.dayGmt(), 
			currentDateTime.hourGmt(), (minsScheduler==-1?currentDateTime.minuteGmt():minsScheduler), 0);
        
        System.debug('Date time used to check the cron matching. ' + triggerDateTime);
        
        //Get all currently running apex jobs. If the job we are trying to kick off, is already runnning, then we will skip executing it.
        for (Common_Scheduler__c job : jobs.values()) {
            try {
                System.debug('Processing job ' + job);
                
                if (!job.Enabled__c) {
                    job.Message__c = getMessage('Job is disabled and hence not running it.');
                    System.debug('Job is disabled and hence not running it [' + job.name + ']');
                    continue;
                }
				
        		//Check if job is ready to be triggered or run is not overriden
                if (!job.Eligible_To_Run__c && !isTimeMatches(getCronPattern(job), triggerDateTime)) {
                    System.debug('Job is not ready to be trigged based on the run frequency [' + job.name + ']');
                    continue;
                }

				runJob(job);
                
            } catch (Exception e) {
                job.Message__c = getMessage(e.getMessage());
                System.debug('Error while executing the batch job ' + job + ' [' + e + ']');
            }
        }
        
        new DbChangesWoSharing().add(jobs.values()).save();
    }
    
    public List<AsyncApexJob> queryActiveJobs(String className) {
        return [SELECT 
                	Id,
					ApexClass.Name,
                	CreatedDate
                FROM AsyncApexJob 
                where Status != 'Completed' 
                	and Status != 'Failed' 
                	and Status != 'Aborted' 
                	and (JobType = 'BatchApex' OR JobType = 'Queueable') 
                	and ApexClass.Name = :className
       ];
    }
    
    public static void deleteJobs() {
        //Get the ids for IKnock batch jobs
        System.debug('Deleting the Common Scheduler Jobs');
        List<CronTrigger> cronJobs = [SELECT Id FROM CronTrigger where CronJobDetailId in (SELECT Id FROM CronJobDetail where name like 'Common Scheduler%')];
        for (CronTrigger cronJob : cronJobs) {
            System.abortJob(cronJob.id);
        }
        System.debug('All Common Scheduler Jobs are successfully deleted');
    }

    public static void scheduleJobs() {
    
        deleteJobs();
    	
        System.debug('Scheduling Common Scheduler Jobs to run every 1 minute');
        for (Integer i = 0; i < 60; i++) {
            System.schedule('Common Scheduler - ' + (i<10?('0' + i):''+i) + ' Min', '0 ' + i + ' * * * ?', new CommonSchedulerImpl(i));
        }

        System.debug('All Common Scheduler Jobs are successfully scheduled');
    }

    public Object createInstance(String clz) {
        Type typ = Type.forName(clz);
        Object instance = null;
        if (typ != null) {
            instance = typ.newInstance();
        }
        
        if (instance == null) {
            throw new BusinessException('Couldn\'t successfully instantiate an object for class ' + clz + '. Please check if Class name is correct, is compilable and current user has access.');
        }
        
        return instance;
    }
    
    /**
     * Parses the given cron pattern and determines if job is ready to kick off.
     * Cron pattern is based on https://www.salesforce.com/us/developer/docs/apexcode/Content/apex_scheduler.htm
     * 
     * Some changes over what is standard with Salesforce.
     * 
     * Value of seconds is not evaluated and that segment is ignored.
     * Special chars L, W, #, / are not supported.
     */ 
    public Boolean isTimeMatches(String cronPattern, Datetime currentTime) {
        
        System.debug('Matching cron pattern ' + cronPattern + ' with datetime ' + currentTime);
        
        if (cronPattern == null) {
            return false;
        }
        
        String[] segments = cronPattern.split(' ');
        if (segments.size() != 7) {
            throw new BusinessException('Invalid Cron pattern [' + cronPattern + ']. It should contain exactly 7 values');
        }
        
        //Ignore the seconds.
        
        //Minutes should match the currently being executed minutes.
        if (matchSegment(segments[1], formatInPacificTz(currentTime, 'm'))
	    		&& matchSegment(segments[2], formatInPacificTz(currentTime, 'H'))
           		&& matchSegment(segments[3], formatInPacificTz(currentTime, 'd'))
            	&& matchSegment(segments[4], formatInPacificTz(currentTime, 'M'))
            	&& matchSegment(segments[5], formatInPacificTz(currentTime, 'EEE'))
	            && matchSegment(segments[6], formatInPacificTz(currentTime, 'yyyy'))) {
            return true;
        }

        return false;
    }
    
    public String formatInPacificTz(DateTime dt, String format) {
        return dt.format(format, 'America/Los_Angeles');
    }
    
    public Boolean matchSegment(String segment, String inputValue) {
        segment = segment.toUpperCase();
        inputValue = inputValue.toUpperCase();
        Integer value = NameToValueMap.containsKey(inputValue)?NameToValueMap.get(inputValue):Integer.valueOf(inputValue);
        
        //If * or ?, then we treat it as matching.
        if (segment == '*' || segment == '?') {
            return true;
        }
        
        List<Integer> segmentValues = new List<Integer>();
        String[] subSegments = segment.split(',');
        for (String subsegment : subSegments) {
            
            if (subsegment.indexOf('-') >= 0) {
            	String[] ranges = subsegment.split('-');
                Integer lower = NameToValueMap.containsKey(ranges[0])?NameToValueMap.get(ranges[0]):Integer.valueOf(ranges[0]);
                Integer higher = NameToValueMap.containsKey(ranges[1])?NameToValueMap.get(ranges[1]):Integer.valueOf(ranges[1]);
                
                for (Integer i = lower; i <= higher; i++) {
                    segmentValues.add(i);
                }
            } else {
                segmentValues.add(Integer.valueOf(subsegment));
            }
        }
        
        for (Integer segmentValue : segmentValues) {
            if (value == segmentValue) {
                return true;
            }
        }
        
        return false;
    }
    
    public String getCronPattern(Common_Scheduler__c job) {
		String cronPattern;
        if (job.Run_Frequency__c == 'Every Min') {
            job.Run_Frequency__c = 'Every Min';
            cronPattern = '0 * * * * * *';

        } else if (job.Run_Frequency__c == 'Every 5 Mins') {
            job.Run_Frequency__c = 'Every 5 Mins';
            cronPattern = '0 0,5,10,15,20,25,30,35,40,45,50,55 * * * * *';

        } else if (job.Run_Frequency__c == 'Every 10 Mins') {
            job.Run_Frequency__c = 'Every 10 Mins';
            cronPattern = '0 0,10,20,30,40,50 * * * * *';

        } else if (job.Run_Frequency__c == 'Every 15 Mins') {
            job.Run_Frequency__c = 'Every 15 Mins';
            cronPattern = '0 0,15,30,45 * * * * *';

        } else if (job.Run_Frequency__c == 'Every 30 Mins') {
            job.Run_Frequency__c = 'Every 30 Mins';
            cronPattern = '0 0,30 * * * * *';

        } else if (job.Run_Frequency__c == 'Every Hr') {
            job.Run_Frequency__c = 'Every Hr';
            cronPattern = '0 0 * * * * *';

        } else if (job.Run_Frequency__c == 'Every 2 Hrs') {
            job.Run_Frequency__c = 'Every 2 Hrs';
            cronPattern = '0 0 0,2,4,6,8,10,12,14,16,18,20,22 * * * *';

        } else if (job.Run_Frequency__c == 'Every 4 Hrs') {
            job.Run_Frequency__c = 'Every 4 Hrs';
            cronPattern = '0 0 0,4,8,12,16,20 * * * *';

        } else if (job.Run_Frequency__c == 'Every 6 Hrs') {
            job.Run_Frequency__c = 'Every 6 Hrs';
            cronPattern = '0 0 0,6,12,18 * * * *';

        } else if (job.Run_Frequency__c == 'Every 12 Hrs') {
            job.Run_Frequency__c = 'Every 12 Hrs';
            cronPattern = '0 0 0,12 * * * *';

        } else if (job.Run_Frequency__c == 'Every Day') {
            job.Run_Frequency__c = 'Every Day';
            cronPattern = '0 0 0 * * * *';

        } else if (job.Run_Frequency__c == 'Every Week') {
            job.Run_Frequency__c = 'Every Week';
            cronPattern = '0 0 0 SAT * * *';

        } else if (job.Run_Frequency__c == 'Cron') {
            job.Run_Frequency__c = 'Cron';
            cronPattern = job.Cron_Trigger__c;
            
        } else if (job.Run_Frequency__c == 'On Demand') {
            job.Run_Frequency__c = 'On Demand';
            cronPattern = null;

        } else {
            throw new BusinessException('Invalid run frequency [' + job.Run_Frequency__c + ']');
        }
        
        return cronPattern;
    }
    
    public String runJob(Common_Scheduler__c job) {
        String jobId = null;
        System.debug('Running job ' + job);
        
        if (!job.Enabled__c) {
            job.Message__c = getMessage('Job is disabled and hence not running it.');
            System.debug('Job is disabled and hence not running it [' + job.name + ']');
            return null;
        }
        
        if (job.Delay_Until_Time__c != null && job.Delay_Until_Time__c > DateTime.now()) {
            job.Message__c = getMessage('Job\'s configured delay [' + formatDateTime(job.Delay_Until_Time__c) + '] not elapsed and hence not running yet');
            System.debug('Job\'s configured delay not elapsed and hence not running yet [' + job.name + ']');
            return null;
        }
        job.Delay_Until_Time__c = null;
        
        String className = job.Class__c==null?job.Name:job.Class__c;
        List<AsyncApexJob> currentInstances = abortJobsIfRequired(job, queryActiveJobs(className), DateTime.now());
        if (!currentInstances.isEmpty()) {
            String message = getMessage('An instance of this Job is currently being processed and hence not ' 
                                        + 'starting a new one. But job has been marked as Eligible to Run and ' 
                                        + 'will be executed as soon as previous job is completed.');
            job.Message__c = message;
            System.debug(message + ' [' + currentInstances + ']');
            job.Eligible_To_Run__c = true;
            
        } else {
            System.debug('Job is ready to be executed [' + job.name + ']');
            
            Object instance = createInstance(className);
            if (job.Parameters__c != null && instance instanceof CommonSchedulable) {
                CommonSchedulable cs = (CommonSchedulable) instance;
                
                cs.setData(join(new String[]{job.Data1__c, job.Data2__c, job.Data3__c, job.Data4__c, job.Data5__c}, ''));
                
                String[] pairs = job.Parameters__c.split(',');
                for(String pair : pairs) {
                    String[] keyValue = pair.split('=');
                    System.debug('Setting parameter ' + keyValue[0] + '=' + keyValue[1]);
                    cs.setParameter(keyValue[0], keyValue[1]);
                }
            }
            
            if (instance instanceof Queueable) {
                if (instance instanceof CommonBatchable) {
	                System.debug('Queueable job supports batching so going to query the batches. [' + job.name + ']');
                    CommonBatchable commonBatchable = (CommonBatchable) instance;
                    List<List<Id>> batches = commonBatchable.getBatches(Integer.valueOf(job.Batch_Job_Scope__c));
                    System.debug('Found ' + batches.size() + ' batches for job ' + job.name);
                    if (!batches.isEmpty()) {
                        for (List<Id> batch : batches) {
                            commonBatchable = (CommonBatchable) createInstance(className);
                            commonBatchable.setBatch(batch);
                            System.enqueueJob((Queueable) commonBatchable);
                        }
                        job.Message__c = getMessage('Started ' + batches.size() + ' instances of ' + job.name);
                    } else {
                        job.Message__c = getMessage('Found no batches so did not start any jobs for ' + job.name);
                    }
                } else {
                    jobId = System.enqueueJob((Queueable) instance);
                    job.Message__c = getMessage('Started a queueable job with job id ' + jobId);
                }
                
            } else {
                System.debug('Running the batch job. [' + job + ']');
                Database.Batchable<SObject> batchJob = (Database.Batchable<SObject>) instance;
                jobId = Database.executeBatch(batchJob, (Integer) job.Batch_Job_Scope__c);
                job.Message__c = getMessage('Started a batch job with job id ' + jobId);
            }
            
            job.Last_Run_Time__c = DateTime.now();
            job.Eligible_To_Run__c = false;
        }
        
        return jobId;
    }
    
    public Common_Scheduler__c runJobAfterMins(String jobName, Decimal mins) {
        return runJobAfterMins(findOrCreateJob(jobName), mins);
    }

    public Common_Scheduler__c runJobAfterMins(Common_Scheduler__c job, Decimal mins) {
        job.Eligible_To_Run__c = true;
        
        if (mins > 0) {
            DateTime delayTime = DateTime.now().addSeconds(Integer.valueOf(mins * 60));
            
            //If there is already a delay time and if that is later than delay time, then 
            //we will update to delay time else we will leave it as is.
            //This is to ensure that, subsequent updates to delay time, will not just keep pushing 
            //the job to future.
            if (job.Delay_Until_Time__c == null || job.Delay_Until_Time__c.getTime() > delayTime.getTime()) {
	            job.Delay_Until_Time__c = delayTime;                
            }
        } else {
			job.Delay_Until_Time__c = null;
            runJob(job);
        }
        
        update job;
        return job;
    }
    
    public Common_Scheduler__c runJob(String className) {
        return runJobAfterMins(className, -1);
    }
    
    public Common_Scheduler__c findOrCreateJob(String jobName) {
    
        Common_Scheduler__c byJobName = null;
        Common_Scheduler__c byClassName = null;
        
        for (Common_Scheduler__c job : Common_Scheduler__c.getAll().values()) {
            if (job.Name == jobName) {
                byJobName = job;
                break;
            }

            if (job.Class__c == jobName) {
                byClassName = job;
                break;
            }
        }
        
        if (byJobName == null && byClassName == null) {
            Common_Scheduler__c job = new Common_Scheduler__c(Run_Frequency__c='On Demand');
            
            //Max job name length is 38 chars.
            if (jobName.length() <= 38) {
                job.Name = jobName;
            } else {
                job.name = jobName.substring(0, 38);
                job.Class__c = jobName;
            }
            insert job;
            byJobName = job;
        }
		
    	return byJobName==null?byClassName:byJobName;
    }
    
    public String getMessage(String message) {
        return  + formatDateTime(DateTime.now()) + ' ' + message;
    }
    
    public String formatDateTime(DateTime dt) {
        return dt.format('yyyy/MM/dd hh:mm:ss a z', 'America/Los_Angeles');
    }
    
    public String join(List<String> strings, String separator){
        if(strings == null){
            return null;
        }
        if (separator == null) {
            separator = ', ';
        }
        String joinedString = null;
        for(String value : strings) {
            if (value == null) {
                continue;
            }
            
            if (value == null) {
                value = '';
            }
            
            if (joinedString == null) {
                joinedString = value;
            } else {
                joinedString += separator + value;
            }
        }
        
        return joinedString;
    }
    
    /**
     * Would go through the instances and configured abort jobs mins. If any of these jobs have
     * been running for more than specified mins, then they will be aborted. Email will be sent
     * with list of jobs aborted. At the end, returns the list of jobs not aborted.
     */
    public List<AsyncApexJob> abortJobsIfRequired(Common_Scheduler__c job, List<AsyncApexJob> currentInstances, DateTime currentTime) {
        Decimal abortMins = job.Abort_After_Mins__c;
        if (abortMins == null || abortMins <= 0) {
            return currentInstances;
        }
        
        List<String> jobsAborted = new List<String>();
        List<AsyncApexJob> jobsNotAborted = new List<AsyncApexJob>();
        for (AsyncApexJob currentInstance : currentInstances) {
            if (currentInstance.CreatedDate.addMinutes(Integer.valueOf(abortMins)) < currentTime) {
                jobsAborted.add('Job ' + currentInstance.ApexClass.Name + ' [Id=' 
					+ currentInstance.id + ', SubmittedDate=' 
					+ formatDateTime(currentInstance.CreatedDate) + ', RunTime=' + diffInMins(currentInstance.CreatedDate, currentTime) + ']');
                System.abortJob(currentInstance.id);
            } else {
                jobsNotAborted.add(currentInstance);
            }
        }
        
        if (!jobsAborted.isEmpty()) {
            String body = 'Common Scheduler has aborted following jobs as their' 
                + ' running time is more than configured Abort After Mins [' + job.Abort_After_Mins__c + ']';
            for (String jobAborted : jobsAborted) {
                body += '\n\n' + jobAborted;
            }
            
            List<String> emailsAddrs = Sf.settingsService.getStringList(' AdminNotificationEmails', new List<String>());
            if (!emailsAddrs.isEmpty()) {
                sendEmail(emailsAddrs, 'Common Scheduler: ' + jobsAborted.size() + ' jobs aborted', body);
            }
        }
        
        return jobsNotAborted;
    }
    
    public void sendEmail(List<String> toAddresses, String subject, String htmlBody) {
    
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setSubject(subject);
       	mail.setHtmlBody(htmlBody);
       	mail.setPlainTextBody(htmlBody);

        mail.setToAddresses(toAddresses);
        
		Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
    }

    /**
     * Calculates the difference between two datetimes in minutes. If either of dates is null, then response is null as well.
     */ 
    public Integer diffInMins(DateTime d1, DateTime d2)  {
        if (d1 == null || d2 == null) {
            return null;
        }
		
		Integer diff = (Integer) Math.abs((d1.getTime() - d2.getTime()) / (1000 * 60));
        System.debug('Difference between ' + d1 + ' and ' + d2 + ' is ' + diff + ' mins');
        return diff;
    }
    
    public Common_Scheduler__c markJobEligibleToRun(String jobName) {
        Common_Scheduler__c job = findOrCreateJob(jobName);
        if (!job.Eligible_To_Run__c) {
            job.Eligible_To_Run__c = true;
            
            //If we need to mark the job as eligible, then we might as well clear the
            //delay time so that job will be run in in next iteration.
            job.Delay_Until_Time__c = null;
            DbChangesWosharing.save(job);
        }
        
        return job;
    }
    
}