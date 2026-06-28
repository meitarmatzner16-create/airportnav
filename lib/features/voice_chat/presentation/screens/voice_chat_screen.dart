import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:airport_nav/core/constants/app_colors.dart';
import 'package:airport_nav/core/constants/app_spacing.dart';
import 'package:airport_nav/core/theme/app_theme.dart';
import 'package:airport_nav/features/voice_chat/domain/entities/chat_message.dart';
import 'package:airport_nav/features/voice_chat/presentation/providers/voice_chat_providers.dart';
import 'package:airport_nav/features/voice_chat/presentation/widgets/chat_bubble.dart';
import 'package:airport_nav/features/voice_chat/presentation/widgets/route_plan_card.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class VoiceChatScreen extends ConsumerStatefulWidget {
  const VoiceChatScreen({super.key});

  @override
  ConsumerState<VoiceChatScreen> createState() => _VoiceChatScreenState();
}

class _VoiceChatScreenState extends ConsumerState<VoiceChatScreen>
    with TickerProviderStateMixin {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  final _focusNode = FocusNode();
  late stt.SpeechToText _speech;
  bool _speechAvailable = false;
  late AnimationController _pulseController;
  late AnimationController _orbController;

  static const _suggestions = <_Suggestion>[
    _Suggestion(
      icon: Icons.lunch_dining,
      title: 'Quick eat + luxury shopping',
      subtitle: 'A burger followed by designer bags',
      prompt: 'I want to eat a burger and see luxury bag shops',
    ),
    _Suggestion(
      icon: Icons.local_cafe_outlined,
      title: 'Duty free + coffee',
      subtitle: 'Browse, then sip before boarding',
      prompt: 'I want to browse duty free and grab a coffee',
    ),
    _Suggestion(
      icon: Icons.airline_seat_individual_suite_outlined,
      title: 'Recharge + tech',
      subtitle: 'Lounge time and an electronics stop',
      prompt: 'Find me a lounge to relax and an electronics store',
    ),
    _Suggestion(
      icon: Icons.shopping_bag_outlined,
      title: 'The full luxe loop',
      subtitle: 'Eat, shop, browse, and gear up',
      prompt:
          'I want to eat, shop for luxury bags, browse duty free, and check out electronics',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _initSpeech();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _orbController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3600),
    )..repeat(reverse: true);
  }

  Future<void> _initSpeech() async {
    _speechAvailable = await _speech.initialize(
      onError: (error) {
        ref.read(isListeningProvider.notifier).state = false;
        _pulseController.stop();
      },
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          ref.read(isListeningProvider.notifier).state = false;
          _pulseController.stop();
        }
      },
    );
    if (mounted) setState(() {});
  }

  void _startListening() async {
    if (!_speechAvailable) return;
    ref.read(isListeningProvider.notifier).state = true;
    _pulseController.repeat(reverse: true);
    await _speech.listen(
      onResult: (result) {
        _textController.text = result.recognizedWords;
        if (result.finalResult) {
          _sendMessage();
        }
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 5),
    );
  }

  void _stopListening() async {
    await _speech.stop();
    ref.read(isListeningProvider.notifier).state = false;
    _pulseController.stop();
  }

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    ref.read(voiceChatMessagesProvider.notifier).sendMessage(text);
    _textController.clear();
    _scrollToBottom();
  }

  void _applySuggestion(String prompt) {
    _textController.text = prompt;
    _textController.selection = TextSelection.fromPosition(
      TextPosition(offset: _textController.text.length),
    );
    _focusNode.requestFocus();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    _pulseController.dispose();
    _orbController.dispose();
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(voiceChatMessagesProvider);
    final isListening = ref.watch(isListeningProvider);
    final airportCode = ref.watch(voiceChatAirportProvider);
    final theme = Theme.of(context);

    // "Hero" mode = the user has not chatted yet (only the greeting exists).
    final inHeroMode =
        messages.length <= 1 && (messages.isEmpty || !messages.first.isUser);
    final greetingText =
        messages.isNotEmpty && !messages.first.isUser ? messages.first.text : '';

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            ShaderMask(
              shaderCallback: (rect) => const LinearGradient(
                colors: [AppColors.accent, AppColors.primaryLight],
              ).createShader(rect),
              child: const Icon(Icons.auto_awesome, size: 22, color: Colors.white),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'Assistant',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        actions: [
          _AirportPill(
            airportCode: airportCode,
            onChanged: (value) {
              ref.read(voiceChatAirportProvider.notifier).state = value;
              ref.read(voiceChatMessagesProvider.notifier).resetChat();
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'New conversation',
            onPressed: () {
              ref.read(voiceChatMessagesProvider.notifier).resetChat();
            },
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 280),
              transitionBuilder: (child, animation) =>
                  FadeTransition(opacity: animation, child: child),
              child: inHeroMode
                  ? _HeroState(
                      key: const ValueKey('hero'),
                      orbController: _orbController,
                      greeting: greetingText,
                      suggestions: _suggestions,
                      onSuggestion: (s) => _applySuggestion(s.prompt),
                    )
                  : _ConversationState(
                      key: const ValueKey('conversation'),
                      scrollController: _scrollController,
                      messages: messages,
                    ),
            ),
          ),

          // Undo strip — only when there's a previous itinerary to revert to.
          if (!inHeroMode)
            Consumer(
              builder: (context, ref, _) {
                final canUndo = ref.watch(canUndoItineraryProvider);
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: canUndo
                      ? _UndoStrip(
                          key: const ValueKey('undo'),
                          onUndo: () {
                            ref
                                .read(voiceChatMessagesProvider.notifier)
                                .undo();
                          },
                        )
                      : const SizedBox.shrink(key: ValueKey('no-undo')),
                );
              },
            ),

          // Compact suggestion strip (conversation mode only).
          if (!inHeroMode)
            _SuggestionStrip(
              suggestions: _suggestions,
              onTap: (s) => _applySuggestion(s.prompt),
            ),

          _InputDock(
            controller: _textController,
            focusNode: _focusNode,
            isListening: isListening,
            pulseController: _pulseController,
            onSend: _sendMessage,
            onMicTap: () {
              if (isListening) {
                _stopListening();
              } else {
                _startListening();
              }
            },
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Hero state — shown before the user has chatted.
// ─────────────────────────────────────────────────────────────────────────────
class _HeroState extends StatelessWidget {
  final AnimationController orbController;
  final String greeting;
  final List<_Suggestion> suggestions;
  final void Function(_Suggestion) onSuggestion;

  const _HeroState({
    super.key,
    required this.orbController,
    required this.greeting,
    required this.suggestions,
    required this.onSuggestion,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.gutter,
        AppSpacing.lg,
        AppSpacing.gutter,
        AppSpacing.lg,
      ),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.lg),
          _AssistantOrb(controller: orbController),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'How can I help today?',
            textAlign: TextAlign.center,
            style: theme.textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.smMd),
          if (greeting.isNotEmpty)
            Text(
              greeting,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          const SizedBox(height: AppSpacing.xxl),
          ...suggestions.map(
            (s) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.smMd),
              child: _SuggestionCard(suggestion: s, onTap: () => onSuggestion(s)),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}

class _AssistantOrb extends StatelessWidget {
  final AnimationController controller;
  const _AssistantOrb({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final t = Curves.easeInOut.transform(controller.value);
        final outerScale = 1.0 + (t * 0.08);
        final midScale = 1.0 + (t * 0.04);
        return SizedBox(
          width: 200,
          height: 200,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer halo
              Transform.scale(
                scale: outerScale,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.accent.withValues(alpha: 0.20),
                        AppColors.accent.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),
              // Mid ring
              Transform.scale(
                scale: midScale,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.accentAlpha10,
                    border: Border.all(
                      color: AppColors.accentAlpha20,
                      width: 1,
                    ),
                  ),
                ),
              ),
              // Inner orb — solid accent, no gradient.
              Container(
                width: 84,
                height: 84,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.accent,
                  boxShadow: AppShadows.accentGlow,
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  final _Suggestion suggestion;
  final VoidCallback onTap;

  const _SuggestionCard({required this.suggestion, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surface = isDark ? AppColors.darkSurface : AppColors.surface;
    final hairline = isDark ? AppColors.hairlineDark : AppColors.hairline;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        child: Ink(
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(color: hairline, width: 1),
            boxShadow: AppShadows.card,
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    color: AppColors.accentAlpha10,
                  ),
                  child: Icon(
                    suggestion.icon,
                    color: AppColors.accent,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        suggestion.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        suggestion.subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                const Icon(
                  Icons.arrow_forward_rounded,
                  color: AppColors.onSurfaceVariant,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Conversation state.
// ─────────────────────────────────────────────────────────────────────────────
class _ConversationState extends StatelessWidget {
  final ScrollController scrollController;
  final List<ChatMessage> messages;

  const _ConversationState({
    super.key,
    required this.scrollController,
    required this.messages,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.smMd),
      itemCount: messages.length,
      cacheExtent: 1000,
      itemBuilder: (context, index) {
        final message = messages[index];
        return RepaintBoundary(
          key: ValueKey(message.id),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ChatBubble(message: message),
              if (message.routePlan != null)
                RoutePlanCard(plan: message.routePlan!),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Undo affordance shown above the input dock when an earlier itinerary
// state exists. Quiet by design — neutral pill with an accent label.
// ─────────────────────────────────────────────────────────────────────────────
class _UndoStrip extends StatelessWidget {
  final VoidCallback onUndo;

  const _UndoStrip({super.key, required this.onUndo});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.gutter,
        AppSpacing.xs,
        AppSpacing.gutter,
        AppSpacing.xs,
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onUndo,
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.smMd,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                border: Border.all(color: AppColors.hairline, width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.undo_rounded,
                      size: 14, color: AppColors.accent),
                  const SizedBox(width: 6),
                  Text(
                    'Undo last change',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Compact pill strip used in conversation mode.
// ─────────────────────────────────────────────────────────────────────────────
class _SuggestionStrip extends StatelessWidget {
  final List<_Suggestion> suggestions;
  final void Function(_Suggestion) onTap;

  const _SuggestionStrip({required this.suggestions, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        itemCount: suggestions.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, i) {
          final s = suggestions[i];
          return InkWell(
            onTap: () => onTap(s),
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.smMd,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                color: AppColors.accentAlpha10,
                border: Border.all(color: AppColors.accentAlpha20, width: 1),
              ),
              child: Row(
                children: [
                  Icon(s.icon, size: 14, color: AppColors.accent),
                  const SizedBox(width: 6),
                  Text(
                    s.title,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom input dock.
// ─────────────────────────────────────────────────────────────────────────────
class _InputDock extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isListening;
  final AnimationController pulseController;
  final VoidCallback onSend;
  final VoidCallback onMicTap;

  const _InputDock({
    required this.controller,
    required this.focusNode,
    required this.isListening,
    required this.pulseController,
    required this.onSend,
    required this.onMicTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surface = isDark ? AppColors.darkSurface : AppColors.surface;
    final fieldBg = isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant;
    final hairline = isDark ? AppColors.hairlineDark : AppColors.hairline;

    return Container(
      decoration: BoxDecoration(
        color: surface,
        border: Border(top: BorderSide(color: hairline, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.smMd,
            AppSpacing.sm,
            AppSpacing.smMd,
            AppSpacing.sm,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: fieldBg,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.smMd),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: controller,
                          focusNode: focusNode,
                          minLines: 1,
                          maxLines: 4,
                          style: theme.textTheme.bodyMedium,
                          decoration: const InputDecoration(
                            hintText: 'Tell me what you want to do…',
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            filled: false,
                            contentPadding: EdgeInsets.symmetric(vertical: 12),
                          ),
                          onSubmitted: (_) => onSend(),
                          textInputAction: TextInputAction.send,
                        ),
                      ),
                      ValueListenableBuilder<TextEditingValue>(
                        valueListenable: controller,
                        builder: (context, value, _) {
                          final hasText = value.text.trim().isNotEmpty;
                          return AnimatedSwitcher(
                            duration: const Duration(milliseconds: 180),
                            transitionBuilder: (child, animation) =>
                                ScaleTransition(scale: animation, child: child),
                            child: hasText
                                ? IconButton(
                                    key: const ValueKey('send'),
                                    icon: const Icon(Icons.arrow_upward_rounded),
                                    color: AppColors.accent,
                                    onPressed: onSend,
                                  )
                                : const SizedBox(
                                    key: ValueKey('empty'),
                                    width: 0,
                                  ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              _MicButton(
                isListening: isListening,
                pulseController: pulseController,
                onTap: onMicTap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MicButton extends StatelessWidget {
  final bool isListening;
  final AnimationController pulseController;
  final VoidCallback onTap;

  const _MicButton({
    required this.isListening,
    required this.pulseController,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulseController,
      builder: (context, _) {
        final t = pulseController.value;
        return SizedBox(
          width: 48,
          height: 48,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (isListening)
                Container(
                  width: 48 + (t * 16),
                  height: 48 + (t * 16),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.error.withValues(alpha: 0.16 * (1 - t)),
                  ),
                ),
              Material(
                color: Colors.transparent,
                shape: const CircleBorder(),
                child: InkWell(
                  onTap: onTap,
                  customBorder: const CircleBorder(),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isListening ? AppColors.error : AppColors.accent,
                    ),
                    child: Icon(
                      isListening ? Icons.stop_rounded : Icons.mic_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AirportPill extends StatelessWidget {
  final String airportCode;
  final ValueChanged<String> onChanged;

  const _AirportPill({required this.airportCode, required this.onChanged});

  static const _airports = ['JFK', 'LAX', 'LHR', 'CDG', 'DXB', 'SIN', 'NRT', 'SFO'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.smMd, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.accentAlpha10,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        border: Border.all(color: AppColors.accentAlpha20, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.public_rounded, size: 14, color: AppColors.accent),
          const SizedBox(width: 6),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: airportCode,
              isDense: true,
              icon: const Icon(Icons.arrow_drop_down_rounded,
                  size: 18, color: AppColors.accent),
              style: theme.textTheme.labelLarge?.copyWith(
                color: AppColors.accent,
                fontWeight: FontWeight.w700,
              ),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              items: [
                for (final a in _airports)
                  DropdownMenuItem(value: a, child: Text(a)),
              ],
              onChanged: (value) {
                if (value != null) onChanged(value);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Suggestion {
  final IconData icon;
  final String title;
  final String subtitle;
  final String prompt;

  const _Suggestion({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.prompt,
  });
}
