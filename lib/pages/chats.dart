import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:maroro/modules/reusable_widgets.dart';
import 'package:maroro/pages/chart_screen.dart';

class Chats extends StatelessWidget {
  final String userType;
  const Chats({super.key, required this.userType});

  @override
  Widget build(BuildContext context) {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final FirebaseAuth auth = FirebaseAuth.instance;

    return Scaffold(
      appBar: AppBar(title: const Text('Chats')),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestore
            .collection('chats')
            .where('participants', arrayContains: auth.currentUser!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final chats = snapshot.data!.docs;

          if (chats.isEmpty) {
            return const Center(child: Text('No chats yet'));
          }

          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index].data() as Map<String, dynamic>;
              final chatId = chats[index].id;
              final participants = List<String>.from(chat['participants'] ?? []);

              // Safe way to find other user ID
              String? otherUserId;
              try {
                otherUserId = participants.firstWhere(
                  (id) => id != auth.currentUser!.uid,
                );
              } catch (e) {
                // Handle the case where no other user is found
                return const ListTile(
                  title: Text('Chat unavailable'),
                  subtitle: Text('No other participant found'),
                );
              }

              if (otherUserId.isEmpty) {
                return const ListTile(
                  title: Text('Invalid chat'),
                  subtitle: Text('Missing participant information'),
                );
              }

              final future = userType == 'Vendors'
                  ? firestore.collection('Customers').where('userId', isEqualTo: otherUserId).limit(1).get()
                  : firestore.collection('Vendors').where('userId', isEqualTo: otherUserId).limit(1).get();

              return FutureBuilder<QuerySnapshot>(
                future: future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const ListTile(
                      title: Text('Loading...'),
                      leading: CircularProgressIndicator(),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return ListTile(
                      title: Text('User not found'),
                      subtitle: Text('ID: $otherUserId'),
                    );
                  }

                  final otherUserData = snapshot.data!.docs.first.data() as Map<String, dynamic>;
                  final otherUserName = userType == 'Customers'
                      ? otherUserData['business name'] ?? 'Unknown Business'
                      : otherUserData['username'] ?? 'Unknown User';

                  return ListTile(
                    title: Text(otherUserName),
                    subtitle: Text(chat['lastMessage'] ?? 'No messages yet'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(
                            chatId: chatId,
                            otherUserId: otherUserId.toString(),
                            otherUserName: otherUserName,
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}