global class UpdateAssetsFromCSVFile implements Messaging.InboundEmailHandler
{
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) 
    {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        if(email != null)
        {
            if(email.binaryAttachments == null || email.binaryAttachments.size() == 0)
            {
                result.success = false;
                result.message = 'Please include the asset list as an attachment and send again.';
                return result;
            }
            SavePoint sp = Database.setSavepoint();
            try
            {
                Messaging.InboundEmail.BinaryAttachment binaryAtt = email.binaryAttachments.get(0);
                String csvFile = binaryAtt.Body.toString();
                List<Asset> updatedAssets = parseCSVFile(csvFile);
                update updatedAssets;
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setSubject('Silver Peak Customer Portal:Asset List successfully updated.');
                mail.setPlainTextBody('Your Asset List is updated successfully.\r\n\r\n');
                mail.setReplyTo('noreply@silver-peak.com');
                mail.setToAddresses(new String[] {email.fromAddress});
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                
            } catch (Exception ex) {
                result.success = false;
                result.message = '\nOne or more Asset ID cannot be found. Please make sure you didn\'t update asset IDs. \r\n' + ex.getMessage() + '\r\n' + ex.getStackTraceString();
                Database.rollback(sp);
                return result;
            }
        }
        result.success = true;
        return result;  
    }
    
    private List<Asset> parseCSVFile(String csvFile)
    {
        String [] rows = csvFile.split('\\n');
        rows = rows.size() == 1 ? csvFile.split('\\r') : rows;
        String [] headers = AssetUtilities.splitCsv(rows[0]);
        Map<String, String> fieldHeaderMap = AssetUtilities.getHeaderMap(); // key: header of csv, value: field api name
        Map<String, Schema.SObjectField> assetFieldNames = Schema.SObjectType.Asset.fields.getMap();
        Asset asset;
        List<String> fieldValues;
        List<Asset> updatedAssets = new List<Asset>();
        Boolean isUpdate = false;
        for(Integer i = 1; i < rows.size(); i++)
        {
            isUpdate = false;
            fieldValues = AssetUtilities.splitCsv(rows[i]);
            if(fieldValues.size() > 0 && String.isNotEmpty(fieldValues[0]))
            {
                asset = new Asset();
                asset.put('Id', fieldValues[0]);
                for(Integer j = 1; j < fieldValues.size(); j++)
                {
                    if(j == fieldValues.size() - 1) // last column
                    {
                        headers[j] = headers[j].split('\\n').size() >= 1 ? headers[j].split('\\n')[0] : headers[j];
                        headers[j] = headers[j].split('\\r').size() >= 1 ? headers[j].split('\\r')[0] : headers[j];
                        if(fieldValues[j] != null && fieldValues[j] != '' && fieldValues[j] != ' ')
                        {
                            fieldValues[j] = fieldValues[j].split('\\n').size() >= 1 ? fieldValues[j].split('\\n')[0] : fieldValues[j];
                            fieldValues[j] = fieldValues[j].split('\\r').size() >= 1 ? fieldValues[j].split('\\r')[0] : fieldValues[j];
                        }
                    }
                    if(fieldHeaderMap.containsKey(headers[j]))
                    {
                        isUpdate = true;
                        asset = (Asset)validateFieldValue(asset, fieldValues[j], assetFieldNames.get(fieldHeaderMap.get(headers[j])));
                    }
                }
                if(isUpdate)
                {
                    updatedAssets.add(asset);
                }
            }
        }
        return updatedAssets;
    }
    
    private sObject validateFieldValue(sObject obj, String value, Schema.SObjectField objectField)
    {
        Schema.DescribeFieldResult fieldResult = objectField != null ? objectField.getDescribe() : null;
        if(fieldResult != null)
        {
            Schema.DisplayType fieldType = fieldResult.getType();
            if(String.isEmpty(value))
            {
                obj.put(fieldResult.getName(), null);
            }
            else if(fieldType == Schema.DisplayType.Date)
            {
                try
                {
                    String [] dateStr = value.split('/'); // 11/22/2014
                    obj.put(fieldResult.getName(), Date.newInstance(Integer.valueOf(dateStr[2]), Integer.valueOf(dateStr[0]), Integer.valueOf(dateStr[1])));
                }
                catch(Exception ex)
                {
                    throw ex;
                }
            }
            else
            {
                value = EncodingUtil.urldecode(EncodingUtil.urlEncode(value, 'UTF-8').replaceAll('%5Cn', '%0A'), 'UTF-8');
                obj.put(fieldResult.getName(), value);
            }
        }
        return obj;
    }
}