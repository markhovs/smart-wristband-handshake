import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsModel with ChangeNotifier {
  bool _approveContacts = false;

  bool get approveContacts => _approveContacts;

  SettingsModel() {
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _approveContacts = prefs.getBool('approveContacts') ?? false;
    notifyListeners();
  }

  Future<void> toggleApproveContacts() async {
    _approveContacts = !_approveContacts;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('approveContacts', _approveContacts);
  }
}
