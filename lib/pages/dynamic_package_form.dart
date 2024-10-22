import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:maroro/modules/dynamic_options.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

import 'package:maroro/Provider/state_management.dart';
import 'package:maroro/modules/add_package_image.dart';
import 'package:maroro/modules/form_field_maps.dart';

class DynamicPackageForm extends StatefulWidget {
  final Map? initialData;

  const DynamicPackageForm({super.key, this.initialData});

  @override
  State<DynamicPackageForm> createState() => _DynamicPackageFormState();
}

class _DynamicPackageFormState extends State<DynamicPackageForm> {
  final _formKey = GlobalKey<FormState>();
  late Map<String, TextEditingController> controllers;
  String selectedCurrency = 'USD';
  String? selectedServiceType;
  String? selectedRateUnit;
  List<DateTime> selectedDates = [];
  bool isLoading = true;
  List<String> availableServices = [];
  List<Map<String, dynamic>> _dynamicOptions = [];

  final List<String> defaultFields = [
    'packageName',
    'rate',
    'description',
  ];

  @override
  void initState() {
    super.initState();
    controllers = {};
    _initializeControllers();
    _initializeData();
  }

  void _initializeControllers() {
    // Initialize controllers for default fields
    for (var field in defaultFields) {
      controllers[field] = TextEditingController();
    }
  }

  Future<void> _initializeData() async {
    try {
      await _loadServices();
      if (widget.initialData != null) {
        _loadInitialData();
      }
    } catch (e) {
      print('Error initializing data: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadServices() async {
    try {
      final servicesSnapshot =
          await FirebaseFirestore.instance.collection('Services').get();
      setState(() {
        availableServices = servicesSnapshot.docs.map((doc) => doc.id).toList();
      });
    } catch (e) {
      print('Error loading services: $e');
      rethrow;
    }
  }

  void _loadInitialData() {
    widget.initialData?.forEach((key, value) {
      if (controllers.containsKey(key)) {
        controllers[key]?.text = value.toString();
      }
    });
  }

  void _handleDynamicOptionsChanged(List<Map<String, dynamic>> options) {
    setState(() {
      _dynamicOptions = options;
    });
  }

  Widget _buildServiceTypeSelector() {
    return DropdownButtonFormField<String>(
      value: selectedServiceType,
      decoration: const InputDecoration(
        labelText: 'Service Type',
        border: OutlineInputBorder(),
      ),
      items: availableServices.map((String type) {
        return DropdownMenuItem(
          value: type,
          child: Text(type),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          selectedServiceType = newValue;
          selectedRateUnit = null;
          _dynamicOptions = [];

          // Keep default field controllers but reinitialize service-specific ones
          final tempControllers =
              Map<String, TextEditingController>.from(controllers);
          controllers.forEach((key, controller) {
            if (!defaultFields.contains(key)) {
              controller.dispose();
            }
          });
          controllers.clear();

          // Restore default field controllers
          for (var field in defaultFields) {
            controllers[field] =
                tempControllers[field] ?? TextEditingController();
          }

          // Initialize new service-specific field controllers
          if (newValue != null && vendorServiceFields.containsKey(newValue)) {
            for (var field in vendorServiceFields[newValue]!) {
              if (!defaultFields.contains(field['fieldName'])) {
                controllers[field['fieldName']] = TextEditingController();
              }
            }
          }
        });
      },
      validator: (value) =>
          value == null ? 'Please select a service type' : null,
    );
  }

  Widget _buildCurrencyDropdown() {
    final currencies = [
      'USD',
      'EUR',
      'GBP',
      'AOA',
      'NGN',
      'ZAR',
      'KES',
      'UGX',
      'TZS',
      'RWF',
      'BIF',
      'ETB',
      'GHS',
      'XOF',
      'XAF',
      'MAD',
      'EGP',
      'ZWL'
    ];

    return DropdownButtonFormField<String>(
      value: selectedCurrency,
      decoration: const InputDecoration(
        labelText: 'Currency',
        border: OutlineInputBorder(),
      ),
      items: currencies.map((String currency) {
        return DropdownMenuItem(
          value: currency,
          child: Text(currency),
        );
      }).toList(),
      onChanged: (String? newValue) {
        if (newValue != null) {
          setState(() {
            selectedCurrency = newValue;
          });
        }
      },
    );
  }

  Widget _buildRateSection() {
    final availableUnits = selectedServiceType != null
        ? rateUnits[selectedServiceType] ?? ['flat rate']
        : ['flat rate'];

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              flex: 1,
              child: _buildCurrencyDropdown(),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: TextFormField(
                controller: controllers['rate'],
                decoration: const InputDecoration(
                  labelText: 'Rate',
                  hintText: 'Enter amount',
                  border: OutlineInputBorder(),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a rate';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: selectedRateUnit,
          decoration: const InputDecoration(
            labelText: 'Rate Unit',
            border: OutlineInputBorder(),
          ),
          items: availableUnits.map((String unit) {
            return DropdownMenuItem(
              value: unit,
              child: Text(unit),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              selectedRateUnit = newValue;
            });
          },
          validator: (value) =>
              value == null ? 'Please select a rate unit' : null,
        ),
      ],
    );
  }

  Widget _buildAvailabilityCalendar() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(
              'Select Available Dates',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            TableCalendar(
              firstDay: DateTime.now(),
              lastDay: DateTime.now().add(const Duration(days: 365)),
              focusedDay: DateTime.now(),
              selectedDayPredicate: (day) {
                return selectedDates.any((date) =>
                    date.year == day.year &&
                    date.month == day.month &&
                    date.day == day.day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  if (selectedDates.any((date) =>
                      date.year == selectedDay.year &&
                      date.month == selectedDay.month &&
                      date.day == selectedDay.day)) {
                    selectedDates.removeWhere((date) =>
                        date.year == selectedDay.year &&
                        date.month == selectedDay.month &&
                        date.day == selectedDay.day);
                  } else {
                    selectedDates.add(selectedDay);
                  }
                });
              },
              calendarStyle: const CalendarStyle(
                selectedDecoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormField(String fieldName, {Map<String, dynamic>? fieldData}) {
    if (!controllers.containsKey(fieldName)) {
      controllers[fieldName] = TextEditingController();
    }

    switch (fieldName) {
      case 'packageName':
        return TextFormField(
          controller: controllers[fieldName],
          decoration: const InputDecoration(
            labelText: 'Package Name',
            hintText: 'Enter package name',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a package name';
            }
            return null;
          },
        );

      case 'description':
        return TextFormField(
          controller: controllers[fieldName],
          decoration: const InputDecoration(
            labelText: 'Description',
            hintText: 'Enter package description',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a description';
            }
            return null;
          },
        );

      default:
        final label = fieldData?['label'] ?? _formatFieldLabel(fieldName);
        return TextFormField(
          controller: controllers[fieldName],
          decoration: InputDecoration(
            labelText: label,
            hintText: 'Enter $label',
            border: const OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter $label';
            }
            return null;
          },
        );
    }
  }
  // Update _buildRateSection to include hints

