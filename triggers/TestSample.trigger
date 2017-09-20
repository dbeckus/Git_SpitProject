trigger TestSample on Sample_Data__c (before insert,before update,after insert,after update) {
If(Trigger.IsBefore)
    {
        If(Trigger.IsInsert)
        {
            System.debug('Before Insert');
        }
        If(Trigger.IsUpdate)
        {
            System.debug('Before Update');
        }
    }
    If(Trigger.IsAfter)
    {
        If(Trigger.IsInsert)
        { 
            System.debug('After Insert');
            /*for(Sample_Data__c obj:Trigger.New)
            {
                Sample_Data__c newData= new Sample_Data__c(Id=obj.Id);
                newData.Sample1__c='Kalpesh';
                update newData;
            }*/
           
        }
        If(Trigger.IsUpdate)
        {
            System.debug('After Update');
            
        }
    }
}