import 'package:alarm/alarm.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_p/Login-Register/first_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_p/SplashScreen.dart';
import 'Services/firebase_options.dart';

Future<void> backgroundHandler(RemoteMessage message) async {}

void main() async {
  AwesomeNotifications().initialize(null, [
    NotificationChannel(
      channelKey: "noti",
      channelName: "noti warning",
      channelDescription: "noti of warning",
      defaultColor: Colors.redAccent,
      ledColor: Colors.white,
      importance: NotificationImportance.Max,
      channelShowBadge: true,
      locked: true,
      defaultRingtoneType: DefaultRingtoneType.Ringtone,
      //soundSource: "asset://assets/sounds/ses.mp3",
    )
  ]);
  FirebaseMessaging.onBackgroundMessage(backgroundHandler);
SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  await Alarm.init(showDebugLogs: true);

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SplashScreen(),
    );
  }
}
