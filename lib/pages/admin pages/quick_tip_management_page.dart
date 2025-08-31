// Quick Tips Management Page


// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class QuickTipsManagementPage extends StatefulWidget {
  const QuickTipsManagementPage({super.key});

  @override
  QuickTipsManagementPageState createState() => QuickTipsManagementPageState();
}

class QuickTipsManagementPageState extends State<QuickTipsManagementPage>
    with TickerProviderStateMixin {
  List<dynamic> categories = [];
  List<dynamic> quickTips = [];
  String? selectedCategoryId;
  String? selectedCategoryName;
  bool isLoadingCategories = true;
  bool isLoadingTips = false;
  String? error;
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final TextEditingController _tipTitleController = TextEditingController();
  final TextEditingController _tipContentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    fetchCategories();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _tipTitleController.dispose();
    _tipContentController.dispose();
    super.dispose();
  }

  Future<void> fetchCategories() async {
    try {
      final response = await http.get(
        Uri.parse('https://medflow-phi.vercel.app/api/category'),
        headers: {
          'Cache-Control': 'no-cache, no-store, must-revalidate',
          'Pragma': 'no-cache',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> fetchedCategories = json.decode(response.body);
        setState(() {
          categories = fetchedCategories;
          isLoadingCategories = false;
        });
        _animationController.forward();
      } else {
        setState(() {
          error = 'Failed to load categories: ${response.statusCode}';
          isLoadingCategories = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Error: $e';
        isLoadingCategories = false;
      });
    }
  }

  Future<void> fetchQuickTips(String categoryId) async {
    setState(() {
      isLoadingTips = true;
      quickTips = [];
    });

    try {
      final response = await http.get(
        Uri.parse('https://medflow-phi.vercel.app/api/quicktips/category/$categoryId'),
        headers: {
          'Cache-Control': 'no-cache, no-store, must-revalidate',
          'Pragma': 'no-cache',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          quickTips = responseData['data']['tips'] ?? [];
          isLoadingTips = false;
        });
      } else if (response.statusCode == 404) {
        setState(() {
          quickTips = [];
          isLoadingTips = false;
        });
      } else {
        setState(() {
          error = 'Failed to load quick tips: ${response.statusCode}';
          isLoadingTips = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Error: $e';
        isLoadingTips = false;
      });
    }
  }

  Future<void> addTip() async {
    if (selectedCategoryId == null || 
        _tipTitleController.text.trim().isEmpty || 
        _tipContentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields and select a category'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('https://medflow-phi.vercel.app/api/quicktips/category/$selectedCategoryId/tip'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'title': _tipTitleController.text.trim(),
          'content': _tipContentController.text.trim(),
        }),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tip added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        _tipTitleController.clear();
        _tipContentController.clear();
        fetchQuickTips(selectedCategoryId!);
      } else {
        throw Exception('Failed to add tip: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding tip: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> updateTip(String tipId, String title, String content) async {
    try {
      final response = await http.put(
        Uri.parse('https://medflow-phi.vercel.app/api/quicktips/category/$selectedCategoryId/tip/$tipId'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'title': title,
          'content': content,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tip updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        fetchQuickTips(selectedCategoryId!);
      } else {
        throw Exception('Failed to update tip: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating tip: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> deleteTip(String tipId) async {
    try {
      final response = await http.delete(
        Uri.parse('https://medflow-phi.vercel.app/api/quicktips/category/$selectedCategoryId/tip/$tipId'),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tip deleted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        fetchQuickTips(selectedCategoryId!);
      } else {
        throw Exception('Failed to delete tip: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting tip: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void showAddTipDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.deepPurple.shade50,
                  Colors.white,
                ],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.lightbulb_outline_rounded,
                        color: Colors.deepPurple.shade600,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Add Quick Tip',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _tipTitleController,
                  decoration: InputDecoration(
                    labelText: 'Tip Title',
                    hintText: 'Enter a descriptive title',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.deepPurple.shade400),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _tipContentController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: 'Tip Content',
                    hintText: 'Enter the tip content...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.deepPurple.shade400),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _tipTitleController.clear();
                        _tipContentController.clear();
                      },
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.inter(
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        addTip();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple.shade500,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Add Tip',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void showEditTipDialog(Map<String, dynamic> tip) {
    final titleController = TextEditingController(text: tip['title']);
    final contentController = TextEditingController(text: tip['content']);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.blue.shade50,
                  Colors.white,
                ],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.edit_rounded,
                        color: Colors.blue.shade600,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Edit Quick Tip',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Tip Title',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.blue.shade400),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: contentController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: 'Tip Content',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.blue.shade400),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.inter(
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        updateTip(
                          tip['_id'],
                          titleController.text.trim(),
                          contentController.text.trim(),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade500,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Update',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void showDeleteConfirmDialog(String tipId, String tipTitle) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.red.shade400,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                'Delete Tip',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to delete "$tipTitle"? This action cannot be undone.',
            style: GoogleFonts.inter(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: GoogleFonts.inter(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                deleteTip(tipId);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade500,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Delete',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          'Add Quick Tips',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        centerTitle: true,
        elevation: 0,
        shadowColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoadingCategories
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        size: 64,
                        color: Colors.red.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading data',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.red.shade700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        error!,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.red.shade600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: fetchCategories,
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Retry'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade500,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                )
              : AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Category Selection
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.deepPurple.shade400,
                                      Colors.deepPurple.shade600,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.deepPurple.withValues(alpha:0.3),
                                      blurRadius: 12,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withValues(alpha:0.2),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: const Icon(
                                            Icons.category_rounded,
                                            color: Colors.white,
                                            size: 24,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          'Select Category',
                                          style: GoogleFonts.inter(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          value: selectedCategoryId,
                                          hint: Text(
                                            'Choose a category to manage tips',
                                            style: GoogleFonts.inter(
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                          isExpanded: true,
                                          items: categories.map<DropdownMenuItem<String>>((category) {
                                            return DropdownMenuItem<String>(
                                              value: category['_id'],
                                              child: Text(
                                                category['name'],
                                                style: GoogleFonts.inter(
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                          onChanged: (String? newValue) {
                                            if (newValue != null) {
                                              setState(() {
                                                selectedCategoryId = newValue;
                                                selectedCategoryName = categories
                                                    .firstWhere((cat) => cat['_id'] == newValue)['name'];
                                              });
                                              fetchQuickTips(newValue);
                                            }
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 24),

                              if (selectedCategoryId != null) ...[
                                // Header with add button
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Quick Tips for $selectedCategoryName',
                                        style: GoogleFonts.inter(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey.shade800,
                                        ),
                                      ),
                                    ),
                                    ElevatedButton.icon(
                                      onPressed: showAddTipDialog,
                                      icon: const Icon(Icons.add_rounded),
                                      label: const Text('Add Tip'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.deepPurple.shade500,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 12,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 16),

                                // Tips list
                                Expanded(
                                  child: isLoadingTips
                                      ? const Center(child: CircularProgressIndicator())
                                      : quickTips.isEmpty
                                          ? Center(
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets.all(24),
                                                    decoration: BoxDecoration(
                                                      color: Colors.grey.shade100,
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: Icon(
                                                      Icons.lightbulb_outline_rounded,
                                                      size: 48,
                                                      color: Colors.grey.shade400,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 16),
                                                  Text(
                                                    'No quick tips yet',
                                                    style: GoogleFonts.inter(
                                                      fontSize: 18,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.grey.shade600,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    'Add your first tip for this category',
                                                    style: GoogleFonts.inter(
                                                      fontSize: 14,
                                                      color: Colors.grey.shade500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                          : ListView.builder(
                                              itemCount: quickTips.length,
                                              itemBuilder: (context, index) {
                                                final tip = quickTips[index];
                                                return Container(
                                                  margin: const EdgeInsets.only(bottom: 12),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius: BorderRadius.circular(16),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black.withValues(alpha:0.05),
                                                        blurRadius: 8,
                                                        offset: const Offset(0, 2),
                                                      ),
                                                    ],
                                                  ),
                                                  child: ListTile(
                                                    contentPadding: const EdgeInsets.all(16),
                                                    leading: Container(
                                                      padding: const EdgeInsets.all(8),
                                                      decoration: BoxDecoration(
                                                        color: Colors.deepPurple.shade100,
                                                        borderRadius: BorderRadius.circular(8),
                                                      ),
                                                      child: Icon(
                                                        Icons.lightbulb_rounded,
                                                        color: Colors.deepPurple.shade600,
                                                        size: 20,
                                                      ),
                                                    ),
                                                    title: Text(
                                                      tip['title'] ?? 'Untitled',
                                                      style: GoogleFonts.inter(
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                    subtitle: Padding(
                                                      padding: const EdgeInsets.only(top: 8),
                                                      child: Text(
                                                        tip['content'] ?? '',
                                                        style: GoogleFonts.inter(
                                                          color: Colors.grey.shade600,
                                                          fontSize: 14,
                                                        ),
                                                        maxLines: 2,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                    trailing: Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        IconButton(
                                                          onPressed: () => showEditTipDialog(tip),
                                                          icon: Icon(
                                                            Icons.edit_rounded,
                                                            color: Colors.blue.shade500,
                                                            size: 20,
                                                          ),
                                                        ),
                                                        IconButton(
                                                          onPressed: () => showDeleteConfirmDialog(
                                                            tip['_id'],
                                                            tip['title'] ?? 'Untitled',
                                                          ),
                                                          icon: Icon(
                                                            Icons.delete_rounded,
                                                            color: Colors.red.shade500,
                                                            size: 20,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}