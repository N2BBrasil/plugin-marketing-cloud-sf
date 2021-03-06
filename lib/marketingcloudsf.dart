import 'dart:async';

import 'package:flutter/services.dart';

class Marketingcloudsf {
  static const MethodChannel _channel = MethodChannel('marketingcloudsf');

  static Future<void> init({
    required String setApplicationId,
    required String setAccessToken,
    required String setSenderId,
    required String setMarketingCloudServerUrl,
    required String setMid,
  }) async {
    await _channel.invokeMethod<void>(
      'initialize',
      {
        'appID': setApplicationId,
        'accessToken': setAccessToken,
        'senderId': setSenderId,
        'appEndpoint': setMarketingCloudServerUrl,
        'mid': setMid
      },
    );
  }

  static Future<bool?> get isPushEnabled async {
    final bool? isEnable = await _channel.invokeMethod('isPushEnabled');
    return isEnable;
  }

  static void get enablePush {
    _channel.invokeMethod<void>('enablePush');
  }

  static void get disablePush {
    _channel.invokeMethod<void>('disablePush');
  }

  static void setMessagingToken(String token) {
    _channel.invokeMethod('setMessagingToken', {
      'token': token,
    });
  }

  static Future<String?> get getMessagingToken async {
    return _channel.invokeMethod('getMessagingToken');
  }

  static Future<Map<Object?, Object?>?> get getAttributes async {
    final Map<Object?, Object?>? attr = await _channel.invokeMethod('getAttributes');
    return attr;
  }

  static void setAttribute({required String? key, required String? value}) {
    _channel.invokeMethod<void>('setAttribute', {'key': key, 'value': value});
  }

  static void clearAttribute({required String? key}) {
    _channel.invokeMethod<void>('clearAttribute', {'key': key});
  }

  static void addTag({required String? tag}) {
    _channel.invokeMethod<void>('addTag', {'tag': tag});
  }

  static void removeTag({required String? tag}) {
    _channel.invokeMethod<void>('removeTag', {'tag': tag});
  }

  static Future<List<String>?> get getTags async {
    final List<String>? tags = await _channel.invokeMethod('getTags');
    return tags;
  }

  static void setContactKey({required String? contactKey}) {
    _channel.invokeMethod<void>('setContactKey', {'contactKey': contactKey});
  }

  static Future<String?> get getContactKey async {
    final String? contactKey = await _channel.invokeMethod<String>('getContactKey');
    return contactKey;
  }

  static void trackCart({
    required String item,
    required int quantity,
    required double value,
    required String uniqueId,
  }) {
    _channel.invokeMethod<void>('trackCart', {
      'item': item,
      'quantity': quantity,
      'value': value,
      'uniqueId': uniqueId,
    });
  }

  static void trackConversion(
      {required String item,
      required int quantity,
      required double value,
      required String uniqueId,
      required String orderNumber,
      required double shipping,
      required double discount}) {
    _channel.invokeMethod<void>('trackConversion', {
      'item': item,
      'quantity': quantity,
      'value': value,
      'uniqueId': uniqueId,
      'orderNumber': orderNumber,
      'shipping': shipping,
      'discount': discount
    });
  }

  static void trackPageViews({
    required String url,
    String title = '',
    String item = '',
    String searchTerms = '',
  }) {
    _channel.invokeMethod<void>(
      'trackPageViews',
      {
        'url': url,
        'title': title,
        'item': item,
        'searchTerms': searchTerms,
      },
    );
  }

  static void logSdkState() {
    _channel.invokeMethod<void>('logSdkState');
  }

  static void handlePushMessage(Map<String, dynamic> message) {
    _channel.invokeMethod<void>('handlePushMessage', {message: message});
  }
}
