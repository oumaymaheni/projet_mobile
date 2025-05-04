// lib/screens/user_profile_page.dart
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/user_model.dart';
import '../widgets/gradient_button.dart';

class UserProfilePage extends StatefulWidget {
  final User userData;

  UserProfilePage({Key? key, required this.userData}) : super(key: key);
 
  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}
 
class _UserProfilePageState extends State<UserProfilePage> {
  // Données utilisateur par défaut
  final User _defaultUser = User(
    name: 'Jean Dupont',
    email: 'jean.dupont@exemple.com',
    phone: '+33 6 12 34 56 78',
    address: '123 Rue de Paris, 75001 Paris',
    joinDate: '12/05/2023',
    avatar: 'https://via.placeholder.com/150',
  );

  User get _user {
    return widget.userData ?? _defaultUser;
  }

  // Couleurs d'accent orange qui complètent le bleu existant
  final Color accentOrange = const Color(0xFFFF7D00);
  final Color lightOrange = const Color(0xFFFFE0C4);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: CustomScrollView(
        slivers: [
          // En-tête avec avatar et nom (SliverAppBar pour un effet de parallaxe)
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            backgroundColor: AppTheme.primaryBlue, // Gardé le bleu original
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Édition du profil à implémenter'),
                      backgroundColor: accentOrange, // SnackBar orange
                    ),
                  );
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppTheme.primaryGradient, // Gardé le gradient bleu original
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Avatar avec bordure orange
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: accentOrange, width: 4), // Bordure orange
                          color: Colors.white,
                        ),
                        child: ClipOval(
                          child: _user.avatar != null
                              ? Image.network(
                                  _user.avatar!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(
                                      Icons.person,
                                      size: 80,
                                      color: Colors.grey.shade400,
                                    );
                                  },
                                )
                              : Icon(
                                  Icons.person,
                                  size: 80,
                                  color: Colors.grey.shade400,
                                ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Nom et email masqués quand l'app bar est réduite
                      Text(
                        _user.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        _user.email,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              title: const Text('Profil Utilisateur'),
            ),
          ),
          
          // Contenu principal
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Informations personnelles
                _buildSectionCard(
                  'Informations personnelles',
                  [
                    _buildInfoRow(
                      Icons.phone,
                      'Téléphone',
                      _user.phone,
                      onTap: () {
                        // Action lorsque l'utilisateur appuie sur le numéro de téléphone
                      },
                    ),
                    const Divider(height: 1), // Divider standard
                    _buildInfoRow(
                      Icons.location_on,
                      'Adresse',
                      _user.address,
                      onTap: () {
                        // Action lorsque l'utilisateur appuie sur l'adresse
                      },
                    ),
                    Divider(height: 1, color: lightOrange), // Divider orange clair
                    _buildInfoRow(
                      Icons.calendar_today,
                      'Membre depuis',
                      _user.joinDate,
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // Préférences utilisateur
                _buildSectionCard(
                  'Préférences',
                  [
                    _buildSettingRow(
                      Icons.home_outlined,
                      'Mes propriétés',
                      () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Mes propriétés à implémenter'),
                            backgroundColor: accentOrange, // SnackBar orange
                          ),
                        );
                      },
                    ),
                    Divider(height: 1, color: lightOrange), // Divider orange clair
                    _buildSettingRow(
                      Icons.favorite_border,
                      'Mes favoris',
                      () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Mes favoris à implémenter'),
                            backgroundColor: accentOrange, // SnackBar orange
                          ),
                        );
                      },
                    ),
                    Divider(height: 1, color: lightOrange), // Divider orange clair
                    _buildSettingRow(
                      Icons.history,
                      'Historique de recherche',
                      () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Historique à implémenter'),
                            backgroundColor: accentOrange, // SnackBar orange
                          ),
                        );
                      },
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // Paramètres de compte
                _buildSectionCard(
                  'Paramètres du compte',
                  [
                    _buildSettingRow(
                      Icons.lock_outline,
                      'Changer le mot de passe',
                      () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Changement de mot de passe à implémenter'),
                            backgroundColor: accentOrange, // SnackBar orange
                          ),
                        );
                      },
                    ),
                    Divider(height: 1, color: lightOrange), // Divider orange clair
                    _buildSettingRow(
                      Icons.notifications_none,
                      'Notifications',
                      () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Paramètres de notification à implémenter'),
                            backgroundColor: accentOrange, // SnackBar orange
                          ),
                        );
                      },
                    ),
                    Divider(height: 1, color: lightOrange), // Divider orange clair
                    _buildSettingRow(
                      Icons.language,
                      'Langue',
                      () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Paramètres de langue à implémenter'),
                            backgroundColor: accentOrange, // SnackBar orange
                          ),
                        );
                      },
                    ),
                    Divider(height: 1, color: lightOrange), // Divider orange clair
                    _buildSettingRow(
                      Icons.privacy_tip_outlined,
                      'Confidentialité',
                      () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Paramètres de confidentialité à implémenter'),
                            backgroundColor: accentOrange, // SnackBar orange
                          ),
                        );
                      },
                    ),
                  ],
                ),
                
                const SizedBox(height: 30),
                
                // Bouton de déconnexion
                // Padding(
                //   padding: const EdgeInsets.symmetric(horizontal: 20),
                //   child: GradientButton(
                //     text: 'Déconnexion',
                //     gradient: LinearGradient(
                //       colors: [AppTheme.primaryBlue, AppTheme.primaryBlue.shade700 ?? Colors.blue.shade700], // Gardé le gradient bleu
                //     ),
                //     onPressed: () {
                //       showDialog(
                //         context: context,
                //         builder: (context) => AlertDialog(
                //           title: const Text('Déconnexion'),
                //           content: const Text('Voulez-vous vraiment vous déconnecter ?'),
                //           actions: [
                //             TextButton(
                //               onPressed: () => Navigator.pop(context),
                //               child: Text(
                //                 'Annuler',
                //                 style: TextStyle(color: Colors.grey[700]),
                //               ),
                //             ),
                //             TextButton(
                //               onPressed: () {
                //                 Navigator.pop(context);
                //                 // Mettre ici la logique de déconnexion et de redirection
                //                 ScaffoldMessenger.of(context).showSnackBar(
                //                   SnackBar(
                //                     content: const Text('Déconnexion à implémenter'),
                //                     backgroundColor: accentOrange, // SnackBar orange
                //                   ),
                //                 );
                //               },
                //               child: Text(
                //                 'Déconnecter',
                //                 style: TextStyle(color: Colors.red[700]), // Texte rouge pour déconnexion
                //               ),
                //             ),
                //           ],
                //         ),
                //       );
                //     },
                //   ),
                // ),
                
                const SizedBox(height: 20),
              ]),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 4, // Indice de l'onglet Profil
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primaryBlue, // Garder la couleur bleue pour l'onglet sélectionné
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Rechercher',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            activeIcon: Icon(Icons.favorite),
            label: 'Favoris',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message_outlined),
            activeIcon: Icon(Icons.message),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
        onTap: (index) {
          if (index != 4) {
            // Navigation vers d'autres pages
          }
        },
      ),
    );
  }

  // Fonction pour créer une carte de section
  Widget _buildSectionCard(String title, List<Widget> children) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryBlue, // Titre en bleu
              ),
            ),
            const SizedBox(height: 15),
            ...children,
          ],
        ),
      ),
    );
  }

  // Widget pour afficher une ligne d'information
  Widget _buildInfoRow(IconData icon, String label, String value, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withOpacity(0.1), // Fond bleu transparent
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: accentOrange, // Icône orange
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.textLight,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textDark,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(
                Icons.arrow_forward_ios,
                color: accentOrange.withOpacity(0.6), // Icône orange semi-transparente
                size: 16,
              ),
          ],
        ),
      ),
    );
  }

  // Widget pour afficher une ligne de paramètre
  Widget _buildSettingRow(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: lightOrange, // Fond orange clair
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: accentOrange, // Icône orange
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textDark,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: accentOrange.withOpacity(0.6), // Icône orange semi-transparente
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}