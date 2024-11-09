// chat_types.dart
import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:jitsi_meet_wrapper/jitsi_meet_wrapper.dart';
import 'package:maroro/main.dart';
import 'package:maroro/modules/some_classes.dart';
import 'package:maroro/pages/calls.dart';
import 'package:maroro/pages/media_view.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_compress/video_compress.dart';
import 'package:path/path.dart' as path;

enum MessageType { text, media, proposal, milestone, checklist }

enum CallType { audio, video }

// Call status enum
enum CallStatus { pending, accepted, declined, ended }

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String otherUserId;
  final String otherUserName;
  final bool isGroup;

  const ChatScreen({
    super.key,
    required this.chatId,
    required this.otherUserId,
    required this.otherUserName,
    this.isGroup = false,
  });

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>
    with SingleTickerProviderStateMixin, CallHandler {
  late TabController _tabController;
  @override
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  @override
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late ChatUser _currentUser;
  late Stream<QuerySnapshot> _messagesStream;
  final List<String> _quickResponses = [
    "I'll check and get back to you shortly",
    "Would you like to schedule a consultation?",
    "Here's our pricing package",
  ];
  final FirebaseStorage _storage = FirebaseStorage.instance;

  List<ChatMessage> _processMessages(List<QueryDocumentSnapshot> docs) {
    return docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;

      // Handle media messages
      final medias = data['mediaUrl'] != null
          ? [
              ChatMedia(
                url: data['mediaUrl'],
                type: _getMediaTypeFromString(data['mediaType']),
                fileName: data['fileName'] ?? '',
              )
            ]
          : null;

      // Store messageId in customProperties instead of trying to set it directly
      Map<String, dynamic> customProperties =
          Map<String, dynamic>.from(data['customProperties'] ?? {});
      customProperties['messageId'] = doc.id; // Store the message ID here

      return ChatMessage(
        text: data['text'] ?? '',
        user: ChatUser(
          id: data['senderId'],
          firstName: data['senderName'] ?? '',
        ),
        createdAt:
            (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
        medias: medias,
        customProperties: customProperties,
      );
    }).toList();
  }

  Widget _buildMediaPreview(ChatMedia media) {
    switch (media.type) {
      case MediaType.image:
        return Container(
          constraints: BoxConstraints(
            maxHeight: 200,
            maxWidth: 300,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              media.url,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(child: CircularProgressIndicator());
              },
            ),
          ),
        );
      case MediaType.video:
        return Container(
          constraints: BoxConstraints(
            maxHeight: 200,
            maxWidth: 300,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Container(
                    color: Colors.black,
                    child: Center(
                      child: Icon(
                        Icons.play_circle_fill,
                        size: 48,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _handleMediaTap(media),
                  child: SizedBox(
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
              ),
            ],
          ),
        );
      default:
        return ListTile(
          leading: Icon(Icons.insert_drive_file),
          title: Text(media.fileName),
          onTap: () => _openFile(media.url),
        );
    }
  }

  Widget _buildProposalMessage(Map<String, dynamic> details) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.description, color: Colors.blue),
              SizedBox(width: 8),
              Text(
                'Proposal: ${details['title']}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          Divider(),
          Text(
            details['description'],
            style: TextStyle(fontSize: 14),
          ),
          SizedBox(height: 8),
          Text(
            'Price: \$${details['price']}',
            style: TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => _handleProposalResponse(details, true),
                child: Text(
                  'Accept',
                  style: TextStyle(color: Colors.green),
                ),
              ),
              SizedBox(width: 8),
              TextButton(
                onPressed: () => _handleProposalResponse(details, false),
                child: Text('Decline'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChecklistMessage(List<dynamic> items, String messageId) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.checklist, color: Colors.green),
              SizedBox(width: 8),
              Text(
                'Checklist',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          Divider(),
          ...items.asMap().entries.map<Widget>((entry) {
            final int index = entry.key;
            final item = entry.value;
            return CheckboxListTile(
              value: item['completed'] ?? false,
              onChanged: (bool? value) => _updateChecklistItemInMessage(
                messageId, // This is now correctly passed from customProperties
                index,
                value ?? false,
                item['text'],
              ),
              title: Text(
                item['text'],
                style: TextStyle(
                  decoration: item['completed'] == true
                      ? TextDecoration.lineThrough
                      : null,
                ),
              ),
              controlAffinity: ListTileControlAffinity.leading,
              dense: true,
            );
          }),
        ],
      ),
    );
  }

  Future<void> _updateChecklistItemInMessage(
      String messageId, int index, bool completed, String itemText) async {
    try {
      // Get the message document
      final messageDoc = await _firestore
          .collection('chats')
          .doc(widget.chatId)
          .collection('messages')
          .doc(messageId)
          .get();

      if (!messageDoc.exists) return;

      final data = messageDoc.data()!;
      final customProperties =
          Map<String, dynamic>.from(data['customProperties'] ?? {});
      final items = List<dynamic>.from(customProperties['items'] ?? []);

      // Update the specific item
      if (index < items.length) {
        items[index]['completed'] = completed;

        // Update the message document
        await messageDoc.reference.update({
          'customProperties': {
            ...customProperties,
            'items': items,
          },
        });

        // Send notification to the checklist creator
        if (completed && data['senderId'] != _currentUser.id) {
          await _firestore.collection('notifications').add({
            'userId': data['senderId'],
            'type': 'checklist_update',
            'title': 'Checklist Item Completed',
            'message': '${_currentUser.firstName} completed: $itemText',
            'timestamp': FieldValue.serverTimestamp(),
            'read': false,
            'chatId': widget.chatId,
            'messageId': messageId,
          });
        }
      }
    } catch (e) {
      print('Error updating checklist item: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating checklist item')),
      );
    }
  }

  Future<void> _handleProposalResponse(
      Map<String, dynamic> proposal, bool accepted) async {
    try {
      // Update the proposal status
      final proposalRef = await _firestore.collection('proposals').add({
        ...proposal,
        'accepted': accepted,
        'respondedAt': FieldValue.serverTimestamp(),
        'responderId': _currentUser.id,
      });

      // Send a notification message
      await _sendMessage(
        ChatMessage(
          user: _currentUser,
          text: accepted ? "Proposal Accepted" : "Proposal Declined",
          createdAt: DateTime.now(),
          customProperties: {
            'type': 'proposal_feedback',
            'proposalId': proposalRef.id,
            'accepted': accepted,
          },
        ),
      );

      // Send notification to the proposal sender
      await _firestore.collection('notifications').add({
        'userId': proposal['senderId'],
        'type': 'proposal_response',
        'title': 'Proposal ${accepted ? 'Accepted' : 'Declined'}',
        'message':
            '${_currentUser.firstName} has ${accepted ? 'accepted' : 'declined'} your proposal',
        'timestamp': FieldValue.serverTimestamp(),
        'read': false,
        'proposalId': proposalRef.id,
      });
    } catch (e) {
      print('Error handling proposal response: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating proposal status')),
      );
    }
  }

  Future<void> _updateChecklistItem(String itemId, bool? completed) async {
    if (completed != null) {
      await _firestore
          .collection('checklists')
          .doc(itemId)
          .update({'completed': completed});
    }
  }

  void _handleMediaTap(ChatMedia media) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MediaViewerScreen(
          url: media.url,
          mediaType: media.type,
        ),
      ),
    );
  }

  Widget _buildChecklistItem(Map<String, dynamic> item) {
    bool isCompleted = item['completed'] ?? false;

    return ListTile(
      leading: Checkbox(
        value: isCompleted,
        onChanged: (bool? value) async {
          if (value != null) {
            try {
              await _updateChecklistItem(item['id'], value);

              // Send notification when item is checked
              if (value) {
                await _firestore.collection('notifications').add({
                  'userId': widget.otherUserId,
                  'type': 'checklist_update',
                  'title': 'Checklist Item Completed',
                  'message':
                      '${_currentUser.firstName} completed: ${item['text']}',
                  'timestamp': FieldValue.serverTimestamp(),
                  'read': false,
                });

                // Send a message to the chat about the completed item
                await _sendMessage(
                  ChatMessage(
                    user: _currentUser,
                    text: "✓ Completed: ${item['text']}",
                    createdAt: DateTime.now(),
                    customProperties: {
                      'type': 'checklist_update',
                      'itemId': item['id'],
                      'completed': true,
                    },
                  ),
                );
              }
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error updating checklist item: $e')),
              );
            }
          }
        },
      ),
      title: Text(
        item['text'],
        style: TextStyle(
          decoration: isCompleted ? TextDecoration.lineThrough : null,
        ),
      ),
      // Add progress indicator if needed
      trailing: item['inProgress'] == true
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : null,
    );
  }

  Future<void> _showChecklistDialog() async {
    final items = await showDialog<List<String>>(
      context: context,
      builder: (context) => ChecklistDialog(),
    );

    if (items != null && items.isNotEmpty) {
      final checklistItems = items
          .map((item) => {
                'id': UniqueKey().toString(),
                'text': item,
                'completed': false,
              })
          .toList();

      await _sendMessage(
        ChatMessage(
          user: _currentUser,
          text: "New Checklist",
          createdAt: DateTime.now(),
          customProperties: {
            'type': 'checklist',
            'items': checklistItems,
          },
        ),
      );
    }
  }

  Future<void> _openFile(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to launch the URL: $url')),
        );
      }
    } catch (e) {
      print('Error opening file: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error opening file: $e')),
      );
    }
  }

  Future<void> _pickAndSendMedia() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: [
          'jpg',
          'jpeg',
          'png',
          'gif',
          'mp4',
          'pdf',
          'doc',
          'docx'
        ],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = File(result.files.first.path!);
        final fileName = result.files.first.name;
        final fileExtension = path.extension(fileName).toLowerCase();

        // Show loading indicator
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Uploading file...',
                      style: TextStyle(color: Colors.white)),
                ],
              ),
            );
          },
        );

        // Process file based on type
        File processedFile = file;
        MediaType mediaType;

        // Handle different file types
        if (['.jpg', '.jpeg', '.png', '.gif'].contains(fileExtension)) {
          mediaType = MediaType.image;
        } else if (fileExtension == '.mp4') {
          mediaType = MediaType.video;
          // Compress video if needed
          if (await file.length() > 10 * 1024 * 1024) {
            // If larger than 10MB
            final compressedVideo = await VideoCompress.compressVideo(
              file.path,
              quality: VideoQuality.MediumQuality,
              includeAudio: true,
            );
            if (compressedVideo?.path != null) {
              processedFile = File(compressedVideo!.path!);
            }
          }
        } else {
          mediaType = MediaType.file;
        }

        // Create and send message with media
        final media = ChatMedia(
          url: processedFile.path,
          type: mediaType,
          fileName: fileName,
        );

        await _sendMessage(
          ChatMessage(
            user: _currentUser,
            createdAt: DateTime.now(),
            medias: [media],
          ),
        );

        // Hide loading indicator
        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('File sent successfully')),
        );
      }
    } catch (e) {
      Navigator.of(context).pop(); // Hide loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending file: $e')),
      );
    }
  }

  Future<void> _sendMessage(ChatMessage message) async {
    try {
      final messageData = {
        'text': message.text,
        'senderId': message.user.id,
        'senderName': message.user.firstName,
        'otheruser': widget.otherUserId,
        'timestamp': FieldValue.serverTimestamp(),
        'customProperties': message.customProperties,
      };

      if (message.medias != null && message.medias!.isNotEmpty) {
        final media = message.medias!.first;
        final String? mediaUrl = await _uploadMedia(media);
        if (mediaUrl != null) {
          messageData['mediaUrl'] = mediaUrl;
          messageData['mediaType'] = media.type.toString();
          messageData['fileName'] = media.fileName;
        }
      }

      await _firestore
          .collection('chats')
          .doc(widget.chatId)
          .collection('messages')
          .add(messageData);

      await _firestore.collection('chats').doc(widget.chatId).update({
        'lastMessage': message.text,
        'lastMessageTime': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending message: $e')),
      );
    }
  }

  Future<String?> _uploadMedia(ChatMedia media) async {
    try {
      final path =
          'chat/${widget.chatId}/${DateTime.now().millisecondsSinceEpoch}_${media.fileName}';
      final ref = _storage.ref().child(path);
      final uploadTask = ref.putFile(File(media.url));
      final snapshot = await uploadTask.whenComplete(() {});
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading media: $e');
      return null;
    }
  }

  Stream<QuerySnapshot> _getFilesStream() {
    return _firestore
        .collection('chats')
        .doc(widget.chatId)
        .collection('messages')
        .where('mediaUrl', isNull: false)
        .snapshots();
  }

  Stream<DocumentSnapshot> _getMilestonesStream() {
    return _firestore
        .collection('chats')
        .doc(widget.chatId)
        .collection('milestones')
        .doc('timeline')
        .snapshots();
  }

  Widget _buildFilePreview(Map<String, dynamic> file) {
    final String mediaType = file['mediaType'] ?? '';
    final String url = file['mediaUrl'] ?? '';

    return Card(
      child: InkWell(
        onTap: () => _openFile(url),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              mediaType.contains('image')
                  ? Icons.image
                  : mediaType.contains('video')
                      ? Icons.video_library
                      : Icons.insert_drive_file,
              size: 48,
            ),
            SizedBox(height: 8),
            Text(
              file['fileName'] ?? 'File',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  MediaType _getMediaTypeFromString(String? mediaTypeString) {
    switch (mediaTypeString) {
      case 'MediaType.image':
        return MediaType.image;
      case 'MediaType.video':
        return MediaType.video;
      default:
        return MediaType.file;
    }
  }

  @override
  void dispose() {
    disposeCallListener(); // Add this line
    _tabController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _setupUsers();
    _setupMessageStream();
    initializeCallListener(context); // Add this line
  }

  void _setupUsers() {
    final currentUser = _auth.currentUser!;
    _currentUser = ChatUser(
      id: currentUser.uid,
      firstName: currentUser.displayName ?? 'User',
    );
  }

  void _setupMessageStream() {
    _messagesStream = _firestore
        .collection('chats')
        .doc(widget.chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<void> _showCallOptions() async {
    await showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.video_call),
              title: Text('Video Call'),
              onTap: () {
                Navigator.pop(context);
                _initiateCall(CallType.video);
              },
            ),
            ListTile(
              leading: Icon(Icons.phone),
              title: Text('Audio Call'),
              onTap: () {
                Navigator.pop(context);
                _initiateCall(CallType.audio);
              },
            ),
            
          ],
        ),
      ),
    );
  }

  Future _initiateCall(CallType callType) async {
    try {
      // Generate room name
      final roomName = widget.chatId;

      // Create call record in Firestore
      final callDoc = await _firestore.collection('calls').add({
        'callerId': _currentUser.id,
        'callerName': _currentUser.firstName,
        'receiverId': widget.otherUserId,
        'receiverName': widget.otherUserName,
        'type': callType.toString(),
        'status': 'pending',
        'timestamp': FieldValue.serverTimestamp(),
        'roomName': roomName, // Add room name to call data
      });

      // Send notification to receiver
      await _firestore.collection('notifications').add({
        'userId': widget.otherUserId,
        'type': 'incoming_call',
        'title': '${callType == CallType.video ? 'Video' : 'Audio'} Call',
        'message': '${_currentUser.firstName} is calling you',
        'callId': callDoc.id,
        'roomName': roomName, // Add room name to notification
        'timestamp': FieldValue.serverTimestamp(),
        'read': false,
      });

      // Navigate to call screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CallScreen(
            userId: widget.otherUserId,
            userName: widget.otherUserName,
            callType: callType,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to initiate call: $e')),
      );
    }
  }


  Future<void> _shareCallLink() async {
    final roomName =
        'room_${widget.chatId}_${DateTime.now().millisecondsSinceEpoch}';
    final callLink = 'CelebrEase://call/$roomName';

    try {
      // Save call link to Firestore
      await _firestore
          .collection('chats')
          .doc(widget.chatId)
          .collection('messages')
          .add({
        'text': 'Join my call: $callLink',
        'senderId': _currentUser.id,
        'senderName': _currentUser.firstName,
        'timestamp': FieldValue.serverTimestamp(),
        'customProperties': {
          'type': 'call_link',
          'roomName': roomName,
        },
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to share call link: $e')),
      );
    }
  }

  Future<void> _startVideoCall() async {
    final roomName = widget.chatId;

    var options = JitsiMeetingOptions(
      roomNameOrUrl: roomName,
      userDisplayName: _currentUser.firstName,
      userEmail: _auth.currentUser?.email,
      isAudioMuted: false,
      isVideoMuted: false,
    );

    await JitsiMeetWrapper.joinMeeting(options: options);
  }

  Future<void> _sendProposal() async {
    // Show proposal dialog and send as special message type
    final proposal = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => ProposalDialog(),
    );

    if (proposal != null) {
      await _sendMessage(
        ChatMessage(
          user: _currentUser,
          text: "New Proposal",
          createdAt: DateTime.now(),
          customProperties: {
            'type': 'proposal',
            'details': proposal,
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.otherUserName),
        actions: [
          IconButton(
            icon: Icon(Icons.call),
            onPressed: _showCallOptions,
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'proposal':
                  _sendProposal();
                  break;
                case 'checklist':
                  _showChecklistDialog();
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'proposal',
                child: Text('Send Proposal'),
              ),
              PopupMenuItem(
                value: 'checklist',
                child: Text('Create Checklist'),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Chat'),
            Tab(text: 'Files'),
            Tab(text: 'Timeline'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildChatTab(),
          _buildFilesTab(),
          _buildTimelineTab(),
        ],
      ),
    );
  }

  Widget _buildChatTab() {
    return StreamBuilder(
      stream: _messagesStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final messages = _processMessages(snapshot.data!.docs);

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Expanded(
                child: DashChat(
                  currentUser: _currentUser,
                  onSend: _sendMessage,
                  messages: messages,
                  messageOptions: MessageOptions(
                    showTime: true,
                    containerColor: Theme.of(context).primaryColor,
                    textColor: Colors.white,
                    messagePadding: const EdgeInsets.all(8),
                    messageRowBuilder: (message, previousMessage, nextMessage,
                        isAfterDateSeparator, isBeforeDateSeparator) {
                      final String? messageId =
                          message.customProperties?['messageId'] as String?;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (message.customProperties?['type'] == 'proposal')
                            _buildProposalMessage(
                                message.customProperties!['details']),
                          if (message.customProperties?['type'] ==
                                  'checklist' &&
                              messageId != null)
                            _buildChecklistMessage(
                              message.customProperties!['items'],
                              messageId,
                            ),
                          if (message.medias?.isNotEmpty ?? false)
                            _buildMediaPreview(message.medias!.first),
                          if (message.text.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 10),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: message.user.id == _currentUser.id
                                      ? Colors.grey[800]
                                      : const Color.fromARGB(255, 117, 133, 27),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  message.text,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                  inputOptions: InputOptions(
                    leading: [
                      IconButton(
                        icon: const Icon(Icons.attach_file),
                        onPressed: _pickAndSendMedia,
                      ),
                    ],
                  ),
                ),
              ),
              _buildQuickResponses(),
              SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickResponses() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _quickResponses.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: ActionChip(
              label: Text(_quickResponses[index]),
              onPressed: () => _sendMessage(
                ChatMessage(
                  text: _quickResponses[index],
                  user: _currentUser,
                  createdAt: DateTime.now(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilesTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: _getFilesStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        final files = snapshot.data!.docs;
        return GridView.builder(
          padding: EdgeInsets.all(8),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: files.length,
          itemBuilder: (context, index) {
            final file = files[index].data() as Map<String, dynamic>;
            return _buildFilePreview(file);
          },
        );
      },
    );
  }

  // Add the createMilestone method
  Future<void> _createMilestone() async {
    final milestone = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => MilestoneDialog(),
    );

    if (milestone != null) {
      try {
        final docRef = _firestore
            .collection('chats')
            .doc(widget.chatId)
            .collection('milestones')
            .doc('timeline');

        await docRef.set({
          'milestones': FieldValue.arrayUnion([milestone]),
        }, SetOptions(merge: true));

        // Send a message to the chat about the new milestone
        await _sendMessage(
          ChatMessage(
            user: _currentUser,
            text: "New Milestone Created: ${milestone['title']}",
            createdAt: DateTime.now(),
            customProperties: {
              'type': 'milestone',
              'milestone': milestone,
            },
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating milestone: $e')),
        );
      }
    }
  }

  Widget _buildTimelineTab() {
    return Stack(
      children: [
        StreamBuilder<DocumentSnapshot>(
          stream: _getMilestonesStream(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }

            final data = snapshot.data!.data() as Map<String, dynamic>?;
            if (data == null || !data.containsKey('milestones')) {
              return Center(child: Text('No milestones yet'));
            }

            final milestones = (data['milestones'] as List?)?.map((item) {
                  if (item is! Map<String, dynamic>) {
                    return {
                      'title': 'Invalid milestone',
                      'description': '',
                      'dueDate': DateTime.now().toString(),
                      'completed': false,
                    };
                  }
                  return item;
                }).toList() ??
                [];

            if (milestones.isEmpty) {
              return Center(child: Text('No milestones yet'));
            }

            return ListView.builder(
              itemCount: milestones.length,
              itemBuilder: (context, index) {
                return TimelineTile(
                  milestone: milestones[index],
                  isFirst: index == 0,
                  isLast: index == milestones.length - 1,
                );
              },
            );
          },
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            backgroundColor: Theme.of(context).primaryColorDark.withOpacity(0.6),
            onPressed: _createMilestone,
            tooltip: 'Create Milestone',
            child: Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}


// Call handler mixin
