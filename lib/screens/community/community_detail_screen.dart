import 'package:flutter/material.dart';
import '../../models/community.dart';
import '../../services/community_service.dart';
import '../../core/state/auth_store.dart';
import 'community_chat_screen.dart';

class CommunityDetailScreen extends StatefulWidget {
  final Community community;

  const CommunityDetailScreen({super.key, required this.community});

  @override
  State<CommunityDetailScreen> createState() => _CommunityDetailScreenState();
}

class _CommunityDetailScreenState extends State<CommunityDetailScreen> {
  bool _isMember = false;
  bool _isLoading = true;
  bool _isSubmitting = false;
  int _memberCount = 0;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMembershipStatus();
  }

  Future<void> _loadMembershipStatus() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final userId = AuthStore.instance.user?.id;
      final results = await Future.wait([
        if (userId != null)
          CommunityService.isMember(widget.community.id, userId)
        else
          Future.value(false),
        CommunityService.memberCount(widget.community.id),
      ]);

      if (!mounted) return;

      setState(() {
        _isMember = results[0] as bool;
        _memberCount = results[1] as int;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = 'Could not load community details.';
      });
    }
  }

  Future<void> _handleJoin() async {
    setState(() => _isSubmitting = true);

    try {
      await CommunityService.joinPublicCommunity(widget.community.id);
      if (!mounted) return;
      setState(() {
        _isMember = true;
        _memberCount += 1;
        _isSubmitting = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not join. Please try again.')),
      );
    }
  }

  Future<void> _handleLeave() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave group?'),
        content: Text('You will stop receiving messages from ${widget.community.name}.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Leave'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    if (!mounted) return;

    setState(() => _isSubmitting = true);

    try {
      await CommunityService.leaveCommunity(widget.community.id);
      if (!mounted) return;
      setState(() {
        _isMember = false;
        _memberCount = (_memberCount - 1).clamp(0, _memberCount);
        _isSubmitting = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not leave. Please try again.')),
      );
    }
  }

  void _openChat() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CommunityChatScreen(community: widget.community),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final community = widget.community;

    return Scaffold(
      appBar: AppBar(title: Text(community.name)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    CircleAvatar(
                      radius: 40,
                      child: Icon(
                        community.isPrivate
                            ? Icons.lock_outline
                            : Icons.groups_outlined,
                        size: 36,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      community.name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (community.city != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        community.city!,
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.people_outline, size: 18, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Text('$_memberCount members'),
                      ],
                    ),
                    if (community.description != null) ...[
                      const SizedBox(height: 16),
                      Text(community.description!),
                    ],
                    const SizedBox(height: 24),
                    if (_isMember)
                      Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: _openChat,
                              icon: const Icon(Icons.chat_bubble_outline),
                              label: const Text('Open chat'),
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: _isSubmitting ? null : _handleLeave,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                              ),
                              child: _isSubmitting
                                  ? const SizedBox(
                                      height: 18,
                                      width: 18,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Text('Leave group'),
                            ),
                          ),
                        ],
                      )
                    else if (!community.isPrivate)
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _isSubmitting ? null : _handleJoin,
                          child: _isSubmitting
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Join group'),
                        ),
                      )
                    else
                      const Text(
                        'This is a private group. You need an invite code to join.',
                        style: TextStyle(color: Colors.grey),
                      ),
                  ],
                ),
    );
  }
}