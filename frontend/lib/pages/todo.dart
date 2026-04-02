import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Todo {
  String id;
  String title;
  bool completed;
  DateTime targetDate;

  Todo({
    required this.id,
    required this.title,
    required this.targetDate,
    this.completed = false,
  });

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['_id'] ?? "",
      title: json['title'] ?? "",
      completed: json['completed'] ?? false,
      targetDate: json['targetDate'] != null
          ? DateTime.parse(json['targetDate'])
          : DateTime.now(),
    );
  }
}

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => TodoPageState();
}

class TodoPageState extends State<TodoPage> {
  final Color marooncolor = const Color(0xFFA44A3F);

  List<Todo> tasks = [];
  TextEditingController taskController = TextEditingController();
  DateTime? selectedDate;

  String get baseUrl => "https://to-do-gu1g.onrender.com";

  @override
  void initState() {
    super.initState();
    fetchTasks();
  }

  Future<void> fetchTasks() async {
    try {
      final response =
          await http.get(Uri.parse("$baseUrl/api/todo/get"));

      print("STATUS: ${response.statusCode}");
      print("BODY: ${response.body}");

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        List dataList = [];

        if (decoded is List) {
          dataList = decoded;
        } else if (decoded['todos'] != null) {
          dataList = decoded['todos'];
        } else if (decoded['data'] != null) {
          dataList = decoded['data'];
        }

        if (mounted) {
          setState(() {
            tasks = dataList.map((e) => Todo.fromJson(e)).toList();
          });
        }
      }
    } catch (e) {
      print("ERROR: $e");
    }
  }

  Future<void> createTask(String title, DateTime date) async {
    final response = await http.post(
      Uri.parse("$baseUrl/api/todo/create"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "title": title,
        "targetDate": date.toIso8601String(),
      }),
    );

    print("CREATE STATUS: ${response.statusCode}");
    print("CREATE BODY: ${response.body}");

    if (response.statusCode != 200 &&
        response.statusCode != 201) {
      throw Exception("Failed to create task");
    }
  }

  Future<void> deleteTask(String id) async {
    final response = await http.delete(
      Uri.parse("$baseUrl/api/todo/delete/$id"),
    );

    if (response.statusCode == 200) {
      fetchTasks();
    }
  }

  Future<void> toggleComplete(String id) async {
    final response = await http.put(
      Uri.parse("$baseUrl/api/todo/update/$id"),
    );

    if (response.statusCode == 200) {
      fetchTasks();
    }
  }

  Future<void> pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (date != null) {
      setState(() {
        selectedDate = date;
      });
    }
  }

  void showAddTaskSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: taskController,
                decoration: const InputDecoration(
                  labelText: "Write your task",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: Text(
                      selectedDate == null
                          ? "Pick date"
                          : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_month),
                    onPressed: pickDate,
                  ),
                ],
              ),

              const SizedBox(height: 12),

              ElevatedButton(
                onPressed: () async {
                  if (taskController.text.isEmpty ||
                      selectedDate == null) return;

                  await createTask(
                      taskController.text, selectedDate!);

                  taskController.clear();

                  setState(() {
                    selectedDate = null;
                  });

                  if (mounted) {
                    Navigator.pop(context);
                  }

                  await fetchTasks();
                },
                child: Text(
                  "Add Task",
                  style: TextStyle(color: marooncolor),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Todo",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: marooncolor,
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: showAddTaskSheet,
        child: const Icon(Icons.add),
      ),

      body: tasks.isEmpty
          ? const Center(child: Text("No tasks yet"))
          : ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];

                return ListTile(
                  leading: Checkbox(
                    value: task.completed,
                    onChanged: (_) => toggleComplete(task.id),
                  ),
                  title: Text(task.title),
                  subtitle: Text(
                    "${task.targetDate.day}/${task.targetDate.month}/${task.targetDate.year}",
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => deleteTask(task.id),
                  ),
                );
              },
            ),
    );
  }
}