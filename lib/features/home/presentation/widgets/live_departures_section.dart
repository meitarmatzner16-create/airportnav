import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/airline_tile.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../flight/domain/entities/flight.dart';

// Shared column weights so the header and every row line up. All cells are
// flexible + ellipsised so the row can never overflow on a narrow screen.
const double _tileSize = 22;
const double _leadGap = 6;
const double _leadW = _tileSize + _leadGap; // 28
const int _flightFlex = 23;
const int _destFlex = 31;
const int _timeFlex = 20;
const int _gateFlex = 11;
const int _statusFlex = 24;

/// "Live Departures" - a boarding-board style table. Tapping a row selects
/// that flight; the selected row is boxed and its tile becomes a check.
class LiveDeparturesSection extends StatelessWidget {
  final List<Flight> flights;
  final String? selectedFlightId;
  final ValueChanged<Flight> onSelect;
  final VoidCallback onSeeAll;

  const LiveDeparturesSection({
    super.key,
    required this.flights,
    required this.selectedFlightId,
    required this.onSelect,
    required this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.dSurface : AppColors.card;
    final hairline = isDark ? AppColors.dHairline : AppColors.hairline;
    final headerBg = isDark ? AppColors.dBg : AppColors.paper;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Live Departures',
          actionText: 'See all',
          onAction: onSeeAll,
        ),
        const SizedBox(height: AppSpacing.smMd),
        Container(
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: isDark ? Border.all(color: hairline, width: 1) : null,
            boxShadow: isDark ? null : AppShadows.card,
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              _HeaderRow(bg: headerBg, hairline: hairline),
              if (flights.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Text(
                    'No departures in the next few hours.',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: AppColors.muted),
                  ),
                )
              else
                for (var i = 0; i < flights.length; i++)
                  _DeparturesRow(
                    flight: flights[i],
                    selected: flights[i].id == selectedFlightId,
                    isLast: i == flights.length - 1,
                    onTap: () => onSelect(flights[i]),
                  ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HeaderRow extends StatelessWidget {
  final Color bg;
  final Color hairline;

  const _HeaderRow({required this.bg, required this.hairline});

  @override
  Widget build(BuildContext context) {
    final labelStyle = AppTypography.mono(
      fontSize: 9.5,
      weight: FontWeight.w600,
      color: AppColors.muted,
    ).copyWith(letterSpacing: 0.3);

    Widget cell(String text, int flex, {TextAlign align = TextAlign.left}) =>
        Expanded(
          flex: flex,
          child: Text(text,
              style: labelStyle,
              textAlign: align,
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        );

    return Container(
      decoration: BoxDecoration(
        color: bg,
        border: Border(bottom: BorderSide(color: hairline, width: 1)),
      ),
      padding: const EdgeInsets.fromLTRB(10, 9, 10, 9),
      child: Row(
        children: [
          const SizedBox(width: _leadW),
          cell('FLIGHT', _flightFlex),
          cell('DESTINATION', _destFlex),
          cell('TIME', _timeFlex),
          cell('GATE', _gateFlex),
          cell('STATUS', _statusFlex, align: TextAlign.right),
        ],
      ),
    );
  }
}

class _DeparturesRow extends StatelessWidget {
  final Flight flight;
  final bool selected;
  final bool isLast;
  final VoidCallback onTap;

  const _DeparturesRow({
    required this.flight,
    required this.selected,
    required this.isLast,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? AppColors.dText : AppColors.ink;
    final mutedColor = isDark ? AppColors.dMuted : AppColors.muted;
    final hairline = isDark ? AppColors.dHairline : AppColors.hairline;
    final time = DateFormat('h:mm a').format(flight.departureTime);

    Widget dataCell(String text, int flex,
            {required TextStyle style, TextAlign align = TextAlign.left}) =>
        Expanded(
          flex: flex,
          child: Text(text,
              style: style,
              textAlign: align,
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        );

    final rowContent = Row(
      children: [
        AirlineTile(
          flightNumber: flight.flightNumber,
          size: _tileSize,
          selected: selected,
        ),
        const SizedBox(width: _leadGap),
        dataCell(flight.flightNumber, _flightFlex,
            style: AppTypography.mono(
                fontSize: 11, weight: FontWeight.w600, color: textColor)),
        dataCell('${flight.arrivalCity} (${flight.arrivalAirport})', _destFlex,
            style: theme.textTheme.bodySmall?.copyWith(
                  color: textColor,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 11,
                ) ??
                const TextStyle()),
        dataCell(time, _timeFlex,
            style: AppTypography.mono(fontSize: 10.5, color: mutedColor)),
        dataCell(flight.gate ?? '-', _gateFlex,
            style: AppTypography.mono(
                fontSize: 10.5, weight: FontWeight.w600, color: textColor)),
        Expanded(
          flex: _statusFlex,
          child: Align(
            alignment: Alignment.centerRight,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: StatusBadge(status: flight.status),
            ),
          ),
        ),
      ],
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: selected
            ? Container(
                margin: const EdgeInsets.fromLTRB(4, 5, 4, 5),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.skyAlpha15 : AppColors.skyTint,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(color: AppColors.sky, width: 1.5),
                ),
                child: rowContent,
              )
            : Container(
                padding: const EdgeInsets.fromLTRB(10, 13, 10, 13),
                decoration: BoxDecoration(
                  border: isLast
                      ? null
                      : Border(bottom: BorderSide(color: hairline, width: 1)),
                ),
                child: rowContent,
              ),
      ),
    );
  }
}
