/*
*    Controller of Page OpportunityMerge
*/
public class OpportunityMergeController 
{
    private static Map<String, Schema.SObjectField> fieldResults;
    private static String basicSql;
    private static Map<String, Schema.DisplayType> Name2Type;
    private static List<String> fieldNames;
    private static List<String> fieldLabels;
    private static List<String> fieldParents;
    
    static
    {
        fieldResults = Schema.SObjectType.Opportunity.Fields.getMap();
        basicSql = 'select ';
        Name2Type = new Map<String, Schema.DisplayType>();
        fieldNames = new List<String>();
        fieldLabels = new List<String>();
        fieldParents = new List<String>();
        for(Schema.SObjectField sobjectField : fieldResults.values())
        {
            Schema.DescribeFieldResult describeField = sobjectField.getDescribe();
            if(describeField.isAccessible() && describeField.isUpdateable() && !(describeField.isAutoNumber() || describeField.isCalculated()))
            {
                basicSql += describeField.getName() + ', ';
                Name2Type.put(describeField.getName() + '', describeField.getType());
                fieldNames.add(describeField.getName() + '');
                fieldLabels.add(describeField.getLabel() + '');
                fieldParents.add((describeField.getReferenceTo().size() > 0) ? describeField.getReferenceTo()[0] + '' : '');
            }
        }
        basicSql = basicSql.subString(0, basicSql.length() - 2);
    }
    
    public OpportunityMergeController()
    {
        Id masterOppId = ApexPages.currentPage().getParameters().get('op1');
        Id childOppId = ApexPages.currentPage().getParameters().get('op2');
        
        initOpps(masterOppId, childOppId);
        
        LeftOppName = LeftOpp.Name.replaceAll('\'', '&#39;').replaceAll('\"', '&quot;');
        RightOppName = RightOpp.Name.replaceAll('\'', '&#39;').replaceAll('\"', '&quot;');
    }
    
    public List<FieldComparisonInfo> ComparingFields { get; set; }
    public Opportunity LeftOpp { get; set; }
    public Opportunity RightOpp { get; set; }
    public String LeftOppName { get; set; }
    public String RightOppName { get; set; } 
    
    public PageReference mergeOpps()
    {
        List<FieldComparisonInfo> mergingFields = new List<FieldComparisonInfo>();
        Opportunity master = LeftOpp, losingOpp = RightOpp;
        Boolean OppChanged = false;
        for(FieldComparisonInfo field : ComparingFields)
        {
            if(field.fieldName == 'Master Record' && field.selectedSide == 'right')
            {
                master = RightOpp;
                losingOpp = LeftOpp;
                OppChanged = true;
            }
            
            if(field.needMerge)
            {
                mergingFields.add(field);
            }
        }
        
        Boolean copyQuote = false, copyLineItem = false, copyPartner = false, copyCompetitor = false;
        for(FieldComparisonInfo field : mergingFields)
        {
            if(field.fieldName == 'Products')
            {
                if((OppChanged && field.selectedSide == 'left') || (!OppChanged && field.selectedSide == 'right'))
                {
                    copyLineItem = true;
                }
            }
            else if(field.fieldName == 'Silver Peak Quotes')
            {
                if((OppChanged && field.selectedSide == 'left') || (!OppChanged && field.selectedSide == 'right'))
                {
                    copyQuote = true;
                }
            }
            else if(field.fieldName == 'Partners')
            {
                if((OppChanged && field.selectedSide == 'left') || (!OppChanged && field.selectedSide == 'right'))
                {
                    copyPartner = true;
                }
            }
            else if(field.fieldName == 'Competitors')
            {
                if((OppChanged && field.selectedSide == 'left') || (!OppChanged && field.selectedSide == 'right'))
                {
                    copyCompetitor = true;  
                }
            }
            else
            {
                master.put(field.fieldName, (field.selectedSide == 'left') ? LeftOpp.get(field.fieldName) : RightOpp.get(field.fieldName));
            }
        }
        
        SavePoint sp = Database.setSavePoint();
        try
        {
            if(copyLineItem)
            {
                processProducts(master.Id, losingOpp.Id);
            }
            
            if(copyQuote)
            {
                processQuotes(master.Id, losingOpp.Id);
            }
            
            if(copyPartner)
            {
                processPartners(master.Id, losingOpp.Id);
                master.put('Primary_Partner__c', losingOpp.get('Primary_Partner__c'));
                master.put('Registered_Partner__c', losingOpp.get('Registered_Partner__c'));
            }
            
            if(copyCompetitor)
            {
                processCompetitors(master.Id, losingOpp.Id);
            }
            
            combineOtherRelatedList(master.Id, losingOpp.Id);
            
            //ignore the validation rules
            master.Bypassing_Validation__c = true;
            
            update master;
            losingOpp.Surviving_Opportunity__c = master.Id;
            update losingOpp;
            ArchiveDeletedOpportunityController adoc = new ArchiveDeletedOpportunityController(new ApexPages.StandardController(losingOpp));
            adoc.archive();
        }
        catch(Exception e)
        {
            Database.rollback(sp);
            ApexPages.addMessages(e);
            return null;
        }
        
        /*try
{
//reset the mark
master.Bypassing_Validation__c = false;
update master;
}
catch(Exception e)
{
ApexPages.addMessages(e);
}*/
        return new PageReference('/' + master.Id);
    } 
    
