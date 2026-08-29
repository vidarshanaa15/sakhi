class EmergencyContact {
  final String name;
  final String phone;
  const EmergencyContact({required this.name, required this.phone});
}

class UserProfile {
  final String name;
  final String email;
  final String avatarUrl;
  final List<EmergencyContact> emergencyContacts;

  const UserProfile({
    required this.name,
    required this.email,
    required this.avatarUrl,
    required this.emergencyContacts,
  });
}

// Mock data until backend/auth is wired up.
final mockUserProfile = UserProfile(
  name: 'Sandhya G.',
  email: 'sandhya@example.com',
  avatarUrl: 'https://i.pravatar.cc/150?img=47',
  emergencyContacts: const [
    EmergencyContact(name: 'Amma', phone: '+91 98765 43210'),
    EmergencyContact(name: 'Roommate - Priya', phone: '+91 91234 56789'),
  ],
);