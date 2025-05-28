import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => TodoData(),
      builder: (context, child) => const MyApp(),
    ),
  );
}

class TodoData extends ChangeNotifier {
  List<TodoTask> _tasks = [];

  List<TodoTask> get tasks => _tasks;

  void addTask(String taskName) {
    _tasks = [..._tasks, TodoTask(name: taskName)];
    notifyListeners();
  }

  void removeTask(TodoTask task) {
    _tasks = _tasks.where((t) => t != task).toList();
    notifyListeners();
  }

  void toggleTask(TodoTask task) {
    task.isDone = !task.isDone;
    notifyListeners();
  }
}

class TodoTask {
  String name;
  bool isDone;

  TodoTask({required this.name, this.isDone = false});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is TodoTask &&
              runtimeType == other.runtimeType &&
              name == other.name &&
              isDone == other.isDone;

  @override
  int get hashCode => name.hashCode ^ isDone.hashCode;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const TodoListScreen(),
    );
  }
}

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo List'),
      ),
      body: Consumer<TodoData>(
        builder: (context, todoData, child) {
          return ListView.builder(
            itemCount: todoData.tasks.length,
            itemBuilder: (context, index) {
              final task = todoData.tasks[index];
              return TodoListItem(
                task: task,
                onRemove: () {
                  todoData.removeTask(task);
                },
                onToggle: () {
                  todoData.toggleTask(task);
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              String newTaskName = '';
              return AlertDialog(
                title: const Text('Add New Task'),
                content: TextField(
                  autofocus: true,
                  decoration: const InputDecoration(hintText: 'Task name'),
                  onChanged: (value) {
                    newTaskName = value;
                  },
                  onSubmitted: (value) {
                    newTaskName = value;
                    if (newTaskName.isNotEmpty) {
                      Provider.of<TodoData>(context, listen: false)
                          .addTask(newTaskName);
                      Navigator.of(context).pop();
                    }
                  },
                ),
                actions: <Widget>[
                  TextButton(
                    child: const Text('Cancel'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  TextButton(
                    child: const Text('Add'),
                    onPressed: () {
                      if (newTaskName.isNotEmpty) {
                        Provider.of<TodoData>(context, listen: false)
                            .addTask(newTaskName);
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                ],
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class TodoListItem extends StatelessWidget {
  final TodoTask task;
  final VoidCallback onRemove;
  final VoidCallback onToggle;

  const TodoListItem({super.key, required this.task, required this.onRemove, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(task.name),
      onDismissed: (direction) {
        onRemove();
      },
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20.0),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: ListTile(
        leading: Checkbox(
          value: task.isDone,
          onChanged: (bool? value) {
            onToggle();
          },
        ),
        title: Text(
          task.name,
          style: TextStyle(
            decoration: task.isDone ? TextDecoration.lineThrough : null,
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: onRemove,
        ),
      ),
    );
  }
}
