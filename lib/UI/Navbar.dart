import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import 'Home.dart';
import '../Location/location_permission.dart';
import '../Profile.dart';

class Navbar extends StatefulWidget {
  const Navbar({Key? key}) : super(key: key);

  @override
  _NavbarState createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> {
  late Timer _timer;
  bool _isSendingLocation = false;

  Future<void> _sendLocationToFirebase() async {
    try {
      Position position = await getCurrentLocation();
      await saveLocationToFirebase(position);
    } catch (e) {
      print('Hata: $e');
    }
  }

  void _startSendingLocation() {
    // Konum gönderme işlemini başlat.
    _timer = Timer.periodic(
        Duration(minutes: 1), (Timer t) => _sendLocationToFirebase());
    setState(() {
      _isSendingLocation = true;
    });
  }

  void _stopSendingLocation() {
    // Konum gönderme işlemini durdur.
    _timer.cancel();
    setState(() {
      _isSendingLocation = false;
    });
  }

  @override
  void dispose() {
    super.dispose();
    // Timer'ı iptal et.
    _timer?.cancel();
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        child: const Icon(
          Icons.warning_amber_sharp,
          color: Colors.black,
        ),
        onPressed:
            _isSendingLocation ? _stopSendingLocation : _startSendingLocation,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: Colors.grey.shade800,
        shape: const CircularNotchedRectangle(),
        notchMargin: 10,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  MaterialButton(
                    minWidth: 40,
                    onPressed: () {
                      setState(() {
                        currentScreen = const Home();
                        currentTab = 0;
                      });
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.home_outlined,
                          size: 35,
                          color: currentTab == 0 ? Colors.white : Colors.grey,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  MaterialButton(
                    minWidth: 40,
                    onPressed: () {
                      setState(() {
                        currentScreen = const Profile();
                        currentTab = 1;
                      });
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.person_outlined,
                          size: 35,
                          color: currentTab == 1 ? Colors.white : Colors.grey,
                        ),
                      ],
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
