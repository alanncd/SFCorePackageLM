global WITH SHARING class cadenceAutoSchedule_sch implements Schedulable{
    global String sTipo;
    global List<List<SObject>> lToDel;
    global List<List<SObject>> lToIns;
    global List<List<SObject>> lToUpd;
    
    global cadenceAutoSchedule_sch(){
        this.sTipo = 'bch';
    }
    
    global cadenceAutoSchedule_sch(String sTipo, List<List<SObject>> lToDel, List<List<SObject>> lToIns, List<List<SObject>> lToUpd){
        this.sTipo = sTipo;
        this.lToDel = lToDel;
        this.lToIns = lToIns;
        this.lToUpd = lToUpd;
    }
    /**********************************************************************
    * @description: 
    **********************************************************************/
    global void execute(SchedulableContext SC) {
        //Batch
        if( sTipo == 'bch' ){
            cadenceAutoSchedule_bch bch = new cadenceAutoSchedule_bch();
            database.executebatch(bch,200);
            fnProgram('bch', null, null, null);
        }
        //Encolable delete
        if( sTipo == 'delete' ){
            //Encola para Eliminar
            for( List<SObject> lstDel : lToDel ){
                if( lstDel.size() > 0 ){
                    //Encolable
                    //System.enqueueJob( new BCP_SEG_RecalculateSecurityMatrix_que.DeleteAssingment( lstDel ) );    
                }
            }
            fnProgram('insert', lToDel, lToIns, lToUpd);
        }
        else if( sTipo == 'insert' ){//Encolable Insert
            //Encola para Insertar
            for( List<SObject> lstIns : lToIns ){
                if(lstIns.size() > 0){
                   // System.enqueueJob( new BCP_SEG_RecalculateSecurityMatrix_que.InsertAssingment( lstIns ) );    
                }
            }
            fnProgram('update', lToDel, lToIns, lToUpd );
        }
        else if( sTipo == 'update' ){//Encolable Update
            //Encola para Actualizar
            for( List<SObject> lstUpd : lToUpd ){
                if( lstUpd.size() > 0 ){
                    //System.enqueueJob( new BCP_SEG_RecalculateSecurityMatrix_que.UpdateUser( lstUpd ) );    
                }
            }
        }
        try{
            system.abortJob( SC.getTriggerId() );
        }
        catch( exception e ){
            system.debug('#### schedule job exception while aborting:' + e);
        }
    }
    /**********************************************************************
    * @description: Programa las clases Queueable por Operación
    **********************************************************************/
    global void fnProgram( String sTipo, List<List<SObject>> lToDel, List<List<SObject>> lToIns, List<List<SObject>> lToUpd ){
        this.sTipo = sTipo;
        this.lToDel = lToDel;
        this.lToIns = lToIns;
        this.lToUpd = lToUpd;
        String sNameSch = 'Recalculate-'+sTipo;
        Datetime dtAhora = System.now();
        Datetime dtMas;
        Integer iHora = 0;
        Integer iDia = 0;
        String minute ='0';
        String hour ='0';
        String day ='*';
        String month ='*';
        String year ='2022';
        String strSchedule = '0 ' + minute + ' ' + hour + ' ' + day + ' ' + month + ' ?' + ' ' + year;
            //Clases de prueba
            if( Test.isRunningTest() ){
                strSchedule = '0 0 0 * * ?';
            }
            
            System.debug('##strSchedule: ' + strSchedule );
            String second='0';
            String millisecond='0';
            String sNameSchedule = sNameSch  +' - Hora: ' + hour + ':' + minute + ':' + second + ':' + millisecond +' Día: ' + day + '/' + month + '/' + year;
            
            String jobID = null;
            
            String sValidaSchedule = '2';//fnValidaNombreSchedule( sNameSchedule );
            
            if( sValidaSchedule == '2' ){
                
                jobID = System.schedule( sNameSchedule,
                                        strSchedule, 
                                        new cadenceAutoSchedule_sch(sTipo,lToDel,lToIns,lToUpd) );
            }
            else if ( sValidaSchedule == '1' ){
                
                sNameSchedule = sNameSchedule + '_2';
                
                jobID = System.schedule( sNameSchedule,
                                        strSchedule, 
                                        new cadenceAutoSchedule_sch(sTipo,lToDel,lToIns,lToUpd) );
            }
        }
    }
    /**********************************************************************
    * @description: 1 - Si Existe JOB con el mismo nombre.
                    2 - No existe JOB con el mismo nombre. 
                    3 - Solo se reprograma el Batch una vez.
    **********************************************************************/
    /*global String fnValidaNombreSchedule( String sNameSchedule ){
        
        String sValidaSchedule = '';
        //Valida para que el Schedule de bch no se ejecute dos veces
        if( sNameSchedule.contains( 'RecalculateSecurityMatrix_sch-bch' ) ){
            
            List<CronTrigger> lCronTrigger = [
                SELECT Id, CronExpression, CronJobDetailId, CronJobDetail.Name, StartTime, State, EndTime 
                FROM CronTrigger
                where CronJobDetail.Name LIKE '%RecalculateSecurityMatrix_sch-bch%' 
                AND EndTime = null ];
            
            sValidaSchedule = ( lCronTrigger.size() > 0 ? '3' : '2' );
        }
        else{//Valida que no exitan JOB's con el mismo nombre
            List<CronTrigger> lCronTrigger = [
                SELECT Id, CronExpression, CronJobDetailId, CronJobDetail.Name, StartTime, State, EndTime 
                FROM CronTrigger
                where CronJobDetail.Name =: sNameSchedule 
                AND EndTime = null ];
            
            sValidaSchedule = ( lCronTrigger.size() > 0 ? '1' : '2' );
        }
        
        return sValidaSchedule;
    }*/