import 'package:shared_preferences/shared_preferences.dart';

int streak = 0;
String lastAttendanceDate = "";

Future<void> loadStreak() async {
  final prefs = await SharedPreferences.getInstance();

  streak = prefs.getInt('streak') ?? 0;
  lastAttendanceDate = prefs.getString('lastDate') ?? "";
}

Future<void> saveStreak() async {
  final prefs = await SharedPreferences.getInstance();

  prefs.setInt('streak', streak);
  prefs.setString('lastDate', lastAttendanceDate);
}

void updateStreak() {
  final today = DateTime.now().toIso8601String().split('T')[0];

  if (lastAttendanceDate == today) return;

  final yesterday = DateTime.now()
      .subtract(const Duration(days: 1))
      .toString()
      .substring(0, 10);

  if (lastAttendanceDate == yesterday) {
    streak += 1;
  } else {
    streak = 1;
  }

  lastAttendanceDate = today;
  saveStreak();
}
