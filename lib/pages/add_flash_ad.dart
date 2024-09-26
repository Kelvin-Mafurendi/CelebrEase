import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maroro/Provider/state_management.dart';
import 'package:maroro/modules/add_flashAd_image.dart';
import 'package:maroro/modules/add_highlight_images.dart';
import 'package:maroro/modules/add_package_image.dart';
import 'package:maroro/modules/flash_ad.dart';
import 'package:maroro/modules/mybutton.dart';
import 'package:provider/provider.dart';

class AddFlashAd extends StatefulWidget {
  const AddFlashAd({super.key});

  @override
  State<AddFlashAd> createState() => _AddFlashAdState();
}

class _AddFlashAdState extends State<AddFlashAd> {
  late TextEditingController descriptionController;
  late TextEditingController titleController;

  @override
  void initState() {
    super.initState();
    final flashAd = Provider.of<ChangeManager>(context, listen: false).flashAd;

    // Initialize controllers with null checks
    descriptionController = TextEditingController(text: '');
    titleController = TextEditingController(text: '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        scrollDirection: Axis.vertical,
        children: [
          Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 15),
              child: Column(
                children: [
                  AddFlashadImage(),
                  const SizedBox(height: 10),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Upload Flash Image'),
                    ],
                  )
                ],
              )),
          buildTextField(
            titleController,
            'Title',
            'Ad title..',
            MaxLengthEnforcement.enforced,
          ),
          const Spacer(),
          buildTextField(
              descriptionController,
              'Advert',
              'Type your Ad Here...\nNote that FlashAds a CelebrEase exclusive advertisements which last for 24 hours on CelebrEase.',
              MaxLengthEnforcement.enforced,
              maxLines: 10,
              maxLength: 500),
          const Spacer(),
          Consumer<ChangeManager>(
            builder: (context, changeManager, child) {
              return MyButton(
                onTap: () async {
                  try {
                    Map<String, dynamic> updatedData = {};

                    if (descriptionController.text.isNotEmpty) {
                      updatedData['description'] = descriptionController.text;
                    }
                    if (titleController.text.isNotEmpty) {
                      updatedData['title'] = titleController.text;
                    }

                    if (changeManager.getFlashImage() != null) {
                      updatedData['mainPicPath'] =
                          changeManager.getFlashImage()!.path;
                    }

                    changeManager.updateFlashAd(updatedData);
                    Navigator.pop(context);
                  } catch (e) {
                    // ignore: avoid_print
                    print('Error in AdFlashAd: $e');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error updating FlashAd: $e')),
                    );
                  }
                },
                todo: 'Post',
              );
            },
          ),
        ],
      ),
    );
  }

  Widget buildTextField(TextEditingController controller, String label,
      String hintText, MaxLengthEnforcement maxLengthEnforcement,
      {int maxLines = 1, int? maxLength}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        maxLength: maxLength,
        maxLengthEnforcement: maxLengthEnforcement,
        decoration: InputDecoration(
          hintText: hintText,
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        style: GoogleFonts.lateef(
          fontSize: 22,
        ),
      ),
    );
  }

  @override
  void dispose() {
    descriptionController.dispose();
    titleController.dispose();
    super.dispose();
  }
}
