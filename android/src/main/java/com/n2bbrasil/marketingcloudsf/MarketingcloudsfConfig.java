package com.n2bbrasil.marketingcloudsf;

import android.annotation.SuppressLint;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;

import com.salesforce.marketingcloud.MarketingCloudConfig;
import com.salesforce.marketingcloud.notifications.NotificationCustomizationOptions;

import java.util.Random;

public class MarketingcloudsfConfig {
    private MarketingcloudsfConfig() {}

    @SuppressLint("UnspecifiedImmutableFlag")
    public static MarketingCloudConfig prepareConfigBuilder(
            Context context,
            String appID,
            String accessToken,
            String senderId,
            String appEndpoint,
            String mid
    ) {
        return MarketingCloudConfig
                .builder()
                .setApplicationId(appID)
                .setAccessToken(accessToken)
//                .setSenderId(senderId)
                .setMarketingCloudServerUrl(appEndpoint)
                .setMid(mid)
                .setDelayRegistrationUntilContactKeyIsSet(true)
                .setUseLegacyPiIdentifier(true)
                .setAnalyticsEnabled(true)
                .setPiAnalyticsEnabled(true)
                .setGeofencingEnabled(true)
                .setProximityEnabled(true)
                .setNotificationCustomizationOptions(NotificationCustomizationOptions.create(R.drawable.notification_icon))
                .setUrlHandler((context1, url, type) -> {
                    Random r = new Random();
                    return PendingIntent.getActivity(
                            context1,
                            r.nextInt(),
                            new Intent(Intent.ACTION_VIEW, Uri.parse(url)),
                            PendingIntent.FLAG_UPDATE_CURRENT);
                })
                .build(context);
    }
}