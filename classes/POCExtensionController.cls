public class POCExtensionController {
    
    public Request__c POCRequest{get;set;}
    
    public POCExtensionController(ApexPages.StandardController controller)
    {
        Id pocId=controller.getId();
        POCRequest= new Request__c();
        POCRequest=[Select Id,Status__c, Target_End_Date__c, POC_Type__c,Requested_End_Date__c,Extension_Justification__c from Request__c where Id=:pocId];
        System.debug(pocId);
        
        if(POCRequest.Status__c=='Pending Return')
        {
            POCRequest.Requested_End_Date__c=Date.today().addDays(10);
        }
        else
        {
            if(POCRequest.Target_End_Date__c!=null)
            {
                POCRequest.Requested_End_Date__c=POCRequest.Target_End_Date__c.addDays(10);
            }
            
        }
        
    }
    public PageReference SaveExtension()
    {
        boolean isValid=true;
        // Validate the extension request 
        
        if(POCRequest.Requested_End_Date__c==null )
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please enter Extend To Date.'));
            isValid=false;
        }
        if(String.isblank(POCRequest.Extension_Justification__c) )
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please enter the reason for POC Extension.'));
            isValid=false;
        }
        if(!isValid)
        {
            return null;
        }
        try
        {
            update pocRequest;
            // Call the approval process
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setComments('Extension request for approval.');
            req1.setObjectId(pocRequest.id);
            // Submit the approval request for the account
            Approval.ProcessResult result = Approval.process(req1);
        }
        catch(Exception ex)
        {
            ApexPages.addMessages(ex);
            return null;
        }
        // save the extension request 
        
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Succeeded.<script type="text/javascript">opener.location="/'+pocRequest.Id+'";setTimeout("window.close()", 3000)</script>'));
        return null;
    }
}