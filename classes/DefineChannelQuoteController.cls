public without sharing class DefineChannelQuoteController {
    public static Opportunity reqOpp{get;set;}
    public boolean IsSaveEnabled{get;set;}
    public  PartnerInfo PartnerData
    {
        get;set;
    }
    public DefineChannelQuoteController()
    {
        IsSaveEnabled=true;
        String oppId = ApexPages.currentPage().getParameters().get('id');
        SetInitialData(oppId);
        if(PartnerData.RsmGEO == null)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'GEO is not set for Account Manager.'));
        }
        
    }
    public List<InitialPartnerInfo> InitialSelectedPartners
    {
        get
        {
            List<InitialPartnerInfo> lstInitialPartnerInfo = new List<InitialPartnerInfo>();
            List<string> acctIds= new List<string>();
            if(PartnerData.Registering_PartnerId!=null)
            { 
                acctIds.add(PartnerData.Registering_PartnerId);
            }
            if(PartnerData.Registered_DistributorId != null)
            { 
                acctIds.add(PartnerData.Registered_DistributorId);
            }
            if(PartnerData.Tier3_PartnerId!=null)
            { 
                acctIds.add(PartnerData.Tier3_PartnerId);
            }
            if(acctIds.size()>0)
            {
                for(Account acct : [select Id, Name from Account where Id in: acctIds])
                {
                    lstInitialPartnerInfo.add(new InitialPartnerInfo(acct.Id, acct.Name) );
                }
            }
            if(String.isNotBlank(PartnerData.Registering_Partner_Sales_RepId) || String.isNotBlank(PartnerData.Registered_Distributor_RepId))
            { 
                for(Contact ct : [Select Id, Name from Contact where Id=:PartnerData.Registering_Partner_Sales_RepId or Id=:PartnerData.Registered_Distributor_RepId])
                {
                    lstInitialPartnerInfo.add(new InitialPartnerInfo(ct.Id, ct.Name) );
                }
            }
            return lstInitialPartnerInfo;
        }
    }
    private  void SetInitialData(string oppId)
    {
        List<Opportunity> opps = [select Id, Name, AccountId,Registering_Partner__c,Registering_Partner_Sales_Rep__c,Registered_Distributor__c, Registered_Distributor_Contact__c, Primary_Partner__c,Tier1_Partner__c, Tier2_Partner__c, Tier3_Partner__c, Deal_Reg__c, (select Id, Role, AccountToId, IsPrimary from Partners order by Role asc, CreatedDate desc) from Opportunity where Id=:oppId limit 1];
        if(opps.size() > 0)
        {
            reqOpp = opps[0];
           
            if(PartnerData==null)
            {
                PartnerData= new PartnerInfo(reqOpp);
            }
        }
    }
    
    public class InitialPartnerInfo
    {
        public String Id { get; set; }
        public String Name { get; set; }
        public InitialPartnerInfo(string Id, string Name)
        {
            this.Id= Id;
            this.Name= Name;
        }
    }
    public class PartnerInfo
    {
        public PartnerInfo(Opportunity opp)
        {
            this.Registering_PartnerId = (opp.Registering_Partner__c != null) ? opp.Registering_Partner__c : opp.Tier1_Partner__c;
            this.Registering_Partner_Sales_RepId = opp.Registering_Partner_Sales_Rep__c;
            this.Registered_DistributorId = (opp.Registered_Distributor__c != null) ? opp.Registered_Distributor__c : opp.Tier2_Partner__c;
            this.Registered_Distributor_RepId = opp.Registered_Distributor_Contact__c;
            this.Tier3_PartnerId = opp.Tier3_Partner__c;
            this.OppId= opp.Id;
            
            Map<String, Id> role2PartnerId = new Map<String, Id>();
            for(Partner partner : opp.Partners)
            {
                role2PartnerId.put(partner.Role, partner.AccountToId);
            }
            if(this.Registering_PartnerId != null)
            {
                this.Registering_PartnerId = role2PartnerId.get('Tier 1');
            }
            if(this.Registered_DistributorId != null)
            {
                this.Registered_DistributorId = role2PartnerId.get('Tier 2');
            }
            if(this.Tier3_PartnerId != null)
            {
                this.Tier3_PartnerId = role2PartnerId.get('Tier 3');
            }
            if(this.Tier3_PartnerId == this.Registered_DistributorId)
            {
                this.Tier3_PartnerId = null;
            }
            if(this.Registered_DistributorId == null && this.Tier3_PartnerId == this.Registering_PartnerId)
            {
                this.Tier3_PartnerId = null;
            }
            
            this.AccountId=opp.AccountId;
            Account accInfo=[Select Id, Patch__r.RSM__c from Account where Id=:opp.AccountId];
            if(accInfo.Patch__r.RSM__c!=null)
            {
                User rsmUser= [Select Id, GEO__c from User where Id=:accInfo.Patch__r.RSM__c];
                this.RsmGEO= rsmUser.GEO__c;
            }
        }
        
        public String Registering_PartnerId { get; set; }
        public String Registering_Partner_Sales_RepId { get; set; }
        public String Registered_DistributorId { get; set; }
        public String Registered_Distributor_RepId { get; set; }
        public String Tier3_PartnerId { get; set; }
        public String OppId { get; set; }
        public String AccountId { get; set; }
        public String RsmGEO { get; set; }
        
    }
    @remoteAction
    public static string InitResellerAccounts(string accId,string term)
    {
        string rsmUserGEO=null;
        Account accountInfo=[Select Id, Patch__r.RSM__c from Account where Id=:accId];
        if(accountInfo.Patch__r.RSM__c!=null)
        {
            User rsmUser= [Select Id, GEO__c from User where Id=:accountInfo.Patch__r.RSM__c];
            rsmUserGEO= rsmUser.GEO__c;
        }
        String result = '[{"id":"","text":"-NONE-"},';
        List<Account> accounts = new List<Account>();
        String soql = 'select Id, Name from Account where Type=\'Partner\' and Partner_level__c!=null and ParentId=null ';
        if(rsmUserGEO!=null)
        {
            soql += 'and GEO_Supported__c includes ( \'' + rsmUserGEO + '\') ';
        }
        
        if(String.isNotBlank(term) && term.length() > = 2)
        {
            soql += ' and Name like \'' + String.escapeSingleQuotes(term) + '%\' ';
        }
        soql += 'order by Name limit 200';
        //System.debug(soql);
        accounts= Database.query(soql);
        if(accounts!=null && accounts.size()>0)
        {
            for(Account acc : accounts)
            {
                if(String.isNotBlank(acc.Name))
                {
                    result += '{"id":"' + acc.Id + '","text":"' +acc.Name.replaceAll('"', '') + '"},';
                }
            }
        }
        result = result.removeEnd(',');
        result += ']';
        return result;
        
    }
    @remoteAction
    public static string InitDistributorAccounts(string accId,string term)
    {
        string rsmUserGEO=null;
        Account accountInfo=[Select Id, Patch__r.RSM__c from Account where Id=:accId];
        if(accountInfo.Patch__r.RSM__c!=null)
        {
            User rsmUser= [Select Id, GEO__c from User where Id=:accountInfo.Patch__r.RSM__c];
            rsmUserGEO= rsmUser.GEO__c;
        }
        String result = '[{"id":"","text":"-NONE-"},';
        List<Account> accounts = new List<Account>();
        String soql = 'select Id, Name from Account where Partner_Type__c=\'Distributor\' and Reseller_Agreement__c=true ';
        if(rsmUserGEO!=null)
        {
            soql += 'and GEO_Supported__c includes ( \'' + rsmUserGEO + '\') ';
        }
        
        if(String.isNotBlank(term) && term.length() > = 2)
        {
            soql += ' and Name like \'' + String.escapeSingleQuotes(term) + '%\' ';
        }
        soql += 'order by Name limit 200';
        //System.debug(soql);
        accounts= Database.query(soql);
        if(accounts!=null && accounts.size()>0)
        {
            for(Account acc : accounts)
            {
                if(String.isNotBlank(acc.Name))
                {
                    result += '{"id":"' + acc.Id + '","text":"' +acc.Name.replaceAll('"', '') + '"},';
                }
            }
        }
        result = result.removeEnd(',');
        result += ']';
        return result;
        
    }
    @remoteAction
    public static string InitTier3Accounts(string accId,string term)
    {
        string rsmUserGEO=null;
        Account accountInfo=[Select Id, Patch__r.RSM__c from Account where Id=:accId];
        if(accountInfo.Patch__r.RSM__c!=null)
        {
            User rsmUser= [Select Id, GEO__c from User where Id=:accountInfo.Patch__r.RSM__c];
            rsmUserGEO= rsmUser.GEO__c;
        }
        String result = '[{"id":"","text":"-NONE-"},';
        List<Account> accounts = new List<Account>();
        String soql = 'select Id, Name from Account ';
        if(String.isNotBlank(term) && term.length() > = 2)
        {
            soql += 'where Name like \'' + String.escapeSingleQuotes(term) + '%\' ';
        }
        soql += 'order by Name limit 50';
        accounts= Database.query(soql);
        if(accounts!=null && accounts.size()>0)
        {
            for(Account acc : accounts)
            {
                if(String.isNotBlank(acc.Name))
                {
                    result += '{"id":"' + acc.Id + '","text":"' +acc.Name.replaceAll('"', '') + '"},';
                }
            }
        }
        result = result.removeEnd(',');
        result += ']';
        return result;
        
    }
    public PageReference save()
    {
        boolean isValid=true;
        Opportunity opp=[Select Id,Registering_Partner__c,Registering_Partner_Sales_Rep__c,Registered_Distributor__c,Tier2_Partner__c,Registered_Distributor_Contact__c,Primary_Partner__c,Deal_Reg__c from Opportunity where Id=:PartnerData.oppId];
        if(opp !=null && String.isNotBlank(PartnerData.Registering_PartnerId) && opp.Registering_Partner__c!=PartnerData.Registering_PartnerId && opp.Deal_Reg__c)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Sorry, you cannot change the channel definition for opportunities that were initiated by the partner.  If you need to quote someone other than the registered partner, please change the partner and partner contact on the quote.'));
            isValid=false;
        }
       /* if((PartnerData.RSMGEO!='NAM' && PartnerData.RSMGEO!= null && !String.isblank(PartnerData.RSMGEO)) && (PartnerData.Registered_DistributorId == null || String.isBlank(PartnerData.Registered_DistributorId) ))
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Distributor Account is mandatory for international accounts.'));
            isValid=false;
        }   */
        
        if(PartnerData.RSMGEO=='NAM')
        {
            if(PartnerData.Registering_PartnerId==null || String.isBlank(PartnerData.Registering_PartnerId))
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Reseller Account is mandatory for North America Accounts.'));
                isValid=false;
            } 
            if(PartnerData.Registering_PartnerId!=null && !String.isBlank(PartnerData.Registering_PartnerId))
            {
                Account acc=[Select Id,Reseller_Agreement__c from Account where Id=:PartnerData.Registering_PartnerId];
                if(!acc.Reseller_Agreement__c && (PartnerData.Registered_DistributorId==null || String.isBlank(PartnerData.Registered_DistributorId))) 
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Distributor Partner Account is required as reseller doesnt have valid reseller agreement.'));
                    isValid=false;
                }
            }
        } 
        /* Removing requirement for partner sales rep
        * if((PartnerData.Registering_PartnerId!=null && !String.isBlank(PartnerData.Registering_PartnerId)) && (PartnerData.Registering_Partner_Sales_RepId == null|| String.isBlank(PartnerData.Registering_Partner_Sales_RepId)) )
        * {
        *     ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select Reseller Contact.'));
        *     isValid=false;
        * } 
        */
        
        if((PartnerData.Registering_PartnerId!=null && !String.isBlank(PartnerData.Registering_PartnerId)) && (PartnerData.Registering_Partner_Sales_RepId != null && !String.isBlank(PartnerData.Registering_Partner_Sales_RepId)) )
        {
            Contact con=[Select Id,AccountId from Contact where Id=:PartnerData.Registering_Partner_Sales_RepId];
            if(con.AccountId != PartnerData.Registering_PartnerId)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'This contact does not belong to this Reseller Account.'));
                isValid=false;
            }
        } 
        if(isValid)
        {
            Savepoint sp = Database.setSavepoint();
            ReevaluateOppShares(opp.Id, opp.Registering_Partner_Sales_Rep__c, opp.Registering_Partner__c,true);

            opp.Registering_Partner__c = String.isBlank(PartnerData.Registering_PartnerId)?null:PartnerData.Registering_PartnerId;
            opp.Registered_Partner__c = opp.Registering_Partner__c;
            opp.Registering_Partner_Sales_Rep__c = String.isBlank(PartnerData.Registering_Partner_Sales_RepId)?null:PartnerData.Registering_Partner_Sales_RepId;
            opp.Registered_Distributor__c = String.isBlank(PartnerData.Registered_DistributorId)?null:PartnerData.Registered_DistributorId;
            opp.Registered_Distributor_Contact__c = String.isBlank(PartnerData.Registered_Distributor_RepId)?null:PartnerData.Registered_Distributor_RepId;
           
            opp.Tier1_Partner__c = opp.Registering_Partner__c;
            opp.Tier2_Partner__c = opp.Registered_Distributor__c;
            opp.Tier3_Partner__c = String.isBlank(PartnerData.Tier3_PartnerId) ? (String.isBlank(PartnerData.Registered_DistributorId)?PartnerData.Registering_PartnerId:PartnerData.Registered_DistributorId) : PartnerData.Tier3_PartnerId;
            
            if(!String.isBlank(PartnerData.Registered_DistributorId))
            {
                System.debug('Distributor'+PartnerData.Registered_DistributorId);
                
                List<Contact> lstCon=[Select Id from Contact where AccountId=:PartnerData.Registered_DistributorId and Quote_Contact__c=true];
                if(lstCon!=null && lstCon.size()>0)
                {
                    opp.Registered_Distributor_Contact__c=lstCon[0].Id;
                }
            }
            
            try
            {
                
                update opp;
                //shares opportunity to partner
                ReevaluateOppShares(opp.Id, opp.Registering_Partner_Sales_Rep__c, opp.Registering_Partner__c,false);
                ResetPartnerList(opp.Id, opp.Tier1_Partner__c, opp.Tier2_Partner__c, opp.Tier3_Partner__c);
                
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
            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Succeeded.<script type="text/javascript">opener.location="/'+opp.Id+'";setTimeout("window.close()", 3000)</script>'));
        }        
        SetInitialData(PartnerData.oppId);
        return null;
    }
    
    private void ResetPartnerList(Id oppId, Id tier1Id, Id tier2Id, Id tier3Id)
    {
        delete [select Id from Partner where OpportunityId=:oppId];
        List<Partner> newPartners = new List<Partner>();
        if(tier1Id != null)
        {
            newPartners.add(new Partner(OpportunityId=oppId, Role='Tier 1', AccountToId=tier1Id, IsPrimary=false));
        }
        if(tier2Id != null)
        {
            newPartners.add(new Partner(OpportunityId=oppId, Role='Tier 2', AccountToId=tier2Id, IsPrimary=false));
        }
        if(tier3Id != null)
        {
            if((tier2Id != null && tier2Id != tier3Id) || (tier2Id == null && tier1Id != tier3Id))
            {
                newPartners.add(new Partner(OpportunityId=oppId, Role='Tier 3', AccountToId=tier3Id, IsPrimary=false));
            }
        }
        if(newPartners.size() > 0)
        {
            newPartners[newPartners.size() - 1].IsPrimary = true;
        }
        insert newPartners;
    }
    
    private void ReevaluateOppShares(Id oppId,Id partnerContactId, Id partnerAccId,boolean isDelete)
    {
        List<OpportunityShare> oppShares = new List<OpportunityShare>();
        Set<Id> setUserIds=new Set<Id>();
        if(partnerContactId!=null)
        {
            List<User> partnerUser = [select Id from User where UserType='PowerPartner' and ContactId=:partnerContactId and isActive=true];
            if(partnerUser!=null && partnerUser.size()>0)
            {
                setUserIds.add(partnerUser[0].Id);
            }
            
        }
        if(partnerAccId!=null)
        {
            
            Account partnerAcc=[Select Name from Account where Id=:partnerAccId];
            string partnerAcctName= partnerAcc.Name;
            if(partnerAcctName!='')
            {
                //partnerAcctName= partnerAcctName.replaceAll( '\\s+', '');
                string portalRoleName= partnerAcctName+' Partner Manager';
                System.debug('portalRoleName'+portalRoleName);
                List<Group> lstGroup=[SELECT Id,Name,DeveloperName,Type FROM Group where RelatedId in(Select Id from UserRole where Name=:portalRoleName) and Type='Role'];
                System.debug('lstGroup'+lstGroup);
                if(lstGroup!=null && lstGroup.size()>0) 
                {
                    setUserIds.add(lstGroup[0].Id);
                }
            }
        }
        
        if(isDelete)
        {
            
            if(setUserIds.size()>0)
            {
                oppShares=[select Id from OpportunityShare where OpportunityId=:oppId and UserOrGroupId in :setUserIds];
                if(oppShares.size()>0)
                {
                    Database.delete(oppShares, false);
                }
                
            }
        }
        else
        {
            
            if(setUserIds.size()>0)
            {
                for (Id user : setUserIds)
                {
                    OpportunityShare oppShare = new OpportunityShare(OpportunityId=oppId, UserOrGroupId=user, OpportunityAccessLevel='Edit');
                    oppShares.add(oppShare);
                }
                if(oppShares.size()>0)
                {
                    Database.insert(oppShares, false);
                }
            }
        }
        
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
    @remoteAction
    public static string InitResellerContacts(string accountName,string term)
    {
        
        List<Contact> contacts = new List<Contact>();
        String result = '[{"id":"","text":"-NONE-"},';
        
        if(String.isBlank(accountName))
        {
            return '[{"id":"","text":"-NONE-"}]';
        }
        
        String soql = 'select Id, Name from Contact where Account.Name='+ '\'' + String.escapeSingleQuotes(accountName) + '\'';
        if(String.isNotBlank(term) && term.length() > = 2)
        {
            soql += ' and Name like \'' + String.escapeSingleQuotes(term) + '%\' ';
        }
        soql += ' order by Name limit 200';
        //System.debug(soql);
        contacts= Database.query(soql);
        if(contacts!=null && contacts.size()>0)
        {
            for(Contact con : contacts)
            {
                if(String.isNotBlank(con.Name))
                {
                    result += '{"id":"' + con.Id + '","text":"' +con.Name.replaceAll('"', '') + '"},';
                }
            }
        }
        result = result.removeEnd(',');
        result += ']';
        return result;
        
    }
    
}