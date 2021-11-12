package com.n2bbrasil.marketingcloudsf;

import android.app.Activity;
import android.content.Context;
import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;


import android.util.Log;


import com.salesforce.marketingcloud.MCLogListener.AndroidLogListener;
import com.salesforce.marketingcloud.MarketingCloudSdk;
import com.salesforce.marketingcloud.MarketingCloudSdk.WhenReadyListener;
import com.salesforce.marketingcloud.analytics.AnalyticsManager;
import com.salesforce.marketingcloud.analytics.PiCart;
import com.salesforce.marketingcloud.analytics.PiCartItem;
import com.salesforce.marketingcloud.analytics.PiOrder;
import com.salesforce.marketingcloud.messages.iam.InAppMessage;
import com.salesforce.marketingcloud.messages.iam.InAppMessageManager;
import com.salesforce.marketingcloud.messages.push.PushMessageManager;

import org.jetbrains.annotations.NotNull;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Set;

import static com.google.android.gms.common.util.CollectionUtils.listOf;


public class MarketingcloudsfPlugin implements FlutterPlugin, MethodCallHandler, ActivityAware {
  public MethodChannel channel;
  public MarketingCloudSdk sdk;
  public AnalyticsManager analyticsManager;
  public MarketingCloudSdk.InitializationListener listener;
  public Activity activity;
  public Context context;
  private String blockedMessageId;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    context = flutterPluginBinding.getApplicationContext();
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "marketingcloudsf");
    channel.setMethodCallHandler(this);
  }


  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }

  public void initialize(String appID, String accessToken, String senderId, String appEndpoint, String mid){
    if(io.flutter.BuildConfig.DEBUG) {
      MarketingCloudSdk.setLogLevel(Log.VERBOSE);
      MarketingCloudSdk.setLogListener(new AndroidLogListener());
    }

    MarketingCloudSdk.init(
            context,
            MarketingcloudsfConfig.prepareConfigBuilder(
                    context,
                    appID,
                    accessToken,
                    senderId,
                    appEndpoint,
                    mid
            ),
            listener
    );
    sdk = MarketingCloudSdk.getInstance();
    MarketingCloudSdk.requestSdk(new WhenReadyListener() {
      @Override
      public void ready(@NonNull MarketingCloudSdk marketingCloudSdk) {
        inAppMenssageInit();
        analyticsManager  = marketingCloudSdk.getAnalyticsManager();

        if(blockedMessageId != null) {
          marketingCloudSdk.getInAppMessageManager().showMessage(blockedMessageId);
        }
      }
    });
  }

  public void inAppMenssageInit() {
    sdk.getInAppMessageManager().setInAppMessageListener(new InAppMessageManager.EventListener() {
      @Override
      public boolean shouldShowMessage(@NonNull @NotNull InAppMessage inAppMessage) {
        Log.d("SF_INAPP_RECEIVE", inAppMessage.toString() );
        if (shouldShowMessage(inAppMessage)) {
          return true;
        } else {
          blockedMessageId = inAppMessage.id();
          return false;
        }
      }

      @Override
      public void didShowMessage(@NonNull @NotNull InAppMessage inAppMessage) {      }

      @Override
      public void didCloseMessage(@NonNull @NotNull InAppMessage inAppMessage) {
        Log.d("SF_INAPP_CLOSE", inAppMessage.toString() );
      }
    });
  }

  public void handlePushMessage(Map<String,String> message) {
    if(PushMessageManager.isMarketingCloudPush(message)) {
      MarketingCloudSdk.requestSdk(new WhenReadyListener() {
        @Override
        public void ready(@NonNull MarketingCloudSdk marketingCloudSdk) {
          marketingCloudSdk.getPushMessageManager().handleMessage(message);
        }
      });
    }
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

  public void logSdkState() {
    Log.d("SDKSTATE",  sdk.getSdkState().toString());
  }

  public void setMessagingToken(String token) { sdk.getPushMessageManager().setPushToken(token); }
  public String getMessagingToken() { return sdk.getPushMessageManager().getPushToken(); }

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
    sdk.getRegistrationManager().edit().setContactKey(Objects.requireNonNull(arguments.get("contactKey")).toString()).commit();
  }

  public String getContactKey() {
    return sdk.getRegistrationManager().getContactKey();
  }


  public void trackCart(Map<String, Object> arguments) {
    PiCartItem cartItem = PiCartItem.create(arguments.get("item").toString(), Integer.parseInt(arguments.get("quantity").toString()), Double.parseDouble(arguments.get("value").toString()), arguments.get("uniqueId").toString());
    PiCart cart = PiCart.create(Collections.singletonList(cartItem));

    analyticsManager.trackCartContents(cart);
  }
  public void trackConversion(Map<String, Object> arguments) {
    PiCartItem cartItem = PiCartItem.create(arguments.get("item").toString(), Integer.parseInt(arguments.get("quantity").toString()), Double.parseDouble(arguments.get("value").toString()), arguments.get("uniqueId").toString());
    PiCart cart = PiCart.create(Collections.singletonList(cartItem));
    PiOrder order = PiOrder.create(cart, arguments.get("orderNumber").toString(), Double.parseDouble(arguments.get("shipping").toString()), Double.parseDouble(arguments.get("discount").toString()));

    analyticsManager.trackCartConversion(order);
  }
  public void trackPageViews(Map<String, Object> arguments) {
    analyticsManager.trackPageView(arguments.get("url").toString(), arguments.get("title").toString(),arguments.get("item").toString(),arguments.get("searchTerms").toString() );
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    switch (call.method) {
      case "handlePushMessage":
        handlePushMessage(call.argument("message"));
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
      case "initialize":
        initialize(
                call.argument("appID"),
                call.argument("accessToken"),
                call.argument("senderId"),
                call.argument("appEndpoint"),
                call.argument("mid")
        );
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
      case "getMessagingToken":
        result.success(getMessagingToken());
        break;
      case "setMessagingToken":
        setMessagingToken(call.argument("token"));
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
