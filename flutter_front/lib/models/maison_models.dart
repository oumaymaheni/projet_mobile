import 'package:cloud_firestore/cloud_firestore.dart';

class House {
  final String id;
  final String title;
  final String address;
  final int price;
  final int bedrooms;
  final int bathrooms;
  final int surface;
  final List<String> imageUrls;
  final double rating;
  bool isFavorite;
  final String locality;
  final String city;
  final String state;
  final String? pinCode;
  final String houseNo;
  final String society;
  final double latitude;
  final double longitude;
  final DateTime createdAt;
  final String publisher;
  final String propertyType;
  final String description;


 House({
  required this.id,
  required this.title,
  required this.address,
  required this.price,
  required this.bedrooms,
  required this.bathrooms,
  required this.surface,
  required this.imageUrls,
  required this.rating,
  required this.isFavorite,
  required this.locality,
  required this.city,
  required this.state,
  this.pinCode,
  required this.houseNo,
  required this.society,
  required this.latitude,
  required this.longitude,
  required this.createdAt,
  required this.publisher,
  this.propertyType = 'House',

  this.description = '',

});


  factory House.fromMap(String id, Map<String, dynamic> data) {
    return House(
      id: id,
      title: data['title'] ?? '',
      address: data['address'] ?? '',
      price: data['price'] ?? 0,
      bedrooms: data['bedrooms'] ?? 0,
      bathrooms: data['bathrooms'] ?? 0,
      surface: data['surface'] ?? 0,
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      rating: (data['rating'] ?? 0).toDouble(),
      isFavorite: data['isFavorite'] ?? false,
      locality: data['locality'] ?? '',
      city: data['city'] ?? '',
      state: data['state'] ?? '',
      pinCode: data['pinCode'],
      houseNo: data['houseNo'] ?? '',
      society: data['society'] ?? '',
      latitude: (data['location']?['_latitude'] ?? 0.0).toDouble(),
      longitude: (data['location']?['_longitude'] ?? 0.0).toDouble(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      publisher: data['publisher'] ?? '',
      propertyType: data['propertyType'] ?? 'House',
      description: data['description'] ?? '',

    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'address': address,
      'price': price,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'surface': surface,
      'imageUrls': imageUrls,
      'rating': rating,
      'isFavorite': isFavorite,
      'locality': locality,
      'city': city,
      'state': state,
      if (pinCode != null) 'pinCode': pinCode,
      'houseNo': houseNo,
      'society': society,
      'location': {'_latitude': latitude, '_longitude': longitude},
      'createdAt': Timestamp.fromDate(createdAt),
      'publisher': publisher,
      'propertyType': propertyType,

      // Nouveaux champs
      'description': description,
    };
  }
}
