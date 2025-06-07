import 'package:dialog_flowtter/dialog_flowtter.dart';
import 'package:flutter/material.dart';
import 'package:med/widgets/appbar.dart';

class ChatBotPage extends StatefulWidget {
  const ChatBotPage({super.key});

  @override
  State<ChatBotPage> createState() => _ChatBotPageState();
}

class _ChatBotPageState extends State<ChatBotPage> {
  late DialogFlowtter dialogFlowtter;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> messages = [];

  @override
  void initState() {
    super.initState();
    initDialogFlow();
  }

  Future<void> initDialogFlow() async {
    dialogFlowtter = await DialogFlowtter.fromFile(
      path: 'assets/dialogflow_auth.json',
    );
  }

  void sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      messages.add({'message': {'text': [text]}, 'isUser': true});
    });

    _messageController.clear();

    final response = await dialogFlowtter.detectIntent(
      queryInput: QueryInput(text: TextInput(text: text)),
    );

    if (response.message != null) {
      setState(() {
        messages.add({'message': response.message!.toJson(), 'isUser': false});
      });

      // Scroll to bottom after new message
      Future.delayed(Duration(milliseconds: 300), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  @override
  void dispose() {
    dialogFlowtter.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildMessage(Map<String, dynamic> message) {
    final isUser = message['isUser'] as bool;
    final text = message['message']['text'][0];

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isUser ? Colors.teal[400] : Colors.grey[300],
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: Radius.circular(isUser ? 12 : 0),
            bottomRight: Radius.circular(isUser ? 0 : 12),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(color: isUser ? Colors.white : Colors.black87),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          const CurvedAppBar(
            title: 'Chat Bot',
            isProfileAvailable: false,
            showIcon: true,
            isBack: false,
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.only(bottom: 10),
              itemCount: messages.length,
              itemBuilder: (context, index) => _buildMessage(messages[index]),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        color: Colors.grey[100],
        padding: EdgeInsets.only(
          left: 10,
          right: 10,
          top: 10,
          bottom: MediaQuery.of(context).padding.bottom + 10, // Account for safe area
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                textInputAction: TextInputAction.send,
                onSubmitted: sendMessage,
                decoration: InputDecoration(
                  hintText: 'Type your message...',
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(color: Colors.teal, width: 1),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: Colors.teal,
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white),
                onPressed: () => sendMessage(_messageController.text),
              ),
            ),
          ],
        ),
      ),
    );
  }
}