import 'package:alarm/alarm.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_p/FamilyRelations/family_relations.dart';
import 'package:flutter_p/NotePage/notepage.dart';
import 'package:flutter_p/Reminders/Reminders.dart';
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

  Widget buildCustomCircleAvatar(double radius, double top, double right) {
    return Positioned(
      top: top,
      right: right,
      child: StreamBuilder<DocumentSnapshot>(
        stream:
            FirebaseFirestore.instance.collection("Users").doc(uid).snapshots(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }
          if (snapshot.hasData) {
            var data = snapshot.data!.data() as Map<String, dynamic>;
            var profileImageUrl = data["profileImage"];
            if (profileImageUrl != null && profileImageUrl.isNotEmpty) {
              return CircleAvatar(
                backgroundColor: Colors.white,
                radius: radius,
                backgroundImage: NetworkImage(profileImageUrl),
              );
            }
          }
          return CircleAvatar(
            backgroundColor: Colors.grey,
            radius: radius,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    CollectionReference UsersRef = _firestore.collection("Users");
    var Docref = UsersRef.doc(uid);
    return SafeArea(
      child: Scaffold(
        appBar: MyAppBar(
          title: 'AlzHelper',
          actions: [],
        ),
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
                      return Column(
                        children: [
                          Text(
                            firstNameRef + " " + lastNameRef,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          StreamBuilder<DocumentSnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection("Users")
                                .doc(uid)
                                .snapshots(),
                            builder: (BuildContext context,
                                AsyncSnapshot<DocumentSnapshot> snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const CircularProgressIndicator();
                              }
                              if (snapshot.hasData) {
                                var data = snapshot.data!.data()
                                    as Map<String, dynamic>;
                                var description = data["description"];
                                return Text(
                                  description != null && description.isNotEmpty
                                      ? description
                                      : "Bu kısmı profilden düzenleyebilirsiniz",
                                  style: const TextStyle(fontSize: 16),
                                );
                              }
                              return const Text(
                                "Veri Bulunamadı",
                                style: TextStyle(fontSize: 16),
                              );
                            },
                          ),
                        ],
                      );
                    }
                  }
                  return const Text(
                    "Veri Bulunamadı",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
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
                          builder: (context) => family_relations(),
                        ),
                      );
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
                    final familyRelations = snapshot.data!.docs;
                    if (familyRelations.isEmpty) {
                      return SizedBox(
                        height: 60, // İstediğiniz yükseklik değeri
                        child: Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 8.0, right: 4.0),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => family_relations(),
                                    ),
                                  );
                                },
                                child: CircleAvatar(
                                  backgroundColor: Colors.grey,
                                  radius: 30,
                                  child: Icon(
                                    Icons.add,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    } else {
                      return SizedBox(
                        height: 60, // İstediğiniz yükseklik değeri
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: familyRelations.length,
                          itemBuilder: (BuildContext context, int index) {
                            final imageUrl =
                                familyRelations[index]["relationsImage"];
                            return Padding(
                              padding: EdgeInsets.only(
                                left: index == 0
                                    ? 8.0
                                    : 4.0, // İlk daire için sol boşluk, diğerleri için aralık
                                right: 4.0, // Sağ boşluk
                              ),
                              child: CircleAvatar(
                                backgroundImage: NetworkImage(imageUrl),
                                radius: 30,
                              ),
                            );
                          },
                        ),
                      );
                    }
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
                                    style: TextStyle(fontSize: 15),
                                  ),
                                )
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  SizedBox(width: 16.0), // Add spacing between the buttons
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        /*String? token =
                                await FirebaseMessaging.instance.getToken();
                            print(token);*/
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Reminders(),
                          ),
                        );
                      },
                      child: Column(
                        children: [
                          InkWell(
                            child: NotesWidget(
                              child: Text(
                                "Henüz hatırlatıcı eklemediniz",
                                style: TextStyle(fontSize: 15),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
