import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StudentTaskManager(),
    );
  }
}

class StudentTaskManager extends StatefulWidget {
  const StudentTaskManager({super.key});

  @override
  State<StudentTaskManager> createState() => _StudentTaskManagerState();
}

class _StudentTaskManagerState extends State<StudentTaskManager> {
  List tasks = [];
  final TextEditingController taskController = TextEditingController();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTasks();
  }

  // Fetch tasks from API
  Future<void> fetchTasks() async {
    final response = await http.get(
      Uri.parse('https://jsonplaceholder.typicode.com/todos?_limit=5'),
    );

    if (response.statusCode == 200) {
      setState(() {
        tasks = json.decode(response.body);
        isLoading = false;
      });
    }
  }

  // Add new task
  void addTask() {
    if (taskController.text.isNotEmpty) {
      setState(() {
        tasks.add({"title": taskController.text, "completed": false});
        taskController.clear();
      });
    }
  }

  // Delete task
  void deleteTask(int index) {
    setState(() {
      tasks.removeAt(index);
    });
  }

  // Toggle complete status
  void toggleTask(int index) {
    setState(() {
      tasks[index]["completed"] = !(tasks[index]["completed"] ?? false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Task Manager"),
        backgroundColor: Colors.blue,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Add Task Section
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: taskController,
                          decoration: const InputDecoration(
                            hintText: "Enter new task",
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 5),
                      ElevatedButton(
                        onPressed: addTask,
                        child: const Text("Add"),
                      ),
                    ],
                  ),
                ),

                // Task List
                Expanded(
                  child: ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      return Card(
                        child: ListTile(
                          title: Text(
                            tasks[index]["title"],
                            style: TextStyle(
                              decoration: tasks[index]["completed"] == true
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                            ),
                          ),
                          leading: IconButton(
                            icon: Icon(
                              tasks[index]["completed"] == true
                                  ? Icons.check_circle
                                  : Icons.radio_button_unchecked,
                              color: tasks[index]["completed"] == true
                                  ? Colors.green
                                  : Colors.grey,
                            ),
                            onPressed: () => toggleTask(index),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => deleteTask(index),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
