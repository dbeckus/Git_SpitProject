@RestResource(urlMapping='/CPFileInfo/*')
global with sharing class CloudPortalS3FileRestAPI {
    
    @HttpPost
    global static string UploadFilesToCase(List<FileInfo> fileInfo)
    {
        RestRequest req = RestContext.request;
        RestResponse res=RestContext.response;
        List<Ensemblestorage__EnsembleFile__c> lstFilesToInsert= new List<Ensemblestorage__EnsembleFile__c>();
        
        
        if(fileInfo!=null && fileInfo.size()>0)
        {
            try
            {
                //Retreive Case Id from case Number
                SetCaseIdsfromCaseNumber(fileInfo);
                for(FileInfo item: fileInfo)
                {     
                    if(string.isEmpty(item.sfCaseRecordId))
                    {
                        throw new CustomException('There is no case record with this input '+item.sfCaseId );
                        break;
                    }
                    
                    Ensemblestorage__EnsembleFile__c filedetail= new Ensemblestorage__EnsembleFile__c();
                    filedetail.Ensemblestorage__Case__c= item.sfCaseRecordId;
                    filedetail.Name= item.fileName;
                    filedetail.Ensemblestorage__S3Key__c= item.fileKey;
                    filedetail.Ensemblestorage__Size__c= item.fileSize;
                    filedetail.Ensemblestorage__S3Bucket__c='silverpeaksystemsstorage';
                    lstFilesToInsert.add(filedetail);
                    
                }
                
                if(lstFilesToInsert.size()>0)
                {
                    insert lstFilesToInsert;
                    return 'Files are created successfully.';
                }
            }
            catch(Exception ex)
            {
                insert new ErrorLog__c(Subject__c='Error in CPFileInfo API', Message__c=ex.getMessage() + '\r\n' + ex.getStackTraceString());
                res.responseBody = Blob.valueOf(String.valueOf(ex) + '\n\n' + ex.getStackTraceString());
                res.statusCode=400;
                
            }
            
        }
        return 'No files uploaded.';
    }
    
    private static void SetCaseIdsfromCaseNumber(List<FileInfo> lstFileRec)
    {
        Map<String,Id> mapCaseNumber= new Map<String,Id>();
        for(FileInfo item: lstFileRec)
        {
            if(item.sfCaseId!=null)
            {
                if(item.sfCaseId.startsWith('500'))// Case Id
                    item.sfCaseRecordId=item.sfCaseId;
                else if(!mapCasenumber.containsKey(item.sfCaseId)) // Case Number
                    mapCasenumber.put(item.sfCaseId,null);
            }
            
        } 
        if(mapCaseNumber.size()>0)
        {
            List<Case> lstCases= [Select Id,casenumber from case where casenumber in:mapCasenumber.keySet()];
            for(Case caseRec:lstCases)
            {
                if(mapCasenumber.containsKey(caseRec.casenumber))
                {
                    mapCaseNumber.put(caseRec.casenumber,caseRec.Id);
                }
            }
            for(FileInfo item: lstFileRec)
            {
                if(string.isBlank(item.sfCaseRecordId))
                {
                    item.sfCaseRecordId=mapCaseNumber.get(item.sfCaseId);
                }
            }
        }
    }
    
    global class FileInfo
    {
        global string sfCaseId{get;set;}
        private string sfCaseRecordId{get;set;}
        global string fileName{get;set;}
        global string fileKey{get;set;}
        global decimal fileSize{get;set;}    
        
    }
    
    
    
}