import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jitsi_meet_wrapper/jitsi_meet_wrapper.dart';
import 'package:maroro/pages/chart_screen.dart';

class PlanningGroup {
  final String id;
  final String eventName;
  final String customerId;
  final List<String> vendorIds;
  final DateTime createdAt;
  final List<String> milestones;

  PlanningGroup({
    required this.id,
    required this.eventName,
    required this.customerId,
    required this.vendorIds,
    required this.createdAt,
    this.milestones = const [],
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'eventName': eventName,
        'customerId': customerId,
        'vendorIds': vendorIds,
        'createdAt': createdAt,
        'milestones': milestones,
      };
}
// proposal_dialog.dart
class ProposalDialog extends StatefulWidget {
  const ProposalDialog({super.key});

  @override
  _ProposalDialogState createState() => _ProposalDialogState();
}

class _ProposalDialogState extends State<ProposalDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
 

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Create Proposal'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title'),
              validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
            ),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
              maxLines: 3,
              validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
            ),
            TextFormField(
              controller: _priceController,
              decoration: InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.number,
              validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState?.validate() ?? false) {
              Navigator.pop(context, {
                'title': _titleController.text,
                'description': _descriptionController.text,
                'price': double.parse(_priceController.text),
                'timestamp': DateTime.now(),
                'status':'pending',
                
              });
            }
          },
          child: Text('Send'),
        ),
      ],
    );
  }
}

// timeline_tile.dart
class TimelineTile extends StatelessWidget {
  final Map<String, dynamic> milestone;
  final bool isFirst;
  final bool isLast;

  const TimelineTile({
    super.key,
    required this.milestone,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        children: [
          _buildTimeline(context),
          Expanded(
            child: Card(
              margin: EdgeInsets.all(8),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      milestone['title'],
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    SizedBox(height: 8),
                    Text(milestone['description']),
                    SizedBox(height: 4),
                    Text(
                      'Due: ${milestone['dueDate']}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline(BuildContext context) {
    return SizedBox(
      width: 40,
      child: Column(
        children: [
          Container(
            width: 1,
            height: isFirst ? 0 : 20,
            color: Theme.of(context).dividerColor,
          ),
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: milestone['completed'] ? Colors.green : Colors.grey,
            ),
          ),
          Container(
            width: 1,
            height: isLast ? 0 : 20,
            color: Theme.of(context).dividerColor,
          ),
        ],
      ),
    );
  }
}

// Add ChecklistDialog widget
class ChecklistDialog extends StatefulWidget {
  const ChecklistDialog({super.key});

  @override
  _ChecklistDialogState createState() => _ChecklistDialogState();
}

class _ChecklistDialogState extends State<ChecklistDialog> {
  final List<TextEditingController> _controllers = [TextEditingController()];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Create Checklist'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ..._controllers
                .map((controller) => Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: controller,
                            decoration: InputDecoration(hintText: 'Enter item'),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.remove),
                          onPressed: () => _removeItem(controller),
                        ),
                      ],
                    ))
                ,
            TextButton(
              onPressed: _addItem,
              child: Text('Add Item'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final items = _controllers
                .map((c) => c.text)
                .where((text) => text.isNotEmpty)
                .toList();
            Navigator.pop(context, items);
          },
          child: Text('Create'),
        ),
      ],
    );
  }

  void _addItem() {
    setState(() {
      _controllers.add(TextEditingController());
    });
  }

  void _removeItem(TextEditingController controller) {
    if (_controllers.length > 1) {
      setState(() {
        _controllers.remove(controller);
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }
}
class MilestoneDialog extends StatefulWidget {
  const MilestoneDialog({super.key});

  @override
  _MilestoneDialogState createState() => _MilestoneDialogState();
}

class _MilestoneDialogState extends State<MilestoneDialog> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _selectedDate;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Create Milestone'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _titleController,
            decoration: InputDecoration(labelText: 'Title'),
          ),
          TextField(
            controller: _descriptionController,
            decoration: InputDecoration(labelText: 'Description'),
            maxLines: 3,
          ),
          ListTile(
            title: Text(_selectedDate == null
                ? 'Pick Due Date'
                : 'Due: ${_selectedDate!.toLocal()}'.split(' ')[0]),
            trailing: Icon(Icons.calendar_today),
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(Duration(days: 365)),
              );
              if (date != null) {
                setState(() => _selectedDate = date);
              }
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (_titleController.text.isNotEmpty && _selectedDate != null) {
              Navigator.pop(context, {
                'title': _titleController.text,
                'description': _descriptionController.text,
                'dueDate': _selectedDate!.toIso8601String(),
                'completed': false,
                'createdAt': DateTime.now().toIso8601String(),
              });
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Please fill in all required fields')),
              );
            }
          },
          child: Text('Create'),
        ),
      ],
    );
  }
}

// Add new CallScreen widget
class CallScreen extends StatefulWidget {
  final String userId;
  final String userName;
  final CallType callType;

  const CallScreen({
    super.key,
    required this.userId,
    required this.userName,
    required this.callType,
  });

  @override
  _CallScreenState createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  bool _isMuted = false;
  bool _isVideoOff = false;

  @override
  void initState() {
    super.initState();
    _startCall();
  }

  Future<void> _startCall() async {
    final roomName = 'call_${widget.userId}_${DateTime.now().millisecondsSinceEpoch}';
    
    var options = JitsiMeetingOptions(
      roomNameOrUrl: roomName,
      userDisplayName: widget.userName,
      userEmail: FirebaseAuth.instance.currentUser?.email,
      isAudioMuted: _isMuted,
      isVideoMuted: _isVideoOff || widget.callType == CallType.audio,
    );

    try {
      await JitsiMeetWrapper.joinMeeting(options: options);
      Navigator.pop(context); // Close call screen when call ends
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to start call: $e')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Calling ${widget.userName}...',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
            SizedBox(height: 32),
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: Icon(
                    _isMuted ? Icons.mic_off : Icons.mic,
                    color: Colors.white,
                    size: 32,
                  ),
                  onPressed: () => setState(() => _isMuted = !_isMuted),
                ),
                IconButton(
                  icon: Icon(
                    Icons.call_end,
                    color: Colors.red,
                    size: 32,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                if (widget.callType == CallType.video)
                  IconButton(
                    icon: Icon(
                      _isVideoOff ? Icons.videocam_off : Icons.videocam,
                      color: Colors.white,
                      size: 32,
                    ),
                    onPressed: () => setState(() => _isVideoOff = !_isVideoOff),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}