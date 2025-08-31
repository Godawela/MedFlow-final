
// ignore_for_file: use_build_context_synchronously

import 'package:auto_route/auto_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:med/widgets/appbar.dart';

@RoutePage()
class StudentQuestionsPage extends StatefulWidget {
  const StudentQuestionsPage({super.key});

  @override
  StudentQuestionsPageState createState() => StudentQuestionsPageState();
}

class StudentQuestionsPageState extends State<StudentQuestionsPage> {
  List<dynamic> myQuestions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchMyQuestions();
  }

  Future<void> fetchMyQuestions() async {
    final String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      final response = await http.get(
        Uri.parse('https://medflow-phi.vercel.app/api/questions/student/$uid'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          myQuestions = data;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load questions');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching questions: $e')),
      );
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('MMM dd, yyyy - HH:mm').format(date);
    } catch (e) {
      return dateString;
    }
  }

  Widget _buildMyQuestionCard(dynamic question) {
    final bool hasReply = question['status'] == 'answered' && question['reply'] != null;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasReply 
              ? Colors.green.withValues(alpha: 0.3)
              : const Color(0xFF8E2DE2).withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: hasReply 
                      ? Colors.green.withValues(alpha: 0.1)
                      : Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  hasReply ? 'Answered' : 'Pending',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: hasReply ? Colors.green : Colors.orange,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                _formatDate(question['timestamp']),
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF4A5568),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Your Question:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              question['question'],
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF2D3748),
                height: 1.4,
              ),
            ),
          ),
          
          if (hasReply) ...[
            const SizedBox(height: 16),
            const Text(
              'Admin Reply:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.green.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Text(
                question['reply'],
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF2D3748),
                  height: 1.4,
                ),
              ),
            ),
            if (question['repliedAt'] != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Replied on: ${_formatDate(question['repliedAt'])}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF4A5568),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Column(
        children: [
          const CurvedAppBar(
            title: 'My Questions',
            isProfileAvailable: false,
            showIcon: true,
            isBack: true,
          ),
          Expanded(
            child: Transform.translate(
              offset: const Offset(0, -40),
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8E2DE2)),
                      ),
                    )
                  : myQuestions.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.quiz_outlined,
                                size: 64,
                                color: Color(0xFF8E2DE2),
                              ),
                              SizedBox(height: 16),
                              Text(
                                'No questions yet',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF4A5568),
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Ask your first question from the profile page',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF4A5568),
                                ),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: fetchMyQuestions,
                          child: ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.all(20),
                            itemCount: myQuestions.length,
                            itemBuilder: (context, index) {
                              return _buildMyQuestionCard(myQuestions[index]);
                            },
                          ),
                        ),
            ),
          ),
        ],
      ),
    );
  }
}