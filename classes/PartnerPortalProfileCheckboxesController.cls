public with sharing class PartnerPortalProfileCheckboxesController 
{
    public String objectToDisplay { get; set; }
    public String fieldToDisplay { get; set; }

    public List<String> items 
    {
        get
        {
            List<String> result = new List<String>();
            if(String.isNotBlank(fieldToDisplay) && String.isNotBlank(fieldToDisplay))
            {
                List<Schema.DescribeSObjectResult> fieldDescs = Schema.describeSObjects(new List<String> { objectToDisplay });
                
                for(Schema.PicklistEntry entry : fieldDescs[0].fields.getMap().get(fieldToDisplay).getDescribe().getPicklistValues())
                {
                    result.add(entry.getValue());
                }
            }
            return result;
        }
    }
}