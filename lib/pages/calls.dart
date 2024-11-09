// Call notification widget
class CallNotification extends StatelessWidget {
  final String callerName;
  final String callId;
  final CallType callType;
  final Function(bool) onResponse;

  const CallNotification({
    Key? key,
    required this.callerName,
    required this.callId,
    required this.callType,
    required this.onResponse,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Incoming ${callType == CallType.video ? 'Video' : 'Audio'} Call',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 8),
            Text('$callerName is calling...'),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: Icon(Icons.call_end),
                  label: Text('Decline'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  onPressed: () => onResponse(false),
                ),
                ElevatedButton.icon(
                  icon: Icon(Icons.call),
                  label: Text('Accept'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  onPressed: () => onResponse(true),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
