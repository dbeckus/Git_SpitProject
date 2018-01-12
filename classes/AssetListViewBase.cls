public virtual class AssetListViewBase {
    public  List<AccountInfo> AccountKeyList{get;set;}
    public  Boolean IsPartnerManager{get;set;}
    public  Boolean IsPartnerUser{get;set;}
    public  Id PartnerAccountId{get;set;}
    public AssetListViewBase()
    {
        List<User> lstUser=  [Select Id , Name,UserRole.Name, ProfileId,UserType,Contact.Account.Name,Contact.AccountId from User where Id=:UserInfo.getUserId()];
        if(lstUser[0].UserRole.Name.contains('Partner Manager'))
        {
            IsPartnerManager=true;
        }
        if(lstUser[0].UserRole.Name.contains('Partner User'))
        {
            IsPartnerUser=true;
        }
        if(lstUser[0].Contact.AccountId!=null)
        {
            PartnerAccountId=lstUser[0].Contact.AccountId;
        }
        if(lstUser!=null && lstUser.size()>0)
        {
            AccountKeyList = new List<AccountInfo>();
            List<Account> lstAccount=null;
            
            lstAccount=[Select Id,Name,Cloud_Portal_Account_Key__c,Cloud_Portal_Account_Name__c from Account where Id=:lstUser[0].Contact.AccountId ];
            
            if(lstAccount!=null && lstAccount.size()>0)
            {
                for(Account acc: lstAccount)
                {
                    AccountInfo acctInfo=new AccountInfo();
                    acctInfo.AccountKey=acc.Cloud_Portal_Account_Key__c;
                    acctInfo.ProductName='EC';
                    acctInfo.AccountName=string.isBlank(acc.Cloud_Portal_Account_Name__c)?acc.Name:acc.Cloud_Portal_Account_Name__c;
                    AccountKeyList.add(acctInfo);
                }
                
            }
        }
    }
    
    
    public class AccountInfo
    {
        public string AccountName {get;set;}
        public string ProductName {get;set;}
        public string AccountKey {get;set;}
        public AccountInfo()
        {
            
        }
        public AccountInfo(string name,string key,string prodName)
        {
            this.AccountName=name;
            this.AccountKey=key;
            this.ProductName=prodName;
        }
    }
}