import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:maroro/modules/add_package_image.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:maroro/Provider/state_management.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'dart:io';

class DynamicPackageForm extends StatefulWidget {
  final String serviceType;
  final Map<String, dynamic>? initialData;
  
  const DynamicPackageForm({
    Key? key,
    required this.serviceType,
    this.initialData,
  }) : super(key: key);

  @override
  State<DynamicPackageForm> createState() => _DynamicPackageFormState();
}

class _DynamicPackageFormState extends State<DynamicPackageForm> {
  final _formKey = GlobalKey<FormState>();
  late Map<String, TextEditingController> controllers;
  String selectedCurrency = 'USD';
  List<DateTime> selectedDates = [];
  
  // Field labels map
  final Map<String, String> fieldLabels = {
    'packageName': 'Package Name',
    'rate': 'Rate',
    'description': 'Description',
    'roomType': 'Room Type',
    'amenities': 'Amenities',
    'capacity': 'Capacity',
    'itemTypes': 'Item Types',
    'customOrders': 'Custom Orders',
    'makeupTypes': 'Makeup Types',
    'danceStyle': 'Dance Style',
    'availability': 'Available Dates',
    'duration': 'Duration',
    'equipment': 'Equipment',
    'rehearsalDuration': 'Rehearsal Duration',
    'numberOfDancers': 'Number of Dancers',
    'clothingType': 'Clothing Type',
    'sizes': 'Available Sizes',
    'customDesign': 'Custom Design Options',
    'materials': 'Materials Used',
    'decorStyle': 'Decoration Style',
    'colorSchemes': 'Color Schemes',
    'decorTypes': 'Decoration Types',
    'setupTime': 'Setup Time',
    'eventTypes': 'Event Types',
    'planningServices': 'Planning Services',
    'teamSize': 'Team Size',
    'flowerTypes': 'Flower Types',
    'bouquetStyles': 'Bouquet Styles',
    'delivery': 'Delivery Options',
    'cuisineType': 'Cuisine Type',
    'menuItems': 'Menu Items',
    'dietaryOptions': 'Dietary Options',
    'servingCapacity': 'Serving Capacity',
    'giftTypes': 'Gift Types',
    'customization': 'Customization Options',
    'hairServices': 'Hair Services',
    'products': 'Products Used',
    'jewelryType': 'Jewelry Type',
    'languages': 'Languages',
    'experience': 'Years of Experience',
    'musicType': 'Music Type',
    'shootType': 'Shoot Type',
    'deliverables': 'Deliverables',
    'vehicleType': 'Vehicle Type',
    'range': 'Service Range',
    'venueType': 'Venue Type',
  };
  
  // Field hints map
  final Map<String, String> fieldHints = {
    'packageName': 'Enter a unique name for your package',
    'rate': 'Enter the price',
    'description': 'Provide a detailed description of your package',
    'roomType': 'E.g., Single, Double, Suite',
    'amenities': 'List all available amenities',
    'capacity': 'Maximum number of people',
    'itemTypes': 'Types of items available',
    'customOrders': 'Custom order options',
    'makeupTypes': 'Types of makeup services',
    'danceStyle': 'Available dance styles',
    // Add hints for other fields...
  };

  // Service-specific form fields
  final Map<String, List<String>> serviceFields = {
    'Accommodation': [
      'roomType',
      'amenities',
      'capacity',
      'availability',
    ],
    'Bakery': [
      'itemTypes',
      'customOrders',
      'capacity',
    ],
    'Beauty': [
      'makeupTypes',
      'products',
      'duration',
      'availability',
    ],
    'Choreography': [
      'danceStyle',
      'rehearsalDuration',
      'numberOfDancers',
      'availability',
    ],
    // Add other service types...
  };
  
  // Default form fields
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
    _loadUserCurrency();
    if (widget.initialData != null) {
      _loadInitialData();
    }
  }

  void _loadInitialData() {
    widget.initialData?.forEach((key, value) {
      if (controllers.containsKey(key)) {
        controllers[key]?.text = value.toString();
      }
    });
  }

  Future<void> _loadUserCurrency() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        final doc = await FirebaseFirestore.instance
            .collection('Vendors')
            .doc(userId)
            .get();
        
        if (doc.exists) {
          String location = doc.data()?['location'] ?? '';
          final currency = _getCurrencyForCountry(_extractCountryCode(location));
          setState(() => selectedCurrency = currency);
        }
      }
    } catch (e) {
      print('Error loading user currency: $e');
    }
  }

  String _extractCountryCode(String location) {
    final pattern = RegExp(r'🇦🇴');
    if (pattern.hasMatch(location)) return 'AO';
    return 'US';
  }

  String _getCurrencyForCountry(String countryCode) {
    final currencyMap = {
      'AO': 'AOA',
      'US': 'USD',
      'GB': 'GBP',
      'EU': 'EUR',
    };
    return currencyMap[countryCode] ?? 'USD';
  }

  void _initializeControllers() {
    // Initialize controllers for default fields
    for (var field in defaultFields) {
      controllers[field] = TextEditingController();
    }
    
    // Initialize controllers for service-specific fields
    final fields = serviceFields[widget.serviceType] ?? [];
    for (var field in fields) {
      controllers[field] = TextEditingController();
    }
  }

  Widget _buildCurrencyDropdown() {
    final currencies = [
      'USD', 'EUR', 'GBP', 'AOA', 'NGN', 'ZAR', 'KES', 'UGX', 'TZS',
      'RWF', 'BIF', 'ETB', 'GHS', 'XOF', 'XAF', 'MAD', 'EGP'
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
                  date.day == day.day
                );
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  if (selectedDates.any((date) => 
                    date.year == selectedDay.year && 
                    date.month == selectedDay.month && 
                    date.day == selectedDay.day
                  )) {
                    selectedDates.removeWhere((date) => 
                      date.year == selectedDay.year && 
                      date.month == selectedDay.month && 
                      date.day == selectedDay.day
                    );
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
           fieldName.replaceAllMapped(
             RegExp(r'([A-Z])'),
             (match) => ' ${match.group(1)}'
           ).capitalize();
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
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
        border: const OutlineInputBorder(),
      ),
      maxLines: fieldName == 'description' ? 3 : 1,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        }
        return null;
      },
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
        
        // Format rate with currency prefix
        data['rate'] = '$selectedCurrency ${controllers['rate']!.text}';
        
        // Add image path if exists
        final packageImage = context.read<ChangeManager>().getPackageImage();
        if (packageImage != null) {
          data['mainPicPath'] = packageImage.path;
        }
        
        // Add selected dates if applicable
        if (selectedDates.isNotEmpty) {
          data['availableDates'] = selectedDates.map((date) => 
            DateFormat('yyyy-MM-dd').format(date)
          ).toList();
        }
        
        // Add service type
        data['serviceType'] = widget.serviceType;
        
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
    final allFields = [...defaultFields];
    if (serviceFields.containsKey(widget.serviceType)) {
      allFields.addAll(serviceFields[widget.serviceType]!);
    }

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AddPackageImage(),
          const SizedBox(height: 16),
          ...allFields.map((field) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildFormField(field),
          )).toList(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: ElevatedButton(
              onPressed: _submitForm,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Save Package'),
            ),
          ),
        ],
      ),
    );
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