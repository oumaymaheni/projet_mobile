// post_house_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; 
import 'package:latlong2/latlong.dart';
import 'package:uuid/uuid.dart';
import '../models/maison_models.dart';
import '../services/firebase_service.dart';
import '../widgets/map_picker.dart';
import '../widgets/image_picker_grid.dart';

class PostHouseScreen extends StatefulWidget {
  const PostHouseScreen({super.key});

  @override
  State<PostHouseScreen> createState() => _PostHouseScreenState();
}

class _PostHouseScreenState extends State<PostHouseScreen> {
  final _formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final priceController = TextEditingController();
  final surfaceController = TextEditingController();
  final bedroomsController = TextEditingController();
  final bathroomsController = TextEditingController();
  final localityController = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final pinCodeController = TextEditingController();
  final houseNoController = TextEditingController();
  final societyController = TextEditingController();
  final user = FirebaseAuth.instance.currentUser;

  final kBlueColor = Colors.blue.shade700;
  List<String> _imageUrls = [];
  LatLng? _pickedLocation;
  bool _isSubmitting = false;

  Widget _buildStyledField(
    String label,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    bool required = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator ?? (required 
          ? (val) => val == null || val.isEmpty ? 'Requis' : null 
          : null),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: kBlueColor),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: kBlueColor, width: 2),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade400),
          ),
        ),
      ),
    );
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs requis')),
      );
      return;
    }
    
    if (_pickedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner un emplacement sur la carte')),
      );
      return;
    }
    
    if (_imageUrls.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez ajouter au moins une image')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    
    try {
      final house = House(
        id: const Uuid().v4(),
        title: titleController.text,
        address: '${houseNoController.text}, ${societyController.text}, '
                '${localityController.text}, ${cityController.text}',
        price: int.tryParse(priceController.text) ?? 0,
        bedrooms: int.tryParse(bedroomsController.text) ?? 0,
        bathrooms: int.tryParse(bathroomsController.text) ?? 0,
        surface: int.tryParse(surfaceController.text) ?? 0,
        imageUrls: _imageUrls,
        rating: 0,
        isFavorite: false,
        locality: localityController.text,
        city: cityController.text,
        state: stateController.text,
        pinCode: pinCodeController.text.isNotEmpty ? pinCodeController.text : null,
        houseNo: houseNoController.text,
        society: societyController.text,
        latitude: _pickedLocation!.latitude,
        longitude: _pickedLocation!.longitude,
        createdAt: DateTime.now(),
        publisher: user?.uid ?? 'unknown',
      );
      
      await FirebaseService.addHouse(house);
      
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Maison publiée avec succès')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la publication: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Publier une Maison"),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section Informations principales
                Card(
                  elevation: 3,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(
                          'INFORMATIONS PRINCIPALES',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: kBlueColor,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildStyledField(
                          "Titre de l'annonce*",
                          titleController,
                          required: true,
                        ),
                        _buildStyledField(
                          "Prix*",
                          priceController,
                          keyboardType: TextInputType.number,
                          required: true,
                        ),
                        _buildStyledField(
                          "Surface (m²)*",
                          surfaceController,
                          keyboardType: TextInputType.number,
                          required: true,
                        ),
                        _buildStyledField(
                          "Chambres*",
                          bedroomsController,
                          keyboardType: TextInputType.number,
                          required: true,
                        ),
                        _buildStyledField(
                          "Salles de bain*",
                          bathroomsController,
                          keyboardType: TextInputType.number,
                          required: true,
                        ),
                      ],
                    ),
                  ),
                ),

                // Section Adresse
                Card(
                  elevation: 3,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ADRESSE',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: kBlueColor,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildStyledField('N° de maison*', houseNoController, required: true),
                        _buildStyledField('Nom de la société', societyController),
                        _buildStyledField('Quartier*', localityController, required: true),
                        _buildStyledField('Ville*', cityController, required: true),
                        _buildStyledField('État*', stateController, required: true),
                        _buildStyledField(
                          'Code postal',
                          pinCodeController,
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),
                  ),
                ),

                // Section Carte
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'EMPLACEMENT SUR LA CARTE*',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: kBlueColor,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text('Sélectionnez l\'emplacement exact sur la carte'),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 200,
                          child: MapPicker(
                            onLocationPicked: (pos) => _pickedLocation = pos,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Section Images
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'IMAGES*',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: kBlueColor,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ImagePickerGrid(
                          onImagesPicked: (List<String> imageUrls) {
                            setState(() {
                              _imageUrls = imageUrls;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Bouton de soumission
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kBlueColor,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: _isSubmitting ? null : _submit,
                    child: _isSubmitting 
                      ? const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 10),
                            Text(
                              "Publication en cours...",
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        )
                      : const Text(
                          "PUBLIER LA MAISON",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

