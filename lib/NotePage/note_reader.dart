import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../Classes.dart';

class NoteReaderScreen extends StatefulWidget {
  NoteReaderScreen(this.doc, {Key? key}) : super(key: key);
  final QueryDocumentSnapshot doc;

  @override
  State<NoteReaderScreen> createState() => _NoteReaderScreenState();
}

class _NoteReaderScreenState extends State<NoteReaderScreen> {
  Future<void> deleteNote() async {
    String noteId = widget.doc.id;
    User? user = FirebaseAuth.instance.currentUser;
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(user?.uid)
          .get();
    String patientID = userSnapshot.get('patientID');

    // Aynı patientID'ye sahip kullanıcıları getir ve notlarını sil
    FirebaseFirestore.instance
        .collection('Users')
        .where('patientID', isEqualTo: patientID)
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((userDoc) {
        String userId = userDoc.id;
        FirebaseFirestore.instance
            .collection('Users')
            .doc(userId)
            .collection('Notes')
            .doc(noteId)
            .delete();
      });
      print('Notlar silindi');
      Navigator.pop(context);
    }).catchError((error) {
      print('Notlar silinirken hata oluştu: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        title: 'AlzHelper',
        actions: [IconButton(
            onPressed: deleteNote,
            icon: Icon(Icons.delete,color: Colors.red,),
          ),],
        showBackButton: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.doc["note_title"],
              style: CardTextStyle.mainTitle,
            ),
            const SizedBox(
              height: 4,
            ),
            const Divider(
              height: 10,
              thickness: 2,
              color: AllColors.black,
            ),
            const SizedBox(
              height: 4,
            ),
            Text(
              widget.doc["creation_date"],
              style: CardTextStyle.dateTitle,
            ),
            const SizedBox(
              height: 10,
            ),
            const Divider(
              height: 10,
              thickness: 2,
              color: AllColors.black,
            ),
            const SizedBox(
              height: 20,
            ),
            Text(
              widget.doc["note_content"],
              style: CardTextStyle.mainContent,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

