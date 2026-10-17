import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'booking.dart';

class BookingStorage {
  static const Duration _timeout = Duration(seconds: 15);

  final CollectionReference<Map<String, dynamic>> _bookings =
      FirebaseFirestore.instance.collection('bookings');

  // Signs in anonymously the first time, then reuses the same user.
  Future<String> _currentUserId() async {
    final auth = FirebaseAuth.instance;
    final user =
        auth.currentUser ?? (await auth.signInAnonymously()).user;
    return user!.uid;
  }

  Future<List<Booking>> loadBookings() async {
    final userId = await _currentUserId();

    final snapshot = await _bookings
        .where('userId', isEqualTo: userId)
        .get()
        .timeout(_timeout);

    return snapshot.docs.map((doc) => Booking.fromJson(doc.data())).toList();
  }

  Future<void> addBooking(Booking booking) async {
    final userId = await _currentUserId();

    await _bookings.doc(booking.id).set({
      ...booking.toJson(),
      'userId': userId,
    }).timeout(_timeout);
  }

  Future<void> deleteBooking(String id) async {
    await _bookings.doc(id).delete().timeout(_timeout);
  }
}