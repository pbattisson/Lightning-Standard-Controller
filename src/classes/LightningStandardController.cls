/**
  * @author:        Paul Battisson (@pbattisson)
  * @description:   This controller provides a standard set of functionality for use in Lightning Components similar to the 
  *                 Standard Controller provided for Visualforce.
  */
public with sharing class LightningStandardController {
    
    //String used to help in casting our input from a generic SObject
    private static String listStringTemplate = 'List<{0}>';

    /**
      * @description: Saves a single record of a specified type.
      * @param objectType The API name of the object we are saving, for example Account or Invoice__c.
      * @param record The SObject record we wish to save.
      * @return The Id of the saved record.
      */
    @AuraEnabled
    public static Id save(String objectType, SObject record) {
        return save(objectType, new List<SObject>{ record })[0];
    }

    /**
      * @description: Saves a list of record of a specified type.
      * @param objectType The API name of the object we are saving, for example Account or Invoice__c.
      * @param records The SObject records we wish to save.
      * @return The list of Ids of the saved records.
      */
    @AuraEnabled
    public static List<Id> save(String objectType, List<SObject> records) {
        Type listType = Type.forName(String.format(listStringTemplate, new List<String>{ objectType }));
        List<SObject> items = (List<SObject>)listType.newInstance();
        items.addAll(records);
        upsert items;

        List<Id> returnIds = new List<Id>();

        for(SObject item : items) {
            returnIds.add((Id)item.get('Id'));
        }

        return returnIds;
    }

    /**
      * @description Retrieves a list of records given a valid query string.
      * @param query The query string to execute.
      * @return The list of retrieved records.
      */
    @AuraEnabled
    public static List<SObject> query(String query) {
        return Database.query(query);
    }

    /**
      * @description Retrieves a list of records from the specified object with the requested fields
      * @param objectType The API name of the object we are saving, for example Account or Invoice__c.
      * @param fields A list of strings which are the API field names for the fields we wish to retrieve.
      * @return The list of retrieved records.
      */
    @AuraEnabled
    public static List<SObject> query(String objectType, List<String> fields) {
        if(fields == null || fields.size() == 0) {
            throw new LightningStandardControllerException(Label.Empty_Field_List_For_Query);
        }

        String query = 'SELECT ';

        for(String field : fields) {
            query += field + ',';
        }

        query = query.substring(0, query.length() - 1) + ' FROM ' + objectType;

        return query(query);
    }

    /**
      * @description Custom exception class for the Lightning Standard Controller system.
      */
    public class LightningStandardControllerException extends Exception {

    }
}