import 'package:flutter/material.dart';
import '../models/maison_models.dart';

// Import all the widget files
import '../widgets/homeDetails/image_slider.dart';
import '../widgets/homeDetails/header_info.dart';
import '../widgets/homeDetails/property_stats.dart';
import '../widgets/homeDetails/property_description.dart';
import '../widgets/homeDetails/property_location.dart';
import '../widgets/homeDetails/contact_button.dart';

class PropertyDetailPage extends StatefulWidget {
  final House house;
  final bool showContactButton;

  // const PropertyDetailPage({Key? key, required this.house}) : super(key: key);
  const PropertyDetailPage({
    Key? key,
    required this.house,
    this.showContactButton = true, // Valeur par défaut true
  }) : super(key: key);

  @override
  State<PropertyDetailPage> createState() => _PropertyDetailPageState();
}

class _PropertyDetailPageState extends State<PropertyDetailPage> {
  // Theme colors
  final Color primaryBlue = const Color(0xFF1E88E5);
  final Color accentOrange = const Color(0xFFFF9800);
  final Color lightBackground = Colors.white;
  final Color textDark = const Color(0xFF333333);
  final Color textLight = const Color(0xFF757575);

  void _toggleFavorite() {
    setState(() {
      widget.house.isFavorite = !widget.house.isFavorite;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: lightBackground,
      body: CustomScrollView(
        slivers: [
          // Custom app bar with image slider
          PropertyImageSliderBar(
            house: widget.house,
            onFavoriteToggle: _toggleFavorite,
          ),

          // Content
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Price and Location info
                  PropertyHeaderInfo(house: widget.house, textLight: textLight),

                  const SizedBox(height: 24),

                  // Property stats (rooms, baths, area)
                  PropertyStats(
                    house: widget.house,
                    textDark: textDark,
                    textLight: textLight,
                  ),

                  const SizedBox(height: 24),

                  // Description
                  PropertyDescription(
                    description: widget.house.description,
                    textLight: textLight,
                  ),

                  const SizedBox(height: 24),

                  // Location section
                  PropertyLocation(house: widget.house),

                  const SizedBox(height: 100), // Extra space for bottom button
                ],
              ),
            ),
          ),
        ],
      ),
      // bottomSheet: ContactButton(
      //   primaryBlue: primaryBlue,
      //   publisherId: widget.house.publisher,
      // ),
      bottomSheet:
          widget.showContactButton
              ? ContactButton(
                primaryBlue: primaryBlue,
                publisherId: widget.house.publisher,
              )
              : null,
    );
  }
}
