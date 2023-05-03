//import 'dart:html';
import 'package:flutter/material.dart';
import 'package:flutter_p/FamilyRelations.dart';
import 'package:flutter_p/Navbar.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_p/Reminders.dart';
import 'package:flutter_p/NotePage/notepage.dart';
import 'firebase_options.dart';

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
      home: const NotePage(),
    );
  }
}
