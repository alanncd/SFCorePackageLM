global with sharing class Lmr_SmrtPhoneScheduled_sch Implements Schedulable{
    public String scheduledRecordId;
    public String scheduledSmsTemplate;
    
    global void execute(SchedulableContext sc)
        {
           // Lmr_SmrtPhone_cls.smartPhoneCallout(scheduledRecordId,scheduledSmsTemplate);
           System.debug('delete this class');
        }
    
    public Lmr_SmrtPhoneScheduled_sch (String recordId,String idTemplate){
        if ( scheduledRecordId == null ) {
            scheduledRecordId =recordId;
        }
        if ( scheduledSmsTemplate == null ) {
            scheduledSmsTemplate =idTemplate;
        }
    }
}