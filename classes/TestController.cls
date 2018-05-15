public class TestController

{
    
    public String Var{get; set;}
    
    public PageReference checkNull()
        
    {
        
        if(Var !=null)
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.CONFIRM, 'Success!'));
        else
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Input value cannot be null.'));
        
        return null;
        
    }
    
}