class House {
  final String id;
  final String title;
  final String address;
  final int price;
  final int bedrooms;
  final int bathrooms;
  final int surface;
  final String imageUrl;
  final double rating;
  final bool isFavorite;

  House({
    required this.id,
    required this.title,
    required this.address,
    required this.price,
    required this.bedrooms,
    required this.bathrooms,
    required this.surface,
    required this.imageUrl,
    required this.rating,
    required this.isFavorite,
  });
}