import 'package:flutter/material.dart';

class RemindDialog extends StatefulWidget {
  final String initial;
  const RemindDialog({super.key, this.initial = 'Once a day'});

  @override
  State<RemindDialog> createState() => _RemindDialogState();
}

class _RemindDialogState extends State<RemindDialog> {
  late String selected;

  @override
  void initState() {
    super.initState();
    selected = widget.initial;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: StatefulBuilder(builder: (context, setState) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top-left X button
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Spacer(),
                ],
              ),
              const SizedBox(height: 4),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Text('Remind me in:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: DropdownButtonFormField<String>(
                  value: selected,
                  onChanged: (v) => setState(() => selected = v ?? selected),
                  items: const [
                    DropdownMenuItem(value: 'Once a day', child: Text('Once a day')),
                    DropdownMenuItem(value: 'Once a week', child: Text('Once a week')),
                    DropdownMenuItem(value: 'Once a month', child: Text('Once a month')),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(selected),
                    child: const Text('Confirm'),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }
}
