import 'package:flutter/material.dart';
import '../../models/maison_models.dart';
import '../../maison/house_details.dart';

class PropertyListView extends StatelessWidget {
  final List<House> houses;
  final Color textDark;

  const PropertyListView({
    Key? key,
    required this.houses,
    required this.textDark,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Dark mode colors
    Color backgroundColor = isDarkMode ? const Color.fromARGB(255, 46, 46, 46) : Colors.grey[50]!;
    Color textColor = isDarkMode ? Colors.white : const Color.fromARGB(255, 6, 6, 6);
    Color iconColor = isDarkMode ? Colors.white70 : Colors.grey[500]!;

    if (houses.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.home_work_outlined, size: 64, color: Color.fromARGB(255, 62, 60, 219)),
              SizedBox(height: 16),
              Text(
                'No properties found',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Try changing your filters or check back later',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: houses.length,
      itemBuilder: (context, index) {
        final house = houses[index];
        return GestureDetector(
          onTap: () {
            // Navigate to the detail page when card is tapped
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PropertyDetailPage(house: house),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Property Image
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                  child: _buildPropertyImage(house),
                ),

                // Property Details
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        house.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),

                      // Address
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 14, color: iconColor),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              house.address,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Features and Price
                      Row(
                        children: [
                          // Features
                          Expanded(
                            child: Row(
                              children: [
                                _buildFeatureChip(Icons.directions_car, '${house.bedrooms}'),
                                const SizedBox(width: 10),
                                _buildFeatureChip(Icons.bed, '${house.bathrooms}'),
                                const SizedBox(width: 10),
                                _buildFeatureChip(Icons.square_foot, '${house.surface} m²'),
                              ],
                            ),
                          ),

                          // Price
                          Text(
                            '${house.price.toStringAsFixed(0)} DT',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Handle image display
  Widget _buildPropertyImage(House house) {
    if (house.imageUrls == null || house.imageUrls.isEmpty) {
      return Container(
        height: 150,
        color: Colors.grey[300],
        child: const Center(
          child: Icon(Icons.home, size: 50, color: Colors.white),
        ),
      );
    }

    return Image.network(
      house.imageUrls[0],
      height: 150,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          height: 150,
          color: Colors.grey[300],
          child: const Center(
            child: Icon(Icons.error, color: Colors.white),
          ),
        );
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          height: 150,
          color: Colors.grey[200],
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }

  Widget _buildFeatureChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: const Color.fromARGB(255, 72, 56, 222)),
        const SizedBox(width: 2),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
