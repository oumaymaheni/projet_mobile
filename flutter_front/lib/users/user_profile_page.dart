import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import '../models/user_model.dart';
import 'change_password_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import '../theme/theme_provider.dart';

class UserProfilePage extends StatefulWidget {
  final User? userData;
  const UserProfilePage({Key? key, this.userData}) : super(key: key);

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  User? _currentUser;
  bool _isEditing = false;
  final ImagePicker _picker = ImagePicker();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  Color get primaryBlue {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: true);
    return themeProvider.isDarkMode ? Colors.blueAccent : const Color(0xFF2979FF);
  }

  Color get secondaryBlue {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: true);
    return themeProvider.isDarkMode ? Colors.blueGrey : const Color(0xFF75A7FF);
  }

  Color get backgroundWhite {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: true);
    return themeProvider.isDarkMode ? Colors.grey[900]! : Colors.white;
  }

  Color get textGrey {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: true);
    return themeProvider.isDarkMode ? Colors.grey[300]! : const Color(0xFF757575);
  }

  Color get cardColor {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: true);
    return themeProvider.isDarkMode ? Colors.grey[800]! : Colors.white;
  }

  Color get shadowColor {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: true);
    return themeProvider.isDarkMode ? Colors.black12 : Colors.black.withOpacity(0.05);
  }

  User? get _user => _currentUser ?? widget.userData;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  void _toggleTheme() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    themeProvider.toggleTheme(!themeProvider.isDarkMode);
  }

  Future<void> _fetchUserData() async {
    try {
      final fb_auth.User? firebaseUser = fb_auth.FirebaseAuth.instance.currentUser;
      if (firebaseUser != null) {
        final doc = await FirebaseFirestore.instance.collection('users').doc(firebaseUser.uid).get();
        if (doc.exists) {
          setState(() {
            _currentUser = User.fromMap(doc.data()!);
            _nameController.text = _currentUser?.name ?? '';
            _phoneController.text = _currentUser?.phone ?? '';
            _addressController.text = _currentUser?.address ?? '';
          });
        }
      }
    } catch (e) {
      print('Erreur lors de la récupération: $e');
    }
  }

  Future<void> _pickAndUploadImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    try {
      final bytes = await image.readAsBytes();
      final base64Image = base64Encode(bytes);
      const apiKey = '82842c6b96e27bc5c0f6d72cd45c27da';

      final response = await http.post(
        Uri.parse('https://api.imgbb.com/1/upload'),
        body: {
          'key': apiKey,
          'image': base64Image,
        },
      );

      final jsonResponse = json.decode(response.body);
      if (jsonResponse['success']) {
        final imageUrl = jsonResponse['data']['url'];
        final user = fb_auth.FirebaseAuth.instance.currentUser;

        if (user != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .update({'avatar': imageUrl});
          
          setState(() {
            _currentUser = _currentUser?.copyWith(avatar: imageUrl);
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Photo de profil mise à jour'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      print('Erreur upload: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de l\'upload: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _saveChanges() async {
    final fb_auth.User? firebaseUser = fb_auth.FirebaseAuth.instance.currentUser;
    if (firebaseUser != null && _currentUser != null) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(firebaseUser.uid).update({
          'name': _nameController.text.trim(),
          'phone': _phoneController.text.trim(),
          'address': _addressController.text.trim(),
        });
        setState(() {
          _currentUser = _currentUser!.copyWith(
            name: _nameController.text.trim(),
            phone: _phoneController.text.trim(),
            address: _addressController.text.trim(),
          );
          _isEditing = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil mis à jour avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la mise à jour: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    if (_user == null) {
      return Scaffold(
        backgroundColor: backgroundWhite,
        body: Center(child: CircularProgressIndicator(color: primaryBlue)),
      );
    }

    return Scaffold(
      backgroundColor: backgroundWhite,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: primaryBlue),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 20),
            _buildPersonalInformationCard(),
            const SizedBox(height: 20),
            _buildOptionsMenu(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
Widget _buildProfileHeader() {
  return Column(
    children: [
      const SizedBox(height: 10), // Réduit l'espace au-dessus
      InkWell(
        onTap: _pickAndUploadImage,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 120, // Taille réduite
              height: 120, // Taille réduite
              decoration: BoxDecoration(
                shape: BoxShape.circle, // Correction de la faute de frappe
                border: Border.all(
                  color: Colors.white,
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ClipOval(
                child: _user?.avatar != null
                    ? Image.network(
                        _user!.avatar!,
                        fit: BoxFit.cover,
                        width: 120,
                        height: 120,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              color: primaryBlue,
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded / 
                                    loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: primaryBlue,
                            child: Icon(
                              Icons.person,
                              size: 50, // Taille réduite
                              color: Colors.white,
                            ),
                          );
                        },
                      )
                    : Container(
                        color: primaryBlue,
                        child: Icon(
                          Icons.person,
                          size: 50, // Taille réduite
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            Positioned(
              bottom: 5, // Position ajustée
              right: 5, // Position ajustée
              child: Container(
                padding: const EdgeInsets.all(6), // Taille réduite
                decoration: BoxDecoration(
                  color: primaryBlue,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(
                  Icons.camera_alt,
                  size: 16, // Taille réduite
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 12), // Espace réduit
      Text(
        _user!.name,
        style: TextStyle(
          fontSize: 20, // Taille légèrement réduite
          fontWeight: FontWeight.bold,
          color: Provider.of<ThemeProvider>(context).isDarkMode 
              ? Colors.white 
              : Colors.black,
        ),
      ),
      const SizedBox(height: 2), // Espace réduit
      Text(
        _user!.email,
        style: TextStyle(
          fontSize: 14,
          color: Provider.of<ThemeProvider>(context).isDarkMode
              ? Colors.grey[300]
              : Colors.grey[600],
        ),
      ),
    ],
  );
}

  Widget _buildPersonalInformationCard() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: shadowColor, blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person_pin_circle_rounded, color: primaryBlue),
              const SizedBox(width: 10),
              Text(
                'Informations personnelles',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryBlue),
              ),
              const Spacer(),
              IconButton(
                icon: Icon(_isEditing ? Icons.save : Icons.edit, color: primaryBlue),
                onPressed: () {
                  if (_isEditing) {
                    _saveChanges();
                  } else {
                    setState(() => _isEditing = true);
                  }
                },
              ),
            ],
          ),
          const Divider(height: 25),
          _buildEditableRow(Icons.person, 'Nom complet', _nameController),
          const SizedBox(height: 16),
          _buildStaticRow(Icons.email, 'Email', _user!.email),
          const SizedBox(height: 16),
          _buildEditableRow(Icons.phone, 'Téléphone', _phoneController),
          const SizedBox(height: 16),
          _buildEditableRow(Icons.location_on, 'Adresse', _addressController),
        ],
      ),
    );
  }

Widget _buildEditableRow(IconData icon, String label, TextEditingController controller) {
  final themeProvider = Provider.of<ThemeProvider>(context);
  final isDarkMode = themeProvider.isDarkMode;

  return Row(
    children: [
      Icon(icon, color: secondaryBlue, size: 20),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 12, color: textGrey, fontWeight: FontWeight.w500)),
            const SizedBox(height: 4),
            _isEditing
                ? TextFormField(
                    controller: controller,
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black87,
                      fontSize: 16,
                    ),
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                      filled: true,
                      fillColor: cardColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: textGrey.withOpacity(0.3)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: textGrey.withOpacity(0.3)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: primaryBlue, width: 2),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.red, width: 1),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.red, width: 2),
                      ),
                    ),
                  )
                : Text(
                    controller.text.isNotEmpty ? controller.text : 'Non renseigné',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isDarkMode ? Colors.white : Colors.black87,
                      fontStyle: controller.text.isEmpty ? FontStyle.italic : FontStyle.normal,
                    ),
                  ),
          ],
        ),
      ),
    ],
  );
}

  Widget _buildStaticRow(IconData icon, String label, String value) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Row(
      children: [
        Icon(icon, color: secondaryBlue, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 12, color: textGrey, fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: isDarkMode ? Colors.white : Colors.black87)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOptionsMenu() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: shadowColor, blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          _buildListTile(
            icon: Icons.security,
            title: 'Sécurité',
            subtitle: 'Modifiez votre mot de passe',
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => ChangePasswordPage()));
            },
          ),
          Divider(height: 1, color: Colors.grey.withOpacity(0.3)),
          _buildListTile(
            icon: isDarkMode ? Icons.light_mode : Icons.dark_mode,
            title: isDarkMode ? 'Mode clair' : 'Mode sombre',
            subtitle: 'Changer le thème de l\'application',
            onTap: _toggleTheme,
          ),
          if (!_isEditing) Divider(height: 1, color: Colors.grey.withOpacity(0.3)),
          if (!_isEditing)
            _buildListTile(
              icon: Icons.logout,
              title: 'Déconnexion',
              subtitle: 'Quitter votre compte',
              onTap: () {
                fb_auth.FirebaseAuth.instance.signOut();
                Navigator.pushReplacementNamed(context, '/login');
              },
              isLogout: true,
            ),
        ],
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isLogout ? Colors.red.withOpacity(0.1) : primaryBlue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: isLogout ? Colors.redAccent : primaryBlue, size: 22),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: isLogout ? Colors.redAccent : (isDarkMode ? Colors.white : Colors.black87),
        ),
      ),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 13, color: textGrey)),
      trailing: Icon(Icons.chevron_right, color: isLogout ? Colors.redAccent : Colors.grey),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      onTap: onTap,
    );
  }
}