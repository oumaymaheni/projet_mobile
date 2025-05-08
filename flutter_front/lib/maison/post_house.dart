// post_house_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; 
import 'package:latlong2/latlong.dart';
import 'package:uuid/uuid.dart';
import '../models/maison_models.dart';
import '../services/firebase_service.dart';
import '../widgets/post_form.dart';
import '../widgets/map_picker.dart';
import '../widgets/image_picker_grid.dart';
import 'form_section.dart';

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

  List<String> _imageUrls = []; // Store image URLs directly
  LatLng? _pickedLocation;
  bool _isSubmitting = false;

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
      final houseId = const Uuid().v4();
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
        publisher: user?.uid ?? 'unknown', // Gestion du cas null
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
      appBar: AppBar(title: const Text("Publier une Maison")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: "Titre de l'annonce"),
                  validator: (val) => val == null || val.isEmpty ? 'Requis' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: priceController,
                  decoration: const InputDecoration(labelText: "Prix"),
                  keyboardType: TextInputType.number,
                  validator: (val) => val == null || val.isEmpty ? 'Requis' : null,
                ),
                TextFormField(
                  controller: surfaceController,
                  decoration: const InputDecoration(labelText: "Surface (m²)"),
                  keyboardType: TextInputType.number,
                  validator: (val) => val == null || val.isEmpty ? 'Requis' : null,
                ),
                TextFormField(
                  controller: bedroomsController,
                  decoration: const InputDecoration(labelText: "Chambres"),
                  keyboardType: TextInputType.number,
                  validator: (val) => val == null || val.isEmpty ? 'Requis' : null,
                ),
                TextFormField(
                  controller: bathroomsController,
                  decoration: const InputDecoration(labelText: "Salles de bain"),
                  keyboardType: TextInputType.number,
                  validator: (val) => val == null || val.isEmpty ? 'Requis' : null,
                ),
                const SizedBox(height: 16),
                PostForm(
                  localityController: localityController,
                  cityController: cityController,
                  stateController: stateController,
                  pinCodeController: pinCodeController,
                  houseNoController: houseNoController,
                  societyController: societyController,
                ),
                const SizedBox(height: 16),
                MapPicker(
                  onLocationPicked: (pos) => _pickedLocation = pos,
                ),
                const SizedBox(height: 16),
                ImagePickerGrid(
                  onImagesPicked: (List<String> imageUrls) {
                    setState(() {
                      _imageUrls = imageUrls;
                    });
                  },
                ),
                const SizedBox(height: 16),
                Center(
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submit,
                    child: _isSubmitting 
                      ? const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            SizedBox(width: 10),
                            Text("Publication en cours..."),
                          ],
                        )
                      : const Text("Publier la maison"),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}