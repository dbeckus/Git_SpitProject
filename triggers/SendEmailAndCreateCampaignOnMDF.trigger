/*
 * 1. Send Email Alert to User When the MDF Past Due 7 Days(Approval_Status = 'Approved' && MDF_Status__c = 'Past Due' And Activity_Complete__c = 'false' )
 * 2. create a campaign after MDF is approved
 *
 */
trigger SendEmailAndCreateCampaignOnMDF on MDF_Request__c (after Update)
{
    List<MDF_Request__c> emailMdf = new List<MDf_Request__c>();
    List<MDf_Request__c> updateMDF = new List<MDF_Request__c>();
    for(MDF_Request__c newMDf : Trigger.new)
    {
        for(MDF_Request__c oldMDF : Trigger.old)
        {
            if( newMDf.Approval_Status__c == 'Approved' && newMDF.SendReminder__c == true && newMDf.MDF_Status__c == 'Past Due')
            {
                if(newMDF.Id == oldMDF.Id)
                {
                    if(newMDF.SendReminder__c == true && oldMDF.SendReminder__c == false)
                    {
                        emailMdf.add(newMDf);
                    }
                }
            }
            if(newMDF.Id == oldMDF.Id)
            {
                if(oldMDF.Approval_Status__c != 'Approved' && newMDf.Approval_Status__c == 'Approved' && newMDF.Campaign__c == null)
                {
                    updateMDF.add(newMDF);
                }
            }
        }
    }
    if(!emailMdf.isEmpty())
    {
        List<MDF_Request__c> mdfs = [Select Id, Name, Owner.Name,Owner.FirstName, Owner.Email, Owner.Profile.Name, Contact__c, Contact__r.Name,Contact__r.FirstName, Contact__r.Email from MDF_Request__c where Id in: emailMdf];
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        List<EmailTemplate> et = [Select Id, Name, Body, HtmlValue,Subject from EmailTemplate where DeveloperName like '%New_MDF_Approved_Post_Event%' limit 1];
        List<OrgWideEmailAddress> orgWideEmail = [Select Id from OrgWideEmailAddress where DisplayName = 'Silver Peak Channel Team' LIMIT 1];
        List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
        for(Attachment attach : [select Id, Name, Body from Attachment where parentId = :et[0].Id])
        {
            Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
            efa.setFileName(attach.Name);
            efa.setBody(attach.Body);
            fileAttachments.add(efa);
        }
         
        if(!et.isEmpty())
        {
            String url;
            for(MDF_Request__c mdf : mdfs )
            {
                url = SendMdfUrlToClientController.encryptParameter(mdf.Id);
                String recipient = mdf.Owner.Profile.Name == '13g-SP Partner Community' ? mdf.Owner.Email : mdf.Contact__r.Email;
                mail.setToAddresses(new String[] {recipient});
                //mail.setSenderDisplayName('The Silver Peak Team');
                mail.setOrgWideEmailAddressId(orgWideEmail[0].Id);
                mail.setSubject(mergeEmail(et[0].Subject, mdf, url));
                mail.setPlainTextBody(mergeEmail(et[0].Body, mdf, url));
                mail.setBccSender(false);
                mail.setUseSignature(false);

                if(!fileAttachments.IsEmpty())
                {
                    mail.setFileAttachments(fileAttachments);
                }
                mails.add(mail);
            }
            Messaging.sendEmail(mails);
        }
    }
    if(!updateMDF.isEmpty())
    {
        List<MDF_Request__c> mdfs = [Select Id, Campaign__c, Activity_Date__c, Event_Campaign_Name__c, Event_Location_City__c, Type_of_Program__c, GEO__c, Account__r.Name  from MDF_Request__c where Id in: updateMDF];
        Map<MDF_Request__c,Campaign> mdfAndCampaign = new Map<MDF_Request__c, Campaign>();
        for(MDF_Request__c mdf : mdfs)
        {
            MDFAndCampaign.put(mdf, new Campaign(Name = getCampaignName(mdf)));
        }
        try
        {
            insert mdfAndCampaign.values();
            for(MDF_Request__c mdf : mdfAndCampaign.keySet())
            {
                mdf.Campaign__c = mdfAndCampaign.get(mdf).Id;
            }
            upsert new List<MDF_Request__c>(MDFAndCampaign.keySet());
        }
        catch(Exception ex)
        {
            SilverPeakUtils.logException(ex);
        }
    }
    
    private String mergeEmail(String originalValue, MDF_Request__c mdf, String encryptedLink)
    {
        String recipientName = mdf.Owner.Profile.Name == '13g-SP Partner Community' ? mdf.Owner.FirstName : mdf.Contact__r.FirstName;
        return originalValue.replace('{!MDF_Request__c.Owner.Name}', recipientName).replace('{!MDF_Request__c.OwnerFirstName}', recipientName).replace('{!MDF_Request__c.Link}','https://partners.silver-peak.com/s/MarketingFundsAnonymous?id=' + encryptedLink).replace('{!MDF_Request__c.Name}', mdf.Name);
    }
    
    private String getCampaignName(MDF_Request__c mdf)
    {
        if(mdf != null)
        {
            String fyfq = getQuarter(mdf.Activity_Date__c);
            String geo = mdf.GEO__c == 'NAM' ? 'AMER' : mdf.GEO__c;
            String activityDate = (mdf.Activity_Date__c == null) ? '' : ((mdf.Activity_Date__c.month() < 10 ? '0' + mdf.Activity_Date__c.month() : '' + mdf.Activity_Date__c.month()) + '' + (mdf.Activity_Date__c.day() < 10 ? '0' + mdf.Activity_Date__c.day() : '' + mdf.Activity_Date__c.day()) + '' + (String.valueOf(mdf.Activity_Date__c.year()).right(2)));
            String campaignName = truncateString(fyfq, 6) + '_' + truncateString(activityDate, 6) + '_' + truncateString(geo, 5) + '_' + truncateString(mdf.Type_Of_Program__c, 15) + '_' + truncateString(mdf.Event_Campaign_Name__c, 15) + '_' + truncateString(mdf.Account__r.Name, 15) + '_' + truncateString(mdf.Event_Location_City__c, 12);
            return campaignName.length() > 80 ? campaignName.substring(0, 80) : campaignName;
        }
        else
        {
            return null;
        }
    }
    
    private String truncateString(String value, Integer length)
    {
        if(value == null)
        {
            value = '';
        }
        if(value.length() > length)
        {
            value = value.replaceAll(' ', '');
            if(value.length() > length)
            {
                value = value.substring(0, length);
            }
        }
        return value;
    }
    
    private String getQuarter(Date d)
    {
        if(d != null)
        {
            Integer month = d.month();
            String FY = 'FY' + String.valueOf((month >= 8) ? d.year() + 1 : d.year()).subString(2,4);
            String FQ = 'Q' + (Integer)Math.ceil((month >= 8 ? month -7 : month + 5) /3.0);
            return FY + FQ;
        }
        else
        {
            return '';
        }
    }
}