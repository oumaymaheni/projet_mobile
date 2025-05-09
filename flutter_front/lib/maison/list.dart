import 'package:flutter/material.dart';
import '../models/maison_models.dart';
import '../components/bottom_navigation_widget.dart'; 
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Color primaryBlue = const Color(0xFF1E88E5);
  final Color accentOrange = const Color(0xFFFF9800);
  final Color lightBlue = const Color(0xFFBBDEFB);

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
    // Ajoute les autres maisons ici comme dans ton exemple
  ];

  String _selectedFilter = 'Tous';
  final List<String> _filters = ['Tous', 'Populaires', 'Récents', 'Prix bas', 'Prix élevé'];

  int _selectedIndex = 0;

  void _onBottomNavTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 4) {
      Navigator.pushNamed(context, '/userProfile');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBlue.withOpacity(0.3),
      appBar: AppBar(
        backgroundColor: primaryBlue,
        elevation: 0,
        title: Text('ImmoLoc', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.person_outline, color: Colors.white),
            onPressed: () {
              Navigator.pushNamed(context, '/userProfile');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            _buildFilterChips(),
            _buildSectionTitle('Maisons recommandées'),
            _buildHorizontalHouseList(),
            _buildSectionTitle('Maisons à proximité'),
            _buildVerticalHouseList(),
          ],
        ),
      ),
bottomNavigationBar: HomeBottomNavigationBar(
  currentIndex: _selectedIndex,
  onTap: _onBottomNavTapped, // Changer _onItemTapped en _onBottomNavTapped
  primaryBlue: primaryBlue,
),
    );
  }

  Widget _buildHeader() {
    return Container(
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
          Text('Trouvez votre\nmaison idéale',
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          SizedBox(height: 20),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
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
    );
  }

  Widget _buildFilterChips() {
    return Column(
      children: [
        SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text('Catégories', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          TextButton(
            onPressed: () {},
            child: Text('Voir tout', style: TextStyle(color: accentOrange)),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalHouseList() {
    return SizedBox(
      height: 300,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16),
        itemCount: _houses.length,
        itemBuilder: (context, index) => _featuredHouseCard(_houses[index]),
      ),
    );
  }

  Widget _buildVerticalHouseList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 16),
      itemCount: _houses.length,
      itemBuilder: (context, index) => _houseListItem(_houses[index]),
    );
  }

  Widget _featuredHouseCard(House house) {
    return Container(
      width: 240,
      margin: EdgeInsets.only(right: 16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                  child: Container(
                    height: 150,
                    width: double.infinity,
                    color: Colors.grey.shade300,
                    child: Image.network(
                      house.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Center(child: Icon(Icons.home, size: 50, color: Colors.grey.shade500)),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: InkWell(
                    onTap: () {},
                    child: Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
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
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Icon(Icons.star, color: Colors.amber, size: 18),
                    SizedBox(width: 4),
                    Text(house.rating.toString(), style: TextStyle(fontWeight: FontWeight.bold)),
                  ]),
                  SizedBox(height: 6),
                  Text(house.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text(house.address, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                  SizedBox(height: 8),
                  Row(children: [
                    _featureItem(Icons.king_bed_outlined, '${house.bedrooms}'),
                    SizedBox(width: 16),
                    _featureItem(Icons.bathtub_outlined, '${house.bathrooms}'),
                    SizedBox(width: 16),
                    _featureItem(Icons.square_foot, '${house.surface} m²'),
                  ]),
                  SizedBox(height: 8),
                  Text('${house.price} €/mois', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryBlue)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _houseListItem(House house) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 100,
                height: 100,
                color: Colors.grey.shade300,
                child: Image.network(
                  house.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      Center(child: Icon(Icons.home, size: 40, color: Colors.grey.shade500)),
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Row(children: [
                      Icon(Icons.star, color: Colors.amber, size: 16),
                      SizedBox(width: 4),
                      Text(house.rating.toString(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    ]),
                    Icon(house.isFavorite ? Icons.favorite : Icons.favorite_border, color: house.isFavorite ? Colors.red : Colors.grey, size: 20),
                  ]),
                  SizedBox(height: 4),
                  Text(house.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text(house.address, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                  SizedBox(height: 6),
                  Text('${house.price} €/mois', style: TextStyle(fontWeight: FontWeight.bold, color: primaryBlue)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _featureItem(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 12)),
      ],
    );
  }
}
