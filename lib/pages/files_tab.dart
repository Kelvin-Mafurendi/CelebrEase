import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class FilesTab extends StatelessWidget {
  final String groupId;

  const FilesTab({Key? key, required this.groupId}) : super(key: key);

  Future<void> _uploadFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null) {
      final file = result.files.first;
      final ref = FirebaseStorage.instance
          .ref()
          .child('planning_groups')
          .child(groupId)
          .child(file.name);

      // Upload file
      if (file.bytes != null) {
        await ref.putData(file.bytes!);
      } else if (file.path != null) {
        await ref.putFile(File(file.path!));
      }

      // Add file reference to planning group
      final downloadUrl = await ref.getDownloadURL();
      await FirebaseFirestore.instance
          .collection('planningGroups')
          .doc(groupId)
          .update({
        'sharedFiles': FieldValue.arrayUnion([
          {
            'name': file.name,
            'url': downloadUrl,
            'uploadedBy': FirebaseAuth.instance.currentUser!.uid,
            'uploadedAt': FieldValue.serverTimestamp(),
          }
        ]),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('planningGroups')
            .doc(groupId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final files = (snapshot.data!.get('sharedFiles') as List? ?? [])
              .cast<Map<String, dynamic>>();

          if (files.isEmpty) {
            return Center(
              child: Text('No files shared yet'),
            );
          }

          return ListView.builder(
            itemCount: files.length,
            itemBuilder: (context, index) {
              final file = files[index];
              return ListTile(
                leading: Icon(_getFileIcon(file['name'])),
                title: Text(file['name']),
                subtitle: Text(DateFormat.yMMMd()
                    .format((file['uploadedAt'] as Timestamp).toDate())),
                trailing: IconButton(
                  icon: Icon(Icons.download),
                  onPressed: () async {
                    // Implement file download
                    // This would typically open the file URL in a browser
                    // or use a plugin like url_launcher
                    await launchUrl(Uri.parse(file['url']));
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _uploadFile,
        child: Icon(Icons.add),
        tooltip: 'Upload File',
      ),
    );
  }

  IconData _getFileIcon(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Icons.image;
      default:
        return Icons.insert_drive_file;
    }
  }
}