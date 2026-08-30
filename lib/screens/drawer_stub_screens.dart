import 'package:flutter/material.dart';
import '../widgets/empty_state.dart';

/// Placeholder screens for sidebar sections not built out yet.
/// Each uses your existing EmptyState widget so they're visually
/// consistent with Search/Itinerary's empty states. Replace the body
/// of each as that feature gets built — the AppShell drawer already
/// routes to these, so nothing else needs to change when you do.

class ChatbotScreen extends StatelessWidget {
  const ChatbotScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Itinerary Chatbot')),
    body: const EmptyState(
      icon: Icons.chat_bubble_outline,
      message: 'Chatbot coming next.\nWill suggest hidden gems and plan itineraries based on your preferences.',
    ),
  );
}

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