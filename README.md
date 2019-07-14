# SObjectDeleteBatch
## Batch file that will delete object records based on dynamic SOQL passed in.

Ever been up against your data storage limits?  

Ever wanted a quick way to delete a bunch of records?

### Today’s your lucky day!

With just a couple of apex class files we can have a batch process that we can feed a SOQL query to and it will delete the records pulled up with the query. Really, it’s mainly one file. But we have to have a test file for it so we get good code coverage and feel confident about what it is doing.

Now, by default, this will only delete Tasks that are over 7 years old. But if you can craft a SOQL query that can get you the Id’s of a certain object’s records… well then, you’re in business.  

With great power comes great responsibility. This isn’t a superpower, but it may feel like one. Be careful out there.

> ## Test all your SOQL queries before you feed them to the batch. Make sure they only pull the records you want deleted.

### Create New Files

There's only two, but do them in this order. Find them in the src folder of the repo.
- SObjectDeleteBatch
- SObjectDeleteBatchTest

### How do I use this thing?

Let's consult the Book of Armaments. Chapter two, verses nine to twenty one. 
> This shall blow your records to bits...  Then shalt thou count to two. No more, no less. Two shall be the number thou shalt count, and the number of thy counting shall be two.  

Well, there's at least two that I'll go over for thou... err, you.

#### Using anonymous apex.

You can run this batch using the anonymous apex feature in different tools.  Developer Console, Workbench, or VS Code to name a couple.  Here’s the code:

```java
String batchQuery = 'SELECT Id FROM Account WHERE Name = \'test account\'';
SObjectDeleteBatch deleteBatch = new SObjectDeleteBatch();
deleteBatch.batchQuery = batchQuery;
Id batchProcessId = Database.executeBatch(deleteBatch);
```

#### Using Batch Runner

There is a declarative way you could run the batch.  Head over to my [Batch Runner](https://github.com/MarkHMorrison/BatchRunner) GitHub repo and check it out.


