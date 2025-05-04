// lib/routes/user.dart
import 'package:flutter/material.dart';
import '../users/profil.dart';
import '../models/user_model.dart';

final mockUser = User(
  name: 'Jean Dupont',
  email: 'jean.dupont@exemple.com',
  phone: '+33 6 12 34 56 78',
  address: '123 Rue de Paris, 75001 Paris',
  joinDate: '12/05/2023',
  avatar: 'https://via.placeholder.com/150',
);

final Map<String, WidgetBuilder> userRoutes = {
  '/userProfile': (context) => UserProfilePage(userData: mockUser),
};
