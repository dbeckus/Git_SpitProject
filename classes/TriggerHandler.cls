/**
 * The default trigger handler implement ITrigger interface.
 *
 * @author  Matt Yuan
 * @created 4/20/2015
 * @version 1.0
 * @since   33.0
 *
 * @changelog
 * 4/20/2015 Matt Yuan - Created.
 */

public virtual class TriggerHandler implements ITrigger 
{
    public void execute()
    {
        if(Trigger.isBefore)
        {
            if(Trigger.isInsert)
            {
                this.beforeInsert();
            }
            else if(Trigger.isUpdate)
            {
                this.beforeUpdate();
            }
            else if(Trigger.isDelete) 
            {
                this.beforeDelete();
            }
        }
        else
        {
            if(Trigger.isInsert)
            {
                this.afterInsert();
            }
            else if(Trigger.isUpdate)
            {
                this.afterUpdate();
            }
            else if(Trigger.isDelete)
            {
                this.afterDelete();
            }
            else if(Trigger.isUndelete)
            {
                this.afterUndelete();
            }
        }
    }
    
    public virtual void beforeInsert() 
    { 
    
    }

    public virtual void beforeUpdate() 
    { 
    
    }

    public virtual void beforeDelete() 
    { 
    
    }

    public virtual void afterInsert() 
    { 
    
    }

    public virtual void afterUpdate() 
    { 
    
    }

    public virtual void afterDelete() 
    { 
    
    }

    public virtual void afterUndelete() 
    { 
    
    }
}