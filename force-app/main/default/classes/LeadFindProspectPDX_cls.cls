public with sharing class LeadFindProspectPDX_cls {

    // convert Prospect Lead into Homeowner Lead with Campaign 
   /* public static void findProspectLead(List<Lead> newList){ 
        if (newList[0].Email == 'emailpdxtrg@leftmain.com')  //INICIA IFF
            {
        Id leadHomeownerId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Homeowner').getRecordTypeId();
        Id leadProspectId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Prospect').getRecordTypeId();
        Set<String> streetSet = new Set<String>();
        Set<String> citySet = new Set<String>();
        Set<String> phoneSet = new Set<String>();
        Set<String> mobileSet = new Set<String>();        
        Map<String,Lead> newLeadMap = new Map<String,Lead>();
        Map<String,Lead> newPhoneLeadMap = new Map<String,Lead>();
        Map<String,Lead> newMobileLeadMap = new Map<String,Lead>();
        for(Lead leadObj : newList){
            if(leadObj.RecordTypeId != null &&   leadObj.RecordTypeId == leadHomeownerId && 
               String.isNotBlank(leadObj.Street) && String.isNotBlank(leadObj.City) ){
                   streetSet.add(leadObj.Street);
                   citySet.add(leadObj.City);
                   newLeadMap.put(leadObj.Street.toLowerCase()+''+leadObj.City.toLowerCase(),leadObj);
               }
            if(leadObj.RecordTypeId != null &&   leadObj.RecordTypeId == leadHomeownerId && 
               String.isNotBlank(leadObj.phone)){
                   phoneSet.add(leadObj.phone);
                   newPhoneLeadMap.put(leadObj.phone,leadObj);
               }
            if(leadObj.RecordTypeId != null &&   leadObj.RecordTypeId == leadHomeownerId && 
               String.isNotBlank(leadObj.MobilePhone)){
                   mobileSet.add(leadObj.MobilePhone);
                   newMobileLeadMap.put(leadObj.MobilePhone,leadObj);
               }
        }
        List<Lead> updateLeadList = new List<Lead>();
        List<Lead> deleteProspectList = new List<Lead>();
        List<CampaignMember> insertCampaignList = new List<CampaignMember>();
        //List<Lead> prospectLeadList = new List<Lead>();
        List<Lead> prospectLeadList = [SELECT Id, LastName, FirstName, Salutation, Name, 
                                       RecordTypeId, Title, Company, Street, City, State, PostalCode, Country, Latitude, 
                                       Longitude, Address, Phone, MobilePhone, Fax, Email, Website, 
                                       PhotoUrl, Description, LeadSource, Status, Industry, Rating, AnnualRevenue, 
                                       NumberOfEmployees, SICCode__c, 
                                       ProductInterest__c,Primary__c, CurrentGenerators__c, 
                                       NumberofLocations__c,Age_of_HVAC__c, Age_of_HWH__c,
                                       Age_of_Roof__c,Any_Recent_Updates__c, Asking_Price__c,
                                       Bathrooms__c,
                                       Bedrooms__c, Contacted__c, Current_on_Payments__c,
                                       Decision_Makers__c, Email__c, How_Long_Owned__c,
                                       How_soon_are_you_looking_to_close__c, Lead_Source__c,
                                       Lot_Size__c, Mortgage_Owed__c, Next_Step__c,
                                       Occupancy__c, Phone__c, Special_Features__c,
                                       Square_footage__c, Year_Built__c, Lead_Contacted_Time__c,
                                       Elapsed_Minutes_to_Contacted__c, Unqualified_Reason__c, 
                                       Repairs_Needed__c, Tenant_Current_Monthly_Rent__c,
                                       Tenant_Current_Lease_Terms__c, Property_Type__c, 
                                       TaskCount__c, EventCount__c, Activity_Count_TE__c, 
                                       ConvertLead__c, Reason_for_Selling__c, 
                                       Garage__c, Mailing_Address__c, Bed_Count__c 
                                       FROM Lead WHERE  
                                       (Phone IN :phoneSet    OR 
                                        MobilePhone IN :mobileSet ) AND
                                       RecordTypeId  != null AND RecordTypeId =:leadProspectId
                                       LIMIT 100
                                      ];

        if(!prospectLeadList.isEmpty()){ 
            Map<String,List<CampaignMember>> mapCampaign = new Map<String,List<CampaignMember>>();
            List<CampaignMember> campaignList = [SELECT Id,CampaignId,LeadId FROM CampaignMember WHERE leadId IN :prospectLeadList AND LeadId != null AND CampaignId != null];
            for(CampaignMember campaignObj : campaignList){
                if(!mapCampaign.containsKey(campaignObj.LeadId)){
                    mapCampaign.put(campaignObj.LeadId, new List<CampaignMember>{campaignObj});
                }else{
                    mapCampaign.get(campaignObj.LeadId).add(campaignObj);
                }
            }
            
            for(Lead prospectLeadObj : prospectLeadList){
                Boolean LeadFound = false;
                Lead leadObj;
                String Street = String.isNotBlank(prospectLeadObj.Street) ? prospectLeadObj.Street.toLowerCase() : '';
                String City  = String.isNotBlank(prospectLeadObj.City) ? prospectLeadObj.City.toLowerCase() : '';
                String StreetAndCity = Street+''+City;
                String phone = String.isNotBlank(prospectLeadObj.phone) ?  prospectLeadObj.phone : '';
                String mobile = String.isNotBlank(prospectLeadObj.MobilePhone) ?  prospectLeadObj.MobilePhone : '';
                if(String.isNotBlank(Street)  && String.isNotBlank(City) && newLeadMap != null && newLeadMap.Size() > 0 && newLeadMap.containsKey(StreetAndCity)){
                    leadObj = newLeadMap.get(StreetAndCity);
                    LeadFound = true;
                }else if(String.isNotBlank(phone) && newPhoneLeadMap != null && newPhoneLeadMap.Size() > 0 && newPhoneLeadMap.containsKey(phone)){
                    leadObj = newPhoneLeadMap.get(phone);
                    LeadFound = true;
                }else if(String.isNotBlank(mobile) && newMobileLeadMap != null && newMobileLeadMap.Size() > 0 && newMobileLeadMap.containsKey(mobile)){
                    leadObj = newMobileLeadMap.get(mobile);
                    LeadFound = true;
                }
                
                if(LeadFound){
                    Id ProspectId = prospectLeadObj.Id;
                    Id LeadId = leadObj.id;
                    String firstName = leadObj.FirstName;
                    String lastName   = leadObj.LastName;
                    leadObj  = prospectLeadObj.clone(false, false, false, false);
                    leadObj.firstName = firstName;
                    leadObj.LastName  = lastName;
                    leadObj.Id = LeadId;
                    leadObj.RecordTypeId = leadHomeownerId;
                    updateLeadList.add(leadObj);
                    if(mapCampaign != null && mapCampaign.containsKey(prospectLeadObj.Id)){
                        List<CampaignMember> campaignMemberUpdateList = mapCampaign.get(prospectLeadObj.Id) != null && !mapCampaign.get(prospectLeadObj.Id).isEmpty() ? mapCampaign.get(prospectLeadObj.Id) : new List<CampaignMember>();
                        for(CampaignMember CampaignMemObj : campaignMemberUpdateList){
                            CampaignMember newCampaign = new CampaignMember(); 
                            newCampaign.campaignid = CampaignMemObj.CampaignId;
                            newCampaign.leadid= LeadId;
                            insertCampaignList.add(newCampaign);   
                        }
                    }
                    deleteProspectList.add(prospectLeadObj);
                }
            }
            if(!updateLeadList.isEmpty()){
                update updateLeadList;
            }
            if(!insertCampaignList.isEmpty()){
                insert insertCampaignList;
            }
            if(!deleteProspectList.isEmpty() && Lead.sObjectType.getDescribe().isDeletable()){
                delete deleteProspectList;
            }
        }
    }
}*/
}