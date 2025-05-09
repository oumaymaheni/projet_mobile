import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_maps_flutter_web/google_maps_flutter_web.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'firebase_options.dart'; // Fichier généré automatiquement
import 'routes/app_routes.dart'; // Routes centralisées
import 'authentification/login.dart'; // Exemple de page login
import 'package:provider/provider.dart';
import 'theme/theme_provider.dart'; // Chemin corrigé

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
  setUrlStrategy(PathUrlStrategy()); // <-- Ajout important

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mon Application',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: themeProvider.themeMode,
      initialRoute: AppRoutes.login,
      routes: AppRoutes.routes,
    );
  }
}
