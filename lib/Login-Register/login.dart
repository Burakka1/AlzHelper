import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_p/UI/Home.dart';
import 'package:flutter_p/UI/Navbar.dart';
import 'package:flutter_p/Services/auth.dart';
import 'package:flutter_p/UI/patient_relative_home.dart';
import 'package:flutter_p/UI/patient_relative_navbar.dart';

import '../Classes.dart';

class patient_login extends StatefulWidget {
  const patient_login({Key? key}) : super(key: key);

  @override
  State<patient_login> createState() => _patient_loginState();
}

class _patient_loginState extends State<patient_login> {
 final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  AuthService _authService = AuthService();
  String _errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        title: 'AlzHelper',
        actions: [],
        showBackButton: true,
      ),
      backgroundColor: Colors.grey[300],
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                SizedBox(height: 20),
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: AssetImage('assets/images/AlzhelperLogo.png'),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Şifre',
                  ),
                  obscureText: true,
                ),
                SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      String email = _emailController.text.trim();
                      String password = _passwordController.text.trim();

                      if (email.isEmpty || password.isEmpty) {
                        setState(() {
                          _errorMessage = 'Email veya şifre boş bırakılamaz.';
                        });
                      } else {
                        _authService.signIn(email, password).then((user) {
                          if (user != null) {
                            redirectUser(user.uid);
                          }
                        }).catchError((error) {
                          String errorMessage = error.toString();
                          if (errorMessage.startsWith('Exception: ')) {
                            errorMessage =
                                errorMessage.substring('Exception: '.length);
                          }
                          setState(() {
                            _errorMessage = errorMessage;
                          });
                        });
                      }
                    },
                    child: Text(
                      'Giriş Yap',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
                if (_errorMessage.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      _errorMessage,
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void redirectUser(String userId) async {
    // Firebase Firestore ile kullanıcının verilerini çekin
    DocumentSnapshot snapshot =
        await FirebaseFirestore.instance.collection('Users').doc(userId).get();

    // Kullanıcı türünü alın
    String userType = snapshot['userType'];

    // Kullanıcı türüne göre yönlendirme yapın
    if (userType == 'patient') {
      // Kullanıcı türü A ise A sayfasına yönlendirin
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Navbar()),
      );
    } else if (userType == 'patient_relative') {
      // Kullanıcı türü B ise B sayfasına yönlendirin
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Navbar1()),
      );
    } else {
      // Geçersiz kullanıcı türü
      print('Geçersiz kullanıcı türü');
    }
  }
}
