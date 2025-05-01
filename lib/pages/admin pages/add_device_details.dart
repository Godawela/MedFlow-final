import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

@RoutePage()
class AddDevicePage extends StatefulWidget {
  const AddDevicePage({Key? key}) : super(key: key);

  @override
  _AddDevicePageState createState() => _AddDevicePageState();
}

class _AddDevicePageState extends State<AddDevicePage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _referenceController = TextEditingController();
  final TextEditingController _linkOfResourceController = TextEditingController();

  bool isLoading = false;
  String? errorMessage;

  List<dynamic> _categories = []; // fetched categories
  String? _selectedCategory; // selected category name

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    try {
      final response = await http.get(Uri.parse('http://10.0.2.2:8000/api/category'));

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
      'category': _selectedCategory, // use selected category
      'description': _descriptionController.text,
      'reference': _referenceController.text,
      'linkOfResource': _linkOfResourceController.text,
    };

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/api/devices'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(deviceData),
      );

      if (response.statusCode == 201) {
        Navigator.pop(context, true);
      } else {
        setState(() {
          errorMessage = 'Failed to add device. Status code: ${response.statusCode}';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Device'),
        backgroundColor: Colors.transparent,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Device Name'),
                validator: (value) => value!.isEmpty ? 'Please enter a name' : null,
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(labelText: 'Category'),
                items: _categories.map((category) {
                  return DropdownMenuItem<String>(
                    value: category['name'], // use 'name' field
                    child: Text(category['name']),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
                validator: (value) => value == null ? 'Please select a category' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (value) => value!.isEmpty ? 'Please enter a description' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _referenceController,
                decoration: const InputDecoration(labelText: 'Reference'),
                validator: (value) => value!.isEmpty ? 'Please enter a reference' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _linkOfResourceController,
                decoration: const InputDecoration(labelText: 'Link of Resource'),
                validator: (value) => value!.isEmpty ? 'Please enter a link' : null,
              ),
              const SizedBox(height: 20),
              if (errorMessage != null) ...[
                Text(
                  errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 20),
              ],
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submitDevice,
                      child: const Text('Add Device'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
