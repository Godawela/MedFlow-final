// import 'dart:io';
// import 'dart:typed_data';

// import 'package:dash_chat_2/dash_chat_2.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_gemini/flutter_gemini.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:speech_to_text/speech_to_text.dart' as stt;



// class ChatBot extends StatefulWidget {
//   const ChatBot({super.key});

//   @override
//   State<ChatBot> createState() => _ChatBotState();
// }

// class _ChatBotState extends State<ChatBot> {
//   final Gemini gemini = Gemini.instance;
//   final stt.SpeechToText _speech = stt.SpeechToText();


//   List<ChatMessage> messages = [];

//   ChatUser currentUser = ChatUser(id: "0", firstName: "User");
//   ChatUser geminiUser = ChatUser(
//     id: "1",
//     firstName: "Med",
//   );
//   bool _isListening = false;
//   String _voiceInput = "";

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         centerTitle: true,
//         title: const Text(
//           "Med Flow ChatBot",
//         ),
//       ),
//       body: _buildUI(),
//     );
//   }

//   Widget _buildUI() {
//     return DashChat(
//       inputOptions: InputOptions(trailing: [
//         IconButton(
//           icon: const Icon(Icons.mic),
//          onPressed: _isListening ? _stopListening : _startListening,
//           ),
//         IconButton(
//           onPressed: _sendMediaMessage,
//           icon: const Icon(
//             Icons.image,
//           ),
//         )
//       ]),
//       currentUser: currentUser,
//       onSend: _sendMessage,
//       messages: messages,
//     );
//   }

//   void _sendMessage(ChatMessage chatMessage) {
//     setState(() {
//       messages = [chatMessage, ...messages];
//     });
//     try {
//       String question = chatMessage.text;
//       List<Uint8List>? images;
//       if (chatMessage.medias?.isNotEmpty ?? false) {
//         images = [
//           File(chatMessage.medias!.first.url).readAsBytesSync(),
//         ];
//       }
//       gemini
//           .streamGenerateContent(
//         question,
//         images: images,
//       )
//           .listen((event) {
//         ChatMessage? lastMessage = messages.firstOrNull;
//         if (lastMessage != null && lastMessage.user == geminiUser) {
//           lastMessage = messages.removeAt(0);
//           String response = event.content?.parts?.fold(
//                   "", (previous, current) => "$previous ${current.text}") ??
//               "";
//           lastMessage.text += response;
//           setState(
//             () {
//               messages = [lastMessage!, ...messages];
//             },
//           );
//         } else {
//           String response = event.content?.parts?.fold(
//                   "", (previous, current) => "$previous ${current.text}") ??
//               "";
//           ChatMessage message = ChatMessage(
//             user: geminiUser,
//             createdAt: DateTime.now(),
//             text: response,
//           );
//           setState(() {
//             messages = [message, ...messages];
//           });
//         }
//       });
//     } catch (e) {
//       print(e);
//     }
//   }

//   void _sendMediaMessage() async {
//     ImagePicker picker = ImagePicker();
//     XFile? file = await picker.pickImage(
//       source: ImageSource.gallery,
//     );
//     if (file != null) {
//       print("Picked image: ${file.path}");
//       ChatMessage chatMessage = ChatMessage(
//         user: currentUser,
//         createdAt: DateTime.now(),
//         text: "Describe this picture?",
//         medias: [
//           ChatMedia(
//             url: file.path,
//             fileName: "",
//             type: MediaType.image,
//           )
//         ],
//       );
//       _sendMessage(chatMessage);
//     }
//   }
  
//    void _startListening() async {
//     bool available = await _speech.initialize();
//     if (available) {
//       setState(() => _isListening = true);
//       _speech.listen(
//         onResult: (result) {
//           setState(() => _voiceInput = result.recognizedWords);
//           if (!_speech.isListening) {
//             // Send the recognized words as a chat message
//             ChatMessage voiceMessage = ChatMessage(
//               user: currentUser,
//               createdAt: DateTime.now(),
//               text: _voiceInput,
//             );
//             _sendMessage(voiceMessage);
//           }
//         },
//       );
//     }
//   }

//   void _stopListening() {
//     _speech.stop();
//     setState(() => _isListening = false);
//   }

// }