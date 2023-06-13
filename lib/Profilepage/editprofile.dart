import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

class AddPatientPage extends StatefulWidget {
  @override
  _AddPatientPageState createState() => _AddPatientPageState();
}

class _AddPatientPageState extends State<AddPatientPage> {
  final _formKey = GlobalKey<FormState>();
  File? _profileImage;
  final picker = ImagePicker();

  late String _description;
  late String _name;
  late String _surname;
  late int _age;
  late String _phoneNumber;
  late String _bloodGroup;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile Düzenle'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              GestureDetector(
                onTap: () {
                  _showImagePicker();
                },
                child: _profileImage != null
                    ? Container(
                        height: 150,
                        width: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: FileImage(_profileImage!),
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                    : Container(
                        height: 150,
                        width: 150,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.camera_alt,
                          size: 50,
                          color: Colors.grey[800],
                        ),
                      ),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Hasta Hakkında Yazı'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Hasta hakkında yazı boş bırakılamaz';
                  }
                  return null;
                },
                onSaved: (value) {
                  _description = value!;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'İsim'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'İsim boş bırakılamaz';
                  }
                  return null;
                },
                onSaved: (value) {
                  _name = value!;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Soyisim'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Soyisim boş bırakılamaz';
                  }
                  return null;
                },
                onSaved: (value) {
                  _surname = value!;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Yaş'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Yaş boş bırakılamaz';
                  }
                  return null;
                },
                onSaved: (value) {
                  _age = int.parse(value!);
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Telefon No'),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Telefon numarası boş bırakılamaz';
                  }
                  return null;
                },
                onSaved: (value) {
                  _phoneNumber = value!;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Kan Grubu'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Kan grubu boş bırakılamaz';
                  }
                  return null;
                },
                onSaved: (value) {
                  _bloodGroup = value!;
                },
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    _updatePatient();
                  }
                },
                child: Text('Güncelle'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showImagePicker() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Profil Fotoğrafı Ekle'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                GestureDetector(
                  child: Text('Galeri'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _getImageFromGallery();
                  },
                ),
                SizedBox(height: 10),
                GestureDetector(
                  child: Text('Kamera'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _getImageFromCamera();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _getImageFromGallery() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  void _getImageFromCamera() async {
    final pickedFile = await picker.getImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  void _updatePatient() {
    // Firestore'da belgeyi güncelleme işlemini gerçekleştirir
    final data = {
      'description': _description,
      'firstName': _name,
      'lastName': _surname,
      'age': _age,
      'phoneNumber': _phoneNumber,
      'bloodGroup': _bloodGroup,
    };

    if (_profileImage != null) {
      data['profileImage'] = _profileImage!.path;
    }

    String uid = FirebaseAuth.instance.currentUser!.uid;
    FirebaseFirestore.instance
        .collection('Users')
        .doc(uid)
        .update(data) // update metodu kullanarak belgeyi güncelleyin
        .then((_) {
      // Belge başarıyla güncellendikten sonra işlenecek kodlar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bilgiler başarıyla güncellendi')),
      );
      _resetFields();
    }).catchError((error) {
      // Hata durumunda işlenecek kodlar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bilgiler güncellenirken bir hata oluştu')),
      );
    });
  }

  void _resetFields() {
    setState(() {
      _profileImage = null; // _profileImage'ı null olarak ayarla
    });

    if (_formKey.currentState != null) {
      _formKey.currentState!.reset();
    }
  }
}
