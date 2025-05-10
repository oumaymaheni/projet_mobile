import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../models/maison_models.dart';
import '../services/firebase_service.dart';
import '../widgets/image_picker_grid.dart';
import '../widgets/map_picker.dart';

class EditHouseScreen extends StatefulWidget {
  final House house;

  const EditHouseScreen({Key? key, required this.house}) : super(key: key);

  @override
  State<EditHouseScreen> createState() => _EditHouseScreenState();
}

class _EditHouseScreenState extends State<EditHouseScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _priceController;
  late TextEditingController _surfaceController;
  late TextEditingController _bedroomsController;
  late TextEditingController _bathroomsController;
  late TextEditingController _addressController;

  late List<String> _imageUrls;
  LatLng? _pickedLocation;
  bool _isSubmitting = false;

  // Couleurs personnalisées
  final Color _primaryColor = const Color(0xFF2979FF);
  final Color _accentColor = Colors.orange.shade600;
  final Color _backgroundColor = Colors.grey.shade50;
  final Color _buttonTextColor = Colors.grey.shade50;
  final Color _appBarIconColor = const Color.fromARGB(255, 255, 255, 255);

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.house.title);
    _priceController = TextEditingController(
      text: widget.house.price.toString(),
    );
    _surfaceController = TextEditingController(
      text: widget.house.surface.toString(),
    );
    _bedroomsController = TextEditingController(
      text: widget.house.bedrooms.toString(),
    );
    _bathroomsController = TextEditingController(
      text: widget.house.bathrooms.toString(),
    );
    _addressController = TextEditingController(text: widget.house.address);

    _imageUrls = List<String>.from(widget.house.imageUrls);
    _pickedLocation = LatLng(widget.house.latitude, widget.house.longitude);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final updates = {
        'title': _titleController.text,
        'price': int.parse(_priceController.text),
        'surface': int.parse(_surfaceController.text),
        'bedrooms': int.parse(_bedroomsController.text),
        'bathrooms': int.parse(_bathroomsController.text),
        'address': _addressController.text,
        'imageUrls': _imageUrls,
        'latitude': _pickedLocation?.latitude ?? widget.house.latitude,
        'longitude': _pickedLocation?.longitude ?? widget.house.longitude,
        'updatedAt': DateTime.now(),
      };

      await FirebaseService.updateHouse(widget.house.id, updates);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Annonce mise à jour avec succès'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la modification: $e'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _handleImagesPicked(List<String> images) {
    setState(() {
      _imageUrls = images;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Modifier Annonce',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: _primaryColor,
        iconTheme: IconThemeData(color: _appBarIconColor), // Icônes blanches
        actions: [
          if (_isSubmitting)
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(_appBarIconColor),
                  strokeWidth: 2,
                ),
              ),
            )
          else
            IconButton(
              icon: Icon(
                Icons.save,
                size: 28,
                color: _appBarIconColor,
              ), // Icône blanche
              onPressed: _submit,
              tooltip: 'Enregistrer les modifications',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section Informations de base
              _buildSectionHeader('Informations de base'),
              _buildTextField(_titleController, 'Titre*', Icons.title),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      _priceController,
                      'Prix (DT)*',
                      Icons.attach_money,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: _buildTextField(
                      _surfaceController,
                      'Surface (m²)*',
                      Icons.aspect_ratio,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      _bedroomsController,
                      'Chambres*',
                      Icons.king_bed,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: _buildTextField(
                      _bathroomsController,
                      'Salles de bain*',
                      Icons.bathtub,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              _buildTextField(
                _addressController,
                'Adresse complète*',
                Icons.location_on,
              ),

              const SizedBox(height: 25),

              // Section Photos
              _buildSectionHeader('Photos de l\'annonce'),
              const SizedBox(height: 10),
              ImagePickerGrid(
                initialImages: _imageUrls,
                onImagesPicked: _handleImagesPicked,
              ),

              const SizedBox(height: 25),

              // Section Localisation
              _buildSectionHeader('Localisation'),
              const SizedBox(height: 10),
              Container(
                height: 300,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  // border: Border.all(color: Colors.grey.shade300),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: MapPicker(
                    initialPosition: _pickedLocation,
                    onLocationPicked:
                        (pos) => setState(() => _pickedLocation = pos),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Appuyez longuement sur la carte pour définir l\'emplacement',
                style: TextStyle(
                  color: const Color.fromARGB(255, 78, 77, 77),
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),

              const SizedBox(height: 30),

              // Bouton de soumission
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryColor,
                    foregroundColor: _buttonTextColor, // Couleur du texte
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child:
                      _isSubmitting
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                          : const Text(
                            'ENREGISTRER LES MODIFICATIONS',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: _primaryColor,
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String labelText,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon, color: _primaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: _primaryColor, width: 2),
        ),
        filled: true,
        // fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 16,
        ),
      ),
      keyboardType: keyboardType,
      validator: (value) => value!.isEmpty ? 'Ce champ est requis' : null,
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _surfaceController.dispose();
    _bedroomsController.dispose();
    _bathroomsController.dispose();
    _addressController.dispose();
    super.dispose();
  }
}

// import 'package:flutter/material.dart';
// import 'package:latlong2/latlong.dart';
// import '../models/maison_models.dart';
// import '../services/firebase_service.dart';
// import '../widgets/image_picker_grid.dart';
// import '../widgets/map_picker.dart';

// class EditHouseScreen extends StatefulWidget {
//   final House house;

//   const EditHouseScreen({Key? key, required this.house}) : super(key: key);

//   @override
//   State<EditHouseScreen> createState() => _EditHouseScreenState();
// }

