global class PartnerPortalBatchGetCertificates implements Database.Batchable<PartnerPortalCertificate>, Database.AllowsCallouts 
{
	
	global final List<PartnerPortalCertificate> Certificates;

	global PartnerPortalBatchGetCertificates(List<PartnerPortalCertificate> certificates) 
	{
		this.Certificates = certificates;
	}
	
	global List<PartnerPortalCertificate> start(Database.BatchableContext BC) 
	{
		return Certificates;
	}

   	global void execute(Database.BatchableContext BC, List<PartnerPortalCertificate> scope) 
   	{
		system.debug(scope);
	}
	
	global void finish(Database.BatchableContext BC) 
	{
		
	}
	
}