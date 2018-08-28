public class TestInvocationQueryAction {
    
    @InvocableMethod(Label='Test label' description='Test desc')
    public static List<Accountwrapper> TestData()
    {
        List<AccountWrapper> lstAccountWrapper= new List<AccountWrapper>();
        List<Account> lstAccount = [Select Id,Name from Account Limit 10];
        if(lstaccount!=null && lstAccount.size()>0)
        for(Account acc: lstAccount)
        {
            lstAccountWrapper.add(new accountwrapper(acc.Name));
        }
        
        return lstAccountWrapper;
    }
    
    
    public class accountWrapper
    {
        @InvocableVariable
        public string Name;
        public accountwrapper()
        {
            
        }
         public accountwrapper(string accName)
        {
            Name=accName;
        }
    }

}