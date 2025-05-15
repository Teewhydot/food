class Restaurant {
  final String id;
  final String name;
  final String imageUrl;
  final String description;
  final List<String> categories;
  final double rating;
  final int reviewCount;

  Restaurant({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.description,
    required this.categories,
    required this.rating,
    required this.reviewCount,
  });
}
