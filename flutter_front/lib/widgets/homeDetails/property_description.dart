import 'package:flutter/material.dart';

class PropertyDescription extends StatelessWidget {
  final String description;
  final Color textLight;

  const PropertyDescription({
    Key? key,
    required this.description,
    required this.textLight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      description,
      style: TextStyle(
        fontSize: 14,
        color: textLight,
        height: 1.5,
      ),
    );
  }
}