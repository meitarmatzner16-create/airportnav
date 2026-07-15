import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';

/// Live search field on Home. Filters the departures board as you type;
/// shows a scan affordance when empty and a clear button once text is entered.
class HomeSearchBar extends StatefulWidget {
  final String hint;
  final ValueChanged<String> onChanged;
  final VoidCallback onScan;

  const HomeSearchBar({
    super.key,
    required this.hint,
    required this.onChanged,
    required this.onScan,
  });

  @override
  State<HomeSearchBar> createState() => _HomeSearchBarState();
}

class _HomeSearchBarState extends State<HomeSearchBar> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_handleChange);
    _focusNode.addListener(() => setState(() {}));
  }

  void _handleChange() {
    setState(() {});
    widget.onChanged(_controller.text);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final fill = isDark ? AppColors.dSurface : AppColors.card;
    final hairline = isDark ? AppColors.dHairline : AppColors.hairline;
    final iconColor = isDark ? AppColors.dMuted : AppColors.muted;
    final textColor = isDark ? AppColors.dText : AppColors.ink;
    final focused = _focusNode.hasFocus;
    final hasText = _controller.text.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: focused ? AppColors.sky : hairline,
          width: focused ? 1.5 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: AppSpacing.md, right: 6),
        child: Row(
          children: [
            Icon(Icons.search_rounded, size: 22, color: iconColor),
            const SizedBox(width: AppSpacing.smMd),
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                textInputAction: TextInputAction.search,
                style: theme.textTheme.bodyMedium?.copyWith(color: textColor),
                cursorColor: AppColors.sky,
                decoration: InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  hintText: widget.hint,
                  hintStyle:
                      theme.textTheme.bodyMedium?.copyWith(color: iconColor),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            hasText
                ? IconButton(
                    icon: Icon(Icons.close_rounded, size: 20, color: iconColor),
                    splashRadius: 20,
                    tooltip: 'Clear',
                    onPressed: () => _controller.clear(),
                  )
                : IconButton(
                    icon: Icon(Icons.qr_code_scanner_rounded,
                        size: 22, color: iconColor),
                    splashRadius: 20,
                    tooltip: 'Scan boarding pass',
                    onPressed: widget.onScan,
                  ),
          ],
        ),
      ),
    );
  }
}
