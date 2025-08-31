// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class UpdateDevicePopup extends StatefulWidget {
  final Map<String, dynamic> deviceData;
  final VoidCallback onUpdateSuccess;

  const UpdateDevicePopup({
    super.key,
    required this.deviceData,
    required this.onUpdateSuccess,
  });

  @override
  _UpdateDevicePopupState createState() => _UpdateDevicePopupState();

  // Static method to show the popup
  static void show({
    required BuildContext context,
    required Map<String, dynamic> deviceData,
    required VoidCallback onUpdateSuccess,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return UpdateDevicePopup(
          deviceData: deviceData,
          onUpdateSuccess: onUpdateSuccess,
        );
      },
    );
  }
}

class _UpdateDevicePopupState extends State<UpdateDevicePopup>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _categoryController;
  late TextEditingController _descriptionController;
  late TextEditingController _referenceController;
  late TextEditingController _linkController;

  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize controllers with existing data
    _nameController =
        TextEditingController(text: widget.deviceData['name'] ?? '');
    _categoryController =
        TextEditingController(text: widget.deviceData['category'] ?? '');
    _descriptionController =
        TextEditingController(text: widget.deviceData['description'] ?? '');
    _referenceController =
        TextEditingController(text: widget.deviceData['reference'] ?? '');
    _linkController =
        TextEditingController(text: widget.deviceData['linkOfResource'] ?? '');

    // Setup animation
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _descriptionController.dispose();
    _referenceController.dispose();
    _linkController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _updateDevice() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final updatedData = {
        'name': _nameController.text.trim(),
        'category': _categoryController.text.trim(),
        'description': _descriptionController.text.trim(),
        'reference': _referenceController.text.trim(),
        'linkOfResource': _linkController.text.trim(),
      };

      final response = await http.patch(
        Uri.parse(
            'https://medflow-phi.vercel.app/api/devices/${widget.deviceData['_id']}'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(updatedData),
      );

      if (response.statusCode == 200) {
        Navigator.of(context).pop();
        widget.onUpdateSuccess();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Device updated successfully!'),
              ],
            ),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      } else {
        throw Exception('Failed to update device: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text('Error: ${e.toString()}')),
            ],
          ),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: Colors.deepPurple.shade600),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.deepPurple.shade600, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
          labelStyle: GoogleFonts.inter(color: Colors.deepPurple.shade700),
          hintStyle: GoogleFonts.inter(color: Colors.grey.shade500),
        ),
        style: GoogleFonts.inter(fontSize: 16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.8,
                maxWidth: MediaQuery.of(context).size.width * 0.9,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha:0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.deepPurple.shade500,
                          Colors.deepPurple.shade700,
                        ],
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha:0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.edit_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Update Device',
                            style: GoogleFonts.inter(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close_rounded,
                              color: Colors.white),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white.withValues(alpha:0.2),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Form content
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            _buildInputField(
                              controller: _nameController,
                              label: 'Device Name',
                              icon: Icons.medical_services_rounded,
                              hint: 'Enter device name',
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Device name is required';
                                }
                                return null;
                              },
                            ),

                            _buildInputField(
                              controller: _referenceController,
                              label: 'Device Ref No',
                              icon: Icons.badge_rounded,
                              hint: 'Enter reference number',
                            ),

                            _buildInputField(
                              controller: _categoryController,
                              label: 'Category',
                              icon: Icons.category_rounded,
                              hint: 'Enter device category',
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Category is required';
                                }
                                return null;
                              },
                            ),

                            _buildInputField(
                              controller: _descriptionController,
                              label: 'Description',
                              icon: Icons.description_rounded,
                              hint: 'Enter device description',
                              maxLines: 3,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Description is required';
                                }
                                return null;
                              },
                            ),

                            _buildInputField(
                              controller: _linkController,
                              label: 'Resource Link',
                              icon: Icons.link_rounded,
                              hint: 'Enter resource URL (optional)',
                              validator: (value) {
                                if (value != null && value.isNotEmpty) {
                                  if (!Uri.tryParse(value)!.hasAbsolutePath ==
                                      true) {
                                    return 'Please enter a valid URL';
                                  }
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 20),

                            // Action buttons
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: _isLoading
                                        ? null
                                        : () => Navigator.of(context).pop(),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16),
                                      side: BorderSide(
                                          color: Colors.grey.shade400),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: Text(
                                      'Cancel',
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed:
                                        _isLoading ? null : _updateDevice,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          Colors.deepPurple.shade600,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 2,
                                    ),
                                    child: _isLoading
                                        ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                      Colors.white),
                                            ),
                                          )
                                        : Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const SizedBox(width: 8),
                                              Text(
                                                'Update',
                                                style: GoogleFonts.inter(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
