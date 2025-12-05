// Remind notifier and model
import 'package:flutter/foundation.dart';

class Reminder {
	final String id;
	final String bookId;
	final String frequency; // e.g. 'Once a day'

	Reminder({required this.id, required this.bookId, required this.frequency});
}

class RemindNotifier extends ChangeNotifier {
	final List<Reminder> _reminders = [];

	List<Reminder> get reminders => List.unmodifiable(_reminders);

	void addReminder(Reminder r) {
		_reminders.add(r);
		notifyListeners();
	}

	void removeReminder(String id) {
		_reminders.removeWhere((r) => r.id == id);
		notifyListeners();
	}
}