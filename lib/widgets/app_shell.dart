import 'package:flutter/material.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/search/search_screen.dart';
import '../screens/chatbot/chatbot_screen.dart';
import '../screens/itinerary/itinerary_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/drawer_stub_screens.dart';
import '../core/state/auth_store.dart';
import '../core/state/sos_store.dart';
import '../core/state/evidence_store.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/app_spacing.dart';
import '../screens/auth/login_screen.dart';
import 'sos_button.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    SosStore.instance.loadContacts();
    EvidenceStore.instance.load();
  }

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
    Navigator.pop(context);
    setState(() => _index = i);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _drawerItems[_index].label,
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
      ),
      drawer: Drawer(
        backgroundColor: AppTheme.background,
        child: SafeArea(
          child: Column(
            children: [
              const _DrawerHeader(),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  itemCount: _drawerItems.length,
                  itemBuilder: (context, i) {
                    final item = _drawerItems[i];
                    final selected = i == _index;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
                      child: Material(
                        color: selected ? AppTheme.primary.withOpacity(0.08) : Colors.transparent,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                        child: ListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                          ),
                          leading: Icon(
                            selected ? item.selectedIcon : item.icon,
                            color: selected ? AppTheme.primary : AppTheme.textSecondary,
                          ),
                          title: Text(
                            item.label,
                            style: TextStyle(
                              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                              color: selected ? AppTheme.primary : AppTheme.textPrimary,
                            ),
                          ),
                          onTap: () => _select(i),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Divider(height: 1, color: Colors.black.withOpacity(0.06)),
              ListTile(
                leading: const Icon(Icons.logout, color: AppTheme.safetyRed),
                title: const Text('Log out', style: TextStyle(color: AppTheme.safetyRed, fontWeight: FontWeight.w500)),
                onTap: () {
                  AuthStore.instance.reset();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (route) => false,
                  );
                },
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
          ),
        ),
      ),
      body: IndexedStack(index: _index, children: _screens),
      floatingActionButton: const SosButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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
  const _DrawerHeader();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AuthStore.instance,
      builder: (context, _) {
        final verified = AuthStore.instance.isVerified;
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppTheme.primary.withOpacity(0.06),
            border: Border(bottom: BorderSide(color: Colors.black.withOpacity(0.06))),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: const Icon(Icons.shield, size: 24, color: Colors.white),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Sakhi',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: (verified ? AppTheme.safetyGreen : AppTheme.accent).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      verified ? Icons.verified_user : Icons.gpp_maybe_outlined,
                      size: 13,
                      color: verified ? AppTheme.safetyGreen : AppTheme.accent,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      verified ? 'Verified' : 'Not verified',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: verified ? AppTheme.safetyGreen : AppTheme.accent,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}