import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_p/Reminders/Reminders.dart';
import 'package:flutter_p/constants.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../Classes.dart';
import '../NotePage/notepage.dart';
import 'package:flutter/material.dart';

class patient_relative_home extends StatefulWidget {
  const patient_relative_home({Key? key}) : super(key: key);

  @override
  State<patient_relative_home> createState() => _patient_relative_homeState();
}

class _patient_relative_homeState extends State<patient_relative_home> {
  String uid = FirebaseAuth.instance.currentUser!.uid;
  final Completer<GoogleMapController> _controller = Completer();
  LatLng? sourceLocation;
  LatLng? destination;
  String? token;

  @override
  void initState() {
    super.initState();
    fetchLocations();
    _getCurrentLocation();
    getToken();
  }

  Future<void> getToken() async {
    token = await FirebaseMessaging.instance.getToken();
    String uid = FirebaseAuth.instance.currentUser!.uid;

    // Firestore kullanıcı referansı
    DocumentReference userRef =
        FirebaseFirestore.instance.collection('Users').doc(uid);

    // Kullanıcının patientID'sini al
    DocumentSnapshot userSnapshot = await userRef.get();
    String patientID = userSnapshot.get('patientID');

    // Kullanıcı sorgusu
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Users')
        .where('patientID', isEqualTo: patientID)
        .get();

    // Kullanıcıların altına token alanını ekleyin
    for (QueryDocumentSnapshot doc in querySnapshot.docs) {
      await doc.reference.update({'token': token});
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        sourceLocation = LatLng(position.latitude, position.longitude);
      });
    } catch (e) {
      print(e);
    }
  }

  void onMapCreated(GoogleMapController controller) async {
    final GoogleMapController mapController = controller;
    if (sourceLocation != null) {
      mapController
          .animateCamera(CameraUpdate.newLatLngZoom(sourceLocation!, 14.5));
    }
  }

  Future<void> fetchLocations() async {
    final userSnapshot =
        await FirebaseFirestore.instance.collection('Users').doc(uid).get();
    final patientID = userSnapshot.get('patientID');

    final querySnapshot = await FirebaseFirestore.instance
        .collection('Users')
        .where('userType', isEqualTo: 'patient')
        .where('patientID', isEqualTo: patientID)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final patient = querySnapshot.docs.first;
      final locationsSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(patient.id)
          .collection('Locations')
          .orderBy('time', descending: true)
          .limit(1)
          .get();

      if (locationsSnapshot.docs.isNotEmpty) {
        final location = locationsSnapshot.docs.first;
        final latitude = location.get('latitude');
        final longitude = location.get('longitude');

        setState(() {
          sourceLocation = LatLng(latitude, longitude);
          destination = LatLng(latitude, longitude);
        });
      }
    }
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newLatLngZoom(destination!, 14.5));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        title: 'AlzHelper',
        actions: [],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  radius: 200,
                  backgroundColor: Colors.grey,
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: destination ?? LatLng(0, 0),
                      zoom: 14.5,
                    ),
                    markers: Set<Marker>.from([
                      if (sourceLocation != null)
                        Marker(
                          markerId: MarkerId("source"),
                          position: sourceLocation!,
                          infoWindow: InfoWindow(title: "Konum'um"),
                        ),
                      if (destination != null)
                        Marker(
                          markerId: MarkerId("destination"),
                          position: destination!,
                          icon: BitmapDescriptor.defaultMarkerWithHue(
                            BitmapDescriptor.hueAzure,
                          ),
                          infoWindow: InfoWindow(title: "Hasta'ya ait konum"),
                        ),
                    ]),
                    onMapCreated: (GoogleMapController controller) {
                      onMapCreated(controller);
                      _controller.complete(controller);
                    },
                  ),
                ),
              ),
            ),
            Container(
              child: const Divider(),
            ),
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.end, // Align buttons to the right
              children: [
                Column(
                  children: [
                    Text(
                      '  Kartlar',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                IconButton(
                  onPressed: () async {
                    _getCurrentLocation();
                    final GoogleMapController controller =
                        await _controller.future;
                    controller
                        .animateCamera(CameraUpdate.newLatLng(destination!));
                  },
                  icon: Icon(Icons.add_location),
                  tooltip: 'Konumumu Bul',
                ),
                IconButton(
                  onPressed: () async {
                    if (sourceLocation != null) {
                      final GoogleMapController controller =
                          await _controller.future;
                      controller.animateCamera(
                          CameraUpdate.newLatLng(sourceLocation!));
                    }
                  },
                  icon: Icon(Icons.place),
                  tooltip: 'Hasta Konumunu Bul',
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    width: 180,
                    height: 200,
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection("Users")
                          .doc(uid)
                          .collection("Notes")
                          .snapshots(),
                      builder:
                          (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (snapshot.hasData &&
                            snapshot.data!.docs.isNotEmpty) {
                          final reversedDocs =
                              snapshot.data!.docs.reversed.toList();
                          final note = reversedDocs.first;
                          return noteCard(() {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const NotePage(),
                              ),
                            );
                          }, note);
                        }
                        return InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => NotePage()));
                          },
                          child: Column(
                            children: [
                              NotesWidget(
                                child: Text(
                                  "Henüz not eklemediniz",
                                  style: TextStyle(fontSize: 15),
                                ),
                              )
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(width: 16.0), // Add spacing between the buttons
                Expanded(
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Reminders(),
                        ),
                      );
                    },
                    child: Column(
                      children: [
                        InkWell(
                          onTap: () async {
                            String? token =
                                await FirebaseMessaging.instance.getToken();
                            print(token);
                          },
                          child: NotesWidget(
                            child: Text(
                              "Henüz hatırlatıcı eklemediniz",
                              style: TextStyle(fontSize: 15),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
