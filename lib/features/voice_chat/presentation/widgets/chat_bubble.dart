import 'package:flutter/material.dart';
import 'package:airport_nav/core/constants/app_colors.dart';
import 'package:airport_nav/core/constants/app_spacing.dart';
import 'package:airport_nav/features/voice_chat/domain/entities/chat_message.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        isUser ? AppSpacing.xxl : AppSpacing.md,
        AppSpacing.xs,
        isUser ? AppSpacing.md : AppSpacing.xxl,
        AppSpacing.xs,
      ),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            const _AssistantAvatar(),
            const SizedBox(width: AppSpacing.sm),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.smMd - 2,
              ),
              decoration: BoxDecoration(
                color: isUser
                    ? AppColors.primary
                    : isDark
                        ? AppColors.darkSurface
                        : AppColors.surface,
                border: isUser
                    ? null
                    : Border.all(
                        color: isDark
                            ? AppColors.hairlineDark
                            : AppColors.hairline,
                        width: 1,
                      ),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(AppSpacing.radiusLg),
                  topRight: const Radius.circular(AppSpacing.radiusLg),
                  bottomLeft: Radius.circular(
                      isUser ? AppSpacing.radiusLg : AppSpacing.radiusXs),
                  bottomRight: Radius.circular(
                      isUser ? AppSpacing.radiusXs : AppSpacing.radiusLg),
                ),
              ),
              child: Text(
                message.text,
                style: theme.textTheme.bodyMedium?.copyWith(
                  height: 1.4,
                  color: isUser
                      ? Colors.white
                      : isDark
                          ? AppColors.darkOnSurface
                          : AppColors.onSurface,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AssistantAvatar extends StatelessWidget {
  const _AssistantAvatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.accentAlpha10,
        border: Border.all(color: AppColors.accentAlpha20, width: 1),
      ),
      child: const Icon(
        Icons.auto_awesome,
        color: AppColors.accent,
        size: 14,
      ),
    );
  }
}