    public PageReference prev()
    {
        return new PageReference('/apex/OpportunityChooseForMerge?Id=' + LeftOpp.Id);
    }
    
    public PageReference cancel()
    {
        return new PageReference('/' + LeftOpp.Id);
    }
    
    @future
    public static void removeOrphanedPOC()
    {
        try
        {
            delete [select Id from Request__c where Opportunity__c = null];
        }
        catch(Exception ex)
        {
        }
    }
    
    private void initOpps(Id oppId, Id mergeOppId)
    {
        Lead leftLead, rightLead;
        List<SObject> leftOpps = Database.query(basicSql + ' from Opportunity where Id = \'' + oppId + '\' limit 1');
        LeftOpp = (leftOpps.size() > 0) ? (Opportunity)leftOpps[0] : new Opportunity();
        List<Lead> LeftLeads = [select Id, Name from Lead where ConvertedOpportunityId = :LeftOpp.Id limit 1];
        LeftLead = (LeftLeads.size() > 0) ? LeftLeads[0] : null;
        
        List<SObject> rightOpps = Database.query(basicSql + ' from Opportunity where Id = \'' + mergeOppId + '\' limit 1');
        RightOpp = (rightOpps.size() > 0) ? (Opportunity)rightOpps[0] : new Opportunity();
        List<Lead> RightLeads = [select Id, Name from Lead where ConvertedOpportunityId = :RightOpp.Id limit 1];
        RightLead = (RightLeads.size() > 0) ? RightLeads[0] : null;
        
        ComparingFields = new List<FieldComparisonInfo>();
        String leftLeadField = (LeftLead == null) ? 'None' : '<a href="/' + LeftLead.Id+ '" target="_blank">' + LeftLead.Name + '</a>';
        String rightLeadField = (RightLead == null) ? 'None ' : '<a href="/' + RightLead.Id  +' " target="_blank">' + RightLead.Name + '</a> ';
        ComparingFields.add(new FieldComparisonInfo('Lead', 'Lead', leftLeadField, rightLeadField , false, false, false));
        if((LeftLead != null && RightLead != null) || (LeftLead == null && RightLead == null))
        {
            //RightOpp is appended with a blankspace because the value will be compared later. If the values of both sides are equivalent, that field won't show up.
            ComparingFields.add(new FieldComparisonInfo('Master Record', 'Master Record', LeftOpp.Name, RightOpp.Name + ' ', true, false, false));   
        }
        else
        {
            if(LeftLead == null && RightLead != null)
            {
                FieldComparisonInfo oppInfo = new FieldComparisonInfo('Master Record', 'Master Record', LeftOpp.Name, '<img src="/img/checkbox_checked.gif" alt="checked"/>' + RightOpp.Name, false, false, false);
                oppInfo.selectedSide = 'right';
                ComparingFields.add(oppInfo);
            }
            else
            {
                //left is from a lead.
                ComparingFields.add(new FieldComparisonInfo('Master Record', 'Master Record', '<img src="/img/checkbox_checked.gif" alt="checked"/>' + LeftOpp.Name, RightOpp.Name, false, false, false));
            }
        }
        
        for(Integer i = 0; i < fieldNames.size(); i++)
        {
            String leftValue = String.valueOf(LeftOpp.get(fieldNames[i]));
            String rightValue = String.valueOf(RightOpp.get(fieldNames[i]));
            if(leftValue != rightValue)
            {
                String fieldType = Name2Type.get(fieldNames[i]).name();
                if(fieldType == 'Reference')
                {
                    String leftName = getObjectNameFieldValue(fieldParents[i], leftValue);
                    String rightName = getObjectNameFieldValue(fieldParents[i], rightValue);
                    if(fieldNames[i] == 'Primary_Partner__c' || fieldNames[i] == 'Registered_Partner__c')
                    {
                        ComparingFields.add(new FieldComparisonInfo(fieldLabels[i], fieldNames[i], leftName, rightName, false, false, false));
                    }
                    else
                    {
                        ComparingFields.add(new FieldComparisonInfo(fieldLabels[i], fieldNames[i], leftName, rightName));
                    }
                }
                else if(fieldType == 'Date')
                {
                    Date left = (Date)LeftOpp.get(fieldNames[i]);
                    Date right = (Date)RightOpp.get(fieldNames[i]);
                    ComparingFields.add(new FieldComparisonInfo(fieldLabels[i], fieldNames[i], (left == null) ? '' : left.format(), (right == null) ? '' : right.format()));
                }
                else if(fieldType == 'DateTime')
                {
                    DateTime left = (DateTime)LeftOpp.get(fieldNames[i]);
                    DateTime right = (DateTime)RightOpp.get(fieldNames[i]);
                    ComparingFields.add(new FieldComparisonInfo(fieldLabels[i], fieldNames[i], (left == null) ? '' : left.format(), (right == null) ? '' : right.format()));
                }
                else
                {
                    ComparingFields.add(new FieldComparisonInfo(fieldLabels[i], fieldNames[i], leftValue, rightValue));
                }
            }
        }
        
        ComparingFields.add(new FieldComparisonInfo('Products', 'Products', 'Keep', 'Discard', true, true, true));
        ComparingFields.add(new FieldComparisonInfo('Silver Peak Quotes', 'Silver Peak Quotes', 'Keep', 'Discard', true, true, true));
        ComparingFields.add(new FieldComparisonInfo('Partners', 'Partners', 'Keep', 'Discard', true, true, true));
        ComparingFields.add(new FieldComparisonInfo('Competitors', 'Competitors', 'Keep', 'Discard', true, true, true));
        
        ComparingFields.add(new FieldComparisonInfo('POC Requests', 'POC Requests', 'Combine', 'Combine ', false, false, false));
        ComparingFields.add(new FieldComparisonInfo('Notes', 'Notes', 'Combine', 'Combine ', false, false, false));
        ComparingFields.add(new FieldComparisonInfo('Files', 'Files', 'Combine', 'Combine ', false, false, false));
        ComparingFields.add(new FieldComparisonInfo('Contracts', 'Contracts', 'Combine', 'Combine ', false, false, false));
        ComparingFields.add(new FieldComparisonInfo('POC Summaries', 'POC Summaries', 'Combine', 'Combine ', false, false, false));
        ComparingFields.add(new FieldComparisonInfo('Purchase Orders', 'Purchase Orders', 'Combine', 'Combine ', false, false, false));
    }
    
