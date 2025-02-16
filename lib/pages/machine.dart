import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:med/routes/router.dart';

@RoutePage()
class MachinePage extends StatelessWidget {
  const MachinePage({Key? key}) : super(key: key);

  Future<List<Map<String, dynamic>>> fetchMachineCategories() async {
    final url = Uri.parse("http://localhost:8080/api/machines/categories");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => {'id': item['id'], 'name': item['name']}).toList();
    } else {
      throw Exception("Failed to load machine categories");
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
            AutoRouter.of(context).push(HomeRoute());
          },
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Ensures column only takes needed space
            mainAxisAlignment: MainAxisAlignment.center, // Centers vertically
            crossAxisAlignment: CrossAxisAlignment.center, // Centers horizontally
            children: [
              Text(
                'Hi! User',
                style: GoogleFonts.goblinOne(fontSize: 24, color: Colors.black),
              ),
              const SizedBox(height: 20),
              Text(
                'Please select a device type',
                style: GoogleFonts.inter(fontSize: 20, color: Colors.black),
              ),
              const SizedBox(height: 20),
              FutureBuilder<List<Map<String, dynamic>>>(
                future: fetchMachineCategories(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return const Text('Error fetching data');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text('No machine categories found');
                  }

                  final machineCategories = snapshot.data!;
                  return Column(
                    children: machineCategories.map((category) {
                      return DeviceButton(
                        label: category['name'],
                        onTap: () {
                          AutoRouter.of(context).push(
                            DeviceListRoute(categoryId: category['id']),
                          );
                        },
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DeviceButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const DeviceButton({Key? key, required this.label, required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF9CE6F6),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.inter(fontSize: 20, color: Colors.black),
          ),
        ),
      ),
    );
  }
}
