import Flutter
import UIKit
import MarketingCloudSDK

public class SwiftMarketingcloudsfPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "marketingcloudsf", binaryMessenger: registrar.messenger())
    let instance = SwiftMarketingcloudsfPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }


 
    var window: UIWindow?
    
    
    
    let inbox = false
    let location = false
    let analytics = true
    
    @discardableResult
    func configureMarketingCloudSDK(appID: String,accessToken: String,appEndpoint: String,mid: String) -> Bool {
        let builder = MarketingCloudSDKConfigBuilder()
            .sfmc_setApplicationId(appID)
            .sfmc_setAccessToken(accessToken)
            .sfmc_setMarketingCloudServerUrl(appEndpoint)
            .sfmc_setMid(mid)
            .sfmc_setInboxEnabled(inbox as NSNumber)
            .sfmc_setLocationEnabled(location as NSNumber)
            .sfmc_setAnalyticsEnabled(analytics as NSNumber)
            .sfmc_build()!
        
        var success = false
        
        do {
            try MarketingCloudSDK.sharedInstance().sfmc_configure(with:builder)
            success = true
        } catch let error as NSError {
            
            let configErrorString = String(format: "MarketingCloudSDK sfmc_configure failed with error = %@", error)
            print(configErrorString)
        }
        
        if success == true {            
            #if DEBUG
            MarketingCloudSDK.sharedInstance().sfmc_setDebugLoggingEnabled(true)
            #endif
        }
        
        return success
    }
    








  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    
     
      switch (call.method) {
      case "inAppMenssage":  result(FlutterError.init(code: "errorSetDebug", message: "data or format error", details: nil))
      
      case "trackCart": MarketingCloudSDK.sharedInstance().sfmc_trackCartContents(call.arguments as! [AnyHashable : Any])
      
      case "trackConversion": MarketingCloudSDK.sharedInstance().sfmc_trackCartConversion(call.arguments as! [AnyHashable : Any])
      
      case "trackPageViews": if let args = call.arguments as? Dictionary<String, Any>,
          let url = args["url"] as? String,
          let title = args["title"] as? String,
          let item = args["item"] as? String,
          let search = args["search"] as? String {
        
        MarketingCloudSDK.sharedInstance().sfmc_trackPageView(withURL: url,title: title,item: item,search: search)

        } else {
          result(FlutterError.init(code: "errorSetDebug", message: "data or format error", details: nil))
        }
      
      
      case "trackInboxMessageOpens":  result(FlutterError.init(code: "errorSetDebug", message: "data or format error", details: nil))
      
      case "init": if let args = call.arguments as? Dictionary<String, Any>,
          let appID = args["appID"] as? String,
          let accessToken = args["accessToken"] as? String,
          let appEndpoint = args["appEndpoint"] as? String,
          let mid = args["mid"] as? String {
        
        self.configureMarketingCloudSDK(appID: appID,accessToken: accessToken,appEndpoint: appEndpoint,mid: mid)

        } else {
          result(FlutterError.init(code: "errorSetDebug", message: "data or format error", details: nil))
        }
      
      
      

      case "getPlatformVersion": result("iOS " + UIDevice.current.systemVersion)
     
      case "isPushEnabled": result(MarketingCloudSDK.sharedInstance().sfmc_pushEnabled())
     
      case "enablePush":  result(MarketingCloudSDK.sharedInstance().sfmc_setPushEnabled(true))
     
      case "disablePush":  result(MarketingCloudSDK.sharedInstance().sfmc_setPushEnabled(false))
     
      case "getSystemToken":  result(MarketingCloudSDK.sharedInstance().sfmc_deviceToken())
     
      case "getAttributes":  result(MarketingCloudSDK.sharedInstance().sfmc_attributes())
      
      case "setAttribute":  
      if let args = call.arguments as? Dictionary<String, Any>,
          let key = args["key"] as? String,
          let value = args["value"] as? String {
        
          result(MarketingCloudSDK.sharedInstance().sfmc_setAttributeNamed(key, value: value))

        } else {
          result(FlutterError.init(code: "errorSetDebug", message: "data or format error", details: nil))
        }
      
      
      case "clearAttribute":  
       if let args = call.arguments as? Dictionary<String, Any>,
          let key = args["key"] as? [Any]{
            
            result(MarketingCloudSDK.sharedInstance().sfmc_clearAttributesNamed(key))
        } else {
          result(FlutterError.init(code: "errorSetDebug", message: "data or format error", details: nil))
        }
      
      
      case "addTag":  
      if let args = call.arguments as? Dictionary<String, Any>,
          let tag = args["tag"] as? String{
            
            result(MarketingCloudSDK.sharedInstance().sfmc_addTag(tag))        
        } else {
          result(FlutterError.init(code: "errorSetDebug", message: "data or format error", details: nil))
        }
      
      
      case "removeTag":  
        if let args = call.arguments as? Dictionary<String, Any>,
          let tag = args["tag"] as? String{
            
            result(MarketingCloudSDK.sharedInstance().sfmc_removeTag(tag))       
        } else {
          result(FlutterError.init(code: "errorSetDebug", message: "data or format error", details: nil))
        }
      
     
      case "getTags":  result(MarketingCloudSDK.sharedInstance().sfmc_tags())
      
      case "setContactKey":  
      if let args = call.arguments as? Dictionary<String, Any>,
          let contactKey = args["contactKey"] as? String{
            
            result(MarketingCloudSDK.sharedInstance().sfmc_setContactKey(contactKey))     
        } else {
          result(FlutterError.init(code: "errorSetDebug", message: "data or format error", details: nil))
        }
      
     
      case "getContactKey":  result(MarketingCloudSDK.sharedInstance().sfmc_contactKey())
     
      case "enableVerboseLogging":  result(MarketingCloudSDK.sharedInstance().sfmc_setDebugLoggingEnabled(true))
     
      case "disableVerboseLogging":  result(MarketingCloudSDK.sharedInstance().sfmc_setDebugLoggingEnabled(false))
      
      case "logSdkState":  result(MarketingCloudSDK.sharedInstance().sfmc_getSDKState())
     
     
    
        
      case ("configure") :
            UIApplication.shared.registerForRemoteNotifications()

            /*if launchNotification != nil {
                self.channel?.invokeMethod("onLaunch", arguments: launchNotification!)
            }

            result(nil)*/
        result(FlutterMethodNotImplemented)
      
      default: result(FlutterMethodNotImplemented)

      
    
    
  }




     

    



}
}
