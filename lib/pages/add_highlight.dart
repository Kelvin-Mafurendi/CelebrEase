import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:maroro/Provider/state_management.dart';
import 'package:maroro/modules/add_highlight_images.dart';
import 'package:maroro/modules/mybutton.dart';
import 'package:provider/provider.dart';

class AddHighlight extends StatefulWidget {
  const AddHighlight({super.key, required Map initialData});

  @override
  State<AddHighlight> createState() => _AddHighlightState();
}

class _AddHighlightState extends State<AddHighlight> {
  late TextEditingController packageNameController;
  late TextEditingController rateController;
  late TextEditingController descriptionController;

  @override
  void initState() {
    super.initState();
    final highlightData = Provider.of<ChangeManager>(context, listen: false).highlightData;
    
    // Initialize controllers with null checks
    packageNameController = TextEditingController(text: highlightData['packageName']);
    rateController = TextEditingController(text: highlightData['rate']);
    descriptionController = TextEditingController(text: highlightData['description']);
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
                const SizedBox(height: 10),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Upload Main Highlight Image'),
                  ],
                )
              ],
            )
          ),
          buildTextField(packageNameController, 'Package Name', 'Enter package name for this highlight', MaxLengthEnforcement.none),
          buildTextField(rateController, 'Rate', 'How much was this package e.g per hour', MaxLengthEnforcement.none),
          buildTextField(descriptionController, 'Description', 'What do you want your audience to know about this highlight?', MaxLengthEnforcement.enforced, maxLines: 10, maxLength: 100),
          AddHighLightVideo(),
          const SizedBox(height: 10),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Upload Highlight Video/Image'),
            ],
          ),
          const SizedBox(height: 150),
          Consumer<ChangeManager>(
            builder: (context, changeManager, child) {
              return MyButton(
                onTap: () async {
                  Map<String, dynamic> updatedData = {};

                  // Only include non-empty values
                  if (packageNameController.text.isNotEmpty) updatedData['packageName'] = packageNameController.text;
                  if (rateController.text.isNotEmpty) updatedData['rate'] = rateController.text;
                  if (descriptionController.text.isNotEmpty) updatedData['description'] = descriptionController.text;

                  // Include file paths if they've been set
                  if (changeManager.getHighlightImage() != null) {
                    updatedData['mainPicPath'] = changeManager.getHighlightImage()!.path;
                  }
                  if (changeManager.getHighlightVideo() != null) {
                    updatedData['videoPath'] = changeManager.getHighlightVideo()!.path;
                  }

                  changeManager.updateHighlight(updatedData);

                  Navigator.pop(context);
                },
                todo: 'Save Changes',
              );
            },
          ),
        ],
      ),
    );
  }

  Widget buildTextField(
    TextEditingController controller, 
    String label, 
    String hintText,
    MaxLengthEnforcement maxLengthEnforcement,
    {int maxLines = 1, int? maxLength}
  ) {
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