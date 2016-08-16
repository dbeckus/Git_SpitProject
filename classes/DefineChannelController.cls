/*
 * Controller of page DefineChannel
 * actually it works to add/update partners to opportunity
 */ 
public without sharing class DefineChannelController
{
    private Opportunity opp;

    public DefineChannelController()
    {
        String oppId = ApexPages.currentPage().getParameters().get('id');
        List<Opportunity> opps = [select Id, Name, AccountId, Registered_Partner__c, (select Id, Role, AccountToId, IsPrimary from Partners order by Role asc, CreatedDate desc) from Opportunity where Id=:oppId limit 1];
        if(opps.size() > 0)
        {
            opp = opps[0];
        }
        initPartners();
    }
    
    public Boolean IsReady { get; set; }
    
    public Opportunity getOpp()
    {
        return opp;
    }
    
    public List<PartnerInfo> Partners
    {
        get;set;
    }
    
    public Set<Id> CreditHoldPartners
    {
        get
        {
            Set<Id> result = new Set<Id>();
            Integer maxLimit = (Test.isRunningTest()) ? 10 : 999;
            for(Account partner : [select Id from Account where CreditHold__c=true limit :maxLimit])
            {
                result.add(partner.Id);
            }
            return result;
        }
    }
    
    public List<Account> InitialSelectedPartners
    {
        get
        {
            List<Account> accs = new List<Account>();
            for(OpportunityPartner oppPartner : [select Id, AccountTo.Id, AccountTo.Name from OpportunityPartner where OpportunityId=:opp.Id])
            {
                accs.add(oppPartner.AccountTo);
            }
            return accs;
        }
    }
    
    @remoteAction
    public static String getPartners(Integer tier, String term) 
    {
        String result = '[{"id":"","text":"-NONE-"},';
        User currentUser = [select Id, GEO__c from User where Id=:UserInfo.getUserId() limit 1];
        String currentGEO = currentUser.GEO__c;
        if(currentGEO == null || currentGEO == '')
        {
            currentGEO = 'All';
        }
        List<Account> accounts = new List<Account>();
        if(tier == 1)
        {
            accounts = getTier1Partners(currentGEO, term);
        }
        else if(tier == 2)
        {
            accounts = getTier2Partners(currentGEO, term);
        }
        else if(tier == 3)
        {
            accounts = getTier3Partners(currentGEO, term);
        }
        for(Account acc : accounts)
        {
            if(String.isNotBlank(acc.Name))
            {
                result += '{"id":"' + acc.Id + '","text":"' +acc.Name.replaceAll('"', '') + '"},';
            }
        }
        result = result.removeEnd(',');
        result += ']';
        return result;
    }
    
    public PageReference save()
    {
        if(isValidInput())
        {
            Savepoint sp = Database.setSavepoint();
            List<Partner> existingPartners = new List<Partner>();
            Set<String> accountIds = new Set<String>();
            for(Partner partner : opp.Partners)
            {
                accountIds.add(partner.AccountToId);
                existingPartners.add(partner);
            }
            List<OpportunityShare> existingOppShares = getExistingOppShares(opp.Id, accountIds);
            try
            {
                delete existingPartners;
                delete existingOppShares;
            }
            catch(Exception ex)
            {
                ApexPages.addMessages(ex);
                return null;
            }
            List<Partner> newPartners = new List<Partner>();
            Set<String> newAccountIds = new Set<String>();
            Boolean hasRegistered = false;
            for(PartnerInfo partner : Partners)
            {
                if(partner.AccountId != null && partner.AccountId instanceOf Id)
                {
                    if(partner.IsRegistered)
                    {
                        opp.Registered_Partner__c = partner.AccountId;
                        hasRegistered = true;
                    }
                    newAccountIds.add(partner.AccountId);
                    newPartners.add(new Partner(OpportunityId=opp.Id, Role=partner.Role, AccountToId=partner.AccountId, IsPrimary=false));
                }
            }
            if(!hasRegistered)
            {
                opp.Registered_Partner__c = null;
            }
            if(newPartners.size() > 0)
            {
                newPartners[newPartners.size() - 1].IsPrimary = true;
                if(!HasAgreement(newPartners[newPartners.size() - 1].AccountToId))
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'The primary partner must have the Reseller Agreement checked.'));
                    Database.rollback(sp);
                    return null;
                }
                opp.Primary_Partner__c = newPartners[newPartners.size() - 1].AccountToId;
                opp.Tier1_Partner__c = (Partners[0].AccountId == null) ? null : Partners[0].AccountId;
                opp.Tier2_Partner__c = (Partners[1].AccountId == null) ? null : Partners[1].AccountId;
                List<OpportunityShare> newOppShares = shareOppToParnter(opp.Id, newAccountIds); 
                try
                {
                    insert newPartners;
                    update opp;
                    //shares opportunity to partner
                    Database.insert(newOppShares, false);
                    //updating for trigger on quote
                    toggleQuoteDiscount(opp.Id);
                    toggleQuoteDiscount(opp.Id);
                    
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Succeeded.<script type="text/javascript">opener.location="/'+opp.Id+'";setTimeout("window.close()", 3000)</script>'));
                    return null;
                }
                catch(Exception ex)
                {
                    ApexPages.addMessages(ex);
                    Database.rollback(sp);
                    return null;
                }
            }
            else
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'At least one partner required'));
                Database.rollback(sp);
                return null;
            }
        }
        return null;
    }
    
    public PageReference cancel()
    {
        if(opp != null)
        {
            return new PageReference('/' + opp.Id);
        }
        else
        {
            return new PageReference('/006/o');
        }
    }
    
    public PageReference deleteExisting()
    {
        if(opp != null)
        {
            List<Partner> deletingPartners = new List<Partner>();
            Set<String> accountIds = new Set<String>();
            for(Partner partner : opp.Partners)
            {
                if(partner.Role != 'Tier 1' && partner.Role != 'Tier 2' && partner.Role != 'Tier 3' && partner.Role != 'Client')
                {
                    accountIds.add(partner.AccountToId);
                    deletingPartners.add(partner);
                }
            }
            List<OpportunityShare> oppShares = getExistingOppShares(opp.Id, accountIds);
            try
            {
                delete deletingPartners;
                delete oppShares;
                IsReady = true;
                opp = [select Id, Name, AccountId, Registered_Partner__c, (select Id, Role, AccountToId, IsPrimary from Partners order by Role) from Opportunity where Id=:opp.Id limit 1];
                initPartners();
            }
            catch(Exception ex)
            {
                ApexPages.addMessages(ex);
            }
        }
        return null;
    }
    
    private static Boolean isChannelMember(Id userId)
    {
        Id groupId = '00G50000001f1RQ';
        List<GroupMember> members = [select Id from GroupMember where (Group.DeveloperName='DefineChannelTeam' or GroupId=:groupId) and UserOrGroupId=:userId limit 1];
        return members.size() > 0;
    }

    private static List<Account> getTier1Partners(String geo, String term)
    {
        String soql = 'select Id, Name from Account where IsAPartner__c=1 ';
        if(!isChannelMember(UserInfo.getUserId()))
        {
            soql += 'and GEO_Supported__c includes (\'All\', \'' + String.escapeSingleQuotes(geo) + '\') ';
        }
        if(String.isNotBlank(term) && term.length() > = 2)
        {
            soql += ' and Name like \'' + String.escapeSingleQuotes(term) + '%\' ';
        }
        soql += 'order by Name limit 200';
        return Database.query(soql);
    }
    
    private static List<Account> getTier2Partners(String geo, String term)
    {
        String soql = 'select Id, Name from Account where IsTier2Partner__c=1 ';
        if(!isChannelMember(UserInfo.getUserId()))
        {
            soql += 'and GEO_Supported__c includes (\'All\', \'' + String.escapeSingleQuotes(geo) + '\') ';
        }
        if(String.isNotBlank(term) && term.length() > = 2)
        {
            soql += ' and Name like \'' + String.escapeSingleQuotes(term) + '%\' ';
        }
        soql += 'order by Name limit 200';
        return Database.query(soql);
    }
    
    private static List<Account> getTier3Partners(String geo, String term)
    {
        String soql = 'select Id, Name from Account where IsTier3Partner__c=true ';
        if(!isChannelMember(UserInfo.getUserId()))
        {
            soql += 'and GEO_Supported__c includes (\'All\', \'' + String.escapeSingleQuotes(geo) + '\') ';
        }
        if(String.isNotBlank(term) && term.length() > = 2)
        {
            soql += ' and Name like \'' + String.escapeSingleQuotes(term) + '%\' ';
        }
        soql += 'order by Name limit 200';
        return Database.query(soql);
    }
    
    private Boolean isValidInput()
    {
        if(String.isBlank(Partners[0].AccountId))
        {
            Partners[0].AccountId = null;
        }
        if(String.isBlank(Partners[1].AccountId))
        {
            Partners[1].AccountId = null;
        }
        if(String.isBlank(Partners[2].AccountId))
        {
            Partners[2].AccountId = null;
        }
        if(Partners[0].AccountId == null && (Partners[1].AccountId != null || Partners[2].AccountId != null))
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'You cannot define channel with a gap, Tier 1 required.'));
            return false;
        }
        if(Partners[1].AccountId == null && Partners[2].AccountId != null)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'You cannot define channel with a gap, Tier 2 required.'));
            return false;
        }
        if(Partners[0].AccountId != null && Partners[0].AccountId == Partners[1].AccountId)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'You cannot define the same partner as two tiers.' + Partners[0].AccountId));
            return false;
        }
        if(Partners[0].AccountId != null && Partners[0].AccountId == Partners[2].AccountId)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'You cannot define the same partner as two tiers.' + Partners[0].AccountId));
            return false;
        }
        if(Partners[1].AccountId != null && Partners[1].AccountId == Partners[2].AccountId)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'You cannot define the same partner as two tiers.' + Partners[1].AccountId));
            return false;
        }
        if(Partners[0].AccountId != null && Partners[0].AccountId == opp.AccountId)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Partner and opportunity account can not be the same. Set opportunity account to the end user.'));
            return false;
        }
        if(Partners[1].AccountId != null && Partners[1].AccountId == opp.AccountId)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Partner and opportunity account can not be the same. Set opportunity account to the end user.'));
            return false;
        }
        if(Partners[2].AccountId != null && Partners[2].AccountId == opp.AccountId)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Partner and opportunity account can not be the same. Set opportunity account to the end user.'));
            return false;
        }
        if(Partners[0].IsRegistered == true && Partners[0].AccountId == null)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please choose a registered partner.'));
            return false;
        }
        if(Partners[1].IsRegistered == true && Partners[1].AccountId == null)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please choose a registered partner.'));
            return false;
        }
        if(Partners[2].IsRegistered == true && Partners[2].AccountId == null)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please choose a registered partner.'));
            return false;
        }  
        return true;
    }
    
    private void initPartners()
    {
        if(opp != null)
        {
            partners = new List<PartnerInfo>();
            IsReady = true;
            for(Partner partner : opp.Partners)
            {
                if(partner.Role != 'Tier 1' && partner.Role != 'Tier 2' && partner.Role != 'Tier 3' && partner.Role != 'Client' && partner.Role != null)
                {
                    IsReady = false;
                }
            }
            if(IsReady)
            {
                for(Integer tier = 1; tier <= 3; tier++)
                {
                    Boolean found = false;
                    for(Partner existingPartner : opp.Partners)
                    {
                        if(existingPartner.Role == 'Tier ' + tier)
                        {
                            Boolean registered = (opp.Registered_Partner__c == existingPartner.AccountToId);
                            partners.add(new PartnerInfo('Tier ' + tier, existingPartner.AccountToId, registered));
                            found = true;
                            break;
                        }
                    }
                    if(!found)
                    {
                        partners.add(new PartnerInfo('Tier ' + tier, '', false));
                    }
                }
            }
        }
    }
    
    //shares Opportunity as "Read/Write" to the "Gold Parnter" users
    private List<OpportunityShare> shareOppToParnter(String oppId, Set<String> accountIds)
    {
        List<OpportunityShare> oppShares = new List<OpportunityShare>();
        List<User> users = [Select Id from User where UserType='PowerPartner' and Contact.AccountId in :accountIds and isActive=true];
        if(users.size() > 0)
        {
            for (User user : users)
            {
                OpportunityShare oppShare = new OpportunityShare(OpportunityId=oppId, UserOrGroupId=user.Id, OpportunityAccessLevel='Edit');
                oppShares.add(oppShare);
            }
        }
        return oppShares;
    }
    
    private List<OpportunityShare> getExistingOppShares(String oppId, Set<String> accountIds)
    {
        List<OpportunityShare> oppShares = new List<OpportunityShare>();
        List<User> users = [select Id from User where UserType='PowerPartner' and Contact.AccountId in :accountIds and isActive=true];
        return [select Id from OpportunityShare where OpportunityId=:oppId and UserOrGroupId in :users];
    }
    
    private void toggleQuoteDiscount(String oppId)
    {
        List<Quote__c> quotes = [select Id, Primary__c, ShowDiscount__c from Quote__c where Opportunity__c =:oppId and Primary__c =true limit 1];
        if(quotes.size() > 0)
        {
            Quote__c quoteInfo = quotes[0]; 
            
            if(quoteInfo.ShowDiscount__c == null)
            {
                quoteInfo.ShowDiscount__c = false;
            }
            quoteInfo.ShowDiscount__c = !quoteInfo.ShowDiscount__c;
            try
            {
                update quoteInfo;
            }
            catch(Exception ex)
            {
                ApexPages.addMessages(ex);
            }
        }
    }
    
    //checkes if the Reseller_Agreement field is true on the specified account
    private Boolean HasAgreement(Id accountId)
    {
        List<Account> accounts = [select Id, Reseller_Agreement__c from Account where Id=:accountId limit 1];
        if(accounts.size() == 1)
        {
            return accounts[0].Reseller_Agreement__c;
        }
        return false;
    }
    
    public class PartnerInfo
    {
        public PartnerInfo(String role, String accountId, Boolean isRegistered)
        {
            this.Role = role;
            this.AccountId = accountId;
            this.IsRegistered = isRegistered;
        }
        
        public String Role { get; set; }
        public String AccountId { get; set; }
        public Boolean IsRegistered { get; set; }
    }
    
    @isTest
    static void testDefineChannelController()
    {
        Pricebook2 priceBook = new Pricebook2(Name='standard');
        insert priceBook;
        Account acc = new Account(Name='acme');
        insert acc;
        Opportunity opp = new Opportunity(Name='acme', StageName='Discovery', CloseDate=Date.today(), AccountId=acc.Id, Pricebook2id=priceBook.Id, Amount=1);
        opp.Technical_Responsible__c= USerInfo.getUserId();
        insert opp;
        Account partnerAcc = new Account(Name='acme', Reseller_Agreement__c=true);
        insert partnerAcc;
        Partner partner1 = new Partner(AccountToId=partnerAcc.Id, OpportunityId=opp.Id);
        Partner partner2 = new Partner(AccountToId=partnerAcc.Id, OpportunityId=opp.Id, Role='Tier 1');
        insert new Partner[]{partner1, partner2};
        Quote__c quote = new Quote__c(Opportunity__c=opp.Id, Quote_Date__c=Date.today(), Quote_Valid_Until__c=Date.today(), Primary__c=true);
        insert quote;
        Product2 product = new Product2(Name = 'prodcut');
        insert product;
        Quote_Line__c quoteLine = new Quote_Line__c(Unit_Price__c=1, Quantity__c=1, Quote__c=quote.Id, Product__c=product.Id);
        insert quoteLine; 
        
        PageReference page = new PageReference('/apex/DefineChannel?id=' + opp.Id);
        Test.setCurrentPage(page);
        DefineChannelController controller = new DefineChannelController();
        System.assert(controller.CreditHoldPartners != null);
        System.assert(controller.InitialSelectedPartners != null);
        System.assert(DefineChannelController.getPartners(1, 'ac') != null);
        System.assert(DefineChannelController.getPartners(2, 'ac') != null);
        System.assert(DefineChannelController.getPartners(3, 'ac') != null);
        System.assert(controller.cancel() != null);
        controller.deleteExisting();
        
        //tests isValidInput method
        controller.Partners[0].AccountId = null;
        controller.Partners[1].AccountId = partnerAcc.Id;
        controller.isValidInput();
        controller.Partners[0].AccountId = null;
        controller.Partners[2].AccountId = partnerAcc.Id;
        controller.isValidInput(); 
        controller.Partners[0].AccountId = partnerAcc.Id;
        controller.Partners[1].AccountId = partnerAcc.Id;
        controller.isValidInput();
        controller.Partners[0].AccountId = partnerAcc.Id;
        controller.Partners[1].AccountId = null;
        controller.Partners[2].AccountId = partnerAcc.Id;
        controller.isValidInput();
        controller.Partners[0].AccountId = null;
        controller.Partners[1].AccountId = partnerAcc.Id;
        controller.Partners[2].AccountId = partnerAcc.Id;
        controller.isValidInput();
        controller.Partners[0].AccountId = opp.AccountId;
        controller.isValidInput();
        controller.Partners[0].AccountId = partnerAcc.Id;
        controller.Partners[1].AccountId = opp.AccountId;
        controller.isValidInput();
        controller.Partners[0].IsRegistered = true;
        controller.Partners[0].AccountId = null;
        controller.isValidInput();
        controller.Partners[0].AccountId = partnerAcc.Id;
        controller.Partners[1].IsRegistered = true;
        controller.Partners[1].AccountId = null;
        controller.isValidInput();
        controller.Partners[2].IsRegistered = true;
        controller.Partners[2].AccountId = null;
        controller.isValidInput();
        
        controller.Partners[0].AccountId = partnerAcc.Id;
        controller.Partners[0].IsRegistered = true;
        controller.Partners[1].AccountId = null; 
        controller.Partners[1].IsRegistered = false;
        controller.Partners[2].AccountId = null;
        controller.Partners[2].IsRegistered = false;
        controller.save();
        controller.shareOppToParnter(null, null);
        controller.toggleQuoteDiscount(null);
    }
}