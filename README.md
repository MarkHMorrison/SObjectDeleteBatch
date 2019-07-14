# SObjectDeleteBatch
## Batch file that will delete object records based on dynamic SOQL passed in.

Ever been up against your data storage limits?  

Ever wanted a quick way to delete a bunch of records?

Today’s your lucky day!

With just a couple of apex class files we can have a batch process that we can feed a SOQL query to and it will delete the records pulled up with the query. Really, it’s mainly one file. But we have to have a test file for it so we get good code coverage and feel confident about what it is doing.

Now, by default, this will only delete Tasks that are over 7 years old. But if you can craft a SOQL query that can get you the Id’s of a certain object’s records… well then, you’re in business.  

With great power comes great responsibility. This isn’t a superpower, but it may feel like one. Be careful out there.

> ## Test all your SOQL queries before you feed them to the batch. Make sure they only pull the records you want deleted.

### Create New Files

There's only two, but do them in this order. Find them in the src folder of the repo.
- SObjectDeleteBatch
- SObjectDeleteBatchTest


