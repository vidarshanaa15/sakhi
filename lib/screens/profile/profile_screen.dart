import 'package:flutter/material.dart';
import '../../core/state/settings_store.dart';
import '../../core/state/auth_store.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme.dart';
import '../../models/user_profile.dart';
import '../auth/login_screen.dart';
import '../../widgets/section_header.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = mockUserProfile;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: AppTheme.background,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.md,
          AppSpacing.xxl,
        ),
        children: [
          // Profile header
          Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundImage: NetworkImage(user.avatarUrl),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      user.email,
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                color: AppTheme.primary,
                onPressed: () {},
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // Verification
          ListenableBuilder(
            listenable: AuthStore.instance,
            builder: (context, _) {
              final verified = AuthStore.instance.isVerified;

              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm + 2,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: verified
                      ? AppTheme.safetyGreen.withOpacity(0.08)
                      : AppTheme.accent.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(
                    AppSpacing.radiusPill,
                  ),
                  border: Border.all(
                    color: verified
                        ? AppTheme.safetyGreen.withOpacity(0.16)
                        : AppTheme.accent.withOpacity(0.16),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      verified
                          ? Icons.verified_user_outlined
                          : Icons.gpp_maybe_outlined,
                      size: 17,
                      color: verified
                          ? AppTheme.safetyGreen
                          : AppTheme.accent,
                    ),
                    const SizedBox(width: 7),
                    Text(
                      verified
                          ? 'Verified via DigiLocker'
                          : 'Identity not verified',
                      style: TextStyle(
                        color: verified
                            ? AppTheme.safetyGreen
                            : AppTheme.accent,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: AppSpacing.xl),

          SectionHeader('Emergency Contacts'),
          const SizedBox(height: AppSpacing.sm),

          ...user.emergencyContacts.map(
                (c) => Card(
              margin: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.07),
                    borderRadius: BorderRadius.circular(
                      AppSpacing.radiusSm,
                    ),
                  ),
                  child: const Icon(
                    Icons.contact_phone_outlined,
                    color: AppTheme.primary,
                    size: 20,
                  ),
                ),
                title: Text(
                  c.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                subtitle: Text(
                  c.phone,
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
                trailing: const Icon(
                  Icons.chevron_right_rounded,
                  color: AppTheme.textSecondary,
                ),
                onTap: () {},
              ),
            ),
          ),

          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add),
            label: const Text('Add emergency contact'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.primary,
              side: BorderSide(
                color: AppTheme.primary.withOpacity(0.3),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  AppSpacing.radiusSm,
                ),
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          SectionHeader('Safety Settings'),
          const SizedBox(height: AppSpacing.sm),

          ListenableBuilder(
            listenable: SettingsStore.instance,
            builder: (context, _) {
              final s = SettingsStore.instance;

              return Card(
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Share live location'),
                      subtitle: const Text(
                        'With emergency contacts during trips',
                      ),
                      value: s.locationSharingEnabled,
                      onChanged: s.setLocationSharing,
                      activeColor: AppTheme.accent,
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      title: const Text('Push notifications'),
                      subtitle: const Text(
                        'Safety alerts and trip updates',
                      ),
                      value: s.notificationsEnabled,
                      onChanged: s.setNotifications,
                      activeColor: AppTheme.accent,
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      title: const Text('Offline distress alerts'),
                      subtitle: const Text(
                        'Use LoRa pendant when no network is available',
                      ),
                      value: s.offlineAlertsEnabled,
                      onChanged: s.setOfflineAlerts,
                      activeColor: AppTheme.accent,
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: AppSpacing.xl),

          SectionHeader('Device'),
          const SizedBox(height: AppSpacing.sm),

          Card(
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(
                    AppSpacing.radiusSm,
                  ),
                ),
                child: const Icon(
                  Icons.watch_outlined,
                  color: AppTheme.primary,
                ),
              ),
              title: const Text(
                'Safety pendant',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              subtitle: Text(
                'Not paired',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                ),
              ),
              trailing: const Icon(
                Icons.chevron_right_rounded,
                color: AppTheme.textSecondary,
              ),
              onTap: () {},
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.safetyRed,
                side: BorderSide(
                  color: AppTheme.safetyRed.withOpacity(0.25),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.md,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AppSpacing.radiusSm,
                  ),
                ),
              ),
              onPressed: () {
                AuthStore.instance.reset();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LoginScreen(),
                  ),
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