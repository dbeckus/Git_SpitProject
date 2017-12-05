/*
 * update account when status = Approved or create child account when status = 'Rejected'; 
 * Set status after account update - 'Merged' or 'Child Account Created'
 * @Author: SnapBi
 * @ChangeLog
 * 13/1/2017 Daniel - created
 * 18/1/2017 Andy - added for loop starting line 19 to allow process flow to submit child account for approval
 * 07/2/2017 Andy - added for loop to add values to existing account
 * 13/02/2017 Andy - changed status values, removed CAM and set billing address only for child accounts
 */
trigger InforCardHandleTrigger on Information_Card__c (after update) {
    List<Information_Card__c> approvedCards = new List<Information_Card__c>();
    List<Information_Card__c> modifiedCards = new List<Information_Card__c>();
    List<Account> accts = new List<Account>();
    Set<Id> acctIds = new Set<Id>();
    for(Information_Card__c card : trigger.new)
    {
        if(card.Status__c == 'Rejected' && trigger.oldMap.get(card.Id).Status__c != 'Rejected')
        {
            accts.add(populateAccount(card, new Account()));
            //setting parnter application status and created from info card so child account can be submitted for approval
            for(Account a : accts)
            {
                a.Created_from_Information_Card__c = True;
                a.Partner_Application_Status__c = 'Pending';
                a.Type = 'Partner';
                a.BillingCity = card.Billing_City__c;
                a.BillingCountry = card.Billing_Country__c;
                a.BillingPostalCode = card.Billing_Postal_Code__c;
                a.BillingState = card.Billing_State__c;
                a.BillingStreet = card.Billing_Street__c;
                a.Region__c = card.Region__c;
                a.Website = card.Website__c;
                a.Name = card.Company_Name__c;
            }
            modifiedCards.add(card);
        }
        else if(card.Status__c == 'Approved' && trigger.oldMap.get(card.Id).Status__c != 'Approved')
        {
            approvedCards.add(card);
            acctIds.add(card.Account__c);
        }
    }
    if(!approvedCards.isEmpty())
    {
        modifiedCards.addAll(approvedCards);
        for(Account acct : [Select ParentId, business_is_Consulting_Sales__c, business_is_Product_Sales__c, business_is_Services_Sales__c, Parent_Company__c, Are_you_an_authorized_partner_of__c, 
                           BillingCity, BillingCountry, BillingPostalCode, BillingState, BillingStreet, Name, Distributor_of_Choice__c, Email_Domain_Used__c, Integrate_cloudsolutions_with_vendors__c,
                           Marketting_Oferrings__c, Number_of_employees_in_your_organization__c, Own_brand_of_professional_services__c, Phone, Primary_target_market_size__c, Professionals_in_your_org_Inside_Sales__c,
                           Number_of_sales_professionals_in_org__c, Professionals_in_org__c, Provide_technical_support__c, Region__c, Silver_Peak_oppo_pend__c, Tax_ID_Number__c, Please_Name_the_Vendors__c, 
                           TOP_3_industries__c, total_annual_sales_revenues_last_year__c, Website, Years_in_Business__c, MarketingPartnerContact__c, PrimaryPartnerContact__c, 
                           RegisteringUserContact__c, SignatoryPartnerContact__c from Account where Id in: acctIds])
        {
            for(Information_Card__c card : approvedCards)
            {
                if(card.Account__c == acct.Id)
                {
                    accts.add(populateAccount(card, acct));
                    for(Account a : accts)
                    {
                        a.Updated_from_Information_Card__c = True;
                        a.Partner_Application_Status__c = 'Pending';
                    }
                }
            }
        }
    }
    if(!modifiedCards.isEmpty())
    {
        List<Information_Card__c> cards = new List<Information_Card__c>();
        for(Information_Card__c card : [Select Id, Status__c from Information_Card__c where Id in: modifiedCards])
        {
            if(card.Status__c == 'Rejected')
            {
                card.Status__c = 'Child Account Created';
            }
            else if(card.Status__c == 'Approved')
            {
                card.Status__c = 'Merged';
            }
            cards.add(card);
        }
        try
        {
            Database.update(cards, false);
        }
        catch(DmlException ex)
        {
            SilverPeakUtils.logException(ex);
        }
    }
    if(!accts.isEmpty())
    {
        try
        {
            Database.upsert(accts, false);
            Map<Id, Id> con2Acc = new Map<Id, Id>();
            for(Account acct : accts)
            {
                con2Acc.put(acct.MarketingPartnerContact__c, acct.Id);
                con2Acc.put(acct.PrimaryPartnerContact__c, acct.Id);
                con2Acc.put(acct.RegisteringUserContact__c, acct.Id);
                con2Acc.put(acct.SignatoryPartnerContact__c, acct.Id);
            }
            con2Acc.remove(null);
            List<Contact> cons = new List<Contact>();
            for(Contact con : [Select Id, AccountId from Contact where Id In: con2Acc.keySet()])
            {
                con.CanAllowPartnerPortalSelfReg__c = True;
                con.AccountId = con2Acc.get(con.Id);
                cons.add(con);
            }
            if(!cons.isEmpty())
            {
                update cons;
            }
        }
        catch(DmlException ex)
        {
            SilverPeakUtils.logException(ex);
        }
    }

    
    private Account populateAccount(Information_Card__c card, Account acct)
    {
        acct.business_is_Consulting_Sales__c = card.business_is_Consulting_Sales__c;
        acct.business_is_Product_Sales__c = card.business_is_Product_Sales__c;
        acct.business_is_Services_Sales__c = card.business_is_Services_Sales__c;
        //acct.Parent_Company__c = String.isBlank(acct.Id) ? card.Account__c : acct.Parent_Company__c;
        acct.ParentId = String.isBlank(acct.Id) ? card.Account__c : acct.ParentId;
        //card.Account_CAM__c = [Select Id, CAM__c from Account where Id =: acct.Id].CAM__c;
        acct.Are_you_an_authorized_partner_of__c = card.Are_you_an_authorized_partner_of__c;
        //data to be overwritten only if existing account field is null
        acct.BillingCity = String.isBlank(acct.BillingCity) ? card.Billing_City__c : acct.BillingCity;
        acct.BillingCountry = String.isBlank(acct.BillingCountry) ? card.Billing_Country__c : acct.BillingCountry;
        acct.BillingPostalCode = String.isBlank(acct.BillingPostalCode) ? card.Billing_Postal_Code__c : acct.BillingPostalCode;
        acct.BillingState = String.isBlank(acct.BillingState) ? card.Billing_State__c : acct.BillingState;
        acct.BillingStreet = String.isBlank(acct.BillingStreet) ? card.Billing_Street__c : acct.BillingStreet;
        acct.Region__c = String.isBlank(acct.Region__c) ? card.Region__c : acct.Region__c;
        acct.Website = String.isBlank(acct.Website) ? card.Website__c : acct.Website;
        //acct.BillingCity = card.Billing_City__c;
        //acct.BillingCountry = card.Billing_Country__c;
        //acct.BillingPostalCode = card.Billing_Postal_Code__c;
        //acct.BillingState = card.Billing_State__c;
        //acct.BillingStreet = card.Billing_Street__c;
        //acct.Name = card.Company_Name__c;
        //acct.Region__c = card.Region__c;
        //acct.Website = card.Website__c;
        acct.Distributor_of_Choice__c = card.Distributor_of_Choice__c;
        acct.Email_Domain_Used__c = card.Email_Domain_Used__c;
        acct.Integrate_cloudsolutions_with_vendors__c = card.Integrate_Cloud_Solutions_with_Vendors__c;
        acct.Marketting_Oferrings__c = card.Marketing_Offerings__c;
        acct.Number_of_employees_in_your_organization__c = card.Number_of_employees_in_your_organization__c;
        acct.Own_brand_of_professional_services__c = card.Own_brand_of_professional_services__c;
        acct.Phone = card.Phone__c;
        acct.Please_Name_the_Vendors__c = card.Please_Name_the_Vendors__c;
        acct.Primary_target_market_size__c = card.Primary_target_market_size__c;
        acct.Professionals_in_your_org_Inside_Sales__c = card.Professionals_in_your_org_Inside_Sales__c;
        acct.Number_of_sales_professionals_in_org__c = card.Number_of_sales_professionals_in_org__c;
        acct.Professionals_in_org__c = card.Professionals_in_org__c;
        acct.Provide_technical_support__c = card.Provide_technical_support__c;
        acct.GEO_Supported__c = card.Region__c;
        acct.Silver_Peak_oppo_pend__c = card.Silver_Peak_opportunity_pending__c;
        acct.Tax_ID_Number__c = card.Tax_ID_Number__c;
        acct.TOP_3_industries__c = card.TOP_3_industries__c;
        acct.total_annual_sales_revenues_last_year__c = card.Total_annual_sales_revenues_last_year__c;
        acct.Years_in_Business__c = card.Years_in_Business__c;
        //update acct contact information
        acct.MarketingPartnerContact__c = card.MarketingPartnerContact__c != null ? card.MarketingPartnerContact__c : acct.MarketingPartnerContact__c;
        acct.PrimaryPartnerContact__c = card.PrimaryPartnerContact__c != null ? card.PrimaryPartnerContact__c : acct.PrimaryPartnerContact__c;
        acct.RegisteringUserContact__c = card.RegisteringUserContact__c != null ? card.RegisteringUserContact__c : acct.RegisteringUserContact__c;
        acct.SignatoryPartnerContact__c = card.SignatoryPartnerContact__c != null ? card.SignatoryPartnerContact__c : acct.SignatoryPartnerContact__c;
        acct.Reseller_Agreement_Acknowledged__c = true;
        return acct;
    }
    /*
    private void submitToProcess(Id objId)
    {
        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
        req.setObjectId(objId);
        Approval.ProcessResult result = Approval.Process(req);
    }
    */
}