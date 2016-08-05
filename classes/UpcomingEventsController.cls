/*
 * Base class for customer/partner upcoming events
 */
public abstract class UpcomingEventsController 
{
    public UpcomingEventsController()
    {
    }

    public List<EventInfo> AllEvents
    {
        get
        {
            List<EventInfo> result = new List<EventInfo>();
            Date currentDate = Date.today();
            List<Training_Events__c> entries = getEventsRecords();
            if(!entries.isEmpty()) 
            {
                for(Training_Events__c entry : entries)
                {
                    EventInfo event = new EventInfo();
                    event.EventId = entry.Id;
                    event.StartDate = (entry.Start_Date__c != null)?entry.Start_Date__c.format():'...';           
                    event.EndDate = (entry.End_Date__c != null)?entry.End_Date__c.format():'...';
                    event.Openings = entry.Openings__c;
                    event.SessionTime = entry.Session_Times__c;
                    event.Location = entry.Location__c;
                    event.MaximumAttendees = (entry.Maximum_Attendees__c == null) ? 0 : entry.Maximum_Attendees__c.intValue();
                    event.ConfirmedRegistrations = (entry.Confirmed_Registrations__c == null) ? 0 : entry.Confirmed_Registrations__c.intValue();
                    event.RegisteredAttendees = (entry.Registered_Attendees__c == null) ? 0 : entry.Registered_Attendees__c.intValue();
                    if(entry.Course_Name__r != null && String.isNotEmpty(entry.Course_Name__r.Description__c))
                    {                        
                        event.CourseName = entry.Course_Name__r.Name;
                        String stripDescription = entry.Course_Name__r.Description__c.stripHtmlTags();
                        String description = entry.Course_Name__r.Description__c;
                        if(stripDescription.length() <= 250)
                        {
                            event.Description = description;
                            event.SubDescription = stripDescription;
                        }
                        else
                        {
                            event.Description = description;
                            event.SubDescription = stripDescription.substring(0,250) + '……';
                        }
                    }
                    if(entry.Course_Name__r != null && String.isNotEmpty(entry.Location__c))
                    {                        
                        event.CourseName = entry.Course_Name__r.Name;
                        String stripLocation = entry.Location__c.stripHtmlTags();
                        String location = entry.Location__c;
                        if(stripLocation.length() <= 250)
                        {
                            event.Location = location.replace('\r\n', '</br>');
                            event.SubLocation = stripLocation;
                        }
                        else
                        {
                            event.Location = location.replace('\r\n', '</br>');
                            event.SubLocation = stripLocation.substring(0,250) + '……';
                        }
                    }                    
                    result.add(event);
                }
            }
            return result;
        }
    }
    
    public abstract List<Training_Events__c> getEventsRecords();
    
    //a custome class for event
    public class EventInfo
    {
        public EventInfo()
        {
            this.CourseName = '';
            this.Description = 'No Description for the course!';
            this.SubDescription = 'No Description for the course!';
        }
        public String EventId {get; set;}
        public String CourseName {get; set;}
        public String StartDate {get; set;}
        public String EndDate {get; set;}
        public String Openings { get; set; }
        public String Location { get; set; }
        public String SubLocation { get; set; }        
        public String SessionTime { get; set; }
        public String Description {get; set;}
        public String SubDescription {get; set;} 
        public Integer MaximumAttendees { get; set; }
        public Integer ConfirmedRegistrations { get; set; }
        public Integer RegisteredAttendees { get; set; }
    }
}