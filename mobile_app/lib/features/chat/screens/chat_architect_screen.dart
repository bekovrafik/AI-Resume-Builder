import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import 'package:mobile_app/core/theme/app_theme.dart';
import 'package:mobile_app/core/ui/app_typography.dart';

import 'package:mobile_app/core/ui/gradient_background.dart';

import 'package:mobile_app/core/services/gemini_service.dart';
import 'package:mobile_app/core/ui/custom_snackbar.dart';

// Simple provider for chat state (keeping original logic)
final chatMessagesProvider = StateProvider<List<Content>>((ref) => []);

class ChatArchitectScreen extends ConsumerStatefulWidget {
  const ChatArchitectScreen({super.key});

  @override
  ConsumerState<ChatArchitectScreen> createState() =>
      _ChatArchitectScreenState();
}

class _ChatArchitectScreenState extends ConsumerState<ChatArchitectScreen> {
  final _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  ChatSession? _chatSession;

  final List<String> _quickActions = [
    "Apply Executive Tone",
    "Inject High-Impact Metrics",
    "FAANG ATS Optimization",
    "Refine for Startups",
    "Shorten Summary"
  ];

  @override
  void initState() {
    super.initState();
    // Initialize session lazily or here?
    // We'll init it on first use or safely in build/post-frame if we want to sync history.
    // For now, let's just ensure we have one.
  }

  Future<void> _ensureSession() async {
    if (_chatSession != null) return;

    final gemini = ref.read(geminiServiceProvider);

    // Attempt to sync with existing provider state if any (simple reconstruction)
    // Note: This matches the "fresh start" behavior if provider is empty.
    _chatSession = gemini.startChat();

    // If we wanted to restore history, we would pass it to startChat inside GeminiService
    // via a new method overload, but for this iteration, we start fresh context
    // to ensure the system prompt is the anchor.
    // If the user has old messages in the UI, the AI might not "remember" them
    // unless we replay them. For simplicity in this "Refinement" tool,
    // we assume a session is ephemeral or user hits refresh.
  }

