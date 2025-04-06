// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter_drawing_board/flutter_drawing_board.dart';


// class DrawingApp extends StatefulWidget {
//   const DrawingApp({super.key});

//   @override
//   State<DrawingApp> createState() => _DrawingAppState();
// }

// class _DrawingAppState extends State<DrawingApp> {
//   late DrawingController _controller;

//   @override
//   void initState() {
//     super.initState();
//     _controller = DrawingController();
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.blue,
//         centerTitle: true,
//         title: const Text(
//           "Drawig App",
//           style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//         ),
//       ),
//       body: DrawingBoard(
//         controller: _controller,
//         background: Container(
//         color: Colors.white,
//         height: 600,
//         width: 600,
//       ),
//         showDefaultActions: true,
//         showDefaultTools: true,
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: saveDrawing,
//         backgroundColor: Colors.blue,
//         child: const Icon(
//           Icons.save_alt,
//           color: Colors.white,
//         ),
//       ),
//     );
//   }

//   Future<void> saveDrawing() async {
//     try {
//       final imageData = await _controller.getImageData();
//       if (imageData == null) {
//         print("No image to save");
//         return;
//       }

//       String path;
//       final directory = Directory("C:/Users/user/Desktop");
//       if(!directory.existsSync()){
//         directory.createSync(recursive: true);
//       }

//       path="${directory.path}/drawing.png";

//       final file = File(path);
//       await file.writeAsBytes(imageData.buffer.asUint8List());
//       print("Drawing saved at $path");

//     } catch (error) {
//       print("Error: $error");
//     }
//   }
// }
