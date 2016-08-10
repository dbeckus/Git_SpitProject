/*
 * Controller for pages: RegisterInformation, RegisterAuthorizationCode, RegisterResult
  */
public abstract class RegisterController 
{
    public RegisterController()
    {
        Registration = new Training_Registration__c(Polo_Shirt_Size__c='M');
        Social = 'No';
        Diet = 'No';
        Student = new Contact(LeadSource='Training Registration');
        EventId = Apexpages.currentPage().getParameters().get('event');
        Message = '';
        if(eventId != null && eventId != '')
        {
            List<Training_Events__c> events = [select Course_Name__r.Course_Code__c, Course_Name__r.Name, Session_Times__c, Start_Date__c, End_Date__c, Location__c, Openings__c from Training_Events__c where Id = :EventId limit 1];
            if(events.size() > 0)
            {
                TrainEvent = events[0];
            }
        }
    }
    
    public Training_Registration__c Registration { get; set; }
    public Contact Student { get; set; }
    public String AuthCode { get; set; }
    public Training_Events__c TrainEvent { get; set; }
    public String EventId { get; set; }
    public String Message { get; set; }
    public String Diet { get; set; }
    public String Social { get; set; }
    public String Company { get; set; }
    
    //input basic information
    public abstract PageReference GotoStep1();
    
    //input authorization code
    public abstract PageReference GotoStep2();
    
    //confirmation
    public abstract PageReference GotoStep3();
    
    protected void saveRegisterInformation()
    {
        List<AuthCode__c> codes = [select Id, Account__c, Account__r.Name, Course_Code__c, Valid__c, Expiration_Date__c from AuthCode__c where Authorization_Code__c = :AuthCode limit 1];
        if(codes.size() == 1)
        {
            if(codes[0].Account__c != null)
            {
                Company = codes[0].Account__r.Name;
            }
            if(TrainEvent != null && TrainEvent.Course_Name__r != null && TrainEvent.Course_Name__r.Course_Code__c != '')
            {
                if(validAuthCode(codes[0], TrainEvent.Course_Name__r.Course_Code__c))
                {
                    String email = Student.Email;
                    Contact newStudent = new Contact(LeadSource='Training Registration');
                    List<Contact> students = [select Id, FirstName, LastName, Phone from Contact where Email = :email limit 1];
                    if(students.size() == 1)
                    {
                        //existing contact, update the name and phone
                        newStudent = students[0];
                        newStudent.FirstName = student.FirstName;
                        newStudent.LastName = student.LastName;
                        newStudent.Phone = student.Phone;
                    }
                    else
                    {
                        //new contact
                        newStudent.FirstName = Student.FirstName;
                        newStudent.LastName = Student.LastName;
                        newStudent.Phone = student.Phone;
                        newStudent.Email = Student.Email;
                        newStudent.AccountId = codes[0].Account__c;
                    }
                    try
                    {
                        upsert newStudent;
                        Registration.Attendee__c = newStudent.Id;
                        Registration.Authorization__c = codes[0].Id;
                        Registration.Event__c = EventId;
                        //Registration.Name = (newStudent.FirstName == null)?'':newStudent.FirstName + ' ' + newStudent.LastName;
                        Registration.Diet__c = Diet;
                        Registration.Social__c = Social;
                        try
                        {
                            insert Registration;
                            Message = 'Your registration was completed successfully. You will receive an email confirmation once you are confirmed in the event.';
                        }
                        catch(Exception ex)
                        {
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'There was a problem completing your registration, please contact the Silver Peak Systems training department for assistance.'));
                        }
                    }
                    catch(Exception ex)
                    {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'There was a problem completing your registration, please contact the Silver Peak Systems training department for assistance.'));
                    }                    
                }
                else
                { 
                     Message = 'There was a problem completing your registration, please contact the Silver Peak Systems training department for assistance. The authorization code you entered is not valid for this course.';
                }
            }
            else
            {
                Message = 'There was a problem completing your registration, please contact the Silver Peak Systems training department for assistance.';
            }
        }
        else
        {
            Message = 'There was a problem completing your registration, please contact the Silver Peak Systems training department for assistance. The authorization code you entered is not valid.';
        }
    }
    
    //validate if the auth code is valid and equals to the course code
    protected Boolean validAuthCode(AuthCode__c code, String courseCode)
    {
        Boolean isValid = false;
        if(code.Valid__c == true)
        {
            if(code.Course_Code__c == courseCode && (code.Expiration_Date__c == null || code.Expiration_Date__c >= Date.today()))
            {
                isValid = true;
            }
        }
        return isValid;
    }
}