import 'package:flutter/material.dart';
import 'Classes.dart';



class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

 
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          
          const SizedBox(height: 20),
         buildCustomCircleAvatar(50, 20, 8),
          Container(
            child: customDivider(),
          ),
          const Text(
            'İsim Soyisim',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          const Text(
            'Hasta hakkında kısa bir özyazı',
            style: TextStyle(fontSize: 16),
          ),
          Container(
            child: customDivider(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: const Text(
                  'Aile Yakınları',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'Tümünü Gör',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: List.generate(
              5,
              (index) => buildCustomCircleAvatar(35, 10, 8),
            ),
          ),
          Container(
            child: customDivider(),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: const Text(
                  'Kartlar',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  
                ),
              ),
            ],
          ),
        ],
      ),
      
    );
  }
}
