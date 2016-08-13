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
      * @description Retrieves a list of records from the specified object with the requested fields
      * @param objectType The API name of the object we are saving, for example Account or Invoice__c.
      * @param fields A list of strings which are the API field names for the fields we wish to retrieve.
      * @param filters A map of field names to filter values.
      * @return The list of retrieved records.
      */
    @AuraEnabled
    public static List<SObject> query(String objectType, List<String> fields, LightningStandardQueryFilters filters) {
        if(fields == null || fields.size() == 0) {
            throw new LightningStandardControllerException(Label.Empty_Field_List_For_Query);
        }

        String query = 'SELECT ';

        for(String field : fields) {
            query += field + ',';
        }

        query = query.substring(0, query.length() - 1) + ' FROM ' + objectType;

        if(filters.hasFilters()) {
            query += ' WHERE ';
        }

        System.debug('PAULx ' + filters.ls_and.isEmpty() + ':: ' + filters.ls_and);

        if(!filters.ls_and.isEmpty()) {
            for(String key : filters.ls_and.keySet()) {
                query += buildFilterString(key, filters.ls_and.get(key)) + ' AND ';
            }
            query = query.substring(0, query.length() - 4);
        }

        if(!filters.ls_or.isEmpty()) {
            query += filters.ls_and.isEmpty() ? '' : ' AND '; 
            query += '(';
            for(String key : filters.ls_or.keySet()) {
                query += buildFilterString(key, filters.ls_or.get(key)) + ' OR ';
            }
            query = query.substring(0, query.length() - 4) + ')';
        }

        if(!filters.ls_in.isEmpty()) {
            query += filters.ls_and.isEmpty() && filters.ls_or.isEmpty() ? '' : ' AND ';
            for(String key : filters.ls_in.keySet()) {
                query += buildInFilterString(key, (List<String>)filters.ls_in.get(key)) + ' AND ';
            }
            query = query.substring(0, query.length() - 4);
        }

        System.debug('PAUL: ' + query);

        return query(query);
    }


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

    private static String buildInFilterString(String fieldName, List<String> values) {
        String filter = fieldName + ' in ' + '(';
            
        for(String value : values) {
            filter += '\'' + value + '\',';
        }

        filter = filter.substring(0, filter.length() - 1) + ')';

        return filter;
    }

    /**
      * @description Filter object used to enable a flexible querying structure for the 
      */
    public class LightningStandardQueryFilters {
        public Map<String, Object> ls_and = new Map<String, Object>();
        public Map<String, Object> ls_or = new Map<String, Object>();
        public Map<String, Object> ls_in = new Map<String, Object>();

        public Boolean hasFilters() {
            return !ls_and.isEmpty() || !ls_or.isEmpty() || !ls_in.isEmpty();
        }
    }

    /**
      * @description Custom exception class for the Lightning Standard Controller system.
      */
    public class LightningStandardControllerException extends Exception {

    }
}