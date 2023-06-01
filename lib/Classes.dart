import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

//Divider çekmek için widget Container( child: customDivider(),),
Widget customDivider({
  double height = 1.2,
  Color color = Colors.grey,
}) {
  return Container(
    height: height,
    margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 15.0),
    decoration: BoxDecoration(
      border: Border(
        bottom: BorderSide(
          width: height,
          color: color,
        ),
      ),
    ),
  );
}

// buildCustomCircleAvatar(50, 20, 8),
Widget buildCustomCircleAvatar(
  double radius,
  double sizedBoxHeight,
  double paddingValue,
) {
  return Padding(
    padding: EdgeInsets.only(right: paddingValue),
    child: Column(
      children: [
        SizedBox(height: sizedBoxHeight),
        CircleAvatar(
          backgroundColor: AllColors.grey,
          radius: radius,
        ),
      ],
    ),
  );
}

//NotesWidget(child: const Text('Note 1')), şeklinde kullanarak not kartı çekilir.
class NotesWidget extends StatelessWidget {
  final Widget child;
  const NotesWidget({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: 170,
        height: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: AllColors.grey,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 110,
                height: 45, // height değeri 120 olarak değiştirildi
                child: child,
              ),
              const Divider(
                height: 10,
                thickness: 2,
                color: AllColors.black,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//note card
Widget noteCard(Function()? onTap, QueryDocumentSnapshot doc) {
  return InkWell(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(8.0),
      margin: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: AllColors.grey,
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            doc["note_title"],
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
          Text(
            doc["creation_date"],
            style: CardTextStyle.dateTitle,
          ),
          const SizedBox(
            height: 5,
          ),
          const Divider(
            height: 10,
            thickness: 2,
            color: AllColors.black,
          ),
          Text(
            doc["note_content"],
            style: CardTextStyle.mainContent,
            maxLines: 6,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    ),
  );
}

Widget familyRelationsCard(Function()? onTap, QueryDocumentSnapshot doc) {
  return InkWell(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(8.0),
      margin: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        color: AllColors.grey,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(doc["relationsImage"]),
            radius: 40,
          ),
          SizedBox(
            height: 5,
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              doc["relationsName"],
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            doc["relations"],
            style: TextStyle(
              fontSize: 18.0,
            ),
          ),
          TextButton(
              onPressed: () {
                makePhoneCall(doc["frnumber"]);
              },
              child: Text(doc["frnumber"]))
        ],
      ),
    ),
  );
}

void makePhoneCall(String phoneNumber) async {
  String url = 'tel:$phoneNumber';
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Arama başlatılamadı: $url';
  }
}

// Family Relations class
class FamilyRelationsWidget extends StatelessWidget {
  final String name;
  final String degreeOfCloseness;

  const FamilyRelationsWidget({
    Key? key,
    required this.name,
    required this.degreeOfCloseness,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.45,
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: AllColors.grey,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.width * 0.45,
            child: const Padding(
              padding: EdgeInsets.all(8.0),
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: Container(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      degreeOfCloseness,
                      style: const TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomFloatingActionButton extends StatelessWidget {
  final VoidCallback onPressed;

  const CustomFloatingActionButton({Key? key, required this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      tooltip: 'Add',
      child: Icon(Icons.add, color: AllColors.black),
      backgroundColor: AllColors.grey,
      shape: StadiumBorder(
        side: BorderSide(color: AllColors.black, width: 0.8),
      ),
    );
  }
}

//Card Text style
class CardTextStyle {
  static TextStyle mainTitle =
      GoogleFonts.roboto(fontSize: 18.0, fontWeight: FontWeight.bold);
  static TextStyle mainContent =
      GoogleFonts.roboto(fontSize: 16.0, fontWeight: FontWeight.normal);
  static TextStyle dateTitle =
      GoogleFonts.roboto(fontSize: 13.0, fontWeight: FontWeight.w500);
}

//Color color = AllColors.grey, şeklinde renkleri çekmek için
class AllColors {
  static const Color white = Colors.white;
  static const Color grey = Color.fromARGB(255, 224, 224, 224);
  static const Color black = Colors.black;
  static const Color red = Colors.red;
}
