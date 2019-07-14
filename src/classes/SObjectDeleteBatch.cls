/**
 * @description Batch to delete old data.
 * @author Mark H. Morrison
 * @date Tues Jan 29 2019
 */
global class SObjectDeleteBatch implements Database.Batchable<sObject>, Database.Stateful {
  global Integer recordsProcessed = 0;
  global Integer recordsNotProcessed = 0;
  global String errorMessages = '';
  global String batchQuery;

  global SObjectDeleteBatch() {
    batchQuery = 'SELECT Id ' +
      'FROM Task ' +
      'WHERE CreatedDate < :dateSave ' +
      'LIMIT 10000';
      // limit needs to stay below 10000 for propper looping to work.  If it pulls less that's fine.
      // increasing the limit requires changing the code on line 52 to corespond to even breakdown of 200 per batch
      // if limit is 50000 then it will run 250 batches
    System.debug('constructor batchQuery: ' + batchQuery);
  }

  global Database.QueryLocator start(Database.BatchableContext bc) {
    // set our save date almost 8 years out, saving the most recent 8 years of data
    Date dateSave = System.today() - 2880;
    System.debug('start batchQuery: ' + batchQuery);
    return Database.getQueryLocator(batchQuery);
  }

  global void execute(Database.BatchableContext bc, sObject[] scope){
    Database.DeleteResult[] deleteResults = Database.delete(scope,false);
    Integer recordId = 0;
    for(Database.DeleteResult deleteResult : deleteResults) {
      if(!deleteResult.isSuccess()) {
        errorMessages += '\n Object Record Id: ' + scope[recordId].Id;
        for(Database.Error error: deleteResult.getErrors()) errorMessages += '\n - ' + error.getMessage();
        recordsNotProcessed++;
      }
      recordsProcessed++;
      recordId++;
    }
  }

  global void finish(Database.BatchableContext bc){
    AsyncApexJob jobResult = [
      SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, ExtendedStatus
      FROM AsyncApexJob
      WHERE Id = :bc.getJobId()
    ];
    // these numbers need to be configured for SOQL limit devided by 200
    // TotalJobItems = SOQL limit devided by 200 and recordsProcessed = SOQL Limit
    Boolean runAgain = jobResult.TotalJobItems == 50 && recordsProcessed == 10000 ? true : false;
    Boolean sendEmail = runAgain && recordsNotProcessed > 0 ? true : false;
    
    if(sendEmail || !runAgain) {
      String textBody = '\n\nJob Items (Batches):';
      textBody += '\n - Total:     ' + jobResult.TotalJobItems;
      textBody += '\n - Processed: ' + jobResult.JobItemsProcessed;
      textBody += '\n - Errors:    ' + jobResult.NumberOfErrors;
      if(jobResult.ExtendedStatus != null) { textBody += '\n\n' + jobResult.ExtendedStatus; }
      textBody += '\n\nRecord Counts:';
      textBody += '\n - Total:  ' + recordsProcessed;
      textBody += '\n - Errors: ' + recordsNotProcessed;
      textBody += '\n' + errorMessages;
      textBody += '\n\nBatchQuery:\n' + batchQuery;

      Messaging.SingleEmailMessage emailMessage = new Messaging.SingleEmailMessage();
      emailMessage.setToAddresses(new String[] {'first.last@example.com'});
      emailMessage.setSubject(UserInfo.getOrganizationName() + ' SObjectDeleteBatch ' + jobResult.Status);
      emailMessage.setPlainTextBody(emailMessage.getSubject() + textBody);
      if(!Test.isRunningTest()) { Messaging.sendEmail(new Messaging.SingleEmailMessage[]{emailMessage}); }
      else { System.debug(emailMessage.getPlainTextBody()); }
    }
    if(runAgain) {
      SObjectDeleteBatch deleteBatch = new SObjectDeleteBatch();
      deleteBatch.batchQuery = batchQuery;
      Id batchProcessId = Database.executeBatch(deleteBatch);
    }
  }
}