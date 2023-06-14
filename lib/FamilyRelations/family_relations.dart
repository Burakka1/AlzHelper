import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_p/Classes.dart';
import 'package:flutter_p/FamilyRelations/family_relations_editor.dart';
import 'package:flutter_p/UI/Home.dart';
import 'package:flutter_p/UI/Navbar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';
import '../NotePage/note_reader.dart';

class family_relations extends StatefulWidget {
  const family_relations({Key? key}) : super(key: key);

  @override
  State<family_relations> createState() => _family_relationsState();
}

class _family_relationsState extends State<family_relations> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String uid = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        title: const Text("Aile Yakınları"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 10.0,
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
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
                    return GridView(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 3/4,
                        crossAxisSpacing: 16.0,
                      ),
                      children: snapshot.data!.docs.map(
                        (note) {
                          return Stack(
                            children: [
                              familyRelationsCard(() {}, note, uid),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: GestureDetector(
                                  onTap: () {
                                    // Silme işlemini burada gerçekleştirin
                                    _firestore
                                        .collection("Users")
                                        .doc(uid)
                                        .collection("FamilyRelations")
                                        .doc(note.id)
                                        .delete();
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ).toList(),
                    );
                  }
                  return const Text("Henüz eklemediniz");
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FamilyRelationsEditor(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text("Oluştur"),
      ),
    );
  }
}
