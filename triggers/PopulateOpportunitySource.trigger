trigger PopulateOpportunitySource on Opportunity (after insert) {
    Map<Id,string> lstUsrProf= new Map<Id,string>();
    List<Opportunity>lstOpp= new List<Opportunity>();
    if(Trigger.IsAfter)
    {
        for(Opportunity opp:Trigger.New)
        {
            lstUsrProf.put(opp.CreatedById,'');
        }
        if(lstUsrProf.size()>0)
        {
            for (User[] users : [SELECT Id, Profile.Name FROM User WHERE Id IN :lstUsrProf.keySet()])
            {
                for (Integer i=0; i<users.size(); i++)
                {
                    lstUsrProf.put(users[i].Id, users[i].Profile.Name);
                }
            }
        }
        
        
        for(Opportunity opp:Trigger.New)
        {
            string oppSource=opp.Opportunity_Source__c;
            if(opp.Deal_Reg__c)
            {
                oppSource='PIO';
            }
            else if(!opp.Deal_Reg__c)
            {
                string profName= lstUsrProf.get(opp.CreatedById);
                
                if(profName.contains('Inside Sales'))
                {
                    oppSource='BDR-MQL';
                }
                else if(profName.contains('Regional Sales Manager') || profName.contains('1.4- Intl Regional Sales Manager')||profName.contains('1.6- Sales Engineer Team')||profName.contains('1.0- Sales Management'))
                {
                    oppSource='RSM';
                }            
            }
            lstOpp.add(new Opportunity(Id=opp.Id,Opportunity_Source__c=oppSource));
        }
        if(lstOpp.size()>0)
        {
            update lstOpp;
        }
    }
}