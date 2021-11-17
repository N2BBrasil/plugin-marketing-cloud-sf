import Flutter
import UIKit
import MarketingCloudSDK

public class SwiftMarketingcloudsfPlugin: NSObject,
        FlutterPlugin,
        MarketingCloudSDKEventDelegate,
        MarketingCloudSDKURLHandlingDelegate,
        UNUserNotificationCenterDelegate,
        UIApplicationDelegate {
    
    public static func register(with registrar: FlutterPluginRegistrar) {
      let channel = FlutterMethodChannel(name: "marketingcloudsf", binaryMessenger: registrar.messenger())
      let instance = SwiftMarketingcloudsfPlugin()
      registrar.addMethodCallDelegate(instance, channel: channel)
      registrar.addApplicationDelegate(instance)
    }
    
    public var window: UIWindow?
    
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
            
            MarketingCloudSDK.sharedInstance().sfmc_setEventDelegate(self)
            MarketingCloudSDK.sharedInstance().sfmc_setURLHandlingDelegate(self)

            // Make sure to dispatch this to the main thread, as UNUserNotificationCenter will present UI.
            DispatchQueue.main.async {
                if #available(iOS 10.0, *) {
                    // Set the UNUserNotificationCenterDelegate to a class adhering to thie protocol.
                    // In this exmple, the AppDelegate class adheres to the protocol (see below)
                    // and handles Notification Center delegate methods from iOS.
                    UNUserNotificationCenter.current().delegate = self
                    // Request authorization from the user for push notification alerts.
                    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge], completionHandler: {(_ granted: Bool, _ error: Error?) -> Void in
                        if error == nil {
                            if granted == true {
                                // Your application may want to do something specific if the user has granted authorization
                                // for the notification types specified; it would be done here.
                                print(MarketingCloudSDK.sharedInstance().sfmc_deviceToken() ?? "error: no token - was UIApplication.shared.registerForRemoteNotifications() called?")
                            }
                        }
                    })
                }
                
                // In any case, your application should register for remote notifications *each time* your application
                // launches to ensure that the push token used by MobilePush (for silent push) is updated if necessary.
                
                // Registering in this manner does *not* mean that a user will see a notification - it only means
                // that the application will receive a unique push token from iOS.
                UIApplication.shared.registerForRemoteNotifications()
            }
        
        }
        
        return success
    }
    
    public func sfmc_handle(_ url: URL, type: String) {
        UIApplication.shared.open(url, options: [:],
                                  completionHandler: {
                                    (success) in
                                    print("Open \(url): \(success)")
        })
    }
    
    public func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print(deviceToken)
        MarketingCloudSDK.sharedInstance().sfmc_setDeviceToken(deviceToken)
    }

    // MobilePush SDK: REQUIRED IMPLEMENTATION
    public func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print(error)
    }

    
    // MobilePush SDK: REQUIRED IMPLEMENTATION
    /** This delegate method offers an opportunity for applications with the "remote-notification" background mode to fetch appropriate new data in response to an incoming remote notification. You should call the fetchCompletionHandler as soon as you're finished performing that operation, so the system can accurately estimate its power and data cost.
     This method will be invoked even if the application was launched or resumed because of the remote notification. The respective delegate methods will be invoked first. Note that this behavior is in contrast to application:didReceiveRemoteNotification:, which is not called in those cases, and which will not be invoked if this method is implemented. **/
    @nonobjc public func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        MarketingCloudSDK.sharedInstance().sfmc_setNotificationUserInfo(userInfo)
        completionHandler(.newData)
    }
    
    // MobilePush SDK: REQUIRED IMPLEMENTATION
    // The method will be called on the delegate when the user responded to the notification by opening the application, dismissing the notification or choosing a UNNotificationAction. The delegate must be set before the application returns from applicationDidFinishLaunching:.
    @available(iOS 10.0, *)
    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // Required: tell the MarketingCloudSDK about the notification. This will collect MobilePush analytics
        // and process the notification on behalf of your application.
        MarketingCloudSDK.sharedInstance().sfmc_setNotificationRequest(response.notification.request)
        completionHandler()
    }

    // MobilePush SDK: REQUIRED IMPLEMENTATION
    // The method will be called on the delegate only if the application is in the foreground. If the method is not implemented or the handler is not called in a timely manner then the notification will not be presented. The application can choose to have the notification presented as a sound, badge, alert and/or in the notification list. This decision should be based on whether the information in the notification is otherwise visible to the user.
    @available(iOS 10.0, *)
    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler(.alert)
    }
    
    public func sfmc_didShow(inAppMessage message: [AnyHashable : Any]) {
        // message shown
    }

    public func sfmc_didClose(inAppMessage message: [AnyHashable : Any]) {
        // message closed
    }
    
    public func sfmc_shouldShow(inAppMessage message: [AnyHashable : Any]) -> Bool {
         print("message should show")
         return true
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
      case "initialize": if let args = call.arguments as? Dictionary<String, Any>,
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
      case "getMessagingToken":
          result(MarketingCloudSDK.sharedInstance().sfmc_deviceToken())
      case "setMessagingToken":
         result(true)
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
      case "logSdkState":
          print("SDK State = \(MarketingCloudSDK.sharedInstance().sfmc_getSDKState() ?? "SDK State is nil")")
      default: result(FlutterMethodNotImplemented)

      
    
    
      }
  }
}