  // Update _buildServiceSpecificFields to use vendorServiceFields
  Widget _buildServiceSpecificFields() {
    if (selectedServiceType == null) return Container();

    final fields = vendorServiceFields[selectedServiceType] ?? [];
    List<Widget> fieldWidgets = [];

    // 1. First, add the DynamicOptions widget if there are any select/multiselect fields
    bool hasSelectFields = fields.any(
        (field) => field['type'] == 'select' || field['type'] == 'multiselect');

    if (hasSelectFields) {
      fieldWidgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Package Options',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: MediaQuery.of(context).size.width * 0.85,
                child: DynamicOptions(
                  service: selectedServiceType!,
                  onOptionsChanged: _handleDynamicOptionsChanged,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 2. Process all other fields
    for (var field in fields) {
      final fieldName = field['fieldName'];
      final fieldType = field['type'];
      final fieldLabel = field['label'] ?? _formatFieldLabel(fieldName);

      // Skip select/multiselect fields as they're handled by DynamicOptions
      if (fieldType == 'select' || fieldType == 'multiselect') {
        continue;
      }

      // Handle different field types
      Widget fieldWidget;
      switch (fieldType) {
        case 'availability':
          fieldWidget = _buildAvailabilityCalendar();
          break;

        case 'number':
          fieldWidget = TextFormField(
            controller: controllers[fieldName],
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: fieldLabel,
              hintText: field['hint'] ?? 'Enter a number',
              border: const OutlineInputBorder(),
            ),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter $fieldLabel';
              }
              if (double.tryParse(value) == null) {
                return 'Please enter a valid number';
              }
              return null;
            },
          );
          break;

        case 'date':
          fieldWidget = TextFormField(
            controller: controllers[fieldName],
            decoration: InputDecoration(
              labelText: fieldLabel,
              hintText: field['hint'] ?? 'Select a date',
              border: const OutlineInputBorder(),
              suffixIcon: const Icon(Icons.calendar_today),
            ),
            readOnly: true,
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (date != null) {
                controllers[fieldName]?.text =
                    DateFormat('yyyy-MM-dd').format(date);
              }
            },
            validator: (value) =>
                value?.isEmpty ?? true ? 'Please select a date' : null,
          );
          break;

        case 'time':
          fieldWidget = TextFormField(
            controller: controllers[fieldName],
            decoration: InputDecoration(
              labelText: fieldLabel,
              hintText: field['hint'] ?? 'Select a time',
              border: const OutlineInputBorder(),
              suffixIcon: const Icon(Icons.access_time),
            ),
            readOnly: true,
            onTap: () async {
              final time = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
              );
              if (time != null) {
                controllers[fieldName]?.text = time.format(context);
              }
            },
            validator: (value) =>
                value?.isEmpty ?? true ? 'Please select a time' : null,
          );
          break;

