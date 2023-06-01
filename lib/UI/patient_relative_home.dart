import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_p/Reminders/Reminders.dart';
import '../Classes.dart';
import '../NotePage/notepage.dart';
import 'package:flutter/material.dart';

class patient_relative_home extends StatefulWidget {
  const patient_relative_home({Key? key}) : super(key: key);

  @override
  State<patient_relative_home> createState() => _patient_relative_homeState();
}

class _patient_relative_homeState extends State<patient_relative_home> {
  String uid = FirebaseAuth.instance.currentUser!.uid;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Center(
              child: buildCustomCircleAvatar(120, 50, 20),
            ),
            Container(
              child: customDivider(),
            ),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Users')
                  .doc(uid)
                  .collection('Locations')
                  .orderBy('time', descending: true)
                  .limit(2)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Veri alınamadı');
                } else if (!snapshot.hasData) {
                  return Text('Veri bulunamadı');
                } else {
                  QuerySnapshot locationSnapshot = snapshot.data!;
                  List<QueryDocumentSnapshot> locationDocuments =
                      locationSnapshot.docs;

                  List<Widget> locationTextWidgets =
                      locationDocuments.map((doc) {
                    double latitude = doc.get('latitude');
                    double longitude = doc.get('longitude');
                    return Text(
                      '$latitude, $longitude',
                      style: TextStyle(fontSize: 18),
                    );
                  }).toList();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: locationTextWidgets,
                  );
                }
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text(
                    'Kartlar',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                Expanded(
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Reminders(),
                        ),
                      );
                    },
                    child: Column(
                      children: [
                        NotesWidget(
                          child: Text(
                            "Henüz hatırlatıcı eklemediniz",
                            style: TextStyle(fontSize: 18),
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
    );
  }
}
