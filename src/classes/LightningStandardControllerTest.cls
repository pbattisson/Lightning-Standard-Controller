/**
  * @author:        Paul Battisson (@pbattisson)
  * @description:   Test class for the LightningStandardController class.
  */
@isTest
private class LightningStandardControllerTest {

    private static final String testAccountName = 'Test Account';
    private static final String testAccountSite = 'Some site';
    private static final String testAccountNumber = '1234';
    private static final Integer testAccountNumberOfEmployees = 1000;
    private static Account acc = new Account(Name = testAccountName, AccountNumber = testAccountNumber, Site = testAccountSite, NumberOfEmployees = testAccountNumberOfEmployees);
	
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

    @isTest
    private static void testQueryWithAndFilterMap() {
        insert acc;

        LightningStandardController.LightningStandardQueryFilters filters = new LightningStandardController.LightningStandardQueryFilters();

        filters.ls_and = new Map<String, Object>{'Name' => testAccountName, 'AccountNumber' => testAccountNumber};

        List<Account> accs = (List<Account>)LightningStandardController.query('Account', new List<String>{ 'Id', 'Name', 'AccountNumber' }, filters);

        System.assertEquals(1, accs.size());
        System.assertEquals(testAccountName, accs[0].Name);
        System.assertEquals(testAccountNumber, accs[0].AccountNumber);
        System.assertEquals(acc.Id, accs[0].Id);
    }

    @isTest
    private static void testQueryWithOrFilterMap() {
        insert acc;

        LightningStandardController.LightningStandardQueryFilters filters = new LightningStandardController.LightningStandardQueryFilters();

        filters.ls_or = new Map<String, Object>{'Name' => testAccountName, 'AccountNumber' => testAccountNumber};

        List<Account> accs = (List<Account>)LightningStandardController.query('Account', new List<String>{ 'Id', 'Name', 'AccountNumber' }, filters);

        System.assertEquals(1, accs.size());
        System.assertEquals(testAccountName, accs[0].Name);
        System.assertEquals(testAccountNumber, accs[0].AccountNumber);
        System.assertEquals(acc.Id, accs[0].Id);
    }

    @isTest
    private static void testQueryWithInFilterMap() {
        insert acc;

        LightningStandardController.LightningStandardQueryFilters filters = new LightningStandardController.LightningStandardQueryFilters();

        filters.ls_in = new Map<String, Object>{'Name' => new List<String>{testAccountName}};

        List<Account> accs = (List<Account>)LightningStandardController.query('Account', new List<String>{ 'Id', 'Name', 'AccountNumber' }, filters);

        System.assertEquals(1, accs.size());
        System.assertEquals(testAccountName, accs[0].Name);
        System.assertEquals(testAccountNumber, accs[0].AccountNumber);
        System.assertEquals(acc.Id, accs[0].Id);
    }

    @isTest
    private static void testComplexFilterQueryAndOr() {
        insert acc;

        LightningStandardController.LightningStandardQueryFilters filters = new LightningStandardController.LightningStandardQueryFilters();

        filters.ls_and = new Map<String, Object>{'Name' => testAccountName, 'Site' => testAccountSite};
        filters.ls_or = new Map<String, Object>{'AccountNumber' => '321', 'AccountNumber' => testAccountNumber};

        List<Account> accs = (List<Account>)LightningStandardController.query('Account', new List<String>{ 'Id', 'Name', 'AccountNumber', 'Site' }, filters);

        System.assertEquals(1, accs.size());
        System.assertEquals(testAccountName, accs[0].Name);
        System.assertEquals(testAccountNumber, accs[0].AccountNumber);
        System.assertEquals(testAccountSite, accs[0].Site);
        System.assertEquals(acc.Id, accs[0].Id);
    }

    @isTest
    private static void testComplexFilterQueryAndIn() {
        insert acc;

        LightningStandardController.LightningStandardQueryFilters filters = new LightningStandardController.LightningStandardQueryFilters();

        filters.ls_and = new Map<String, Object>{'AccountNumber' => testAccountNumber, 'Site' => testAccountSite};
        filters.ls_in = new Map<String, Object>{'Name' => new List<String>{testAccountName}};

        List<Account> accs = (List<Account>)LightningStandardController.query('Account', new List<String>{ 'Id', 'Name', 'AccountNumber', 'Site' }, filters);

        System.assertEquals(1, accs.size());
        System.assertEquals(testAccountName, accs[0].Name);
        System.assertEquals(testAccountNumber, accs[0].AccountNumber);
        System.assertEquals(testAccountSite, accs[0].Site);
        System.assertEquals(acc.Id, accs[0].Id);
    }

