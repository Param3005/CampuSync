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
      backgroundColor: const Color(0xFFFDE2E4),
      appBar: AppBar(
        title: const Text("Calendar 📅"),
        backgroundColor: const Color(0xFFF8C8DC),
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TableCalendar(
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


              calendarStyle: CalendarStyle(
                defaultTextStyle: TextStyle(color: Color(0xFF473C33)),
                weekendTextStyle: TextStyle(color: Colors.red),
                todayDecoration: BoxDecoration(
                  color: const Color(0xFFF8C8DC),
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: const Color(0xFF473C33),
                  shape: BoxShape.circle,
                ),
              ),

              daysOfWeekStyle: const DaysOfWeekStyle(
                weekdayStyle: TextStyle(color: Color(0xFF473C33)),
                weekendStyle: TextStyle(color: Colors.red),
              ),

              headerStyle: const HeaderStyle(
                titleCentered: true,
                formatButtonVisible: true,
                titleTextStyle: TextStyle(
                  color: Color(0xFF473C33),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                formatButtonTextStyle: TextStyle(
                  color: Colors.white,
                ),
                formatButtonDecoration: BoxDecoration(
                  color: Color(0xFFF8C8DC),
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
