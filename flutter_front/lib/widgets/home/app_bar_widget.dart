import 'package:flutter/material.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String selectedCity;
  final List cities;
  final Function(String?) onCityChanged;
  final Color textDark;
  final bool isFavoritesTab;
  
  const HomeAppBar({
    Key? key,
    required this.selectedCity,
    required this.cities,
    required this.onCityChanged,
    required this.textDark,
    this.isFavoritesTab = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Show different app bar based on tab
    if (isFavoritesTab) {
      return AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Favoris',
          style: TextStyle(
            color: textDark,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        // Avatar removed from here
      );
    }
    
    // Default Home tab app bar
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Row(
        children: [
          // Dynamic city dropdown
          DropdownButton(
            value: selectedCity,
            icon: Icon(Icons.keyboard_arrow_down, color: textDark, size: 20),
            style: TextStyle(
              color: textDark,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
            underline: Container(), // Remove underline
            onChanged: onCityChanged,
            items: cities.map((dynamic value) {
              return DropdownMenuItem<String>(
                value: value.toString(),
                child: Text(value.toString()),
              );
            }).toList(),
          ),
        ],
      ),
      // Avatar removed from here
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}