  Future<void> _sendMessage([String? quickAction]) async {
    final text = quickAction ?? _textController.text.trim();
    if (text.isEmpty) return;

    if (quickAction == null) _textController.clear();

    // 1. Update UI immediately
    final userContent = Content.text(text);
    ref
        .read(chatMessagesProvider.notifier)
        .update((state) => [...state, userContent]);

    setState(() => _isLoading = true);
    _scrollToBottom();

    try {
      await _ensureSession();

      // 2. Send to Gemini
      final response = await _chatSession!.sendMessage(userContent);

      if (response.text != null) {
        final aiResponse = Content.model([TextPart(response.text!)]);

        // 3. Update UI with AI Response
        ref
            .read(chatMessagesProvider.notifier)
            .update((state) => [...state, aiResponse]);

        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        CustomSnackBar.show(
          context,
          message: 'Error: $e',
          type: SnackBarType.error,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatMessagesProvider);

    return GradientBackground(
      withOrbs: false, // Cleaner look for chat
      child: Scaffold(
        backgroundColor: Colors.transparent,
        // Pinned Header
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: Container(
            padding: const EdgeInsets.only(top: 10, left: 16, right: 16),
            decoration: BoxDecoration(
              border: Border(
                  bottom:
                      BorderSide(color: Colors.white.withValues(alpha: 0.1))),
              color: AppColors.midnightNavy
                  .withValues(alpha: 0.8), // Semi-transparent header
            ),
            child: SafeArea(
              child: Row(
                children: [
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back,
                          size: 18, color: Colors.white),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("AI ASSISTANT",
                          style: AppTypography.labelSmall
                              .copyWith(color: Colors.white)),
                      Row(
                        children: [
                          Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                  color: Colors.green, shape: BoxShape.circle)),
                          const SizedBox(width: 4),
                          Text("ONLINE",
                              style: AppTypography.labelSmall
                                  .copyWith(color: Colors.grey, fontSize: 8)),
                        ],
                      )
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.white54),
                    onPressed: () =>
                        ref.read(chatMessagesProvider.notifier).state = [],
                  ),
                ],
              ),
            ),
          ),
        ),
        body: Column(
          children: [
            // Message Stream
            Expanded(
              child: messages.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(Icons.chat_bubble_outline,
                                color: AppColors.strategicGold),
                          ),
                          const SizedBox(height: 16),
                          Text("NARRATIVE FORGE",
                              style: AppTypography.header3
                                  .copyWith(color: Colors.white)),
                          const SizedBox(height: 8),
                          Text(
                            "Awaiting instructions.\nHow shall we refine your career legacy today?",
                            textAlign: TextAlign.center,
                            style: AppTypography.bodySmall
                                .copyWith(color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final msg = messages[index];
                        final isUser = msg.role == 'user';
                        return Align(
                          alignment: isUser
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            padding: const EdgeInsets.all(16),
                            constraints: const BoxConstraints(maxWidth: 280),
                            decoration: BoxDecoration(
                              color: isUser
                                  ? AppColors.strategicGold
                                  : AppColors
                                      .midnightNavy, // Darker contrast for AI
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(16),
                                topRight: const Radius.circular(16),
                                bottomLeft: isUser
                                    ? const Radius.circular(16)
                                    : const Radius.circular(2),
                                bottomRight: isUser
                                    ? const Radius.circular(2)
                                    : const Radius.circular(16),
                              ),
                              border: isUser
                                  ? null
                                  : Border.all(
                                      color:
                                          Colors.white.withValues(alpha: 0.1)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                )
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  msg.parts
                                      .whereType<TextPart>()
                                      .map((e) => e.text)
                                      .join(''),
                                  style: isUser
                                      ? AppTypography.bodyMedium.copyWith(
                                          color: AppColors.midnightNavy)
                                      : AppTypography.bodyMedium
                                          .copyWith(color: Colors.white),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  isUser ? "SENT" : "AI",
                                  style: AppTypography.labelSmall.copyWith(
                                    fontSize: 8,
                                    color: isUser
                                        ? AppColors.midnightNavy
                                            .withValues(alpha: 0.6)
                                        : Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),

            if (_isLoading)
              Padding(
                padding: const EdgeInsets.only(left: 20, bottom: 10),
                child: Row(
                  children: [
                    Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                            color: AppColors.strategicGold,
                            shape: BoxShape.circle)),
                    const SizedBox(width: 4),
                    Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                            color: AppColors.strategicGold,
                            shape: BoxShape.circle)),
                    const SizedBox(width: 4),
                    Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                            color: AppColors.strategicGold,
                            shape: BoxShape.circle)),
                  ],
                ),
              ),

            // Footer
            Container(
              padding: const EdgeInsets.only(
                  top: 16, bottom: 24, left: 16, right: 16),
              decoration: BoxDecoration(
                color: AppColors.midnightNavy.withValues(alpha: 0.9),
                border: Border(
                    top:
                        BorderSide(color: Colors.white.withValues(alpha: 0.1))),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  children: [
                    // Quick Actions
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _quickActions
                            .map((action) => Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: InkWell(
                                    onTap: _isLoading
                                        ? null
                                        : () => _sendMessage(action),
                                    borderRadius: BorderRadius.circular(20),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 8),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Colors.white
                                                .withValues(alpha: 0.2)),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(action,
                                          style: AppTypography.labelSmall
                                              .copyWith(color: Colors.grey)),
                                    ),
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Input Row
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.attach_file,
                              color: Colors.grey, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            height: 44,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.1)),
                            ),
                            child: TextField(
                              controller: _textController,
                              style: AppTypography.bodyMedium
                                  .copyWith(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: "Apply Refinement...",
                                hintStyle: AppTypography.bodyMedium
                                    .copyWith(color: Colors.white24),
                                border: InputBorder.none,
                              ),
                              onSubmitted:
                                  _isLoading ? null : (_) => _sendMessage(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        InkWell(
                          onTap: _isLoading ? null : () => _sendMessage(),
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: const BoxDecoration(
                              color: AppColors.strategicGold,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.arrow_upward,
                                color: AppColors.midnightNavy),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
