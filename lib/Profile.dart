import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_p/Login-Register/first_screen.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Column(
            children: [
              TextButton(onPressed: signOut, child: Text("çıkış yap"))
            ],
          ),
        ),
      ),
    );
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      print('User signed out');
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => first_screen()));
    } catch (e) {
      print('Sign out failed: $e');
    }
  }
}
