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
    public static List<SObject> runQuery(String query) {
        return Database.query(query);
    }

    /**
      * @description Retrieves a list of records from the specified object with the requested fields
      * @param objectType The API name of the object we are saving, for example Account or Invoice__c.
      * @param fields A list of strings which are the API field names for the fields we wish to retrieve.
      * @return The list of retrieved records.
      */
    public static List<SObject> query(String objectType, List<String> fields) {
        if(fields == null || fields.size() == 0) {
            throw new LightningStandardControllerException(Label.Empty_Field_List_For_Query);
        }

        String query = 'SELECT ';

        for(String field : fields) {
            query += field + ',';
        }

        query = query.substring(0, query.length() - 1) + ' FROM ' + objectType;

        return runQuery(query);
    }

    /**
      * @description Retrieves a list of records from the specified object with the requested fields
      * @param objectType The API name of the object we are saving, for example Account or Invoice__c.
      * @param fields A list of strings which are the API field names for the fields we wish to retrieve.
      * @param filters A map of field names to filter values.
      * @return The list of retrieved records.
      */
    @AuraEnabled
    public static List<SObject> query(String objectType, List<String> fields, Map<String, Object> and_filters, Map<String, Object> or_filters, Map<String, Object> in_filters) {
        
        if(and_filters == null && or_filters == null && in_filters == null) {
            return query(objectType, fields);
        }

        and_filters = and_filters == null ? new Map<String, Object>() : (Map<String, Object>)and_filters;
        or_filters = or_filters == null ? new Map<String, Object>() : (Map<String, Object>)or_filters;
        in_filters = in_filters == null ? new Map<String, Object>() : (Map<String, Object>)in_filters;

        if(fields == null || fields.size() == 0) {
            throw new LightningStandardControllerException(Label.Empty_Field_List_For_Query);
        }

        String query = 'SELECT ';

        for(String field : fields) {
            query += field + ',';
        }

        query = query.substring(0, query.length() - 1) + ' FROM ' + objectType;

        if(!and_filters.isEmpty() || !or_filters.isEmpty() || !in_filters.isEmpty()) {
            query += ' WHERE ';
        }

        if(!and_filters.isEmpty()) {
            for(String key : and_filters.keySet()) {
                query += buildFilterString(key, and_filters.get(key)) + ' AND ';
            }
            query = query.substring(0, query.length() - 4);
        }

        if(!or_filters.isEmpty()) {
            query += and_filters.isEmpty() ? '' : ' AND '; 
            query += '(';
            for(String key : or_filters.keySet()) {
                query += buildFilterString(key, or_filters.get(key)) + ' OR ';
            }
            query = query.substring(0, query.length() - 4) + ')';
        }

        if(!in_filters.isEmpty()) {
            query += and_filters.isEmpty() && or_filters.isEmpty() ? '' : ' AND ';
            for(String key : in_filters.keySet()) {
                query += buildInFilterString(key, (List<String>)in_filters.get(key)) + ' AND ';
            }
            query = query.substring(0, query.length() - 4);
        }

        return runQuery(query);
    }

    /**
      * @description This method takes a field name and value and creates a filter string to use.
      * @param fieldName This name of the field we are filtering on.
      * @param value The value we are trying to equate to.
      * @return A correctly formatted string for use in the query string.
      */
    private static String buildFilterString(String fieldName, Object value) {
        String filter = fieldName + ' = ';

        if(value instanceof Boolean || value instanceof Blob || value instanceof Integer || value instanceof Long || value instanceof Decimal)
        {
            filter += value;
        } else if(value instanceof Id || value instanceof String) {
            filter += '\'' + value + '\'';
        } else if (value instanceof Date || value instanceof Datetime) { 
            filter += ((Datetime)value).format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
        } else {
            throw new LightningStandardControllerException(Label.Invalid_Filter_Type);
        }
        
        return filter;
    }

    /**
      * @description This method takes a field name and value and creates a filter string to use.
      * @param fieldName This name of the field we are filtering on.
      * @param values The list value we are trying to find our value in.
      * @return A correctly formatted string for use in the query string.
      */
    private static String buildInFilterString(String fieldName, List<String> values) {
        String filter = fieldName + ' in ' + '(';
            
        for(String value : values) {
            filter += '\'' + value + '\',';
        }

        filter = filter.substring(0, filter.length() - 1) + ')';

        return filter;
    }

    /**
      * @description Custom exception class for the Lightning Standard Controller system.
      */
    public class LightningStandardControllerException extends Exception {

    }
}