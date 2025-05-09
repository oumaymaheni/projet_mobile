import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/maison_models.dart';
import 'package:firebase_auth/firebase_auth.dart';


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

  static Future<List<House>> getHousesByPublisher(String publisherId) async {
    try {
      final query = await _houseRef
          .where('publisher', isEqualTo: publisherId)
          .orderBy('createdAt', descending: true)
          .get();
      return query.docs.map((doc) => House.fromMap(doc.id, doc.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      throw 'Erreur de requête: $e';
    }
  }

  /// Récupère uniquement les annonces de l'utilisateur connecté
  static Future<List<House>> getUserHouses() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw 'Utilisateur non connecté';

      // Requête avec index
      final query = await _houseRef
          .where('publisher', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true)
          .get();

      return query.docs
          .map((doc) => House.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw 'Erreur de chargement: $e';
    }
  }

  static Future<void> updateHouse(String houseId, Map<String, dynamic> updates) async {
    await _houseRef.doc(houseId).update(updates);
  }
}
