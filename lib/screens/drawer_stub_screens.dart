import 'package:flutter/material.dart';
import '../widgets/empty_state.dart';

/// Placeholder screens for sidebar sections not built out yet.
/// Chatbot moved out of here — it now has a real implementation at
/// screens/chatbot/chatbot_screen.dart, imported directly by AppShell.

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Community')),
    body: const EmptyState(
      icon: Icons.groups_outlined,
      message: 'Community groups coming next.\nJoin or create a group by destination.',
    ),
  );
}

class SocialsScreen extends StatelessWidget {
  const SocialsScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Socials')),
    body: const EmptyState(
      icon: Icons.play_circle_outline,
      message: 'Reels and travel blogs coming next.',
    ),
  );
}

class PendantScreen extends StatelessWidget {
  const PendantScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Sakhi Pendant')),
    body: const EmptyState(
      icon: Icons.watch_outlined,
      message: 'Pendant integration coming next.\nEvidence capture, live location, and LoRa status will live here.',
    ),
  );
}

class AppSettingsScreen extends StatelessWidget {
  const AppSettingsScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Settings')),
    body: const EmptyState(
      icon: Icons.settings_outlined,
      message: 'General settings coming next.\nEmergency contacts, live location sharing, and helplines/SOS will live here.',
    ),
  );
}