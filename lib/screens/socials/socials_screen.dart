import 'package:flutter/material.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme.dart';
import '../../models/social_content.dart';

/// Body content only — AppShell supplies the shared AppBar (edit action).
class SocialsScreen extends StatefulWidget {
  const SocialsScreen({super.key});

  @override
  State<SocialsScreen> createState() => _SocialsScreenState();
}

class _SocialsScreenState extends State<SocialsScreen> {
  bool _showBlogs = true;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        _SegmentedTabs(
          showBlogs: _showBlogs,
          onChanged: (value) => setState(() => _showBlogs = value),
        ),
        const SizedBox(height: AppSpacing.lg),
        if (_showBlogs) ...[
          ...mockBlogPosts.map((post) => _BlogCard(post: post)),
          const SizedBox(height: AppSpacing.lg),
        ],
        const _SectionLabel('POPULAR REELS'),
        const SizedBox(height: AppSpacing.sm),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: AppSpacing.sm,
          crossAxisSpacing: AppSpacing.sm,
          childAspectRatio: 0.85,
          children: mockReels.map((reel) => _ReelThumbnail(reel: reel)).toList(),
        ),
      ],
    );
  }
}

class _SegmentedTabs extends StatelessWidget {
  final bool showBlogs;
  final ValueChanged<bool> onChanged;
  const _SegmentedTabs({required this.showBlogs, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        border: Border.all(color: Colors.black.withOpacity(0.06)),
      ),
      child: Row(
        children: [
          Expanded(child: _TabButton(label: 'Featured Blogs', selected: showBlogs, onTap: () => onChanged(true))),
          Expanded(child: _TabButton(label: 'Short Reels', selected: !showBlogs, onTap: () => onChanged(false))),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _TabButton({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
        color: AppTheme.primary.withOpacity(0.75),
      ),
    );
  }
}

class _BlogCard extends StatelessWidget {
  final BlogPost post;
  const _BlogCard({required this.post});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: () {}, // TODO(backend): open full blog post
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 10,
              child: Image.network(post.coverImageUrl, fit: BoxFit.cover),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(post.title, style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      CircleAvatar(radius: 12, backgroundImage: NetworkImage(post.authorAvatarUrl)),
                      const SizedBox(width: 6),
                      Text('By ${post.author}', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                      const SizedBox(width: 8),
                      Text('•', style: TextStyle(color: AppTheme.textSecondary.withOpacity(0.5))),
                      const SizedBox(width: 8),
                      Text(post.readTime, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReelThumbnail extends StatelessWidget {
  final Reel reel;
  const _ReelThumbnail({required this.reel});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(reel.thumbnailUrl, fit: BoxFit.cover),
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: Colors.black.withOpacity(0.4), shape: BoxShape.circle),
              child: const Icon(Icons.play_arrow, color: Colors.white, size: 16),
            ),
          ),
          Positioned(
            bottom: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
              ),
              child: Text(reel.views, style: const TextStyle(color: Colors.white, fontSize: 11)),
            ),
          ),
        ],
      ),
    );
  }
}