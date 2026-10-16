class Booking {
  final String id;
  final String serviceName;
  final String customerName;
  final String phone;
  final String address;
  final String notes;
  final DateTime pickupTime;

  const Booking({
    required this.id,
    required this.serviceName,
    required this.customerName,
    required this.phone,
    required this.address,
    required this.notes,
    required this.pickupTime,
  });

  // Turns a booking into a Map that can be saved as JSON text.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'serviceName': serviceName,
      'customerName': customerName,
      'phone': phone,
      'address': address,
      'notes': notes,
      'pickupTime': pickupTime.toIso8601String(),
    };
  }

  // Rebuilds a booking from saved JSON data.
  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] as String,
      serviceName: json['serviceName'] as String,
      customerName: json['customerName'] as String,
      phone: json['phone'] as String,
      address: json['address'] as String,
      notes: json['notes'] as String,
      pickupTime: DateTime.parse(json['pickupTime'] as String),
    );
  }

  // The pickup date and time written for people, e.g. "20 Oct 2026, 9:30 AM".
  String get pickupText {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];

    final hour = pickupTime.hour % 12 == 0 ? 12 : pickupTime.hour % 12;
    final minute = pickupTime.minute.toString().padLeft(2, '0');
    final period = pickupTime.hour < 12 ? 'AM' : 'PM';

    return '${pickupTime.day} ${months[pickupTime.month - 1]} '
        '${pickupTime.year}, $hour:$minute $period';
  }
}