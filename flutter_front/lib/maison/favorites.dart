import 'package:flutter/material.dart';
import '../models/maison_models.dart';
import '../widgets/home/property_list_widget.dart';
import '../maison/list.dart';



class FavoritesScreen extends StatefulWidget {
  final List<House> houses;
  final Function(House) onToggleFavorite;

  const FavoritesScreen({
    Key? key,
    required this.houses,
    required this.onToggleFavorite,
  }) : super(key: key);

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  // Theme colors
  final Color primaryBlue = const Color(0xFF1E88E5);
  final Color accentOrange = const Color(0xFFFF9800);
  final Color lightBackground = const Color(0xFFF5F7FA);
  final Color textDark = const Color(0xFF333333);
  final Color textLight = const Color(0xFF757575);

  List<House> _favoriteHouses = [];

  @override
  void initState() {
    super.initState();
    _updateFavoritesList();
  }

  @override
  void didUpdateWidget(FavoritesScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update favorites list when widget updates (e.g. when coming back from another screen)
    _updateFavoritesList();
  }

  void _updateFavoritesList() {
    setState(() {
      _favoriteHouses = widget.houses.where((house) => house.isFavorite).toList();
    });
  }

  // Handle favorite toggle specifically for the favorites screen
  void _handleToggleFavorite(House house) {
    widget.onToggleFavorite(house);
    
    // Remove the house from the local list immediately for better UX
    setState(() {
      _favoriteHouses.removeWhere((h) => h.id == house.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBackground,
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_favoriteHouses.isEmpty) {
      return _buildEmptyState();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: PropertyListView(
        houses: _favoriteHouses,
        onToggleFavorite: _handleToggleFavorite,
        textDark: textDark,
      ),
    );
  }

  Widget _buildEmptyState() {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.favorite_outline,
          size: 80,
          color: Colors.grey[400],
        ),
        const SizedBox(height: 16),
        Text(
          'Aucun favori',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: textDark,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Ajoutez des propriétés à vos favoris',
          style: TextStyle(
            fontSize: 16,
            color: textLight,
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: () {
            // Navigate to the home screen (index 0)
            // This will work if you're using bottom navigation
            if (context.mounted) {
              // Find the closest Navigator
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const HomePage()),
                (Route<dynamic> route) => false, // Remove all previous routes
              );
              
              // Alternative approach if the above doesn't work:
              // If you have access to a global key for your bottom navigation
              // GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
              // scaffoldKey.currentState.onNavTap(0);
            }
          },
          icon: const Icon(Icons.home_outlined),
          label: const Text('Explorer les propriétés'),
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryBlue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    ),
  );
}
}