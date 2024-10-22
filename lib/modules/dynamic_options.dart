import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:maroro/main.dart';
import 'package:maroro/modules/form_field_maps.dart';

class DynamicOptions extends StatefulWidget {
  final String service;
  final Function(List<Map<String, dynamic>>) onOptionsChanged;
  
  const DynamicOptions({
    super.key, 
    required this.service,
    required this.onOptionsChanged,
  });

  @override
  _DynamicOptionsState createState() => _DynamicOptionsState();
}

class _DynamicOptionsState extends State<DynamicOptions> {
  List<Map<String, dynamic>> fields = [];
  String selectedService = '';
  final List<TextEditingController> _optionControllers = [];
  final List<TextEditingController> _priceControllers = [];

  @override
  void initState() {
    super.initState();
    selectedService = widget.service;
    _populateFields();
  }

  @override
  void didUpdateWidget(DynamicOptions oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.service != widget.service) {
      selectedService = widget.service;
      _populateFields();
    }
  }

  void _populateFields() {
    fields.clear();
    _optionControllers.clear();
    _priceControllers.clear();

    if (vendorServiceFields.containsKey(selectedService)) {
      var serviceFields = vendorServiceFields[selectedService];
      if (serviceFields != null) {
        for (var field in serviceFields) {
          if ((field['type'] == 'select' || field['type'] == 'multiselect')) {
            setState(() {
              fields.add({
                'name': field['label'],
                'fieldName': field['fieldName'],
                'label': field['hint'],
                'hint': field['hint'],
                'type': field['type'],
                'options': [], // Each option will be a map containing the option text and price info
              });
              _optionControllers.add(TextEditingController());
              _priceControllers.add(TextEditingController());
            });
          }
        }
            }
    }
  }

  void addOption(int fieldIndex) {
    final newOption = _optionControllers[fieldIndex].text.trim();
    if (newOption.isEmpty) return;

    setState(() {
      fields[fieldIndex]['options'].add({
        'text': newOption,
        'priceType': 'free', // Default to free
        'price': 0.0,
      });
      _optionControllers[fieldIndex].clear();
      _priceControllers[fieldIndex].clear();
    });
    widget.onOptionsChanged(fields);
  }

  void removeOption(int fieldIndex, int optionIndex) {
    setState(() {
      fields[fieldIndex]['options'].removeAt(optionIndex);
    });
    widget.onOptionsChanged(fields);
  }

  void updateOptionPrice(int fieldIndex, int optionIndex, String priceType, {double? price}) {
    setState(() {
      fields[fieldIndex]['options'][optionIndex]['priceType'] = priceType;
      fields[fieldIndex]['options'][optionIndex]['price'] = price ?? 0.0;
    });
    widget.onOptionsChanged(fields);
  }

  Widget _buildPriceOption(int fieldIndex, int optionIndex, Map<String, dynamic> option) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        DropdownButton<String>(
          value: option['priceType'],
          items: const [
            DropdownMenuItem(value: 'free', child: Text('Free')),
            DropdownMenuItem(value: 'paid', child: Text('Paid')),
          ],
          onChanged: (value) {
            updateOptionPrice(fieldIndex, optionIndex, value!);
          },
        ),
        if (option['priceType'] == 'paid')
          SizedBox(
            width: 100,
            child: TextField(
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
              decoration: const InputDecoration(
               // prefixText: ,
                contentPadding: EdgeInsets.symmetric(horizontal: 8),
              ),
              onChanged: (value) {
                updateOptionPrice(
                  fieldIndex,
                  optionIndex,
                  'paid',
                  price: double.tryParse(value) ?? 0.0,
                );
              },
              controller: TextEditingController(
                text: option['price']?.toString() ?? '0.00',
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: fields.length,
      itemBuilder: (context, fieldIndex) {
        final field = fields[fieldIndex];
        final options = List.from(field['options'] ?? []);

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  field['name'],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  field['label'],
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _optionControllers[fieldIndex],
                        decoration: InputDecoration(
                          hintText: 'Add new option for ${field['name']}',
                          border: const OutlineInputBorder(),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        onSubmitted: (_) => addOption(fieldIndex),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.add_circle),
                      color: accentColor,
                      onPressed: () => addOption(fieldIndex),
                    ),
                  ],
                ),
                if (options.isNotEmpty) ...[
                  const Divider(),
                  const SizedBox(height: 8),
                  const Text(
                    'Current Options:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: options.length,
                    itemBuilder: (context, optionIndex) {
                      final option = options[optionIndex];
                      return Card(
                        child: ListTile(
                          title: Text(option['text']),
                          subtitle: _buildPriceOption(fieldIndex, optionIndex, option),
                          trailing: GestureDetector(
                            child: const Icon(Icons.delete, color: primaryColor),
                            onTap: () => removeOption(fieldIndex, optionIndex),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    for (var controller in _optionControllers) {
      controller.dispose();
    }
    for (var controller in _priceControllers) {
      controller.dispose();
    }
    super.dispose();
  }
}