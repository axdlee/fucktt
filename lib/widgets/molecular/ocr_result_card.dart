import 'package:flutter/material.dart';

import '../atomic/card.dart';
import '../atomic/button.dart';

/// OCR结果卡片 - 分子级组件
/// 展示OCR识别结果
class OcrResultCard extends StatelessWidget {
  final String text;
  final double confidence;
  final String? language;
  final VoidCallback? onCopy;
  final VoidCallback? onRetry;
  final VoidCallback? onShare;

  const OcrResultCard({
    super.key,
    required this.text,
    required this.confidence,
    this.language,
    this.onCopy,
    this.onRetry,
    this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题和置信度
          Row(
            children: [
              Icon(
                Icons.text_fields,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'OCR 识别结果',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              _buildConfidenceBadge(theme),
            ],
          ),
          const SizedBox(height: 12),

          // 识别文本
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: SelectableText(
              text.isNotEmpty ? text : '未识别到文本',
              style: theme.textTheme.bodyMedium,
            ),
          ),
          const SizedBox(height: 12),

          // 语言信息
          if (language != null)
            Row(
              children: [
                Icon(
                  Icons.language,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  '语言: $language',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),

          // 操作按钮
          const SizedBox(height: 16),
          _buildActionButtons(context),
        ],
      ),
    );
  }

  Widget _buildConfidenceBadge(ThemeData theme) {
    Color getColor() {
      if (confidence >= 0.9) return Colors.green;
      if (confidence >= 0.7) return Colors.orange;
      return Colors.red;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: getColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '${(confidence * 100).toStringAsFixed(0)}%',
        style: theme.textTheme.labelSmall?.copyWith(
          color: getColor(),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (onRetry != null) ...[
          AppButton(
            text: '重试',
            type: ButtonType.outline,
            size: ButtonSize.small,
            onPressed: onRetry,
          ),
          const SizedBox(width: 8),
        ],
        if (onCopy != null) ...[
          AppButton(
            text: '复制',
            type: ButtonType.secondary,
            size: ButtonSize.small,
            onPressed: onCopy,
          ),
          const SizedBox(width: 8),
        ],
        if (onShare != null)
          AppButton(
            text: '分享',
            type: ButtonType.primary,
            size: ButtonSize.small,
            onPressed: onShare,
          ),
      ],
    );
  }
}

/// 加载状态卡片
class OcrLoadingCard extends StatelessWidget {
  final String? message;

  const OcrLoadingCard({
    super.key,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            message ?? '正在识别文本...',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// 错误状态卡片
class OcrErrorCard extends StatelessWidget {
  final String error;
  final VoidCallback? onRetry;

  const OcrErrorCard({
    super.key,
    required this.error,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: theme.colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            '识别失败',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.error,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          if (onRetry != null)
            AppButton(
              text: '重试',
              type: ButtonType.danger,
              onPressed: onRetry,
            ),
        ],
      ),
    );
  }
}
