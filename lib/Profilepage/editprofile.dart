import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AddPatientPage extends StatefulWidget {
  const AddPatientPage({Key? key}) : super(key: key);

  @override
  State<AddPatientPage> createState() => _AddPatientPageState();
}

class _AddPatientPageState extends State<AddPatientPage> {
  File? _profileImage;
  final picker = ImagePicker();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Stream<DocumentSnapshot<Map<String, dynamic>>>? _profileStream;

  final _formKey = GlobalKey<FormState>();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _surnameController = TextEditingController();
  TextEditingController _ageController = TextEditingController();
  TextEditingController _phoneNumberController = TextEditingController();
  TextEditingController _bloodGroupController = TextEditingController();

  @override
  void initState() {
    super.initState();
    String uid = _auth.currentUser!.uid;
    _profileStream =
        FirebaseFirestore.instance.collection('Users').doc(uid).snapshots();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _nameController.dispose();
    _surnameController.dispose();
    _ageController.dispose();
    _phoneNumberController.dispose();
    _bloodGroupController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Profil Düzenle"),
        ),
        body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: _profileStream,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final profileData = snapshot.data!.data();
              _descriptionController.text = profileData?['description'] ?? '';
              _nameController.text = profileData?['firstName'] ?? '';
              _surnameController.text = profileData?['lastName'] ?? '';
              _ageController.text = profileData?['age']?.toString() ?? '';
              _phoneNumberController.text = profileData?['phoneNumber'] ?? '';
              _bloodGroupController.text = profileData?['bloodGroup'] ?? '';

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      Center(
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            ClipOval(
                              child: Container(
                                width: 200,
                                height: 200,
                                color: Colors.grey,
                                child: _profileImage != null
                                    ? Image.file(
                                        _profileImage!,
                                        fit: BoxFit.cover,
                                      )
                                    : profileData?['profileImage'] != null
                                        ? Image.network(
                                            profileData?['profileImage'],
                                            fit: BoxFit.cover,
                                          )
                                        : Container(),
                              ),
                            ),
                            Positioned(
                              bottom: 8.0,
                              right: 8.0,
                              child: GestureDetector(
                                onTap: () {
                                  _showImagePickerDialog();
                                },
                                child: Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.camera_alt,
                                    color: Colors.black,
                                    size: 30,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextFormField(
                        decoration:
                            InputDecoration(labelText: 'Hasta Hakkında Yazı'),
                        controller: _descriptionController,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Hasta hakkında yazı boş bırakılamaz';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        decoration: InputDecoration(labelText: 'İsim'),
                        controller: _nameController,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'İsim boş bırakılamaz';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Soyisim'),
                        controller: _surnameController,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Soyisim boş bırakılamaz';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Yaş'),
                        keyboardType: TextInputType.number,
                        controller: _ageController,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Yaş boş bırakılamaz';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Telefon No'),
                        keyboardType: TextInputType.phone,
                        controller: _phoneNumberController,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Telefon numarası boş bırakılamaz';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Kan Grubu'),
                        controller: _bloodGroupController,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Kan grubu boş bırakılamaz';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16.0),
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _updatePatient();
                          }
                        },
                        child: Text('Güncelle'),
                      ),
                    ],
                  ),
                ),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Veriler çekilirken bir hata oluştu.'),
              );
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      ),
    );
  }

  void _updatePatient() {
    // Hasta verilerini Firestore'da güncelleyin
    String uid = _auth.currentUser!.uid;
    FirebaseFirestore.instance.collection('Users').doc(uid).update({
      'description': _descriptionController.text,
      'firstName': _nameController.text,
      'lastName': _surnameController.text,
      'age': int.parse(_ageController.text),
      'phoneNumber': _phoneNumberController.text,
      'bloodGroup': _bloodGroupController.text,
    }).then((value) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hasta bilgileri güncellendi')),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Hasta bilgileri güncellenirken bir hata oluştu')),
      );
    });
  }

  void _showImagePickerDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Profil Fotoğrafı Seç'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('İptal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.camera);
              },
              child: Text('Kamera'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.gallery);
              },
              child: Text('Galeri'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedImage = await picker.getImage(source: source);
    if (pickedImage != null) {
      setState(() {
        _profileImage = File(pickedImage.path);
      });
    }
  }
}
