import 'package:flutter/material.dart';
import 'package:flutter_front/routes/app_routes.dart';
import '../models/maison_models.dart';
import '../widgets/home/app_bar_widget.dart';
import '../widgets/home/property_list_widget.dart';
import '../widgets/bottom_navigation_widget.dart';
import '../services/firebase_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Theme colors
   final Color primaryColor = const Color(0xFF3366FF); // Bleu plus moderne
  final Color accentColor = const Color(0xFFFF6B6B);   // Corail pour les accents
  final Color textPrimary = const Color(0xFF2D3436);
  final Color textSecondary = const Color(0xFF636E72);

  // public method to change the tab index
  void setTabIndex(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // City filter
  List<String> _cities = ['All'];
  String _selectedCity = 'All';

  // Houses list from Firebase
  List<House> _houses = [];
  bool _isLoading = true;

  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchHouses();
  }

Future<void> _fetchHouses() async {
  setState(() {
    _isLoading = true;
  });

  try {
    final houses = await FirebaseService.getOtherUsersHouses();
    setState(() {
      _houses = houses;
      _isLoading = false;
      _initializeCities();
    });
  } catch (e) {
    print('Error fetching houses: $e');
    setState(() {
      _isLoading = false;
    });
  }
}

  // Method to extract unique cities from houses to use it later in the filter
  void _initializeCities() {
    Set<String> uniqueCities = _houses.map((house) => house.city).toSet();
    List<String> sortedCities = uniqueCities.toList()..sort();
    _cities = ['All', ...sortedCities];
    _selectedCity = 'All';
  }

  void _addHouse(House newHouse) async {
    await FirebaseService.addHouse(newHouse);
    _fetchHouses();
  }

  // Filter houses by city
  List<House> get _filteredHouses {
    return _houses.where((house) {
      // Apply city filter
      bool matchesCity = _selectedCity == 'All' || house.city == _selectedCity;

      return matchesCity;
    }).toList();
  }

  void _onCityChanged(String? newValue) {
    if (newValue != null) {
      setState(() {
        _selectedCity = newValue;
      });
    }
  }

  void _onBottomNavTapped(int index) {
    setTabIndex(index);

    switch (index) {
      case 0:
        // Home - reste sur la même page
        break;
      case 1:
        Navigator.pushNamed(context, AppRoutes.myAnnounce);
        break;
      case 2:
        Navigator.pushNamed(context, AppRoutes.userProfile);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          _selectedIndex == 0
              ? HomeAppBar(
                selectedCity: _selectedCity,
                cities: _cities,
                onCityChanged: _onCityChanged,
                textDark: textSecondary,
                isFavoritesTab: false,
                textColor: textPrimary ,
                primaryColor: primaryColor ,
              )
              : null,
      body: _selectedIndex == 0 ? _buildHomeContent() : Container(),
      bottomNavigationBar: HomeBottomNavigationBar(
        currentIndex: _selectedIndex,
        primaryBlue: primaryColor,
        onTap: _onBottomNavTapped,
      ),
      floatingActionButton:
          _selectedIndex == 0 ? _buildFloatingActionButton() : null,
    );
  }

  Widget _buildHomeContent() {

    if (_isLoading) {
      return Center(child: CircularProgressIndicator(color: primaryColor));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 30),
    
                Text(
                  'Trouvez votre',
                  style: TextStyle(
                    fontSize: 28,
                    color: textPrimary,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                Text(
                  'Logement idéal',
                  style: TextStyle(
                    fontSize: 32,
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                    height: 0.9,
                  ),
                ),
          const SizedBox(height: 20),

          _filteredHouses.isEmpty
              ? Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 30.0),
                  child: Text(
                    'No properties found',
                    style: TextStyle(color: textPrimary, fontSize: 16),
                  ),
                ),
              )
              : PropertyListView(houses: _filteredHouses, textDark: textPrimary),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  FloatingActionButton _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () {
        Navigator.pushNamed(context, '/post-house').then((newHouse) {
          if (newHouse != null && newHouse is House) {
            _addHouse(newHouse);
          }
        });
      },
      backgroundColor: primaryColor,
      child: const Icon(Icons.add, color: Color.fromARGB(255, 255, 255, 255)),
    );
  }
}