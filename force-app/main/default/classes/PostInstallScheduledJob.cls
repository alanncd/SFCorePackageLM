global with sharing class PostInstallScheduledJob implements InstallHandler{

    
        global void onInstall(InstallContext context) {
         // List<CronTrigger> jobsToAbort = [select Id,state from CronTrigger where CronJobDetail.JobType = '7' AND State != 'DELETED' LIMIT 149];
			
     List<CronTrigger> jobsToAbort = [select Id,CronJobDetail.Name from CronTrigger where CronJobDetail.JobType = '7'
     AND (CronJobDetail.Name='Cadence SMS' OR CronJobDetail.Name LIKE '%Cadence SMS%' OR CronJobDetail.Name LIKE '%Cadence%' OR CronJobDetail.Name='Cadence Task' OR CronJobDetail.Name='Cadence Email') LIMIT 140];
	for (CronTrigger job : jobsToAbort) { System.abortJob(job.Id); }
           try{
               /*
System.schedule('Cadence Email test 1', '0 05 8-23 ? * MON,TUE,WED,THU,FRI,SAT,SUN *', new batchCadenceEmail());
System.schedule('Cadence Email test 2', '0 10 8-23 ? * MON,TUE,WED,THU,FRI,SAT,SUN *', new batchCadenceEmail());
System.schedule('Cadence Email test 3', '0 15 8-23 ? * MON,TUE,WED,THU,FRI,SAT,SUN *', new batchCadenceEmail());
System.schedule('Cadence Email test 4', '0 20 8-23 ? * MON,TUE,WED,THU,FRI,SAT,SUN *', new batchCadenceEmail());
System.schedule('Cadence Email test 5', '0 25 8-23 ? * MON,TUE,WED,THU,FRI,SAT,SUN *', new batchCadenceEmail());
System.schedule('Cadence Email test 6', '0 30 8-23 ? * MON,TUE,WED,THU,FRI,SAT,SUN *', new batchCadenceEmail());
System.schedule('Cadence Email test 7', '0 35 8-23 ? * MON,TUE,WED,THU,FRI,SAT,SUN *', new batchCadenceEmail());
System.schedule('Cadence Email test 8', '0 45 8-23 ? * MON,TUE,WED,THU,FRI,SAT,SUN *', new batchCadenceEmail());
System.schedule('Cadence Email test 9', '0 50 8-23 ? * MON,TUE,WED,THU,FRI,SAT,SUN *', new batchCadenceEmail());
System.schedule('Cadence Email test 10', '0 55 8-23 ? * MON,TUE,WED,THU,FRI,SAT,SUN *', new batchCadenceEmail());
System.schedule('Cadence Email test 11', '0 00 8-23 ? * MON,TUE,WED,THU,FRI,SAT,SUN *', new batchCadenceEmail());
*/
               
System.schedule('Cadence SMS 0', '0 0 8-21 ? * MON,TUE,WED,THU,FRI,SAT,SUN *', new batchCadence());
System.schedule('Cadence SMS 10', '0 10 8-21 ? * MON,TUE,WED,THU,FRI,SAT,SUN *', new batchCadence());
System.schedule('Cadence SMS 20', '0 20 8-21 ? * MON,TUE,WED,THU,FRI,SAT,SUN *', new batchCadence());
System.schedule('Cadence SMS 30', '0 30 8-21 ? * MON,TUE,WED,THU,FRI,SAT,SUN *', new batchCadence());
System.schedule('Cadence SMS 40', '0 40 8-21 ? * MON,TUE,WED,THU,FRI,SAT,SUN *', new batchCadence());               
System.schedule('Cadence SMS 50', '0 50 8-21 ? * MON,TUE,WED,THU,FRI,SAT,SUN *', new batchCadence());
System.schedule('Cadence Task', '0 0 9-18 ? * MON,TUE,WED,THU,FRI,SAT *', new batchCadenceTask());
System.schedule('Cadence Email', '0 30 8-21 ? * MON,TUE,WED,THU,FRI,SAT,SUN *', new batchCadenceEmail());
           }catch(Exception e){
                System.debug('its scheduled');
           }
        
        //Left_main.batchCadenceEmail batchObj = new Left_main.batchCadenceEmail();
       // database.executebatch(batchObj,1);
            
        }
    


}