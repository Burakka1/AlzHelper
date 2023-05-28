import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

import 'family_relations_services.dart';

class FamilyRelationsEditor extends StatefulWidget {
  const FamilyRelationsEditor({Key? key}) : super(key: key);

  @override
  State<FamilyRelationsEditor> createState() => _FamilyRelationsEditorState();
}

class _FamilyRelationsEditorState extends State<FamilyRelationsEditor> {
  TextEditingController _relationsNameController = TextEditingController();
  TextEditingController _relationsController = TextEditingController();
  FREService _freService = FREService();

  final ImagePicker _pickerImage = ImagePicker();
  var profileImage;
  dynamic _pickImage;

  Widget imagePlace() {
    double height = MediaQuery.of(context).size.height;
    if (profileImage != null) {
      return CircleAvatar(
        backgroundImage: FileImage(File(profileImage!.path)),
        radius: height * 0.08,
      );
    } else {
      if (_pickImage != null) {
        return Stack(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(_pickImage),
              radius: height * 0.08,
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: CircleAvatar(
                backgroundImage: AssetImage("assets/images/logo.png"),
              ),
            ),
          ],
        );
      } else {
        return Stack(
          children: [
            CircleAvatar(
              backgroundImage: AssetImage("assets/images/logo.png"),
              radius: height * 0.08,
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: InkWell(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return _customAlertDialog();
                    },
                  );
                },
                child: CircleAvatar(
                  backgroundImage: AssetImage("assets/images/logo.png"),
                ),
              ),
            ),
          ],
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Aile Yakını Ekle"),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          child: Column(
                            children: [
                              Center(
                                child: imagePlace(),
                              ),
                              TextFormField(
                                controller: _relationsNameController,
                                decoration: InputDecoration(
                                  labelText: "Adı - Soyadı",
                                ),
                              ),
                              TextFormField(
                                controller: _relationsController,
                                decoration: InputDecoration(
                                  labelText: "Yakınlık Derecesi",
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: ElevatedButton(
                                  onPressed: () {
                                    _freService
                                        .addFRE(
                                            _relationsNameController.text,
                                            _relationsController.text,
                                            _pickImage)
                                        .then((value) {
                                      Fluttertoast.showToast(
                                          msg: "Ekleme Başarılı",
                                          timeInSecForIosWeb: 2,
                                          toastLength: Toast.LENGTH_SHORT,
                                          gravity: ToastGravity.BOTTOM,
                                          backgroundColor: Colors.grey[600],
                                          textColor: Colors.white,
                                          fontSize: 14);
                                      Navigator.pop(context);
                                    });
                                  },
                                  child: const Text("Ekle"),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _customAlertDialog() {
    return AlertDialog(
      title: const Text('Seçenekler'),
      content: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          InkWell(
            onTap: () => _onImageButtonPressed(ImageSource.camera),
            child: _buildOptionBox('assets/images/logo.png'),
          ),
          const SizedBox(width: 16),
          InkWell(
            onTap: () => _onImageButtonPressed(ImageSource.gallery),
            child: _buildOptionBox('assets/images/logo.png'),
          ),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Kapat'),
        ),
      ],
    );
  }

  Widget _buildOptionBox(String imagePath) {
    return Container(
      width: 100,
      height: 100,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Image.asset(imagePath),
    );
  }

  void _onImageButtonPressed(ImageSource source) async {
    try {
      final pickedFile = await _pickerImage.pickImage(source: source);
      setState(() {
        profileImage = pickedFile!;
        print("dosyaya geldim: $profileImage");
      });
      print('aaa');
    } catch (e) {
      setState(() {
        _pickImage = e;
        print("Image Error: $_pickImage");
      });
    }
  }
}
