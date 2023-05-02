import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


import 'Classes.dart';

DateTime _selectedTime = DateTime.now();

void _showBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _buildTimePicker(context),
            SizedBox(height: 16.0),
            _buildDayPicker(),
            SizedBox(height: 16.0),
            _buildAlarmNameField(),
            SizedBox(height: 16.0),
            _buildAddImageButton(),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                //TODO: handle saving the alarm with selected time, day, name, and image
              },
              child: Text('Kaydet'),
            ),
          ],
        ),
      );
    },
  );
}

Widget _buildTimePicker(BuildContext context) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: <Widget>[
      Text('Saat: '),
      SizedBox(width: 8.0),
      GestureDetector(
        onTap: () async {
          TimeOfDay? selectedTime = await showTimePicker(
            context: context,
  initialTime: TimeOfDay.now(),
  builder: (BuildContext context, Widget? child) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
      child: child!,
    );
  },
          );
          if (selectedTime != null) {
            _selectedTime = DateTime(
              DateTime.now().year,
              DateTime.now().month,
              DateTime.now().day,
              selectedTime.hour,
              selectedTime.minute,
            );
          }
        },
        child: Container(
          padding: EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            color: Colors.grey[200],
          ),
          child: Text(
            '${DateFormat('HH:mm').format(_selectedTime)}',
            style: TextStyle(fontSize: 16.0),
          ),
        ),
      ),
    ],
  );
}


Widget _buildDayPicker() {
  List<String> days = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: <Widget>[
      Text('Gün: '),
      SizedBox(width: 8.0),
      DropdownButton<String>(
        items: days.map((String day) {
          return DropdownMenuItem<String>(
            value: day,
            child: Text(day),
          );
        }).toList(),
        onChanged: (String? selectedDay) {
          //TODO: handle day selection
        },
        value: days.first,
      ),
    ],
  );
}

Widget _buildAlarmNameField() {
  return TextField(
    decoration: InputDecoration(
      border: OutlineInputBorder(),
      labelText: 'Alarm Adı',
    ),
  );
}

Widget _buildAddImageButton() {
  return ElevatedButton.icon(
    icon: Icon(Icons.add_a_photo),
    label: Text('Resim Ekle'),
    onPressed: () {
      //TODO: handle adding image
    },
  );
}


class Reminders extends StatelessWidget {
  const Reminders({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(),
      floatingActionButton: CustomFloatingActionButton(
        onPressed: () {
          _showBottomSheet(context);
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