    private String getObjectNameFieldValue(String parentObject, String parentId)
    {
        if(parentId instanceOf Id)
        {
            String tempSql = 'select Id, ', parentName = '';
            if(parentObject == 'Solution')
            {
                parentName = 'SolutionName';
            }
            else if(parentObject == 'Case')
            {
                parentName = 'CaseNumber';
            }
            else
            {
                parentName = 'Name';
            }
            
            tempSql = tempSql + parentName + ' from ' + parentObject + ' where Id = \'' + parentId + '\' limit 1';
            List<SObject> tempObjects = Database.query(tempSql);
            if(tempObjects.size() > 0)
            {
                sObject obj = tempObjects[0];
                return (String)obj.get(parentName);
            }
        }
        return '';
    }
    
    //processes 'POC Requests', 'Notes and Attachments', 'Contracts', 'POC Summary', 'Purchase Order', and 'Ensemble Files' here.
    private void combineOtherRelatedList(Id winningOppId, Id losingOppId)
    {
        Opportunity losingOpp = [Select (Select Id From Requests__r), (Select Id From Purchase_Orders__r), (Select Id From POCSummaries__r), 
                                 (Select Id From Notes), (Select Id From Contracts__r), (Select Id From Attachments) From Opportunity where Id = :losingOppId limit 1];
        if(losingOpp.Requests__r.size() > 0)
        {
            String pocRequestSql = 'select ';
            List<String> pocRequestFieldNames = new List<String>();
            for(Schema.SObjectField sobjectField : Schema.SObjectType.Request__c.Fields.getMap().values())
            {
                Schema.DescribeFieldResult describeField = sobjectField.getDescribe();
                if(describeField.isAccessible() && describeField.isUpdateable() && !(describeField.isAutoNumber() || describeField.isCalculated()))
                {
                    pocRequestSql += describeField.getName() + ', ';
                    pocRequestFieldNames.add(describeField.getName() + '');
                }
            }
            pocRequestSql = pocRequestSql.subString(0, pocRequestSql.length() - 2);
            
            List<Request__c> pocRequests = (List<Request__c>)Database.query(pocRequestSql + ' from Request__c where Opportunity__c = \'' + losingOppId + '\'');
            
            for(Request__c pocRequest : pocRequests)
            {
                pocRequest.Opportunity__c = winningOppId;
            }
            
            update pocRequests;
        }
        
        insert copyNote(winningOppId, losingOppId);
        insert copyAttachment(winningOppId, losingOppId);
        
        List<Ensemblestorage__EnsembleFile__c> files = [select Id, Ensemblestorage__Opportunity__c from Ensemblestorage__EnsembleFile__c 
                                                        where Ensemblestorage__Opportunity__c = :losingOppId];
        if(files.size() > 0)
        {
            for(Ensemblestorage__EnsembleFile__c file : files)
            {
                file.Ensemblestorage__Opportunity__c = winningOppId;
            }
            
            update files;
        }
        
        if(losingOpp.Contracts__r.size() > 0)
        {
            List<Contract_to_Opportunity__c> contracts = [select Id, Opportunity__c from Contract_to_Opportunity__c where Opportunity__c = :losingOppId];
            for(Contract_to_Opportunity__c contract : contracts)
            {
                contract.Opportunity__c = winningOppId;
            }
            
            update contracts;
        }
        
        if(losingOpp.POCSummaries__r.size() > 0)
        {
            List<POC_Summary__c> pocSummaries = [select Id, POC_For__c from POC_Summary__c where POC_For__c = :losingOppId];
            for(POC_Summary__c pocSummary : pocSummaries)
            {
                pocSummary.POC_For__c = winningOppId;
            }
            
            update pocSummaries;
        }
        
        
        if(losingOpp.Purchase_Orders__r.size() > 0)
        {
            List<Purchase_Order__c> orders = [select Id, Opportunity__c from Purchase_Order__c where Opportunity__c = :losingOppId];
            for(Purchase_Order__c order : orders)
            {
                order.Opportunity__c = winningOppId;
            }
            
            update orders;
        }
    }
    
