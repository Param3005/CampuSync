import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../streak.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  List<Map<String, dynamic>> tasks = [];

  final TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadTasks();
    loadStreak();
  }

  void loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList('tasks');

    if (data != null) {
      setState(() {
        tasks = data.map((e) {
          final parts = e.split('|');
          return {"title": parts[0], "done": parts[1] == 'true'};
        }).toList();
      });
    }
  }

  void saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final data = tasks
        .map((task) => "${task['title']}|${task['done']}")
        .toList();

    prefs.setStringList('tasks', data);
  }

  void addTask() {
    debugPrint("ADD CLICKED");

    if (controller.text.trim().isEmpty) return;

    setState(() {
      tasks.add({"title": controller.text.trim(), "done": false});
      controller.clear();
    });
    saveTasks();
  }

  void deleteTask(int index) {
    setState(() {
      tasks.removeAt(index);
    });
    saveTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDDEEDC), 
      appBar: AppBar(
        title: const Text("My Tasks"),
        backgroundColor: const Color(0xFF7FC97F), 
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: "Add a task...",
                      prefixIcon: const Icon(Icons.chat_bubble_outline),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    addTask();
                  },
                ),
              ],
            ),

            const SizedBox(height: 20),

            Expanded(
              child: ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  return CheckboxListTile(
                    value: tasks[index]["done"],
                    title: Text(tasks[index]["title"]),

                    secondary: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        deleteTask(index);
                      },
                    ),
                    onChanged: (val) {
                      setState(() {
                        tasks[index]["done"] = val!;
                      });
                      saveTasks();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
