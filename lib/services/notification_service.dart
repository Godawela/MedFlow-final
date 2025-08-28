import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initialize() async {
    // FCM Setup only
    await _initializeFCM();
  }

  Future<void> _initializeFCM() async {
    // Request permission for push notifications
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
      
      // Get FCM token
      String? token = await _firebaseMessaging.getToken();
      print('FCM Token: $token');
      
      // Send token to backend and associate it with the user
      await _sendTokenToBackend(token);
      
      // Listen for token refresh
      _firebaseMessaging.onTokenRefresh.listen(_sendTokenToBackend);
    }

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received foreground message: ${message.notification?.title}');
      // The system will handle showing the notification
    });

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  Future<void> _sendTokenToBackend(String? token) async {
    if (token == null) return;
    
    final String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    
    try {
      // Send token to backend
      await http.post(
        Uri.parse('https://medflow-phi.vercel.app/api/fcm-tokens'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'token': token,
          'userId': userId,
        }),
      );
      print('FCM token sent to backend successfully');
    } catch (e) {
      print('Error sending FCM token: $e');
    }
  }

  // Send notification to admins when student submits question
  Future<void> notifyAdminsOfNewQuestion({
    required String studentName,
    required String questionPreview,
  }) async {
    try {
      // Call backend endpoint to send push notification to all admin devices
      final response = await http.post(
        Uri.parse('https://medflow-phi.vercel.app/api/notify-admins'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'type': 'new_question',
          'studentName': studentName,
          'questionPreview': questionPreview.length > 100 
              ? '${questionPreview.substring(0, 100)}...' 
              : questionPreview,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );
      
      if (response.statusCode == 200) {
        print('Admin notification sent successfully');
      } else {
        print('Failed to send admin notification: ${response.statusCode}');
      }
    } catch (e) {
      print('Error notifying admins: $e');
    }
  }

  // Send notification to student when admin replies
  Future<void> notifyStudentOfReply({
    required String studentId,
    required String replyPreview,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('https://medflow-phi.vercel.app/api/notify-student'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'type': 'admin_reply',
          'studentId': studentId,
          'replyPreview': replyPreview.length > 100 
              ? '${replyPreview.substring(0, 100)}...' 
              : replyPreview,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );
      
      if (response.statusCode == 200) {
        print('Student notification sent successfully');
      } else {
        print('Failed to send student notification: ${response.statusCode}');
      }
    } catch (e) {
      print('Error notifying student: $e');
    }
  }

  // Get current FCM token 
  Future<String?> getCurrentToken() async {
    try {
      return await _firebaseMessaging.getToken();
    } catch (e) {
      print('Error getting FCM token: $e');
      return null;
    }
  }

  // Subscribe to topic 
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      print('Subscribed to topic: $topic');
    } catch (e) {
      print('Error subscribing to topic $topic: $e');
    }
  }

}



// Top-level function for handling background messages
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling background message: ${message.messageId}');
  print('Background message data: ${message.data}');
}