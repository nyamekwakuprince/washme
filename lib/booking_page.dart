import 'package:flutter/material.dart';

import 'booking.dart';
import 'booking_storage.dart';
import 'confirmation_page.dart';
import 'laundry_service.dart';
import 'user_preferences.dart';

class BookingPage extends StatefulWidget {
  final LaundryService service;

  const BookingPage({super.key, required this.service});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  static const List<String> _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();
  final UserPreferences _preferences = UserPreferences();

  DateTime? _pickupDate;
  TimeOfDay? _pickupTime;
  String? _dateTimeError;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadSavedContact();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  // Fills in the name and phone the customer used last time.
  Future<void> _loadSavedContact() async {
    try {
      final contact = await _preferences.loadContact();

      if (!mounted) return;

      if (_nameController.text.isEmpty) {
        _nameController.text = contact.name;
      }
      if (_phoneController.text.isEmpty) {
        _phoneController.text = contact.phone;
      }
    } catch (_) {
      // If nothing can be loaded, the customer simply types the details.
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day} ${_months[date.month - 1]} ${date.year}';
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final picked = await showDatePicker(
      context: context,
      initialDate: _pickupDate ?? today,
      firstDate: today,
      lastDate: today.add(const Duration(days: 60)),
    );

    if (picked != null) {
      setState(() {
        _pickupDate = picked;
        _dateTimeError = null;
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _pickupTime ?? const TimeOfDay(hour: 9, minute: 0),
    );

    if (picked != null) {
      setState(() {
        _pickupTime = picked;
        _dateTimeError = null;
      });
    }
  }

  Future<void> _submit() async {
    final formIsValid = _formKey.currentState!.validate();

    final date = _pickupDate;
    final time = _pickupTime;

    String? dateTimeError;
    DateTime? pickupDateTime;

    if (date == null || time == null) {
      dateTimeError = 'Please choose a pickup date and time';
    } else {
      pickupDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );

      if (pickupDateTime.isBefore(DateTime.now())) {
        dateTimeError = 'Pickup time must be in the future';
      }
    }

    setState(() {
      _dateTimeError = dateTimeError;
    });

    if (!formIsValid || dateTimeError != null || pickupDateTime == null) {
      return;
    }

    final booking = Booking(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      serviceName: widget.service.name,
      customerName: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      notes: _notesController.text.trim(),
      pickupTime: pickupDateTime,
    );

    setState(() {
      _isSaving = true;
    });

    try {
      await BookingStorage().addBooking(booking);
    } catch (error) {
      debugPrint('Save failed: $error');
      if (!mounted) return;
      setState(() {
        _isSaving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not save your booking. Please try again.'),
        ),
      );
      return;
    }

    // Remember the name and phone for next time. If this fails, the
    // booking is still saved, so the error is ignored.
    try {
      await _preferences.saveContact(
        name: booking.customerName,
        phone: booking.phone,
      );
    } catch (_) {}

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ConfirmationPage(booking: booking),
      ),
    );
  }

  InputDecoration _inputDecoration(
    String label,
    IconData icon, {
    String? hint,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget _buildServiceSummary() {
    final service = widget.service;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE0F2FE),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(service.icon, color: const Color(0xFF0284C7), size: 36),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'GH\u20B5 ${service.price.toStringAsFixed(0)} / ${service.unit}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0284C7),
                  ),
                ),
              ],
            ),
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
        title: Text('Book ${widget.service.name}'),
        backgroundColor: const Color(0xFFF1F7FB),
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildServiceSummary(),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _nameController,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.words,
                  decoration: _inputDecoration('Full name', Icons.person),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  decoration: _inputDecoration('Phone number', Icons.phone),
                  validator: (value) {
                    final digits =
                        (value ?? '').replaceAll(RegExp(r'[^0-9]'), '');
                    if (digits.length < 9) {
                      return 'Please enter a valid phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _addressController,
                  maxLines: 2,
                  textInputAction: TextInputAction.next,
                  decoration: _inputDecoration(
                    'Pickup address or landmark',
                    Icons.location_on,
                    hint: 'Street, landmark or Ghana Post GPS code',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter the pickup address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _pickDate,
                        icon: const Icon(Icons.calendar_today),
                        label: Text(
                          _pickupDate == null
                              ? 'Pick a date'
                              : _formatDate(_pickupDate!),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _pickTime,
                        icon: const Icon(Icons.access_time),
                        label: Text(
                          _pickupTime == null
                              ? 'Pick a time'
                              : _pickupTime!.format(context),
                        ),
                      ),
                    ),
                  ],
                ),
                if (_dateTimeError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8, left: 4),
                    child: Text(
                      _dateTimeError!,
                      style: const TextStyle(
                        color: Color(0xFFB91C1C),
                        fontSize: 13,
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _notesController,
                  maxLines: 3,
                  decoration: _inputDecoration(
                    'Notes (optional)',
                    Icons.notes,
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    onPressed: _isSaving ? null : _submit,
                    child: Text(
                      _isSaving ? 'Saving...' : 'Continue',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}