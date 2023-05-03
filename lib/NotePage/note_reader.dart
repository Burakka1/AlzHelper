import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../Classes.dart';

class NoteReaderScreen extends StatefulWidget {
  NoteReaderScreen(this.doc, {Key? key}) : super(key: key);
  QueryDocumentSnapshot doc;
  @override
  State<NoteReaderScreen> createState() => _NoteReaderScreenState();
}

class _NoteReaderScreenState extends State<NoteReaderScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
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
