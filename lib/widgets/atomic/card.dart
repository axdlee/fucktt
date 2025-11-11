import 'package:flutter/material.dart';

/// 原子级卡片组件
/// 统一卡片样式和交互
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? elevation;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;
  final bool enabled;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.elevation,
    this.backgroundColor,
    this.borderRadius,
    this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardTheme = theme.cardTheme;
    final defaultRadius = BorderRadius.circular(12);

    Widget card = Card(
      elevation: elevation ?? cardTheme.elevation ?? 1,
      color: backgroundColor ?? cardTheme.color,
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ?? defaultRadius,
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16),
        child: child,
      ),
    );

    if (onTap != null && enabled) {
      card = InkWell(
        onTap: onTap,
        borderRadius: borderRadius ?? defaultRadius,
        child: card,
      );
    }

    return card;
  }
}

/// 信息卡片
class InfoCard extends StatelessWidget {
  final String title;
  final String? content;
  final Widget? icon;
  final CardType type;

  const InfoCard({
    super.key,
    required this.title,
    this.content,
    this.icon,
    this.type = CardType.info,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Color getColor() {
      switch (type) {
        case CardType.info:
          return colorScheme.primary;
        case CardType.success:
          return Colors.green;
        case CardType.warning:
          return Colors.orange;
        case CardType.error:
          return colorScheme.error;
      }
    }

    return AppCard(
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(
              (icon as Icon).icon,
              color: getColor(),
              size: 24,
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (content != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    content!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.textTheme.bodySmall?.color,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 卡片类型
enum CardType {
  info,
  success,
  warning,
  error,
}
