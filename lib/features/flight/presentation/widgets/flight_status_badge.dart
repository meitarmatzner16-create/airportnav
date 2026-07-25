import 'package:flutter/material.dart';
import '../../../../core/widgets/status_badge.dart';

/// Thin shim that delegates to the kit-level [StatusBadge].
///
/// Public API is unchanged - any screen that constructs [FlightStatusBadge]
/// continues to compile without modification.
class FlightStatusBadge extends StatelessWidget {
  final String status;
  final int? delayMinutes;

  const FlightStatusBadge({
    super.key,
    required this.status,
    this.delayMinutes,
  });

  @override
  Widget build(BuildContext context) {
    return StatusBadge(status: status, delayMinutes: delayMinutes);
  }
}