// class _EditHouseScreenState extends State<EditHouseScreen> {
//   final _formKey = GlobalKey<FormState>();
//   late TextEditingController _titleController;
//   late TextEditingController _priceController;
//   late TextEditingController _surfaceController;
//   late TextEditingController _bedroomsController;
//   late TextEditingController _bathroomsController;
//   late TextEditingController _addressController;
  
//   late List<String> _imageUrls;
//   LatLng? _pickedLocation;
//   bool _isSubmitting = false;

//   @override
//   void initState() {
//     super.initState();
//     _titleController = TextEditingController(text: widget.house.title);
//     _priceController = TextEditingController(text: widget.house.price.toString());
//     _surfaceController = TextEditingController(text: widget.house.surface.toString());
//     _bedroomsController = TextEditingController(text: widget.house.bedrooms.toString());
//     _bathroomsController = TextEditingController(text: widget.house.bathrooms.toString());
//     _addressController = TextEditingController(text: widget.house.address);
    
//     // Création d'une nouvelle liste pour éviter les problèmes de référence
//     _imageUrls = List<String>.from(widget.house.imageUrls);
//     debugPrint('EditHouseScreen init - Images: $_imageUrls');
    
//     _pickedLocation = LatLng(widget.house.latitude, widget.house.longitude);
//   }

//   Future<void> _submit() async {
//     if (!_formKey.currentState!.validate()) return;
    
//     setState(() => _isSubmitting = true);

//     try {
//       debugPrint('Soumission - Images à enregistrer: $_imageUrls');
      
//       final updates = {
//         'title': _titleController.text,
//         'price': int.parse(_priceController.text),
//         'surface': int.parse(_surfaceController.text),
//         'bedrooms': int.parse(_bedroomsController.text),
//         'bathrooms': int.parse(_bathroomsController.text),
//         'address': _addressController.text,
//         'imageUrls': _imageUrls,
//         'latitude': _pickedLocation?.latitude ?? widget.house.latitude,
//         'longitude': _pickedLocation?.longitude ?? widget.house.longitude,
//         'updatedAt': DateTime.now(),
//       };

//       await FirebaseService.updateHouse(widget.house.id, updates);
      
//       if (!mounted) return;
      
//       // Afficher un message de confirmation
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Annonce mise à jour avec succès')),
//       );
      
//       Navigator.pop(context, true); // Retourne true pour indiquer une modification réussie
//     } catch (e) {
//       debugPrint('Erreur lors de la mise à jour: $e');
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Erreur lors de la modification: $e')),
//       );
//     } finally {
//       if (mounted) {
//         setState(() => _isSubmitting = false);
//       }
//     }
//   }

//   void _handleImagesPicked(List<String> images) {
//     debugPrint('Images reçues du picker: $images');
//     setState(() {
//       _imageUrls = images;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Modifier Annonce'),
//         actions: [
//           if (_isSubmitting)
//             const Padding(
//               padding: EdgeInsets.all(8.0),
//               child: Center(child: SizedBox(
//                 width: 20, 
//                 height: 20, 
//                 child: CircularProgressIndicator(
//                   strokeWidth: 2,
//                   color: Colors.white,
//                 )
//               )),
//             )
//           else
//             IconButton(
//               icon: const Icon(Icons.save),
//               onPressed: _submit,
//             ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               TextFormField(
//                 controller: _titleController,
//                 decoration: const InputDecoration(labelText: 'Titre*'),
//                 validator: (value) => value!.isEmpty ? 'Ce champ est requis' : null,
//               ),
//               TextFormField(
//                 controller: _priceController,
//                 decoration: const InputDecoration(labelText: 'Prix (DT)*'),
//                 keyboardType: TextInputType.number,
//                 validator: (value) => value!.isEmpty ? 'Ce champ est requis' : null,
//               ),
//               TextFormField(
//                 controller: _surfaceController,
//                 decoration: const InputDecoration(labelText: 'Surface (m²)*'),
//                 keyboardType: TextInputType.number,
//                 validator: (value) => value!.isEmpty ? 'Ce champ est requis' : null,
//               ),
//               Row(
//                 children: [
//                   Expanded(
//                     child: TextFormField(
//                       controller: _bedroomsController,
//                       decoration: const InputDecoration(labelText: 'Chambres*'),
//                       keyboardType: TextInputType.number,
//                       validator: (value) => value!.isEmpty ? 'Requis' : null,
//                     ),
//                   ),
//                   const SizedBox(width: 16),
//                   Expanded(
//                     child: TextFormField(
//                       controller: _bathroomsController,
//                       decoration: const InputDecoration(labelText: 'Salles de bain*'),
//                       keyboardType: TextInputType.number,
//                       validator: (value) => value!.isEmpty ? 'Requis' : null,
//                     ),
//                   ),
//                 ],
//               ),
//               TextFormField(
//                 controller: _addressController,
//                 decoration: const InputDecoration(labelText: 'Adresse*'),
//                 validator: (value) => value!.isEmpty ? 'Ce champ est requis' : null,
//               ),
              
//               const SizedBox(height: 20),
//               const Text('Images de l\'annonce:', style: TextStyle(fontWeight: FontWeight.bold)),
//               ImagePickerGrid(
//                 initialImages: _imageUrls,
//                 onImagesPicked: _handleImagesPicked,
//               ),
              
//               const SizedBox(height: 20),
//               const Text('Localisation:', style: TextStyle(fontWeight: FontWeight.bold)),
//               SizedBox(
//                 height: 300,
//                 child: MapPicker(
//                   initialPosition: _pickedLocation,
//                   onLocationPicked: (pos) => setState(() => _pickedLocation = pos),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _titleController.dispose();
//     _priceController.dispose();
//     _surfaceController.dispose();
//     _bedroomsController.dispose();
//     _bathroomsController.dispose();
//     _addressController.dispose();
//     super.dispose();
//   }
// }