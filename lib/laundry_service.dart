import 'package:flutter/material.dart';

// Describes one laundry service.
class LaundryService {
  final String name;
  final String description;
  final double price;
  final String unit;
  final IconData icon;

  const LaundryService({
    required this.name,
    required this.description,
    required this.price,
    required this.unit,
    required this.icon,
  });
}

// Sample services. The prices are sample values for now.
const List<LaundryService> laundryServices = [
  LaundryService(
    name: 'Wash & Fold',
    description: 'Washed, dried and neatly folded.',
    price: 15,
    unit: 'kg',
    icon: Icons.local_laundry_service,
  ),
  LaundryService(
    name: 'Wash & Iron',
    description: 'Washed, dried and ironed, ready to wear.',
    price: 20,
    unit: 'kg',
    icon: Icons.iron,
  ),
  LaundryService(
    name: 'Dry Cleaning',
    description: 'For suits, dresses and delicate clothes.',
    price: 35,
    unit: 'item',
    icon: Icons.dry_cleaning,
  ),
  LaundryService(
    name: 'Ironing Only',
    description: 'Already clean? We just iron it.',
    price: 5,
    unit: 'item',
    icon: Icons.checkroom,
  ),
  LaundryService(
    name: 'Bedding & Duvets',
    description: 'Bed sheets, blankets and duvets.',
    price: 50,
    unit: 'item',
    icon: Icons.bed,
  ),
];