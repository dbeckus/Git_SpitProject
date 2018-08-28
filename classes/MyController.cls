public class MyController {
    public string FirstName{get;set;}
    
    public String GetName1()
    {
        if(FirstName==null)
        {
             FirstName='Praj';
        	 return FirstName;
        }
        else
        {
             return '1';
        }
       
           
    }
     public String GetName2()
    {
        if(FirstName==null)
        {
             FirstName='Kappu';
        	 return FirstName;
        }
        else
        {
             return '2';
        }
       
           
    }
      public String GetName3()
    {
        if(FirstName==null)
        {
             FirstName='Arjun';
        	 return FirstName;
        }
        else
        {
             return '3';
        }
       
           
    }
}