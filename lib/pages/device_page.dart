import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

@RoutePage()
class DeviceListPage extends StatelessWidget {
  final int categoryId;

  const DeviceListPage({Key? key, required this.categoryId}) : super(key: key);

  Future<List<Map<String, dynamic>>> fetchDevices() async {
    final url = Uri.parse("http://localhost:8080/api/devices/$categoryId");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => {'id': item['id'], 'name': item['name'], 'description': item['description']}).toList();
    } else {
      throw Exception("Failed to load devices");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Devices')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: fetchDevices(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return const Center(child: Text('Error fetching devices'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No devices found'));
              }

              final devices = snapshot.data!;
              return ListView.builder(
                itemCount: devices.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    child: ListTile(
                      title: Text(
                        devices[index]['name'],
                        style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        devices[index]['description'],
                        style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[700]),
                      ),
                      onTap: () {
                        // Navigate to detailed device page if needed
                      },
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
