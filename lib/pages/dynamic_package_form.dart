import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:maroro/Provider/state_management.dart';
import 'package:maroro/modules/add_package_image.dart';

class DynamicPackageForm extends StatefulWidget {
  final Map<String, dynamic>? initialData;

  const DynamicPackageForm({
    Key? key,
    this.initialData,
  }) : super(key: key);

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
  Map<String, List<String>> serviceFieldsget = {};
  List<String> availableServices = [];

  // Default form fields that appear for all service types
  final List<String> defaultFields = [
    'packageName',
    'rate',
    'description',
  ];

  @override
  void initState() {
    super.initState();
    controllers = {};
    _initializeData();
  }

  Future<void> _initializeData() async {
    await Future.wait([
      _loadServices(),
      _loadUserCurrency(),
    ]);

    _initializeControllers();

    if (widget.initialData != null) {
      _loadInitialData();
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _loadServices() async {
    try {
      final servicesSnapshot =
          await FirebaseFirestore.instance.collection('Services').get();

      setState(() {
        // Use document IDs directly as they are the service names
        availableServices = servicesSnapshot.docs.map((doc) => doc.id).toList();

        // Since there are no fields in the documents,
        // we can remove the fields loading part
      });
    } catch (e) {
      print('Error loading services: $e');
    }
  }

  void _initializeControllers() {
    // Initialize controllers for default fields
    for (var field in defaultFields) {
      controllers[field] = TextEditingController();
    }

    // Initialize controllers for service-specific fields if service type is selected
    if (selectedServiceType != null &&
        serviceFieldsget.containsKey(selectedServiceType)) {
      for (var field in serviceFieldsget[selectedServiceType]!) {
        controllers[field] = TextEditingController();
      }
    }
  }

  Widget _buildServiceTypeSelector() {
    return DropdownButtonFormField<String>(
      value: selectedServiceType,
      decoration: const InputDecoration(
        labelText: 'Service Type',
        border: OutlineInputBorder(),
      ),
      items: availableServices.map((String type) {
        return DropdownMenuItem<String>(
          value: type,
          child: Text(type),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          selectedServiceType = newValue;
          selectedRateUnit = null;

          // Reinitialize controllers for the new service type
          _initializeControllers();
        });
      },
      validator: (value) =>
          value == null ? 'Please select a service type' : null,
    );
  }

  final Map<String, List<String>> serviceFields = {
    'Accomodation': [
      'roomType',
      'amenities',
      'capacity',
      'availability',
    ],
    'Bakery': [
      'itemTypes',
      'customOrders',
      'quantityOptions',
    ],
    'Clothing': [
      'clothingType',
      'sizes',
      'customDesign',
      'materials',
    ],
    'Flowers': [
      'flowerTypes',
      'bouquetStyles',
      'delivery',
    ],
    'Food & Catering': [
      'cuisineType',
      'menuItems',
      'dietaryOptions',
      'servingCapacity',
    ],
    'Jewelry': [
      'jewelryType',
      'materials',
      'customization',
    ],
    'Photography': [
      'shootType',
      'duration',
      'deliverables',
      'equipment',
    ],
    'Videography': [
      'duration',
      'editingOptions',
      'addOns',
    ],
    'Venues': [
      'venueType',
      'capacity',
      'amenities',
      'availability',
    ],
    'Transport': [
      'vehicleType',
      'range',
      'capacity',
      'addOns',
    ],
    'Music': [
      'musicType',
      'duration',
      'equipment',
    ],
    'Choreography': [
      'danceStyle',
      'rehearsalDuration',
      'numberOfDancers',
    ],
    'MC': [
      'eventTypes',
      'duration',
      'languages',
      'experience',
    ],
    'Beauty': [
      'makeupTypes',
      'products',
      'trialSessions',
    ],
    'Decor': [
      'decorStyle',
      'colorSchemes',
      'decorTypes',
      'setupTime',
    ],
    'Event Planning': [
      'eventTypes',
      'planningServices',
      'teamSize',
    ],
    'Event Security': [
      'eventTypes',
      'planningServices',
      'teamSize',
    ],
    'Gifts': [
      'giftTypes',
      'customization',
      'delivery',
    ],
    'Hair Dressing': [
      'hairServices',
      'duration',
      'products',
    ],
    'Other': [
      'serviceType',
      'customization',
      'availability',
    ],
  };

  // Updated rate units map with service-specific units
  final Map<String, List<String>> rateUnits = {
    'Accomodation': ['per night', 'per week', 'per month'],
    'Bakery': ['per item', 'per dozen', 'per order'],
    'Clothing': ['per item', 'per rental', 'per set'],
    'Flowers': ['per arrangement', 'per bouquet', 'per event'],
    'Food & Catering': ['per person', 'per event', 'per hour'],
    'Jewelry': ['per piece', 'per set', 'per custom order'],
    'Photography': ['per hour', 'per event', 'per package'],
    'Videography': ['per hour', 'per event', 'per package'],
    'Venues': ['per hour', 'per day', 'per event'],
    'Transport': ['per trip', 'per hour', 'per day'],
    'Music': ['per hour', 'per event', 'per performance'],
    'Choreography': ['per session', 'per event', 'per performance'],
    'MC': ['per hour', 'per event'],
    'Beauty': ['per person', 'per session', 'per event'],
    'Decor': ['per event', 'per item', 'per package'],
    'Event Planning': ['per event', 'per hour', 'per package'],
    'Event Security': ['per event', 'per hour', 'per package'],
    'Gifts': ['per item', 'per package', 'per order'],
    'Hair Dressing': ['per service', 'per hour', 'per person'],
    'Other': ['per service', 'per hour', 'per event'],
  };

  // Updated field labels map with comprehensive labels
  final Map<String, String> fieldLabels = {
    'packageName': 'Package Name',
    'rate': 'Rate',
    'description': 'Description',
    'roomType': 'Room Type',
    'amenities': 'Amenities',
    'capacity': 'Capacity',
    'itemTypes': 'Item Types',
    'customOrders': 'Custom Orders',
    'quantityOptions': 'Quantity Options',
    'clothingType': 'Type of Clothing',
    'sizes': 'Available Sizes',
    'customDesign': 'Custom Design Options',
    'materials': 'Materials Used',
    'flowerTypes': 'Types of Flowers',
    'bouquetStyles': 'Bouquet Styles',
    'delivery': 'Delivery Options',
    'cuisineType': 'Cuisine Type',
    'menuItems': 'Menu Items',
    'dietaryOptions': 'Dietary Options',
    'servingCapacity': 'Number of People Served',
    'jewelryType': 'Type of Jewelry',
    'customization': 'Customization Options',
    'shootType': 'Type of Photography',
    'duration': 'Duration',
    'deliverables': 'Deliverables',
    'equipment': 'Equipment Included',
    'editingOptions': 'Editing Options',
    'addOns': 'Additional Services',
    'venueType': 'Venue Type',
    'range': 'Service Range',
    'musicType': 'Type of Music',
    'danceStyle': 'Dance Style',
    'rehearsalDuration': 'Rehearsal Duration',
    'numberOfDancers': 'Number of Dancers',
    'eventTypes': 'Event Types',
    'languages': 'Languages',
    'experience': 'Years of Experience',
    'makeupTypes': 'Types of Makeup',
    'products': 'Products Used',
    'trialSessions': 'Trial Sessions',
    'decorStyle': 'Decoration Style',
    'colorSchemes': 'Color Schemes',
    'decorTypes': 'Types of Decorations',
    'setupTime': 'Setup Time',
    'planningServices': 'Planning Services',
    'teamSize': 'Team Size',
    'giftTypes': 'Types of Gifts',
    'hairServices': 'Hair Services',
    'serviceType': 'Type of Service',
  };

  // Updated field hints map with comprehensive hints
  final Map<String, String> fieldHints = {
    'packageName': 'Enter a unique name for your package',
    'rate': 'Enter the price',
    'description': 'Provide a detailed description of your package',
    'roomType': 'E.g., Single, Double, Suite',
    'amenities': 'List all available amenities, separated by commas',
    'capacity': 'Maximum number of people',
    'itemTypes': 'Types of items available, separated by commas',
    'customOrders': 'Describe custom order options',
    'quantityOptions': 'Specify minimum and maximum order quantities',
    'clothingType': 'E.g., Formal, Casual, Traditional',
    'sizes': 'Available sizes, separated by commas',
    'customDesign': 'Describe custom design options',
    'materials': 'List materials used, separated by commas',
    'flowerTypes': 'Types of flowers available',
    'bouquetStyles': 'Available arrangement styles',
    'delivery': 'Describe delivery options and areas',
    'cuisineType': 'Type of cuisine offered',
    'menuItems': 'List main menu items',
    'dietaryOptions': 'Available dietary accommodation options',
    'servingCapacity': 'Maximum number of people you can serve',
    'jewelryType': 'Types of jewelry pieces offered',
    'customization': 'Available customization options',
    'shootType': 'Types of photography services offered',
    'duration': 'Length of service or event',
    'deliverables': "What's included in the final delivery",
    'equipment': 'List of equipment provided',
    'editingOptions': 'Available editing and post-production services',
    'addOns': 'Additional services available',
    'venueType': 'Type of venue and setting',
    'range': 'Service area or distance covered',
    'musicType': 'Styles of music offered',
    'danceStyle': 'Types of dance styles taught',
    'rehearsalDuration': 'Length of rehearsal sessions',
    'numberOfDancers': 'Number of dancers included',
    'eventTypes': 'Types of events covered',
    'languages': 'Languages spoken, separated by commas',
    'experience': 'Years of experience in the field',
    'makeupTypes': 'Types of makeup services offered',
    'products': 'Products and brands used',
    'trialSessions': 'Trial session availability and details',
    'decorStyle': 'Decoration styles available',
    'colorSchemes': 'Available color schemes',
    'decorTypes': 'Types of decorations offered',
    'setupTime': 'Time required for setup',
    'planningServices': 'Planning services included',
    'teamSize': 'Number of team members',
    'giftTypes': 'Types of gifts available',
    'hairServices': 'Hair services offered',
    'serviceType': 'Specify the type of service offered',
  };

  void _loadInitialData() {
    widget.initialData?.forEach((key, value) {
      if (controllers.containsKey(key)) {
        controllers[key]?.text = value.toString();
      }
    });
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
        return DropdownMenuItem<String>(
          value: currency,
          child: Text(currency),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          selectedCurrency = newValue!;
        });
      },
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

  String getFieldLabel(String fieldName) {
    return fieldLabels[fieldName] ??
        fieldName
            .replaceAllMapped(
                RegExp(r'([A-Z])'), (match) => ' ${match.group(1)}')
            .capitalize();
  }

  Widget _buildFormField(String fieldName) {
    final label = getFieldLabel(fieldName);

    if (fieldName == 'rate') {
      return Row(
        children: [
          Expanded(
            flex: 1,
            child: _buildCurrencyDropdown(),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: TextFormField(
              controller: controllers[fieldName],
              decoration: InputDecoration(
                labelText: label,
                hintText: 'Enter amount',
                border: const OutlineInputBorder(),
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
      );
    }

    if (fieldName == 'availability') {
      return _buildAvailabilityCalendar();
    }

    return TextFormField(
      controller: controllers[fieldName],
      decoration: InputDecoration(
        labelText: label,
        hintText: fieldHints[fieldName],
        hintFadeDuration: Duration(seconds: 3),
        border: const OutlineInputBorder(),
      ),
      maxLines: 3,
      minLines: 1,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        }
        return null;
      },
    );
  }

// Update _buildRateSection to include hints
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
                decoration: InputDecoration(
                  labelText: 'Rate',
                  hintText:
                      fieldHints['rate'] ?? 'Enter amount', // Add hint text
                  border: const OutlineInputBorder(),
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
            return DropdownMenuItem<String>(
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
  } // Update _buildServiceSpecificFields to use _buildFormField

  Widget _buildServiceSpecificFields() {
    if (selectedServiceType == null) return Container();

    final fields = serviceFields[selectedServiceType] ?? [];
    return Column(
      children: fields.map((field) {
        if (field == 'availability') {
          return _buildAvailabilityCalendar();
        }

        if (field.contains('items') || field.contains('options')) {
          return _buildDataTable(field);
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildFormField(field), // Use _buildFormField here
        );
      }).toList(),
    );
  }

  Widget _buildDataTable(String field) {
    final items = <Map<String, dynamic>>[];

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

  Future<void> _showAddItemDialog(String field) async {
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

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        final data = <String, dynamic>{};

        // Add all form field values
        controllers.forEach((key, controller) {
          data[key] = controller.text;
        });

        // Format rate with currency and unit
        data['rate'] =
            '$selectedCurrency ${controllers['rate']!.text} $selectedRateUnit';

        // Add service type
        data['serviceType'] = selectedServiceType;

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

  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
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
              child: _buildFormField(field), // Use _buildFormField here
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
    );
  }

  String _formatFieldLabel(String field) {
    return field
        .replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(1)}')
        .capitalize();
  }

  @override
  void dispose() {
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
/////////////////////////////////////////////////////////////////////////////////////////////////////
