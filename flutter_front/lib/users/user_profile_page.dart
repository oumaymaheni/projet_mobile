import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import '../models/user_model.dart';
import 'change_password_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfilePage extends StatefulWidget {
  final User? userData;
  const UserProfilePage({Key? key, this.userData}) : super(key: key);

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  User? _currentUser;
  bool _isDarkMode = false;
  bool _isEditing = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  Color get primaryBlue => _isDarkMode ? Colors.blueAccent : const Color(0xFF2979FF);
  Color get secondaryBlue => _isDarkMode ? Colors.blueGrey : const Color(0xFF75A7FF);
  Color get backgroundWhite => _isDarkMode ? Colors.grey[900]! : Colors.white;
  Color get textGrey => _isDarkMode ? Colors.grey[300]! : const Color(0xFF757575);
  Color get cardColor => _isDarkMode ? Colors.grey[800]! : Colors.white;
  Color get shadowColor => _isDarkMode ? Colors.black12 : Colors.black.withOpacity(0.05);

  User? get _user => _currentUser ?? widget.userData;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
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
            email: _currentUser!.email, // reste inchangé
          );
          _isEditing = false;
        });
      } catch (e) {
        print('Erreur lors de l’enregistrement: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
        actions: [
          IconButton(
            icon: Icon(_isDarkMode ? Icons.light_mode : Icons.dark_mode, color: primaryBlue),
            onPressed: _toggleTheme,
          ),
        ],
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
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          height: 160,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryBlue, secondaryBlue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
        ),
        Column(
          children: [
            const SizedBox(height: 10),
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.white,
              child: ClipOval(
                child: _user!.avatar != null
                    ? Image.network(
                        _user!.avatar!,
                        fit: BoxFit.cover,
                        width: 96,
                        height: 96,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(Icons.person, size: 50, color: primaryBlue);
                        },
                      )
                    : Icon(Icons.person, size: 50, color: primaryBlue),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _user!.name,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            Text(
              _user!.email,
              style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w300),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ],
    );
  }

  Widget _buildPersonalInformationCard() {
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
                  ? TextField(
                      controller: controller,
                      style: TextStyle(color: _isDarkMode ? Colors.white : Colors.black87),
                      decoration: const InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 8),
                        border: UnderlineInputBorder(),
                      ),
                    )
                  : Text(
                      controller.text,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: _isDarkMode ? Colors.white : Colors.black87),
                    ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStaticRow(IconData icon, String label, String value) {
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
              Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: _isDarkMode ? Colors.white : Colors.black87)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOptionsMenu() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: shadowColor, blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          _buildListTile(icon: Icons.security, title: 'Sécurité', subtitle: 'Modifiez votre mot de passe', onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => ChangePasswordPage()));
          }),
          Divider(height: 1, color: Colors.grey.withOpacity(0.3)),
          _buildListTile(icon: Icons.logout, title: 'Déconnexion', subtitle: 'Quitter votre compte', onTap: () {
            fb_auth.FirebaseAuth.instance.signOut();
            Navigator.pushReplacementNamed(context, '/login');
          }, isLogout: true),
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
          color: isLogout ? Colors.redAccent : (_isDarkMode ? Colors.white : Colors.black87),
        ),
      ),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 13, color: textGrey)),
      trailing: Icon(Icons.chevron_right, color: isLogout ? Colors.redAccent : Colors.grey),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      onTap: onTap,
    );
  }
}
