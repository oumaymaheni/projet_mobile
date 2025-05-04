import 'package:flutter/material.dart';
import '../authentification/login.dart';
import '../authentification/register.dart';
import '../authentification/forget_password.dart';

final Map<String, WidgetBuilder> authRoutes = {
  '/login': (context) => const LoginPage(),
  '/register': (context) => const RegisterPage(),
   '/forget-password': (context) => const ForgetPasswordPage(),
};
