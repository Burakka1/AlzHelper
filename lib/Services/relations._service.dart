import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_p/FamilyRelations/family_relations.dart';
import 'package:flutter_p/Services/storege_service_fam.dart';
import 'package:image_picker/image_picker.dart';

class RelationsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StorageService _storageService = StorageService();
  String mediaUrl = "";

  //veri ekleme
  Future<void> addStatus(String status, PickedFile pickedFile) async {
    var ref = _firestore.collection("family_Relations");

    if (pickedFile == null) {
      mediaUrl = '';
    } else {
      mediaUrl = await _storageService.uploadMedia(File(pickedFile.path));
    }

    var documanRef = await ref
        .add({"fam_title": "", "fam_relations": "", "fam_pic": mediaUrl});
  }
}
