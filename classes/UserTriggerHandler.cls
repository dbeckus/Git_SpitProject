public class UserTriggerHandler implements ITriggerHandler {
  public UserTriggerHandler()
    {
        
    }
    public Boolean IsDisabled()
    {
        return false;
    }
    public void BeforeInsert(List<SObject> newItems) 
    {
        if(newItems!=null && newItems.size()>0)
        {
            
            for(User newUser :(List<User>)newItems)
            {
                
            }
        }
        
    }
    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) 
    {
        if(newItems!=null && newItems.size()>0)
        {
            
            for (Id userId : newItems.keyset())
            {
                
                    
                
            }
            
        }
    }
    public void BeforeDelete(Map<Id,SObject> oldItems) 
    {
        boolean isSynced=false;
        if(oldItems.size()>0)
        {
            for(Id userId:oldItems.keySet())
            {
                User oldAccinfo= (User)oldItems.get(userId);
               
            }
        }
    }
    public void AfterInsert(Map<Id, SObject> newItems) 
    {
        
        if(newItems!=null && newItems.size()>0)
        {
            for (Id userId : newItems.keyset())
            {
               
            }
            
        }
    }
    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) 
    {
        
        if(newItems!=null && newItems.size()>0)
        {
            
            for (Id userId : newItems.keyset())
            {
                User newAccInfo= (User)newItems.get(userId);
                User oldAccInfo= (User)oldItems.get(userId);               
                
            }
        }
    }
    public void AfterDelete(Map<Id, SObject> oldItems) 
    {
        
    }
    public void AfterUndelete(Map<Id, SObject> newItems) 
    {
        
    }
}