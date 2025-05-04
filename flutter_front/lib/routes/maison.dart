import 'package:flutter/material.dart';
import '../maison/list.dart'; // vérifie que ce fichier existe bien et contient HomePage

final Map<String, WidgetBuilder> maisonRoutes = {
  '/home': (context) => const HomePage(),
};
