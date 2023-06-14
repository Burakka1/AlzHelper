import 'dart:async';
import 'dart:convert';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_p/UI/patient_relative_home.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Home.dart';
import '../Location/location_permission.dart';
import '../Profilepage/Profile.dart';
import 'package:http/http.dart' as http;

class Navbar extends StatefulWidget {
  const Navbar({Key? key}) : super(key: key);

  @override
  _NavbarState createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> {
  late Timer _timer;
  bool _isSendingLocation = false;
  int maxDataCount = 10;

  Future<void> _sendLocationToFirebase() async {
    try {
      Position position = await getCurrentLocation();
      await saveLocationToFirebase(position);
      await _limitDataCount();
    } catch (e) {
      print('Hata: $e');
    }
  }

  Future<void> saveLocationToFirebase(Position position) async {
    String uid = FirebaseAuth.instance.currentUser!.uid;

    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference konumlarRef =
        firestore.collection('Users').doc(uid).collection("Locations");
    DateTime currentTime = DateTime.now();

    await konumlarRef.add({
      'latitude': position.latitude,
      'longitude': position.longitude,
      'time': currentTime,
    });
  }

  Future<void> _limitDataCount() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;

    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference konumlarRef =
        firestore.collection('Users').doc(uid).collection("Locations");

    QuerySnapshot snapshot =
        await konumlarRef.orderBy('time', descending: true).get();

    List<QueryDocumentSnapshot> documents = snapshot.docs;

    if (documents.length > maxDataCount) {
      List<QueryDocumentSnapshot> deleteDocuments =
          documents.sublist(maxDataCount);

      for (var document in deleteDocuments) {
        await konumlarRef.doc(document.id).delete();
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _startSendingLocation();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      String? title = message.notification!.title;
      String? body = message.notification!.body;
      AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 123,
          channelKey: 'noti',
          color: Colors.white,
          title: title,
          body: body,
          category: NotificationCategory.Call,
          wakeUpScreen: true,
          fullScreenIntent: true,
          autoDismissible: false,
          backgroundColor: Colors.orange,
        ),
        actionButtons: [
          NotificationActionButton(
            key: 'ACCEPT',
            label: 'Anlaşıldı',
            color: Colors.green,
            autoDismissible: true,
          ),
        ],
      );
      AwesomeNotifications().actionStream.listen((event) {
        if (event.buttonKeyPressed == 'REJECT') {
          print('Call Reject');
        } else if (event.buttonKeyPressed == 'ACCEPT') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => patient_relative_home()),
          );
        } else {
          print('Clicked on Notification');
        }
      });
    });
  }

  void _startSendingLocation() {
    // Konum gönderme işlemini başlat.
    _sendLocationToFirebase(); // İlk konum gönderimi yap
    _timer = Timer.periodic(
      Duration(seconds: 10),
      (Timer t) => _sendLocationToFirebase(),
    );
    setState(() {
      _isSendingLocation = true;
    });
  }

  @override
  void dispose() {
    super.dispose();
    // Timer'ı iptal et.
    _timer.cancel();
  }

  int currentTab = 0;
  final List<Widget> screens = [
    const Home(),
    const Profile(),
  ];
  final PageStorageBucket bucket = PageStorageBucket();
  Widget currentScreen = const Home();

  @override
  Widget build(BuildContext context) {
    return navbar();
  }

  Scaffold navbar() {
  return Scaffold(
    body: PageStorage(
      child: currentScreen,
      bucket: bucket,
    ),
    floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    bottomNavigationBar: BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.grey.shade800,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.grey,
      selectedFontSize: 12,
      unselectedFontSize: 12,
      currentIndex: currentTab,
      onTap: (index) {
        setState(() {
          currentTab = index;
          currentScreen = screens[currentTab];
        });
      },
      items: [
        BottomNavigationBarItem(
          icon: Icon(
            Icons.home_outlined,
            size: 35,
          ),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.person_outlined,
            size: 35,
          ),
          label: 'Profile',
        ),
      ],
    ),
    floatingActionButton: Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.red,
        border: Border.all(color: Colors.grey.shade800,width: 6),
      ),
      child: FloatingActionButton(
        backgroundColor: Colors.transparent,
        child: const Icon(
          Icons.notifications,
          color: Colors.black,
        ),
        onPressed: () {
          sendPushNotification();
        },
      ),
    ),
  );
}


  Future<void> sendPushNotification() async {
    try {
      http.Response response = await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization':
              'key=AAAA-DKR914:APA91bHaOoKB1oXJ2EP7JcLsrlFGMGmWaIrZCTGVfJTv8Hubi4A22cu8ygc-cfDYTuCQbuqzOPb1gA0wiQ1YmusPNKu4k9RY7g7JGJbkRjHPE3BbJecoonLh-PS7qD1UWG5wHxEEbHnX',
        },
        body: jsonEncode(
          <String, dynamic>{
            'notification': <String, dynamic>{
              'body': 'Acil durum',
              'title': 'Ulaşım sağlayın',
            },
            'priority': 'high',
            'data': <String, dynamic>{
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'id': '1',
              'status': 'done',
            },
            'to':
                'ehDPwhWRQRywzoCuP3xhGV:APA91bGBFZmGqz-1MnPgh6BckMPjfSW-8dHlhm4pRLR3mpQaq-_RP4GfMyeK_0HPR3WWQJ5sCvLnffiW5LNqoW6FleczGcqsGjUfikLGq9uUcbBpJWEdoVWyv6e2lsd9QRDGM3flaKmw',
          },
        ),
      );
      response;
    } catch (e) {
      e;
    }
  }
}