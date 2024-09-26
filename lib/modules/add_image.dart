import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:provider/provider.dart';
import 'package:maroro/Provider/state_management.dart';

// ignore: must_be_immutable
class AddProfileImage extends StatefulWidget {
  const AddProfileImage({super.key});

  @override
  State<AddProfileImage> createState() => _AddProfileImageState();
}

class _AddProfileImageState extends State<AddProfileImage> {
  dynamic image;
  

  getImage(context) async {
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(type: FileType.image, allowMultiple: false);

    if (result != null) {
      image = result.files.first.bytes;
      String imagePath = result.files.first.path!;
      Provider.of<ChangeManager>(context, listen: false)
          .setProfileImage(File(imagePath));
    }
  }
  @override
  void initState() {
    image = null;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
     
    return Consumer<ChangeManager>(
      builder: (context, changeManager, child) {
        File? image = changeManager.getProfileImage();
        return Stack(
          children: [
            CircleAvatar(
              backgroundImage: image != null ? FileImage(image) : const CachedNetworkImageProvider('https://cdn.vectorstock.com/i/1000v/08/19/gray-photo-placeholder-icon-design-ui-vector-35850819.avif'),
              backgroundColor: Colors.grey[200],
              minRadius: 100,
              //child: const Text('data',textScaler: TextScaler.linear(5),style: TextStyle(color: Colors.white),),
            ),
            Positioned(
              right: 100,
              bottom: 5,
              child: InkWell(
                onTap: () => getImage(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    FluentSystemIcons.ic_fluent_camera_add_regular,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}