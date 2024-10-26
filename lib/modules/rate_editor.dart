import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maroro/main.dart';

class RateEditor extends StatefulWidget {
  final String initialRate;
  final Function(String) onRateChanged;
  final bool isEditing;
  final VoidCallback onEditToggle;

  const RateEditor({
    Key? key,
    required this.initialRate,
    required this.onRateChanged,
    required this.isEditing,
    required this.onEditToggle,
  }) : super(key: key);

  @override
  State<RateEditor> createState() => _RateEditorState();
}

class _RateEditorState extends State<RateEditor> {
  late TextEditingController _rateController;

  @override
  void initState() {
    super.initState();
    _rateController = TextEditingController(text: widget.initialRate);
  }

  @override
  void dispose() {
    _rateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 200,
            maxHeight: widget.isEditing ? 60 : 200,
          ),
          child: widget.isEditing
              ? TextFormField(
                  controller: _rateController,
                  keyboardType: TextInputType.number,
                  style: GoogleFonts.lateef(
                    color: Colors.grey[500],
                    fontSize: MediaQuery.of(context).size.width * 0.05,
                  ),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    isDense: true,
                  ),
                  onChanged: widget.onRateChanged,
                )
              : Text(
                  widget.initialRate,
                  textScaler: const TextScaler.linear(4),
                  style: GoogleFonts.lateef(color: Colors.grey[500]),
                ),
        ),
        InkWell(
          onTap: widget.onEditToggle,
          child: Column(
            children: [
              Icon(
                widget.isEditing
                    ? FluentSystemIcons.ic_fluent_checkmark_regular
                    : FluentSystemIcons.ic_fluent_edit_regular,
                color: primaryColor,
                size: MediaQuery.of(context).size.width * 0.07,
              ),
              const SizedBox(height: 10),
              Text(
                widget.isEditing ? 'Done' : 'Edit',
                style: GoogleFonts.lateef(
                  color: primaryColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}