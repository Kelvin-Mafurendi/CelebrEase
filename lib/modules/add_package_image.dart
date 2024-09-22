import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/material.dart';
import 'package:maroro/Provider/state_management.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class AddPackageImage extends StatelessWidget {
  AddPackageImage({super.key});

  dynamic image;

  getImage(context) async {
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(type: FileType.image, allowMultiple: false);

    if (result != null) {
      image = result.files.first.bytes;
      String imagePath = result.files.first.path!;
      Provider.of<ChangeManager>(context, listen: false)
          .setPackageImage(File(imagePath));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChangeManager>(
      builder: (context, changeManager, child) {
        File? image = changeManager.getPackageImage();
        return Stack(
          children: [
            CircleAvatar(
              backgroundImage: image != null ? FileImage(image) : null,
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
                    color: Color.fromRGBO(255, 255, 255, 0.7),
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
