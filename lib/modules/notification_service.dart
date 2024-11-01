import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static bool _initialized = false;
  static String? _currentUserId;
  
  static Future<void> initialize(BuildContext context) async {
    if (_initialized) return;
    
    // Initialize notifications
    const initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    
    await _notifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse details) {
        // Handle notification tap
        if (details.payload != null) {
          final payloadParts = details.payload!.split('|');
          if (payloadParts.length == 3) {
            Navigator.pushNamed(
              context,
              '/ChatScreen',
              arguments: {
                'chatId': payloadParts[0],
                'vendorId': payloadParts[1],
                'vendorName': payloadParts[2],
              },
            );
          }
        }
      },
    );

    _currentUserId = _auth.currentUser?.uid;
    if (_currentUserId != null) {
      _listenToNewMessages();
    }
    
    _initialized = true;
  }

  static void _listenToNewMessages() {
    // Listen to all chats where current user is a participant
    _firestore
        .collection('chats')
        .where('participants', arrayContains: _currentUserId)
        .snapshots()
        .listen((snapshot) {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.modified) {
          _handleChatUpdate(change.doc);
        }
      }
    });
  }

  static Future<void> _handleChatUpdate(DocumentSnapshot chatDoc) async {
    final chatData = chatDoc.data() as Map<String, dynamic>;
    final participants = (chatData['participants'] as List<dynamic>).cast<String>();
    
    // Get the other participant's ID
    final otherUserId = participants.firstWhere(
      (id) => id != _currentUserId,
      orElse: () => '',
    );
    
    if (otherUserId.isEmpty) return;

    // Get the latest message
    final messagesSnapshot = await _firestore
        .collection('chats')
        .doc(chatDoc.id)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get();

    if (messagesSnapshot.docs.isEmpty) return;

    final latestMessage = messagesSnapshot.docs.first.data();
    final senderId = latestMessage['senderId'];

    // Only show notification if the message is from the other user
    if (senderId != _currentUserId) {
      // Get sender's name
      final senderDoc = await _firestore
          .collection('Vendors')
          .doc(senderId)
          .get();
      
      if (!senderDoc.exists) {
        final customerDoc = await _firestore
            .collection('Customers')
            .doc(senderId)
            .get();
        if (!customerDoc.exists) return;
        
        final senderData = customerDoc.data() as Map<String, dynamic>;
        final senderName = senderData['username'] ?? 'Unknown';
        
        await _showNotification(
          chatDoc.id,
          senderId,
          senderName,
          latestMessage['text'] ?? '',
        );
      } else {
        final senderData = senderDoc.data() as Map<String, dynamic>;
        final senderName = senderData['business name'] ?? 'Unknown';
        
        await _showNotification(
          chatDoc.id,
          senderId,
          senderName,
          latestMessage['text'] ?? '',
        );
      }
    }
  }

  static Future<void> _showNotification(
    String chatId,
    String senderId,
    String senderName,
    String message,
  ) async {
    const androidDetails = AndroidNotificationDetails(
      'chat_messages',
      'Chat Messages',
      channelDescription: 'Notifications for new chat messages',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      chatId.hashCode,
      senderName,
      message,
      details,
      payload: '$chatId|$senderId|$senderName',
    );
  }

  static Future<void> requestPermissions() async {
    final platform = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (platform != null) {
      await platform.requestNotificationsPermission();  // Changed from requestPermission to requestNotificationsPermission
    }
  }
}