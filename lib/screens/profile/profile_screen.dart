import 'package:flutter/material.dart';
import '../../core/state/settings_store.dart';
import '../../core/state/auth_store.dart';
import '../../models/user_profile.dart';
import '../auth/login_screen.dart';
import '../../widgets/section_header.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = mockUserProfile;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // --- Header ---
          Row(
            children: [
              CircleAvatar(radius: 32, backgroundImage: NetworkImage(user.avatarUrl)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.name, style: Theme.of(context).textTheme.titleLarge),
                    Text(user.email, style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () {}, // edit profile — wire to backend later
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Reads live from AuthStore — flips to "Verified via DigiLocker"
          // the moment AadhaarVerifyScreen calls markVerified(), no
          // separate wiring needed on this screen beyond this listener.
          ListenableBuilder(
            listenable: AuthStore.instance,
            builder: (context, _) {
              final verified = AuthStore.instance.isVerified;
              return Chip(
                avatar: Icon(
                  verified ? Icons.verified_user : Icons.gpp_maybe_outlined,
                  size: 18,
                  color: verified ? Colors.green : Colors.orange,
                ),
                label: Text(verified ? 'Verified via DigiLocker' : 'Identity not verified'),
                backgroundColor: (verified ? Colors.green : Colors.orange).withOpacity(0.1),
              );
            },
          ),

          const SizedBox(height: 24),
          SectionHeader('Emergency Contacts'),
          ...user.emergencyContacts.map(
                (c) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: const Icon(Icons.contact_phone_outlined),
                title: Text(c.name),
                subtitle: Text(c.phone),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {}, // edit contact — later
              ),
            ),
          ),
          OutlinedButton.icon(
            onPressed: () {}, // add contact — later
            icon: const Icon(Icons.add),
            label: const Text('Add emergency contact'),
          ),

          const SizedBox(height: 24),
          SectionHeader('Safety Settings'),
          ListenableBuilder(
            listenable: SettingsStore.instance,
            builder: (context, _) {
              final s = SettingsStore.instance;
              return Card(
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Share live location'),
                      subtitle: const Text('With emergency contacts during trips'),
                      value: s.locationSharingEnabled,
                      onChanged: s.setLocationSharing,
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      title: const Text('Push notifications'),
                      subtitle: const Text('Safety alerts and trip updates'),
                      value: s.notificationsEnabled,
                      onChanged: s.setNotifications,
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      title: const Text('Offline distress alerts'),
                      subtitle: const Text('Use LoRa pendant when no network is available'),
                      value: s.offlineAlertsEnabled,
                      onChanged: s.setOfflineAlerts,
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 24),
          SectionHeader('Device'),
          Card(
            child: ListTile(
              leading: const Icon(Icons.watch_outlined),
              title: const Text('Safety pendant'),
              subtitle: const Text('Not paired'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {}, // BLE pairing flow — later, once hardware team's ready
            ),
          ),

          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
              onPressed: () {
                // Clear verification state on logout so a different user
                // logging in on this device doesn't inherit it.
                AuthStore.instance.reset();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                );
              },
              icon: const Icon(Icons.logout),
              label: const Text('Log out'),
            ),
          ),
        ],
      ),
    );
  }
}