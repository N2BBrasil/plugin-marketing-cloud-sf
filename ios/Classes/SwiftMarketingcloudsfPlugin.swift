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
    
    /
    
    let inbox = false
    let location = false
    let analytics = true
    
    @discardableResult
    func configureMarketingCloudSDK(appID: String,accessToken: String,appEndpoint: String,mid: String,) -> Bool {
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
      
      case "trackCart": MarketingCloudSDK.sharedInstance().sfmc_trackCartContents(call.arguments)
      
      case "trackConversion": MarketingCloudSDK.sharedInstance().sfmc_trackCartConversion(call.arguments)
      
      case "trackPageViews": if let args = call.arguments as? Dictionary<String, Any>,
          let url = args["url"] as? String,
          let title = args["title"] as? String,
          let item = args["item"] as? String,
          let search = args["search"] as? String {
        
           MarketingCloudSDK.sharedInstance().sfmc_trackPageView(url,title,item,search)

        } else {
          result(FlutterError.init(code: "errorSetDebug", message: "data or format error", details: nil))
        }
      
      
      case "trackInboxMessageOpens":  result(FlutterError.init(code: "errorSetDebug", message: "data or format error", details: nil))
      
      case "init": if let args = call.arguments as? Dictionary<String, Any>,
          let appID = args["appID"] as? String,
          let accessToken = args["accessToken"] as? String,
          let appEndpoint = args["appEndpoint"] as? String,
          let mid = args["mid"] as? String {
        
          self.configureMarketingCloudSDK(appID,accessToken,appEndpoint,mid)

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
     
      case "requestNotificationPermissions":
          let registeredToMarketingCloud = self.configureMarketingCloudSDK()

            logMessage("requestNotificationPermissions registeredToMC: \(registeredToMarketingCloud)")

            if (!registeredToMarketingCloud) {
                result(FlutterError(code: String(format: "Error %ld", 897),
                                    message: "Failed to register with marketing cloud",
                                    details: "MarketingCloudSDK sfmc_configure failed with error"))
                return
            }
            
            let arguments = args as? Dictionary<String, Any>
            
            if #available(iOS 10.0, *) {
                logMessage("request ios > 10")
                
                var authOptions: UNAuthorizationOptions = []
                let provisional = (arguments?["provisional"] as? Bool) ?? false
                let soundSelected = (arguments?["sound"] as? Bool) ?? false
                let alertSelected = (arguments?["alert"] as? Bool) ?? false
                let badgeSelected = (arguments?["badge"] as? Bool) ?? false
                
                if (soundSelected) {
                    authOptions.insert(.sound)
                }
                if (alertSelected) {
                    authOptions.insert(.alert)
                }
                if (badgeSelected) {
                    authOptions.insert(.badge)
                }

                var isAtLeastVersion12: Bool = false
                if #available(iOS 12, *) {
                    isAtLeastVersion12 = true
                    
                    if (provisional) {
                        authOptions.insert(.provisional)
                    }
                } else {
                    isAtLeastVersion12 = false
                }
                
                let center = UNUserNotificationCenter.current()

                center.delegate = self
                
                center.requestAuthorization(options: authOptions, completionHandler: { granted, error in
                    if error != nil {
                        self.logMessage("Something went wrong, error found")
                        result(self.getFlutterError(error))
                        
                        return
                    }
                    
                    if !granted {
                        self.logMessage("Something went wrong, permission not granted")
                        result(self.getFlutterError(error))
                        
                        return
                    } else {
                        let deviceToken = MarketingCloudSDK.sharedInstance().sfmc_deviceToken()

                        if deviceToken == nil {
                            self.logMessage("error: no token - was UIApplication.shared.registerForRemoteNotifications() called?")
                        } else {
                            let token = deviceToken ?? "** empty **"
                            self.logMessage("success: token - was \(token)")
                        }
                    }

                 
                    UNUserNotificationCenter.current().getNotificationSettings(completionHandler: { settings in
                        let settingsDictionary = [
                            "sound": NSNumber(value: settings.soundSetting == .enabled),
                            "badge": NSNumber(value: settings.badgeSetting == .enabled),
                            "alert": NSNumber(value: settings.alertSetting == .enabled),
                            "provisional": NSNumber(value: granted && provisional && isAtLeastVersion12)
                        ]
                        self.channel?.invokeMethod("onIosSettingsRegistered", arguments: settingsDictionary)
                    })
                    
                    result(NSNumber(value: granted))
                })
                
                UIApplication.shared.registerForRemoteNotifications()
            } else {
                logMessage("request ios < 10")
                var notificationTypes = UIUserNotificationType(rawValue: 0)
                let soundSelected = (arguments?["sound"] as? Bool) ?? false
                let alertSelected = (arguments?["alert"] as? Bool) ?? false
                let badgeSelected = (arguments?["badge"] as? Bool) ?? false
                
                if (soundSelected) {
                    notificationTypes.insert(.sound)
                }
                if (alertSelected) {
                    notificationTypes.insert(.alert)
                }
                if (badgeSelected) {
                    notificationTypes.insert(.badge)
                }
                
                let settings = UIUserNotificationSettings(types: notificationTypes, categories: nil)
                UIApplication.shared.registerUserNotificationSettings(settings)

                UIApplication.shared.registerForRemoteNotifications()
                result(NSNumber(value: true))
            }
        } else if (call.method == "configure") {
            UIApplication.shared.registerForRemoteNotifications()

            if launchNotification != nil {
                self.channel?.invokeMethod("onLaunch", arguments: launchNotification!)
            }

            result(nil)


      default: result(FlutterMethodNotImplemented)

      }
    
    
  }




    // MARK: - app delegate
    public func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        MarketingCloudSDK.sharedInstance().sfmc_setDeviceToken(deviceToken)
    }
    
    public func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        logMessage("\(error.localizedDescription)")
    }

    public func application(_ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [AnyHashable : Any]) -> Bool {
        launchNotification = launchOptions[UIApplication.LaunchOptionsKey.remoteNotification] as? [AnyHashable: Any]
        return true
    }

    public func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        let settingsDictionary = [
            "sound": NSNumber(value: notificationSettings.types.rawValue & UIUserNotificationType.sound.rawValue != 0),
            "badge": NSNumber(value: notificationSettings.types.rawValue & UIUserNotificationType.badge.rawValue != 0),
            "alert": NSNumber(value: notificationSettings.types.rawValue & UIUserNotificationType.alert.rawValue != 0),
            "provisional": NSNumber(value: false)
        ]
        self.channel?.invokeMethod("onIosSettingsRegistered", arguments: settingsDictionary)
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        MarketingCloudSDK.sharedInstance().sfmc_setNotificationUserInfo(userInfo)

        if (resumingFromBackground) {
            channel?.invokeMethod("onResume", arguments: userInfo)
        } else {
            channel?.invokeMethod("onMessage", arguments: userInfo)
        }

        for key in userInfo.keys {
            guard let key = key as? String else {
                continue
            }
            if let object = userInfo[key] {
                logMessage("property value: \(object)")
            }
        }
    }

    public func applicationDidEnterBackground(_ application: UIApplication) {
        resumingFromBackground = true
    }

    public func applicationDidBecomeActive(_ application: UIApplication) {
        resumingFromBackground = false
        application.applicationIconBadgeNumber = 1
        application.applicationIconBadgeNumber = 0
    }
    
    @available(iOS 10, *)
    public func userNotificationCenter(_ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void) {
        MarketingCloudSDK.sharedInstance().sfmc_setNotificationRequest(response.notification.request)
        completionHandler()
    }

    @available(iOS 10, *)
    public func userNotificationCenter(_ center: UNUserNotificationCenter,
        willPresent notification:UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler(UNNotificationPresentationOptions.alert)
    }

    private func logMessage(_ s: String) {
        print("MC: \(s)")
    }



}
