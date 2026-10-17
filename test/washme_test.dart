import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:washme/booking.dart';
import 'package:washme/laundry_service.dart';
import 'package:washme/main.dart';

void main() {
  final booking = Booking(
    id: '123',
    serviceName: 'Wash & Fold',
    customerName: 'Ama Mensah',
    phone: '0201234567',
    address: 'Near the market, Kumasi',
    notes: 'Please call on arrival',
    pickupTime: DateTime(2026, 10, 20, 9, 30),
  );

  group('Booking', () {
    test('toJson and fromJson give back the same booking', () {
      final restored = Booking.fromJson(booking.toJson());

      expect(restored.id, booking.id);
      expect(restored.serviceName, booking.serviceName);
      expect(restored.customerName, booking.customerName);
      expect(restored.phone, booking.phone);
      expect(restored.address, booking.address);
      expect(restored.notes, booking.notes);
      expect(restored.pickupTime, booking.pickupTime);
    });

    test('pickupText shows a morning time', () {
      expect(booking.pickupText, '20 Oct 2026, 9:30 AM');
    });

    test('pickupText shows an afternoon time', () {
      final afternoon = Booking(
        id: '2',
        serviceName: 'Dry Cleaning',
        customerName: 'Kofi',
        phone: '0241234567',
        address: 'Accra',
        notes: '',
        pickupTime: DateTime(2026, 11, 3, 14, 5),
      );

      expect(afternoon.pickupText, '3 Nov 2026, 2:05 PM');
    });

    test('pickupText handles midnight and noon', () {
      final midnight = Booking(
        id: '3',
        serviceName: 'Wash & Iron',
        customerName: 'Esi',
        phone: '0501234567',
        address: 'Tema',
        notes: '',
        pickupTime: DateTime(2026, 12, 1, 0, 0),
      );
      final noon = Booking(
        id: '4',
        serviceName: 'Wash & Iron',
        customerName: 'Esi',
        phone: '0501234567',
        address: 'Tema',
        notes: '',
        pickupTime: DateTime(2026, 12, 1, 12, 0),
      );

      expect(midnight.pickupText, '1 Dec 2026, 12:00 AM');
      expect(noon.pickupText, '1 Dec 2026, 12:00 PM');
    });
  });

  group('laundryServices', () {
    test('the list is not empty', () {
      expect(laundryServices, isNotEmpty);
    });

    test('every service has a name and a price above zero', () {
      for (final service in laundryServices) {
        expect(service.name, isNotEmpty);
        expect(service.price, greaterThan(0));
      }
    });
  });

  group('ServiceCard', () {
    testWidgets('shows the service name and price', (tester) async {
      const service = LaundryService(
        name: 'Wash & Fold',
        description: 'Washed, dried and neatly folded.',
        price: 15,
        unit: 'kg',
        icon: Icons.local_laundry_service,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ServiceCard(service: service),
          ),
        ),
      );

      expect(find.text('Wash & Fold'), findsOneWidget);
      expect(find.text('GH\u20B5 15 / kg'), findsOneWidget);
    });
  });
}