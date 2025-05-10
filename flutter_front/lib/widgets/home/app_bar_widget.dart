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

    // Show different app bar based on tab
    if (isFavoritesTab) {
      return AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        title: Text(
          'Favoris',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      );
    }

    // Default Home tab app bar with improved filter button
    return AppBar(
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

  // Filter bottom sheet UI
  Widget _buildFilterSheet(BuildContext context, Color backgroundColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filtres',
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              IconButton(
                icon: Icon(Icons.close, color: textColor),
                onPressed: () => Navigator.pop(context),
              )
            ],
          ),

          
        ],
      ),
    );
  }

  // Helper method to build filter categories
  Widget _buildFilterCategory(BuildContext context, String title, List<String> options) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    Color chipBgColor = isDarkMode ? Colors.grey[800]! : Colors.grey[200]!;
    Color selectedChipColor = Theme.of(context).colorScheme.primary;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            bool isSelected = option == options[0]; // Just for demo
            return FilterChip(
              label: Text(option),
              selected: isSelected,
              showCheckmark: false,
              backgroundColor: chipBgColor,
              selectedColor: selectedChipColor.withOpacity(0.2),
              labelStyle: TextStyle(
                color: isSelected 
                    ? selectedChipColor
                    : isDarkMode ? Colors.white : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              side: BorderSide(
                color: isSelected ? selectedChipColor : Colors.transparent,
                width: 1,
              ),
              onSelected: (bool selected) {
                // Handle filter selection
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}