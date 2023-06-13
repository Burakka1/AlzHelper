import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_p/Classes.dart';
import 'package:flutter_p/Login-Register/first_screen.dart';
import 'package:flutter_p/Profilepage/editprofile.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Stream<DocumentSnapshot<Map<String, dynamic>>>? _profileStream;

  @override
  void initState() {
    super.initState();
    // Verileri çekmek için Firestore stream'ini başlatın
    String uid = _auth.currentUser!.uid;
    _profileStream =
        FirebaseFirestore.instance.collection('Users').doc(uid).snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Profil"),
        ),
        body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: _profileStream,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final profileData = snapshot.data!.data();
              late String _profileImage;
              _profileImage = profileData?['profileImage'] ?? '';

              return Center(
                child: Column(
                  children: [
                    const SizedBox(
                      height: 40,
                    ),
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(_profileImage),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      child: customDivider(),
                    ),
                    Text(
                      "${profileData?['description']}",
                      style: TextStyle(fontSize: 16),
                    ),
                    Container(
                      child: customDivider(),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Bilgilerim",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: ((context) => AddPatientPage()),
                                ),
                              );
                            },
                            icon: const Icon(Icons.edit_note_outlined),
                            label: const Text(
                              "Düzenle",
                              style:
                                  TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Text(
                                "İsim:",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              Text(
                                " ${profileData?['firstName']}",
                                style: const TextStyle(fontSize: 16),
                              )
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              Text(
                                "Soyisim:",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              Text(
                                "  ${profileData?['lastName']}",
                                style: const TextStyle(fontSize: 16),
                              )
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              Text(
                                "Yaş: ",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              Text(
                                "  ${profileData?['age']}",
                                style: const TextStyle(fontSize: 16),
                              )
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              Text(
                                "Telefon No: ",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              Text(
                                "  ${profileData?['phoneNumber']}",
                                style: const TextStyle(fontSize: 16),
                              )
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              Text(
                                "Kan Grubu: ",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              Text(
                                "  ${profileData?['bloodGroup']}",
                                style: const TextStyle(fontSize: 16),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      child: customDivider(),
                    ),
                    TextButton(
                      onPressed: signOut,
                      child: const Text("Çıkış Yap"),
                    ),
                  ],
                ),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Veriler çekilirken bir hata oluştu.'),
              );
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      ),
    );
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      print('User signed out');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => first_screen(),
        ),
      );
    } catch (e) {
      print('Sign out failed: $e');
    }
  }
}
