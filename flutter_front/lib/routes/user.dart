// lib/routes/user.dart
import 'package:flutter/material.dart';
import '../users/user_profile_page.dart';
import '../models/user_model.dart';
import '../users/change_password_page.dart';



final Map<String, WidgetBuilder> userRoutes = {
  '/userProfile': (context) => UserProfilePage(), // Sans userData
  '/passwordchange': (context) => ChangePasswordPage(),
};

