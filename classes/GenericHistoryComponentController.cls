public class GenericHistoryComponentController 
{
    public Id parentId { get; set; }
    public Integer recordLimit {get; set;}
    public static String objectLabel {get;}
    
    public objectHistoryLine[] objectHistory; 

    //public static final Map<String, Schema.SObjectType> mySObjectTypeMap = Schema.getGlobalDescribe();
    public static Map<String, Schema.SObjectField> myObjectFieldMap;
    public static List<Schema.PicklistEntry> historyFieldPicklistValues;
    
    public List<objectHistoryLine> getObjectHistory()
    {
        if (parentId == null) 
        {
            return new List<objectHistoryLine>();
        }

        Schema.DescribeSObjectResult objectDescription = parentId.getSObjectType().getDescribe();

        myObjectFieldMap = objectDescription.fields.getMap();
        objectLabel = String.valueOf(objectDescription.getLabel());
        
        //Get the name of the history table
        String objectHistoryTableName = objectDescription.getName();
        
        //ID field name         
        string ObjectIdName;
        
        //if we have a custom object we need to drop the 'c' off the end before adding 'History' to get the history tables name        
        if (objectDescription.isCustom())
        {            
            objectHistoryTableName = objectHistoryTableName.substring(0, objectHistoryTableName.length()-1);
            ObjectIdName = 'ParentId';        
        }        
        else
        {
            ObjectIdName = objectHistoryTableName+ 'Id';
        }
        
        if(objectHistoryTableName == 'Opportunity') 
        {
            objectHistoryTableName = objectHistoryTableName + 'FieldHistory';
        }
        else 
        {
            objectHistoryTableName = objectHistoryTableName + 'History';
        }
        
        List<Schema.DescribeSObjectResult> descriptionTable = Schema.describeSObjects(new List<String> { objectHistoryTableName });
        Schema.DescribeFieldResult objectHistoryFieldField = descriptionTable[0].fields.getMap().get('Field').getDescribe();
        historyFieldPicklistValues = objectHistoryFieldField.getPickListValues();
                    
        list<objectHistoryLine> objectHistory = new list<objectHistoryLine>();
        
        String prevDate = '';
                
        if (recordLimit== null){
            recordLimit = 100;
        }
                
        list<sObject> historyList = Database.query( 'SELECT CreatedDate, CreatedById, Field, NewValue, OldValue ' +
                                                    'FROM ' + objectHistoryTableName + ' ' +
                                                    'WHERE ' + ObjectIdName + ' =\'' + parentId + '\' ' +
                                                    'ORDER BY CreatedDate DESC '+
                                                    'LIMIT ' + String.valueOf(recordLimit));
        
        for(Integer i = 0; i < historyList.size(); i++){
            sObject historyLine = historyList.get(i);
            if ((historyLine.get('newValue') == null && historyLine.get('oldValue') == null) 
                    || (historyLine.get('newValue') != null && !(historyLine.get('newValue') instanceOf Id))
                    || (historyLine.get('oldValue') != null && !(historyLine.get('oldValue') instanceOf Id))){
                objectHistoryLine tempHistory = new objectHistoryLine();
                // Set the Date and who performed the action
                if (String.valueOf(historyLine.get('CreatedDate')) != prevDate){
                    tempHistory.theDate = datetime.valueof(historyLine.get('CreatedDate')).format();
                    tempHistory.userId = String.valueOf(historyLine.get('CreatedById'));
                    tempHistory.who = String.valueOf(historyLine.get('CreatedById'));
                }
                else{
                    tempHistory.theDate = '';
                    tempHistory.who = '';
                    tempHistory.userId = String.valueOf(historyLine.get('CreatedById'));
                }
                prevDate = String.valueOf(historyLine.get('CreatedDate'));
                
                // Get the field label
                String fieldLabel = GenericHistoryComponentController.returnFieldLabel(String.valueOf(historyLine.get('Field')));
                
                // Set the Action value
                   if (String.valueOf(historyLine.get('Field')) == 'created') {    // on Creation
                       tempHistory.action = 'Created.';
                  }
                  else if (String.valueOf(historyLine.get('Field')) == 'opportunityCreatedFromLead') {    // on Creation
                       tempHistory.action = 'Created by lead convert.';
                  }
                  else if (historyLine.get('oldValue') != null && historyLine.get('newValue') == null){ // when deleting a value from a field
                      // Format the Date and if there's an error, catch it and re
                      try {
                         tempHistory.action = 'Deleted ' + Date.valueOf(historyLine.get('oldValue')).format() + ' in <b>' + fieldLabel + '</b>.';
                    } catch (Exception e){
                         tempHistory.action = 'Deleted ' + String.valueOf(historyLine.get('oldValue')) + ' in <b>' + fieldLabel + '</b>.';
                    }
                  }
                  else{  // all other scenarios
                    String fromText = '';
                    if (historyLine.get('oldValue') != null) {
                         try {
                              fromText = ' from ' + Date.valueOf(historyLine.get('oldValue')).format();
                         } catch (Exception e) {
                              fromText = ' from ' + String.valueOf(historyLine.get('oldValue'));
                         }
                    }
                    
                    String toText = '';
                    if (historyLine.get('newValue') != null) {
                        try {
                             toText = Date.valueOf(historyLine.get('newValue')).format();
                        } catch (Exception e) {
                             toText = String.valueOf(historyLine.get('newValue'));
                        }
                    }
                    if (toText != ''){
                        tempHistory.action = 'Changed <b>' + fieldLabel + '</b>' + fromText + ' to <b>' + toText + '</b>.';
                    }
                    else {
                        tempHistory.action = 'Changed <b>' + fieldLabel;
                    }
                   }
                   
                   // Add to the list
                   objectHistory.add(tempHistory);
            }
         }
         
         List<Id> userIdList = new List<Id>();
         for (objectHistoryLine myHistory : objectHistory){
             userIdList.add(myHistory.userId);
         }
         Map<Id, User> userIdMap = new Map<ID, User>([SELECT Name FROM User WHERE Id IN : userIdList]);
         
         for (objectHistoryLine myHistory : objectHistory){
             if (userIdMap.containsKey(myHistory.userId) & (myHistory.who != '') ){
                 myHistory.who = userIdMap.get(myHistory.who).Name;
             }
         }
         
         return objectHistory;
    }    
    
    // Function to return Field Label of a object field given a Field API name
    public Static String returnFieldLabel(String fieldName){

        if (GenericHistoryComponentController.myObjectFieldMap.containsKey(fieldName)){
            return GenericHistoryComponentController.myObjectFieldMap.get(fieldName).getDescribe().getLabel();
        }
        else {
            for(Schema.PicklistEntry pickList : historyFieldPicklistValues){
                if (pickList.getValue() == fieldName){
                    if (pickList.getLabel() != null){
                        return pickList.getLabel();
                    }
                    else {
                        return pickList.getValue();
                    }
                }
            }
        }
        return '';
    }
    
    // Inner Class to store the detail of the object history lines    
    public class objectHistoryLine {

        public String theDate {get; set;}
        public String who {get; set;}
        public Id userId {get; set;} 
        public String action {get; set;}
    }
}