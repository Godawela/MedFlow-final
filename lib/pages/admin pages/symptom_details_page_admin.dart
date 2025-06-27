import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:med/widgets/appbar.dart';
import 'package:url_launcher/url_launcher.dart';

class SymptomDetailPageAdmin extends StatefulWidget {
  final String symptomName;

  const SymptomDetailPageAdmin({super.key, required this.symptomName});

  @override
  State<SymptomDetailPageAdmin> createState() => _SymptomDetailPageAdminState();
}

class _SymptomDetailPageAdminState extends State<SymptomDetailPageAdmin> with TickerProviderStateMixin {
  Map<String, dynamic>? symptomDetails;
  bool isLoading = true;
  bool isEditing = false;
  bool isUpdating = false;
  String? error;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  // Controllers for editing
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _resourceLinkController = TextEditingController();
    Timer? _refreshTimer;


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
    
    fetchSymptomDetails();
     _refreshTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      fetchSymptomDetails();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _resourceLinkController.dispose();
        _refreshTimer?.cancel();

    super.dispose();
  }

  Future<void> fetchSymptomDetails() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/symptoms/name/${widget.symptomName}'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> detail = json.decode(response.body);
        
        if (detail.isNotEmpty) {
          setState(() {
            symptomDetails = detail;
            isLoading = false;
            // Initialize controllers with current data
            _nameController.text = detail['name'] ?? '';
            _descriptionController.text = detail['description'] ?? '';
            _resourceLinkController.text = detail['resourceLink'] ?? '';
          });
          _animationController.forward();
        } else {
          setState(() {
            isLoading = false;
            error = 'No symptom details found';
          });
        }
      } else {
        setState(() {
          isLoading = false;
          error = 'Failed to load details: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        error = 'Error: $e';
      });
    }
  }

  Future<void> updateSymptom() async {
    if (symptomDetails == null) return;
    
    setState(() {
      isUpdating = true;
    });

    try {
      final Map<String, dynamic> updatedData = {
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'resourceLink': _resourceLinkController.text.trim(),
      };

      final response = await http.patch(
        Uri.parse('http://10.0.2.2:8000/api/symptoms/${symptomDetails!['_id']}'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(updatedData),
      );

      if (response.statusCode == 200) {
        final updatedSymptom = json.decode(response.body);
        setState(() {
          symptomDetails = updatedSymptom;
          isEditing = false;
          isUpdating = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Symptom updated successfully!'),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      } else {
        throw Exception('Failed to update symptom: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isUpdating = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating symptom: $e'),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  Future<void> deleteSymptom() async {
    if (symptomDetails == null) return;

    // Show confirmation dialog
    final bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange.shade600),
              const SizedBox(width: 8),
              const Text('Delete Symptom'),
            ],
          ),
          content: Text(
            'Are you sure you want to delete "${symptomDetails!['name']}"? This action cannot be undone.',
            style: GoogleFonts.inter(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      try {
        final response = await http.delete(
          Uri.parse('http://10.0.2.2:8000/api/symptoms/${symptomDetails!['_id']}'),
        );

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Symptom deleted successfully!'),
              backgroundColor: Colors.green.shade600,
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.of(context).pop(); // Go back to previous screen
        } else {
          throw Exception('Failed to delete symptom: ${response.statusCode}');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting symptom: $e'),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _toggleEdit() {
    setState(() {
      isEditing = !isEditing;
      if (!isEditing) {
        // Reset controllers if canceling edit
        _nameController.text = symptomDetails!['name'] ?? '';
        _descriptionController.text = symptomDetails!['description'] ?? '';
        _resourceLinkController.text = symptomDetails!['resourceLink'] ?? '';
      }
    });
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch $url')),
      );
    }
  }

  Widget _buildEditableField(String label, TextEditingController controller, {int maxLines = 1}) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple.shade800,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: controller,
              maxLines: maxLines,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.deepPurple.shade400, width: 2),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              style: GoogleFonts.inter(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard(String title, String content, IconData icon) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.deepPurple.shade700,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple.shade800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              content,
              style: GoogleFonts.inter(
                fontSize: 16,
                color: Colors.grey.shade800,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

// Replace the build method in your SymptomDetailPage with this fixed version

@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.grey.shade50,
    body: Column(
      children: [
        CurvedAppBar(
          title: isEditing ? 'Edit Symptom' : widget.symptomName,
          isProfileAvailable: false,
          showIcon: true,
          isBack: true,
        ),
        Expanded(
          child: isLoading
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                        )],
                        ),
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.deepPurple.shade400,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Loading symptom details...',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )
              : error != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.error_outline_rounded,
                              size: 48,
                              color: Colors.red.shade400,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Oops! Something went wrong',
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
                            onPressed: () {
                              setState(() {
                                isLoading = true;
                                error = null;
                              });
                              fetchSymptomDetails();
                            },
                            icon: const Icon(Icons.refresh_rounded),
                            label: const Text('Try Again'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade500,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
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
                          child: Column(
                            children: [
                              // MAIN CONTENT - Scrollable
                              Expanded(
                                child: SingleChildScrollView(
                                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0), // Remove bottom padding
                                  child: Column(
                                    children: [
                                      // Symptom header with action buttons
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
                                          borderRadius: BorderRadius.circular(20),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.deepPurple.withOpacity(0.3),
                                              blurRadius: 12,
                                              offset: const Offset(0, 6),
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(16),
                                              decoration: BoxDecoration(
                                                color: Colors.white.withOpacity(0.2),
                                                borderRadius: BorderRadius.circular(16),
                                              ),
                                              child: Icon(
                                                isEditing ? Icons.edit_rounded : Icons.health_and_safety_rounded,
                                                size: 40,
                                                color: Colors.white,
                                              ),
                                            ),
                                            const SizedBox(height: 16),
                                            Text(
                                              isEditing ? 'Editing Symptom' : (symptomDetails!['name'] ?? widget.symptomName),
                                              style: GoogleFonts.inter(
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                            const SizedBox(height: 20),
                                            // Action buttons in header
                                            if (isEditing) ...[
                                              // Update and Cancel buttons
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: ElevatedButton.icon(
                                                      onPressed: isUpdating ? null : updateSymptom,
                                                      icon: isUpdating
                                                          ? const SizedBox(
                                                              width: 16,
                                                              height: 16,
                                                              child: CircularProgressIndicator(
                                                                strokeWidth: 2,
                                                                valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                                                              ),
                                                            )
                                                          : const Icon(Icons.check_rounded, size: 18),
                                                      label: Text(
                                                        isUpdating ? 'Saving...' : 'Save',
                                                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                                      ),
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor: Colors.green.shade600,
                                                        foregroundColor: Colors.white,
                                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(10),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Expanded(
                                                    child: ElevatedButton.icon(
                                                      onPressed: _toggleEdit,
                                                      icon: const Icon(Icons.close_rounded, size: 18),
                                                      label: const Text(
                                                        'Cancel',
                                                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                                      ),
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor: Colors.white.withOpacity(0.2),
                                                        foregroundColor: Colors.white,
                                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(10),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ] else ...[
                                              // Edit and Delete buttons
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: ElevatedButton.icon(
                                                      onPressed: _toggleEdit,
                                                      icon: const Icon(Icons.edit_rounded, size: 18),
                                                      label: const Text(
                                                        'Edit',
                                                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                                      ),
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor: Colors.white.withOpacity(0.2),
                                                        foregroundColor: Colors.white,
                                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(10),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Expanded(
                                                    child: ElevatedButton.icon(
                                                      onPressed: deleteSymptom,
                                                      icon: const Icon(Icons.delete_rounded, size: 18),
                                                      label: const Text(
                                                        'Delete',
                                                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                                      ),
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor: Colors.red.shade600,
                                                        foregroundColor: Colors.white,
                                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(10),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                      
                                      const SizedBox(height: 24),
                                      
                                      // Content based on edit mode
                                      if (isEditing) ...[
                                        _buildEditableField('Name', _nameController),
                                        _buildEditableField('Description', _descriptionController, maxLines: 5),
                                        _buildEditableField('Resource Link', _resourceLinkController),
                                      ] else ...[
                                        // Display mode
                                        if (symptomDetails!['description'] != null)
                                          _buildDetailCard(
                                            'Description',
                                            symptomDetails!['description'],
                                            Icons.description_rounded,
                                          ),
                                        
                                        if (symptomDetails!['resourceLink'] != null && 
                                            symptomDetails!['resourceLink'].toString().isNotEmpty) ...[
                                          const SizedBox(height: 16),
                                          Center(
                                            child: ElevatedButton.icon(
                                              onPressed: () {
                                                _launchURL(symptomDetails!['resourceLink']);
                                              },
                                              icon: const Icon(Icons.link_rounded),
                                              label: const Text('View Resource'),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.deepPurple.shade500,
                                                foregroundColor: Colors.white,
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 24,
                                                  vertical: 16,
                                                ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(15),
                                                ),
                                                elevation: 5,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                      
                                      // Add some space at bottom so content doesn't get hidden behind buttons
                                      const SizedBox(height: 20),
                                    ],
                                  ),
                                ),
                              ),

                            ],
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