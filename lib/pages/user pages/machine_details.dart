//individual device information page

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:med/widgets/appbar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class MachineDetailPage extends StatefulWidget {
  final String machineName;

  const MachineDetailPage({super.key, required this.machineName});

  @override
  _MachineDetailPageState createState() => _MachineDetailPageState();
}

class _MachineDetailPageState extends State<MachineDetailPage> with TickerProviderStateMixin {
  Map<String, dynamic>? machineDetails;
  bool isLoading = true;
  String? error;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
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
    
    fetchMachineDetails();
      _refreshTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      fetchMachineDetails();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
            _refreshTimer?.cancel();

    super.dispose();
  }

  Future<void> fetchMachineDetails() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/devices/name/${widget.machineName}'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> decodedResponse = json.decode(response.body);

        if (decodedResponse.isNotEmpty) {
          setState(() {
            machineDetails = decodedResponse.first;
            isLoading = false;
          });
          _animationController.forward();
        } else {
          setState(() {
            isLoading = false;
            error = 'No machine details found';
          });
        }
      } else {
        setState(() {
          isLoading = false;
          error = 'Failed to load details: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        error = 'Error: $e';
      });
    }
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch $url')),
      );
    }
  }

  Widget _buildDetailCard(String title, String content, IconData icon) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.deepPurple.shade700,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple.shade800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              content,
              style: GoogleFonts.inter(
                fontSize: 16,
                color: Colors.grey.shade800,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Column(
        children: [
          CurvedAppBar(
            title: widget.machineName,
            isProfileAvailable: false,
            showIcon: true,
            isBack: true,
          ),
          Expanded(
            child: isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                          )],
                          ),
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.deepPurple.shade400,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Loading device details...',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                : error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.error_outline_rounded,
                                size: 48,
                                color: Colors.red.shade400,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Oops! Something went wrong',
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.red.shade700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              error!,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: Colors.red.shade600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: () {
                                setState(() {
                                  isLoading = true;
                                  error = null;
                                });
                                fetchMachineDetails();
                              },
                              icon: const Icon(Icons.refresh_rounded),
                              label: const Text('Try Again'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red.shade500,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) {
                          return FadeTransition(
                            opacity: _fadeAnimation,
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                children: [
                                  // Device header
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Colors.deepPurple.shade400,
                                          Colors.deepPurple.shade600,
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.deepPurple.withOpacity(0.3),
                                          blurRadius: 12,
                                          offset: const Offset(0, 6),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                          child: Icon(
                                            Icons.medical_services_rounded,
                                            size: 40,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          widget.machineName,
                                          style: GoogleFonts.inter(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                  
                                  const SizedBox(height: 24),
                                  
                                  // Device details
                                  if (machineDetails!['category'] != null)
                                    _buildDetailCard(
                                      'Category',
                                      machineDetails!['category'],
                                      Icons.category_rounded,
                                    ),
                                  
                                  if (machineDetails!['description'] != null)
                                    _buildDetailCard(
                                      'Description',
                                      machineDetails!['description'],
                                      Icons.description_rounded,
                                    ),
                                  
                                  if (machineDetails!['reference'] != null)
                                    _buildDetailCard(
                                      'Reference',
                                      machineDetails!['reference'],
                                      Icons.badge_rounded,
                                    ),
                                  
                                  if (machineDetails!['linkOfResource'] != null) ...[
                                    const SizedBox(height: 16),
                                    Center(
                                      child: ElevatedButton.icon(
                                        onPressed: () {
                                          _launchURL(machineDetails!['linkOfResource']);
                                        },
                                        icon: const Icon(Icons.link_rounded),
                                        label: const Text('View Resource'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.deepPurple.shade500,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 24,
                                            vertical: 16,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(15),
                                          ),
                                          elevation: 5,
                                        ),
                                      ),
                                    ),
                                  ],
                                  
                                  const SizedBox(height: 20),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}