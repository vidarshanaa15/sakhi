import 'package:flutter/material.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/search/search_screen.dart';
import '../screens/itinerary/itinerary_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/drawer_stub_screens.dart';
import '../core/state/auth_store.dart';
import '../screens/auth/login_screen.dart';

/// Replaces BottomNavShell. A side drawer scales better than bottom tabs
/// once you're past ~4 sections — this app has 9.
///
/// IndexedStack keeps each screen's state alive when switching sections
/// (e.g. Search's filters don't reset when you check the Chatbot and
/// come back), same tradeoff the old BottomNavShell made.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  static const _screens = [
    DashboardScreen(),
    HomeScreen(),
    SearchScreen(),
    ChatbotScreen(),
    ItineraryScreen(),
    CommunityScreen(),
    SocialsScreen(),
    PendantScreen(),
    AppSettingsScreen(),
    ProfileScreen(),
  ];

  static const _drawerItems = [
    _DrawerItem(icon: Icons.dashboard_outlined, selectedIcon: Icons.dashboard, label: 'Dashboard'),
    _DrawerItem(icon: Icons.explore_outlined, selectedIcon: Icons.explore, label: 'Explore'),
    _DrawerItem(icon: Icons.search_outlined, selectedIcon: Icons.search, label: 'Search'),
    _DrawerItem(icon: Icons.chat_bubble_outline, selectedIcon: Icons.chat_bubble, label: 'Chatbot'),
    _DrawerItem(icon: Icons.map_outlined, selectedIcon: Icons.map, label: 'Trips'),
    _DrawerItem(icon: Icons.groups_outlined, selectedIcon: Icons.groups, label: 'Community'),
    _DrawerItem(icon: Icons.play_circle_outline, selectedIcon: Icons.play_circle, label: 'Socials'),
    _DrawerItem(icon: Icons.watch_outlined, selectedIcon: Icons.watch, label: 'Sakhi Pendant'),
    _DrawerItem(icon: Icons.settings_outlined, selectedIcon: Icons.settings, label: 'Settings'),
    _DrawerItem(icon: Icons.person_outline, selectedIcon: Icons.person, label: 'Profile'),
  ];

  void _select(int i) {
    Navigator.pop(context); // close drawer
    setState(() => _index = i);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_drawerItems[_index].label)),
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              _DrawerHeader(),
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: _drawerItems.length,
                  itemBuilder: (context, i) {
                    final item = _drawerItems[i];
                    final selected = i == _index;
                    return ListTile(
                      leading: Icon(selected ? item.selectedIcon : item.icon,
                          color: selected ? Theme.of(context).colorScheme.primary : null),
                      title: Text(
                        item.label,
                        style: TextStyle(
                          fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                          color: selected ? Theme.of(context).colorScheme.primary : null,
                        ),
                      ),
                      selected: selected,
                      onTap: () => _select(i),
                    );
                  },
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Log out', style: TextStyle(color: Colors.red)),
                onTap: () {
                  AuthStore.instance.reset();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (route) => false,
                  );
                },
              ),
            ],
          ),
        ),
      ),
      body: IndexedStack(index: _index, children: _screens),
    );
  }
}

class _DrawerItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  const _DrawerItem({required this.icon, required this.selectedIcon, required this.label});
}

class _DrawerHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AuthStore.instance,
      builder: (context, _) {
        final verified = AuthStore.instance.isVerified;
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          color: Theme.of(context).colorScheme.primary.withOpacity(0.06),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.shield, size: 40, color: Colors.deepPurple),
              const SizedBox(height: 10),
              const Text('Sakhi', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    verified ? Icons.verified_user : Icons.gpp_maybe_outlined,
                    size: 14,
                    color: verified ? Colors.green : Colors.orange,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    verified ? 'Verified' : 'Not verified',
                    style: TextStyle(fontSize: 12, color: verified ? Colors.green : Colors.orange),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}