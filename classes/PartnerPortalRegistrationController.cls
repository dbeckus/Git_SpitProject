public class PartnerPortalRegistrationController
{
    // Constructor
    public PartnerPortalRegistrationController()
    {
        pap = new Partner_Account_Profile__c();
        List<RecordType> resellers = [select Id from RecordType where Name='Resellers' and SObjectType='Account' limit 1];
        acc = new Account(RecordTypeId=((resellers.size() > 0) ? resellers[0].Id : null));
        con = new Contact(LeadSource='Partner Portal');
        pbc = new Contact(LeadSource='Partner Portal');
        hq = new Partner_Portal_Account_Profile_Address__c(Type__c = 'Headquarter');
        phqc = new Partner_Portal_Account_Profile_Address__c(Type__c = 'Primary HQ Contact');
        pmc  = new Partner_Portal_Account_Profile_Address__c(Type__c = 'Primary Marketing Contact');
        pcgmc = new Partner_Portal_Account_Profile_Address__c(Type__c = 'CEO/General Manager');
        ptc = new Partner_Portal_Account_Profile_Address__c(Type__c = 'Primary Technical Contact');
        psc = new Partner_Portal_Account_Profile_Address__c(Type__c = 'Primary Sales Contact');
        boi = new Partner_Portal_Account_Profile_Address__c(Type__c = 'Branch');
        pcp = new Partner_Contact_Profile__c();
        page = 0;
    }
    
    // Properties
    public Integer page { get; private set; }
    
    public Partner_Account_Profile__c pap { get; set; }
    
    public Account acc { get; set; }
    
    public Contact con { get; set; }
    
    public Contact pbc { get; set; }
    
    public Partner_Portal_Account_Profile_Address__c hq { get; set; }
    
    public Partner_Portal_Account_Profile_Address__c phqc { get; set; }
    
    public Partner_Portal_Account_Profile_Address__c pmc { get; set; }
    
    public Partner_Portal_Account_Profile_Address__c pcgmc { get; set; }
    
    public Partner_Portal_Account_Profile_Address__c ptc { get; set; }
    
    public Partner_Portal_Account_Profile_Address__c psc { get; set; }
    
    public Partner_Portal_Account_Profile_Address__c boi { get; set; }
    
    public Partner_Contact_Profile__c pcp { get; set; }
    
    
    public List<SelectOption> goToMarketSalesModelItem
    {
        get
        {
            return getSelectOptions('Partner_Account_Profile__c', 'Go_To_Market_Sales_Model__c');
        }
    }
    
    public String[]  goToMarketSalesModelItemSetGet
    {
        get
        {
            return getMultiValue(pap.Go_To_Market_Sales_Model__c);
        }
        set
        {
            setMultiValue(value, pap, 'Go_To_Market_Sales_Model__c');
        }
    }
    
    public List<SelectOption> marketingSegmentsServedItem
    {
        get
        {
            return getSelectOptions('Partner_Account_Profile__c', 'Marketing_Segments_Served__c');
        }
    }
    
    public String[]  marketingSegmentsServedSetGet
    {
        get
        {
            return getMultiValue(pap.Marketing_Segments_Served__c);
        }
        set
        {
            setMultiValue(value, pap, 'Marketing_Segments_Served__c');
        }
    }
    
    public List<SelectOption> productCategoriesSoldItem
    {
        get
        {
            return getSelectOptions('Partner_Account_Profile__c', 'Product_Categories_Sold__c');
        }
    }
    
    public String[]  productCategoriesSoldSetGet
    {
        get
        {
            return getMultiValue(pap.Product_Categories_Sold__c);
        }
        set
        {
            setMultiValue(value, pap, 'Product_Categories_Sold__c');
        }
    }
    
    
    
    public List<SelectOption> silverPeakProductsSoldItem
    {
        get
        {
            return getSelectOptions('Partner_Account_Profile__c', 'Silver_Peak_Products_Sold__c');
        }
    }
    
    public String[]  silverPeakProductsSoldSetGet
    {
        get
        {
            return getMultiValue(pap.Silver_Peak_Products_Sold__c);
        }
        set
        {
            setMultiValue(value, pap, 'Silver_Peak_Products_Sold__c');
        }
    }
    
    public List<SelectOption> applicationsItem
    {
        get
        {
            return getSelectOptions('Partner_Account_Profile__c', 'Applications__c');
        }
    }
    
    public String[]  applicationsSetGet
    {
        get
        {
            return getMultiValue(pap.Applications__c);
        }
        set
        {
            setMultiValue(value, pap, 'Applications__c');
        }
    }
    
    public List<SelectOption> silverPeakCompetenciesItem
    {
        get
        {
            return getSelectOptions('Partner_Account_Profile__c', 'Silver_Peak_Competencies__c');
        }
    }
    
    public String[]  silverPeakCompetenciesSetGet
    {
        get
        {
            return getMultiValue(pap.Silver_Peak_Competencies__c);
        }
        set
        {
            setMultiValue(value, pap, 'Silver_Peak_Competencies__c');
        }
    }
    
    public List<SelectOption> professionalServicesOfferedItem
    {
        get
        {
            return getSelectOptions('Partner_Account_Profile__c', 'Professional_Services_Offered__c');
        }
    }
    
    public String[]  professionalServicesOfferedSetGet
    {
        get
        {
            return getMultiValue(pap.Professional_Services_Offered__c);
        }
        set
        {
            setMultiValue(value, pap, 'Professional_Services_Offered__c');
        }
    }
    
    public List<SelectOption> channelProgramsParticipatedItem
    {
        get
        {
            return getSelectOptions('Partner_Account_Profile__c', 'Channel_Programs_Participated__c');
        }
    }
    
    public String[]  channelProgramsParticipatedSetGet
    {
        get
        {
            return getMultiValue(pap.Channel_Programs_Participated__c);
        }
        set
        {
            setMultiValue(value, pap, 'Channel_Programs_Participated__c');
        }
    }
    
    public List<SelectOption> branchOfficeTypeItem
    {
        get
        {
            return getSelectOptions('Partner_Account_Profile__c', 'Branch_Office_Type__c');
        }
    }
    
    public String[]  branchOfficeTypeSetGet
    {
        get
        {
            return getMultiValue(pap.Branch_Office_Type__c);
        }
        set
        {
            setMultiValue(value, pap, 'Branch_Office_Type__c');
        }
    }
    
    public String distributionPartners{
        get{
            String result = '';
            result += groupWithBR(pap.Preferred_Distribution_Partner_1__c,pap.Preferred_Distribution_Partner_Acct_1__c);
            result += groupWithBR(pap.Preferred_Distribution_Partner_2__c,pap.Preferred_Distribution_Partner_Acct_2__c);
            result += groupWithBR(pap.Preferred_Distribution_Partner_3__c,pap.Preferred_Distribution_Partner_Acct_3__c);
            return result;
        }
    }
    
    public PageReference checkProfessionalServicesRender(){
        isProfessionalServicesRendered = !isProfessionalServicesRendered;
        return null;
    }
    
    public boolean isProfessionalServicesRendered  {get;set;} {isProfessionalServicesRendered = true;}
    
    // Methods 
    public void nextPage()
    {
        page++;
    }
    
    public void backPage(){
        page--;
    }
    
    public void resetPage(){
        page = 0;
    }
    
    public void savePage0(){
        hq.Email__c = con.Email;
        acc.GEO_Supported__c = hq.Region__c;
        if(acc.GEO_Supported__c == 'N. America')
        {
            acc.GEO_Supported__c = 'NAM';
        }
        nextPage();
    }
    
    public void savePage1(){
        hq.First_Name__c = con.FirstName;
        hq.Last_Name__c = con.LastName;

        nextpage();
    }
    
    public void savePage2(){
        acc.BillingStreet = hq.Address_1__c + '\r\n' + hq.Address_2__c;
        acc.BillingCity = hq.City__c;
        acc.BillingCountry = hq.Country__c;
        acc.BillingState = hq.State__c;
        acc.BillingPostalCode = hq.Postal_Code__c;
        acc.Phone = hq.Phone__c;
        acc.Fax = hq.Fax__c;
        nextpage();
    }
    
    public void savePage3(){
        pap.Address__c = hq.Address_1__c;
        pap.Address_2__c = hq.Address_2__c;
        pap.City__c = hq.City__c;
        pap.Country__c = hq.Country__c;
        pap.State__c = hq.State__c;
        pap.Postal_Code__c = hq.Postal_Code__c;
        pap.Phone__c = hq.Phone__c;
        pap.Fax__c = hq.Fax__c;
        nextpage();
    }
    
    public void savePage4(){
        nextpage();
    }
    
    public void savePage5(){
        
        SavePoint sp = Database.setSavePoint();
        try
        {
            acc.Type = 'Partner';
            acc.Partner_Type__c = 'Reseller';
            insert acc;
            con.AccountId = acc.id;
            pap.Account__c = acc.id;
            insert con;
            if(!sameContact(con,pbc))
            {
                pbc.AccountId = acc.id;
                insert pbc;
            }
            insert pap;
            hq.Partner_Account_Profile__c = pap.id;
            phqc.Partner_Account_Profile__c = pap.id;
            pmc.Partner_Account_Profile__c = pap.id;
            pcgmc.Partner_Account_Profile__c = pap.id;
            ptc.Partner_Account_Profile__c = pap.id;
            psc.Partner_Account_Profile__c = pap.id;
            boi.Partner_Account_Profile__c = pap.id;
            insert new List<Partner_Portal_Account_Profile_Address__c> { hq, phqc, pmc, pcgmc, ptc, psc, boi};
            pcp.Contact__c = con.id;
            insert pcp;
            sendNotification(pap.Id);
            nextPage();
        }
        catch(Exception ex)
        {
            Database.rollback(sp);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Failed to save'));
            ApexPages.addMessages(ex);
        }
    }
    
    public boolean sameContact(Contact a, Contact b)
    {
        Map<String, String> rules = new Map<String, String>();
        rules.put('FirstName','FirstName');
        rules.put('LastName','LastName');
        rules.put('Email','Email');
        return TriggerTools.sameObject(a, b, rules);
    }
    
    public void setPage0(){
        page = 0;
    }
    
    public void setPage1(){
        page = 1;
    }
    
    public void setPage2(){
        page = 2;
    }
    
    public void setPage3(){
        page = 3;
    }
    
    public void setPage4(){
        page = 4;
    }
    
    // Static Methods
    public static List<SelectOption> getSelectOptions(String objectName, String fieldName){
        List<SelectOption> result = new List<SelectOption>();
        List<Schema.DescribeSObjectResult> fieldDescs = Schema.describeSObjects(new List<String> { objectName });
        for(Schema.PicklistEntry entry : fieldDescs[0].fields.getMap().get(fieldName).getDescribe().getPicklistValues())
        {
            result.add(new SelectOption(entry.getValue(),entry.getValue()));
        }
        return result;
    }
    
    public static void setMultiValue(String[] values, sObject obj, String field){
        String result = '';
        for(String s : values){
            result += s + ';';
        }
        result = result.removeEnd(';');
        obj.put(field,result);
    }
    
    public static String[] getMultiValue(String values){
        if(values == null)
        {
            values = '';
        }
        return values.split(';[\\s]?');
    }
    
    public static String groupWithBR(String a, String b){
        String result = '';
        if(a!=null && b != null){
            result = a + ' (' + b + ')<br />';
        }
        return result;
    }
    
    private void sendNotification(Id accountId)
    {
        List<EmailTemplate> template = [select Id from EmailTemplate where DeveloperName='CommunitiesNewPartnerSignup' limit 1];
        if(template.size() > 0) 
        {
            Map<String, String> recipients = new Map<String, String> { 'NAM'=> 'NAapply@silver-peak.com', 'APAC' => 'APACapply@silver-peak.com', 'EMEA' => 'EMEAapply@silver-peak.com', 'LAT' => 'LATapply@silver-peak.com' };
            String recipientEmail = recipients.get(acc.GEO_Supported__c);
            recipientEmail = String.isBlank(recipientEmail) ? 'partner@silver-peak.com' : recipientEmail;
            Contact tc = new Contact(LastName='partners', Email=recipientEmail);
            insert tc;
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setTargetObjectId(tc.Id);
            mail.setUseSignature(false);
            mail.setCCAddresses(new List<String> {'partner@silver-peak.com'});
            List<OrgWideEmailAddress> address = [select Id from OrgWideEmailAddress where Address='notifications@silver-peak.com' limit 1];
            if(address.size() > 0)
            {
                mail.setOrgWideEmailAddressId(address[0].Id);
            }
            mail.setTemplateId(template[0].Id);
            mail.setWhatId(accountId);
            mail.setSaveAsActivity(false);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }, false);
            delete tc;
        }
    }
}