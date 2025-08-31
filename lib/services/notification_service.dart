import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;
  static const String _baseUrl = 'https://medflow-phi.vercel.app/api';

  // Call this during app startup to set up basic FCM
  Future<void> initializeBasic() async {
    debugPrint('Initializing basic FCM setup...');
    
    // Initialize local notifications
    await _initializeLocalNotifications();
    
    // Request permissions
    await _requestPermission();
    
    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      debugPrint('Received foreground message: ${message.notification?.title}');
      debugPrint('Message data: ${message.data}');
      await _showLocalNotification(message);
    });

    // Handle notification taps when app is in background/terminated
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('Message clicked: ${message.data}');
      _handleNotificationTap(message);
    });

    // Handle initial message if app was opened from terminated state
    RemoteMessage? initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      debugPrint('App opened from notification: ${initialMessage.data}');
      _handleNotificationTap(initialMessage);
    }

    debugPrint('Basic FCM setup completed');
  }

  Future<void> _initializeLocalNotifications() async {
    debugPrint('Initializing local notifications...');

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestSoundPermission: true,
          requestBadgePermission: true,
          requestAlertPermission: true,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint('Local notification tapped: ${response.payload}');
        if (response.payload != null) {
          final data = jsonDecode(response.payload!);
          _handleNotificationData(data);
        }
      },
    );

    // Create notification channel for Android
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _localNotifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidImplementation != null) {
      await androidImplementation.createNotificationChannel(channel);
    }

    debugPrint('Local notifications initialized');
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'high_importance_channel',
          'High Importance Notifications',
          channelDescription: 'This channel is used for important notifications.',
          importance: Importance.high,
          priority: Priority.high,
          showWhen: true,
          playSound: true,
          enableVibration: true,
          icon: '@mipmap/ic_launcher',
        );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics);

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      message.notification?.title ?? 'New Notification',
      message.notification?.body ?? 'You have a new message',
      platformChannelSpecifics,
      payload: jsonEncode(message.data),
    );
  }

  void _handleNotificationTap(RemoteMessage message) {
    _handleNotificationData(message.data);
  }

  void _handleNotificationData(Map<String, dynamic> data) {
    final String? type = data['type'];
    debugPrint('Handling notification type: $type');

    switch (type) {
      case 'new_question':
        // Navigate to admin questions page
        debugPrint('Should navigate to admin questions page');
        // Add your navigation logic here
        break;
      case 'admin_reply':
        // Navigate to student questions page
        debugPrint('Should navigate to student questions page');
        // Add your navigation logic here
        break;
      case 'test':
        debugPrint('Test notification received successfully');
        break;
      default:
        debugPrint('Unknown notification type: $type');
    }
  }

  // Call this AFTER user authentication is complete
  Future<void> initializeForUser() async {
    if (_isInitialized) {
      debugPrint('FCM already initialized for user');
      return;
    }
    
    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      debugPrint('Cannot initialize FCM - user not authenticated');
      return;
    }

    debugPrint('Initializing FCM for user: ${currentUser.uid}');

    // Get FCM token and register it with retry logic
    await _registerTokenWithRetry();
    
    // Listen for token refresh
    _firebaseMessaging.onTokenRefresh.listen((newToken) {
      debugPrint('FCM Token refreshed: ${newToken.substring(0, 20)}...');
      _sendTokenToBackend(newToken);
    });
    
    _isInitialized = true;
    debugPrint('FCM fully initialized for user: ${currentUser.uid}');
  }

  Future<void> _registerTokenWithRetry({int maxRetries = 3}) async {
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        debugPrint('Getting FCM token (attempt $attempt/$maxRetries)...');
        String? token = await _firebaseMessaging.getToken();
        
        if (token != null) {
          debugPrint('FCM Token obtained: ${token.substring(0, 20)}...');
          await _sendTokenToBackend(token);
          
          // Test the token immediately
          await _testToken(token);
          return; // Success, exit retry loop
        } else {
          debugPrint('FCM token is null');
        }
      } catch (e) {
        debugPrint('Failed to get/register FCM token (attempt $attempt): $e');
        if (attempt == maxRetries) {
          debugPrint(' All FCM token registration attempts failed');
        } else {
          await Future.delayed(Duration(seconds: attempt * 2)); // Exponential backoff
        }
      }
    }
  }

  Future<void> _requestPermission() async {
    debugPrint('Requesting FCM permissions...');

    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
      criticalAlert: false,
      carPlay: false,
      announcement: false,
    );

    debugPrint('FCM Permission status: ${settings.authorizationStatus}');

    switch (settings.authorizationStatus) {
      case AuthorizationStatus.authorized:
        debugPrint('User granted notification permission');
        break;
      case AuthorizationStatus.provisional:
        debugPrint('User granted provisional notification permission');
        break;
      case AuthorizationStatus.denied:
        debugPrint('User denied notification permission');
        break;
      case AuthorizationStatus.notDetermined:
        debugPrint('Notification permission not determined');
        break;
    }

    // For iOS, also check if we have local notification permissions
    if (Platform.isIOS) {
      final bool? result = await _localNotifications
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      debugPrint('iOS local notification permission: ${result ?? false}');
    }
  }

  Future<void> _sendTokenToBackend(String? token) async {
    if (token == null) {
      debugPrint('Cannot send null token to backend');
      return;
    }

    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      debugPrint('No authenticated user - skipping token registration');
      return;
    }

    final String userId = currentUser.uid;

    try {
      debugPrint('Registering FCM token for user: $userId');

      final response = await http.post(
        Uri.parse('$_baseUrl/fcm-tokens'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'token': token, 
          'userId': userId,
          'timestamp': DateTime.now().toIso8601String(),
          'platform': Platform.isAndroid ? 'android' : 'ios',
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        debugPrint('FCM token registered successfully');
      } else {
        debugPrint('Failed to register FCM token: ${response.statusCode}');
        debugPrint('Response: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error registering FCM token: $e');
    }
  }

  // Test token immediately after registration
  Future<void> _testToken(String token) async {
    try {
      debugPrint('Testing FCM token...');

      final response = await http.post(
        Uri.parse('$_baseUrl/test-fcm'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({'token': token}),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        debugPrint('FCM token test successful: ${result['messageId']}');
      } else {
        debugPrint('FCM token test failed: ${response.statusCode}');
        debugPrint('Response: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error testing FCM token: $e');
    }
  }

  // Send notification to admins when student submits question
  Future<void> notifyAdminsOfNewQuestion({
    required String studentName,
    required String questionPreview,
  }) async {
    try {
      debugPrint('Notifying admins of new question from: $studentName');

      final response = await http.post(
        Uri.parse('$_baseUrl/notify-admins'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'type': 'new_question',
          'studentName': studentName,
          'questionPreview': questionPreview.length > 100 
              ? '${questionPreview.substring(0, 100)}...' 
              : questionPreview,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      ).timeout(const Duration(seconds: 15));
      
      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        debugPrint('Admin notification result: $result');
      } else {
        debugPrint('Failed to send admin notification: ${response.statusCode}');
        debugPrint('Response: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error notifying admins: $e');
    }
  }

  // Send notification to student when admin replies
  Future<void> notifyStudentOfReply({
    required String studentId,
    required String replyPreview,
  }) async {
    try {
      debugPrint('Notifying student of admin reply: $studentId');

      final response = await http.post(
        Uri.parse('$_baseUrl/notify-student'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'type': 'admin_reply',
          'studentId': studentId,
          'replyPreview': replyPreview.length > 100 
              ? '${replyPreview.substring(0, 100)}...' 
              : replyPreview,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      ).timeout(const Duration(seconds: 15));
      
      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        debugPrint('Student notification result: $result');
      } else {
        debugPrint('Failed to send student notification: ${response.statusCode}');
        debugPrint('Response: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error notifying student: $e');
    }
  }

  // Get current FCM token 
  Future<String?> getCurrentToken() async {
    try {
      final token = await _firebaseMessaging.getToken();
      if (token != null) {
        debugPrint('Current FCM token: ${token.substring(0, 20)}...');
      } else {
        debugPrint('No FCM token available');
      }
      return token;
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
      return null;
    }
  }

  // Subscribe to topic 
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      debugPrint('Subscribed to topic: $topic');
    } catch (e) {
      debugPrint('Error subscribing to topic $topic: $e');
    }
  }

  // Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      debugPrint('Unsubscribed from topic: $topic');
    } catch (e) {
      debugPrint('Error unsubscribing from topic $topic: $e');
    }
  }

  // Debug method to get all FCM info
  Future<void> debugFCMInfo() async {
    try {
      debugPrint('=== FCM DEBUG INFO ===');

      final User? user = FirebaseAuth.instance.currentUser;
      debugPrint('User: ${user?.uid ?? 'Not authenticated'}');

      final String? token = await getCurrentToken();
      debugPrint('Token available: ${token != null}');

      final NotificationSettings settings = await _firebaseMessaging.getNotificationSettings();
      debugPrint('Permission: ${settings.authorizationStatus}');
      debugPrint('Alert: ${settings.alert}');
      debugPrint('Badge: ${settings.badge}');
      debugPrint('Sound: ${settings.sound}');

      debugPrint('Initialized: $_isInitialized');
      debugPrint('==================');
    } catch (e) {
      debugPrint('Error getting FCM debug info: $e');
    }
  }

  // Force token refresh
  Future<void> refreshToken() async {
    try {
      debugPrint('Forcing FCM token refresh...');
      await _firebaseMessaging.deleteToken();
      await Future.delayed(const Duration(seconds: 1));
      final newToken = await _firebaseMessaging.getToken();
      if (newToken != null) {
        debugPrint('New token obtained: ${newToken.substring(0, 20)}...');
        await _sendTokenToBackend(newToken);
      }
    } catch (e) {
      debugPrint('Error refreshing FCM token: $e');
    }
  }
}

// Top-level function for handling background messages
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Received background message: ${message.data}');
}