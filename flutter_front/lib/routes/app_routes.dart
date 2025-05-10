// lib/routes/app_routes.dart
import 'package:flutter/material.dart';
import 'authentification.dart';
import 'maison.dart';
import 'user.dart'; // <--- Ajout
import 'post_routes.dart';
import 'favorites.dart';

class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String forgot = '/forgot';
  static const String home = '/home';
  static const String userProfile = '/userProfile';
  static const String postHouse = '/post-house';
  static const String myAnnounce = '/my-ads';
  static const String EditmyAnnounce = '/edit-house';
  static const String favorites ='/favorites';


  static final routes = <String, WidgetBuilder>{
    ...authRoutes,
    ...maisonRoutes,
    ...userRoutes,
    ...postHouseRoutes,
    // ...favoriteRoute

  };
}
