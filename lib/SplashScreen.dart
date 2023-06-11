import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'Login-Register/first_screen.dart';
import 'Login-Register/login.dart';
import 'Login-Register/register_choice.dart';
import 'UI/Navbar.dart';
import 'UI/patient_relative_navbar.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
 late Timer _timer;
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();
    _timer = Timer(Duration(seconds: 5), () {
      checkLoggedInStatus();
    });

    // Fade efektini başlatmak için Timer kullabilirsiniz
    Timer(Duration(seconds: 3), () {
      setState(() {
        _opacity = 1.0;
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel(); // Timer'ı iptal et
    super.dispose();
  }

  void checkLoggedInStatus() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await redirectUser(user.uid);
    } else {
      navigateToFirstScreen();
    }
  }

  Future<void> redirectUser(String userId) async {
    DocumentSnapshot snapshot =
        await FirebaseFirestore.instance.collection('Users').doc(userId).get();

    String userType = snapshot['userType'];

    if (userType == 'patient') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Navbar()),
      );
    } else if (userType == 'patient_relative') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Navbar1()),
      );
    } else {
      print('Geçersiz kullanıcı türü');
      navigateToFirstScreen();
    }
  }

  void navigateToFirstScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => first_screen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedOpacity(
              opacity: _opacity,
              duration: Duration(seconds: 2),
              curve: Curves.easeIn,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/AlzhelperLogo.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}