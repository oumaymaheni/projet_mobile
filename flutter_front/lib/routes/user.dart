// lib/routes/user.dart
import 'package:flutter/material.dart';
import '../users/profil.dart';
import '../models/user_model.dart';



final Map<String, WidgetBuilder> userRoutes = {
  '/userProfile': (context) => UserProfilePage(), // Sans userData
};

