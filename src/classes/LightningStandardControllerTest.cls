/**
  * @author:        Paul Battisson (@pbattisson)
  * @description:   Test class for the LightningStandardController class.
  */
@isTest
private class LightningStandardControllerTest {

    private static final String testAccountName = 'Test Account';
    private static Account acc = new Account(Name = testAccountName);
	
	@isTest 
    private static void testSaveSingle() {
        Id recordId = LightningStandardController.save('Account', acc);

        System.assertNotEquals(null, recordId, 'Null record Id returned.');
	}

    @isTest 
    private static void testSaveMultiple() {
        Account acc2 = new Account();
        acc2.Name = 'Test Account2';

        List<Id> recordIds = LightningStandardController.save('Account', new List<Account>{ acc, acc2 });

        for(Id recordId : recordIds) {
            System.assertNotEquals(null, recordId, 'Null record Id returned.');    
        }
    }

    @isTest
    private static void testQuery() {
        insert acc;

        List<Account> accs = (List<Account>)LightningStandardController.query('SELECT Id, Name FROM Account');

        System.assertEquals(1, accs.size());
        System.assertEquals(testAccountName, accs[0].Name);
        System.assertEquals(acc.Id, accs[0].Id);
    }

    @isTest
    private static void testQueryWithFieldList() {
        insert acc;

        List<Account> accs = (List<Account>)LightningStandardController.query('Account', new List<String>{ 'Id', 'Name' });

        System.assertEquals(1, accs.size());
        System.assertEquals(testAccountName, accs[0].Name);
        System.assertEquals(acc.Id, accs[0].Id);
    }

    @isTest
    private static void testQueryWithEmptyFieldListError() {
        insert acc;

        try {
            List<Account> accs = (List<Account>)LightningStandardController.query('Account', new List<String>());
            System.assert(false, 'Error should be thrown');
        } catch(LightningStandardController.LightningStandardControllerException lex) {
            System.assertEquals(Label.Empty_Field_List_For_Query, lex.getMessage());
        }
    }

    @isTest
    private static void testQueryWithNullFieldListError() {
        insert acc;

        try {
            List<Account> accs = (List<Account>)LightningStandardController.query('Account', null);
            System.assert(false, 'Error should be thrown');
        } catch(LightningStandardController.LightningStandardControllerException lex) {
            System.assertEquals(Label.Empty_Field_List_For_Query, lex.getMessage());
        }
    }
}