    private List<Note> copyNote(String winningId, String losingId)
    {
        List<Note> newNotes = new List<Note>();
        for(Note note : [Select Title, OwnerId, IsPrivate, Body From Note where ParentId = :losingId])
        {
            Note newNote = note.clone(false, false, false, false);
            newNote.ParentId = winningId;
            newNotes.add(newNote);
        }
        return newNotes;
    }
    
    private List<Attachment> copyAttachment(String winningId, String losingId)
    {
        List<Attachment> newAttachments = new List<Attachment>();
        for(Attachment attachment : [Select OwnerId, Name, IsPrivate, Description, ContentType, Body From Attachment where ParentId = :losingId])
        {
            Attachment newAttachment = attachment.clone(false, false, false, false);
            newAttachment.ParentId = winningId;
            newAttachments.add(newAttachment);
        }
        return newAttachments;
    }
    
    private void processProducts(Id winningOppId, Id losingOppId)
    {
        delete [select Id from OpportunityLineItem where OpportunityId = :winningOppId];
        
        if([select Id from OpportunityLineItem where OpportunityId = :losingOppId limit 1].size() > 0)
        {
            String oppLineItemSql = 'select ';
            List<String> oppLineItemFieldNames = new List<String>();
            for(Schema.SObjectField sobjectField : Schema.SObjectType.OpportunityLineItem.Fields.getMap().values())
            {
                Schema.DescribeFieldResult describeField = sobjectField.getDescribe();
                //cloning only writable fields
                //UnitPrice and TotalPrice is mutual exclusive. 
                if(describeField.isAccessible() && describeField.isUpdateable() && !(describeField.isAutoNumber() || 
                                                                                     describeField.isCalculated()) && describeField.getName() + '' != 'TotalPrice')
                {
                    oppLineItemSql += describeField.getName() + ', ';
                    oppLineItemFieldNames.add(describeField.getName() + '');
                }
            }
            oppLineItemSql += 'PricebookEntryId';
            oppLineItemFieldNames.add('PricebookEntryId');
            
            List<OpportunityLineItem> oppLineItems = (List<OpportunityLineItem>)Database.query(oppLineItemSql + 
                                                                                               ' from OpportunityLineItem where OpportunityId = \'' + losingOppId + '\'' + ' and PricebookEntry.Product2.IsActive = true');
            
            List<OpportunityLineItem> newOppLineItems = new List<OpportunityLineItem>();
            for(OpportunityLineItem oppLineItem : oppLineItems)
            {
                OpportunityLineItem newOppLineItem = oppLineItem.clone(false, false, false, false);
                newOppLineItem.OpportunityId = winningOppId;
                newOppLineItem.UnitPrice = (newOppLineItem.UnitPrice == null) ? 0 : newOppLineItem.UnitPrice;
                newOppLineItems.add(newOppLineItem);
            }
            
            insert newOppLineItems;
        }
    }
    
