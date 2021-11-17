import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:marketingcloudsf/marketingcloudsf.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var _platformVersion = 'Unknown';

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    await Firebase.initializeApp();
    Marketingcloudsf.init(
      setMid: "514004931",
      setAccessToken: "anUXpGCK7XS1c7stu3MDgFtj",
      setSenderId: Firebase.apps.first.options.messagingSenderId,
      setApplicationId: "df86f5e7-8429-4440-aec6-433528ff4cd5",
      setMarketingCloudServerUrl:
          "https://mcztx763gcky9vn2thhbc1h1p16m.device.marketingcloudapis.com/",
    );

    // FirebaseMessaging.instance.getToken().then((value) async {
    //   if (value != null) {
    //     // Marketingcloudsf.setMessagingToken(value);
    //     Marketingcloudsf.setContactKey(contactKey: 'n2b_$value');
    //   }
    // });
    //
    // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    //   print('Got a message whilst in the foreground!');
    //   print('Message data: ${message.data}');
    //
    //   if (message.notification != null) {
    //     print('Message also contained a notification: ${message.notification}');
    //   }
    // });
    // //
    // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            children: [
              Text('Running on: $_platformVersion\n'),
              ElevatedButton(
                onPressed: () async {
                  final token = await Marketingcloudsf.getMessagingToken;
                  print(token);
                  Marketingcloudsf.logSdkState();
                },
                child: Text('teste'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
