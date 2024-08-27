global with sharing class cadenceAutoSchedule_bch implements Database.Batchable<sObject>, Database.Stateful{
    global String sQuery;
    global List<Id> lIdUser;
    /**********************************************************************
    * @description: Constructor del Batch
    **********************************************************************/
    global cadenceAutoSchedule_bch(){
        //Busca la Matriz con la lista de Conjunto de Permisos
        //mMatrizPS = armaMapaCodPuestoConjuntoPermisosMatriz();
        //mMatriz = armaMapaCodPuestoMatriz();
        //Inicializa lista de Id's de Usuarios
        //lIdUser = new List<Id>();
    }
    /**********************************************************************
    * @description: Query PermissionSetAssignments
    **********************************************************************/
    global Database.QueryLocator start(Database.BatchableContext bc) {
        
        sQuery = ' SELECT Id, Name, Status__c, Frecuency_To_Flow__c, Lead__c FROM ScheduleCadence__c';
        if(Test.isRunningTest()){
            sQuery += ' LIMIT 1 ';
        }
        System.debug('##SCHEDULE sQuery: '+ sQuery );
        return Database.getQueryLocator( sQuery );
    }
    /**********************************************************************
    **********************************************************************/
    global void execute( Database.BatchableContext BC, List<ScheduleCadence__c> schCadence ){
        System.debug('##cadenceAutoSchedule_bch execute start schCadence: '+schCadence.size());
        Set<Id> setIds = new Set<Id>();
        List<ScheduleCadence__c> cadenceList = new List<ScheduleCadence__c>();
        //Pasa a la List
        for(ScheduleCadence__c c:schCadence){
            setIds.add(c.Id);
        }
        System.debug('##cadenceAutoSchedule_bch execute end schCadence: '+setIds.size());
    }
    /**********************************************************************
    * @description: Finish del Batch, Crea Evento de Plataforma y envia email
    **********************************************************************/
    global void finish(Database.BatchableContext bc){
        //Reprogramar
        cadenceAutoSchedule_sch sch = new cadenceAutoSchedule_sch();
       sch.fnProgram('bch', null, null, null);
    }
}