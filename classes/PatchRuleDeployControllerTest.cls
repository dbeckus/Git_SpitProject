@isTest
public class PatchRuleDeployControllerTest
{
    @isTest
    static void test()
    {
        Patch__c patch1 = new Patch__c(Patch_Name__c='acme', Active__c=true, ProcessingSequence__c=1);
        insert patch1;
        PatchCriteriaRule__c rule1 = new PatchCriteriaRule__c(Patch__c=patch1.Id, Type__c='Country', Operation__c='equals', Value__c='US', ProcessingSequence__c=1);
        insert rule1;
        
        Test.startTest();
        MetadataServiceMockup mock = new MetadataServiceMockup();
        Test.setMock(WebServiceMock.class, mock);
        PatchRuleDeployController controller = new PatchRuleDeployController();
        String s1 = controller.getPackageXml();
        String s2 = controller.getClassMetadata();
        String s3 = controller.getClassBody();
        controller.ZipData = 'acme';
        controller.startDeploy();
        controller.deployZip();
        
        mock.setStatus('Canceling');
        controller.checkAsyncRequest();
        
        mock.setStatus('InProgress');
        controller.checkAsyncRequest();
        
        mock.setStatus('Succeeded');
        controller.checkAsyncRequest();
        
        mock.setStatus('Failed');
        controller.checkAsyncRequest();
        
        //mock.setStatus('Canceled');
        //controller.checkAsyncRequest();

        Test.stopTest();
    }
    
    public class MetadataServiceMockup implements WebServiceMock 
    {
        private String status;
        
        public void setStatus(String status)
        {
            this.status = status;    
        }
        
        public void doInvoke(Object stub, Object request, Map<String, Object> response, String endpoint, String soapAction, String requestName, String responseNS, String responseName, String responseType) 
        {
            if(requestName == 'deploy')
            {
                MetadataService.deployResponse_element responseElement = new MetadataService.deployResponse_element();
                responseElement.result = new MetadataService.AsyncResult();
                response.put('response_x', responseElement);
            }
            else if(requestName == 'checkStatus')
            {
                MetadataService.checkStatusResponse_element responseElement = new MetadataService.checkStatusResponse_element();
                MetadataService.AsyncResult result = new MetadataService.AsyncResult();
                result.done = true;
                result.state = 'Done';
                responseElement.result = new List<MetadataService.AsyncResult> { result };
                response.put('response_x', responseElement);
            }
            else if(requestName == 'checkDeployStatus')
            {
                MetadataService.checkDeployStatusResponse_element responseElement = new MetadataService.checkDeployStatusResponse_element();
                MetadataService.DeployResult result = new MetadataService.DeployResult();
                result.done = status == 'Succeeded' || status == 'Failed' || status == 'Canceled';
                result.status = status;
                result.success = (status == 'Succeeded');
                result.details = new MetadataService.DeployDetails();
                result.details.componentFailures = new List<MetadataService.DeployMessage>();
                responseElement.result = result;
                response.put('response_x', responseElement);
            }
        }
    }
}