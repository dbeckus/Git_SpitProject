public class Pagination
{
   CustomIterable obj;
    public list<CustomIterable.AccountInner> accInnerObj {get;set;}
    
    public Pagination () {       
        string sQuery = 'SELECT Name, website, AnnualRevenue, description, Type FROM account';
        obj = new CustomIterable(sQuery); 
        obj.setPageSize = 10;
        next();
    }
    public PageReference save()
    {
        for(CustomIterable.AccountInner item: accInnerObj)
        {
            if(item.isSelected)
            {
                System.debug(item.acc.Name);
            }
            
        }
        
        return null;
    }
    public Boolean hasNext {
        get {
            return obj.hasNext();
        }
        set;
    }
    
    public Boolean hasPrevious {
        get {
            return obj.hasPrevious();
        }
        set;
    }
    
    public void next() {
        accInnerObj = obj.next();
    }
    
    public void previous() {
        accInnerObj = obj.previous();
    }
}