global class ShareMDFToPartnerBatch implements Database.Batchable<sObject>
{
    String query = null;
    
    global ShareMDFToPartnerBatch(String queryStr)
    {
        this.query = queryStr;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        return Database.getQueryLocator(query);
    }
    
    global void execute (Database.BatchableContext bc, List<sObject> scope)
    {
        List<MDF_Request__c> mdfs = new List<MDF_Request__c>();
        for(sObject obj : scope)
        {
            MDF_Request__c mdf = (MDF_Request__c)obj; 
            mdfs.add(mdf);
        }
        ShareMDFToPartnerHelper.shareMDFs(mdfs);
    }
    
    global void finish(Database.BatchableContext bc){}
}