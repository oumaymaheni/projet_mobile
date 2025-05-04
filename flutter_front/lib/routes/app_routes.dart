// lib/routes/app_routes.dart
import 'package:flutter/material.dart';
import 'authentification.dart';
import 'maison.dart';
import 'user.dart'; // <--- Ajout


class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String forgot = '/forgot';
  static const String home = '/home';
  static const String userProfile = '/userProfile';

  static final routes = <String, WidgetBuilder>{
    ...authRoutes,
    ...maisonRoutes,
    ...userRoutes, 
  };
}
