/*
 * Controller of page PurchaseRequest
 */
public with sharing class PurchaseRequestController 
{
    @testvisible
    private Purchasing_Request__c request;
    private List<Purchase_Request_Lines__c> Lines;
    
    public PurchaseRequestController(ApexPages.StandardController controller) 
    {
        try
        {
            controller.addFields(new String[] {'Send_PO_to_Vendor__c'});
        }
        catch(Exception ex) { /* prevent exception in test methods*/ }
        
        request = (Purchasing_Request__c)controller.getRecord();   
        request.Ship_To__c = 'Silver Peak Systems, Inc.\r\n' + 
                            '2860 De La Cruz Blvd, #100\r\n' + 
                            'Santa Clara, CA 95050';
        attach = new Attachment();
        sendToVendor = (request.Send_PO_to_Vendor__c == 'Yes');
    }
    
    public Boolean sendToVendor { get; set; }
    
    //uploaded attachments
    public Attachment attach {get; set;}
    public String[] FileNames 
    {
        get
        {
            List<String> files = new List<String>();
            for(Attachment att :  [select Name from Attachment where ParentId =:request.Id])
            {
                if(att.Name != null && att.Name != '')
                {
                    files.add(att.Name);
                }
            }
            return files;
        }
    }

    public PageReference init()
    {
        //remove the temporary PRs created before 6 hours
        Datetime dueDate = Datetime.Now().addHours(-6);
        try
        {
            delete [select Id,createdDate from Purchasing_Request__c where temporary__c = true and createdDate <= :dueDate];
        }
        catch(Exception ex)
        {}
        request.Requested_Date__c = System.today();
        request.Temporary__c = true;
        try
        {
            insert request;
        }
        catch(Exception ex)
        {
            ApexPages.addMessages(ex);
        }
        return null;
    }
    
    //initializes 3 new lines.
    public List<Purchase_Request_Lines__c> getLines()
    {
        if(Lines == null)
        {
            Lines = new List<Purchase_Request_Lines__c>();
            Lines.add(new Purchase_Request_Lines__c());
            Lines.add(new Purchase_Request_Lines__c());
            Lines.add(new Purchase_Request_Lines__c());
        }
        return Lines;
    }
    
    public PageReference saveFile()
    {
         if(attach.body != null)
        {
            attach.ParentId = request.Id;
            try
            {
                upsert attach;
                attach = new Attachment();
            }
            catch(Exception ex)
            {
                ApexPages.addMessages(ex);
            }
        }
        return null;
    }
    
    //saves the purchase request
    public PageReference save()
    { 
        try
        {
            request.temporary__c = false;
            request.Send_PO_to_Vendor__c = (sendToVendor) ? 'Yes' : 'No';
            upsert request;
        }
        catch(Exception ex)
        {
            ApexPages.addMessages(ex);
            return null;
        }
        String requestId = request.Id;
        List<Purchase_Request_Lines__c> newLines = new List<Purchase_Request_Lines__c>();
        for(Purchase_Request_Lines__c linetemp : Lines) 
        {
            if(linetemp.Qty__c != null)
            {
                linetemp.Purchasing_Request__c = requestId;
                newLines.add(linetemp);
            }
        }
        try
        {
            upsert newLines;
        }
        catch(Exception ex)
        {
            ApexPages.addMessages(ex);
            return null;
        }
        try
        {
            Approval.ProcessSubmitRequest request = new Approval.ProcessSubmitRequest();
            request.setComments('Submitting purchase request for approval.');
            request.setObjectId(requestId);
            
            Approval.ProcessResult result = Approval.process(request);
            System.assert(result.isSuccess());
        }
        catch(Exception ex)
        {
            ApexPages.addMessages(ex);
            return null;
        }
        PageReference pageRef = new PageReference('/apex/SubmitPurchasingRequestSuccess');
        pageRef.setRedirect(true);
        return pageRef;  
    }
    
    public PageReference removeLine()
    {
        String indexStr = ApexPages.currentPage().getParameters().get('index');
        if(indexStr != null && indexStr != '')
        {
            try
            {
                Integer index = Double.ValueOf(indexStr).intValue() ;
                Lines.remove(index);
            }
            catch(Exception ex)
            {
                ApexPages.addMessages(ex);
            }
        }
        return null;
    }
    
    public PageReference addLine()
    {    
        Lines.add(new Purchase_Request_Lines__c());
        return null;
    }

    public PageReference formReset() 
    {
        delete request;
        PageReference newpage = new PageReference(System.currentPageReference().getURL());
        newpage.getParameters().clear();
        newpage.setRedirect(true);
        return newpage;
    }
    
    public List<SelectOption> getApprovers()
    {
        return (new InnerHelper()).getApprovers();
    }
    
    public List<SelectOption> getVendorList()
    {
        List<SelectOption> result = new List<SelectOption>();
        result.add(new SelectOption('', 'Other:Complete New Vendor Info Below'));
        for(Vendor_List__c vndr : [select Id, Name from Vendor_List__c])
        {
            result.add(new SelectOption(vndr.Id, vndr.Name));
        }
        return result;
    }

    public without sharing class InnerHelper
    {
        public List<SelectOption> getApprovers()
        {
            List<SelectOption> result = new List<SelectOption>();
            result.add(new SelectOption('', '--'));
            for(User user : [select Id, Name from User where IsActive=true and PR_Approver__c=true])
            {
                result.add(new SelectOption(user.Id, user.Name));
            }
            return result;
        }
    }
    
}