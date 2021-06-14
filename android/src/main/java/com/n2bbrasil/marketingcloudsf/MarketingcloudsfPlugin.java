package com.n2bbrasil.marketingcloudsf;

import android.app.Activity;
import android.app.PendingIntent;
import android.content.Context;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import io.flutter.BuildConfig;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;


import android.content.Intent;
import android.net.Uri;
import android.text.TextUtils;
import android.util.Log;


import com.salesforce.marketingcloud.InitializationStatus;
import com.salesforce.marketingcloud.MCLogListener;
import com.salesforce.marketingcloud.MarketingCloudConfig;
import com.salesforce.marketingcloud.MarketingCloudSdk;
import com.salesforce.marketingcloud.UrlHandler;
import com.salesforce.marketingcloud.analytics.AnalyticsManager;
import com.salesforce.marketingcloud.analytics.PiCart;
import com.salesforce.marketingcloud.analytics.PiCartItem;
import com.salesforce.marketingcloud.analytics.PiOrder;
import com.salesforce.marketingcloud.messages.Region;
import com.salesforce.marketingcloud.messages.RegionMessageManager;
import com.salesforce.marketingcloud.messages.geofence.GeofenceMessageResponse;
import com.salesforce.marketingcloud.messages.iam.InAppMessage;
import com.salesforce.marketingcloud.messages.iam.InAppMessageManager;
import com.salesforce.marketingcloud.messages.proximity.ProximityMessageResponse;
import com.salesforce.marketingcloud.notifications.NotificationCustomizationOptions;
import com.salesforce.marketingcloud.notifications.NotificationManager;
import com.salesforce.marketingcloud.notifications.NotificationMessage;
import com.salesforce.marketingcloud.registration.Registration;
import com.salesforce.marketingcloud.registration.RegistrationManager;

import org.jetbrains.annotations.NotNull;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;
import java.util.TimeZone;

import static com.google.android.gms.common.util.CollectionUtils.listOf;


