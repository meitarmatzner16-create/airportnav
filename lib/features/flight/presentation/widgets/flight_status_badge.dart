import 'package:flutter/material.dart';

class FlightStatusBadge extends StatelessWidget {
  final String status;

  const FlightStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (color, label) = _statusInfo(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Color((color.value & 0x00FFFFFF) | 0x26000000),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  (Color, String) _statusInfo(String status) {
    switch (status) {
      case 'on_time':
        return (const Color(0xFF16A34A), 'On Time');
      case 'delayed':
        return (const Color(0xFFD97706), 'Delayed');
      case 'cancelled':
        return (const Color(0xFFDC2626), 'Cancelled');
      case 'boarding':
        return (const Color(0xFF7C3AED), 'Boarding');
      case 'landed':
        return (const Color(0xFF0891B2), 'Landed');
      case 'scheduled':
        return (const Color(0xFF2563EB), 'Scheduled');
      default:
        return (Colors.grey, status);
    }
  }
}
