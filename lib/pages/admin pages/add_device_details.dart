
// ignore_for_file: use_build_context_synchronously

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

@RoutePage()
class AddDevicePage extends StatefulWidget {
  const AddDevicePage({super.key});

  @override
  AddDevicePageState createState() => AddDevicePageState();
}

class AddDevicePageState extends State<AddDevicePage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _referenceController = TextEditingController();
  final TextEditingController _linkOfResourceController =
      TextEditingController();

  bool isLoading = false;
  String? errorMessage;

  List<dynamic> _categories = [];
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    try {
      final response = await http
          .get(Uri.parse('https://medflow-phi.vercel.app/api/category'));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _categories = data;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load categories.';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching categories: $e';
      });
    }
  }

  Future<void> _submitDevice() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_selectedCategory == null) {
      setState(() {
        errorMessage = 'Please select a category.';
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final deviceData = {
      'name': _nameController.text,
      'category': _selectedCategory,
      'description': _descriptionController.text,
      'reference': _referenceController.text,
      'linkOfResource': _linkOfResourceController.text,
    };

    try {
      final response = await http.post(
        Uri.parse('https://medflow-phi.vercel.app/api/devices'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(deviceData),
      );

      if (response.statusCode == 201) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Device added successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context, true);
      } else {
        setState(() {
          errorMessage =
              'Failed to add device. Status code: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Theme.of(context).primaryColor),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Add New Device',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.deepPurple.shade400,
                      Colors.deepPurple.shade600,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: Theme.of(context).primaryColor.withValues(alpha:0.2)),
                ),
                child: const Column(
                  children: [
                    Icon(
                      Icons.add_circle_outline,
                      size: 48,
                      color: Colors.white,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Create New Device',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Fill in the details below to add a new device to your inventory',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Form Section
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha:0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Device Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Reference Field
                      TextFormField(
                        controller: _referenceController,
                        decoration:
                            _buildInputDecoration('Device Ref No', Icons.tag),
                        validator: (value) =>
                            value!.isEmpty ? 'Please enter a reference' : null,
                      ),
                      const SizedBox(height: 20),

                      // Device Name Field
                      TextFormField(
                        controller: _nameController,
                        decoration:
                            _buildInputDecoration('Device Name', Icons.devices),
                        validator: (value) => value!.isEmpty
                            ? 'Please enter a device name'
                            : null,
                      ),
                      const SizedBox(height: 20),

                      // Category Dropdown
                      DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration:
                            _buildInputDecoration('Category', Icons.category),
                        items: _categories.map((category) {
                          return DropdownMenuItem<String>(
                            value: category['name'],
                            child: Text(category['name']),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value;
                          });
                        },
                        validator: (value) =>
                            value == null ? 'Please select a category' : null,
                        icon: const Icon(Icons.keyboard_arrow_down),
                        dropdownColor: Colors.white,
                      ),
                      const SizedBox(height: 20),

                      // Description Field
                      TextFormField(
                        controller: _descriptionController,
                        decoration: _buildInputDecoration(
                            'Description', Icons.description),
                        maxLines: 3,
                        validator: (value) => value!.isEmpty
                            ? 'Please enter a description'
                            : null,
                      ),
                      const SizedBox(height: 20),

                      // Link Field
                      TextFormField(
                        controller: _linkOfResourceController,
                        decoration:
                            _buildInputDecoration('Resource Link', Icons.link),
                        validator: (value) => value!.isEmpty
                            ? 'Please enter a resource link'
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Error Message
              if (errorMessage != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red.shade600),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          errorMessage!,
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _submitDevice,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                    shadowColor:
                        Theme.of(context).primaryColor.withValues(alpha:0.3),
                  ),
                  child: isLoading
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Adding Device...',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        )
                      : const Text(
                          'Add Device',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
