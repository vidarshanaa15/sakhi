import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../widgets/app_shell.dart';

class EmergencyContact {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  void dispose() {
    nameController.dispose();
    phoneController.dispose();
  }

  Map<String, dynamic> toJson() => {
        'name': nameController.text.trim(),
        'phone': phoneController.text.trim(),
      };
}

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _homeLocationController = TextEditingController();
  final _ageController = TextEditingController();

  String? _gender;
  final _genderOptions = const ['Female', 'Male', 'Other', 'Prefer not to say'];

  static const _interestOptions = [
    'Reading',
    'Fitness',
    'Travel',
    'Music',
    'Cooking',
    'Art',
    'Technology',
    'Sports',
    'Movies',
    'Volunteering',
  ];
  final Set<String> _selectedInterests = {};

  final List<EmergencyContact> _emergencyContacts = [EmergencyContact()];

  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _homeLocationController.dispose();
    _ageController.dispose();
    for (final c in _emergencyContacts) {
      c.dispose();
    }
    super.dispose();
  }

  String? _validateName(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Enter your name';
    return null;
  }

  String? _validatePhone(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Enter your phone number';
    return null;
  }

  String? _validateAge(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return null; // optional
    final age = int.tryParse(v);
    if (age == null || age <= 0 || age > 120) {
      return 'Enter a valid age';
    }
    return null;
  }

  void _addEmergencyContact() {
    setState(() {
      _emergencyContacts.add(EmergencyContact());
    });
  }

  void _removeEmergencyContact(int index) {
    setState(() {
      _emergencyContacts[index].dispose();
      _emergencyContacts.removeAt(index);
    });
  }

  Future<void> _handleSave() async {
    setState(() => _errorMessage = null);

    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      setState(() => _errorMessage = 'You are not signed in. Please log in again.');
      return;
    }

    setState(() => _isSubmitting = true);

    final contacts = _emergencyContacts
        .where((c) =>
            c.nameController.text.trim().isNotEmpty ||
            c.phoneController.text.trim().isNotEmpty)
        .map((c) => c.toJson())
        .toList();

    final age = _ageController.text.trim().isEmpty
        ? null
        : int.tryParse(_ageController.text.trim());

    try {
      await Supabase.instance.client.from('profiles').update({
        'name': _nameController.text.trim(),
        'phone_number': _phoneController.text.trim(),
        'home_location': _homeLocationController.text.trim(),
        'gender': _gender,
        'age': age,
        'interests': _selectedInterests.toList(),
        'emergency_contacts': contacts,
      }).eq('userid', user.id);

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AppShell()),
      );
    } on PostgrestException catch (e) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _errorMessage = e.message;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _errorMessage = 'Something went wrong. Please check your connection.';
      });
    }
  }

  void _handleSkip() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const AppShell()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete your profile'),
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
            onPressed: _isSubmitting ? null : _handleSkip,
            child: const Text('Skip for now'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tell us a bit about yourself so we can keep you safe.',
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),

              const SizedBox(height: 20),

              TextFormField(
                controller: _nameController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Full name',
                  border: OutlineInputBorder(),
                ),
                validator: _validateName,
              ),

              const SizedBox(height: 12),

              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Phone number',
                  border: OutlineInputBorder(),
                ),
                validator: _validatePhone,
              ),

              const SizedBox(height: 12),

              TextFormField(
                controller: _homeLocationController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Home location',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _gender,
                      decoration: const InputDecoration(
                        labelText: 'Gender',
                        border: OutlineInputBorder(),
                      ),
                      items: _genderOptions
                          .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                          .toList(),
                      onChanged: (value) => setState(() => _gender = value),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _ageController,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Age',
                        border: OutlineInputBorder(),
                      ),
                      validator: _validateAge,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              const Text(
                'Interests',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _interestOptions.map((interest) {
                  final selected = _selectedInterests.contains(interest);
                  return FilterChip(
                    label: Text(interest),
                    selected: selected,
                    onSelected: (isSelected) {
                      setState(() {
                        if (isSelected) {
                          _selectedInterests.add(interest);
                        } else {
                          _selectedInterests.remove(interest);
                        }
                      });
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Emergency contacts',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextButton.icon(
                    onPressed: _addEmergencyContact,
                    icon: const Icon(Icons.add),
                    label: const Text('Add'),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              ...List.generate(_emergencyContacts.length, (index) {
                final contact = _emergencyContacts[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: contact.nameController,
                          decoration: const InputDecoration(
                            labelText: 'Contact name',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: contact.phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            labelText: 'Contact phone',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      if (_emergencyContacts.length > 1)
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: () => _removeEmergencyContact(index),
                        ),
                    ],
                  ),
                );
              }),

              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 13),
                ),
              ],

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isSubmitting ? null : _handleSave,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Save and continue'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}