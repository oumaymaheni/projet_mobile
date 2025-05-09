import 'package:flutter/material.dart';

class PropertyFilterChips extends StatelessWidget {
  final List<String> propertyTypes;
  final String selectedPropertyType;
  final Function(String) onPropertyTypeSelected;
  final Color textLight;
  
  const PropertyFilterChips({
    Key? key,
    required this.propertyTypes,
    required this.selectedPropertyType,
    required this.onPropertyTypeSelected,
    required this.textLight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: propertyTypes.length + 1, // +1 for sort button
        itemBuilder: (context, index) {
          // Last item is the sort button
          if (index == propertyTypes.length) {
            return Container(
              margin: const EdgeInsets.only(left: 8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: IconButton(
                icon: const Icon(Icons.tune, size: 20),
                onPressed: () {},
              ),
            );
          }
          final filter = propertyTypes[index];
          final isSelected = selectedPropertyType == filter;
          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  onPropertyTypeSelected(filter);
                }
              },
              backgroundColor: Colors.grey[100],
              selectedColor: const Color(0xFFE8EAFF),
              labelStyle: TextStyle(
                color: isSelected ? const Color(0xFF4A5AFF) : textLight,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
          );
        },
      ),
    );
  }
}