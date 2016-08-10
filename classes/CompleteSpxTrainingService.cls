/**
 * Contains a web service to set the 'Completed SPX Training' field on contact.
 */
global class CompleteSpxTrainingService 
{ 
    //Sets 'Completed SPX Training' field on contact whose is registered in the specified event to true  
    webService static Integer completeSpxTraining(String eventId) 
    {
        Set<Id> contactIds = new Set<Id>();
        List<Contact> contactsForUpdate = new List<Contact>(); 
              
        for(Training_Registration__c registration : [Select Attendee__c from Training_Registration__c Where Event__c =:eventId])
        {   
        	//Avoids the same and null of attendee       	        	
            if(!contactIds.contains(registration.Attendee__c) && registration.Attendee__c != null)
            {    
            	contactIds.add(registration.Attendee__c);           
                contactsForUpdate.add(new Contact(Id = registration.Attendee__c, Completed_SPX_Training__c = true));
            }
        }
        
        if(contactsForUpdate.size() > 0)
        {
            try
            {
                update contactsForUpdate;
            }
            catch(DMLException ex) 
            {
                throw new ApplicationException(ex.getMessage());
            }
        }
        
        return contactsForUpdate.size();
     }
    
    public Class ApplicationException extends Exception {}
    
    @isTest
    static void testChangeContactValue() 
    {
        Training_Events__c trainingEventInfo = new Training_Events__c(Name = 'traingName');
        insert trainingEventInfo;
        
        Contact contactInfo = new Contact(LastName = 'lastName');
        insert contactInfo;
        
        Training_Registration__c trainingRegInfo = new Training_Registration__c(Event__c = trainingEventInfo.Id, Attendee__c = contactInfo.Id);
        insert trainingRegInfo;     
                
        Integer changedCount = CompleteSpxTrainingService.completeSpxTraining(trainingEventInfo.Id);
        System.assertEquals(changedCount, 1);       
    }
    
}