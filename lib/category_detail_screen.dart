import 'package:flutter/material.dart';
import 'package:task_manager/widgets.dart'; 
import 'package:task_manager/task_model.dart';
import 'package:uuid/uuid.dart'; 
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class CategoryDetailScreen extends StatefulWidget {
  final String categoryTitle;

  const CategoryDetailScreen({
    super.key,
    required this.categoryTitle,
  });

  @override
  State<CategoryDetailScreen> createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen> {
  
  late List<Task> _tasks;

  @override
  void initState() {
    super.initState();
    _loadDummyTasks();
  }

  void _loadDummyTasks() {
    final Uuid uuid = const Uuid();
    _tasks = [
      Task(
        id: uuid.v4(),
        title: 'Task 1 for ${widget.categoryTitle}',
        date: DateTime.now(),
        priority: Priority.low
      ),
      Task(
        id: uuid.v4(),
        title: 'Task 2 for ${widget.categoryTitle}',
        date: DateTime.now(),
        priority: Priority.medium,
        isDone: true,
      ),
      Task(
        id: uuid.v4(),
        title: 'Task 3 for ${widget.categoryTitle}',
        date: DateTime.now(),
        priority: Priority.high
      ),
    ];
  }

  void _deleteTask(String taskId) {
    setState(() {
      _tasks.removeWhere((task) => task.id == taskId);
    });
  }
  
  void _editTask(Task task) {
    setState(() {
      task.isDone = !task.isDone;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          widget.categoryTitle,
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // --- UPDATED EMPTY STATE ---
            Expanded(
              child: _tasks.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inbox_outlined, size: 80, color: Colors.grey.withOpacity(0.5)),
                          const SizedBox(height: 16),
                          const Text(
                            "No tasks in this category.",
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : AnimationLimiter(
                      child: ListView.builder(
                        itemCount: _tasks.length,
                        itemBuilder: (context, index) {
                          
                          return AnimationConfiguration.staggeredList(
                            position: index,
                            duration: const Duration(milliseconds: 375),
                            child: SlideAnimation(
                              verticalOffset: 50.0,
                              child: FadeInAnimation(
                                child: TaskItem(
                                  task: _tasks[index],
                                  onDismissed: (id) {
                                    _deleteTask(id);
                                  },
                                  onTap: (task) {
                                    _editTask(task);
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Add logic to add a new task to this category
        },
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add),
      ),
    );
  }
}