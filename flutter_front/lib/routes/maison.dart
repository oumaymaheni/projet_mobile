import '../maison/list.dart';
import 'package:flutter/material.dart';
import '../maison/my_ads_page.dart';
// Assurez-vous que ce fichier contient bien HomePage

final Map<String, WidgetBuilder> maisonRoutes = {
  '/home': (context) => const HomePage(),
  '/my-ads': (context) => const MyAdsPage(),
  '/edit-house': (context) => const MyAdsPage(),
};
