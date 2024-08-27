public with sharing class TwnsqrCallOut {
  @future(callout=true)
  public static void TwnsqrGetConfig() {
    //Verify if was connected
    List<Twnsqr_Config__c> lstConfig = [
      SELECT Id, Sync__c
      FROM Twnsqr_Config__c WITH USER_MODE LIMIT 10000
    ];
    if (lstConfig.size() > 0 && lstConfig[0].Sync__c == true) {}
    // Instantiate a get config
    HttpResponse res = TwnsqrcallOut('/api/v1/config', 'GET', null);
    if (res.getStatusCode() == 200) {
      if (lstConfig.size() > 0) {
        lstConfig[0].Sync__c = true;
        lstConfig[0].Last_Message__c = res.getStatus();
        LeftMain_SecurityUtils.checkUpdate(Twnsqr_Config__c.SObjectType,new List<String> {'Sync__c','Last_Message__c'});

        SObjectAccessDecision decision1 = Security.stripInaccessible(AccessType.UPDATABLE, lstConfig);
        List<Database.SaveResult> myResult = Database.update(lstConfig = decision1.getRecords());

      } else {
        Twnsqr_Config__c twnConfig = new Twnsqr_Config__c();
        twnConfig.Sync__c = true;
        twnConfig.Last_Message__c = res.getStatus();
        LeftMain_SecurityUtils.checkInsert(Twnsqr_Config__c.SObjectType,new List<String> {'Sync__c','Last_Message__c'});
        
        List<Twnsqr_Config__c> listTwnsqrConfig = new List<Twnsqr_Config__c>();
        listTwnsqrConfig.add(twnConfig);

        SObjectAccessDecision decision1 = Security.stripInaccessible(AccessType.CREATABLE, listTwnsqrConfig);
        Database.insert(listTwnsqrConfig = decision1.getRecords());
      }
    } else {
      if (lstConfig.size() > 0) {
        lstConfig[0].Sync__c = false;
        lstConfig[0].Last_Message__c = res.getStatus();
        LeftMain_SecurityUtils.checkUpdate(Twnsqr_Config__c.SObjectType,new List<String> {'Sync__c','Last_Message__c'});


        SObjectAccessDecision decision2 = Security.stripInaccessible(AccessType.UPDATABLE, lstConfig);
        List<Database.SaveResult> myResult = Database.update(lstConfig = decision2.getRecords());

        insertError(res, 'TwnsqrCallOut.TwnsqrGetConfig');
      }
    }
    system.debug(res.getBody());
  }
  @future(callout=true)
  public static void TwnsqrPostConfig() {
    configWrapper cw = new configWrapper();
    List<Twnsqr_Config__c> lstConfig = [
      SELECT Id, Sync__c, org_name__c
      FROM Twnsqr_Config__c WITH USER_MODE LIMIT 10000
    ];
    cw.crm = lstConfig[0].org_name__c; // Sent to the TwnSqrConfig?
    Id OrgId = UserInfo.getOrganizationId();
    config cf = new config();
    cf.salesforceOrgID = OrgId + '';
    cw.config = cf;
    // Instantiate a get config
    HttpResponse res = TwnsqrcallOut(
      '/api/v1/config',
      'POST',
      JSON.serialize(cw, true)
    );
    if (res.getStatusCode() != 200) {
      insertError(res, 'TwnsqrCallOut.TwnsqrPostConfig');
    }
    system.debug(res.getBody());
  }

  @InvocableMethod(label='Post Config')
  public static List<String> TwnsqrPostConfigtwo(List<String> config) {
    List<String> responseList = new List<String>();
	return responseList;
  }
  public static void TwnsqrPostDeal(Transactions__c trx) {
    system.debug('POSTDEAL');
    dealRequest dr = dealMaker(trx);
    dr.expiresAt = Date.today().addDays(30) + '';

    HttpResponse res = TwnsqrcallOut(
      '/api/v1/deals',
      'POST',
      JSON.serialize(dr, true)
    );
    if (res.getStatusCode() == 200) {
      system.debug(res.getBody());
      Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(
        res.getBody()
      );
      trx.Twnsqr_clientId__c = results.get('clientId') + '';
      LeftMain_SecurityUtils.checkUpdate(Transactions__c.SObjectType,new List<String> {'Twnsqr_clientId__c'});

      List<Transactions__c> listTransactions = new List<Transactions__c>();
      listTransactions.add(trx);

      SObjectAccessDecision decision1 = Security.stripInaccessible(AccessType.UPDATABLE, listTransactions);
      List<Database.SaveResult> myResult = Database.update(listTransactions = decision1.getRecords());

    } else {
      insertError(res, 'TwnsqrCallOut.TwnsqrPostDeal');
    }
  }
  public static void TwnsqrPutDeal(Transactions__c trx, String action) {
    dealRequest dr = dealMaker(trx);
    if (action == 'RECHECK') {
      dr.expiresAt = Date.today().addDays(30) + '';
    }
    if (action == 'UNCHECK') {
      dr.expiresAt = Date.today() + '';
    }

    HttpResponse res = TwnsqrcallOut(
      '/api/v1/deals/' + dr.externalRef,
      'PUT',
      JSON.serialize(dr, true)
    );
    if (res.getStatusCode() != 200) {
      insertError(res, 'TwnsqrCallOut.TwnsqrPutDeal');
    }
  }
  public static HttpResponse TwnsqrcallOut(
    String endpoint,
    String method,
    String body
  ) {
    List<Twnsqr_Config__c> lstConfig = [
      SELECT Id, baseURL__c, token__c
      FROM Twnsqr_Config__c WITH USER_MODE LIMIT 10000
    ];

    // Instantiate a new Http object
    Http h = new Http();
    // Instantiate a new HTTP request.
    HttpRequest req = new HttpRequest();
    req.setEndpoint(lstConfig[0].baseURL__c + endpoint);
    req.setMethod(method);

    if (body != null) {
      req.setBody(body);
    }
    // Add your custom header
    req.setHeader('x-api-key', lstConfig[0].token__c); // Replace with your actual custom header and value
    req.setHeader('Content-Type', 'application/json'); // Replace with your actual custom header and value

    // Send the request, and return a response
    HttpResponse res = h.send(req);
    return res;
  }
  public static void insertError(HttpResponse res, String method) {
    insert ErrorHandler_cls.insertErrorHandler(
      'The status code returned was not expected: ' +
        res.getStatusCode() +
        ' ' +
        res.getStatus() +
        res.getBody(),
      method
    );
  }
  public static dealRequest dealMaker(Transactions__c trx) {
    dealRequest dr = new dealRequest();
    return dr;
  }

  public class dealRequest {
    String description;
    Double price;
    String photosLink;
    String address;
    String externalRef;
    String expiresAt;
  }

  public class configWrapper {
    String crm;
    config config;
  }
  public class config {
    String salesforceOrgID;
  }
}