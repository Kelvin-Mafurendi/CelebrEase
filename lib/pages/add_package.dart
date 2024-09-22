import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:maroro/Provider/state_management.dart';
import 'package:maroro/modules/add_highlight_images.dart';
import 'package:maroro/modules/add_package_image.dart';
import 'package:maroro/modules/mybutton.dart';
import 'package:provider/provider.dart';

class AddPackage extends StatefulWidget {
  const AddPackage({super.key, required Map initialData});

  @override
  State<AddPackage> createState() => _AddPackageState();
}

class _AddPackageState extends State<AddPackage> {
  late TextEditingController packageNameController;
  late TextEditingController rateController;
  late TextEditingController descriptionController;

  @override
  void initState() {
    super.initState();
    final packageData =
        Provider.of<ChangeManager>(context, listen: false).packageData;

    // Initialize controllers with null checks
    packageNameController =
        TextEditingController(text: packageData['packageName']);
    rateController = TextEditingController(text: packageData['rate']);
    descriptionController =
        TextEditingController(text: packageData['description']);
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
                  AddPackageImage(),
                  const SizedBox(height: 10),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Upload Package Image'),
                    ],
                  )
                ],
              )),
          buildTextField(packageNameController, 'Package Name',
              'Enter package name', MaxLengthEnforcement.none),
          buildTextField(
              rateController,
              'Rate',
              'How much do you charge for this package e.g per hour',
              MaxLengthEnforcement.none),
          buildTextField(descriptionController, 'Description',
              'Describe your package or product', MaxLengthEnforcement.enforced,
              maxLines: 10, maxLength: 100),
          const Spacer(),
          Consumer<ChangeManager>(
            builder: (context, changeManager, child) {
              return MyButton(
                onTap: () async {
                  try {
                    Map<String, dynamic> updatedData = {};

                    if (packageNameController.text.isNotEmpty) {
                      updatedData['packageName'] = packageNameController.text;
                    }
                    if (rateController.text.isNotEmpty) {
                      updatedData['rate'] = rateController.text;
                    }
                    if (descriptionController.text.isNotEmpty) {
                      updatedData['description'] = descriptionController.text;
                    }

                    if (changeManager.getPackageImage() != null) {
                      updatedData['mainPicPath'] =
                          changeManager.getPackageImage()!.path;
                    }

                    changeManager.updatePackage(updatedData);
                    Navigator.pop(context);
                  } catch (e) {
                    // ignore: avoid_print
                    print('Error in AddPackage: $e');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error updating package: $e')),
                    );
                  }
                },
                todo: 'Save Changes',
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
