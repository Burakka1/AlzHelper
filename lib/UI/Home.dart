import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_p/FamilyRelations/family_relations.dart';
import 'package:flutter_p/NotePage/notepage.dart';
import '../Classes.dart';
import '../NotePage/note_reader.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String uid = FirebaseAuth.instance.currentUser!.uid;
  final _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    CollectionReference UsersRef = _firestore.collection("Users");
    var Docref = UsersRef.doc(uid);
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              buildCustomCircleAvatar(50, 20, 8),
              Container(
                child: customDivider(),
              ),
              StreamBuilder<DocumentSnapshot>(
                  stream: Docref.snapshots(),
                  builder: (BuildContext context, AsyncSnapshot asyncSnapshot) {
                    if (asyncSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }
                    if (asyncSnapshot.hasData) {
                      var firstNameRef = asyncSnapshot.data.data()["firstName"];
                      var lastNameRef = asyncSnapshot.data.data()["lastName"];
                      if (firstNameRef != null && lastNameRef != null) {
                        return Text(
                          firstNameRef + " " + lastNameRef,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        );
                      }
                    }
                    return Text("Veri Bulunamadı",
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold));
                  }),
              const SizedBox(height: 5),
              const Text(
                'Hasta hakkında kısa bir özyazı',
                style: TextStyle(fontSize: 16),
              ),
              Container(
                child: customDivider(),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Text(
                      'Aile Yakınları',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => family_relations()));
                    },
                    child: const Text(
                      'Tümünü Gör',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ),
                ],
              ),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("Users")
                    .doc(uid)
                    .collection("FamilyRelations")
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (snapshot.hasData) {
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment.start, // Resimleri sola hizalar
                        children: snapshot.data!.docs.map((doc) {
                          final imageUrl = doc["relationsImage"];
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: CircleAvatar(
                              backgroundImage: NetworkImage(imageUrl),
                              radius: 30,
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  }
                  return const Text("Veri bulunamadı");
                },
              ),
              Container(
                child: customDivider(),
              ),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Text(
                      'Kartlar',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      width: 180,
                      height: 200,
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection("Users")
                            .doc(uid)
                            .collection("Notes")
                            .snapshots(),
                        builder:
                            (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          if (snapshot.hasData &&
                              snapshot.data!.docs.isNotEmpty) {
                            final reversedDocs =
                                snapshot.data!.docs.reversed.toList();
                            final note = reversedDocs.first;
                            return noteCard(() {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const NotePage(),
                                ),
                              );
                            }, note);
                          }
                          return InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => NotePage()));
                            },
                            child: Column(
                              children: [
                                NotesWidget(
                                  child: Text(
                                    "Henüz not eklemediniz",
                                    style: TextStyle(fontSize: 18),
                                  ),
                                )
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () async {
                      String? token =
                          await FirebaseMessaging.instance.getToken();
                      print(token);
                    },
                    child: SizedBox(
                      height: 200,
                      width: 180,
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
