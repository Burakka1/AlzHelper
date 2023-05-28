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
          FirebaseFirestore.instance
              .collection("Users")
              .doc(uid)
              .collection("Notes")
              .add({
            "note_title": _titleController.text,
            "creation_date": date,
            "note_content": _mainController.text,
          }).then((value) {
            print(value.id);
            Navigator.pop(context);
          }).catchError((error) => print("$error"));
        },
        child: const Icon(Icons.save),
      ),
    );
  }
}
