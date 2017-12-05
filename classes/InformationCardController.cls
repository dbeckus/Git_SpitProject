public class InformationCardController {
    public Information_Card__c card{ get; set; }
    
    public InformationCardController(ApexPages.StandardController controller)
    {
        String cardId = Apexpages.currentPage().getParameters().get('id');
        card = getCard(cardId);    
    }
    
    private Information_Card__c getCard(String cardId)
    {
        List<Information_Card__c> cards = [Select business_is_Consulting_Sales__c, business_is_Product_Sales__c, business_is_Services_Sales__c, Are_you_an_authorized_partner_of__c, 
                Billing_City__c, Billing_Country__c, Billing_Postal_Code__c, Billing_State__c, Billing_Street__c, Company_Name__c, Distributor_of_Choice__c, Email_Domain_Used__c, Integrate_Cloud_Solutions_with_Vendors__c,
                Marketing_Offerings__c, Number_of_employees_in_your_organization__c, Own_brand_of_professional_services__c, Phone__c, Primary_target_market_size__c, Professionals_in_your_org_Inside_Sales__c,
                Number_of_sales_professionals_in_org__c, Professionals_in_org__c, Provide_technical_support__c, Region__c, Silver_Peak_opportunity_pending__c, Tax_ID_Number__c, 
                TOP_3_industries__c, total_annual_sales_revenues_last_year__c, Website__c, Years_in_Business__c, MarketingPartnerContact__c, PrimaryPartnerContact__c, Please_Name_the_Vendors__c,
                RegisteringUserContact__c, SignatoryPartnerContact__c, Account__r.business_is_Consulting_Sales__c, Account__r.business_is_Product_Sales__c, Account__r.business_is_Services_Sales__c, Account__r.Parent_Company__c, Account__r.Are_you_an_authorized_partner_of__c, 
                Account__r.BillingCity, Account__r.BillingCountry, Account__r.BillingPostalCode, Account__r.BillingState, Account__r.BillingStreet, Account__r.Name, Account__r.Distributor_of_Choice__c, Account__r.Email_Domain_Used__c, Account__r.Integrate_cloudsolutions_with_vendors__c,
                Account__r.Marketting_Oferrings__c, Account__r.Number_of_employees_in_your_organization__c, Account__r.Own_brand_of_professional_services__c, Account__r.Phone, Account__r.Primary_target_market_size__c, Account__r.Professionals_in_your_org_Inside_Sales__c,
                Account__r.Number_of_sales_professionals_in_org__c, Account__r.Professionals_in_org__c, Account__r.Provide_technical_support__c, Account__r.Region__c, Account__r.Silver_Peak_oppo_pend__c, Account__r.Tax_ID_Number__c, 
                Account__r.TOP_3_industries__c, Account__r.total_annual_sales_revenues_last_year__c, Account__r.Website, Account__r.Years_in_Business__c, Account__r.MarketingPartnerContact__c, Account__r.PrimaryPartnerContact__c, Account__r.Please_Name_the_Vendors__c,  
                Account__r.RegisteringUserContact__c, Account__r.SignatoryPartnerContact__c from Information_Card__c where Id =: cardId limit 1];
        if(!cards.isEmpty())
        {
            return cards[0];
        }
        return null;
    }
}