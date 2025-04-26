import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:med/pages/user%20pages/symptom_details_page.dart';
import 'package:med/widgets/symptom_button.dart';
import 'package:med/widgets/user_greetings.dart';

class SymptomPage extends StatefulWidget {
  const SymptomPage({super.key});

  @override
  State<SymptomPage> createState() => _SymptomPageState();
}

class _SymptomPageState extends State<SymptomPage> {
  List<dynamic> symptoms = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchSymptoms();
  }

  Future<void> fetchSymptoms() async {
    try {
      final response =
          await http.get(Uri.parse('http://10.0.2.2:8000/api/symptoms'));

      if (response.statusCode == 200) {
        final List<dynamic> symptomData = json.decode(response.body);
        setState(() {
          symptoms = symptomData;
          isLoading = false;
        });
      } else {
        setState(() {
          error = 'Failed to load symptoms: ${response.statusCode}';
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
        title: const Text('Symptoms'),
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
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
                        'Error loading symptoms: $error',
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
                          const SizedBox(height: 24),
                          Text(
                            'Please select a symptom',
                            style: GoogleFonts.inter(
                              fontSize: 20,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 44),
                          Expanded(
                            child: ListView.builder(
                              itemCount: symptoms.length,
                              itemBuilder: (context, index) {
                                final symptom = symptoms[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 20),
                                  child: SymptomButton(
                                    label: symptom['name'],
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              SymptomDetailPage(
                                            symptomName: symptom['name'],
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

