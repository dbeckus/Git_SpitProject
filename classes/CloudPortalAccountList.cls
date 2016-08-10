public class CloudPortalAccountList {
    public CloudPortalAccountList() 
    {
        accounts= new List<CPAccount>();
    }
    public List<CPAccount> accounts{get;set;} 
    public class CPAccount
    {
        public CPAccount() 
        {
        }
        public string Id {get; set;}
        public string salesforceId {get; set;}
        public string name {get; set;}
        public string accountKey {get; set;}
    }   
    
}