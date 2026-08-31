import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../models/chat_message.dart';
import 'widgets/chat_bubble.dart';
import 'widgets/chat_input.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final List<ChatMessage> _messages = [];

  bool _isLoading = false;

  // For Flutter running on the same Windows machine as FastAPI.
  //
  // If you later run Flutter on a physical phone, replace this with
  // your computer's local IP address, for example:
  // http://192.168.1.105:8000
  static const String _baseUrl = 'http://127.0.0.1:8000';

  @override
  void initState() {
    super.initState();

    _messages.add(
      ChatMessage(
        text:
            "Hi, I'm Sakhi. I'm here to help you travel more safely. How can I help you?",
        isUser: false,
      ),
    );
  }

  Future<void> _sendMessage(String text) async {
    if (_isLoading) return;

    setState(() {
      _messages.add(
        ChatMessage(
          text: text,
          isUser: true,
        ),
      );

      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/chat'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'message': text,
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final reply = data['reply']?.toString();

        setState(() {
          _messages.add(
            ChatMessage(
              text: reply?.isNotEmpty == true
                  ? reply!
                  : 'Sorry, I could not generate a response.',
              isUser: false,
            ),
          );
        });
      } else {
        setState(() {
          _messages.add(
            ChatMessage(
              text:
                  'Sorry, I could not connect to Sakhi right now. Please try again.',
              isUser: false,
            ),
          );
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _messages.add(
          ChatMessage(
            text:
                'Unable to connect to the Sakhi server. Please check that the backend is running.',
            isUser: false,
          ),
        );
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _sendSuggestion(String suggestion) {
    _sendMessage(suggestion);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.shield_outlined,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sakhi',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Your safety companion',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),

      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 12),
              itemCount: _messages.length +
                  (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _isLoading) {
                  return const _TypingIndicator();
                }

                return ChatBubble(
                  message: _messages[index],
                );
              },
            ),
          ),

          if (_messages.length == 1 && !_isLoading)
            _SuggestionSection(
              onSuggestionTap: _sendSuggestion,
            ),

          if (_isLoading)
            const Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                bottom: 4,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Sakhi is thinking...',
                  style: TextStyle(
                    fontSize: 12,
                  ),
                ),
              ),
            ),

          ChatInput(
            onSend: _sendMessage,
            enabled: !_isLoading,
          ),
        ],
      ),
    );
  }
}


// ---------------------------------------------------------
// Suggestion buttons
// ---------------------------------------------------------

class _SuggestionSection extends StatelessWidget {
  final Function(String) onSuggestionTap;

  const _SuggestionSection({
    required this.onSuggestionTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final suggestions = [
      'How can I stay safe while travelling alone?',
      'How does Sakhi help me during a journey?',
      'How do I report a safety incident?',
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'You can ask me about',
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),

          SizedBox(
            height: 42,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: suggestions.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(width: 8),
              itemBuilder: (context, index) {
                return ActionChip(
                  label: Text(
                    suggestions[index],
                    overflow: TextOverflow.ellipsis,
                  ),
                  onPressed: () =>
                      onSuggestionTap(suggestions[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}


// ---------------------------------------------------------
// Typing indicator
// ---------------------------------------------------------

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 6,
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.shield_outlined,
              color: theme.colorScheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const SizedBox(
              width: 28,
              height: 16,
              child: _ThreeDots(),
            ),
          ),
        ],
      ),
    );
  }
}


class _ThreeDots extends StatefulWidget {
  const _ThreeDots();

  @override
  State<_ThreeDots> createState() => _ThreeDotsState();
}

class _ThreeDotsState extends State<_ThreeDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final value = _controller.value;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(3, (index) {
            final offset =
                ((value + index * 0.2) % 1.0);

            final opacity =
                0.3 + (offset < 0.5 ? offset : 1 - offset);

            return Opacity(
              opacity: opacity.clamp(0.3, 1.0),
              child: Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurfaceVariant,
                  shape: BoxShape.circle,
                ),
              ),
            );
          }),
        );
      },
    );
  }
}