import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_front/maison/house_details.dart';
import 'package:flutter_front/widgets/bottom_navigation_widget.dart';
import '../models/maison_models.dart';
import '../services/firebase_service.dart';
import 'edit_house_screen.dart';

class MyAdsPage extends StatefulWidget {
  const MyAdsPage({Key? key}) : super(key: key);

  @override
  State<MyAdsPage> createState() => _MyAdsPageState();
}

class _MyAdsPageState extends State<MyAdsPage> {
  final Color primaryBlue = const Color(0xFF2979FF);
  List<House> _myHouses = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUserHouses();
  }

  Future<void> _loadUserHouses() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw 'Veuillez vous connecter pour voir vos annonces';
      }

      final houses = await FirebaseService.getHousesByPublisher(user.uid);

      setState(() {
        _myHouses = houses;
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Annonces'),
        // backgroundColor: primaryBlue,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: _buildContent(),
      bottomNavigationBar: HomeBottomNavigationBar(
        currentIndex: 3, // Mes annonces est à l'index 3
        primaryBlue: primaryBlue,
        onTap: (int index) {
          // Navigue selon l'index sélectionné
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/home');
              break;
            case 1:
              Navigator.pushReplacementNamed(context, '/search');
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/favorites');
              break;
            case 3:
              // Déjà sur la page mes annonces, ne rien faire
              break;
            case 4:
              Navigator.pushReplacementNamed(context, '/userProfile');
              break;
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed:
            () => Navigator.pushNamed(
              context,
              '/post-house',
            ).then((_) => _loadUserHouses()),
        backgroundColor: primaryBlue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 50, color: Colors.red),
            const SizedBox(height: 20),
            Text(
              _errorMessage!,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadUserHouses,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    if (_myHouses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.list_alt, size: 50, color: Colors.grey),
            const SizedBox(height: 20),
            const Text(
              'Vous n\'avez aucune annonce',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed:
                  () => Navigator.pushNamed(
                    context,
                    '/post-house',
                  ).then((_) => _loadUserHouses()),
              child: const Text('Créer une annonce'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _myHouses.length,
      itemBuilder:
          (context, index) => _HouseCard(
            house: _myHouses[index],
            onDelete: _deleteHouse,
            onEdit: _editHouse,
            primaryColor: primaryBlue,
          ),
    );
  }

  Future<void> _deleteHouse(String houseId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirmer la suppression'),
            content: const Text(
              'Voulez-vous vraiment supprimer cette annonce ?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Annuler'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Supprimer',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      try {
        await FirebaseService.deleteHouse(houseId);
        setState(() {
          _myHouses.removeWhere((house) => house.id == houseId);
        });

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Annonce supprimée avec succès')),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la suppression: $e')),
        );
      }
    }
  }

  Future<void> _editHouse(House house) async {
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => EditHouseScreen(house: house)),
    );

    if (updated == true) {
      _loadUserHouses(); // Rafraîchir la liste après modification
    }
  }
}

class _HouseCard extends StatelessWidget {
  final House house;
  final Function(String) onDelete;
  final Function(House) onEdit;
  final Color primaryColor;

  const _HouseCard({
    required this.house,
    required this.onDelete,
    required this.onEdit,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          // Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Container(
              height: 180,
              width: double.infinity,
              color: const Color.fromRGBO(238, 238, 238, 1),
              child:
                  house.imageUrls.isNotEmpty
                      ? Image.network(
                        house.imageUrls[0],
                        fit: BoxFit.cover,
                        errorBuilder:
                            (_, __, ___) => const Icon(Icons.home, size: 50),
                      )
                      : const Icon(Icons.home, size: 50),
            ),
          ),
          // Details
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  house.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        house.address,
                        style: TextStyle(color: Colors.grey.shade600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.king_bed, size: 20, color: primaryColor),
                        const SizedBox(width: 4),
                        Text('${house.bedrooms}'),
                        const SizedBox(width: 16),
                        Icon(Icons.bathtub, size: 20, color: primaryColor),
                        const SizedBox(width: 4),
                        Text('${house.bathrooms}'),
                        const SizedBox(width: 16),
                        Icon(Icons.square_foot, size: 20, color: primaryColor),
                        const SizedBox(width: 4),
                        Text('${house.surface} m²'),
                      ],
                    ),
                    Text(
                      '${house.price} DT',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildActionButton(Icons.edit, 'Modifier', () {
                      onEdit(house);
                    }),
                    _buildActionButton(Icons.delete, 'Supprimer', () {
                      onDelete(house.id);
                    }),
                    _buildActionButton(Icons.visibility, 'Détails', () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => PropertyDetailPage(
                                house: house,
                                showContactButton:
                                    false, // Désactive le bouton contact
                              ),
                        ),
                      );
                    }),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    IconData icon,
    String label,
    VoidCallback onPressed,
  ) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: TextButton.styleFrom(foregroundColor: Colors.grey.shade700),
    );
  }
}
