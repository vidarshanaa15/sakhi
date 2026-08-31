import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../widgets/empty_state.dart';

/// Placeholder for sidebar sections not built out yet.
/// Chatbot, Community, and Socials now live in their own screen folders.

class PendantScreen extends StatelessWidget {
  const PendantScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppTheme.background,
    appBar: AppBar(
      title: const Text('Sakhi Pendant'),
      backgroundColor: AppTheme.background,
    ),
    body: const EmptyState(
      icon: Icons.watch_outlined,
      message:
      'Pendant integration coming next.\nEvidence capture, live location, and LoRa status will live here.',
    ),
  );
}