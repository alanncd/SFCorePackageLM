//Util Class to sent sms - Unt used
public with sharing class RingCentralSms {
    class numberWrapper{
        public String target_id;
        public String target_type;        
    }
   
    class smsWrapper{
        public String direction;
        public String created_date;
        public String from_number;
        public String user_id;
        public List<String> to_numbers;
    }
}