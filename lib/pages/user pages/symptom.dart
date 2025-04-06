import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:med/pages/user%20pages/symptom_details_page.dart';


class SymptomPage extends StatefulWidget {
  const SymptomPage({super.key});

  @override
  State<SymptomPage> createState() => _SymptomPageState();
}

class _SymptomPageState extends State<SymptomPage> {
  List<dynamic> symptoms = [];

  @override
  void initState() {
    super.initState();
    fetchSymptoms();
  }

  Future<void> fetchSymptoms() async {
    final response = await http.get(Uri.parse('http://10.0.2.2:8000/api/symptoms'));

    if (response.statusCode == 200) {
      final List<dynamic> symptomData = json.decode(response.body);
      setState(() {
        symptoms = symptomData;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Symptoms'),
        backgroundColor: Colors.blueAccent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: symptoms.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: symptoms.length,
              itemBuilder: (context, index) {
                final symptom = symptoms[index];
                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.all(10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    title: Text(
                      symptom['name'],
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      symptom['description'] ?? '',
                      style: GoogleFonts.inter(fontSize: 16),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, color: Colors.blueAccent),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SymptomDetailPage(
                            symptomName: symptom['name'],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
