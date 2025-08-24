// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'dart:io';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:med/widgets/image_upload_widget.dart';

@RoutePage()
class AddSymptomPage extends StatefulWidget {
  const AddSymptomPage({super.key});

  @override
  _AddSymptomPageState createState() => _AddSymptomPageState();
}

class _AddSymptomPageState extends State<AddSymptomPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _linkOfResourceController =
      TextEditingController();
  File? _selectedImage;

  bool isLoading = false;
  String? errorMessage;

Future<void> addSymptom() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() {
    isLoading = true;
    errorMessage = null;
  });

  final url = Uri.parse('https://medflow-phi.vercel.app/api/symptoms');
  final request = http.MultipartRequest('POST', url);

  // Add text fields
  request.fields['name'] = _nameController.text.trim();
  request.fields['description'] = _descriptionController.text.trim();
  request.fields['resourceLink'] = _linkOfResourceController.text.trim();

  // Add image if selected
  if (_selectedImage != null) {
    final imageStream = http.ByteStream(_selectedImage!.openRead());
    final imageLength = await _selectedImage!.length();

    final multipartFile = http.MultipartFile(
      'image',
      imageStream,
      imageLength,
      filename: 'category_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );

    request.files.add(multipartFile);
  }

  try {
    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode == 201 || response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Symptom added successfully!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Clear form
      _nameController.clear();
      _descriptionController.clear();
      _linkOfResourceController.clear();
      setState(() {
        _selectedImage = null;
      });

      Navigator.pop(context, true);
    } else {
      setState(() {
        errorMessage =
            'Failed to add symptom. Status code: ${response.statusCode}\nResponse: $responseBody';
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
      prefixIcon: Icon(icon, color: Colors.purple),
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
        borderSide: const BorderSide(color: Colors.purple, width: 2),
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
          'Add New Symptom',
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
                  border:
                      Border.all(color: Colors.purple.withValues(alpha: 0.2)),
                ),
                child: const Column(
                  children: [
                    Icon(
                      Icons.medical_services_outlined,
                      size: 48,
                      color: Colors.white,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Add Medical Symptom',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Document a new symptom with detailed information and resources',
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
                      color: Colors.black.withValues(alpha: 0.05),
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
                        'Symptom Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Symptom Name Field
                      TextFormField(
                        controller: _nameController,
                        decoration:
                            _buildInputDecoration('Symptom Name', Icons.sick),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please enter symptom name'
                            : null,
                      ),
                      const SizedBox(height: 20),

                      // Image Upload Section
                      Text(
                        'Category Image',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 12),

                      ImageUploadWidget(
                        selectedImage: _selectedImage,
                        onImageSelected: (File? image) {
                          setState(() {
                            _selectedImage = image;
                          });
                        },
                      ),

                      const SizedBox(height: 24),

                      // Description Field
                      TextFormField(
                        controller: _descriptionController,
                        decoration: _buildInputDecoration(
                            'Description', Icons.description),
                        maxLines: 4,
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please enter a description'
                            : null,
                      ),
                      const SizedBox(height: 20),

                      // Resource Link Field
                      TextFormField(
                        controller: _linkOfResourceController,
                        decoration:
                            _buildInputDecoration('Resource Link', Icons.link),
                        validator: (value) => value == null || value.isEmpty
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
                  onPressed: isLoading ? null : addSymptom,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple.shade500,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                    shadowColor: Colors.purple.withValues(alpha: 0.3),
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
                              'Adding Symptom...',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        )
                      : const Text(
                          'Add Symptom',
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

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _linkOfResourceController.dispose();

    super.dispose();
  }
}
