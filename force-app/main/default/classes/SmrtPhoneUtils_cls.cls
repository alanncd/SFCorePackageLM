public class SmrtPhoneUtils_cls {

    public static String findObjectNameFromRecordIdPrefix(String recordIdOrPrefix){
        String objectName = '';
        try{
            //Get prefix from record ID
            //This assumes that you have passed at least 3 characters
            String myIdPrefix = String.valueOf(recordIdOrPrefix).substring(0,3);
             
            //Get schema information
            Map<String, Schema.SObjectType> gd =  Schema.getGlobalDescribe(); 
             
            //Loop through all the sObject types returned by Schema
            for(Schema.SObjectType stype : gd.values()){
                String sobjectName = ''+stype;
                if(!(sobjectName =='Lead' || sobjectName =='Contact' || sobjectName =='Account' || sobjectName =='Opportunity' )) continue;
                Schema.DescribeSObjectResult r = stype.getDescribe();
                String prefix = r.getKeyPrefix();
                 
                //Check if the prefix matches with requested prefix
                if(prefix!=null && prefix.equals(myIdPrefix)){
                    objectName = r.getName();
                    break;
                }
            }
        }catch(Exception e){
            System.debug(e);
        }
        return objectName;
    }
}