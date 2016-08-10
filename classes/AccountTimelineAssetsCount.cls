global with sharing class AccountTimelineAssetsCount implements Schedulable {

    // This class will be run as part of the AccountTimelineController's scheduled interface.
    private transient Map<String,Map<String, Integer>> acctWithAssets {get; set;}
     
    public AccountTimelineAssetsCount () {
    }
    global void execute(SchedulableContext sc) {
           new AccountTimelineAssetsCount().populateAssetsCount();           
    }
    public void populateAssetsCount() { 
       Map<String, String>  sappCap = new Map<String, String>();
       
       sappCap.put('NX-1700', 'SMALL');
       sappCap.put('NX-1700-D', 'SMALL');
       sappCap.put('NX-1700-B-HW', 'SMALL');        
       sappCap.put('NX-2500', 'SMALL');
       sappCap.put('NX-2600', 'SMALL');
       sappCap.put('NX-2610', 'SMALL');
       sappCap.put('NX-2700', 'SMALL');
       sappCap.put('NX-2700-B-HW', 'SMALL');
       sappCap.put('NX-3500', 'SMALL');
       sappCap.put('NX-3600', 'SMALL');
       sappCap.put('NX-3700', 'SMALL');
        
       sappCap.put('NX-5500', 'MEDIUM');
       sappCap.put('NX-5504', 'MEDIUM');
       sappCap.put('NX-5600', 'MEDIUM');
       sappCap.put('NX-5700', 'MEDIUM');
       sappCap.put('NX-6700', 'MEDIUM');
       sappCap.put('NX-7500', 'MEDIUM');
       sappCap.put('NX-7504', 'MEDIUM');
       sappCap.put('NX-7600', 'MEDIUM');
       sappCap.put('NX-7700', 'MEDIUM');
        
       sappCap.put('NX-8504', 'LARGE');
       sappCap.put('NX-8600', 'LARGE');
       sappCap.put('NX-8700', 'LARGE');       
       sappCap.put('NX-9610', 'LARGE');
       sappCap.put('NX-9700', 'LARGE');       
       sappCap.put('NX-10700', 'LARGE');
       sappCap.put('NX-11700', 'LARGE');
       
       // VRX
       sappCap.put('VRX-2', 'SMALL');
       sappCap.put('VRX-4', 'MEDIUM');
       sappCap.put('VRX-8', 'LARGE');
       
       
       // VX
       
       
       sappCap.put('VX-500', 'SMALL');
       sappCap.put('VX-1000', 'SMALL');
       sappCap.put('VX-2000', 'SMALL');
       sappCap.put('VX-3000', 'SMALL');
       
       sappCap.put('VX-5000', 'MEDIUM');       
       sappCap.put('VX-6000', 'MEDIUM');
       sappCap.put('VX-7000', 'MEDIUM');
       
       sappCap.put('VX-8000', 'LARGE');
       sappCap.put('VX-9000', 'LARGE');
       
               
       acctWithAssets = new  Map<String,Map<String, Integer>>();
       List<Asset> allAssets = [SELECT Account.Name, AccountId, Model__c FROM Asset];
       for (Asset asset: allAssets) {
            //System.Debug(LoggingLevel.INFO, 'Adding key Aggr:' + (String) agr.get('Account') + ',' + (String) agr.get('Product')+ ', ' + (Integer) agr.get('Total')); 
            if(!acctWithAssets.containsKey(asset.AccountId)) {
                Map<String,Integer> initial = new Map<String,Integer>();
                initial.put('NX', 0);
                initial.put('VX', 0);
                initial.put('VRX', 0);
                initial.put('GMS', 0);
                initial.put('GX', 0); 
                initial.put('SMALL', 0);               
                initial.put('MEDIUM', 0);               
                initial.put('LARGE', 0);               
                                                
                Map<String,Integer> obj = acctWithAssets.put(asset.AccountId, initial);
            }
            Map<String,Integer> obj = acctWithAssets.get(asset.AccountId);
            String model = asset.Model__c;
            if(model.contains('SPARE')) {
                System.Debug(LoggingLevel.INFO, 'Ignoring SPARE: ' + model);
                continue;
            }
            String appType = sappCap.get(model);
            if(appType != null) {
                obj.put(appType, obj.get(appType) + 1);
            } else {
                //System.Debug(LoggingLevel.INFO, 'App type not found for model: ' + model);
            }
            if(model == 'VX-XEN' || model == 'VX-EQ') {
                System.Debug(LoggingLevel.INFO, 'Ignoring model: ' + model);
            } else if(model.startsWith('V')) {
                
                if(model.startsWith('VRX')) {
                   obj.put('VRX', obj.get('VRX') + 1);
                   
                } else if(model.startsWith('VX')) {
                   obj.put('VX', obj.get('VX') + 1);                  
                } else {
                    System.Debug(LoggingLevel.INFO, 'Ignoring model: ' + model);
                }
            } else if(model.startsWith('N')) {
                   obj.put('NX', obj.get('NX') + 1);
            } else if(model.startsWith('G')) {
                if(model.startsWith('GM')) {
                    obj.put('GMS', obj.get('GMS') + 1);
                } else if(model.startsWith('GX')) {
                    obj.put('GX', obj.get('GX') + 1);
                }
            } else {
                System.Debug(LoggingLevel.INFO, 'Ignoring model: ' + model);
            }
        }
       //System.Debug(LoggingLevel.INFO,JSON.serialize(acctWithAssets));
       
       List<AccountWithTimeline__c> acctList = [SELECT Name__c, GMS__c, GX__c, NX__c, VRX__c, VX__c, SMALL__c, MEDIUM__c, LARGE__c FROM AccountWithTimeline__c];  
       for(AccountWithTimeline__c acct: acctList) {
           
           Map<String,Integer> obj = acctWithAssets.get(acct.Name__c);
           //No Assets
           if(obj == null) {
               acct.GMS__c = 0;
               acct.GX__c = 0;
               acct.NX__c = 0;
               acct.VRX__c = 0;
               acct.VX__c = 0;
               acct.SMALL__c = 0;
               acct.MEDIUM__c = 0;
               acct.LARGE__c = 0;
           } else {
           
               //System.Debug(LoggingLevel.INFO, 'NX:' + obj.get('NX') + ', Acct: ' + acct.Name__c);
               acct.GMS__c = (Integer) obj.get('GMS');
               acct.GX__c = (Integer)obj.get('GX');
               acct.NX__c = (Integer)obj.get('NX');
               acct.VRX__c = (Integer)obj.get('VRX');
               acct.VX__c = (Integer)obj.get('VX'); 
               acct.SMALL__c = (Integer)obj.get('SMALL');
               acct.MEDIUM__c = (Integer)obj.get('MEDIUM');
               acct.LARGE__c = (Integer)obj.get('LARGE');
           }
       } 
       System.Debug(LoggingLevel.INFO,JSON.serialize(acctList));
       update acctList;
    }
}