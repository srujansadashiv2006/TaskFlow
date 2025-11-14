import 'package:flutter/material.dart';
import 'package:task_manager/widgets.dart'; 
import 'package:task_manager/category_detail_screen.dart';
import 'package:provider/provider.dart';
import 'package:task_manager/profile_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Widget> _taskCards = [];
  List<Widget> _noteCards = [];
  
  final TextEditingController _categoryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Use addPostFrameCallback to safely access context
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialCards();
    });
  }

  @override
  void dispose() {
    _categoryController.dispose();
    super.dispose();
  }

  void _loadInitialCards() {
    _taskCards = [
      CategoryCard(
        title: 'Health + Fitness',
        emoji: '🏋️',
        color: const Color(0xFFCCFFCC), 
        onTap: () => _navigateToCategory(context, 'Health + Fitness'),
      ),
      CategoryCard(
        title: 'Work',
        emoji: '💼',
        color: const Color(0xFFF0C8C8), 
        onTap: () => _navigateToCategory(context, 'Work'),
      ),
      CategoryCard(
        title: 'Personal',
        emoji: '🏠',
        color: const Color(0xFFC8E6F0), 
        onTap: () => _navigateToCategory(context, 'Personal'),
      ),
    ];
    
    _noteCards = [
      CategoryCard(
        title: 'Chemistry',
        emoji: '🧪',
        color: const Color(0xFFFFF0C0), 
        onTap: () => _navigateToCategory(context, 'Chemistry'),
      ),
      CategoryCard(
        title: 'Physics',
        emoji: '⚡',
        color: const Color(0xFFC8E6F0), 
        onTap: () => _navigateToCategory(context, 'Physics'),
      ),
      CategoryCard(
        title: 'Maths',
        emoji: '🧮',
        color: const Color(0xFFDBC8F0), 
        onTap: () => _navigateToCategory(context, 'Maths'),
      ),
    ];
    // Refresh state after loading
    setState(() {});
  }

  void _navigateToCategory(BuildContext context, String title) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryDetailScreen(categoryTitle: title),
      ),
    );
  }

  void _showAddCategoryDialog(String type) {
    _categoryController.clear();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Add New $type',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _categoryController,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Category Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B2E7E),
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: () {
                  _addCategory(type); 
                },
                child: const Text(
                  'Save Category',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addCategory(String type) {
    final title = _categoryController.text;
    if (title.isEmpty) {
      Navigator.pop(context);
      return;
    }

    final newCard = CategoryCard(
      title: title,
      emoji: '✨', 
      color: const Color(0xFFE0E0E0), 
      onTap: () => _navigateToCategory(context, title),
    );

    setState(() {
      if (type == 'Task') {
        _taskCards.add(newCard);
      } else if (type == 'Note') {
        _noteCards.add(newCard);
      }
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor, 
      
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0, 
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          // Use a Consumer to get the provider
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

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader(
                context, 
                'Tasks',
                () => _showAddCategoryDialog('Task'),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 150, 
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: _taskCards, 
                ),
              ),
              const SizedBox(height: 30),
              _buildSectionHeader(
                context, 
                'Notes',
                () => _showAddCategoryDialog('Note'),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 150, 
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: _noteCards,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, VoidCallback onAddPressed) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white, 
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.add, color: Colors.black),
            onPressed: onAddPressed,
          ),
        ),
      ],
    );
  }
}