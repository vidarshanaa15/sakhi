class BlogPost {
  final String id;
  final String title;
  final String author;
  final String authorAvatarUrl;
  final String coverImageUrl;
  final String readTime;

  const BlogPost({
    required this.id,
    required this.title,
    required this.author,
    required this.authorAvatarUrl,
    required this.coverImageUrl,
    required this.readTime,
  });
}

class Reel {
  final String id;
  final String thumbnailUrl;
  final String views;

  const Reel({required this.id, required this.thumbnailUrl, required this.views});
}

// Mock data until socials/content API is ready.
final List<BlogPost> mockBlogPosts = [
  const BlogPost(
    id: 'b1',
    title: 'Safe, Solitary, and Serene: My 5 Days in Munnar tea valleys',
    author: 'Ritika Sen',
    authorAvatarUrl: 'https://i.pravatar.cc/100?img=32',
    coverImageUrl: 'https://i.ibb.co/nsGhdbwB/munnarblog.jpg',
    readTime: '4 min read',
  ),
];

final List<Reel> mockReels = [
  const Reel(id: 'r1', thumbnailUrl: 'https://i.ibb.co/F4V54bL2/reelbeach.jpg', views: '12k views'),
  const Reel(id: 'r2', thumbnailUrl: 'https://i.ibb.co/gbL35vLy/reelstreet.jpg', views: '45k views'),
];