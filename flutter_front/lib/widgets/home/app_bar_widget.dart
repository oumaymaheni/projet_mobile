import 'package:flutter/material.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String selectedCity;
  final List cities;
  final Function(String?) onCityChanged;
  final Color textDark;
  final bool isFavoritesTab;
  final Color primaryColor;  
  final Color textColor; 
  
  const HomeAppBar({
    Key? key,
    required this.selectedCity,
    required this.cities,
    required this.onCityChanged,
    required this.textDark,
    required this.primaryColor,
    required this.textColor,
    this.isFavoritesTab = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    // Responsive colors based on theme
    Color backgroundColor = isDarkMode 
        ? const Color.fromARGB(255, 46, 46, 46) 
        : Colors.grey[50]!;
    Color textColor = isDarkMode 
        ? Colors.white 
        : const Color.fromARGB(255, 6, 6, 6);
    Color dropdownBgColor = isDarkMode 
        ? const Color.fromARGB(255, 65, 65, 65) 
        : Colors.white;
    Color accentColor = Theme.of(context).colorScheme.secondary;


    // Default Home tab app bar with improved filter button
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: backgroundColor,
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      title: Row(
        children: [
          // Improved city dropdown with custom container
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: dropdownBgColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
              border: Border.all(
                color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
                width: 1,
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedCity,
                icon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(width: 8),
                    Icon(
                      Icons.location_on_rounded,
                      color: accentColor,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: textColor,
                      size: 20,
                    ),
                  ],
                ),
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                isDense: true,
                borderRadius: BorderRadius.circular(8),
                menuMaxHeight: 300,
                dropdownColor: dropdownBgColor,
                onChanged: onCityChanged,
                items: cities.map<DropdownMenuItem<String>>((dynamic value) {
                  return DropdownMenuItem<String>(
                    value: value.toString(),
                    child: Text(
                      value.toString(),
                      style: TextStyle(
                        // FIXED: Always specify text color for dropdown items
                        color: isDarkMode ? Colors.white : Colors.black87,
                        fontWeight: value.toString() == selectedCity
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}