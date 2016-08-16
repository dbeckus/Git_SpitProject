trigger CheckValidProductsAddedOnECPOCFlag on Request__c (before update) {
    
    Map<Id,String> requestIds= new Map<Id,String>();
    
    for(Request__c item : Trigger.New)
    {
        if(item.POC_Type__c!= trigger.oldMap.get(item.Id).POC_Type__c)
        {
            requestIds.put(item.Id,item.POC_Type__c);
        }
        
    }
    
    Set<string> ECProducts= new Set<string>();
    Set<string> NonECProducts= new Set<string>();
    
    for(Id recordId: requestIds.keyset())
    {
        List<Request__c> requestData =[Select Id,POC_Type__c,VirtualProduct1__c,VirtualProduct2__c,VirtualProduct3__c,VirtualProduct4__c,VirtualProduct5__c,
                                       PhysicalProduct1__c,PhysicalProduct2__c,PhysicalProduct3__c,PhysicalProduct4__c,PhysicalProduct5__c,Opportunity__r.Account.Partner_Type__c,Opportunity__r.Account.ECSP__c from Request__c where Id=:recordId ];
        if(requestData!=null && requestData.size()>0 && requestData.size()==1)
        {
            Request__c currRequest=requestData[0];
            if(currRequest.VirtualProduct1__c!=null && currRequest.VirtualProduct1__c.startsWith('EC-') )
            { 
                ECProducts.add(currRequest.VirtualProduct1__c);
            }
            else if(currRequest.VirtualProduct1__c!=null && !currRequest.VirtualProduct1__c.startsWith('EC-') )
            {
                NonECProducts.add(currRequest.VirtualProduct1__c); 
            }
            if(currRequest.VirtualProduct2__c!=null && currRequest.VirtualProduct2__c.startsWith('EC-') )
            { 
                ECProducts.add(currRequest.VirtualProduct2__c);
            }
            else if(currRequest.VirtualProduct2__c!=null && !currRequest.VirtualProduct2__c.startsWith('EC-') )
            {
                NonECProducts.add(currRequest.VirtualProduct2__c); 
            }
            
            if(currRequest.VirtualProduct3__c!=null && currRequest.VirtualProduct3__c.startsWith('EC-') )
            { 
                ECProducts.add(currRequest.VirtualProduct3__c);
            }
            else if(currRequest.VirtualProduct3__c!=null && !currRequest.VirtualProduct3__c.startsWith('EC-') )
            {
                NonECProducts.add(currRequest.VirtualProduct3__c); 
            }
            
            if(currRequest.VirtualProduct4__c!=null && currRequest.VirtualProduct4__c.startsWith('EC-') )
            { 
                ECProducts.add(currRequest.VirtualProduct4__c);
            }
            else if(currRequest.VirtualProduct4__c!=null && !currRequest.VirtualProduct4__c.startsWith('EC-') )
            {
                NonECProducts.add(currRequest.VirtualProduct4__c); 
            }
            
            if(currRequest.VirtualProduct5__c!=null && currRequest.VirtualProduct5__c.startsWith('EC-') )
            { 
                ECProducts.add(currRequest.VirtualProduct5__c);
            }
            else if(currRequest.VirtualProduct5__c!=null && !currRequest.VirtualProduct5__c.startsWith('EC-') )
            {
                NonECProducts.add(currRequest.VirtualProduct5__c); 
            }
            
            // Add the Physical Products
            if(currRequest.PhysicalProduct1__c!=null && currRequest.PhysicalProduct1__c.startsWith('EC-') )
            { 
                ECProducts.add(currRequest.PhysicalProduct1__c);
            }
            else if(currRequest.PhysicalProduct1__c!=null && !currRequest.PhysicalProduct1__c.startsWith('EC-') )
            {
                NonECProducts.add(currRequest.PhysicalProduct1__c); 
            }
            if(currRequest.PhysicalProduct2__c!=null && currRequest.PhysicalProduct2__c.startsWith('EC-') )
            { 
                ECProducts.add(currRequest.PhysicalProduct2__c);
            }
            else if(currRequest.PhysicalProduct2__c!=null && !currRequest.PhysicalProduct2__c.startsWith('EC-') )
            {
                NonECProducts.add(currRequest.PhysicalProduct2__c); 
            }
            
            if(currRequest.PhysicalProduct3__c!=null && currRequest.PhysicalProduct3__c.startsWith('EC-') )
            { 
                ECProducts.add(currRequest.PhysicalProduct3__c);
            }
            else if(currRequest.PhysicalProduct3__c!=null && !currRequest.PhysicalProduct3__c.startsWith('EC-') )
            {
                NonECProducts.add(currRequest.PhysicalProduct3__c); 
            }
            
            if(currRequest.PhysicalProduct4__c!=null && currRequest.PhysicalProduct4__c.startsWith('EC-') )
            { 
                ECProducts.add(currRequest.PhysicalProduct4__c);
            }
            else if(currRequest.PhysicalProduct4__c!=null && !currRequest.PhysicalProduct4__c.startsWith('EC-') )
            {
                NonECProducts.add(currRequest.PhysicalProduct4__c); 
            }
            
            if(currRequest.PhysicalProduct5__c!=null && currRequest.PhysicalProduct5__c.startsWith('EC-') )
            { 
                ECProducts.add(currRequest.PhysicalProduct5__c);
            }
            else if(currRequest.PhysicalProduct5__c!=null && !currRequest.PhysicalProduct5__c.startsWith('EC-') )
            {
                NonECProducts.add(currRequest.PhysicalProduct5__c); 
            }
            
            if(currRequest.Opportunity__r.Account.Partner_Type__c=='Service Provider')
            {
                if(currRequest.Opportunity__r.Account.ECSP__c)  
                {
                    if(requestIds.get(recordId)=='WAN Op')
                    {
                        Trigger.New[0].POC_Type__c.addError('You cannot select this POC Type for this account. Please select Service Provider as POC Type.');
                    }
                    if(requestIds.get(recordId)=='Service Provider' && NonECProducts!=null && NonECProducts.size()>0 )
                    {
                        Trigger.New[0].POC_Type__c.addError('Service Provider and Enterprise assets cannot be mixed. Please create a new POC.');
                    }
                    
                }
                else if(!currRequest.Opportunity__r.Account.ECSP__c)
                {
                    if(requestIds.get(recordId)=='Service Provider')
                    {
                        Trigger.New[0].POC_Type__c.addError('You can only select Service Provider POC Type for Service Provider accounts.  Please check the ECSP box on the account / Please contact the Service Provider team to enable this account as a Service Provider.');
                    }
                    else if((requestIds.get(recordId)=='EdgeConnect' && NonECProducts!=null && NonECProducts.size()>0 ) || (requestIds.get(recordId)!='EdgeConnect' && ECProducts!=null && ECProducts.size()>0 )) 
                    {
                        Trigger.New[0].POC_Type__c.addError('EdgeConnect and Non-EdgeConnect products cannot be mixed.');
                    }
                }
                
            }
            else
            {
                if(requestIds.get(recordId)=='Service Provider')
                {  
                    Trigger.New[0].POC_Type__c.addError('You can only select Service Provider POC Type for Service Provider accounts.  Please check the ECSP box on the account / Please contact the Service Provider team to enable this account as a Service Provider.');
                }
                else if((requestIds.get(recordId)=='EdgeConnect' && NonECProducts!=null && NonECProducts.size()>0 ) || (requestIds.get(recordId)!='EdgeConnect' && ECProducts!=null && ECProducts.size()>0 )) 
                {
                    Trigger.New[0].POC_Type__c.addError('EdgeConnect and Non-EdgeConnect products cannot be mixed.');
                }
            }
            
            
            
        }
        
    }
    
}