// routes/app_routes.dart
import 'package:flutter/material.dart';
import 'authentification.dart';
import 'maison.dart';
import '../maison/list.dart';   
final Map<String, WidgetBuilder> maisonRoutes = {
  '/home': (context) => const HomePage(),
};

class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String forgot = '/forgot';
  static const String home = '/home';

  static final routes = <String, WidgetBuilder>{
    ...authRoutes,  // Routes pour l'authentification
    ...maisonRoutes,  // Routes pour la maison
  };
}

