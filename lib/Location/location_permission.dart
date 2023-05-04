import 'package:geolocator/geolocator.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<Position> getCurrentLocation() async {
  bool serviceEnabled;
  LocationPermission permission;

  // Konum servisi açık mı diye kontrol et.
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return Future.error('Konum servisi kapalı.');
  }

  // Konum izni al.
  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.deniedForever) {
    return Future.error(
        'Konum erişimi kalıcı olarak reddedildi, ayarlardan açın.');
  }
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission != LocationPermission.whileInUse &&
        permission != LocationPermission.always) {
      return Future.error('Konum izni verilmedi.');
    }
  }

  // Konum verilerini al.
  return await Geolocator.getCurrentPosition();
}

Future<void> saveLocationToFirebase(Position position) async {
  // Firebase'in başlatılması.
  await Firebase.initializeApp();

  // Firestore referansı.
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Firestore'a konum verisi ekleme.
  await firestore.collection('konumlar').add({
    'latitude': position.latitude,
    'longitude': position.longitude,
    'time': DateTime.now(),
  });
}

Future<void> sendLocationToFirebase() async {
  try {
    Position position = await getCurrentLocation();
    await saveLocationToFirebase(position);
  } catch (e) {
    print('Hata: $e');
  }
}
