import 'package:flutter/material.dart';
import '../models/maison_models.dart';
import '../maison/favorites.dart';
import '../widgets/home/app_bar_widget.dart';
import '../widgets/home/property_list_widget.dart';
import '../widgets/bottom_navigation_widget.dart';
import '../services/firebase_service.dart'; // Import your Firebase service

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Theme colors
  final Color primaryBlue = const Color(0xFF1E88E5);
  final Color accentOrange = const Color(0xFFFF9800);
  final Color lightBackground = const Color(0xFFF5F7FA);
  final Color textDark = const Color(0xFF333333);
  final Color textLight = const Color(0xFF757575);

  // Current tab index
  int _currentIndex = 0;

  // Property type filters
  final List<String> _propertyTypes = [
    'All',
    'House',
    'Apartment',
    'Villa',
    'Condo',
    'Studio',
  ];
  String _selectedPropertyType = 'All';

  // City filter
  List<String> _cities = ['All'];
  String _selectedCity = 'All';

  // Houses list from Firebase
  List<House> _houses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchHouses();
  }

  // Fetch houses from Firebase
  Future<void> _fetchHouses() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final houses = await FirebaseService.getHouses();

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

  // Method to extract unique cities from houses
  void _initializeCities() {
    // Extract unique city names
    Set<String> uniqueCities = _houses.map((house) => house.city).toSet();
    // Convert to list and sort alphabetically
    List<String> sortedCities = uniqueCities.toList()..sort();
    // Add 'All' at the beginning
    _cities = ['All', ...sortedCities];
    // Set default selected city
    _selectedCity = 'All';
  }

  // Add a house and update city filters
  void _addHouse(House newHouse) async {
    // Add house to Firebase first
    await FirebaseService.addHouse(newHouse);
    // Then refresh houses from Firebase
    _fetchHouses();
  }

  // Toggle favorite status for a house
  void _toggleFavorite(House house) async {
    try {
      final newFavoriteStatus = !house.isFavorite;

      // Update the favorite status in Firebase
      await FirebaseService.updateHouseFavoriteStatus(
        house.id,
        newFavoriteStatus,
      );

      // Then update the local state
      setState(() {
        final index = _houses.indexWhere((h) => h.id == house.id);
        if (index != -1) {
          _houses[index] = _houses[index].copyWith(
            isFavorite: newFavoriteStatus,
          );
        }
      });
    } catch (e) {
      print('Error toggling favorite: $e');
      // Show error message to user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Impossible de mettre à jour le statut favori. Veuillez réessayer.',
          ),
        ),
      );
    }
  }

  // Modified to filter by both property type and city
  List<House> get _filteredHouses {
    return _houses.where((house) {
      // Apply property type filter
      bool matchesPropertyType =
          _selectedPropertyType == 'All' ||
          house.propertyType == _selectedPropertyType;

      // Apply city filter
      bool matchesCity = _selectedCity == 'All' || house.city == _selectedCity;

      // Return houses that match both filters
      return matchesPropertyType && matchesCity;
    }).toList();
  }

  // Handle bottom navigation tap
  void _onNavTap(int index) {
    setState(() {
      _currentIndex = index;
    });
    // Handle special navigation cases
    if (index == 4) {
      // Profile tab index
      Navigator.pushNamed(context, '/userProfile');
    }
  }

  // Handle property type filter selection
  void _onPropertyTypeSelected(String propertyType) {
    setState(() {
      _selectedPropertyType = propertyType;
    });
  }

  // Handle city filter selection
  void _onCityChanged(String? newValue) {
    if (newValue != null) {
      setState(() {
        _selectedCity = newValue;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Define pages to show based on current index
    final List<Widget> _pages = [
      _buildHomeContent(),
      const Center(child: Text('Search Page')),
      FavoritesScreen(houses: _houses, onToggleFavorite: _toggleFavorite),
      const Center(child: Text('Messages Page')),
      const Center(child: Text('Profile Page')),
    ];

    return Scaffold(
      backgroundColor: lightBackground,
      appBar: HomeAppBar(
        selectedCity: _selectedCity,
        cities: _cities,
        onCityChanged: _onCityChanged,
        textDark: textDark,
        isFavoritesTab: _currentIndex == 2,
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: HomeBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
        primaryBlue: primaryBlue,
      ),
      floatingActionButton:
          _currentIndex == 0 ? _buildFloatingActionButton() : null,
    );
  }

  // Home content widget
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

          // Title text
          const Text(
            'Find Your Dream Home',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 12),

          // Show message if no houses
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
              : PropertyListView(
                houses: _filteredHouses,
                onToggleFavorite: _toggleFavorite,
                textDark: textDark,
              ),
          const SizedBox(height: 80), // Add space at bottom for FAB
        ],
      ),
    );
  }

  FloatingActionButton _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () {
        // Use the original navigation approach with the named route
        Navigator.pushNamed(context, '/post-house').then((newHouse) {
          // Check if we got a new house back
          if (newHouse != null && newHouse is House) {
            // When a new house is added, update our Firebase and list
            _addHouse(newHouse);
          }
        });
      },
      backgroundColor: primaryBlue,
      child: const Icon(Icons.add, color: Colors.white),
    );
  }
}
