@RestResource(urlMapping='/TwnsqrWebhook/*')
//leftmainreicoredev2-dev-ed.develop.my.salesforce-sites.com/services/apexrest/TwnsqrWebhook/11111
//ENDPOINT METHOD
global with sharing class TwnsqrWebHook {
    @HttpPost
    global static interesedBuyer doPost() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String trxId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        Map<String, String> header = req.headers;
        String requestBody = req.requestBody.toString();
        interesedBuyer rb = (interesedBuyer)JSON.deserialize(requestBody, interesedBuyer.class);
        //VALIDATE IF THE ORG ID IS THE SAME--------------------
        Id OrgId = UserInfo.getOrganizationId();
        //Update Transaction LeadSource
        List<Transactions__c> tx = [Select Id, LastModifiedById,OwnerId,Acquisition_Rep__c,Lead_Source__c From Transactions__c Where Id=:trxId WITH USER_MODE];
        if(tx.size()>0){
            tx[0].Lead_Source__c=rb.leadSource;
            Set<String> users = new Set<String>();
            users.add(tx[0].Acquisition_Rep__c);
            users.add(tx[0].OwnerId);
            users.add(tx[0].LastModifiedById);
            notifyUsers(users,rb.externalRef);
            List<Contact> contacts = [select Id, Name, Account.Name From Contact Where LastName=:rb.contactinfo.lastName AND FirstName=:rb.contactinfo.firstName WITH USER_MODE];
            List<Account> accounts = [Select Id, Name FROM Account Where Name=:rb.contactinfo.accountName WITH USER_MODE];
            String accId= '';
            if(accounts.size()>0){
                accId = accounts[0].Id;
            }else{
               Account newAcc= new Account();
               newAcc.Name=rb.contactinfo.accountName;
               LeftMain_SecurityUtils.checkInsert(Account.SObjectType,new List<String> {'Name'});

               if (!Schema.sObjectType.Account.isCreateable() ||
                   !Schema.sObjectType.Account.fields.Name.isCreateable()) {
                 throw new AuraHandledException('You do not have permission to create an Account with the specified fields.');
               }

               insert newAcc;
               accId = newAcc.Id;
            }
            if(contacts.size()>0){
                Interested_Buyers__c ib = new Interested_Buyers__c();
                ib.Contact__c=contacts[0].Id;
                ib.Name=rb.interedBuyerName;
                ib.Transactions__c=rb.externalRef;
                LeftMain_SecurityUtils.checkInsert(Interested_Buyers__c.SObjectType,new List<String> {'Contact__c','Name','Transactions__c'});

                List<Interested_Buyers__c>  listInterestedBuyer = new List<Interested_Buyers__c>();
                listInterestedBuyer.add(ib);

                SObjectAccessDecision decision1 = Security.stripInaccessible(AccessType.CREATABLE, listInterestedBuyer);
                Database.insert(listInterestedBuyer = decision1.getRecords());
            }else{
                //Create Contact
                Contact con = new Contact();
                con.LastName=rb.contactinfo.lastName;
                con.FirstName=rb.contactinfo.firstName;
                con.AccountId= accId;

                List<Contact> listContact = new List<Contact>();
                listContact.add(con);
                LeftMain_SecurityUtils.checkInsert(Contact.SObjectType,new List<String> {'LastName','FirstName','AccountId'});
                SObjectAccessDecision decision3 = Security.stripInaccessible(AccessType.CREATABLE, listContact);
                Database.insert(listContact = decision3.getRecords());
                
                // & Insert Interesed Buyer
                List<Interested_Buyers__c> listInterestedBuyers = new List<Interested_Buyers__c>();

				Interested_Buyers__c ib = new Interested_Buyers__c();
                ib.Contact__c=con.Id;
                ib.Name=rb.interedBuyerName;
                ib.Transactions__c=rb.externalRef;
                listInterestedBuyers.add(ib);

                LeftMain_SecurityUtils.checkInsert(Interested_Buyers__c.SObjectType,new List<String> {'Contact__c','Name','Transactions__c'});
                SObjectAccessDecision decision1 = Security.stripInaccessible(AccessType.CREATABLE, listInterestedBuyers);
                Database.insert(listInterestedBuyers = decision1.getRecords());

            }
        }
        LeftMain_SecurityUtils.checkUpdate(Transactions__c.SObjectType,new List<String> {'Acquisition_Rep__c','OwnerId','Lead_Source__c'});
        SObjectAccessDecision decision1 = Security.stripInaccessible(AccessType.UPDATABLE, tx);
        List<Database.SaveResult> myResult = Database.update(tx = decision1.getRecords());

        //Create metadata with users to be notified as a configuration
        return rb;
    }
    @HttpGet
    global static List<Transactions__c> doGet() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String trxId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        Map<String, String> header = req.headers;
        
        system.debug(trxId);
        List<Transactions__c> tx = [Select Id, Name From Transactions__c Where Id=:trxId WITH USER_MODE];
        return tx;
    }
	global class interesedBuyer{
        String organizationId;
        String interedBuyerName;
        Double offer;
        String offerType;
        String offerNotes;
        String externalRef;
        String leadSource;
        contactInfo contactinfo;
	}
    global class contactInfo{
        String accountName;
		String lastName;
        String firstName;
        String phone;
		String mobile;
		String email;
    }
    public static void notifyUsers(Set<String> recipientsIds, String targetId) {

        // Get the Id for our custom notification type
        CustomNotificationType notificationType = 
            [SELECT Id, DeveloperName 
             FROM CustomNotificationType 
             WHERE DeveloperName='Left_Main_Notification' WITH USER_MODE];
        
        // Create a new custom notification
        Messaging.CustomNotification notification = new Messaging.CustomNotification();

        // Set the contents for the notification
        notification.setTitle('New Interesd Buyer Added');
        notification.setBody('New Interesd Buyer Added by Twnsqr, Verify the Transation for more details');

        // Set the notification type and target
        notification.setNotificationTypeId(notificationType.Id);
        notification.setTargetId(targetId);
        
        // Actually send the notification
        try {
            notification.send(recipientsIds);
        }
        catch (Exception e) {
            System.debug('Problem sending notification: ' + e.getMessage());
        }
    }    
}