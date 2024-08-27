public with sharing class TwnsqrForTransactionCtrl {
    public List<Id> selectedRecordIds{get;set;}
    public List<Transactions__c> selTransactions = new List<Transactions__c>();
    public Boolean showToast{get;set;}
    public String errorMsg{get;set;}
        
    public TwnsqrForTransactionCtrl(ApexPages.StandardSetController cntlr){
        try{
            selectedRecordIds = new List<Id>();
            selTransactions = cntlr.getSelected(); //get selected records from account list view
            for(Transactions__c transactionRec : selTransactions) {
                selectedRecordIds.add(transactionRec.Id);  
            }
            System.debug(selectedRecordIds);
            if(selectedRecordIds.isEmpty()){
                showToast = true;
                errorMsg = 'Please select atleast one record.';
            }
        }
        catch(Exception err){
            system.debug(err.getMessage());
        }
    } 
    public void getTwnsqrUpdate(){
        if(!selectedRecordIds.isEmpty()){
            List<Transactions__c> tranRecordList =  [SELECT Id,of_Buy_Boxes__c,of_Contacts__c,Last_Update__c,Left_Main_Address__c 
                                    FROM Transactions__c 
                                    WHERE Id In : selectedRecordIds WITH USER_MODE]; 
            String addressData ='';
            if(!tranRecordList.isEmpty()){
                for(Integer i = 0; i < tranRecordList.size(); i++){
                    if(tranRecordList[i].Left_Main_Address__c != null && tranRecordList[i].Left_Main_Address__c !=' '){
                        if(i == tranRecordList.size()-1 ){
                            addressData += '{"address" : "'+tranRecordList[i].Left_Main_Address__c.replace('\n','')+'","idempotencyKey" : "'+ tranRecordList[i].Id+'"}';
                        }
                        else{
                            addressData += '{"address" : "'+tranRecordList[i].Left_Main_Address__c.replace('\n','')+'","idempotencyKey" : "'+ tranRecordList[i].Id+'"},';
                        }  
                    }
                }
            }
            if(String.isEmpty(addressData)) {
                showToast = true;
                errorMsg = 'Address can\'t be blank.';
            }
            else{
                System.debug('addressData  '+addressData);
                Http h = new Http();
                
                String jsonString =  '{"query": "query MyQuery($queries: [MatchingDemandInput!]!) { MatchingDemands(queries: $queries) '+
                    '{ args { address addressFormatted idempotencyKey} success error contacts buyBoxes }}","variables": {"queries": [' + addressData +']}}';
                
                Twnsqr_Details__mdt reqDetails = [SELECT Endpoint__c, Token__c FROM Twnsqr_Details__mdt WITH USER_MODE LIMIT 1]; 
                
                // Instantiate a new HTTP request, specify the method (GET) as well as the endpoint
                HttpRequest req = new HttpRequest();
                req.setEndpoint(reqDetails.Endpoint__c);
                req.setMethod('POST');
                req.setHeader('Content-Type', 'application/json');
                req.setHeader('Authorization',reqDetails.Token__c);
                req.setBody(jsonString);
                req.setTimeout(80000);
                
                // Send the request, and return a response
                HttpResponse res = h.send(req);
                system.debug(res.getStatusCode() +'--'+  res.getBody());
                TwnsqrResponseWrapper resWrapper = (TwnsqrResponseWrapper) System.JSON.deserialize(res.getBody(), TwnsqrResponseWrapper.class);
                List<sObject> listToUpdate = new List<sObject>();
                
                if(resWrapper != null && resWrapper.data != null){
                    for(Integer i=0; i< resWrapper.data.MatchingDemands.size(); i++) {
                        for(Integer j=0; j < tranRecordList.size(); j++){
                            if(tranRecordList[j].id == resWrapper.data.MatchingDemands[i].args.idempotencyKey){
                                if(resWrapper.data.MatchingDemands[i].buyBoxes != null){ 
                                    tranRecordList[j].of_Buy_Boxes__c = resWrapper.data.MatchingDemands[i].buyBoxes;              
                                }
                                if(resWrapper.data.MatchingDemands[i].contacts != null){
                                    tranRecordList[j].of_Contacts__c = resWrapper.data.MatchingDemands[i].contacts;  
                                }
                                tranRecordList[j].Last_Update__c = System.now();
                                listToUpdate.add(tranRecordList[j]);
                            }
                        } 
                    }
                    if(!listToUpdate.isEmpty()){
                        try {
                            LeftMain_SecurityUtils.checkUpdate(Transactions__c.SObjectType,new List<String> {'of_Buy_Boxes__c','of_Contacts__c','Last_Update__c'});
                            SObjectAccessDecision decision1 = Security.stripInaccessible(AccessType.UPDATABLE, listToUpdate);
                            listToUpdate = decision1.getRecords();
                            List<Database.SaveResult> myResult = Database.update(listToUpdate);

                        } catch(Exception e) {
                            System.debug('error');
                        }
                        showToast = true;
                        errorMsg = 'Records Updated Successfully.';
                    }
                } 
            }
    }
    }
    public PageReference hideToast(){
        showToast = false;
        Schema.DescribeSObjectResult SObjectSchema =  Transactions__c.SObjectType.getDescribe();
        String currentViewUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/lightning/o/Transactions__c/list?filterName=Recent';
        System.debug('currentViewUrl == '+currentViewUrl);
        PageReference newPage =  New Pagereference(currentViewUrl);     
        newPage.setRedirect(true);
        return newPage;
    }  
}