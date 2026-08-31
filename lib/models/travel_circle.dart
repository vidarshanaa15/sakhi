class TravelCircle {
  final String id;
  final String name;
  final String location;
  final int memberCount;
  final String imageUrl;
  final String activityLabel; // e.g. "3 Active Chat Threads" or "Weekly safe-homestay meetups"

  const TravelCircle({
    required this.id,
    required this.name,
    required this.location,
    required this.memberCount,
    required this.imageUrl,
    required this.activityLabel,
  });
}

// Mock data until community API is ready.
final List<TravelCircle> mockYourCircles = [
  const TravelCircle(
    id: 'c1',
    name: 'Rajasthan Solo Sakhis',
    location: 'Jaipur',
    memberCount: 142,
    imageUrl: 'https://i.ibb.co/nNXGy92s/campfire.jpg',
    activityLabel: '3 Active Chat Threads',
  ),
];

final List<TravelCircle> mockSuggestedCircles = [
  const TravelCircle(
    id: 'c2',
    name: 'Gokarna Beach Trekkers',
    location: 'Gokarna',
    memberCount: 89,
    imageUrl: 'https://i.ibb.co/h1J89rDn/rocks.jpg',
    activityLabel: 'Weekly safe-homestay meetups',
  ),
];