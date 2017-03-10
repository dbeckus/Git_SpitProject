public class CloudPortalPostAssetsApi extends CloudPortalApiBase {
    public string token; 
    public string cloudPortalId;
    public List<CPAsset> ecAssets;
    public List<CPAsset> saasAssets;
    public List<CPAsset> cpxAssets;
    public List<CPAsset> spAssets;
    private string cloudPortalAccId;
    
    public CloudPortalPostAssetsApi(string cloudPortalAccId)
    {
        this.cloudPortalAccId=cloudPortalAccId;
    }
    public override String generateEndPoint()
    {
        return BaseEndpoint + '/salesforce/account/'+cloudPortalAccId+'/assets';
    }
    
    public override HttpRequest setHeaders(HttpRequest request)
    {
        request.setMethod('POST');
        request.setHeader('charset', ContentCharset);
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Cookie', token);
        return request;
    }
    
    public override HttpRequest setBody(HttpRequest request)
    {
        System.debug('setbody');
        System.debug('setbody'+ecAssets);
        System.debug('setbody'+saasAssets);
        JSONGenerator generator = JSON.createGenerator(true);
        generator.writeStartObject();
        generator.writeFieldName('ec');
        generator.writeStartArray();
        if(ecAssets!=null && ecAssets.size()>0)
        {
            
            for(CPAsset item:ecAssets)
            {
                generator.writeStartObject();   
                generator.writeObjectField('expire',item.ExpiryDate);
                generator.writeObjectField('base',item.BaseNode);
                generator.writeObjectField('plus',item.PlusNode);
                generator.writeObjectField('boost',item.BoostNode);
                generator.writeEndObject();
            }
            
        }
        generator.writeEndArray();
        generator.writeFieldName('saas');
        generator.writeStartArray();
        if(saasAssets!=null && saasAssets.size()>0)
        {
            for(CPAsset item:saasAssets)
            {
                generator.writeStartObject();   
                generator.writeObjectField('expire',item.ExpiryDate);
                generator.writeEndObject();
            }
            
        }
        generator.writeEndArray(); 
        generator.writeFieldName('cpx');
        generator.writeStartArray();
        if(cpxAssets!=null && cpxAssets.size()>0)
        {
            for(CPAsset item:cpxAssets)
            {
                generator.writeStartObject();   
                generator.writeObjectField('expire',item.ExpiryDate);
                generator.writeEndObject();
            }
            
        }
        generator.writeEndArray(); 
        generator.writeFieldName('ecsp');
        generator.writeStartArray();
        if(spAssets!=null && spAssets.size()>0)
        {
            for(CPAsset item:spAssets)
            {
                generator.writeStartObject();
                if(item.startDate!=null)
                {
                    generator.writeObjectField('startDate',item.startDate);
                }
                else
                {
                    generator.writeObjectField('startDate','');
                }
                if(item.endDate!=null)
                {
                    generator.writeObjectField('endDate',item.endDate);
                }
                else
                {
                    generator.writeObjectField('endDate','');
                }
                generator.writeObjectField('salesforceId',item.salesforceId);
                generator.writeObjectField('id',item.id);
                generator.writeObjectField('name',item.name);
                generator.writeObjectField('quantity',item.quantity);
                generator.writeEndObject();
            }
            
        }
        generator.writeEndArray(); 
        generator.writeEndObject();
        String parameters = generator.getAsString();
        System.debug(parameters);
        request.setBody(parameters);
        return request;
    }
    
    public override void processResult(String response)
    {
        System.debug(response);
        
    }
}