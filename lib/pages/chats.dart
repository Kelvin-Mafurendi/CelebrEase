
// Updated Chats class in chats.dart

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
              final participants = chat['participants'] as List<dynamic>;

              final otherUserId = participants.firstWhere(
                (id) => id != auth.currentUser!.uid,
                orElse: () => null,
              );

              if (otherUserId == null) {
                return const ListTile(title: Text('Unknown Participant'));
              }

              final future = userType == 'Vendors'
                  ? firestore.collection('Customers').doc(otherUserId).get()
                  : firestore.collection('Vendors').doc(otherUserId).get();

              return FutureBuilder<DocumentSnapshot>(
                future: future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const ListTile(title: Text('Loading...'));
                  }

                  if (!snapshot.hasData || snapshot.data == null || !snapshot.data!.exists) {
                    return const ListTile(title: Text('User not found'));
                  }

                  final otherUserData = snapshot.data!.data() as Map<String, dynamic>;
                  final otherUserName = userType == 'Customers'
                      ? otherUserData['business name'] ?? 'Unknown'
                      : otherUserData['username'] ?? 'Unknown';

                  return ListTile(
                    title: Text(otherUserName),
                    subtitle: Text(chat['lastMessage'] ?? 'No messages yet'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(
                            chatId: chatId,
                            vendorId: otherUserId,
                            vendorName: otherUserName,
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