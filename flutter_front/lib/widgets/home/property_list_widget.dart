import 'package:flutter/material.dart';
import '../../models/maison_models.dart';
import '../../maison/house_details.dart';

class PropertyListView extends StatelessWidget {
  final List<House> houses;
  final Function(House)? onToggleFavorite;
  final Color textDark;

  const PropertyListView({
    Key? key,
    required this.houses,
    this.onToggleFavorite ,
    required this.textDark,
  }) : super(key: key);

  @override
    @override
  Widget build(BuildContext context) {
    if (houses.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.home_work_outlined, size: 64, color: Colors.grey),
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
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PropertyDetailPage(house: house),
              ),
            );
          },
          child: Card(
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      child: _buildPropertyImage(house),
                    ),
                    if (onToggleFavorite != null) // Affiche le bouton seulement si la fonction existe
                    Positioned(
                      top: 8,
                      right: 8,
                      child: InkWell(
                        onTap: () => onToggleFavorite!(house), // Utilisation de ! car on a vérifié non null
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            house.isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: house.isFavorite ? Colors.red : Colors.grey,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${house.price.toStringAsFixed(0)} Dt/Mois',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      
                      Text(
                        '${house.title}, ${house.address}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      
                      Row(
                        children: [
                          _buildFeatureChip(Icons.king_bed, '${house.bedrooms}'),
                          const SizedBox(width: 12),
                          _buildFeatureChip(Icons.bathtub, '${house.bathrooms}'),
                          const SizedBox(width: 12),
                          _buildFeatureChip(Icons.square_foot, '${house.surface} ft²'),
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

  // New method to safely handle image display
  Widget _buildPropertyImage(House house) {
    // Check if imageUrls is null or empty
    if (house.imageUrls == null || house.imageUrls.isEmpty) {
      return Container(
        height: 180,
        color: Colors.grey[300],
        child: const Center(
          child: Icon(Icons.home, size: 50, color: Colors.white),
        ),
      );
    }
    
    // If we have image URLs, use the first one
    return Image.network(
      house.imageUrls[0],
      height: 180,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          height: 180,
          color: Colors.grey[300],
          child: const Center(
            child: Icon(Icons.error, color: Colors.white),
          ),
        );
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          height: 180,
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
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}