    @isTest
    private static void testComplexFilterQueryOrIn() {
        insert acc;

        LightningStandardController.LightningStandardQueryFilters filters = new LightningStandardController.LightningStandardQueryFilters();

        filters.ls_or = new Map<String, Object>{'AccountNumber' => '321', 'AccountNumber' => testAccountNumber};
        filters.ls_in = new Map<String, Object>{'Name' => new List<String>{testAccountName}};

        List<Account> accs = (List<Account>)LightningStandardController.query('Account', new List<String>{ 'Id', 'Name', 'AccountNumber', 'Site' }, filters);

        System.assertEquals(1, accs.size());
        System.assertEquals(testAccountName, accs[0].Name);
        System.assertEquals(testAccountNumber, accs[0].AccountNumber);
        System.assertEquals(testAccountSite, accs[0].Site);
        System.assertEquals(acc.Id, accs[0].Id);
    }

    @isTest
    private static void testComplexFilterQueryAndOrIn() {
        insert acc;

        LightningStandardController.LightningStandardQueryFilters filters = new LightningStandardController.LightningStandardQueryFilters();

        filters.ls_and = new Map<String, Object>{'NumberOfEmployees' => testAccountNumberOfEmployees, 'Site' => testAccountSite};
        filters.ls_or = new Map<String, Object>{'AccountNumber' => '321', 'AccountNumber' => testAccountNumber};
        filters.ls_in = new Map<String, Object>{'Name' => new List<String>{testAccountName, 'My Account'}};

        List<Account> accs = (List<Account>)LightningStandardController.query('Account', new List<String>{ 'Id', 'Name', 'AccountNumber', 'Site' }, filters);

        System.assertEquals(1, accs.size());
        System.assertEquals(testAccountName, accs[0].Name);
        System.assertEquals(testAccountNumber, accs[0].AccountNumber);
        System.assertEquals(testAccountSite, accs[0].Site);
        System.assertEquals(acc.Id, accs[0].Id);
    }

    @isTest
    private static void testQueryWithAndFilterInvalidType() {
        insert acc;

        LightningStandardController.LightningStandardQueryFilters filters = new LightningStandardController.LightningStandardQueryFilters();

        filters.ls_and = new Map<String, Object>{'Name' => testAccountName, 'CreatedDate' => new List<String>{testAccountName, 'My Account'} };

        try {
            List<Account> accs = (List<Account>)LightningStandardController.query('Account', new List<String>{ 'Id', 'Name', 'AccountNumber' }, filters);
            System.assert(false, 'Error should be thrown');
        } catch(LightningStandardController.LightningStandardControllerException lex) {
            System.assertEquals(Label.Invalid_Filter_Type, lex.getMessage());
        }
    }

    @isTest
    private static void testComplexQueryWithEmptyFieldListError() {
        insert acc;

        LightningStandardController.LightningStandardQueryFilters filters = new LightningStandardController.LightningStandardQueryFilters();

        filters.ls_and = new Map<String, Object>{'NumberOfEmployees' => testAccountNumberOfEmployees, 'Site' => testAccountSite};
        filters.ls_or = new Map<String, Object>{'AccountNumber' => '321', 'AccountNumber' => testAccountNumber};
        filters.ls_in = new Map<String, Object>{'Name' => new List<String>{testAccountName, 'My Account'}};

        try {
            List<Account> accs = (List<Account>)LightningStandardController.query('Account', new List<String>(), filters);
            System.assert(false, 'Error should be thrown');
        } catch(LightningStandardController.LightningStandardControllerException lex) {
            System.assertEquals(Label.Empty_Field_List_For_Query, lex.getMessage());
        }
    }

    @isTest
    private static void testComplexQueryWithNullFieldListError() {
        insert acc;

        LightningStandardController.LightningStandardQueryFilters filters = new LightningStandardController.LightningStandardQueryFilters();

        filters.ls_and = new Map<String, Object>{'NumberOfEmployees' => testAccountNumberOfEmployees, 'Site' => testAccountSite};
        filters.ls_or = new Map<String, Object>{'AccountNumber' => '321', 'AccountNumber' => testAccountNumber};
        filters.ls_in = new Map<String, Object>{'Name' => new List<String>{testAccountName, 'My Account'}};

        try {
            List<Account> accs = (List<Account>)LightningStandardController.query('Account', null, filters);
            System.assert(false, 'Error should be thrown');
        } catch(LightningStandardController.LightningStandardControllerException lex) {
            System.assertEquals(Label.Empty_Field_List_For_Query, lex.getMessage());
        }
    }

    @isTest
    private static void testQueryWithFilterMapDate() {
        insert acc;

        Test.setCreatedDate(acc.Id, Date.today());

        LightningStandardController.LightningStandardQueryFilters filters = new LightningStandardController.LightningStandardQueryFilters();

        filters.ls_or = new Map<String, Object>{'Name' => testAccountName, 'CreatedDate' => Date.today()};

        List<Account> accs = (List<Account>)LightningStandardController.query('Account', new List<String>{ 'Id', 'Name', 'AccountNumber' }, filters);

        System.assertEquals(1, accs.size());
        System.assertEquals(testAccountName, accs[0].Name);
        System.assertEquals(testAccountNumber, accs[0].AccountNumber);
        System.assertEquals(acc.Id, accs[0].Id);
    }
}