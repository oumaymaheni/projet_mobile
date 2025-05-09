import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/maison_models.dart';

class FirebaseService {
  static final _houseRef = FirebaseFirestore.instance.collection('house_ads');

  /// 🔼 Ajouter une maison
  static Future<void> addHouse(House house) async {
    await _houseRef.doc(house.id).set(house.toMap());
  }

  /// 🔽 Récupérer toutes les maisons
  static Future<List<House>> getHouses() async {
    final snapshot = await _houseRef.orderBy('createdAt', descending: true).get();
    return snapshot.docs.map((doc) => House.fromMap(doc.id, doc.data())).toList();
  }

  /// 🔍 Récupérer une maison par ID
  static Future<House?> getHouseById(String id) async {
    final doc = await _houseRef.doc(id).get();
    if (!doc.exists) return null;
    return House.fromMap(doc.id, doc.data()!);
  }

  /// 🗑 Supprimer une maison
  static Future<void> deleteHouse(String id) async {
    await _houseRef.doc(id).delete();
  }
  
  static Future<void> updateHouseFavoriteStatus(String houseId, bool isFavorite) async {
  try {
    await _houseRef.doc(houseId).update({'isFavorite': isFavorite});
    print('Favorite status updated successfully');
  } catch (e) {
    print('Error updating favorite status: $e');
    throw e;
  }
}

}

