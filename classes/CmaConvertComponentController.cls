/*
* Controller for CmaConvertComponent
*/
public class CmaConvertComponentController
{
    public List<CmaInfo> Cmas
    {
        get
        {
            Cmas = new List<CmaInfo>();
            if(CmaRecordId != null)
            {
                CmaInfo info = new CmaInfo();
                List<RMA_Item__c> rmaItems = [select Id, Asset__c, Asset__r.Model__c, Asset__r.SerialNumber, Asset__r.Contract_Type__c,
                                                Asset__r.Contract_End__c from RMA_Item__c where RMA__c = :CmaRecordId order by Asset__r.Model__c];
                for(RMA_Item__c item : rmaItems)
                {
                    String model = item.Asset__r.Model__c;
                    model = (model == null) ? '' : model;
                    if(model.contains('NX')|| model.contains('GMS-10') ) //no contract on NX
                    {
                        info.NxModel = item.Asset__r.Model__c;
                        info.NxSerialNumber = item.Asset__r.SerialNumber;
                    }
                    if(model.contains('VX')|| model.contains('GX-V'))
                    {
                        info.VxModel = item.Asset__r.Model__c;
                        info.VxSerialNumber = item.Asset__r.SerialNumber;
                        info.ContractType = item.Asset__r.Contract_Type__c;
                        info.ContractEndDate = item.Asset__r.Contract_End__c;
                    }
                }
                Cmas.add(info);
            }
            return Cmas;
        }
        set;
    }
    public String CmaRecordId { get; set; }

    public class CmaInfo
    {
        public String NxModel { get; set; }
        public String VxModel { get; set; }
        public String NxSerialNumber { get; set; }
        public String VxSerialNumber { get; set; }
        public String ContractType { get; set; }
        public Date ContractEndDate { get; set; }
    }
}