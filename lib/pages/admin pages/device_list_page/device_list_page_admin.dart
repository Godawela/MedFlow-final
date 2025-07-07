//individual catagory information page
// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'dart:async';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:med/pages/admin%20pages/device_list_page/services/catagory_service.dart';
import 'package:med/pages/admin%20pages/device_list_page/widgets/add_device_button.dart';
import 'package:med/pages/admin%20pages/device_list_page/widgets/catagory_header_card.dart';
import 'package:med/pages/admin%20pages/device_list_page/widgets/device_section.dart';
import 'package:med/pages/admin%20pages/device_list_page/widgets/error_widget.dart';
import 'package:med/pages/admin%20pages/device_list_page/widgets/loading_widget.dart';
import 'package:med/pages/admin%20pages/machine_details_admin.dart';
import 'package:med/routes/router.dart';
import 'package:med/widgets/appbar.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class DeviceListPageAdmin extends StatefulWidget {
  final String category;
  const DeviceListPageAdmin({super.key, required this.category});

  @override
  _DeviceListPageAdminState createState() => _DeviceListPageAdminState();
}

class _DeviceListPageAdminState extends State<DeviceListPageAdmin>
    with TickerProviderStateMixin {
  List<dynamic> devices = [];
  bool isLoading = true;
  String? error;
  String? categoryDescription;
  String? categoryId;
  String? categoryImage;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
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

    _loadData();
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    await Future.wait([
      fetchDevicesByCategory(),
      fetchCategoryDescription(),
    ]);
  }

  Future<void> fetchDevicesByCategory() async {
    try {
      final deviceList =
          await CategoryService.getDevicesByCategory(widget.category);
      setState(() {
        devices = deviceList;
        isLoading = false;
      });
      _animationController.forward();
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

Future<void> fetchCategoryDescription() async {
  try {
    debugPrint('Fetching category description for ${widget.category}');
    final categoryData = await CategoryService.getCategoryByName(widget.category);
    debugPrint('Received category data: $categoryData');
    setState(() {
      categoryDescription = categoryData['description'];
      categoryId = categoryData['_id'];
      categoryImage = categoryData['image'];
    });
    debugPrint('Set category ID to: $categoryId');
    debugPrint('Set category image to: $categoryImage');
    
    // DEBUG: Check what getImageUrl() returns
    final constructedUrl = getImageUrl();
    debugPrint('getImageUrl() returned: $constructedUrl');
    
    // DEBUG: Call the service method directly
    final serviceUrl = CategoryService.getImageUrl(categoryImage);
    debugPrint('CategoryService.getImageUrl() returned: $serviceUrl');
    
  } catch (e) {
    debugPrint('Error fetching category description: $e');
    setState(() {
      categoryDescription = 'Error fetching description.';
    });
  }
}

  // Method to construct the full image URL
String? getImageUrl() {
  debugPrint('=== Widget getImageUrl() called ===');
  debugPrint('categoryImage: $categoryImage');
  
  if (categoryImage == null || categoryImage!.isEmpty) {
    debugPrint('categoryImage is null or empty, returning null');
    return null;
  }
  
  // For full URLs (like Cloudinary), return as-is
  if (categoryImage!.startsWith('http://') || categoryImage!.startsWith('https://')) {
    debugPrint('categoryImage is a full URL, returning as-is: $categoryImage');
    return categoryImage;
  }
  
  // For relative paths, construct the full URL
  final constructedUrl = CategoryService.getImageUrl(categoryImage);
  debugPrint('Constructed URL for relative path: $constructedUrl');
  return constructedUrl;
}


  Future<void> updateCategory(String newName, String newDescription,
      {File? imageFile, bool removeImage = false}) async {
    if (categoryId == null) {
      debugPrint('Category ID is null - cannot update');
      return;
    }
    debugPrint(
        'Attempting to update category $categoryId with name: $newName, description: $newDescription');
    try {
      final responseData = await CategoryService.updateCategory(
        categoryId!,
        newName,
        newDescription,
        imageFile: imageFile,
        removeImage: removeImage,
      );

      setState(() {
        categoryDescription = newDescription;
        if (removeImage) {
          categoryImage = null;
        } else if (responseData['image'] != null) {
          categoryImage = responseData['image'];
        }
      });

      // If the category name was changed, navigate back to the main page
      if (newName != widget.category) {
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      } else {
        await _refreshData();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Category updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('Update error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating category: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> deleteCategory() async {
    if (categoryId == null) {
      debugPrint('Delete aborted: categoryId is null');
      return;
    }

    try {
      debugPrint('Initiating delete for category $categoryId');
      await CategoryService.deleteCategory(categoryId!);

      // Perform a complete data refresh
      await _refreshData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Category deleted successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Close this page if we're viewing the deleted category
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      debugPrint('Delete error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting category: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _refreshData() async {
    debugPrint('Performing full data refresh');
    setState(() {
      isLoading = true;
      error = null;
    });
    await _loadData();
    if (mounted) setState(() {});
  }

  Future<void> _pickImage({Function? onImageSelected}) async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle bar
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Title
                  Text(
                    'Select Image Source',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Camera option
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.camera_alt_rounded,
                        color: Colors.blue.shade600,
                        size: 24,
                      ),
                    ),
                    title: Text(
                      'Camera',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    subtitle: Text(
                      'Take a new photo',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _pickImageFromSource(ImageSource.camera,
                          onImageSelected: onImageSelected);
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Gallery option
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.photo_library_rounded,
                        color: Colors.green.shade600,
                        size: 24,
                      ),
                    ),
                    title: Text(
                      'Gallery',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    subtitle: Text(
                      'Choose from existing photos',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _pickImageFromSource(ImageSource.gallery,
                          onImageSelected: onImageSelected);
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Cancel button
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

// Add this new method to handle image picking from specific source
  Future<void> _pickImageFromSource(ImageSource source,
      {Function? onImageSelected}) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });

        // Call the callback to update dialog state
        if (onImageSelected != null) {
          onImageSelected();
        }
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error selecting image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void showUpdateCategoryDialog() {
    final nameController = TextEditingController(text: widget.category);
    final descriptionController =
        TextEditingController(text: categoryDescription ?? '');

    // Reset selected image when dialog opens
    _selectedImage = null;
    bool removeCurrentImage = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Text(
                'Update Category',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple.shade700,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category Name Field
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Category Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              BorderSide(color: Colors.deepPurple.shade400),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Description Field
                    TextField(
                      controller: descriptionController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              BorderSide(color: Colors.deepPurple.shade400),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Image Management Section
                    Text(
                      'Category Image',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Current/Selected Image Display
                    Container(
                      width: 100,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: _selectedImage != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                _selectedImage!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: 120,
                              ),
                            )
                          : (!removeCurrentImage && getImageUrl() != null)
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    getImageUrl()!,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: 120,
                                    errorBuilder: (context, error, stackTrace) {
                                      return _buildImagePlaceholder();
                                    },
                                  ),
                                )
                              : _buildImagePlaceholder(),
                    ),
                    const SizedBox(height: 16),
                    // Image Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              await _pickImage(
                                onImageSelected: () {
                                  setDialogState(() {
                                    removeCurrentImage = false;
                                  });
                                },
                              );
                            },
                            icon: const Icon(Icons.photo_library_rounded,
                                size: 18),
                            label: Text(
                              'Select Image',
                              style: GoogleFonts.inter(fontSize: 14),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.deepPurple.shade600,
                              side:
                                  BorderSide(color: Colors.deepPurple.shade300),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: (getImageUrl() != null ||
                                    _selectedImage != null)
                                ? () {
                                    setDialogState(() {
                                      _selectedImage = null;
                                      removeCurrentImage = true;
                                    });
                                  }
                                : null,
                            icon: const Icon(Icons.delete_outline_rounded,
                                size: 18),
                            label: Text(
                              'Remove Image',
                              style: GoogleFonts.inter(fontSize: 14),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red.shade600,
                              side: BorderSide(
                                color: (getImageUrl() != null ||
                                        _selectedImage != null)
                                    ? Colors.red.shade300
                                    : Colors.grey.shade300,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    _selectedImage = null;
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.inter(color: Colors.grey.shade600),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (nameController.text.trim().isNotEmpty) {
                      updateCategory(
                        nameController.text.trim(),
                        descriptionController.text.trim(),
                        imageFile: _selectedImage,
                        removeImage: removeCurrentImage,
                      );
                      Navigator.of(context).pop();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple.shade500,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Update',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      width: double.infinity,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_outlined,
            size: 32,
            color: Colors.grey.shade500,
          ),
          const SizedBox(height: 8),
          Text(
            'No Image',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  void showDeleteConfirmationDialog() {
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
                Icons.warning_rounded,
                color: Colors.red.shade500,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                'Delete Category',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade700,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Are you sure you want to delete this category?',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: Colors.red.shade600,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'This will permanently delete all ${devices.length} devices in this category.',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.red.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: GoogleFonts.inter(color: Colors.grey.shade600),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                deleteCategory();
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
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  // Get icon for device type
  IconData getDeviceIcon(String deviceName) {
    final lowerName = deviceName.toLowerCase();
    if (lowerName.contains('mri')) return Icons.medical_information_rounded;
    if (lowerName.contains('ct')) return Icons.scanner_rounded;
    if (lowerName.contains('x-ray') || lowerName.contains('xray')) {
      return Icons.healing_rounded;
    }
    if (lowerName.contains('ultrasound')) return Icons.monitor_heart_rounded;
    if (lowerName.contains('ecg')) return Icons.favorite_rounded;
    if (lowerName.contains('ventilator')) return Icons.air_rounded;
    if (lowerName.contains('dialysis')) return Icons.water_drop_rounded;
    if (lowerName.contains('lab') || lowerName.contains('laboratory')) {
      return Icons.science_rounded;
    }
    return Icons.medical_services_rounded;
  }

  // Get color for device card
  List<Color> getDeviceColors(int index) {
    final colorSets = [
      [Colors.blue.shade400, Colors.blue.shade600],
      [Colors.green.shade400, Colors.green.shade600],
      [Colors.purple.shade400, Colors.purple.shade600],
      [Colors.orange.shade400, Colors.orange.shade600],
      [Colors.red.shade400, Colors.red.shade600],
      [Colors.teal.shade400, Colors.teal.shade600],
      [Colors.indigo.shade400, Colors.indigo.shade600],
      [Colors.pink.shade400, Colors.pink.shade600],
    ];
    return colorSets[index % colorSets.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Column(
        children: [
          CurvedAppBar(
            title: widget.category,
            isProfileAvailable: false,
            showIcon: true,
            isBack: true,
          ),
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
      floatingActionButton: AddDeviceButton(
        onPressed: () => context.router.push(const AddDeviceRoute()),
      ),
    );
  }

// Content builder widget
  Widget _buildContent() {
    if (isLoading) {
      return const LoadingWidget();
    }

    if (error != null) {
      return CustomErrorWidget(
        error: error!,
        onRetry: () {
          setState(() {
            isLoading = true;
            error = null;
          });
          fetchDevicesByCategory();
        },
      );
    }

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CategoryHeaderCard(
                          category: widget.category,
                          categoryDescription: categoryDescription,
                          imageUrl: getImageUrl(),
                          onEdit: showUpdateCategoryDialog,
                          onDelete: showDeleteConfirmationDialog,
                          getDeviceIcon: getDeviceIcon,
                        ),
                        const SizedBox(height: 24),
                        Flexible(
                          child: DevicesSection(
                            devices: devices,
                            category: widget.category,
                            getDeviceColors: getDeviceColors,
                            getDeviceIcon: getDeviceIcon,
                            onDeviceTap: (device) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MachineDetailPageAdmin(
                                    machineName: device['name'],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
