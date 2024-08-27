@isTest
public class LeadFindProspectPDX_tst {
    static testMethod void testPropectPDX(){
        	Id leadProspectId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Prospect').getRecordTypeId();
        	Id leadHomeownerId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Homeowner').getRecordTypeId();
            Lead leadOBJ = new Lead(); 
            leadOBJ.LastName = 'BBBB';
        	LeadObj.Street = 'test';
        	LeadObj.City = 'test';
        	LeadObj.Phone = '999555111';
            leadOBJ.Next_Step__c = 'Test';
        	leadOBJ.RecordTypeId = leadProspectId;
            insert leadOBJ;  
            Campaign camp1 = new Campaign(Name = 'Test Campaign 1', IsActive = True);
        	insert camp1;
        	Campaign camp2 = new Campaign(Name = 'Test Campaign 2', IsActive = True);
        	insert camp2;
        	CampaignMember testCampMemb1 = new CampaignMember(LeadId =leadOBJ.Id , CampaignId = camp1.Id, Status = 'Sent');
        	CampaignMember testCampMemb2 = new CampaignMember(LeadId =leadOBJ.Id , CampaignId = camp2.Id, Status = 'Sent');
        	insert testCampMemb1;
        	insert testCampMemb2;
            Test.startTest();    
                Lead leadOBJhome = new Lead(); 
                leadOBJhome.LastName = 'AAAA';
                leadOBJhome.Street = 'test';
        		leadOBJhome.Phone = '999555111';
                leadOBJhome.City = 'test';
        		leadOBJhome.Email = 'emailpdxtrg@leftmain.com';  //Para que entre solo cuando tiene este email
                leadOBJhome.Next_Step__c = 'Test';
                leadOBJhome.RecordTypeId = leadHomeownerId;
                insert leadOBJhome;  
        		system.assertNotEquals(leadOBJhome, null);
            Test.stopTest();
    }

    
    
    
}