/** MarketingcloudsfPlugin */
public class MarketingcloudsfPlugin implements FlutterPlugin, MethodCallHandler, ActivityAware {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  public MethodChannel channel;
  public MarketingCloudSdk sdk;
  public AnalyticsManager analyticsManager;
  public MarketingCloudSdk.InitializationListener listener;
  public Activity activity;
  public static final String DEFAULT_ERROR_CODE = "Marketing_cloud_sdk_error";
  public Context context;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {

     context = flutterPluginBinding.getApplicationContext();

      
    MarketingCloudSdk.setLogLevel(BuildConfig.DEBUG ? Log.VERBOSE : Log.ERROR);
    MarketingCloudSdk.setLogListener(new MCLogListener.AndroidLogListener());

    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "marketingcloudsf");
    channel.setMethodCallHandler(this);


   
 
  }


  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }

  public Boolean isPushEnabled() {

    return sdk.getPushMessageManager().isPushEnabled();
  }

  public void enablePush() {
 
    sdk.getPushMessageManager().enablePush();
  }

  public void disablePush() {
    sdk.getPushMessageManager().disablePush();
  }

  public String getSystemToken() {


     return sdk.getPushMessageManager().getPushToken();
  }

  public Map<String, String> getAttributes() {

    Map<String, String> attributes = sdk.getRegistrationManager().getAttributes();
    Map<String, String> resultMap = new HashMap<>(attributes.size());

    if (!attributes.isEmpty()) {
      for (Map.Entry<String, String> entry : attributes.entrySet()) {
        resultMap.put(entry.getKey(), entry.getValue());
      }
    }


    return resultMap;


  }

  public void setAttribute(Map<String, Object> arguments) {
    sdk.getRegistrationManager().edit().setAttribute(arguments.get("key").toString(), arguments.get("value").toString()).commit();
  }

  public void clearAttribute(Map<String, Object> arguments) {

    sdk.getRegistrationManager().edit().clearAttribute(arguments.get("key").toString()).commit();
  }

  public void addTag(Map<String, Object> arguments) {
    sdk.getRegistrationManager().edit().addTag(arguments.get("tag").toString()).commit();
  }

  public void removeTag(Map<String, Object> arguments) {
    sdk.getRegistrationManager().edit().removeTag(arguments.get("tag").toString()).commit();
  }

  public List<String> getTags() {

    Set<String> tags = sdk.getRegistrationManager().getTags();
    List<String> result = new ArrayList<>(tags.size());
    result.addAll(tags);

    return result;


  }

  public void setContactKey(Map<String, Object> arguments) {
    sdk.getRegistrationManager().edit().setContactKey(arguments.get("contactKey").toString()).commit();
  }

  public String getContactKey() {
    return sdk.getRegistrationManager().getContactKey();
  }


  public void enableVerboseLogging() {
    //sdk.setLogLevel(MCLogListener.VERBOSE);
    //sdk.setLogListener(new MCLogListener.AndroidLogListener());
  }

  public void disableVerboseLogging() {
    sdk.setLogListener(null);
  }

  public void logSdkState() {
    //log("MCSDK STATE", sdk.getSdkState().toString());
  }
  public void init(Map<String, Object> arguments){
    MarketingCloudSdk.init(
      context,
      MarketingCloudConfig
              .builder()
              .setApplicationId(arguments.get("appID").toString())
              .setAccessToken(arguments.get("accessToken").toString())
              .setSenderId(arguments.get("senderId").toString())
              .setMarketingCloudServerUrl(arguments.get("appEndpoint").toString())
              .setMid(arguments.get("mid").toString())
              .setDelayRegistrationUntilContactKeyIsSet(true)
              .setUseLegacyPiIdentifier(true)
              .setMarkMessageReadOnInboxNotificationOpen(true)
              .setAnalyticsEnabled(true)
              .setPiAnalyticsEnabled(true)
              .setInboxEnabled(true)
              .setGeofencingEnabled(true)
              .setProximityEnabled(true)
              .setNotificationCustomizationOptions(NotificationCustomizationOptions.create(R.drawable.ic_launcher))
              // Other configuration options
              .setUrlHandler(new UrlHandler() {
                @Nullable
                @Override
                public PendingIntent handleUrl(@NonNull Context context, @NonNull String url, @NonNull String type) {
                  // Open IAM URLs in device browser.
                  return PendingIntent.getActivity(
                          context,
                          1,
                          new Intent(Intent.ACTION_VIEW, Uri.parse(url)),
                          PendingIntent.FLAG_UPDATE_CURRENT);
                }
              })
              .build(context),
      listener);
      sdk = MarketingCloudSdk.getInstance();
      analyticsManager  = sdk.getAnalyticsManager();
      
  }

  public void trackCart(Map<String, Object> arguments) {


    PiCartItem cartItem = PiCartItem.create(arguments.get("item").toString(), Integer.parseInt(arguments.get("quantity").toString()), Double.parseDouble(arguments.get("value").toString()), arguments.get("uniqueId").toString());
    PiCart cart = PiCart.create(listOf(cartItem));

    analyticsManager.trackCartContents(cart);
  }
  public void trackConversion(Map<String, Object> arguments) {


    PiCartItem cartItem = PiCartItem.create(arguments.get("item").toString(), Integer.parseInt(arguments.get("quantity").toString()), Double.parseDouble(arguments.get("value").toString()), arguments.get("uniqueId").toString());
    PiCart cart = PiCart.create(listOf(cartItem));
    PiOrder order = PiOrder.create(cart, arguments.get("orderNumber").toString(), Double.parseDouble(arguments.get("shipping").toString()), Double.parseDouble(arguments.get("discount").toString()));

    analyticsManager.trackCartConversion(order);
  }
  public void trackPageViews(Map<String, Object> arguments) {

    analyticsManager.trackPageView(arguments.get("url").toString(), arguments.get("title").toString(),arguments.get("item").toString(),arguments.get("searchTerms").toString() );
  }
  public void trackInboxMessageOpens(Map<String, Object> arguments) {
    //analyticsManager.trackInboxOpenEvent(menssage);
  }
  public void inAppMenssage(Map<String, Object> arguments) {
    sdk.getInAppMessageManager().setInAppMessageListener(new InAppMessageManager.EventListener() {
      @Override
      public boolean shouldShowMessage(@NonNull @NotNull InAppMessage inAppMessage) {


        return true;
      }

      @Override
      public void didShowMessage(@NonNull @NotNull InAppMessage inAppMessage) {

      }

      @Override
      public void didCloseMessage(@NonNull @NotNull InAppMessage inAppMessage) {

      }
    });
  }
  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {

   
    
    switch (call.method) {
      case "inAppMenssage":
        inAppMenssage(call.<Map<String, Object>>arguments());
        break;
      case "trackCart":
      trackCart(call.<Map<String, Object>>arguments());
        break;
      case "trackConversion":
        trackConversion(call.<Map<String, Object>>arguments());
        break;
      case "trackPageViews":
        trackPageViews(call.<Map<String, Object>>arguments());
        break;
      case "trackInboxMessageOpens":
        trackInboxMessageOpens(call.<Map<String, Object>>arguments());
        break;
      case "init":
        init(call.<Map<String, Object>>arguments());
        break;
      case "isPushEnabled":
        result.success(isPushEnabled());
        break;
      case "enablePush":
        enablePush();
        break;
      case "disablePush":
        disablePush();
        break;
      case "getSystemToken":
        result.success(getSystemToken());
        break;
      case "getAttributes":
        result.success(getAttributes());
        break;
      case "setAttribute":
        setAttribute(call.<Map<String, Object>>arguments());
        break;
      case "clearAttribute":
        clearAttribute(call.<Map<String, Object>>arguments());
        break;
      case "addTag":
        addTag(call.<Map<String, Object>>arguments());
        break;
      case "removeTag":
        removeTag(call.<Map<String, Object>>arguments());
        break;
      case "getTags":
        result.success(getTags());
        break;
      case "setContactKey":
        setContactKey(call.<Map<String, Object>>arguments());
        break;
      case "getContactKey":
        result.success(getContactKey());
        break;
      case "enableVerboseLogging":
        enableVerboseLogging();
        break;
      case "disableVerboseLogging":
        disableVerboseLogging();
        break;
      case "logSdkState":
        logSdkState();
        break;
      default:
        result.notImplemented();
        break;


    }

  }
  @Override
  public void onAttachedToActivity(@NonNull ActivityPluginBinding activityPluginBinding) {
    activity = activityPluginBinding.getActivity();
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {

  }

  @Override
  public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding activityPluginBinding) {

  }

  @Override
  public void onDetachedFromActivity() {

  }
}
