// import 'package:flutter/material.dart';
// import '../../models/community.dart';
// import '../../services/community_service.dart';
// import '../../core/state/auth_store.dart';
// import '../../widgets/empty_state.dart';
// import 'community_detail_screen.dart';
// import 'create_community_screen.dart';

// class CommunityListScreen extends StatefulWidget {
//   const CommunityListScreen({super.key});

//   @override
//   State<CommunityListScreen> createState() => _CommunityListScreenState();
// }

// class _CommunityListScreenState extends State<CommunityListScreen>
//     with SingleTickerProviderStateMixin {
//   late final TabController _tabController;

//   List<Community> _myCommunities = [];
//   List<Community> _publicCommunities = [];
//   bool _isLoading = true;
//   String? _error;

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 2, vsync: this);
//     _loadCommunities();
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   Future<void> _loadCommunities() async {
//     setState(() {
//       _isLoading = true;
//       _error = null;
//     });

//     try {
//       final userId = AuthStore.instance.user?.id;
//       final results = await Future.wait([
//         if (userId != null)
//           CommunityService.fetchMyCommunities(userId)
//         else
//           Future.value(<Community>[]),
//         CommunityService.fetchPublicCommunities(),
//       ]);

//       if (!mounted) return;

//       setState(() {
//         _myCommunities = results[0];
//         _publicCommunities = results[1];
//         _isLoading = false;
//       });
//     } catch (e) {
//       if (!mounted) return;
//       setState(() {
//         _isLoading = false;
//         _error = 'Could not load communities. Pull down to retry.';
//       });
//     }
//   }

//   Future<void> _handleJoinByCode() async {
//     final controller = TextEditingController();

//     final code = await showDialog<String>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Join private community'),
//         content: TextField(
//           controller: controller,
//           textCapitalization: TextCapitalization.characters,
//           decoration: const InputDecoration(
//             labelText: 'Invite code',
//             border: OutlineInputBorder(),
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           FilledButton(
//             onPressed: () => Navigator.pop(context, controller.text.trim()),
//             child: const Text('Join'),
//           ),
//         ],
//       ),
//     );

//     if (code == null || code.isEmpty) return;
//     if (!mounted) return;

//     try {
//       await CommunityService.joinPrivateCommunity(code);
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Joined community!')),
//       );
//       _loadCommunities();
//     } catch (e) {
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Invalid invite code.')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Community'),
//         bottom: TabBar(
//           controller: _tabController,
//           tabs: const [
//             Tab(text: 'My Groups'),
//             Tab(text: 'Discover'),
//           ],
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.vpn_key_outlined),
//             tooltip: 'Join with invite code',
//             onPressed: _handleJoinByCode,
//           ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton.extended(
//         onPressed: () async {
//           final created = await Navigator.push<bool>(
//             context,
//             MaterialPageRoute(builder: (_) => const CreateCommunityScreen()),
//           );
//           if (created == true) _loadCommunities();
//         },
//         icon: const Icon(Icons.add),
//         label: const Text('New group'),
//       ),
//       body: RefreshIndicator(
//         onRefresh: _loadCommunities,
//         child: _isLoading
//             ? const Center(child: CircularProgressIndicator())
//             : _error != null
//                 ? Center(child: Text(_error!))
//                 : TabBarView(
//                     controller: _tabController,
//                     children: [
//                       _buildCommunityList(_myCommunities, isMine: true),
//                       _buildCommunityList(_publicCommunities, isMine: false),
//                     ],
//                   ),
//       ),
//     );
//   }

//   Widget _buildCommunityList(List<Community> communities, {required bool isMine}) {
//     if (communities.isEmpty) {
//       return ListView(
//         children: [
//           EmptyState(
//             icon: Icons.groups_outlined,
//             message: isMine
//                 ? "You haven't joined any groups yet.\nExplore the Discover tab to find one."
//                 : 'No public groups yet.\nBe the first to create one.',
//           ),
//         ],
//       );
//     }

//     return ListView.separated(
//       padding: const EdgeInsets.all(16),
//       itemCount: communities.length,
//       separatorBuilder: (_, __) => const SizedBox(height: 8),
//       itemBuilder: (context, index) {
//         final community = communities[index];
//         return Card(
//           child: ListTile(
//             leading: CircleAvatar(
//               child: Icon(
//                 community.isPrivate ? Icons.lock_outline : Icons.groups_outlined,
//               ),
//             ),
//             title: Text(community.name),
//             subtitle: Text(
//               community.city != null
//                   ? '${community.city} · ${community.description ?? ''}'
//                   : community.description ?? '',
//               maxLines: 1,
//               overflow: TextOverflow.ellipsis,
//             ),
//             trailing: const Icon(Icons.chevron_right),
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (_) => CommunityDetailScreen(community: community),
//                 ),
//               ).then((_) => _loadCommunities());
//             },
//           ),
//         );
//       },
//     );
//   }
// }