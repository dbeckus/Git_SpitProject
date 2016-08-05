public class ValueGetterController
{
    public String ObjectName { get; set; }
    public String FieldName { get; set; }
    public String FilterField { get; set; }
    public String FilterValue { get; set; }
    
    public String Value
    {
        get
        {
            String soql = 'select ' + FieldName + ' from ' + ObjectName + ' where ' + FilterField + '=\'' + FilterValue + '\'';
            try
            {
                List<sObject> objs = Database.query(soql);
                if(objs.size() > 0)
                {
                    return (String)objs[0].get(FieldName);
                }
            }
            catch(Exception ex) {}
            return '';
        }
    }
}