// Category List Page 

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:med/pages/user%20pages/device_list_page.dart';
import 'package:med/widgets/device_button.dart';
import 'package:med/widgets/user_greetings.dart';


class MachinePage extends StatefulWidget {
  const MachinePage({super.key});

  @override
  _MachinePageState createState() => _MachinePageState();
}

class _MachinePageState extends State<MachinePage> {
  List<String> categories = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/categories'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> fetchedCategories = json.decode(response.body);
        setState(() {
          categories = fetchedCategories.cast<String>();
          isLoading = false;
        });
      } else {
        setState(() {
          error = 'Failed to load categories: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Error: $e';
        isLoading = false;
      });
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
            Navigator.pop(context); // Navigate back to the previous page
          },
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: isLoading
                ? const CircularProgressIndicator()
                : error != null
                    ? Text(
                        'Error loading categories: $error',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: Colors.red,
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 16),
                          const Center(
                            child: CircleAvatar(
                              radius: 33.5,
                              backgroundImage:
                                  AssetImage('assets/images/logo.png'),
                            ),
                          ),
                          const SizedBox(height: 13),
                          // User greeting widget
                       const UserGreeting(),
                          const SizedBox(height: 44),
                          Text(
                            'Please select a device type',
                            style: GoogleFonts.inter(
                              fontSize: 20,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 44),
                          Expanded(
                            child: ListView.builder(
                              itemCount: categories.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 20),
                                  child: DeviceButton(
                                    label: categories[index],
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => DeviceListPage(
                                            category: categories[index],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
          ),
        ),
      ),
    );
  }
}

