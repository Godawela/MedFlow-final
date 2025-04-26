//individual device information page


import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:med/pages/user%20pages/machine_details.dart';
import 'dart:convert';


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
  String? categoryDescription;


  @override
  void initState() {
    super.initState();
    fetchDevicesByCategory();
    fetchCategoryDescription();
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


Future<void> fetchCategoryDescription() async {
  try {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:8000/api/category/name/${widget.category}'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        categoryDescription = data['description'];
      });
    } else {
      setState(() {
        categoryDescription = 'No description available.';
      });
    }
  } catch (e) {
    setState(() {
      categoryDescription = 'Error fetching description.';
    });
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category),
backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: isLoading
    ? const Center(child: CircularProgressIndicator())
    : error != null
        ? Center(child: Text(error!))
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
           if (categoryDescription != null) ...[
  Padding(
    padding: const EdgeInsets.all(16.0),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(20.0),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20.0),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'About This Category',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                categoryDescription!,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: Colors.white,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  ),
],
              Expanded(
                child: devices.isEmpty
                    ? Center(
                        child: Text(
                          'No devices found in ${widget.category}',
                          style: GoogleFonts.inter(fontSize: 16),
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
                              trailing: const Icon(Icons.arrow_forward_ios,
                                  color: Colors.blueAccent),
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
              ),
            ],
          ),
    );
  }
}

