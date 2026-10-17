import 'package:shared_preferences/shared_preferences.dart';

// The name and phone number the customer used last time.
class SavedContact {
  final String name;
  final String phone;

  const SavedContact({required this.name, required this.phone});
}

// Remembers small details on the phone using SharedPreferences.
class UserPreferences {
  static const String _nameKey = 'customer_name';
  static const String _phoneKey = 'customer_phone';

  Future<SavedContact> loadContact() async {
    final prefs = await SharedPreferences.getInstance();

    return SavedContact(
      name: prefs.getString(_nameKey) ?? '',
      phone: prefs.getString(_phoneKey) ?? '',
    );
  }

  Future<void> saveContact({
    required String name,
    required String phone,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_nameKey, name);
    await prefs.setString(_phoneKey, phone);
  }
}