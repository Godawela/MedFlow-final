import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:med/models/category_model.dart';

class MachinePage extends StatefulWidget {
  const MachinePage({Key? key}) : super(key: key);

  @override
  State<MachinePage> createState() => _MachinePageState();
}

class _MachinePageState extends State<MachinePage> {
  List<Category> categories = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCategoryNames();
  }



Future<List<String>> fetchCategoryNames() async {
  try {
    final response = await http.get(Uri.parse('http://localhost:8000/api/devices/category/'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => item['category'].toString()).toList();
    } else {
      throw Exception('Failed to load categories');
    }
  } catch (e) {
    throw Exception('Error fetching categories: $e');
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Machine Page'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
  child: Center(
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: FutureBuilder<List<String>>(
        future: fetchCategoryNames(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: snapshot.data!.map((category) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: DeviceButton(
                    label: category,
                    onTap: () {
                      // Handle button tap
                      print('Selected category: $category');
                    },
                  ),
                );
              }).toList(),
            );
          } else {
            return const Text('No categories found');
          }
        },
      ),
    ),
  ),
),

    );
  }
}

class DeviceButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const DeviceButton({
    Key? key,
    required this.label,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF9CE6F6),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Center(
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 20,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
