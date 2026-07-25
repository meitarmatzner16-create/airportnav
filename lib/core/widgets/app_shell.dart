import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:airport_nav/core/constants/app_colors.dart';
import 'package:airport_nav/core/constants/app_spacing.dart';
import 'package:airport_nav/core/theme/app_theme.dart';

/// Bottom-tab shell. Five tabs with the Assistant centered and emphasized as
/// the app's primary feature (a filled blue disc between the flat tabs).
class AppShell extends StatelessWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  static const _tabs = <_NavItem>[
    _NavItem(
      route: '/home',
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: 'Home',
    ),
    _NavItem(
      // Explore tab: browse food, coffee, lounges & shops with rich detail.
      route: '/explore',
      icon: Icons.search_outlined,
      activeIcon: Icons.search_rounded,
      label: 'Explore',
    ),
    _NavItem(
      route: '/voice-chat',
      icon: Icons.auto_awesome_rounded,
      activeIcon: Icons.auto_awesome_rounded,
      label: 'Assistant',
      isHero: true,
    ),
    _NavItem(
      route: '/flights',
      icon: Icons.flight_outlined,
      activeIcon: Icons.flight_rounded,
      label: 'Flights',
    ),
    _NavItem(
      route: '/map',
      icon: Icons.map_outlined,
      activeIcon: Icons.map_rounded,
      label: 'Map',
    ),
  ];

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    for (var i = 0; i < _tabs.length; i++) {
      if (location.startsWith(_tabs[i].route)) return i;
    }
    return -1; // non-tab shell route (e.g. /offers, /more): no active tab
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
            height: 70,
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
    return item.isHero
        ? _HeroTab(isActive: isActive, onTap: onTap, label: item.label)
        : _StandardTab(item: item, isActive: isActive, onTap: onTap);
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
    final activeColor = isDark ? AppColors.dSky : AppColors.sky;
    final inactiveColor =
        isDark ? AppColors.darkOnSurfaceVariant : AppColors.onSurfaceVariant;
    final color = isActive ? activeColor : inactiveColor;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: Semantics(
        selected: isActive,
        button: true,
        label: item.label,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: isActive
                    ? (isDark ? AppColors.skyAlpha15 : AppColors.skyTint)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              ),
              child: Icon(isActive ? item.activeIcon : item.icon,
                  size: 24, color: color),
            ),
            const SizedBox(height: 4),
            Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                fontSize: 11,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroTab extends StatelessWidget {
  final bool isActive;
  final VoidCallback onTap;
  final String label;

  const _HeroTab({
    required this.isActive,
    required this.onTap,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final labelColor = isActive
        ? (isDark ? AppColors.dSky : AppColors.sky)
        : (isDark ? AppColors.dText : AppColors.ink);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      child: Semantics(
        selected: isActive,
        button: true,
        label: label,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.sky2, AppColors.sky],
                ),
                boxShadow: isActive ? AppShadows.accentGlow : AppShadows.card,
              ),
              child: const Icon(Icons.auto_awesome_rounded,
                  size: 24, color: Colors.white),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                color: labelColor,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                fontSize: 11,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
