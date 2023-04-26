import 'package:flutter/material.dart';
import 'Home.dart';
import 'Profile.dart';

//Divider çekmek için widget Container( child: customDivider(),),
Widget customDivider({
  double height = 1.2,
  Color color = AllColors.grey,
}) {
  return Container(
    height: height,
    margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
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
    return Container(
      width: 150,
      height: 150,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: AllColors.grey,
      ),
      child: Padding(
        // Padding içinde Align ve SizedBox kullanılarak sol üst köşede yerleştirilir
        padding: const EdgeInsets.all(20),
        child: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 110,
            height: 110,
            child: child,
          ),
        ),
      ),
    );
  }
}

//Color color = AllColors.grey, şeklinde renkleri çekmek için
class AllColors {
  static const Color white = Colors.white;
  static const Color grey = Color.fromARGB(255, 224, 224, 224);
  static const Color black = Colors.black;
  static const Color red = Colors.red;
}


