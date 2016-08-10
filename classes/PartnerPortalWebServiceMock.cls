@isTest
public class PartnerPortalWebServiceMock implements WebServiceMock 
{
    public void doInvoke(
                          Object stub,
                          Object request,
                          Map<String, Object> response,
                          String endpoint,
                          String soapAction,
                          String requestName,
                          String responseNS,
                          String responseName,
                          String responseType) 
    {
        system.debug(request);
        system.debug(endpoint);
        if(requestName.indexOf('AuthenticateMethod') > -1)
        {
          webservicesAbsorbtrainingCom.AuthenticateMethodResponse_element respElement = new webservicesAbsorbtrainingCom.AuthenticateMethodResponse_element();
          respElement.AuthenticateMethodResult = 'x1x2x3x4x5';
          response.put('response_x', respElement); 
        }
        else if(requestName.indexOf('GetDepartments') > -1)
        {
          webservicesAbsorbtrainingCom.GetDepartmentsResponse_element respElement = new webservicesAbsorbtrainingCom.GetDepartmentsResponse_element();
          respElement.GetDepartmentsResult = 'x1x2x3x4x5';
          response.put('response_x', respElement); 
        }
        else if(requestName.indexOf('UpdateUserExtraFields') > -1)
        {
          webservicesAbsorbtrainingCom.UpdateUserExtraFieldsResponse_element respElement = new webservicesAbsorbtrainingCom.UpdateUserExtraFieldsResponse_element();
          respElement.UpdateUserExtraFieldsResult = 'x1x2x3x4x5';
          response.put('response_x', respElement); 
        }
        else if(requestName.indexOf('UpdateUserStatus') > -1)
        {
          webservicesAbsorbtrainingCom.UpdateUserStatusResponse_element respElement = new webservicesAbsorbtrainingCom.UpdateUserStatusResponse_element();
          respElement.UpdateUserStatusResult = 'x1x2x3x4x5';
          response.put('response_x', respElement); 
        }
        else if(requestName.indexOf('UpdateProfile') > -1)
        {
          webservicesAbsorbtrainingCom.UpdateProfileResponse_element respElement = new webservicesAbsorbtrainingCom.UpdateProfileResponse_element();
          respElement.UpdateProfileResult = 'x1x2x3x4x5';
          response.put('response_x', respElement); 
        }
        else if(requestName.indexOf('GetStudentMetaInformation') > -1)
        {
          webservicesAbsorbtrainingCom.GetStudentMetaInformationResponse_element respElement = new webservicesAbsorbtrainingCom.GetStudentMetaInformationResponse_element();
          respElement.GetStudentMetaInformationResult = 'x1x2x3x4x5';
          response.put('response_x', respElement); 
        }
        else if(requestName.indexOf('DoAdminLoginMethod') > -1)
        {
          webservicesAbsorbtrainingCom.DoAdminLoginMethodResponse_element respElement = new webservicesAbsorbtrainingCom.DoAdminLoginMethodResponse_element();
          respElement.DoAdminLoginMethodResult = 'x1x2x3x4x5';
          response.put('response_x', respElement); 
        }
        else if(requestName.indexOf('DoStudentLoginMethod') > -1)
        {
          webservicesAbsorbtrainingCom.DoStudentLoginMethodResponse_element respElement = new webservicesAbsorbtrainingCom.DoStudentLoginMethodResponse_element();
          respElement.DoStudentLoginMethodResult = 'x1x2x3x4x5';
          response.put('response_x', respElement); 
        }
        else if(requestName.indexOf('DoLoginMethod') > -1)
        {
          webservicesAbsorbtrainingCom.DoLoginMethodResponse_element respElement = new webservicesAbsorbtrainingCom.DoLoginMethodResponse_element();
          respElement.DoLoginMethodResult = 'x1x2x3x4x5';
          response.put('response_x', respElement); 
        }
        else if(requestName.indexOf('DoLogin') > -1)
        {
          webservicesAbsorbtrainingCom.DoLoginResponse_element respElement = new webservicesAbsorbtrainingCom.DoLoginResponse_element();
          respElement.DoLoginResult = 'x1x2x3x4x5';
          response.put('response_x', respElement); 
        }
        else if(requestName.indexOf('DoStudentLogin') > -1)
        {
          webservicesAbsorbtrainingCom.DoStudentLoginResponse_element respElement = new webservicesAbsorbtrainingCom.DoStudentLoginResponse_element();
          respElement.DoStudentLoginResult = 'x1x2x3x4x5';
          response.put('response_x', respElement); 
        }else if(requestName.indexOf('DoAdminLogin') > -1)
        {
          webservicesAbsorbtrainingCom.DoAdminLoginResponse_element respElement = new webservicesAbsorbtrainingCom.DoAdminLoginResponse_element();
          respElement.DoAdminLoginResult = 'x1x2x3x4x5';
          response.put('response_x', respElement); 
        }
        else if(requestName.indexOf('HashValue') > -1)
        {
          webservicesAbsorbtrainingCom.HashValueResponse_element respElement = new webservicesAbsorbtrainingCom.HashValueResponse_element();
          respElement.HashValueResult = 'x1x2x3x4x5';
          response.put('response_x', respElement); 
        }
        else if(requestName.indexOf('ReturnTimeZoneInfo') > -1)
        {
          webservicesAbsorbtrainingCom.ReturnTimeZoneInfoResponse_element respElement = new webservicesAbsorbtrainingCom.ReturnTimeZoneInfoResponse_element();
          respElement.ReturnTimeZoneInfoResult = new webservicesAbsorbtrainingCom.ArrayOfAbsorbTimeZone();
          response.put('response_x', respElement); 
        }
        else if(requestName.indexOf('UpdateUserDepartment') > -1)
        {
          webservicesAbsorbtrainingCom.UpdateUserDepartmentResponse_element respElement = new webservicesAbsorbtrainingCom.UpdateUserDepartmentResponse_element();
          respElement.UpdateUserDepartmentResult = 'x1x2x3x4x5';
          response.put('response_x', respElement); 
        }
    }
}