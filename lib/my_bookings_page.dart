import 'package:flutter/material.dart';

import 'booking.dart';
import 'booking_storage.dart';

class MyBookingsPage extends StatefulWidget {
  const MyBookingsPage({super.key});

  @override
  State<MyBookingsPage> createState() => _MyBookingsPageState();
}

class _MyBookingsPageState extends State<MyBookingsPage> {
  final BookingStorage _storage = BookingStorage();

  List<Booking> _bookings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    final bookings = await _storage.loadBookings();
    bookings.sort((a, b) => a.pickupTime.compareTo(b.pickupTime));

    if (!mounted) return;
    setState(() {
      _bookings = bookings;
      _isLoading = false;
    });
  }

  Future<void> _cancelBooking(Booking booking) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Cancel booking?'),
          content: Text(
            'Cancel your ${booking.serviceName} booking on ${booking.pickupText}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Keep it'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Cancel booking'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    await _storage.deleteBooking(booking.id);
    await _loadBookings();
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Color(0xFF94A3B8)),
            SizedBox(height: 16),
            Text(
              'No bookings yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Book a service from the home screen and it will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF64748B)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingCard(Booking booking) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.serviceName,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  booking.pickupText,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0284C7),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  booking.address,
                  style: const TextStyle(color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 2),
                Text(
                  '${booking.customerName} \u2022 ${booking.phone}',
                  style: const TextStyle(color: Color(0xFF64748B)),
                ),
                if (booking.notes.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Notes: ${booking.notes}',
                    style: const TextStyle(color: Color(0xFF64748B)),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            tooltip: 'Cancel booking',
            icon: const Icon(Icons.delete_outline),
            color: const Color(0xFFB91C1C),
            onPressed: () => _cancelBooking(booking),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F7FB),
      appBar: AppBar(
        title: const Text('My Bookings'),
        backgroundColor: const Color(0xFFF1F7FB),
        scrolledUnderElevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _bookings.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(24),
                  itemCount: _bookings.length,
                  itemBuilder: (context, index) {
                    return _buildBookingCard(_bookings[index]);
                  },
                ),
    );
  }
}