    private void processCompetitors(Id winningOppId, Id losingOppId)
    {
        delete [Select Id From OpportunityCompetitor where OpportunityId=:winningOppId];
        
        List<OpportunityCompetitor> newCompetitors = new List<OpportunityCompetitor>();
        for(OpportunityCompetitor competitor : [Select Weaknesses, Strengths, CompetitorName From OpportunityCompetitor where OpportunityId=:losingOppId])
        {
            OpportunityCompetitor newCompetitor = competitor.clone(false, false, false, false);
            newCompetitor.OpportunityId = winningOppId;
            newCompetitors.add(newCompetitor);
        }
        if(newCompetitors.size() > 0)
        {
            insert newCompetitors;
        }
    }
    
    private void processPartners(Id winningOppId, Id losingOppId)
    {
        delete [Select Id From Partner where OpportunityId = :winningOppId];
        
        List<Partner> newPartners = new List<Partner>();
        for(Partner partner : [Select Role, IsPrimary, AccountToId, Opportunity.AccountId From Partner where OpportunityId = :losingOppId and Role != 'Client'])
        {
            Partner newPartner = partner.clone(false, false, false, false);
            newPartner.OpportunityId = winningOppId;
            newPartners.add(newPartner);
        }
        if(newPartners.size() > 0)
        {
            insert newPartners;
        }
    }
    
    private void processQuotes(Id winningOppId, Id losingOppId)
    {
        delete [select Id from Quote__c where Opportunity__c = :winningOppId];
        
        List<Quote__c> quotes = [select Id, Opportunity__c from Quote__c where Opportunity__c = :losingOppId];
        if(quotes.size() > 0)
        {
            for(Quote__c quote : quotes)
            {
                quote.Opportunity__c = winningOppId;
            }
            
            update quotes;
        }
    }
    
    private Boolean isNullOrEmpty(String value)
    {
        return value == null || value == '';
    }
    
    public class FieldComparisonInfo
    {
        public FieldComparisonInfo(String fieldLabel, String fieldName, String leftValue, String rightValue)
        {
            this(fieldLabel, fieldName, leftValue, rightValue, true, true, false);
        }
        
        public FieldComparisonInfo(String fieldLabel, String fieldName, String leftValue, String rightValue, Boolean displayRadio, Boolean needMerge, Boolean KeepDiscard)
        {
            this.fieldLabel = fieldLabel;
            this.fieldName = fieldName;
            this.leftValue = leftValue;
            this.rightValue = rightValue;
            this.options = initOptions();
            this.displayRadio = displayRadio;
            this.selectedSide = 'left';
            this.needMerge = needMerge;
            this.KeepDiscard = KeepDiscard;
        }
        
