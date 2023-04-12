import 'package:flutter/material.dart';
//Divider çekmek için widget Container( child: customDivider(),),
Widget customDivider({
  double height = 1.2,
  Color color = const Color.fromARGB(255, 224, 224, 224),
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
          radius: radius,
        ),
      ],
    ),
  );
}