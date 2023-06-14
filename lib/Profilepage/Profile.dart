import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
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
        appBar: MyAppBar(title: 'AlzHelper', actions: [],),
        body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: _profileStream,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final profileData = snapshot.data!.data();
              String _profileImage = profileData?['profileImage'] ?? '';

              return Center(
                child: Column(
                  children: [
                    const SizedBox(
                      height: 40,
                    ),
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: _profileImage.isNotEmpty
                          ? NetworkImage(_profileImage)
                          : null,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      child: const Divider(),
                    ),
                    Text(
                      " ${profileData?['description'] ?? 'Belirtilmedi'}",
                      style: const TextStyle(fontSize: 16),
                    ),
                    Container(
                      child: const Divider(),
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
                                 " ${profileData?['firstName'] ?? 'Belirtilmedi'}",
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
                                " ${profileData?['lastName'] ?? 'Belirtilmedi'}",
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
                                " ${profileData?['age'] ?? 'Belirtilmedi'}",
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
                                " ${profileData?['phoneNumber'] ?? 'Belirtilmedi'}",
                                style: const TextStyle(fontSize: 16),
                              )
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              const Text(
                                "Kan Grubu: ",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              Text(
                                " ${profileData?['bloodGroup'] ?? 'Belirtilmedi'}",
                                style: const TextStyle(fontSize: 16),
                              )
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              const Text(
                                "Hasta ID:",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                                    
                              ),
                              Flexible(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: GestureDetector(
                                    onTap: () {
                                      Clipboard.setData(
                                        ClipboardData(text: "${profileData?['patientID']}"),
                                      );
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: const Text("Patient ID kopyalandı")),
                                      );
                                    },
                                    child: Text(
                                      "${profileData?['patientID']}",
                                      style: const TextStyle(fontSize: 16),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.content_copy),
                                onPressed: () {
                                  Clipboard.setData(
                                    ClipboardData(text: "${profileData?['patientID']}"),
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: const Text("Patient ID kopyalandı")),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      child: const Divider(),
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
                child: const Text('Veriler çekilirken bir hata oluştu.'),
              );
            } else {
              return Center(
                child: const CircularProgressIndicator(),
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