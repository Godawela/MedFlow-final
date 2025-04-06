import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:url_launcher/url_launcher.dart';

class DeviceListPage extends StatefulWidget {
  final String category;

  const DeviceListPage({super.key, required this.category});

  @override
  _DeviceListPageState createState() => _DeviceListPageState();
}

class _DeviceListPageState extends State<DeviceListPage> {
  List<dynamic> devices = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchDevicesByCategory();
  }

  Future<void> fetchDevicesByCategory() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/devices/category/${widget.category}'),
      );

      if (response.statusCode == 200) {
        setState(() {
          devices = json.decode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          error = 'Failed to load devices: ${response.statusCode}';
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
      appBar: AppBar(
        title: Text(widget.category),
        backgroundColor: Colors.blueAccent,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text(error!))
              : devices.isEmpty
                  ? Center(
                      child: Text(
                        'No devices found in ${widget.category}',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: devices.length,
                      itemBuilder: (context, index) {
                        final device = devices[index];
                        return Card(
                          elevation: 4,
                          margin: const EdgeInsets.all(10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            title: Text(
                              device['name'],
                              style: GoogleFonts.inter(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              device['reference'] ?? '',
                              style: GoogleFonts.inter(fontSize: 16),
                            ),
                            trailing: const Icon(Icons.arrow_forward_ios, color: Colors.blueAccent),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MachineDetailPage(
                                    machineName: device['name'],
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

class MachineDetailPage extends StatefulWidget {
  final String machineName;

  const MachineDetailPage({super.key, required this.machineName});

  @override
  _MachineDetailPageState createState() => _MachineDetailPageState();
}

class _MachineDetailPageState extends State<MachineDetailPage> {
  Map<String, dynamic>? machineDetails;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchMachineDetails();
  }

  Future<void> fetchMachineDetails() async {
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
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No machine details found')),
        );
      }
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
      appBar: AppBar(
        title: Text(widget.machineName),
        backgroundColor: Colors.blueAccent,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : machineDetails != null
              ? SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Category:',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent.shade700,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        machineDetails!['category'],
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
                        machineDetails!['description'],
                        style: GoogleFonts.inter(fontSize: 18, height: 1.5),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Reference:',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent.shade700,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        machineDetails!['reference'],
                        style: GoogleFonts.inter(fontSize: 18),
                      ),
                      const SizedBox(height: 30),
                      if (machineDetails!['linkOfResource'] != null)
                        Center(
                          child: ElevatedButton(
                            onPressed: () {
                              _launchURL(machineDetails!['linkOfResource']);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 30, vertical: 15),
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
              : const Center(child: Text('Machine not found')),
    );
  }
}