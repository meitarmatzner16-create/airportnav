import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/airline_tile.dart';
import '../../../flight/domain/entities/flight.dart';

/// Home search: a regular search field with a live suggestions dropdown.
/// Typing filters flights by number / destination / airline; picking one from
/// the dropdown makes it the active flight.
class HomeSearchBar extends StatelessWidget {
  final String hint;
  final List<Flight> flights;
  final ValueChanged<Flight> onSelected;
  final VoidCallback onScan;

  const HomeSearchBar({
    super.key,
    required this.hint,
    required this.flights,
    required this.onSelected,
    required this.onScan,
  });

  @override
  Widget build(BuildContext context) {
    return Autocomplete<Flight>(
      displayStringForOption: (f) => '${f.flightNumber} · ${f.arrivalCity}',
      optionsBuilder: (TextEditingValue value) {
        final q = value.text.trim().toLowerCase();
        if (q.isEmpty) return const Iterable<Flight>.empty();
        return flights.where((f) =>
            f.flightNumber.toLowerCase().contains(q) ||
            f.arrivalCity.toLowerCase().contains(q) ||
            f.arrivalAirport.toLowerCase().contains(q) ||
            f.airline.toLowerCase().contains(q));
      },
      onSelected: onSelected,
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        return _SearchField(
          controller: controller,
          focusNode: focusNode,
          hint: hint,
          onScan: onScan,
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return _SuggestionsOverlay(
          options: options.toList(),
          onSelected: onSelected,
        );
      },
    );
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String hint;
  final VoidCallback onScan;

  const _SearchField({
    required this.controller,
    required this.focusNode,
    required this.hint,
    required this.onScan,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final fill = isDark ? AppColors.dSurface : AppColors.card;
    final hairline = isDark ? AppColors.dHairline : AppColors.hairline;
    final iconColor = isDark ? AppColors.dMuted : AppColors.muted;
    final textColor = isDark ? AppColors.dText : AppColors.ink;

    OutlineInputBorder border(Color c, double w) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: BorderSide(color: c, width: w),
        );

    return TextField(
      controller: controller,
      focusNode: focusNode,
      textInputAction: TextInputAction.search,
      style: theme.textTheme.bodyMedium?.copyWith(color: textColor),
      cursorColor: AppColors.sky,
      decoration: InputDecoration(
        filled: true,
        fillColor: fill,
        isDense: true,
        hintText: hint,
        hintStyle: theme.textTheme.bodyMedium?.copyWith(color: iconColor),
        prefixIcon: Icon(Icons.search_rounded, size: 22, color: iconColor),
        suffixIcon: ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (context, value, _) => value.text.isEmpty
              ? IconButton(
                  icon: Icon(Icons.qr_code_scanner_rounded,
                      size: 22, color: iconColor),
                  tooltip: 'Scan boarding pass',
                  onPressed: onScan,
                )
              : IconButton(
                  icon: Icon(Icons.close_rounded, size: 20, color: iconColor),
                  tooltip: 'Clear',
                  onPressed: controller.clear,
                ),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 15),
        border: border(hairline, 1),
        enabledBorder: border(hairline, 1),
        focusedBorder: border(AppColors.sky, 1.5),
      ),
    );
  }
}

class _SuggestionsOverlay extends StatelessWidget {
  final List<Flight> options;
  final void Function(Flight) onSelected;

  const _SuggestionsOverlay({required this.options, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.dSurface : AppColors.card;
    final hairline = isDark ? AppColors.dHairline : AppColors.hairline;
    final textColor = isDark ? AppColors.dText : AppColors.ink;
    final mutedColor = isDark ? AppColors.dMuted : AppColors.muted;
    final width = MediaQuery.of(context).size.width - AppSpacing.gutter * 2;
    final clock = DateFormat('h:mm a');

    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Material(
          elevation: 6,
          shadowColor: AppColors.shadowMedium,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          child: Container(
            width: width,
            constraints: const BoxConstraints(maxHeight: 264),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(color: hairline, width: 1),
            ),
            clipBehavior: Clip.antiAlias,
            child: ListView.separated(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              itemCount: options.length,
              separatorBuilder: (_, _) => Divider(height: 1, color: hairline),
              itemBuilder: (context, i) {
                final f = options[i];
                return InkWell(
                  onTap: () => onSelected(f),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    child: Row(
                      children: [
                        AirlineTile(flightNumber: f.flightNumber, size: 30),
                        const SizedBox(width: AppSpacing.smMd),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${f.arrivalCity} (${f.arrivalAirport})',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                    color: textColor,
                                    fontWeight: FontWeight.w600),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                '${f.flightNumber} · ${f.airline}',
                                style: theme.textTheme.labelSmall
                                    ?.copyWith(color: mutedColor),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(clock.format(f.departureTime),
                            style: AppTypography.mono(
                                fontSize: 12, color: mutedColor)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
