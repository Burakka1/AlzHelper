import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<User?> signIn(String email, String password) async {
    try {
      var user = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return user.user;
    } catch (error) {
      throw Exception('Email veya şifre hatalı.');
    }
  }

  signOut() async {
    return await _auth.signOut();
  }

  Future<User?> createPatient(
    String first_name,
    String last_name,
    String email,
    String password,
    int phone_number,
  ) async {
    try {
      var user = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      await _firestore.collection("Patient").doc(user.user?.uid).set({
        'first_name': first_name,
        'last_name': last_name,
        'email': email,
        'password': password,
        'phone_number': phone_number
      });
      return user.user;
    } catch (error) {
      throw Exception('Hesap oluşturulurken bir hata oluştu.');
    }
  }

  signInWithEmailAndPassword(String email, String password) {}

  Stream<User?> authStateChanges() {
    return _auth.authStateChanges();
  }
}
