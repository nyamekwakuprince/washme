import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'booking.dart';

class BookingStorage {
  static const String _key = 'bookings';

  Future<List<Booking>> loadBookings() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(_key) ?? [];

    return saved.map((item) {
      return Booking.fromJson(jsonDecode(item) as Map<String, dynamic>);
    }).toList();
  }

  Future<void> addBooking(Booking booking) async {
    final bookings = await loadBookings();
    bookings.add(booking);
    await _saveAll(bookings);
  }

  Future<void> deleteBooking(String id) async {
    final bookings = await loadBookings();
    bookings.removeWhere((booking) => booking.id == id);
    await _saveAll(bookings);
  }

  Future<void> _saveAll(List<Booking> bookings) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = bookings.map((booking) {
      return jsonEncode(booking.toJson());
    }).toList();

    await prefs.setStringList(_key, encoded);
  }
}