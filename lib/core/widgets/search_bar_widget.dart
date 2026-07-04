import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';

/// Sky Pass styled search field.
///
/// Fill: card (light) / dSurface (dark).
/// Border: hairline 1px; focus → sky 1.5px.
/// Radius: radiusMd (14px).
/// Search icon: muted color.
class SearchBarWidget extends StatefulWidget {
  final String hint;
  final ValueChanged<String> onChanged;
  final TextEditingController? controller;

  const SearchBarWidget({
    super.key,
    required this.hint,
    required this.onChanged,
    this.controller,
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  late final TextEditingController _controller;
  bool _ownsController = false;
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _controller = TextEditingController();
      _ownsController = true;
    } else {
      _controller = widget.controller!;
    }
    _controller.addListener(_rebuild);
  }

  void _rebuild() => setState(() {});

  @override
  void dispose() {
    _controller.removeListener(_rebuild);
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fill = isDark ? AppColors.dSurface : AppColors.card;
    final borderColor = isDark ? AppColors.dHairline : AppColors.hairline;
    final focusBorderColor = isDark ? AppColors.dSky : AppColors.sky;
    final iconColor = isDark ? AppColors.dMuted : AppColors.muted;
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      borderSide: BorderSide(
        color: _hasFocus ? focusBorderColor : borderColor,
        width: _hasFocus ? 1.5 : 1.0,
      ),
    );

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Focus(
        onFocusChange: (v) => setState(() => _hasFocus = v),
        child: TextField(
          controller: _controller,
          onChanged: widget.onChanged,
          decoration: InputDecoration(
            hintText: widget.hint,
            filled: true,
            fillColor: fill,
            prefixIcon: Icon(Icons.search, color: iconColor),
            suffixIcon: _controller.text.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.clear, color: iconColor),
                    onPressed: () {
                      _controller.clear();
                      widget.onChanged('');
                    },
                  )
                : null,
            border: border,
            enabledBorder: border,
            focusedBorder: border,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.smMd,
            ),
          ),
        ),
      ),
    );
  }
}
