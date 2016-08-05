/*
 * Posts chatter message after a new virtual asset created
 */
trigger PostChatterMessageOnNewAsset on Asset (after insert) 
{
    /*Map<Id, List<Asset>> requestToAssets = new Map<Id, List<Asset>>();
    List<Asset> assets = [select Id, Name, CreatedDate, Product2.Model__c, Product2.ProductCode, SerialNumber, POCRequest__c, POCRequest__r.Name, PocRequest__r.Opportunity__c, POCRequest__r.Opportunity__r.Owner.Name, POCRequest__r.Opportunity__r.Technical_Responsible__r.Name, POCRequest__r.Opportunity__r.Account.Owner.Name from Asset where Id in :Trigger.new order by CreatedDate];
    for(Asset asset : assets)
    {
        if(asset.POCRequest__c != null)
        {
            if(requestToAssets.containsKey(asset.POCRequest__c))
            {
                requestToAssets.get(asset.POCRequest__c).add(asset);
            }
            else            
            {
                List<Asset> asets = new List<Asset>();
                asets.add(asset);
                requestToAssets.put(asset.POCRequest__c, asets);
            }
        }
    }    
    ChatterHelper.MessageInfo message = new ChatterHelper.MessageInfo();
    for(Id requestId : requestToAssets.keySet())
    {
        ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
        ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
        messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
        
        List<Asset> currentAssets = requestToAssets.get(requestId);
        Asset asset = currentAssets[0];
        String bodyText = '';
        if(asset.POCRequest__c != null && asset.PocRequest__r.Opportunity__c != null)
        {
            if(asset.POCRequest__r.Opportunity__r.OwnerId != null)
            {
                ConnectApi.MentionSegmentInput mention = new ConnectApi.MentionSegmentInput();
                mention.id = asset.POCRequest__r.Opportunity__r.OwnerId;
                messageBodyInput.messageSegments.add(mention);
            }
            if(asset.POCRequest__r.Opportunity__r.Technical_Responsible__c != null)
            {
                ConnectApi.MentionSegmentInput mention = new ConnectApi.MentionSegmentInput();
                mention.id = asset.POCRequest__r.Opportunity__r.Technical_Responsible__c;
                messageBodyInput.messageSegments.add(mention);
            }
            if(asset.POCRequest__r.Opportunity__r.Account.OwnerId != null)
            {
                ConnectApi.MentionSegmentInput mention = new ConnectApi.MentionSegmentInput();
                mention.id = asset.POCRequest__r.Opportunity__r.Account.OwnerId;
                messageBodyInput.messageSegments.add(mention);
            }
            bodyText = ' New asset(s) were created for POC: '+ asset.POCRequest__r.name;
        }
        for(Asset at : currentAssets)
        {
            bodyText += '\r\n Serial Number: ' + at.SerialNumber + ', Model: ' + at.Product2.Model__c;
        }
        ConnectApi.TextSegmentInput textSegment = new ConnectApi.TextSegmentInput();
        textSegment.text = bodyText;
        messageBodyInput.messageSegments.add(textSegment);
        
        feedItemInput.body = messageBodyInput;
        feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
        feedItemInput.subjectId = requestId;
        try
        {
            ConnectApi.ChatterFeeds.postFeedElement(null, feedItemInput, null);
        }
        catch(Exception ex) {}
    }*/
}