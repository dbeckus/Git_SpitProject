trigger AssignGEOFromContactOwner on Contact (before insert,before update) {
    
    for(Contact con: Trigger.New)
    {
        if(con.OwnerId!=null)
        {
            if(trigger.IsInsert)  
            {
                con.GEO__c=   AssignGEO(con.OwnerId);
            }
            if(trigger.IsUpdate)  
            {
                Contact oldCon= Trigger.OldMap.get(con.Id);
                if(oldCon.OwnerId!=con.OwnerId)
                {
                    con.GEO__c=AssignGEO(con.OwnerId);
                }
            }
        }
    }
    
    private static string AssignGEO(Id ownerId)
    {
        List<User> lstUser=[Select GEO_Region__c from User where Id=:ownerId];
        if(lstUser!=null && lstUser.size()>0)
        {
            return lstUser[0].GEO_Region__c;
        }
        return '';
    }
}