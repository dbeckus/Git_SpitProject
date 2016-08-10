global class PartnerPortalSyncCertSchedule implements Schedulable {
	global void execute(SchedulableContext sc) {
		Set<String> courseNames = new Set<String>{'SCTP Exam (Partners)', 'SPX Exam for SP SEs', 'Silver Peak Certified Sales Partner (SCSP) Test'};
		String token = PartnerPortalSSOStub.getToken();
		PartnerPortalGetCoursesApi coursesApi = new PartnerPortalGetCoursesApi(token);
		coursesApi.execute();
		for (PartnerPortalQueryResult course : coursesApi.courses)
		{
			if(courseNames.contains(course.Value))
			{
				PartnerPortalGetCertificatesApi certificatesApi = new PartnerPortalGetCertificatesApi(String.valueOf(course.Id), token,null);
				certificatesApi.execute();
				PartnerPortalBatchGetCertificates batchjob = new PartnerPortalBatchGetCertificates(certificatesApi.Certificates);
				database.executebatch(batchjob);
				//System.debug(certificatesApi.Certificates);
			}
		}
		//MyBatchClass b = new MyBatchClass();
		//database.executebatch(b);
	}
}