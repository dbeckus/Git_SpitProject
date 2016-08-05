@isTest
private class PartnerPortalAbsorbWebServiceTest 
{	
	@isTest static void testPartnerPortalAbsorbWebServiceTest() 
	{
		// Implement test code
		Test.setMock(WebServiceMock.class, new PartnerPortalWebServiceMock());
		webservicesAbsorbtrainingCom.Main2Soap absorbSoap = new webservicesAbsorbtrainingCom.Main2Soap();
		absorbSoap.Authenticate('SSOID', 'passwordHash', 'SSOKey', 'Location', 'Method');
		absorbSoap.GetDepartments('sUsername', 'sPassword');
		absorbSoap.UpdateUserExtraFields('sUIDField', 'sUIDValue', 'sUpdateField', 'sUpdateValue', 'sUsername', 'sPassword', 'sMD5');
		absorbSoap.UpdateUserStatus('sUIDField','sUIDValue', 1,'sUsername','sPassword', 'sMD5');
		absorbSoap.UpdateProfile('sUIDField','sUIDValue','sUpdateField','sUpdateValue','sUsername','sPassword','sMD5');
		absorbSoap.GetStudentMetaInformation('sUIDField','sUIDValue','sUsername','sPassword','sMD5');
		absorbSoap.DoAdminLoginMethod('SSOID','SSOKey','Method');
		absorbSoap.DoStudentLoginMethod('SSOID','SSOKey','Location','Method');
		absorbSoap.DoLogin('SSOID','SSOKey');
		absorbSoap.DoLoginMethod('SSOID','SSOKey','Method');
		absorbSoap.DoStudentLogin('SSOID','SSOKey','Location');
		absorbSoap.DoAdminLogin('SSOID','SSOKey');
		absorbSoap.HashValue('value');
		absorbSoap.ReturnTimeZoneInfo();
		absorbSoap.UpdateUserDepartment('sUIDField','sUIDValue','sDepartmentID','sUsername','sPassword','sMD5');
	}
}