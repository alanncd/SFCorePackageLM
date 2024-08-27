global class scheduledCallout implements Schedulable, Database.AllowsCallouts {
        @TestVisible public static String endpoint1 ='';

    global void execute(SchedulableContext SC) {
        //scheduledCallout.myCallout();
   }
/*
   @future(callout=true) 
  public static void myCallout() {

//Ring_Central_API_Setting__c.getOrgDefaults().apiKey__c
//Ring_Central_API_Setting__c.username__c
String username=Ring_Central_API_Setting__c.getOrgDefaults().username__c;
String password=Ring_Central_API_Setting__c.getOrgDefaults().password__c;
String grantType='password';   
String secretKey=Ring_Central_API_Setting__c.getOrgDefaults().secretKey__c;
String apiKey=Ring_Central_API_Setting__c.getOrgDefaults().apiKey__c;
String authUrl=Ring_Central_API_Setting__c.getOrgDefaults().authUrl__c;



//getting the local datetime of the current user today and interval
        
Datetime now = Datetime.now();
System.debug('now'+now+'system'+System.now())  ;  
 
Datetime local = now;
Datetime localgmt=local;      

// 

  
Datetime now_test = Datetime.now();
Datetime formattedDT = Datetime.newInstance(now_test.year(), now_test.month(), now_test.day(), now_test.hour(), now_test.minute(), now_test.second());        
//now_test=now_test.format('MM/dd/yyyy hh:mm:ss a z', 'Africa/Casablanca');   
System.debug('casa: ' + now_test.format('MM/dd/yyyy hh:mm:ss a z', 'Africa/Casablanca'));

String formatedTZ=formattedDT.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss\'Z\''); 
System.debug('test'+formatedTZ); 
String todaysDateStr = formattedDT.format('yyyy-MM-dd');
String todaysDateStrHMS = formattedDT.format('HH:mm:ss'); 
System.debug('hms'+todaysDateStrHMS)        ;
System.debug('datehms:'+todaysDateStr+ 'T'+todaysDateStrHMS+'Z'); 
System.debug(local.format('HH:mm:ss')+'gmt'+local.format('HH:mm:ss')) ;       
String datetoParam=formatedTZ; // todaysDateStr+ 'T'+todaysDateStrHMS+'Z';     
System.debug('datetoparam:'+datetoParam); 
        
Datetime yesterday1=now_test.addDays(0);    // to be commenter      
//Datetime now2 =now_test.addDays(-5); //for testing
Datetime now2 =now_test.addHours(-10);//.addDays(-1);  // add now_test
String formatedTZfrom=now2.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');         
Integer offset2 = UserInfo.getTimezone().getOffset(now2);
Datetime local2 = now2; 
String todaysDateStr2 = local2.format('yyyy-MM-dd');   
String todaysDateHMSStr2 = local2.format('HH:mm:ss');          
System.debug('date: '+local2+ 'HHMMSS: '+todaysDateHMSStr2);    
System.debug('datehms:'+todaysDateStr2+ 'T'+todaysDateHMSStr2+'Z'); 
String datefromParam=todaysDateStr2+ 'T'+todaysDateHMSStr2+'Z';          
System.debug('datefromParam:'+formatedTZfrom); 
datefromParam=formatedTZfrom;
        
//Adding hours and minute to our URL 
String timePricise='T00:00:00.000Z';        
Integer IntervalMinutes=5;
Integer IntervalHours=5;    
Integer IntervalSeconds=5;         


        
        
String authUrlQ1='https://platform.ringcentral.com/restapi/v1.0/account/~/call-log?view=Simple&showBlocked=false&withRecording=false&dateFrom='+datefromParam+'&totalPages=100&perPage=100000&dateTo='+datetoParam; 
System.debug('show'+authUrlQ1);
 if(Test.isRunningTest()) {
   authUrlQ1 = endpoint1;
System.debug('authUrlQ1: '+authUrlQ1);
}
String authUrlCalllog='https://platform.ringcentral.com/restapi/v1.0/account/~/call-log';        
String accessToken='';  

// Get the Access Token to get the call log
Http http = new Http();
HttpRequest request = new HttpRequest();
request.setEndpoint(authUrl);
request.setMethod('POST');   
Blob headerValue = Blob.valueOf(apiKey + ':' + secretKey);    
String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
request.setHeader('Authorization', authorizationHeader);
request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
String payload = 'username='+EncodingUtil.urlEncode(username,'UTF-8')+'&password='+EncodingUtil.urlEncode(password,'UTF-8')+'&grant_type=password';
System.debug(''+payload);
System.debug(authorizationHeader);
request.setBody(payload);
HttpResponse response = http.send(request);    
System.debug('httprequest1'+request)    ;
    // Parse the JSON response
if (response.getStatusCode() != 200) {
System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus()+response.getBody());
} else {
System.debug('body1'+response.getBody());
        
//get access token
Map<String, String> values = (Map<String, String>)JSON.deserialize(response.getBody(), Map<String, String>.class);
accessToken = values.get('access_token');
    ///////////////now we pass the access token and do a callout
    //Call WS CallLog of today, with missing calls of the extension (central ring extension is the identifiant of the user in central ring) of the current user
//Mapping between extension and Users salesforce is done using Name  
Http http2 = new Http();
HttpRequest request2 = new HttpRequest();
request2.setEndpoint(authUrlQ1);
request2.setMethod('GET');   
String authorizationHeader2 = 'Bearer ' + accessToken;
request2.setHeader('Authorization', authorizationHeader2);
request2.setHeader('Content-Type', 'application/json');
System.debug('url required 1: '+authUrlQ1);
HttpResponse response2 = http2.send(request2);    
System.debug('http2'+request2) ; 
if (response2.getStatusCode() != 200) {
System.debug('The status code returned was not expected: ' + response2.getStatusCode() + ' ' + response2.getStatus()+response.getBody());
} else {
        
        //parse getbody
       
String responseQ2=response2.getBody();
System.debug('body2'+response2.getBody());               
Map<String, Object> results = (Map<String, Object>)JSON.deserializeUntyped(responseQ2); 
System.debug('results'+results); 
List<Object> callrecords = (List<Object>)results.get('records');
System.debug('jsonRecords: '+callrecords.size());
System.debug('FirstList Get: '+callrecords[0]); 
        
    id taskId;
    Integer Missed=0;
    list<RingCentral_Data_Store2__c> rcdList = new list<RingCentral_Data_Store2__c>();
    map<string,RingCentral_Data_Store2__c> rcdValues = new map<string,RingCentral_Data_Store2__c>();
 	list<RingCentral_Data_Store2__c> oldrcd = [select id,From_Number__c,To_Number__c,Raw_Time_Filter__c,Caller_Phone_Number__c,Formatted_Date__c,To_Phone_Number__c 
                                               FROM RingCentral_Data_Store2__c WHERE CreatedDate =THIS_WEEK]; //: system.today()
    system.debug('The size is : '+oldrcd.size());
    for(RingCentral_Data_Store2__c rcdss :oldrcd){rcdValues.put(rcdss.Raw_Time_Filter__c,rcdss);
    }
    
    ///looping through the calls from ringCentral
    for(Object inidividualRecords : callrecords){
        
           //store miss calls in this map objects , 
            Map<String,Object> uriv = (Map<String,Object> )inidividualRecords;
        system.debug('uriv----'+uriv);
         if(uriv.get('direction').equals('Inbound') )  {
             //  (uriv.get('result').equals('Missed') || uriv.get('result').equals('Hang Up') ) & uriv.get('action').equals('Phone Call') & 
            Missed=Missed+1;
            Map<String, Object> resultsfrom = (Map<String, Object>)uriv.get('from');
            System.debug('Caller Name  = ' + resultsfrom.get('name'));
            System.debug('Caller LOCATION = ' + resultsfrom.get('location'));
            System.debug('Caller PhoneNumber = ' + resultsfrom.get('phoneNumber'));
                
            Map<String, Object> resultsto = (Map<String, Object>)uriv.get('to');
				if(rcdValues.get(uriv.get('startTime').toString())==null){
				//if(!rcdValues.containskey(resultsfrom.get('phoneNumber').toString()) && rcdValues.get('Raw_Time_Filter__c') != uriv.get('startTime')){                    
				string fromPhoneNumber;
                    if(resultsfrom.get('phoneNumber')<>NULL){fromPhoneNumber = resultsfrom.get('phoneNumber').toString().replaceAll('\\+1', '');}
                    else{fromPhoneNumber = '0000000';}
                string toPhoneNumber = resultsto.get('phoneNumber').toString().replaceAll('\\+1', '');     
  				RingCentral_Data_Store2__c RCDS = new RingCentral_Data_Store2__c();
                RCDS.name = fromPhoneNumber;
            
                RCDS.Raw_Time_Filter__c = uriv.get('startTime').toString();
                system.debug('raw time filter==============>'+RCDS.Raw_Time_Filter__c) ;
                RCDS.From_Number__c = fromPhoneNumber;//resultsfrom.get('phoneNumber').toString();
                RCDS.To_Number__c = resultsto.get('phoneNumber').toString();
                RCDS.Caller_Phone_Number__c=string.valueof( fromPhoneNumber );
                RCDS.To_Phone_Number__c =string.valueof( toPhoneNumber );    
                //RCDS.Call_Start_Time__c=
				RCDS.Type__c= uriv.get('type').toString();
                RCDS.Call_Result__c = uriv.get('result').toString();
				RCDS.ExternalId__c = uriv.get('id').toString();
                    
                system.debug('RCDS.name==> '+RCDS.name);
                system.debug('RCDS.From Number==> '+RCDS.From_Number__c);
                system.debug('RCDS.To Number==> '+RCDS.To_Number__c);
                System.debug('Missing Call = ' + uriv.get('result'));
                system.debug('RCDS startTime DateTime convert==> '+RCDS.Call_Start_Time__c);
                 rcdList.add(RCDS);
                
                }
              
              
    }
    }
 
    if(rcdList.size()>0){
        insert rcdList;
    }
 
    
}    
}
}
  */
}