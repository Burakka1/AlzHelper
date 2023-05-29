import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_p/Services/storege_service_fam.dart';
import 'package:image_picker/image_picker.dart';

//Veritabanında olşturulan model class
class FamilyRelationsEditorModel {
  String relationsName;
  String relations;
  String relationsImage;
  String FRNumber;

  FamilyRelationsEditorModel(
      {required this.relationsName,
      required this.relations,
      required this.relationsImage,
      required this.FRNumber});

  factory FamilyRelationsEditorModel.formSnapshot(DocumentSnapshot snapshot) {
    return FamilyRelationsEditorModel(
        relationsName: snapshot["relationsName"],
        relations: snapshot["relations"],
        relationsImage: snapshot["relationsImage"],
        FRNumber: snapshot["FRNumber"]);
  }
}

//FRE veri ekleme
class FREService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String uid = FirebaseAuth.instance.currentUser!.uid;

  FREStorageService _freStorageService = FREStorageService();
  String mediaUrl = "";

  Future<FamilyRelationsEditorModel> addFRE(String relationsName,
      String relations, XFile pickedFile, String FRNumber) async {
    var ref =
        _firestore.collection("Users").doc(uid).collection("FamilyRelations");

    mediaUrl = await _freStorageService.uploadMediaFRE(File(pickedFile.path));

    var documentRef = await ref.add({
      "relationsName": relationsName,
      "relations": relations,
      "relationsImage": mediaUrl,
      "frnumber": FRNumber,
    });

    return FamilyRelationsEditorModel(
        relations: relations,
        relationsImage: mediaUrl,
        relationsName: relationsName,
        FRNumber: FRNumber);
  }
}

//FRE resim ekleme
class FREStorageService {
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  Future<String> uploadMediaFRE(File file) async {
    var uploadTask = _firebaseStorage
        .ref()
        .child(
            "${DateTime.now().microsecondsSinceEpoch}.${file.path.split(".").last}")
        .putFile(file);

    uploadTask.snapshotEvents.listen((enevnt) {});

    var storageRef = await uploadTask;

    return await storageRef.ref.getDownloadURL();
  }
}
