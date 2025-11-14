import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import for haptics
import 'package:table_calendar/table_calendar.dart';
import 'package:task_manager/widgets.dart';
import 'package:task_manager/task_model.dart';
import 'package:uuid/uuid.dart';
import 'dart:collection'; 
import 'package:provider/provider.dart';
import 'package:task_manager/profile_provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => CalendarScreenState();
}

class CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  late final LinkedHashMap<DateTime, List<Task>> _tasks;
  List<Task> _selectedTasks = [];

  final TextEditingController _taskController = TextEditingController();
  final Uuid _uuid = const Uuid(); 

  Priority _selectedPriority = Priority.low;

  DateTime _normalizeDate(DateTime date) {
    return DateTime.utc(date.year, date.month, date.day);
  }

  @override
  void initState() {
    super.initState();
    _selectedDay = _normalizeDate(_focusedDay);

    _tasks = LinkedHashMap<DateTime, List<Task>>(
      equals: isSameDay,
      hashCode: (key) => key.day * 1000000 + key.month * 10000 + key.year,
    )..addAll({
        _normalizeDate(DateTime.now()): [
          Task(
            id: _uuid.v4(),
            title: 'Design team meeting',
            date: _normalizeDate(DateTime.now()),
            priority: Priority.high,
          ),
          Task(
            id: _uuid.v4(),
            title: 'Finish Flutter UI',
            date: _normalizeDate(DateTime.now()),
            priority: Priority.medium,
          ),
        ],
        _normalizeDate(DateTime.now().add(const Duration(days: 1))): [
          Task(
            id: _uuid.v4(),
            title: 'Buy groceries',
            date: _normalizeDate(DateTime.now().add(const Duration(days: 1))),
          ),
        ],
      });
    _selectedTasks = _getTasksForDay(_selectedDay!);
  }
  
  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  List<Task> _getTasksForDay(DateTime day) {
    return _tasks[day] ?? [];
  }

  void _deleteTask(String taskId) {
    setState(() {
      _selectedTasks.removeWhere((task) => task.id == taskId);
      if (_tasks.containsKey(_selectedDay)) {
        _tasks[_selectedDay!]!.removeWhere((task) => task.id == taskId);
      }
    });
  }

  void _showEditTaskDialog(Task task) {
    _taskController.text = task.title;
    _selectedPriority = task.priority;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, 
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Edit Task', 
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _taskController,
                      autofocus: true, 
                      decoration: const InputDecoration(
                        labelText: 'Task Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text('Select Priority', style: TextStyle(fontSize: 16)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Radio<Priority>(
                          value: Priority.low,
                          groupValue: _selectedPriority,
                          onChanged: (value) => setModalState(() => _selectedPriority = value!),
                        ),
                        const Text('Low'),
                        Radio<Priority>(
                          value: Priority.medium,
                          groupValue: _selectedPriority,
                          onChanged: (value) => setModalState(() => _selectedPriority = value!),
                        ),
                        const Text('Medium'),
                        Radio<Priority>(
                          value: Priority.high,
                          groupValue: _selectedPriority,
                          onChanged: (value) => setModalState(() => _selectedPriority = value!),
                        ),
                        const Text('High'),
                      ],
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3B2E7E),
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      onPressed: () => _editTask(task),
                      child: const Text(
                        'Save Changes',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _editTask(Task task) {
    final newTitle = _taskController.text;
    if (newTitle.isEmpty) {
      Navigator.pop(context);
      return;
    }
    setState(() {
      task.title = newTitle;
      task.priority = _selectedPriority;
    });
    Navigator.pop(context);
  }

  void showAddTaskDialog() {
    _taskController.clear();
    _selectedPriority = Priority.low;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, 
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Add New Task',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _taskController,
                      autofocus: true, 
                      decoration: const InputDecoration(
                        labelText: 'Task Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text('Select Priority', style: TextStyle(fontSize: 16)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Radio<Priority>(
                          value: Priority.low,
                          groupValue: _selectedPriority,
                          onChanged: (value) => setModalState(() => _selectedPriority = value!),
                        ),
                        const Text('Low'),
                        Radio<Priority>(
                          value: Priority.medium,
                          groupValue: _selectedPriority,
                          onChanged: (value) => setModalState(() => _selectedPriority = value!),
                        ),
                        const Text('Medium'),
                        Radio<Priority>(
                          value: Priority.high,
                          groupValue: _selectedPriority,
                          onChanged: (value) => setModalState(() => _selectedPriority = value!),
                        ),
                        const Text('High'),
                      ],
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3B2E7E),
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      onPressed: _addTask,
                      child: const Text(
                        'Save Task',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // --- THIS FUNCTION IS NOW FIXED ---
  void _addTask() {
    final taskName = _taskController.text;
    if (taskName.isEmpty) {
      Navigator.pop(context);
      return;
    }

    final newTask = Task(
      id: _uuid.v4(),
      title: taskName,
      date: _selectedDay!,
      priority: _selectedPriority,
    );

    setState(() {
      final tasksForDay = _tasks[_selectedDay] ?? [];
      tasksForDay.add(newTask);
      _tasks[_selectedDay!] = tasksForDay;
      _selectedTasks = _getTasksForDay(_selectedDay!);
    });

    // --- THIS IS THE CORRECTED LINE ---
    HapticFeedback.lightImpact();

    Navigator.pop(context);
  }
  // --- END OF FIX ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Consumer<ProfileProvider>(
            builder: (context, profileProvider, child) {
              return profileProvider.getProfileAvatar();
            },
          ),
        ),
        title: Icon(
          Icons.check_circle_outline,
          color: Theme.of(context).iconTheme.color,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(20.0),
            child: Text(
              'Calender',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor, 
              borderRadius: BorderRadius.circular(20),
            ),
            child: TableCalendar(
              firstDay: DateTime.utc(2010, 10, 16),
              lastDay: DateTime.utc(2030, 3, 14),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              eventLoader: _getTasksForDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                if (!isSameDay(_selectedDay, selectedDay)) {
                  setState(() {
                    _selectedDay = _normalizeDate(selectedDay);
                    _focusedDay = focusedDay;
                    _selectedTasks = _getTasksForDay(_selectedDay!);
                  });
                }
              },
              onFormatChanged: (format) {
                if (_calendarFormat != format) {
                  setState(() => _calendarFormat = format);
                }
              },
              onPageChanged: (focusedDay) => _focusedDay = focusedDay,
              headerStyle: const HeaderStyle(
                titleCentered: true,
                formatButtonVisible: false,
                titleTextStyle: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              calendarStyle: CalendarStyle(
                selectedDecoration: const BoxDecoration(
                  color: Color(0xFF3B2E7E),
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: const Color(0xFF3B2E7E).withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                markersMaxCount: 1,
                markerSize: 5.0,
                markerDecoration: const BoxDecoration(
                  color: Color(0xFF3B2E7E),
                  shape: BoxShape.circle,
                ),
                defaultTextStyle: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
                weekendTextStyle: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black),
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: _selectedTasks.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_outline, size: 80, color: Colors.grey.withOpacity(0.5)),
                          const SizedBox(height: 16),
                          const Text(
                            "No tasks for this day.",
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : AnimationLimiter(
                      child: ListView.builder(
                        itemCount: _selectedTasks.length,
                        itemBuilder: (context, index) {
                          final task = _selectedTasks[index];
                          
                          return AnimationConfiguration.staggeredList(
                            position: index,
                            duration: const Duration(milliseconds: 375),
                            child: SlideAnimation(
                              verticalOffset: 50.0,
                              child: FadeInAnimation(
                                child: TaskItem(
                                  task: task,
                                  onDismissed: (id) {
                                    _deleteTask(id);
                                  },
                                  onTap: (task) {
                                    _showEditTaskDialog(task);
                                  },
                                ),
                              ),
                            ),
                          ); 
                        },
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}