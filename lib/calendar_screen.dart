import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';


class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime today = DateTime.now();
  CalendarFormat format = CalendarFormat.month;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F2),
      appBar: AppBar(
        title: const Text("Calendar 📅"),
        backgroundColor: const Color(0xFF473C33),
      ),
      body: Column(
        children: [
          TableCalendar(
            focusedDay: today,
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            calendarFormat: format,
            onFormatChanged: (newFormat) {
              setState(() {
                format = newFormat;
              });
            },
            selectedDayPredicate: (day) => isSameDay(day, today),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                today = selectedDay;
              });
            },
          ),

          const SizedBox(height: 20),

          Text(
            "Selected Date: ${today.toString().split(" ")[0]}",
            style: const TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }
}