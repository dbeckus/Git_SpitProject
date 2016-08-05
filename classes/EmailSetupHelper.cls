public  class EmailSetupHelper 
{
    public static EmailSetupInfo getEmailSetup(String setupName)
    {
        if(setupName != null && setupName != '')
        {
            List<EmailSetup__c> emailSetups = [select Id, Name, Delimiter__c, Drop_Email_From__c, Spam_Keywords__c, Case_Record_Type__c from EmailSetup__c where Name = :setupName limit 1];
            if(emailSetups.size() > 0)
            {
                EmailSetup__c tempEmailSetup = emailSetups.get(0);
                EmailSetupInfo info = new EmailSetupInfo(tempEmailSetup.Name, tempEmailSetup.Drop_Email_From__c, tempEmailSetup.Spam_Keywords__c, tempEmailSetup.Delimiter__c, tempEmailSetup.Case_Record_Type__c);
                return info;
            }
        }
        return new EmailSetupInfo();        
    }
    
    public class EmailSetupInfo
    {
        public String name {get; set; }
        public List<String> dropEmailList {get; set; }
        public List<String> spamKeywordList {get; set; }
        public String delimiter {get; set; }
        public String caseRecordType {get; set; }
        public String caseRecordTypeId {get; set; }
        
        public EmailSetupInfo(){}
        public EmailSetupInfo(String name, String dropEmails, String spamKeywords, String delimiter, String recordType)
        {
                this.name = name;
                this.delimiter = delimiter;
                this.dropEmailList = generateList(dropEmails);
                this.spamKeywordList = generateList(spamKeywords); 
                this.caseRecordType = recordType;
                
                List<RecordType> recordTypes = [select Id from RecordType where Name = :recordType and sObjectType='Case' limit 1];
                if(recordTypes.size() > 0)
                {
                    this.caseRecordTypeId = recordTypes.get(0).Id;
                }
        }
        
        private List<String> generateList(String input)
        {
            if(input != null && input != '')
            {
                List<String> splitResult = input.split('(\r\n)|\r|\n');
                return splitResult;
            }
            return new List<String>();
        }
    }
    
    @isTest
    static void testEmailSetupHelper()
    {
        EmailSetup__c testEmailSetup = new EmailSetup__c();
        testEmailSetup.Name = 'acmeName';
        testEmailSetup.Delimiter__c = '<------>';
        testEmailSetup.Drop_Email_From__c = 'acme1@acme.com\nacme2@acme.com\nacme3@acme.com\nacme4@acme.com';
        testEmailSetup.Spam_Keywords__c = 'mail delivery failure\nacme spam email\nout of office';
        testEmailSetup.Case_Record_Type__c = 'Technical Support';
        insert testEmailSetup;
        
        EmailSetupHelper.EmailSetupInfo info = EmailSetupHelper.getEmailSetup('acmeName');
        System.assertEquals('acmeName', info.name);
        System.assertEquals('<------>', info.delimiter);
        System.assertEquals(4, info.dropEmailList.size());
        System.assertEquals(3, info.spamKeywordList.size());
        System.assertEquals('Technical Support', info.caseRecordType);
    }
    
    @isTest
    static void testGenerateList()
    {
        EmailSetupInfo esi = new EmailSetupInfo();
        System.assertEquals(3, esi.generateList('a\r\nb\r\nc').size());
        System.assertEquals(3, esi.generateList('a\nb\nc').size());
        System.assertEquals(3, esi.generateList('a\rb\rc').size());
    }
}