import '../maison/favorites.dart';
import 'package:flutter/material.dart';

final Map<String, WidgetBuilder> favoriteRoute = {
  '/favorites': (context) {
    // Get arguments passed to the route
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    
    return FavoritesScreen(
      houses: args['houses'],
      onToggleFavorite: args['onToggleFavorite'],
    );
  },
};