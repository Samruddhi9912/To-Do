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
    this.completed = false
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

  Map<String, dynamic> toJson() {
    return {
      "title": title,
      "completed": completed,
      "targetDate": targetDate.toIso8601String(),
    };
  }
}


class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => TodoPageState();
}

class TodoPageState extends State<TodoPage> {
  final Color marooncolor = Color(0xFFA44A3F);

  List<Todo> tasks = [];

  TextEditingController taskController = TextEditingController();
  DateTime? selectedDate;

String get baseUrl {
  return "http://localhost:3000";
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

 Future<void> fetchTasks() async {
  try {
    final response = await http.get(
      Uri.parse("$baseUrl/api/todo/get"),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

if (data is List) {
  setState(() {
    tasks = data.map((e) => Todo.fromJson(e)).toList();
  });
}

      setState(() {
        tasks = data.map((e) => Todo.fromJson(e)).toList();
      });
    }
  } catch (e) {
    print(e);
  }
}
  Future<Todo> createTask(String title, DateTime date) async { 
     final response = await http.post(
    Uri.parse("$baseUrl/api/todo/create"),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "title": title,
      "targetDate": date.toIso8601String(),
    }),
  );

  if (response.statusCode == 200 || response.statusCode == 201) {
    final data = jsonDecode(response.body);
    return Todo.fromJson(data);
  } else {
    throw Exception("Failed to create task");
  }}

Future<void> deleteTask(String id) async {
  final response = await http.delete(
    Uri.parse("$baseUrl/api/todo/delete/$id"),
  );

  if (response.statusCode != 200) {
    throw Exception("Delete failed");
  }
}

Future<void> toggleComplete(String id) async {
  final response = await http.put(
    Uri.parse("$baseUrl/api/todo/update/$id"),
  );

  if (response.statusCode != 200) {
    throw Exception("Update failed");
  }
}

  void showAddTaskSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
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
                    decoration: InputDecoration(
                      labelText: "Write your task",
                      border: OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          selectedDate == null
                              ? "Pickup date"
                              : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.calendar_month),
                        onPressed: pickDate,
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  ElevatedButton(
                    onPressed:  () async {
                        if (taskController.text.isEmpty || selectedDate == null) {
                          return;
                        }

                        final newTask = await createTask(
                          taskController.text,
                          selectedDate!,
                        );

                        setState(() {
                          tasks.add(newTask);
                        });

                        taskController.clear();
                        selectedDate = null;

                        Navigator.pop(context);
                      },
                    child: Text(
                      "Add Task",
                      style: TextStyle(color: marooncolor),
                    ),
                  ),
                  SizedBox(height: 10),
                ],
              ),
            );
          },
        );
      },
    );
  }

 @override
void initState() {
  super.initState();
  fetchTasks();
}

@override
void dispose() {
  taskController.dispose();
  super.dispose();
}
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 60,
        elevation: 0,
        backgroundColor: marooncolor,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          "Todo",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showAddTaskSheet,
        child: Icon(Icons.add_outlined),
      ),
      body:
          tasks.isEmpty
              ? Center(
                child: Text(
                  "No tasks yet",
                  style: TextStyle(
                    color: marooncolor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
              : ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    child: ListTile(
                      leading: Checkbox(
                        value: task.completed,
                        onChanged: (value) async {
                          await toggleComplete(task.id);

                          setState(() {
                            task.completed = value!;
                          });
                        },
                      ),
                      title: Text(
                        task.title,
                        style: TextStyle(
                          color: task.completed ? Colors.grey : Colors.black,
                          decoration:
                              task.completed ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      subtitle: Text(
                        "${task.targetDate.day}/${task.targetDate.month}/${task.targetDate.year}",
                        style: TextStyle(
                          color: task.completed ? Colors.grey : Colors.black,
                        ),
                      ),
                      trailing: IconButton(
                        icon: Icon(
                          Icons.delete,
                          color: task.completed ? Colors.grey : Colors.black,
                        ),
                        onPressed: () async {
                          await deleteTask(task.id);

                          setState(() {
                            tasks.removeAt(index);
                          });
                        },
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
