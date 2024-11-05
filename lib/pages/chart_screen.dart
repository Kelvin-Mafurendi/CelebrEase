
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:maroro/Provider/state_management.dart';
import 'package:maroro/main.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:video_compress/video_compress.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String vendorId;
  final String vendorName;

  const ChatScreen({
    super.key,
    required this.chatId,
    required this.vendorId,
    required this.vendorName,
  });

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  late ChatUser _currentUser;
  late ChatUser _vendor;
  late Stream<QuerySnapshot> _messagesStream;

  @override
  void initState() {
    super.initState();
    _setupUsers();
    _setupMessageStream();
  }

  void _setupUsers() {
    final currentUser = _auth.currentUser!;
    _currentUser = ChatUser(
      id: currentUser.uid,
      firstName: currentUser.displayName ?? 'User',
    );

    _vendor = ChatUser(
      id: widget.vendorId,
      firstName: widget.vendorName,
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

  Future<void> _sendMessage(ChatMessage message) async {
    try {
      final messageData = {
        'text': message.text,
        'senderId': _currentUser.id,
        'timestamp': FieldValue.serverTimestamp(),
      };

      if (message.medias != null && message.medias!.isNotEmpty) {
        final media = message.medias!.first;
        final String? mediaUrl = await _uploadMedia(media);
        if (mediaUrl != null) {
          messageData['mediaUrl'] = mediaUrl;
          messageData['mediaType'] = media.type.toString();
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
      

      Fluttertoast.showToast(
        msg: "Message sent",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0
      );
    } catch (e) {
      print('Error sending message: $e');
      Fluttertoast.showToast(
        msg: "Failed to send message",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0
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

  Future<void> _pickMedia(FileType fileType) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: fileType,
        allowMultiple: false,
      );

      if (result != null) {
        File file = File(result.files.single.path!);
        String fileName = result.files.single.name;

        MediaType mediaType;
        switch (fileType) {
          case FileType.image:
            mediaType = MediaType.image;
            break;
          case FileType.video:
            mediaType = MediaType.video;
            break;
          case FileType.audio:
            mediaType = MediaType.file;
            break;
          default:
            return; // Unsupported file type
        }

        final media = ChatMedia(
          url: file.path,
          type: mediaType,
          fileName: fileName,
        );

        final message = ChatMessage(
          user: _currentUser,
          createdAt: DateTime.now(),
          medias: [media],
        );

        EasyLoading.show(status: 'Sending file...');
        await _sendMessage(message);

        // Update ChangeManager if needed (e.g., for profile image)
        if (fileType == FileType.image) {
          Provider.of<ChangeManager>(context, listen: false)
              .setImage('chat','chatFile',file);
        }
      }
    } catch (e) {
      print('Error picking or sending media: $e');
      EasyLoading.showError('Failed to send file');
    } finally {
      EasyLoading.dismiss();
    }
  }

  Future<File> _fixVideoRotation(File videoFile) async {
    final MediaInfo mediaInfo =
        await VideoCompress.getMediaInfo(videoFile.path);
    if (mediaInfo.orientation == 90 || mediaInfo.orientation == 270) {
      final info = await VideoCompress.compressVideo(
        videoFile.path,
        quality: VideoQuality.MediumQuality,
        includeAudio: true,
        //duration: 0,
      );
      return File(info!.path!);
    }
    return videoFile;
  }

  void _handleMediaTap(ChatMedia media) {
    // Implement media viewing logic here
    print('Media tapped: ${media.url}');
    // You could navigate to a new screen to view the media
  }

  MediaType _getMediaTypeFromString(String? mediaTypeString) {
    switch (mediaTypeString) {
      case 'image':
        return MediaType.image;
      case 'video':
        return MediaType.video;
      default:
        return MediaType.file; // Default to file if type is unknown
    }
  }

  // ... (rest of the methods remain the same)

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: Text(widget.vendorName)),
      body: StreamBuilder<QuerySnapshot>(
        stream: _messagesStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final messages = snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final medias = data['mediaUrl'] != null
                ? [
                    ChatMedia(
                      url: data['mediaUrl'],
                      type: _getMediaTypeFromString(data['mediaType']),
                      fileName: data['fileName'] ?? '',
                    )
                  ]
                : null;
            return ChatMessage(
              text: data['text'] ?? '',
              user: data['senderId'] == _currentUser.id ? _currentUser : _vendor,
              createdAt: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
              medias: medias,
            );
          }).toList();

          return DashChat(
            currentUser: _currentUser,
            onSend: (ChatMessage m) => _sendMessage(m),
            messages: messages,
            messageOptions: MessageOptions(
              currentUserContainerColor: Colors.grey[900],
              timeTextColor: primaryColor,
              showTime: true,
              textColor: isDarkMode ? Colors.black : Colors.black87,
              onTapMedia: _handleMediaTap,
            ),
            inputOptions: InputOptions(
              sendButtonBuilder: (onSend) {
                return IconButton(
                  icon: Icon(Icons.send),
                  color: primaryColor,
                  onPressed: onSend,
                );
              },
              leading: [
                IconButton(
                  icon: Icon(Icons.photo),
                  onPressed: () => _pickMedia(FileType.image),
                ),
                IconButton(
                  icon: Icon(Icons.videocam),
                  onPressed: () => _pickMedia(FileType.video),
                ),
                IconButton(
                  icon: Icon(Icons.mic),
                  onPressed: () => _pickMedia(FileType.audio),
                ),
              ],
              textCapitalization: TextCapitalization.sentences,
              inputTextStyle: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
              inputDecoration: InputDecoration(
                hintText: "Type a message",
                hintStyle: TextStyle(
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                ),
                fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
