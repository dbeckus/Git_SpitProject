/**
 * The interface of trigger handlers.
 *
 * @author  Matt Yuan
 * @created 4/20/2015
 * @version 1.0
 * @since   33.0
 *
 * @changelog
 * 4/20/2015 Matt Yuan - Created.
 */

public interface ITrigger 
{
    void beforeInsert();
    
    void beforeUpdate();

    void beforeDelete();

    void afterInsert();

    void afterUpdate();

    void afterDelete();

    void afterUndelete();
    
   
    
}