        case 'textarea':
          fieldWidget = TextFormField(
            controller: controllers[fieldName],
            decoration: InputDecoration(
              labelText: fieldLabel,
              hintText: field['hint'] ?? 'Enter details',
              border: const OutlineInputBorder(),
            ),
            maxLines: 5,
            validator: (value) =>
                value?.isEmpty ?? true ? 'Please enter $fieldLabel' : null,
          );
          break;

        case 'checkbox':
          final checkboxController =
              controllers[fieldName] ?? TextEditingController(text: 'false');
          fieldWidget = CheckboxListTile(
            title: Text(fieldLabel),
            value: checkboxController.text == 'true',
            onChanged: (bool? value) {
              setState(() {
                checkboxController.text = value?.toString() ?? 'false';
              });
            },
            controlAffinity: ListTileControlAffinity.leading,
          );
          break;

        case 'switch':
          final switchController =
              controllers[fieldName] ?? TextEditingController(text: 'false');
          fieldWidget = SwitchListTile(
            title: Text(fieldLabel),
            value: switchController.text == 'true',
            onChanged: (bool value) {
              setState(() {
                switchController.text = value.toString();
              });
            },
          );
          break;

        case 'table':
          fieldWidget = _buildDataTable(fieldName);
          break;

        // Default to regular text field for unknown types
        default:
          fieldWidget = TextFormField(
            controller: controllers[fieldName],
            decoration: InputDecoration(
              labelText: fieldLabel,
              hintText: field['hint'] ?? 'Enter ${fieldLabel.toLowerCase()}',
              border: const OutlineInputBorder(),
            ),
            validator: (value) =>
                value?.isEmpty ?? true ? 'Please enter $fieldLabel' : null,
          );
      }

      // Add the field widget with consistent padding
      fieldWidgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: fieldWidget,
        ),
      );
    }

    // 3. Return all widgets in a column
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: fieldWidgets,
    );
  }

  Widget _buildDataTable(String field) {
    final items = <Map<String, dynamic>>[];
    // Implement logic to populate items based on 'field'

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _formatFieldLabel(field),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: DataTable2(
                columns: const [
                  DataColumn2(label: Text('Name'), size: ColumnSize.L),
                  DataColumn2(label: Text('Description'), size: ColumnSize.L),
                  DataColumn2(label: Text('Actions'), size: ColumnSize.S),
                ],
                rows: items
                    .map((item) => DataRow2(
                          cells: [
                            DataCell(Text(item['name'] ?? '')),
                            DataCell(Text(item['description'] ?? '')),
                            DataCell(IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                // Handle delete
                              },
                            )),
                          ],
                        ))
                    .toList(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Add Item'),
              onPressed: () {
                // Show dialog to add new item
                _showAddItemDialog(field);
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatFieldLabel(String field) {
    return field
        .replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(1)}')
        .capitalize()
        .trim();
  }

  Future _showAddItemDialog(String field) async {
    final nameController = TextEditingController();
    final descController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add ${_formatFieldLabel(field)}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Add item logic here
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  // Update the _submitForm method to include dynamic options:
  Future _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        Map<String, dynamic> data = {};

        // Add all form field values
        controllers.forEach((key, controller) {
          data[key] = controller.text;
        });

        // Format rate with currency and unit
        data['rate'] =
            '$selectedCurrency ${controllers['rate']!.text} $selectedRateUnit';

        // Add service type
        data['serviceType'] = selectedServiceType;

        // Add dynamic options
        if (_dynamicOptions.isNotEmpty) {
          data['dynamicOptions'] = _dynamicOptions.map((field) {
            return {
              'fieldName': field['fieldName'],
              'name': field['name'],
              'type': field['type'],
              'options': field['options'],
            };
          }).toList();
        }

        // Add image path if exists
        final packageImage = context.read<ChangeManager>().getPackageImage();
        if (packageImage != null) {
          data['mainPicPath'] = packageImage.path;
        }

        // Add selected dates if applicable
        if (selectedDates.isNotEmpty) {
          data['availableDates'] = selectedDates
              .map((date) => DateFormat('yyyy-MM-dd').format(date))
              .toList();
        }

        // Update package using state management
        context.read<ChangeManager>().updatePackage(data);

        if (mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving package: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildServiceTypeSelector(),
                const SizedBox(height: 16),
                AddPackageImage(),
                const SizedBox(height: 16),
                ...defaultFields.map((field) {
                  if (field == 'rate') {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _buildRateSection(),
                    );
                  }
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildFormField(field),
                  );
                }),
                _buildServiceSpecificFields(),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Save Package'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Dispose all controllers
    controllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
