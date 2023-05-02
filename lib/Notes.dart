import 'package:flutter/material.dart';
import 'Classes.dart';
import 'Home.dart';
import 'Profile.dart';

class Notes extends StatelessWidget {
  const Notes({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Notes')),
      body:  Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                NotesWidget(child: Text('Note 1')),
                NotesWidget(child: Text('Note 1')),
              ],
            ),
            Row(
              children: [
                NotesWidget(child: Text('Note 1')),
              ],
            )
          ],
        ),
      ),
    );
  }
}

