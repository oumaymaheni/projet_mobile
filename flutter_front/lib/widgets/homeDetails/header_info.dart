import 'package:flutter/material.dart';
import '../../models/maison_models.dart';

class PropertyHeaderInfo extends StatelessWidget {
  final House house;
  final Color textLight;

  const PropertyHeaderInfo({
    Key? key,
    required this.house,
    required this.textLight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${house.price.toStringAsFixed(0)} Dt/An',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            // color: Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${house.title}, ${house.address}',
          style: TextStyle(fontSize: 16, color: textLight),
        ),
      ],
    );
  }
}