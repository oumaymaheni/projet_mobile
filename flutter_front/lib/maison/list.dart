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
  final Color primaryBlue = const Color(0xFF1E88E5);
  final Color accentOrange = const Color(0xFFFF9800);
  final Color textDark = const Color(0xFF333333);
  final Color textLight = const Color(0xFF757575);

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
        // Navigator.pushNamed(context, AppRoutes.search);
        break;
      case 2:
        // Removed favorites navigation
        break;
      case 3:
        Navigator.pushNamed(context, AppRoutes.myAnnounce);
        break;
      case 4:
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
                textDark: textDark,
                isFavoritesTab: false,
              )
              : null,
      body: _selectedIndex == 0 ? _buildHomeContent() : Container(),
      bottomNavigationBar: HomeBottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onBottomNavTapped,
        primaryBlue: primaryBlue,
      ),
      floatingActionButton:
          _selectedIndex == 0 ? _buildFloatingActionButton() : null,
    );
  }

  Widget _buildHomeContent() {

    if (_isLoading) {
      return Center(child: CircularProgressIndicator(color: primaryBlue));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          const Text(
            'Trouver la meilleure maison à louer',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 12),

          _filteredHouses.isEmpty
              ? Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 30.0),
                  child: Text(
                    'No properties found',
                    style: TextStyle(color: textLight, fontSize: 16),
                  ),
                ),
              )
              : PropertyListView(houses: _filteredHouses, textDark: textDark),
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
      backgroundColor: primaryBlue,
      child: const Icon(Icons.add, color: Color.fromARGB(255, 255, 255, 255)),
    );
  }
}