/*
 * Includes helper methods for the trigger LeadToPOCAutomation
 */
public without sharing class LeadToPOCAutomationHelper
{
    //uses Lead Model_for_Trial__c to find a campaign with related product model in the custom setting ProductCampaignMapping__c. Links lead with the campaign.
    public static void linkLeadToModelCampaign(Id leadId, String model)
    {
        if(!String.isEmpty(model))
        {
            List<String> campaignIds = new List<String>();
            List<ProductCampaignMapping__c> product2CampaignIds = [select Id, Name, CampaignId__c from ProductCampaignMapping__c where Name = :model limit 1];
            if(product2CampaignIds.size() > 0)
            {
                for(String campaignId : product2CampaignIds[0].CampaignId__c.split(','))
                {
                    campaignIds.add(campaignId.trim());
                }
            }
            List<CampaignMember> campaignMembers = new List<CampaignMember>();
            for(String campaignId : campaignIds)
            {
                if(!String.isEmpty(campaignId) && !isCampaignMemberExist(leadId, campaignId))
                {
                    campaignMembers.add(new CampaignMember(LeadId = leadId, CampaignId = campaignId, Status = 'Responded'));
                }
            }
            try
            {
                insert campaignMembers;
            }
            catch(Exception ex)
            {
                SilverPeakUtils.logException('Exception in LeadToPOCAutomationHelper', 'Failed to link lead[' + leadId + '] with campaign [' + model+ '], the error message is: ' + ex.getMessage() + '\r\n' + ex.getStackTraceString());
            }
        }
    }
    
    //uses Lead Marketplace_Code__c to find a campaign from partner account profile and links lead with the campaign.
    public static void linkLeadToMarketplaceCampaign(Id leadId, String marketplaceCode)
    {
        if(!String.isEmpty(marketplaceCode))
        {
            Id campaignId = null;
            String leadMarketplaceCode = marketplaceCode.toLowerCase();
            Map<String, Id> campaignCode2CampaignId = new Map<String, Id>();
            List<Partner_Account_Profile__c> paps = [select Marketplace_1__c, Marketplace_2__c, Marketplace_3__c, 
                                                       Marketplace_Code_1_Campaign__c, Marketplace_Code_2_Campaign__c, Marketplace_Code_3_Campaign__c
                                                       from Partner_Account_Profile__c where Marketplace_1__c = :leadMarketplaceCode or Marketplace_2__c = :leadMarketplaceCode or Marketplace_3__c = :leadMarketplaceCode limit 1];
            if(paps.size() > 0)
            {
                String code1 = paps[0].Marketplace_1__c == null ? '' : paps[0].Marketplace_1__c;
                String code2 = paps[0].Marketplace_2__c == null ? '' : paps[0].Marketplace_2__c;
                String code3 = paps[0].Marketplace_3__c == null ? '' : paps[0].Marketplace_3__c;
                campaignCode2CampaignId.put(code1.toLowerCase(), paps[0].Marketplace_Code_1_Campaign__c);
                campaignCode2CampaignId.put(code2.toLowerCase(), paps[0].Marketplace_Code_2_Campaign__c);
                campaignCode2CampaignId.put(code3.toLowerCase(), paps[0].Marketplace_Code_3_Campaign__c);
            }
            if(campaignCode2CampaignId.containsKey(leadMarketplaceCode) && campaignCode2CampaignId.get(leadMarketplaceCode) != null)
            {
                campaignId = campaignCode2CampaignId.get(leadMarketplaceCode);
            }
            if(!String.isEmpty(campaignId) && !isCampaignMemberExist(leadId, campaignId))
            {
                CampaignMember campaignMember = new CampaignMember(LeadId = leadId, CampaignId = campaignId, Status = 'Responded');
                try
                {
                    insert campaignMember;
                }
                catch(Exception ex)
                {
                    SilverPeakUtils.logException('Exception in LeadToPOCAutomationHelper', 'Failed to link lead[' + leadId + '] to the campaign of marketplace code [' + leadMarketplaceCode + '], the error message is: ' + ex.getMessage()+ '\r\n' + ex.getStackTraceString());
                }
            }
        }
    }
    
    public static void linkLeadToCampaign(Id leadId, Id campaignId)
    {
        if(campaignId != null)
        {
            if(!isCampaignMemberExist(leadId, campaignId))
            {
                try
                {
                    insert new CampaignMember(LeadId = leadId, CampaignId = campaignId, Status = 'Responded');
                }
                catch(Exception ex)
                {
                    SilverPeakUtils.logException('Exception in LeadToPOCAutomationHelper', 'Failed to link lead[' + leadId + '] to the campaign of Id [' + campaignId + '], the error message is: ' + ex.getMessage()+ '\r\n' + ex.getStackTraceString());
                }
            }
        }
    }
    
    @future
    public static void convertAndFulfillTrial(Id leadId)
    {
        SavePoint sp = Database.setSavePoint();
        List<Lead> leads = [select Id, FirstName, LastName, Email, Model_for_Trial__c, Marketplace_Code__c, Company, Description, IsConverted, Patch__c, Patch__r.ISR__c from Lead where id=:leadId limit 1 for update];
        if(leads.size() == 0 || leads[0].IsConverted)
        {
            return;
        }

        Lead lead = leads[0];
        if(lead.Patch__r.ISR__c != null)
        {
            //assign MP owner id to ISR because SFDC updates owner id to Curtis on all web2leads.
            SilverPeakUtils.BypassingTriggers = true;
            lead.OwnerId = lead.Patch__r.ISR__c;
            update lead;
            SilverPeakUtils.BypassingTriggers = false;
        }
        
        Account account = null;
        Contact cont = getLatestContactByEmail(lead.email);
        if(cont == null)
        {
            account = findAccount(lead.Email, lead.Company);
        }
        try
        {
            //convert lead
            Database.leadConvertResult result = doLeadConversion(lead, cont, account, ' Free Marketplace Trial', 'Converted to New Opportunity');
        
            list<Opportunity> opplist = [Select Id, Type, StageName, Amount, Opportunity_Source__c, Trigger_POC__c, OwnerId From Opportunity Where Id =:result.getOpportunityId()];
            if(!opplist.isEmpty())
            {
                
                //update opportunity
                Opportunity opp = opplist[0];
                opp.Type = 'Marketplace';
                opp.StageName = 'Marketplace Trial';
                opp.Amount = 0;
                opp.OwnerId = '005500000045fp1';      //Assign marketplace trial opps to dennis
                opp.Opportunity_Source__c = 'Marketing';
                opp.Trigger_POC__c = true;
                Map<String, Schema.RecordTypeInfO> oppRecordTypes = Schema.SObjectType.Opportunity.getRecordTypeInfosByName();
                if(oppRecordTypes.containsKey('Deleted'))
                {
                    opp.RecordTypeId = oppRecordTypes.get('Deleted').getRecordTypeId();
                }
                update opp;
                
                //Update Contact
                List<Contact> newcnct = [Select Id, CanAllowPortalSelfReg, (select Id from OpportunityContactRoles where Opportunity.IsClosed=false limit 1) From Contact Where Id =:result.getContactId()];
                Contact cnct = newcnct[0];
                cnct.CanAllowPortalSelfReg = True;
                if(cont == null || cnct.OpportunityContactRoles.size() == 0)
                {
                    cnct.Lead_Status__c = 'Marketing Nurturing';
                }
                update cnct;
                
                //add POC request
                List<LeadToPOCAutomationHelper.ModelInfo> models = LeadToPOCAutomationHelper.resolveModelTrial(lead.Model_for_Trial__c);                
                String trialModel = (models.size() > 0) ? models[0].Name : '';
                String hypervisor = (models.size() > 0) ? models[0].Type : '';
                Request__c req = VirtualPOCFulfillmentController.createPOC(result.getContactId(), lead, trialModel, hypervisor, opp);
                VirtualPOCFulfillmentController pocController = new VirtualPOCFulfillmentController(new ApexPages.StandardController(req));
                pocController.isFromApex = true;
                if(req.Target_End_Date__c != null)
                {
                    pocController.LicenseDurationDays = Date.today().daysBetween(req.Target_End_Date__c);
                }
                pocController.save();
            }
            if(account == null)
            {
                //if it's a new MP trial account, route account owner based on GEO
                List<Account> accs = [select Patch__c, Patch__r.RSM__c, Patch__r.CSM__c, GEO_Supported__c, Type from Account where Id=:result.getAccountId() limit 1];
                if(accs.size() > 0)
                {
                    account = accs[0];
                    if(account.Patch__r.RSM__c != null)
                    {
                        account.OwnerId = account.Patch__r.RSM__c;
                    }
                    String geo = account.GEO_Supported__c == null ? '' : account.GEO_Supported__c;
                    if(account.Patch__r.CSM__c != null && account.Type == 'Partner' && !geo.contains('APAC') && !geo.contains('EMEA'))
                    {
                        account.OwnerId = account.Patch__r.CSM__c;
                    }
                    update account;
                }
            }
        }
        catch(Exception ex)
        {
            Database.rollback(sp);
            throw ex;
        }
    }
    
    @future
    public static void convertAndFulfillBuy(Id leadId)
    {        
        SavePoint sp = Database.setSavePoint();
        string oppType='New Business';
        List<Lead> leads = [select Id, FirstName, LastName, Email, Model_for_Trial__c, Marketplace_Code__c, Company, Description, IsConverted from Lead where id=:leadId limit 1 for update];
        if(leads.size() == 0)
        {
            return;
        }
        if(leads[0].IsConverted)
        {
            return;
        }
        Lead lead = leads[0];
        Contact cont = getLatestContactByEmail(lead.email);
        if(cont!=null)
        {
            string acctType= cont.Account.Type;
            if(acctType!='Prospect')
            {
                oppType='Follow on Business';
            }
        }
        try
        {
            //convert lead
            Database.leadConvertResult result = doLeadConversion(lead, cont, null, ' Marketplace Purchase Request', 'Approved');       
            list<Opportunity> opplist = [Select Id, Type, StageName, Pricebook2Id, Amount, Opportunity_Source__c, Trigger_POC__c, Probability, OwnerId From Opportunity Where Id =:result.getOpportunityId()];
            if(!opplist.isEmpty())
            {           
                Integer qty = 0;
                Set<String> modelNames = new Set<String>();
                Map<String, Integer> productCodeToQty = new Map<String, Integer>();
                String defaultPricebookId, oppId = opplist[0].Id;                
                List<PriceBook2> pricebooks = [select id from PriceBook2 where Name = 'Standard Price Book'];
                if(!pricebooks.isEmpty())
                {
                    defaultPricebookId = pricebooks[0].id;
                }
                opplist[0].Pricebook2Id = defaultPricebookId;
                opplist[0].StageName = 'Technically Selected';
                opplist[0].Probability = 50;
                opplist[0].Type=oppType;
                update opplist[0];                
                
                List<LeadToPOCAutomationHelper.ModelInfo> models = LeadToPOCAutomationHelper.resolveModelTrial(lead.Model_for_Trial__c);                
                for(LeadToPOCAutomationHelper.ModelInfo model : models)
                {
                    modelNames.add(model.Name);
                }
                
                List<PurchaseRequestMatrix__c> productMatrixes = [select Name, Price__c, PartNumber__c, GoldMaintenancePrice__c, GoldMaintenancePartNumber__c, PlatinumMaintenancePrice__c, PlatinumMaintenancePartNumber__c, SubscriptionPrice__c, SubscriptionPartNumber__c from PurchaseRequestMatrix__c where Name in :modelNames];
                if(!productMatrixes.isEmpty())
                {   
                    Set<String> allProductCodes = new Set<String>();
                    for(LeadToPOCAutomationHelper.ModelInfo model : models)
                    {
                        if(model.Type == 'S')
                        {
                            for(PurchaseRequestMatrix__c matrix : productMatrixes)
                            {
                                if(matrix.Name == model.Name)
                                {
                                    productCodeToQty.put(matrix.SubscriptionPartNumber__c, model.Qty);
                                    allProductCodes.add(matrix.SubscriptionPartNumber__c);
                                }
                            }
                        }
                        else if(model.Type == 'G' || model.Type == 'P')
                        {
                            for(PurchaseRequestMatrix__c matrix : productMatrixes)
                            {
                                if(matrix.Name == model.Name)
                                {
                                    productCodeToQty.put(model.Type == 'G' ? matrix.GoldMaintenancePartNumber__c : matrix.PlatinumMaintenancePartNumber__c, model.Qty);
                                    productCodeToQty.put(matrix.PartNumber__c, model.Qty);                                    
                                    allProductCodes.add(matrix.PartNumber__c);
                                    allProductCodes.add(model.Type == 'G' ? matrix.GoldMaintenancePartNumber__c : matrix.PlatinumMaintenancePartNumber__c);
                                }
                            }                            
                        } 
                        else
                        {
                            //if the model_for_trial field value doesn't have model type/Qty, it's ignored.
                        }
                    }
                    List<Product2> products =[select id, ProductCode from Product2 where ProductCode in :allProductCodes];
                    List<PriceBookEntry> pbEntries = [select id, UnitPrice, Product2Id from PriceBookEntry where Pricebook2Id = :defaultPricebookId and Product2Id in : products];
                    if(!pbEntries.isEmpty())
                    {                                     
                        List<OpportunityLineItem> insertItems = new List<OpportunityLineItem>();
                        for(PriceBookEntry entry : pbEntries)
                        {
                            for(Product2 prod : products)
                            {
                                if(entry.Product2Id == prod.id)
                                {
                                    insertItems.add(new OpportunityLineItem(OpportunityId = oppId, PricebookEntryId = entry.Id, Quantity = productCodeToQty.get(prod.ProductCode), UnitPrice = entry.UnitPrice));
                                }
                            }                            
                        }
                        insert insertItems;
                    }
                }
            }
        }
        catch(Exception ex)
        {
            Database.rollback(sp);
            throw ex;
        }        
    }
    
    //This return map has three keys:ProductName, ModelType, Qty.
    public static List<ModelInfo> resolveModelTrial(String model)
    {
        List<ModelInfo> resolveModeResult = new List<ModelInfo>();
        model = (model == null) ? '' : model;
        String[] models = model.split(',');
        for(Integer i = 0; i < models.size(); i++)
        {
            ModelInfo newModel = new ModelInfo();
            String[] nameModel = models[i].trim().split('-');
            String productName = '';        
            if(nameModel.size() >= 3)
            {
                newModel.Qty = Integer.valueOf(nameModel[nameModel.size() - 1]);
                newModel.Type = nameModel[nameModel.size() - 2].toUpperCase();
                for(Integer j = 0; j < nameModel.size() - 2; j++)
                {
                    productName += nameModel[j] + '-';
                }
                newModel.Name = productName.substring(0, productName.length()-1);
            }
            else
            {
                newModel.Name =  model;
            }
            resolveModeResult.add(newModel);
        }       
        return resolveModeResult;
    }
    
    //checks that if the lead has already linked to the campaign
    private static Boolean isCampaignMemberExist(String leadId, String campaignId)
    {
        List<CampaignMember> campaignMembers = [select Id from CampaignMember where LeadId = :leadId and CampaignId = :campaignId limit 1];
        return campaignMembers.size() > 0; 
    }

    public static void replaceLeadName(Lead lead)
    {
        Contact cont = getLatestContactByEmail(lead.email);
        String leadname = String.isBlank(lead.FirstName) ? lead.LastName : (lead.FirstName + ' ' + lead.LastName);

        //lead.Description = 'Lead Name: '+leadname+'; Company: '+lead.Company+';';
        if(cont != null)
        {
            lead.FirstName = cont.Firstname;
            lead.LastName = cont.Lastname;
            lead.Company = cont.Account.Name;
        }
        else
        {
            /*lead.FirstName = '';
            lead.LastName = lead.Email;
            lead.Company = lead.Email;*/
        }
    }
    
    //Gets the latest contact by email
    private static Contact getLatestContactByEmail(string myemail)
    {
        if(myemail != null && myemail.length() >= 2)
        {
            list<list<Contact>> mylist = [FIND :myemail In EMAIL FIELDS RETURNING 
                                          Contact(Id, Firstname, Lastname, Email, AccountId, Account.Name, CreatedById , Account.Type
                                            where accountId != null
                                            order by createdById desc limit 1)];
            if(mylist[0].size() > 0)
            {
                return mylist[0][0];
            }
        }
        return null;
    }
    
    private static Account findAccount(String email, String name)
    {
        Account result = null;
        if(String.isNotBlank(email))
        {
            String domain = email.substring(email.indexOf('@'));
            String pattern = '%' + domain;
            List<Contact> contacts = [select Id, FirstName, LastName, Email, AccountId, Account.Name from Contact where Email like :pattern and Account.Name=:name limit 1];
            return (contacts.size() > 0) ? new Account(Id=contacts[0].AccountId, Name=contacts[0].Account.Name) : null;
        }
        return result;
    }
    
    private static Database.leadConvertResult doLeadConversion(Lead ld, Contact contactByEmail, Account acc, String oppoNameSuffix, String postStatus)
    {
        Database.LeadConvert lc = new Database.LeadConvert();
        lc.setLeadId(ld.id);
        lc.setDoNotCreateOpportunity(false);
        if(contactByEmail != null)
        {
            lc.setAccountId(contactByEmail.AccountId);
            lc.setContactId(contactByEmail.Id);
            lc.setOpportunityName(contactByEmail.Account.Name + oppoNameSuffix);
        }
        else if(acc != null)
        {
            lc.setAccountId(acc.Id);
            lc.setOpportunityName(acc.Name + oppoNameSuffix);
        }
        else
        {
            lc.setOpportunityName(ld.Company + oppoNameSuffix);
        }
        lc.setConvertedStatus(postStatus);
        Lead updateLead = new Lead(Id = ld.Id, Marketplace_Fulfillment_Only__c=true);
        update updateLead;
        Database.leadConvertResult lcr = Database.convertLead(lc);           
        return lcr;
    }
    
    
    //Updates existing lead (duplication function is turned off)
    public static Id duplicateOrUpdateLead(Lead lead)
    {
        //finds an existing Lead by email and updates it. If none found, clone one. If multiple found, gets the latest created one.
        Id leadId = null;
        List<Lead> leads = new List<Lead>();
        if(String.isNotEmpty(lead.Email))
        {
            leads = [select Id from Lead where Email = :lead.Email and IsConverted = false order by CreatedDate desc limit 1];
        }
        if(leads.size() > 0)
        {
            Lead latestLead = new Lead(Id = leads[0].Id, FirstName = lead.FirstName, LastName = lead.LastName, Company = lead.Company, Phone = lead.Phone, 
                                       Model_for_Trial__c = lead.Model_for_Trial__c, Marketplace_Code__c = lead.Marketplace_Code__c);
            try
            {
                update latestLead;
            }
            catch(Exception ex)
            {
                lead.addError('Failed to update the existing lead, the error message is: ' + ex.getMessage());
            }
            leadId = latestLead.Id;
        }
        else
        {
            /*Lead clonedLead = lead.clone(false, false, false, false);
            clonedLead.Trial_Request_from_Marketplace__c = false;
            List<RecordType> leadRecordTypes = [select Id from RecordType where sObjectType='Lead' and Name='Lead' and IsActive=true limit 1];
            if(leadRecordTypes.size() == 1)
            {
                clonedLead.RecordTypeId = leadRecordTypes[0].Id;
            }
            try
            {
                insert clonedLead;
            }
            catch(Exception ex)
            {
                lead.addError('Failed to clone a lead, the error message is: ' + ex.getMessage());
            }
            leadId = clonedLead.Id;*/
        }
        return leadId;
    }
    
    public static Boolean isEmailBlacklisted(String email)
    {
        email = (email == null) ? '' : email;
        email = email.toLowerCase();
        String emailDomain = email.substring(email.indexOf('@') + 1);
        //check if the email is blacklisted
        for(BlacklistedDomains__c bld : BlacklistedDomains__c.getAll().values())
        {
            String blacklistedDomain = bld.domain__c.toLowerCase();
            if(blacklistedDomain.startsWith('*.'))
            {
                blacklistedDomain = blacklistedDomain.right(blacklistedDomain.length() - 2);
                if(emailDomain.endsWith(blacklistedDomain))
                {
                    return true;
                }
            }
            else if(emailDomain.startsWith(blacklistedDomain))
            {
                //the domain should exactly match, or is sub domain (means separated by dot)
                if(emailDomain.length() == blacklistedDomain.length() || emailDomain.substring(blacklistedDomain.length(), blacklistedDomain.length() + 1) == '.')
                {
                    return true;
                }
            }
        }
        return false;
    }
    
    public class ModelInfo
    {
        public String Name { get; set; } 
        public String Type { get; set; } 
        public Integer Qty { get; set; }         
    }
}