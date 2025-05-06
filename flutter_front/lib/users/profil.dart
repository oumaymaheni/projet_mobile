import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_theme.dart';
import '../models/user_model.dart';
import '../widgets/gradient_button.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
class UserProfilePage extends StatefulWidget {
  final User? userData;
  const UserProfilePage({Key? key, this.userData}) : super(key: key);
 
  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  User? _currentUser;
  final ImagePicker _picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  bool _isEditing = false;
  bool _isLoading = false;

  // Couleurs harmonisées avec le login
  final Color _primaryBlue = const Color(0xFF2979FF);
  final Color _secondaryBlue = const Color(0xFF75A7FF);
  final Color _backgroundWhite = Colors.white;
  final Color _textGrey = const Color(0xFF757575);
  final Color _lightGrey = const Color(0xFFEEEEEE);
  final Color _inputFillColor = const Color(0xFFF5F8FF);
  final Color _inputBorderColor = const Color(0xFFD0DFFF);

  User? get _user => _currentUser ?? widget.userData;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _initializeControllers();
  }

  void _initializeControllers() {
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _addressController = TextEditingController();
  }

  void _updateControllers() {
    if (_user != null) {
      _nameController.text = _user!.name;
      _emailController.text = _user!.email;
      _phoneController.text = _user!.phone ?? '';
      _addressController.text = _user!.address ?? '';
    }
  }
 Future<void> _pickAndUploadImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    setState(() => _isLoading = true);
    try {
      final bytes = await image.readAsBytes();
      final base64Image = base64Encode(bytes);
      const apiKey = '82842c6b96e27bc5c0f6d72cd45c27da'; // <-- Remplace ici

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
      } else {
        throw Exception('Upload failed');
      }
    } catch (e) {
      print('Erreur upload: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de l\'upload: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
  Future<void> _fetchUserData() async {
    try {
      final fb_auth.User? firebaseUser = fb_auth.FirebaseAuth.instance.currentUser;
      
      if (firebaseUser != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(firebaseUser.uid)
            .get();
            
        if (doc.exists) {
          setState(() {
            _currentUser = User.fromMap(doc.data()!);
            _updateControllers();
          });
        }
      }
    } catch (e) {
      print('Erreur lors de la récupération: $e');
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      try {
        final fb_auth.User? firebaseUser = fb_auth.FirebaseAuth.instance.currentUser;
        
        if (firebaseUser != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(firebaseUser.uid)
              .update({
                'name': _nameController.text,
                'phone': _phoneController.text,
                'address': _addressController.text,
              });
              
          setState(() {
            _isEditing = false;
            _currentUser = User(
              name: _nameController.text,
              email: _emailController.text,
              phone: _phoneController.text,
              address: _addressController.text,
              joinDate: _user?.joinDate ?? '',
              avatar: _user?.avatar,
            );
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profil mis à jour avec succès'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la mise à jour: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      return Scaffold(
        backgroundColor: _backgroundWhite,
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: _backgroundWhite,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            backgroundColor: _primaryBlue,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              if (!_isLoading)
                IconButton(
                  icon: Icon(_isEditing ? Icons.save : Icons.edit, color: Colors.white),
                  onPressed: () {
                    if (_isEditing) {
                      _saveProfile();
                    } else {
                      setState(() => _isEditing = true);
                    }
                  },
                ),
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  ),
                ),
            ],
         flexibleSpace: FlexibleSpaceBar(
      collapseMode: CollapseMode.pin,
      background: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/drawer_design2.png'),
            fit: BoxFit.cover,
          
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                onTap: _isEditing ? _pickAndUploadImage : null,
                child: CircleAvatar(
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
                              return Icon(
                                Icons.person,
                                size: 50,
                                color: _primaryBlue,
                              );
                            },
                          )
                        : Icon(
                            Icons.person,
                            size: 50,
                            color: _primaryBlue,
                          ),
                  ),
                ),
              ),
                      const SizedBox(height: 16),
                      Text(
                        _user!.name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _user!.email,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(24.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Informations personnelles',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _primaryBlue,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildEditableField(
                        context,
                        icon: Icons.person_outline,
                        label: 'Nom complet',
                        controller: _nameController,
                        isEditing: _isEditing,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer votre nom';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildEditableField(
                        context,
                        icon: Icons.email_outlined,
                        label: 'Email',
                        controller: _emailController,
                        isEditing: false,
                      ),
                      const SizedBox(height: 16),
                      _buildEditableField(
                        context,
                        icon: Icons.phone_outlined,
                        label: 'Téléphone',
                        controller: _phoneController,
                        isEditing: _isEditing,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 16),
                      _buildEditableField(
                        context,
                        icon: Icons.location_on_outlined,
                        label: 'Adresse',
                        controller: _addressController,
                        isEditing: _isEditing,
                      ),
                      const SizedBox(height: 24),
                      if (!_isEditing)
                        ElevatedButton(
                          onPressed: () => _showChangePasswordDialog(context),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            backgroundColor: _primaryBlue,
                          ),
                          child: const Text(
                            'Changer le mot de passe',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                          ),
                        ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

void _showChangePasswordDialog(BuildContext context) {
  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock_reset, size: 60, color: _primaryBlue),
            const SizedBox(height: 16),
            Text('Changer le mot de passe',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _primaryBlue,
                )),
            const SizedBox(height: 24),
            TextFormField(
              controller: oldPasswordController,
              obscureText: true,
              decoration: _inputDecoration('Ancien mot de passe', Icons.lock_outline),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: newPasswordController,
              obscureText: true,
              decoration: _inputDecoration('Nouveau mot de passe', Icons.lock_outline),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: _inputDecoration('Confirmer le mot de passe', Icons.lock_outline),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Annuler'),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () async {
                    if (newPasswordController.text != confirmPasswordController.text) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Les mots de passe ne correspondent pas'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    try {
                      final user = fb_auth.FirebaseAuth.instance.currentUser;
                      if (user != null) {
                        final cred = fb_auth.EmailAuthProvider.credential(
                          email: user.email!,
                          password: oldPasswordController.text,
                        );

                        await user.reauthenticateWithCredential(cred);
                        await user.updatePassword(newPasswordController.text);

                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Mot de passe changé avec succès'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } on fb_auth.FirebaseAuthException catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Erreur: ${e.message}'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.check),
                  label: const Text('Enregistrer'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}


  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: _textGrey),
      prefixIcon: Icon(icon, color: _primaryBlue),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _inputBorderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _inputBorderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _primaryBlue, width: 2),
      ),
      filled: true,
      fillColor: _inputFillColor,
    );
  }

  Widget _buildEditableField(
    BuildContext context, {
    required IconData icon,
    required String label,
    TextEditingController? controller,
    bool isEditing = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return isEditing
        ? TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            validator: validator,
            decoration: _inputDecoration(label, icon),
          )
        : Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: _inputFillColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _inputBorderColor),
            ),
            child: Row(
              children: [
                Icon(icon, color: _primaryBlue),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 12,
                          color: _textGrey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        controller?.text ?? '',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
  }
}