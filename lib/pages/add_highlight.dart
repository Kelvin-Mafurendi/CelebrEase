// ignore_for_file: unnecessary_null_comparison

import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:maroro/modules/add_highlight_images.dart';
import 'package:provider/provider.dart';
import 'package:maroro/Provider/state_management.dart';
import 'package:maroro/modules/add_image.dart';
import 'package:maroro/modules/mybutton.dart';

class AddHighlight extends StatefulWidget {
  const AddHighlight({super.key, required Map initialData});

  @override
  State<AddHighlight> createState() => _AddHighlight();
}

class _AddHighlight extends State<AddHighlight> {
  late TextEditingController packageNameController;
  late TextEditingController rateController;
  late TextEditingController descriptionController;

  @override
  void initState() {
    super.initState();
    final highlightData =
        Provider.of<ChangeManager>(context, listen: false).highlightData;
    packageNameController =
        TextEditingController(text: highlightData['brandName']);
    rateController = TextEditingController(text: highlightData['location']);
    descriptionController =
        TextEditingController(text: highlightData['category']);
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
                  AddHighlightImage(),
                  const SizedBox(height: 10,),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Upload Main Highlight Image',),
                    ],
                  )
                ],
              )),
          buildTextField(packageNameController, 'Package Name',
              'Enter package name for this highlight',MaxLengthEnforcement.none),
          buildTextField(
              rateController, 'Rate', 'How much was this package e.g per hour',MaxLengthEnforcement.none),
          buildTextField(descriptionController, 'Description',
              'What do you want your audience to know about this highlight?',MaxLengthEnforcement.enforced,
              maxLines: 10,maxLenth: 100
              ),
          AddHighLightVideo(),
          const SizedBox(height: 10,),
          const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Upload Highlight Video/Image',),
                    ],
                  ),
          const SizedBox(height: 150),
          Consumer<ChangeManager>(builder: (context, changeManager, child) {
            return MyButton(
              onTap: () async {
                Map<String, dynamic> updatedData = {};

                // Include all fields, not just changed ones
                updatedData['packageName'] = packageNameController.text;
                updatedData['rate'] = rateController.text;
                updatedData['description'] = descriptionController.text;

                // Include file paths if they've been set
                if (changeManager.getHighlightImage() != null) {
                  updatedData['mainPicPath'] =
                      changeManager.getHighlightImage()!.path;
                }
                if (changeManager.getHighlightVideo() != null) {
                  updatedData['videoPath'] =
                      changeManager.getHighlightVideo()!.path;
                }

                Provider.of<ChangeManager>(context, listen: false)
                    .updateHighlight(updatedData);

                Navigator.pop(context);
              },
              todo: 'Save Changes',
            );
          }),
        ],
      ),
    );
  }

  Widget buildTextField(
      TextEditingController controller, String label, String hintText,maxLengthEnforcement,
      {int maxLines = 1,maxLenth}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        maxLength: maxLenth,
        maxLengthEnforcement: maxLengthEnforcement,
        decoration: InputDecoration(
          hintText: hintText, //,
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    packageNameController.dispose();
    rateController.dispose();
    descriptionController.dispose();
    super.dispose();
  }
}
