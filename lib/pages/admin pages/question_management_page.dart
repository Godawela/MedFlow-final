
// ignore_for_file: use_build_context_synchronously

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:med/widgets/appbar.dart';
import 'package:med/services/notification_service.dart'; // Add this import

@RoutePage()
class QuestionsPage extends StatefulWidget {
  const QuestionsPage({super.key});

  @override
  QuestionsPageState createState() => QuestionsPageState();
}

class QuestionsPageState extends State<QuestionsPage> {
  List<dynamic> questions = [];
  bool isLoading = true;
  String? selectedQuestionId;
  final TextEditingController replyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchQuestions();
  }

  @override
  void dispose() {
    replyController.dispose();
    super.dispose();
  }

  Future<void> fetchQuestions() async {
    try {
      final response = await http.get(
        Uri.parse('https://medflow-phi.vercel.app/api/questions'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          questions = data;
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

  Future<void> replyToQuestion(String questionId, String reply) async {
    try {
      // Find the question to get student information
      final question = questions.firstWhere((q) => q['_id'] == questionId);
      final String studentId = question['studentId']; 

      // Update the question with the reply
      final response = await http.put(
        Uri.parse('https://medflow-phi.vercel.app/api/questions/$questionId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'reply': reply,
          'status': 'answered',
          'repliedAt': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        // Send notification to the student
        try {
          await NotificationService().notifyStudentOfReply(
            studentId: studentId,
            replyPreview: reply,
          );
          debugPrint('Student notification sent successfully');
        } catch (notificationError) {
          debugPrint('Failed to send student notification: $notificationError');
          // Don't fail the whole operation if notification fails
        }

        setState(() {
          selectedQuestionId = null;
          replyController.clear();
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Reply sent successfully and student notified!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        
        fetchQuestions(); // Refresh the list
      } else {
        throw Exception('Failed to send reply');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sending reply: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
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

  Widget _buildQuestionCard(dynamic question) {
    final bool isAnswered = question['status'] == 'answered';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isAnswered 
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
                  color: isAnswered 
                      ? Colors.green.withValues(alpha: 0.1)
                      : const Color(0xFF8E2DE2).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isAnswered ? 'Answered' : 'Pending',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isAnswered ? Colors.green : const Color(0xFF8E2DE2),
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
          Text(
            question['studentName'] ?? 'Unknown Student',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
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
          
          if (isAnswered && question['reply'] != null) ...[
            const SizedBox(height: 12),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your Reply:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    question['reply'],
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF2D3748),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          if (!isAnswered) ...[
            const SizedBox(height: 16),
            if (selectedQuestionId == question['_id']) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFF8E2DE2).withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: TextField(
                  controller: replyController,
                  maxLines: 3,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF2D3748),
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Type your reply here...',
                    border: InputBorder.none,
                    hintStyle: TextStyle(
                      color: Color(0xFF4A5568),
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          selectedQuestionId = null;
                          replyController.clear();
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        side: const BorderSide(color: Color(0xFF8E2DE2)),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: Color(0xFF8E2DE2),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF4B00E0), Color(0xFF8E2DE2)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          if (replyController.text.trim().isNotEmpty) {
                            replyToQuestion(question['_id'], replyController.text.trim());
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          'Send Reply',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ] else ...[
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      selectedQuestionId = question['_id'];
                      replyController.clear();
                    });
                  },
                  icon: const Icon(
                    Icons.reply,
                    color: Color(0xFF8E2DE2),
                    size: 18,
                  ),
                  label: const Text(
                    'Reply',
                    style: TextStyle(
                      color: Color(0xFF8E2DE2),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    side: const BorderSide(color: Color(0xFF8E2DE2)),
                  ),
                ),
              ),
            ],
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
            title: 'Student Questions',
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
                  : questions.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.question_answer_outlined,
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
                                'Student questions will appear here',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF4A5568),
                                ),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: fetchQuestions,
                          child: ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.all(20),
                            itemCount: questions.length,
                            itemBuilder: (context, index) {
                              return _buildQuestionCard(questions[index]);
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