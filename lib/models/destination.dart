class Destination {
  final String id;
  final String name;
  final String imageUrl;
  final double safetyScore; // 0-10
  final String description;
  final bool isHiddenGem;

  const Destination({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.safetyScore,
    required this.description,
    this.isHiddenGem = false,
  });
}

// Mock data until the backend endpoint is ready.
final List<Destination> mockDestinations = [
  const Destination(
    id: '1',
    name: 'Munnar, Kerala',
    imageUrl: 'https://i.ibb.co/jPNGRZDy/munnar.jpg',
    safetyScore: 8.7,
    description: 'Tea plantations and hill trails, well-trodden and well-lit.',
  ),
  const Destination(
    id: '2',
    name: 'Chopta, Uttarakhand',
    imageUrl: 'https://i.ibb.co/gLPF8HSm/chopta.jpg',
    safetyScore: 7.9,
    description: 'A quieter Himalayan trek base with growing solo-traveler reviews.',
    isHiddenGem: true,
  ),
  const Destination(
    id: '3',
    name: 'Gokarna, Karnataka',
    imageUrl: 'https://i.ibb.co/cKsKHpCq/gokarna.jpg',
    safetyScore: 7.2,
    description: 'Beach town with mixed reports — safer in the main beach cluster.',
  ),
];