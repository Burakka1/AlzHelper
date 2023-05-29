import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_p/Classes.dart';

class NoteEditorScreen extends StatefulWidget {
  const NoteEditorScreen({Key? key}) : super(key: key);

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  String date = DateTime.now().toString();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _mainController = TextEditingController();
  late String noteId; // Notun kimlik değerini saklamak için değişken

  void addNoteToMatchingUsers(String noteContent, String noteId) async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid)
          .get();

      String patientID = userSnapshot.get('patientID');

      QuerySnapshot matchingUsersSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .where('patientID', isEqualTo: patientID)
          .get();

      matchingUsersSnapshot.docs.forEach((doc) {
        String userID = doc.id;

        // Kendi kullanıcısını ekleme
        if (userID != user.uid) {
          FirebaseFirestore.instance
              .collection('Users')
              .doc(userID)
              .collection('Notes')
              .doc(noteId) // Aynı ID'yi kullanarak notu güncelleme
              .set({
            "note_title": _titleController.text,
            "creation_date": date,
            "note_content": noteContent,
          });
        }
      });
    }
  }

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Yeni Note Ekle"),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                    border: InputBorder.none, hintText: "Note Başlığı"),
                style: CardTextStyle.mainTitle,
              ),
              const SizedBox(
                height: 8.0,
              ),
              Text(
                date,
                style: CardTextStyle.dateTitle,
              ),
              const SizedBox(
                height: 28.0,
              ),
              TextField(
                controller: _mainController,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration: const InputDecoration(
                    border: InputBorder.none, hintText: "Not yazmaya başlayın"),
                style: CardTextStyle.mainContent,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
            onPressed: () async {
              String uid = FirebaseAuth.instance.currentUser!.uid;
              String noteContent = _mainController.text;

              // Notu kullanıcının kendi notları koleksiyonuna ekle
              DocumentReference noteRef = FirebaseFirestore.instance
                  .collection("Users")
                  .doc(uid)
                  .collection("Notes")
                  .doc(); // Benzersiz bir kimlik değeri oluştur
              noteId = noteRef.id; // Notun kimlik değerini sakla

              noteRef.set({
                "note_title": _titleController.text,
                "creation_date": date,
                "note_content": noteContent,
              }).then((_) {
                // Eşleşen kullanıcılara notu ekle
                addNoteToMatchingUsers(noteContent, noteId);

                Navigator.pop(context);
              }).catchError((error) => print("$error"));
            },
            child: const Icon(Icons.save),
          ),
        
    
    );
  }
}