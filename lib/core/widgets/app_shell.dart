import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:airport_nav/core/constants/app_colors.dart';
import 'package:airport_nav/core/constants/app_spacing.dart';
import 'package:airport_nav/core/theme/app_theme.dart';

/// Bottom-tab shell. The Assistant tab (index 2) is rendered as a raised
/// gradient pill so it reads as the visually central feature of the app.
class AppShell extends StatelessWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  static const _tabs = <_NavItem>[
    _NavItem(
      route: '/home',
      icon: Icons.flight_outlined,
      activeIcon: Icons.flight,
      label: 'Home',
    ),
    _NavItem(
      route: '/offers',
      icon: Icons.local_offer_outlined,
      activeIcon: Icons.local_offer,
      label: 'Offers',
    ),
    _NavItem(
      route: '/voice-chat',
      icon: Icons.auto_awesome,
      activeIcon: Icons.auto_awesome,
      label: 'Assistant',
      isHero: true,
    ),
    _NavItem(
      route: '/venues',
      icon: Icons.search_outlined,
      activeIcon: Icons.search,
      label: 'Venues',
    ),
    _NavItem(
      route: '/more',
      icon: Icons.menu_outlined,
      activeIcon: Icons.menu,
      label: 'More',
    ),
  ];

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    for (var i = 0; i < _tabs.length; i++) {
      if (location.startsWith(_tabs[i].route)) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surface = isDark ? AppColors.darkSurface : AppColors.surface;
    final hairline = isDark ? AppColors.hairlineDark : AppColors.hairline;
    final currentIndex = _currentIndex(context);

    return Scaffold(
      body: child,
      extendBody: false,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: surface,
          border: Border(top: BorderSide(color: hairline, width: 1)),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.transparent : AppColors.shadowSoft,
              blurRadius: 18,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 68,
            child: Row(
              children: List.generate(_tabs.length, (i) {
                final tab = _tabs[i];
                return Expanded(
                  child: _NavTab(
                    item: tab,
                    isActive: currentIndex == i,
                    onTap: () => context.go(tab.route),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final String route;
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isHero;

  const _NavItem({
    required this.route,
    required this.icon,
    required this.activeIcon,
    required this.label,
    this.isHero = false,
  });
}

class _NavTab extends StatelessWidget {
  final _NavItem item;
  final bool isActive;
  final VoidCallback onTap;

  const _NavTab({
    required this.item,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (item.isHero) {
      return _AssistantTab(isActive: isActive, onTap: onTap, label: item.label);
    }
    return _StandardTab(item: item, isActive: isActive, onTap: onTap);
  }
}

class _StandardTab extends StatelessWidget {
  final _NavItem item;
  final bool isActive;
  final VoidCallback onTap;

  const _StandardTab({
    required this.item,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final activeColor = AppColors.accent;
    final inactiveColor = isDark
        ? AppColors.darkOnSurfaceVariant
        : AppColors.onSurfaceVariant;
    final color = isActive ? activeColor : inactiveColor;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            transitionBuilder: (child, anim) =>
                ScaleTransition(scale: anim, child: child),
            child: Icon(
              isActive ? item.activeIcon : item.icon,
              key: ValueKey(isActive),
              size: 24,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            item.label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              fontSize: 11,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _AssistantTab extends StatelessWidget {
  final bool isActive;
  final VoidCallback onTap;
  final String label;

  const _AssistantTab({
    required this.isActive,
    required this.onTap,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final inactiveLabel = isDark
        ? AppColors.darkOnSurfaceVariant
        : AppColors.onSurfaceVariant;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive ? AppColors.accent : AppColors.accentAlpha10,
              border: Border.all(
                color: isActive ? AppColors.accent : AppColors.accentAlpha20,
                width: 1,
              ),
              boxShadow: isActive ? AppShadows.accentGlow : null,
            ),
            child: Icon(
              Icons.auto_awesome,
              size: 20,
              color: isActive ? Colors.white : AppColors.accent,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: isActive ? AppColors.accent : inactiveLabel,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
