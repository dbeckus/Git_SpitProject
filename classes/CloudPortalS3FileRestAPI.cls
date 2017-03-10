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
            for(FileInfo item: fileInfo)
            {
                Ensemblestorage__EnsembleFile__c filedetail= new Ensemblestorage__EnsembleFile__c();
                filedetail.Ensemblestorage__Case__c= item.sfCaseId;
                filedetail.Ensemblestorage__FullName__c= item.fileName;
                filedetail.Ensemblestorage__S3Key__c= item.fileKey;
                filedetail.Ensemblestorage__Size__c= item.fileSize;
                filedetail.Ensemblestorage__S3Bucket__c='silverpeaksystemsstorage';
                lstFilesToInsert.add(filedetail);
                
            }
            try
            {
                if(lstFilesToInsert.size()>0)
                {
                    insert lstFilesToInsert;
                    return 'Files are created successfully.';
                }
            }
            catch(Exception ex)
            {
                res.responseBody = Blob.valueOf(String.valueOf(ex) + '\n\n' + ex.getStackTraceString());
                res.statusCode=400;
                System.debug(ex.getMessage());
                
            }
            
        }
        return 'No files uploaded.';
    }
    
    
    global class FileInfo
    {
        global string sfCaseId{get;set;}
        global string fileName{get;set;}
        global string fileKey{get;set;}
        global decimal fileSize{get;set;}    
        
    }
}