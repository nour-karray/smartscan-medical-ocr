import 'package:flutter/material.dart';

import '../core/app_feedback_service.dart';
import '../theme/app_theme.dart';

class AppBackdrop extends StatelessWidget {
  const AppBackdrop({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return DecoratedBox(
      decoration: BoxDecoration(gradient: AppThemePalette.pageGradient(isDark)),
      child: Stack(
        children: [
          Positioned(
            top: -90,
            right: -30,
            child: _Orb(
              size: 220,
              color: AppThemePalette.primary.withValues(
                alpha: isDark ? 0.22 : 0.14,
              ),
            ),
          ),
          Positioned(
            top: 180,
            left: -70,
            child: _Orb(
              size: 180,
              color: AppThemePalette.secondary.withValues(
                alpha: isDark ? 0.16 : 0.11,
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            right: -20,
            child: _Orb(
              size: 240,
              color: AppThemePalette.tertiary.withValues(
                alpha: isDark ? 0.18 : 0.1,
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: isDark ? 0.0 : 0.08),
                    Colors.transparent,
                    Colors.white.withValues(alpha: isDark ? 0.0 : 0.05),
                  ],
                ),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class AppPanel extends StatelessWidget {
  const AppPanel({
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.gradient,
    this.color,
    this.onTap,
    this.radius = 28,
    this.border,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Gradient? gradient;
  final Color? color;
  final VoidCallback? onTap;
  final double radius;
  final BorderSide? border;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final decoration = BoxDecoration(
      color: gradient == null
          ? color ??
                theme.colorScheme.surface.withValues(alpha: isDark ? 0.9 : 0.88)
          : null,
      gradient: gradient,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: (border?.color ?? theme.colorScheme.outlineVariant).withValues(
          alpha: border == null ? (isDark ? 0.72 : 1) : 1,
        ),
        width: border?.width ?? 1,
      ),
      boxShadow: AppThemePalette.softShadow(isDark),
    );

    final content = Padding(padding: padding, child: child);

    return DecoratedBox(
      decoration: decoration,
      child: Material(
        color: Colors.transparent,
        child: onTap == null
            ? content
            : InkWell(
                onTap: () {
                  AppFeedbackService.instance.tap();
                  onTap?.call();
                },
                borderRadius: BorderRadius.circular(radius),
                child: content,
              ),
      ),
    );
  }
}

class AppSectionHeader extends StatelessWidget {
  const AppSectionHeader({
    required this.title,
    this.subtitle,
    this.eyebrow,
    this.trailing,
    super.key,
  });

  final String title;
  final String? subtitle;
  final String? eyebrow;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (eyebrow != null) ...[
                Text(
                  eyebrow!,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 6),
              ],
              Text(title, style: theme.textTheme.headlineSmall),
              if (subtitle != null) ...[
                const SizedBox(height: 6),
                Text(subtitle!, style: theme.textTheme.bodyMedium),
              ],
            ],
          ),
        ),
        if (trailing != null) ...[const SizedBox(width: 12), trailing!],
      ],
    );
  }
}

class AppStatTile extends StatelessWidget {
  const AppStatTile({
    required this.icon,
    required this.value,
    required this.label,
    this.hint,
    this.accent,
    super.key,
  });

  final IconData icon;
  final String value;
  final String label;
  final String? hint;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tone = accent ?? theme.colorScheme.primary;
    return AppPanel(
      padding: const EdgeInsets.all(16),
      radius: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: tone.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: tone),
          ),
          const SizedBox(height: 16),
          Text(value, style: theme.textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text(label, style: theme.textTheme.labelLarge),
          if (hint != null) ...[
            const SizedBox(height: 4),
            Text(hint!, style: theme.textTheme.bodySmall),
          ],
        ],
      ),
    );
  }
}

class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.action,
    super.key,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppPanel(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 86,
            height: 86,
            decoration: BoxDecoration(
              gradient: AppThemePalette.heroGradient(
                theme.brightness == Brightness.dark,
              ),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Icon(icon, color: Colors.white, size: 42),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 10),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
          if (action != null) ...[const SizedBox(height: 18), action!],
        ],
      ),
    );
  }
}

class _Orb extends StatelessWidget {
  const _Orb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
        ),
      ),
    );
  }
}
