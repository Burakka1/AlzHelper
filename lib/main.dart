//import 'dart:html';
import 'package:flutter/material.dart';
import 'package:flutter_p/FamilyRelations/FamilyRelations.dart';
import 'package:flutter_p/UI/Home.dart';
import 'package:flutter_p/Login-Register/first_screen.dart';
import 'package:flutter_p/UI/Navbar.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_p/Reminders.dart';
import 'package:flutter_p/NotePage/notepage.dart';
import 'Services/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: first_screen(),
    );
  }
}
