public with sharing class TwnsqrForOpportunityCtrl {
    
    public List<Id> selectedRecordIds{get;set;}
    public List<Opportunity> selOpps = new List<Opportunity>();
    public Boolean showToast{get;set;}
    public String errorMsg{get;set;}
    
    public TwnsqrForOpportunityCtrl(ApexPages.StandardSetController cntlr){
        selectedRecordIds = new List<Id>();
        selOpps = cntlr.getSelected(); //get selected records from account list view
        for(Opportunity opp : selOpps) {
            selectedRecordIds.add(opp.Id);  
        }
        System.debug(selectedRecordIds);
        if(selectedRecordIds.isEmpty()){
            showToast = true;
            errorMsg = 'Please select atleast one record.';
        }
   }
    public void getTwnsqrUpdate(){
        if(!selectedRecordIds.isEmpty()){
            List<Opportunity> oppRecordList = [SELECT Id,of_Buy_Boxes__c,of_Contacts__c,Last_Update__c,Address_1__c 
                                                FROM Opportunity 
                                                WHERE Id In : selectedRecordIds WITH USER_MODE]; 
            String addressData ='';
            if(!oppRecordList.isEmpty()){
                for(Integer i = 0; i < oppRecordList.size(); i++){
                    if(!String.isEmpty(oppRecordList[i].Address_1__c)){
                        if(i == oppRecordList.size()-1 ){
                            addressData += '{"address" : "'+oppRecordList[i].Address_1__c+'","idempotencyKey" : "'+ oppRecordList[i].Id+'"}';
                        }
                        else{
                            addressData += '{"address" : "'+oppRecordList[i].Address_1__c+'","idempotencyKey" : "'+ oppRecordList[i].Id+'"},';
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
                
                if(resWrapper != null){
                    for(Integer i=0; i< resWrapper.data.MatchingDemands.size(); i++) {
                        for(Integer j=0; j < oppRecordList.size(); j++) {
                            if(oppRecordList[j].id == resWrapper.data.MatchingDemands[i].args.idempotencyKey){
                                if(resWrapper.data.MatchingDemands[i].buyBoxes != null){ 
                                    oppRecordList[j].of_Buy_Boxes__c = resWrapper.data.MatchingDemands[i].buyBoxes;              
                                }
                                if(resWrapper.data.MatchingDemands[i].contacts != null){
                                    oppRecordList[j].of_Contacts__c = resWrapper.data.MatchingDemands[i].contacts;  
                                }
                                oppRecordList[j].Last_Update__c = System.now();
                                listToUpdate.add(oppRecordList[j]);
                            }
                        } 
                    }
                    if(!listToUpdate.isEmpty()){
                        try {
                            LeftMain_SecurityUtils.checkUpdate(Opportunity.SObjectType,new List<String> {'of_Buy_Boxes__c','of_Contacts__c','Last_Update__c'});
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
        Schema.DescribeSObjectResult SObjectSchema =  Opportunity.SObjectType.getDescribe();
        String currentViewUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/lightning/o/Opportunity/list?filterName=Recent';
        System.debug('currentViewUrl == '+currentViewUrl);
        PageReference newPage =  New Pagereference(currentViewUrl);     
        newPage.setRedirect(true);
        return newPage;

        
    }  
}