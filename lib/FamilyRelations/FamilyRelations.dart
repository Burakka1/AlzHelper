import 'package:flutter/material.dart';
import '../Classes.dart';

class FamilyRelations extends StatelessWidget {
  const FamilyRelations({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                "Aile Yakınları",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FamilyRelationsWidget(
                  name: "İsim 1",
                  degreeOfCloseness: "Yakınlık Derecesi 1",
                ),
                FamilyRelationsWidget(
                  name: "İsim 2",
                  degreeOfCloseness: "Yakınlık Derecesi 2",
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FamilyRelationsWidget(
                  name: "İsim 3",
                  degreeOfCloseness: "Yakınlık Derecesi 3",
                ),
                FamilyRelationsWidget(
                  name: "İsim 4",
                  degreeOfCloseness: "Yakınlık Derecesi 4",
                ),
              ],
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
