@isTest
public class ValueGetterControllerTest
{
    @isTest
    static void test()
    {
        Account acc = new Account(Name='acme');
        insert acc;
        
        ValueGetterController controller = new ValueGetterController();
        controller.ObjectName = 'Account';
        controller.FieldName = 'Name';
        controller.FilterField = 'Name';
        controller.FilterValue = 'acme';
        System.assertEquals('acme', controller.value);
    }
}