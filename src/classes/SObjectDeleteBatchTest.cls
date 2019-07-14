/**
 * @description Test class for SObjectDeleteBatch apex batch class.
 * @author Mark H. Morrison
 * @date Tues Jan 29 2019
 */
@isTest
private class SObjectDeleteBatchTest {

  @testSetup
  private static void setup() {
    Account testAccount = new Account(Name = 'Test Account');
    insert testAccount;
    System.assertNotEquals(null, testAccount.Id, 'Insert testAccount failed');

    Contact testContact = new Contact(
      AccountId = testAccount.Id,
      FirstName = 'First',
      LastName  = 'Last'
    );
    insert testContact;
    System.assertNotEquals(null, testContact.Id, 'Failed to insert testContact');
    
    Task[] testTasks = new Task[]{};
    for(Integer i = 0; i < 200; i++) {
      Task testTask = new Task(
        ActivityDate = System.today() - 2882,
        WhoId        = testContact.Id,
        Type         = 'Other',
        Subject      = 'Test Task',
        Status       = 'Not Started',
        Priority     = 'Normal'
      );
      testTasks.add(testTask);
    }
    for(Integer i = 0; i < 200; i++) {
      Task testTask = new Task(
        ActivityDate = System.today() - 2879,
        WhoId        = testContact.Id,
        Type         = 'Other',
        Subject      = 'Test Task',
        Status       = 'Not Started',
        Priority     = 'Normal'
      );
      testTasks.add(testTask);
    }
    insert testTasks;
    System.assertNotEquals(null, testTasks[14].Id, 'Insert testTasks failed');

    Event[] testEvents = new Event[]{};
    for(Integer i = 0; i < 150; i++) {
      Event testEvent = new Event(
        ActivityDateTime  = System.now() - 10000,
        Description       = 'Meeting',
        Subject           = 'Test Event',
        Location          = 'Office',
        DurationInMinutes = 60
      );
      testEvents.add(testEvent);
    }
    for(Integer i = 0; i < 150; i++) {
      Event testEvent = new Event(
        ActivityDateTime  = System.now() - 10000,
        Description       = 'Meeting',
        Subject           = 'Test Event',
        Location          = 'Off Site',
        DurationInMinutes = 60
      );
      testEvents.add(testEvent);
    }
    insert testEvents;
    System.assertNotEquals(null, testEvents[14].Id, 'Insert testEvents failed');
  }

  @isTest
  private static void when_UsingDateSaveBindSameAsBase() {
    Date dateSave = System.today() - 2880;
    String batchQuery = 'SELECT Id ' +
      'FROM Task ' +
      'WHERE ActivityDate < :dateSave';
    System.assertEquals(200, Database.query(batchQuery).size());
    Task[] preEvents = [
      SELECT Id FROM Task
    ];
    System.assertEquals(400, preEvents.size());

    Test.startTest();
      SObjectDeleteBatch batchProcess = new SObjectDeleteBatch(); 
      batchProcess.batchQuery = batchQuery;
      Database.executeBatch(batchProcess);
    Test.stopTest();

    Task[] postTasks = [
      SELECT Id FROM Task
    ];
    System.assertEquals(200, postTasks.size());
  }

  @isTest
  private static void when_UsingCustomSOQL() {
    Date dateSave = System.today() - 2880;
    String batchQuery = 'SELECT Id ' +
      'FROM Event ' +
      'WHERE Location = \'Off Site\'';
    System.assertEquals(150, Database.query(batchQuery).size());
    Event[] preEvents = [
      SELECT Id FROM Event
    ];
    System.assertEquals(300, preEvents.size());

    Test.startTest();
      SObjectDeleteBatch batchProcess = new SObjectDeleteBatch(); 
      batchProcess.batchQuery = batchQuery;
      Database.executeBatch(batchProcess);
    Test.stopTest();

    Event[] postEvents = [
      SELECT Id FROM Event
    ];
    System.assertEquals(150, postEvents.size());
  }
}