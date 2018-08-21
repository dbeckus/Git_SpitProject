public class DataTestController {

    public integer count =0;
    
    public PageReference SetCounter()
    {
        count++;
        
        return null;
        
    }
    
    public integer getCount()
    {
        return count;
    }
}