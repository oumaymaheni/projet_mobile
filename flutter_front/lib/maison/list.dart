import 'package:flutter/material.dart';
import '../models/maison_models.dart';
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Définition des couleurs thématiques
  final Color primaryBlue = const Color(0xFF1E88E5); // Bleu principal
  final Color accentOrange = const Color(0xFFFF9800); // Orange accent
  final Color lightBlue = const Color(0xFFBBDEFB); // Bleu clair pour fond

  // Liste des maisons à louer (exemple)
  final List<House> _houses = [
    House(
      id: '1',
      title: 'Villa moderne avec piscine',
      address: '123 Rue des Fleurs, Paris',
      price: 1500,
      bedrooms: 4,
      bathrooms: 2,
      surface: 180,
      imageUrl: 'https://example.com/house1.jpg',
      rating: 4.8,
      isFavorite: false,
    ),
    House(
      id: '2',
      title: 'Appartement au centre-ville',
      address: '45 Avenue Victor Hugo, Lyon',
      price: 900,
      bedrooms: 2,
      bathrooms: 1,
      surface: 75,
      imageUrl: 'https://example.com/house2.jpg',
      rating: 4.2,
      isFavorite: true,
    ),
    House(
      id: '3',
      title: 'Maison de campagne',
      address: '8 Chemin des Vignes, Bordeaux',
      price: 1200,
      bedrooms: 3,
      bathrooms: 2,
      surface: 150,
      imageUrl: 'https://example.com/house3.jpg',
      rating: 4.5,
      isFavorite: false,
    ),
    House(
      id: '4',
      title: 'Loft industriel rénové',
      address: '29 Rue de la République, Marseille',
      price: 1100,
      bedrooms: 2,
      bathrooms: 1,
      surface: 95,
      imageUrl: 'https://example.com/house4.jpg',
      rating: 4.3,
      isFavorite: false,
    ),
    House(
      id: '5',
      title: 'Chalet en montagne',
      address: '12 Route des Alpes, Chamonix',
      price: 2000,
      bedrooms: 5,
      bathrooms: 3,
      surface: 220,
      imageUrl: 'https://example.com/house5.jpg',
      rating: 4.9,
      isFavorite: true,
    ),
  ];

  // Filtres
  String _selectedFilter = 'Tous';
  final List<String> _filters = ['Tous', 'Populaires', 'Récents', 'Prix bas', 'Prix élevé'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBlue.withOpacity(0.3),
      appBar: AppBar(
        backgroundColor: primaryBlue,
        elevation: 0,
        title: Text(
          'ImmoLoc',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.person_outline, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête avec recherche
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              decoration: BoxDecoration(
                color: primaryBlue,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Trouvez votre\nmaison idéale',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Rechercher une maison',
                        prefixIcon: Icon(Icons.search, color: primaryBlue),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            
            // Filtres horizontaux
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Catégories',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 10),
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16),
                itemCount: _filters.length,
                itemBuilder: (context, index) {
                  final filter = _filters[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(filter),
                      selected: _selectedFilter == filter,
                      onSelected: (selected) {
                        setState(() {
                          _selectedFilter = filter;
                        });
                      },
                      selectedColor: accentOrange,
                      backgroundColor: Colors.white,
                      checkmarkColor: Colors.white,
                      labelStyle: TextStyle(
                        color: _selectedFilter == filter ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: _selectedFilter == filter ? accentOrange : Colors.grey.shade300,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            
            // Maisons recommandées
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Maisons recommandées',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'Voir tout',
                      style: TextStyle(color: accentOrange),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            SizedBox(
              height: 300,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16),
                itemCount: _houses.length,
                itemBuilder: (context, index) {
                  final house = _houses[index];
                  return _featuredHouseCard(house);
                },
              ),
            ),
            SizedBox(height: 20),
            
            // Maisons à proximité
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Maisons à proximité',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'Voir tout',
                      style: TextStyle(color: accentOrange),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 16),
              itemCount: _houses.length,
              itemBuilder: (context, index) {
                final house = _houses[index];
                return _houseListItem(house);
              },
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: primaryBlue,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Rechercher',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            label: 'Favoris',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message_outlined),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  // Widget pour une carte de maison dans la section "recommandées"
  Widget _featuredHouseCard(House house) {
    return Container(
      width: 240,
      margin: EdgeInsets.only(right: 16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image de la maison
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                  child: Container(
                    height: 150,
                    width: double.infinity,
                    color: Colors.grey.shade300, // Fallback color
                    child: Image.network(
                      house.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Icon(Icons.home, size: 50, color: Colors.grey.shade500),
                        );
                      },
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: InkWell(
                    onTap: () {
                      // Logique pour ajouter/retirer des favoris
                    },
                    child: Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        house.isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: house.isFavorite ? Colors.red : Colors.grey,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Informations de la maison
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 18),
                      SizedBox(width: 4),
                      Text(
                        house.rating.toString(),
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(height: 6),
                  Text(
                    house.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    house.address,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      _featureItem(Icons.king_bed_outlined, '${house.bedrooms}'),
                      SizedBox(width: 16),
                      _featureItem(Icons.bathtub_outlined, '${house.bathrooms}'),
                      SizedBox(width: 16),
                      _featureItem(Icons.square_foot, '${house.surface} m²'),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${house.price} €/mois',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: primaryBlue,
                        ),
                      ),
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

  // Widget pour un item de maison dans la liste "à proximité"
  Widget _houseListItem(House house) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image de la maison
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 100,
                height: 100,
                color: Colors.grey.shade300, // Fallback color
                child: Image.network(
                  house.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Icon(Icons.home, size: 40, color: Colors.grey.shade500),
                    );
                  },
                ),
              ),
            ),
            SizedBox(width: 12),
            // Informations de la maison
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 16),
                          SizedBox(width: 4),
                          Text(
                            house.rating.toString(),
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ],
                      ),
                      InkWell(
                        onTap: () {
                          // Logique pour ajouter/retirer des favoris
                        },
                        child: Icon(
                          house.isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: house.isFavorite ? Colors.red : Colors.grey,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    house.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    house.address,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      _featureItem(Icons.king_bed_outlined, '${house.bedrooms}'),
                      SizedBox(width: 16),
                      _featureItem(Icons.bathtub_outlined, '${house.bathrooms}'),
                      SizedBox(width: 16),
                      _featureItem(Icons.square_foot, '${house.surface} m²'),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    '${house.price} €/mois',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: primaryBlue,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget pour les caractéristiques de la maison (icône + texte)
  Widget _featureItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}