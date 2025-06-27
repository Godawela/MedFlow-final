import 'package:flutter/material.dart';
import 'package:med/services/ollma_service.dart';
import 'package:med/widgets/appbar.dart';

class ChatBotPage extends StatefulWidget {
  const ChatBotPage({super.key});

  @override
  State<ChatBotPage> createState() => _ChatBotPageState();
}

class _ChatBotPageState extends State<ChatBotPage> with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  List<Map<String, dynamic>> messages = [];
  bool isTyping = false;
  bool isInitialized = false;

  // Medical knowledge base
  final OllamaService _ollamaService = OllamaService();

  void _checkOllamaConnection() async {
    try {
      bool isConnected = await _ollamaService.checkConnection();
      setState(() {
        isInitialized = isConnected;
      });
      
      if (isConnected) {
        _showWelcomeMessage();
      } else {
        _showConnectionError();
      }
    } catch (e) {
      setState(() {
        isInitialized = false;
      });
      _showConnectionError();
    }
  }

  void _showConnectionError() {
    setState(() {
      messages.add({
        'message': {'text': ['⚠️ Unable to connect to Ollama service. Please ensure:\n\n1. Ollama is installed and running\n2. Your computer IP is correctly configured\n3. Both devices are on the same network\n\nTap the retry button to try again.']}, 
        'isUser': false,
        'isError': true
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    
    // Check Ollama connection instead of showing welcome immediately
    _checkOllamaConnection();
  }

  void _showWelcomeMessage() {
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        messages.add({
          'message': {'text': ['Hello! I\'m your medical assistant. I can help you with symptoms, general health advice, and medical information. How can I assist you today?']}, 
          'isUser': false,
          'isWelcome': true
        });
      });
      _animationController.forward();
    });
  }

  void sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      messages.add({'message': {'text': [text]}, 'isUser': true});
      isTyping = true;
    });

    _messageController.clear();
    _scrollToBottom();

    try {
      // Check connection first
      bool isConnected = await _ollamaService.checkConnection();
      
      if (!isConnected) {
        throw Exception('Unable to connect to Ollama service');
      }

      final response = await _ollamaService.generateResponse(text);
      
      setState(() {
        isTyping = false;
        messages.add({'message': {'text': [response]}, 'isUser': false});
      });
      _scrollToBottom();
    } catch (e) {
      setState(() {
        isTyping = false;
        messages.add({
          'message': {'text': ['Sorry, I\'m having trouble connecting to the medical assistant. Please make sure Ollama is running on your computer and try again.\n\nTroubleshooting:\n1. Check if Ollama service is running\n2. Verify your computer\'s IP address\n3. Ensure both devices are on the same network\n\nError: ${e.toString()}']}, 
          'isUser': false,
          'isError': true
        });
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildMessage(Map<String, dynamic> message, int index) {
    final isUser = message['isUser'] as bool;
    final isWelcome = message['isWelcome'] == true;
    final isError = message['isError'] == true;
    final text = message['message']['text'][0];

    return AnimatedContainer(
      duration: Duration(milliseconds: 300 + (index * 50)),
      curve: Curves.easeInOut,
      child: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.symmetric(
            vertical: 6, 
            horizontal: 16,
          ),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.8,
          ),
          child: Column(
            crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              if (!isUser && !isWelcome)
                Padding(
                  padding: const EdgeInsets.only(left: 16, bottom: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: Colors.deepPurple.shade100,
                        child: Icon(
                          Icons.smart_toy,
                          size: 16,
                          color: Colors.deepPurple.shade600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Medical Assistant',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: isUser 
                    ? LinearGradient(
                        colors: [Colors.deepPurple.shade400, Colors.deepPurple.shade600],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : isWelcome
                      ? LinearGradient(
                          colors: [Colors.deepPurple.shade50, Colors.deepPurple.shade100],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : isError
                        ? LinearGradient(
                            colors: [Colors.red.shade50, Colors.red.shade100],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : LinearGradient(
                            colors: [Colors.grey.shade100, Colors.grey.shade200],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(20),
                    topRight: const Radius.circular(20),
                    bottomLeft: Radius.circular(isUser ? 20 : 4),
                    bottomRight: Radius.circular(isUser ? 4 : 20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isWelcome)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.waving_hand,
                              size: 16,
                              color: Colors.deepPurple.shade600,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Welcome!',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    Text(
                      text,
                      style: TextStyle(
                        color: isUser 
                          ? Colors.white 
                          : isWelcome 
                            ? Colors.deepPurple.shade700
                            : isError
                              ? Colors.red.shade700
                              : Colors.black87,
                        fontSize: 16,
                        fontWeight: isWelcome ? FontWeight.w500 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              if (isUser)
                Padding(
                  padding: const EdgeInsets.only(top: 4, right: 16),
                  child: Text(
                    'You',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomLeft: Radius.circular(4),
            bottomRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple.shade400),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Analyzing...',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
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
          // Header
          CurvedAppBar(
            title: 'Medical Assistant',
            subtitle: isInitialized ? 'Ready to help' : 'Connecting...',
            isProfileAvailable: false,
            showIcon: true,
          ),
          
          // Chat Messages
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(vertical: 16),
                itemCount: messages.length + (isTyping ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == messages.length && isTyping) {
                    return _buildTypingIndicator();
                  }
                  return _buildMessage(messages[index], index);
                },
              ),
            ),
          ),
        ],
      ),
      
      // Enhanced Bottom Input
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).padding.bottom + 16,
        ),
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: TextField(
                  controller: _messageController,
                  textInputAction: TextInputAction.send,
                  onSubmitted: sendMessage,
                  decoration: InputDecoration(
                    hintText: 'Ask me about symptoms, health advice...',
                    hintStyle: TextStyle(color: Colors.grey.shade500),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    border: InputBorder.none,
                    prefixIcon: Icon(
                      Icons.chat_bubble_outline,
                      color: Colors.grey.shade500,
                      size: 20,
                    ),
                  ),
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.deepPurple.shade400, Colors.deepPurple.shade600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.deepPurple.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.send_rounded, color: Colors.white),
                onPressed: () => sendMessage(_messageController.text),
                splashColor: Colors.white.withOpacity(0.3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}