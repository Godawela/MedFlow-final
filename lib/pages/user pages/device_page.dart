// // devieces by category page
// // list of all the devices under a one category


// import 'package:auto_route/auto_route.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// @RoutePage()
// class DevicePage extends StatelessWidget {
//   final String category; 

//   const DevicePage({super.key, required this.category});

//   Future<List<Map<String, dynamic>>> fetchDevices() async {
//     final url = Uri.parse("http://localhost:8000/api/devices/category/$category");
//     final response = await http.get(url);

//     if (response.statusCode == 200) {
//       List<dynamic> data = jsonDecode(response.body);
//       return data.map((item) => {'name': item['name']}).toList();
//     } else {
//       throw Exception("Failed to load devices");
//     }
//   }

//   Future<String> fetchCategoryDescription() async {
//     final url = Uri.parse("http://localhost:8000/api/category/name/$category");
//     final response = await http.get(url);
// print('Category Description Response: ${response.body}');

//     if (response.statusCode == 200) {
//       Map<String, dynamic> data = jsonDecode(response.body);
//       return data['description']; 
//     } else {
//       throw Exception("Failed to load category description");
//     }
//   }



//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Devices')),
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: SingleChildScrollView(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 FutureBuilder<String>(
//                   future: fetchCategoryDescription(),
//                   builder: (context, snapshot) {
//                     if (snapshot.connectionState == ConnectionState.waiting) {
//                       return const Center(child: CircularProgressIndicator());
//                     } else if (snapshot.hasError) {
//                       return const Center(child: Text('Error fetching category description'));
//                     } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//                       return const Center(child: Text('No description found'));
//                     }

//                     final description = snapshot.data!;
//                     return Padding(
//                       padding: const EdgeInsets.only(bottom: 16.0),
//                       child: Text(
//                         description,
//                         style: GoogleFonts.inter(fontSize: 16),
//                       ),
//                     );
//                   },
//                 ),

//                 //Devices list
//                 FutureBuilder<List<Map<String, dynamic>>>(
//                   future: fetchDevices(),
//                   builder: (context, snapshot) {
//                     if (snapshot.connectionState == ConnectionState.waiting) {
//                       return const Center(child: CircularProgressIndicator());
//                     } else if (snapshot.hasError) {
//                       return const Center(child: Text('Error fetching devices'));
//                     } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//                       return const Center(child: Text('No devices found'));
//                     }

//                     final devices = snapshot.data!;
//                     return Column(
//                       children: devices.map((device) {
//                         return Card(
//                           margin: const EdgeInsets.symmetric(vertical: 8),
//                           elevation: 4,
//                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//                           child: ListTile(
//                             title: Text(
//                               device['name'],
//                               style: GoogleFonts.inter(fontSize: 40, fontWeight: FontWeight.bold),
//                             ),
//                           ),
//                         );
//                       }).toList(),
//                     );
//                   },
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