        public String selectedSide { get; set; }
        public String fieldLabel { get; set; }
        public String fieldName { get; set; }
        public String leftValue { get; set; }
        public String rightValue { get; set; }
        public List<SelectOption> options { get; set; }
        public Boolean displayRadio { get; set; }
        public Boolean needMerge { get; set; }
        public Boolean KeepDiscard { get; set; }
        public String selectedValue 
        {
            get
            {
                return (selectedSide == 'left') ? leftValue : rightValue;
            }
        }
        
        private List<SelectOption> initOptions()
        {
            List<SelectOption> selectOptions = new List<SelectOption>();
            if(leftValue != rightValue)
            {
                leftValue = (leftValue == null) ? '' : leftValue;
                rightValue = (rightValue == null) ? '' : rightValue;
                selectOptions.add(new SelectOption('left', leftValue));
                selectOptions.add(new SelectOption('right', rightValue));
            }
            
            return selectOptions;
        }
    }
    
    @IsTest(SeeAllData=true)
    static void test1()
    {
        PriceBook2 pb = [select Id from Pricebook2 where IsStandard=true limit 1];
        Account oppAccount = new Account(Name = 'Test Opp Account');
        insert oppAccount;
        Contact con= new Contact(LastName='testLastName',Email='abc@test2323.com',AccountId=oppAccount.Id);
        insert con;
        Test.startTest();
        List<Opportunity> opps = new List<Opportunity>();
        for(Integer i = 0; i < 2; i++)
        {
            opps.add(new Opportunity(Name = 'acme' + i, AccountId = oppAccount.Id, CloseDate = System.today(), StageName = 'Discovery', Pricebook2Id = pb.Id,Technical_Responsible__c=UserInfo.getUserId()));
        }
        insert opps;
        List<OpportunityContactRole> oppContactRoles = new List<OpportunityContactRole>();
        for(Opportunity item: opps)
        {
            oppContactRoles.add(new OpportunityContactRole(OpportunityId=item.Id,Role='Contact',ContactId=con.Id));
        }
        insert oppContactRoles;
       
        Product2 product = new Product2(Name = 'Test Product', ProductCode = '111AAA', IsActive = true);
        insert product;
        PriceBookEntry entry = new PriceBookEntry(IsActive = true, PriceBook2Id = pb.Id, Product2Id = product.Id, UnitPrice = 10, UseStandardPrice = false);
        insert entry;
        OpportunityLineItem oppLine = new OpportunityLineItem(OpportunityId = opps[0].Id, PriceBookEntryId = entry.Id, Quantity = 1, UnitPrice = 10);
        insert oppLine;
        
        Product2 product1 = new Product2(Name = 'Test Product1', ProductCode = '111AAA111', IsActive = true);
        insert product1;
        PriceBookEntry entry1 = new PriceBookEntry(IsActive = true, PriceBook2Id = pb.Id, Product2Id = product1.Id, UnitPrice = 100, UseStandardPrice = false);
        insert entry1;
        OpportunityLineItem oppLine1 = new OpportunityLineItem(OpportunityId = opps[1].Id, PriceBookEntryId = entry1.Id, Quantity = 2, UnitPrice = 100);
        insert oppLine1;
        
        List<Quote__c> quotes = new List<Quote__c>(); 
        for(Integer i = 0; i < 2; i++)
        {
            quotes.add(new Quote__c(Opportunity__c = opps[i].Id, Quote_Valid_Until__c = System.today()));
        }
        insert quotes;
        
        /*Account account = new Account(Name = 'Test Account');
insert account;
List<Partner> partners = new List<Partner>();
for(Integer i = 0; i < 2; i++)
{
partners.add(new Partner(IsPrimary = true, AccountToId = account.Id, OpportunityId = opps[i].Id, Role='Tier 1'));
}
insert partners;
*/
        List<OpportunityCompetitor> competitors = new List<OpportunityCompetitor>();
        for(Integer i = 0; i < 2; i++)
        {
            competitors.add(new OpportunityCompetitor(CompetitorName = 'Test Competitor' + i, Strengths = 'good', Weaknesses = 'bad', OpportunityId = opps[i].Id));
        }
        insert competitors;
        /*
//processes 'POC Requests', 'Notes and Attachments', 'Contracts', 'POC Summary', 'Purchase Order', and 'Ensemble Files' here.
List<Request__c> requests = new List<Request__c>();
for(Integer i = 0; i < 2; i++)
{
requests.add(new Request__c(Opportunity__c = opps[i].Id, Priority__c = 'P3 - Medium', Status__c = 'Open', Type__c = 'Evaluation'));
}
insert requests;
*/
        List<Note> notes = new List<Note>();
        for(Integer i = 0; i < 2; i++)
        {
            notes.add(new Note(ParentId = opps[i].Id, Title = 'Test Title' + i, IsPrivate = true, Body = 'Luffy'));
        }
        insert notes;
        
        List<Attachment> attachments = new List<Attachment>();
        for(Integer i = 0; i < 2; i++)
        {
            attachments.add(new Attachment(Name = 'Test Attachment' + i, ParentId = opps[i].Id, IsPrivate = true, 
                                           Description = 'Luffy', Body = Blob.valueof('111')));
        }
        insert attachments;
         Test.stopTest();
        /*Contract contract = new Contract(Name = 'Test Contract', AccountId = account.Id, SP_Contract_Number__c = '11');
insert contract;
List<Contract_to_Opportunity__c> contracts = new List<Contract_to_Opportunity__c>();
for(Integer i = 0; i < 2; i++)
{
contracts.add(new Contract_to_Opportunity__c(Opportunity__c = opps[i].Id, contract__c = contract.Id));
}
insert contracts;

List<POC_Summary__c> pocSummaries = new List<POC_Summary__c>();
for(Integer i = 0; i < 2; i++)
{
pocSummaries.add(new POC_Summary__c(POC_For__c = opps[i].Id));
}
insert pocSummaries;

List<Purchase_Order__c> pocOrders = new List<Purchase_Order__c>();
for(Integer i = 0; i < 2; i++)
{
pocOrders.add(new Purchase_Order__c(Opportunity__c = opps[i].Id));
}
insert pocOrders;*/
        
        
        PageReference page = new PageReference('/apex/OppMerge');
        Test.setCurrentPage(page);
        ApexPages.currentPage().getParameters().put('op1', opps[0].Id);
        ApexPages.currentPage().getParameters().put('op2', opps[1].Id);
        OpportunityMergeController controller = new OpportunityMergeController();
        
        System.assertEquals(opps[0].Id, controller.LeftOpp.Id);
        System.assertEquals(opps[1].Id, controller.RightOpp.Id);
        
        PageReference prevPage = controller.prev();
        PageReference cancelpage = controller.cancel();
        
        controller.ComparingFields[1].selectedSide = 'right';
        controller.ComparingFields[2].selectedSide = 'right';
        
        controller.mergeOpps();
        //System.assertEquals('acme0', [select Id, Name from Opportunity where Id = :opps[1].Id limit 1].Name);
        //System.assertEquals(opps[1].Id, [select Id, Surviving_Opportunity__c from Opportunity where Id = :opps[0].Id limit 1].Surviving_Opportunity__c);
    }
    
