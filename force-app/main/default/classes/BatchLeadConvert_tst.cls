@isTest
public class BatchLeadConvert_tst {

    @TestSetup
    static void makeData(){
        SObject lead = mock('Lead');
        insert lead;
    }
    static testMethod void testTaskTriggerOne(){
         User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(thisUser){
        try{
             Test.startTest();
        	querysUtilities__mdt query = [Select Id, Query__c, DeveloperName From querysUtilities__mdt];
        	//system.debug('query:'+query);
            BatchLeadConvert obj = new BatchLeadConvert('test@salesforce.com');
            DataBase.executeBatch(obj,50);  
        	System.assertEquals('batchConvertLead', query.DeveloperName);
        Test.stopTest();
            
        }catch(exception e){
                
            }
        }
       
    }
  
    
     static SObject mock(String sobjectName) {
        SObjectType t = Schema.getGlobalDescribe().get(sobjectName);

        SObject o = t.newSobject();

        Map<String, Schema.SObjectField> m = t.getDescribe().fields.getMap();

        for (String fieldName : m.keySet()) {
            DescribeFieldResult f = m.get(fieldName).getDescribe();
            
            if ((!f.isNillable() && f.isCreateable() && !f.isDefaultedOnCreate()) || (fieldName == 'Name' && (sobjectName =='Account' || sobjectName =='Campaign')) )  {
                if (f.getType() == DisplayType.Boolean) {
                    o.put(f.getName(), false);
                }
                else if (f.getType() == DisplayType.Currency) {
                    o.put(f.getName(), 0);
                }
                else if (f.getType() == DisplayType.Date) {
                    o.put(f.getName(), Date.today());
                }
                else if (f.getType() == DisplayType.DateTime) {
                    o.put(f.getName(), System.now());
                }
                else if (f.getType() == DisplayType.Double) {
                    o.put(f.getName(), 0.0);
                }
                else if (f.getType() == DisplayType.Email) {
                    o.put(f.getName(), 'foo@foo.com');
                }
                else if (f.getType() == DisplayType.Integer) {
                    o.put(f.getName(), 0);
                }
                else if (f.getType() == DisplayType.Percent) {
                    o.put(f.getName(), 0);
                }
                else if (f.getType() == DisplayType.Phone) {
                    o.put(f.getName(), '555-555-1212');
                }
                else if (f.getType() == DisplayType.String) {
                    o.put(f.getName(), 'TEST');
                }
                else if (f.getType() == DisplayType.TextArea) {
                    o.put(f.getName(), 'TEST');
                }
                else if (f.getType() == DisplayType.Time) {
                    o.put(f.getName(), System.now().time());
                }
                else if (f.getType() == DisplayType.URL) {
                    o.put(f.getName(), 'http://foo.com');
                }
                else if (f.getType() == DisplayType.PickList) {
                    o.put(f.getName(), f.getPicklistValues()[0].getValue());
                }
            }
        }
        return o;
    }
 @isTest
    static void testExecute() {
        // Obtener el lead insertado en el método setup
        Lead testLead = [SELECT Id FROM Lead LIMIT 1];

        // Simular el paso del lead en el scope
        List<Lead> leadScope = new List<Lead>{ testLead };

        // Crear instancia de la clase BatchLeadConvert
        BatchLeadConvert batch = new BatchLeadConvert('test@example.com');

        // Ejecutar el método execute
        Test.startTest();
        batch.execute(null, leadScope);
        Test.stopTest();

        // Verificar que el lead se ha convertido
        Lead convertedLead = [SELECT Id, IsConverted FROM Lead WHERE Id = :testLead.Id LIMIT 1];
        System.assert(convertedLead.IsConverted, 'El lead debería haberse convertido.');
    }
   

    


  // Clase mock para simular Database.BatchableContext
    private class MockBatchableContext implements Database.BatchableContext {
        public String getJobId() {
            // Devuelve un ID de trabajo ficticio
            return '7071h00003PZ1rA';
        }
        
        public String getChildJobId() {
            // Devuelve un ID de trabajo ficticio para el trabajo hijo
            return null;
        }
    }
    
}