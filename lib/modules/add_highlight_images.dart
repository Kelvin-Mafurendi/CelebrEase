import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:provider/provider.dart';
import 'package:maroro/Provider/state_management.dart';

// ignore: must_be_immutable
class AddHighlightImage extends StatelessWidget {
  AddHighlightImage({super.key});

  dynamic image;

  getImage(context) async {
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(type: FileType.image, allowMultiple: false);

    if (result != null) {
      image = result.files.first.bytes;
      String imagePath = result.files.first.path!;
      Provider.of<ChangeManager>(context, listen: false)
          .setHighlightImage(File(imagePath));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChangeManager>(
      builder: (context, changeManager, child) {
        File? image = changeManager.getHighlightImage();
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

//Adding Video
// ignore: must_be_immutable
class AddHighLightVideo extends StatelessWidget {
  AddHighLightVideo({super.key});

  dynamic image;

  getVideo(context) async {
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(type: FileType.any, allowMultiple: false);

    if (result != null) {
      image = result.files.first.bytes;
      String imagePath = result.files.first.path!;
      Provider.of<ChangeManager>(context, listen: false)
          .setHighlightVideo(File(imagePath));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChangeManager>(
      builder: (context, changeManager, child) {
        File? image = changeManager.getHighlightVideo();
        return Stack(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.width * 0.9,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              child: CircleAvatar(
                backgroundImage: image != null ? FileImage(image) : null,
                backgroundColor: Colors.grey[200],
                minRadius: 100,
                //child: const Text('data',textScaler: TextScaler.linear(5),style: TextStyle(color: Colors.white),),
              ),
            ),
            Positioned(
              right: 100,
              bottom: 5,
              child: InkWell(
                onTap: () => getVideo(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    FluentSystemIcons.ic_fluent_video_regular,
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

//Adding Multiple Images/Other Highligh images

// ignore: must_be_immutable
class AddOtherHighlightImages extends StatelessWidget {
  AddOtherHighlightImages({super.key});

  dynamic image;

  getImages(context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
    );

    if (result != null) {
      image = result.files.toList();
      //List<String> imagePath = image.path;
      Provider.of<ChangeManager>(context, listen: false)
          .setOtherHighlightImages((image));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChangeManager>(
      builder: (context, changeManager, child) {
        File? image = changeManager.getOtherHighlightImages();
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
                onTap: () => getImages(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    FluentSystemIcons.ic_fluent_image_add_regular,
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
