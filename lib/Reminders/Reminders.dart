import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_p/Classes.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class Reminders extends StatefulWidget {
  const Reminders({Key? key}) : super(key: key);

  @override
  State<Reminders> createState() => _RemindersState();
}

class _RemindersState extends State<Reminders> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _imagePicker = ImagePicker();

  List<Alarm> alarms = [];

  @override
  void initState() {
    super.initState();
    loadAlarms();
  }

  Future<void> loadAlarms() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      QuerySnapshot remindersSnapshot = await _firestore
          .collection('Users')
          .doc(user.uid)
          .collection('Reminders')
          .get();

      List<Alarm> loadedAlarms = remindersSnapshot.docs
          .map((doc) => Alarm.fromSnapshot(doc))
          .toList();

      setState(() {
        alarms = loadedAlarms;
      });
    }
  }

  Future<void> addAlarm(String alarmName, TimeOfDay alarmClock, File image) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userData =
          await _firestore.collection('Users').doc(user.uid).get();
      String patientID = userData['patientID'];

      String alarmImagePath = await uploadImage(image);

      QuerySnapshot remindersSnapshot = await _firestore
          .collection('Users')
          .where('patientID', isEqualTo: patientID)
          .get();

      for (DocumentSnapshot doc in remindersSnapshot.docs) {
        DateTime alarmDateTime = DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
          alarmClock.hour,
          alarmClock.minute,
        );

        bool isOpen = !DateTime.now().isAfter(alarmDateTime);

        await doc.reference.collection('Reminders').add({
          'alarmName': alarmName,
          'alarmClock': alarmClock.format(context),
          'alarmImage': alarmImagePath,
          'isOpen': isOpen,
        });
      }

      loadAlarms();
    }
  }

  Future<String> uploadImage(File image) async {
    String imagePath = 'alarm_images/${DateTime.now().millisecondsSinceEpoch}.jpg';
    await _storage.ref(imagePath).putFile(image);
    String imageUrl = await _storage.ref(imagePath).getDownloadURL();
    return imageUrl;
  }

  Future<File?> pickImageFromGallery() async {
    final pickedImage = await _imagePicker.pickImage(source: ImageSource.gallery);
    return pickedImage != null ? File(pickedImage.path) : null;
  }

  Future<File?> pickImageFromCamera() async {
    final pickedImage = await _imagePicker.pickImage(source: ImageSource.camera);
    return pickedImage != null ? File(pickedImage.path) : null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     appBar: MyAppBar(
        title: 'AlzHelper',
        actions: [],
        showBackButton: true,
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16.0),
        itemCount: alarms.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              // Alarma tıklama işlemleri
            },
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Image.network(
                      alarms[index].alarmImage,
                      height: 80.0,
                      width: 80.0,
                      fit: BoxFit.cover,
                    ),
                    SizedBox(width: 16.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            alarms[index].alarmName,
                            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 4.0),
                          Text(
                            alarms[index].alarmClock,
                            style: TextStyle(fontSize: 14.0, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: alarms[index].isOpen, // Alarm durumu
                      onChanged: (value) {
                        setState(() {
                          alarms[index].isOpen = value; // Alarm durumunu güncelle
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          String? alarmName = await showDialog<String>(
            context: context,
            builder: (context) {
              TextEditingController nameController = TextEditingController();
              return AlertDialog(
                title: Text('Add Alarm'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Alarm Name',
                      ),
                    ),
                    SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: () async {
                        File? image = await showDialog<File>(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text('Select Image Source'),
                              content: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  IconButton(
                                    onPressed: () async {
                                      Navigator.of(context).pop(await pickImageFromGallery());
                                    },
                                    icon: Icon(Icons.photo_library),
                                  ),
                                  IconButton(
                                    onPressed: () async {
                                      Navigator.of(context).pop(await pickImageFromCamera());
                                    },
                                    icon: Icon(Icons.camera_alt),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                        Navigator.of(context).pop(nameController.text);
                        if (image != null) {
                          TimeOfDay? selectedTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (selectedTime != null) {
                            addAlarm(nameController.text, selectedTime, image);
                          }
                        }
                      },
                      child: Text('Select Image'),
                    ),
                  ],
                ),
              );
            },
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class Alarm {
  final String alarmName;
  final String alarmClock;
  final String alarmImage;
  bool isOpen; // Alarm durumu

  Alarm({
    required this.alarmName,
    required this.alarmClock,
    required this.alarmImage,
    required this.isOpen,
  });

  factory Alarm.fromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    return Alarm(
      alarmName: data['alarmName'],
      alarmClock: data['alarmClock'],
      alarmImage: data['alarmImage'],
      isOpen: data['isOpen'],
    );
  }
}
