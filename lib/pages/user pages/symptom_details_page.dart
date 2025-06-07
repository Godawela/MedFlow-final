import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:med/widgets/appbar.dart';
import 'package:url_launcher/url_launcher.dart';

class SymptomDetailPage extends StatefulWidget {
  final String symptomName;

  const SymptomDetailPage({super.key, required this.symptomName});

  @override
  State<SymptomDetailPage> createState() => _SymptomDetailPageState();
}

class _SymptomDetailPageState extends State<SymptomDetailPage> {
  Map<String, dynamic>? symptomDetails;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchSymptomDetails();
  }

  Future<void> fetchSymptomDetails() async {
    final response = await http.get(Uri.parse('http://10.0.2.2:8000/api/symptoms/name/${widget.symptomName}'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> detail = json.decode(response.body);
      setState(() {
        symptomDetails = detail;
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load details')),
      );
    }
  }

  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     body: Column(
        children: [
          // CurvedAppBar at the top
           CurvedAppBar(
            title: widget.symptomName,
            isProfileAvailable: false,
            showIcon: true,
            isBack: true,
          ),
          
          // Main content below the app bar with negative margin to overlap
          Expanded(
            child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : symptomDetails != null
              ? SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Name:',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent.shade700,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        symptomDetails!['name'],
                        style: GoogleFonts.inter(fontSize: 18),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Description:',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent.shade700,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        symptomDetails!['description'],
                        style: GoogleFonts.inter(fontSize: 18, height: 1.5),
                      ),
                      const SizedBox(height: 30),
                      if (symptomDetails!['resourceLink'] != null &&
                          symptomDetails!['resourceLink'].toString().isNotEmpty)
                        Center(
                          child: ElevatedButton(
                            onPressed: () {
                              _launchURL(symptomDetails!['resourceLink']);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 5,
                            ),
                            child: Text(
                              'View Resource',
                              style: GoogleFonts.inter(fontSize: 18, color: Colors.white),
                            ),
                          ),
                        ),
                    ],
                  ),
                )
              : const Center(child: Text('Symptom not found')),
    ),
        ],
      ),
    );
  }
}
