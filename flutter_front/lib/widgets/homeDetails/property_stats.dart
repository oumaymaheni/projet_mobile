import 'package:flutter/material.dart';
import '../../models/maison_models.dart';

class PropertyStats extends StatelessWidget {
  final House house;
  final Color textDark;
  final Color textLight;

  const PropertyStats({
    Key? key,
    required this.house,
    required this.textDark,
    required this.textLight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey[200]!),
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildPropertyStat(
            Icons.king_bed,
            '${house.bedrooms} Chambres',
          ),
          _buildPropertyStat(
            Icons.bathtub,
            '${house.bathrooms} Salles de bain',
          ),
          _buildPropertyStat(
            Icons.square_foot,
            '${house.surface} m²',
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyStat(IconData icon, String text) {
    return Column(
      children: [
        Icon(icon, color: textLight),
        const SizedBox(height: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: textDark,
          ),
        ),
      ],
    );
  }
}