    /*@IsTest(SeeAllData=true)
static void test2()
{
PriceBook2 pb = [select Id from Pricebook2 where IsStandard=true limit 1];

Account oppAccount = new Account(Name = 'Test Opp Account');
insert oppAccount;
List<Opportunity> opps = new List<Opportunity>();
for(Integer i = 0; i < 2; i++)
{
opps.add(new Opportunity(Name = 'acme' + i, AccountId = oppAccount.Id, CloseDate = System.today(), StageName = 'Discovery', Pricebook2Id = pb.Id));
}
insert opps;

Product2 product = new Product2(Name = 'Test Product', ProductCode = '111AAA', IsActive = true);
insert product;
PriceBookEntry entry = new PriceBookEntry(IsActive = true, PriceBook2Id = pb.Id, Product2Id = product.Id, UnitPrice = 10, UseStandardPrice = false);
insert entry;
OpportunityLineItem oppLine = new OpportunityLineItem(OpportunityId = opps[0].Id, PriceBookEntryId = entry.Id, Quantity = 1, UnitPrice = 10);
insert oppLine;

Product2 product1 = new Product2(Name = 'Test Product1', ProductCode = '111AAA111', IsActive = true);
insert product1;
PriceBookEntry entry1 = new PriceBookEntry(IsActive = true, PriceBook2Id = pb.Id, Product2Id = product1.Id, UnitPrice = 100, UseStandardPrice = false);
insert entry1;
OpportunityLineItem oppLine1 = new OpportunityLineItem(OpportunityId = opps[1].Id, PriceBookEntryId = entry1.Id, Quantity = 2, UnitPrice = 100);
insert oppLine1;

List<Quote__c> quotes = new List<Quote__c>(); 
for(Integer i = 0; i < 2; i++)
{
quotes.add(new Quote__c(Opportunity__c = opps[i].Id, Quote_Valid_Until__c = System.today()));
}
insert quotes;

Account account = new Account(Name = 'Test Account');
insert account;
List<Partner> partners = new List<Partner>();
for(Integer i = 0; i < 2; i++)
{
partners.add(new Partner(IsPrimary = true, AccountToId = account.Id, OpportunityId = opps[i].Id, Role='Tier 1'));
}
insert partners;

List<OpportunityCompetitor> competitors = new List<OpportunityCompetitor>();
for(Integer i = 0; i < 2; i++)
{
competitors.add(new OpportunityCompetitor(CompetitorName = 'Test Competitor' + i, Strengths = 'good', Weaknesses = 'bad', OpportunityId = opps[i].Id));
}
insert competitors;
//processes 'POC Requests', 'Notes and Attachments', 'Contracts', 'POC Summary', 'Purchase Order', and 'Ensemble Files' here.
List<Request__c> requests = new List<Request__c>();
for(Integer i = 0; i < 2; i++)
{
requests.add(new Request__c(Opportunity__c = opps[i].Id, Priority__c = 'P3 - Medium', Status__c = 'Open', Type__c = 'Evaluation'));
}
insert requests;

List<Note> notes = new List<Note>();
for(Integer i = 0; i < 2; i++)
{
notes.add(new Note(ParentId = opps[i].Id, Title = 'Test Title' + i, IsPrivate = true, Body = 'Luffy'));
}
insert notes;

List<Attachment> attachments = new List<Attachment>();
for(Integer i = 0; i < 2; i++)
{
attachments.add(new Attachment(Name = 'Test Attachment' + i, ParentId = opps[i].Id, IsPrivate = true, 
Description = 'Luffy', Body = Blob.valueof('111')));
}
insert attachments;

Contract contract = new Contract(Name = 'Test Contract', AccountId = account.Id, SP_Contract_Number__c = '11');
insert contract;
List<Contract_to_Opportunity__c> contracts = new List<Contract_to_Opportunity__c>();
for(Integer i = 0; i < 2; i++)
{
contracts.add(new Contract_to_Opportunity__c(Opportunity__c = opps[i].Id, contract__c = contract.Id));
}
insert contracts;

List<POC_Summary__c> pocSummaries = new List<POC_Summary__c>();
for(Integer i = 0; i < 2; i++)
{
pocSummaries.add(new POC_Summary__c(POC_For__c = opps[i].Id));
}
insert pocSummaries;

List<Purchase_Order__c> pocOrders = new List<Purchase_Order__c>();
for(Integer i = 0; i < 2; i++)
{
pocOrders.add(new Purchase_Order__c(Opportunity__c = opps[i].Id));
}
insert pocOrders;

Test.startTest();
PageReference page = new PageReference('/apex/OppMerge');
Test.setCurrentPage(page);
ApexPages.currentPage().getParameters().put('op1', opps[0].Id);
ApexPages.currentPage().getParameters().put('op2', opps[1].Id);
OpportunityMergeController controller = new OpportunityMergeController();

System.assertEquals(opps[0].Id, controller.LeftOpp.Id);
System.assertEquals(opps[1].Id, controller.RightOpp.Id);

PageReference prevPage = controller.prev();
PageReference cancelpage = controller.cancel();

controller.ComparingFields[1].selectedSide = 'right';
controller.ComparingFields[2].selectedSide = 'right';
controller.mergeOpps();
System.assertEquals('acme0', [select Id, Name from Opportunity where Id = :opps[1].Id limit 1].Name);
System.assertEquals(opps[1].Id, [select Id, Surviving_Opportunity__c from Opportunity where Id = :opps[0].Id limit 1].Surviving_Opportunity__c);
Test.stopTest();
}*/
}