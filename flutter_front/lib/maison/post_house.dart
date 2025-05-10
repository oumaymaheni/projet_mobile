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

  final Color primaryColor = const Color(
    0xFF2979FF,
  ); // Couleur principale plus moderne
  final Color secondaryColor = const Color(0xFF3F37C9); // Couleur secondaire
  final Color accentColor = const Color(0xFF4CC9F0); // Couleur d'accentuation

  List<String> _imageUrls = [];
  LatLng? _pickedLocation;
  bool _isSubmitting = false;
  int _currentStep = 0; // Pour le stepper

  // Couleurs adaptatives pour le thème sombre
  Color get scaffoldBackgroundColor =>
      Theme.of(context).scaffoldBackgroundColor;
  Color get cardColor => Theme.of(context).cardColor;
  Color get textColor => Theme.of(context).textTheme.bodyLarge!.color!;
  Color get hintColor => Theme.of(context).hintColor;
  Color get borderColor => Theme.of(context).dividerColor;

  // Liste des étapes pour le stepper
  List<Step> _buildSteps() {
    return [
      Step(
        title: const Text('Infos principales'),
        content: _buildMainInfoSection(),
        isActive: _currentStep >= 0,
      ),
      Step(
        title: const Text('Adresse'),
        content: _buildAddressSection(),
        isActive: _currentStep >= 1,
      ),
      Step(
        title: const Text('Localisation'),
        content: _buildLocationSection(),
        isActive: _currentStep >= 2,
      ),
      Step(
        title: const Text('Photos'),
        content: _buildPhotosSection(),
        isActive: _currentStep >= 3,
      ),
    ];
  }

  Widget _buildStyledField(
    String label,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    bool required = false,
    String? hintText,
    IconData? prefixIcon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator:
            validator ??
            (required
                ? (val) =>
                    val == null || val.isEmpty ? 'Ce champ est requis' : null
                : null),
        style: TextStyle(color: textColor),
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          labelStyle: TextStyle(color: hintColor),
          hintStyle: TextStyle(color: hintColor),
          prefixIcon:
              prefixIcon != null
                  ? Icon(prefixIcon, size: 20, color: hintColor)
                  : null,
          filled: true,
          fillColor: cardColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: primaryColor, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez remplir tous les champs requis'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_pickedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner un emplacement sur la carte'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_imageUrls.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez ajouter au moins une image'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final house = House(
        id: const Uuid().v4(),
        title: titleController.text,
        address:
            '${houseNoController.text}, ${societyController.text}, '
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
        pinCode:
            pinCodeController.text.isNotEmpty ? pinCodeController.text : null,
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
          SnackBar(
            content: const Text('Annonce publiée avec succès'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green.shade600,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red.shade600,
          ),
        );
      }
    }
  }

  Widget _buildMainInfoSection() {
    return Column(
      children: [
        _buildStyledField(
          "Titre de l'annonce*",
          titleController,
          required: true,
          hintText: "Ex: Belle maison avec jardin",
          prefixIcon: Icons.title,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStyledField(
                "Prix*",
                priceController,
                keyboardType: TextInputType.number,
                required: true,
                hintText: "Ex: 250000",
                prefixIcon: Icons.euro,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStyledField(
                "Surface (m²)*",
                surfaceController,
                keyboardType: TextInputType.number,
                required: true,
                hintText: "Ex: 120",
                prefixIcon: Icons.aspect_ratio,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStyledField(
                "Chambres*",
                bedroomsController,
                keyboardType: TextInputType.number,
                required: true,
                hintText: "Ex: 3",
                prefixIcon: Icons.bed,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStyledField(
                "Salles de bain*",
                bathroomsController,
                keyboardType: TextInputType.number,
                required: true,
                hintText: "Ex: 2",
                prefixIcon: Icons.bathtub,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAddressSection() {
    return Column(
      children: [
        _buildStyledField(
          'N° de maison*',
          houseNoController,
          required: true,
          hintText: "Ex: 12B",
          prefixIcon: Icons.home,
        ),
        const SizedBox(height: 12),
        _buildStyledField(
          'Nom de la société',
          societyController,
          hintText: "Ex: Résidence Les Jardins",
          prefixIcon: Icons.apartment,
        ),
        const SizedBox(height: 12),
        _buildStyledField(
          'Quartier*',
          localityController,
          required: true,
          hintText: "Ex: Quartier des Fleurs",
          prefixIcon: Icons.location_city,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStyledField(
                'Ville*',
                cityController,
                required: true,
                hintText: "Ex: Paris",
                prefixIcon: Icons.location_city,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStyledField(
                'État*',
                stateController,
                required: true,
                hintText: "Ex: Île-de-France",
                prefixIcon: Icons.map,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildStyledField(
          'Code postal',
          pinCodeController,
          keyboardType: TextInputType.number,
          hintText: "Ex: 75001",
          prefixIcon: Icons.markunread_mailbox,
        ),
      ],
    );
  }

  Widget _buildLocationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sélectionnez l\'emplacement exact sur la carte',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 300,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: MapPicker(onLocationPicked: (pos) => _pickedLocation = pos),
          ),
        ),
        if (_pickedLocation != null) ...[
          const SizedBox(height: 12),
          Text(
            'Emplacement sélectionné:',
            style: TextStyle(color: primaryColor),
          ),
          Text(
            'Lat: ${_pickedLocation!.latitude.toStringAsFixed(4)}, '
            'Lng: ${_pickedLocation!.longitude.toStringAsFixed(4)}',
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ],
    );
  }

  Widget _buildPhotosSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ajoutez au moins 3 photos de qualité',
          style: TextStyle(color: Colors.grey.shade600),
        ),
        const SizedBox(height: 12),
        ImagePickerGrid(
          onImagesPicked: (List<String> imageUrls) {
            setState(() {
              _imageUrls = imageUrls;
            });
          },
        ),
        if (_imageUrls.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            '${_imageUrls.length} photo(s) sélectionnée(s)',
            style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
          ),
        ],
      ],
    );
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Publier une annonce"),
        centerTitle: true,
        elevation: 0,
      ),
      body: Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Theme.of(context).brightness,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Stepper(
                  currentStep: _currentStep,
                  onStepTapped: (step) => setState(() => _currentStep = step),
                  controlsBuilder:
                      (context, details) => const SizedBox.shrink(),
                  steps: _buildSteps(),
                ),

                const Spacer(),

                Row(
                  children: [
                    if (_currentStep > 0)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => setState(() => _currentStep--),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: BorderSide(color: primaryColor),
                          ),
                          child: Text(
                            'PRÉCÉDENT',
                            style: TextStyle(color: primaryColor),
                          ),
                        ),
                      ),
                    if (_currentStep > 0) const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (_currentStep < _buildSteps().length - 1) {
                            setState(() => _currentStep++);
                          } else {
                            _submit();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              _currentStep == _buildSteps().length - 1
                                  ? Colors.green
                                  : primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          _currentStep == _buildSteps().length - 1
                              ? 'PUBLIER L\'ANNONCE'
                              : 'SUIVANT',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// // post_house_screen.dart
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart'; 
// import 'package:latlong2/latlong.dart';
// import 'package:uuid/uuid.dart';
// import '../models/maison_models.dart';
// import '../services/firebase_service.dart';
// import '../widgets/map_picker.dart';
// import '../widgets/image_picker_grid.dart';

// class PostHouseScreen extends StatefulWidget {
//   const PostHouseScreen({super.key});

//   @override
//   State<PostHouseScreen> createState() => _PostHouseScreenState();
// }

// class _PostHouseScreenState extends State<PostHouseScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final titleController = TextEditingController();
//   final priceController = TextEditingController();
//   final surfaceController = TextEditingController();
//   final bedroomsController = TextEditingController();
//   final bathroomsController = TextEditingController();
//   final localityController = TextEditingController();
//   final cityController = TextEditingController();
//   final stateController = TextEditingController();
//   final pinCodeController = TextEditingController();
//   final houseNoController = TextEditingController();
//   final societyController = TextEditingController();
//   final user = FirebaseAuth.instance.currentUser;

//   final kBlueColor = Colors.blue.shade700;
//   List<String> _imageUrls = [];
//   LatLng? _pickedLocation;
//   bool _isSubmitting = false;

//   Widget _buildStyledField(
//     String label,
//     TextEditingController controller, {
//     TextInputType keyboardType = TextInputType.text,
//     String? Function(String?)? validator,
//     bool required = false,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: TextFormField(
//         controller: controller,
//         keyboardType: keyboardType,
//         validator: validator ?? (required 
//           ? (val) => val == null || val.isEmpty ? 'Requis' : null 
//           : null),
//         decoration: InputDecoration(
//           labelText: label,
//           labelStyle: TextStyle(color: kBlueColor),
//           focusedBorder: UnderlineInputBorder(
//             borderSide: BorderSide(color: kBlueColor, width: 2),
//           ),
//           enabledBorder: UnderlineInputBorder(
//             borderSide: BorderSide(color: Colors.grey.shade400),
//           ),
//         ),
//       ),
//     );
//   }

//   void _submit() async {
//     if (!_formKey.currentState!.validate()) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Veuillez remplir tous les champs requis')),
//       );
//       return;
//     }
    
//     if (_pickedLocation == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Veuillez sélectionner un emplacement sur la carte')),
//       );
//       return;
//     }
    
//     if (_imageUrls.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Veuillez ajouter au moins une image')),
//       );
//       return;
//     }

//     setState(() => _isSubmitting = true);
    
//     try {
//       final house = House(
//         id: const Uuid().v4(),
//         title: titleController.text,
//         address: '${houseNoController.text}, ${societyController.text}, '
//                 '${localityController.text}, ${cityController.text}',
//         price: int.tryParse(priceController.text) ?? 0,
//         bedrooms: int.tryParse(bedroomsController.text) ?? 0,
//         bathrooms: int.tryParse(bathroomsController.text) ?? 0,
//         surface: int.tryParse(surfaceController.text) ?? 0,
//         imageUrls: _imageUrls,
//         rating: 0,
//         isFavorite: false,
//         locality: localityController.text,
//         city: cityController.text,
//         state: stateController.text,
//         pinCode: pinCodeController.text.isNotEmpty ? pinCodeController.text : null,
//         houseNo: houseNoController.text,
//         society: societyController.text,
//         latitude: _pickedLocation!.latitude,
//         longitude: _pickedLocation!.longitude,
//         createdAt: DateTime.now(),
//         publisher: user?.uid ?? 'unknown',
//       );
      
//       await FirebaseService.addHouse(house);
      
//       if (mounted) {
//         Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Maison publiée avec succès')),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() => _isSubmitting = false);
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Erreur lors de la publication: $e')),
//         );
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Publier une Maison"),
//         elevation: 0,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: SingleChildScrollView(
//           child: Form(
//             key: _formKey,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Section Informations principales
//                 Card(
//                   elevation: 3,
//                   margin: const EdgeInsets.only(bottom: 16),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12)),
//                   child: Padding(
//                     padding: const EdgeInsets.all(16.0),
//                     child: Column(
//                       children: [
//                         Text(
//                           'INFORMATIONS PRINCIPALES',
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                             color: kBlueColor,
//                           ),
//                         ),
//                         const SizedBox(height: 12),
//                         _buildStyledField(
//                           "Titre de l'annonce*",
//                           titleController,
//                           required: true,
//                         ),
//                         _buildStyledField(
//                           "Prix*",
//                           priceController,
//                           keyboardType: TextInputType.number,
//                           required: true,
//                         ),
//                         _buildStyledField(
//                           "Surface (m²)*",
//                           surfaceController,
//                           keyboardType: TextInputType.number,
//                           required: true,
//                         ),
//                         _buildStyledField(
//                           "Chambres*",
//                           bedroomsController,
//                           keyboardType: TextInputType.number,
//                           required: true,
//                         ),
//                         _buildStyledField(
//                           "Salles de bain*",
//                           bathroomsController,
//                           keyboardType: TextInputType.number,
//                           required: true,
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),

//                 // Section Adresse
//                 Card(
//                   elevation: 3,
//                   margin: const EdgeInsets.only(bottom: 16),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12)),
//                   child: Padding(
//                     padding: const EdgeInsets.all(16.0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'ADRESSE',
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                             color: kBlueColor,
//                           ),
//                         ),
//                         const SizedBox(height: 12),
//                         _buildStyledField('N° de maison*', houseNoController, required: true),
//                         _buildStyledField('Nom de la société', societyController),
//                         _buildStyledField('Quartier*', localityController, required: true),
//                         _buildStyledField('Ville*', cityController, required: true),
//                         _buildStyledField('État*', stateController, required: true),
//                         _buildStyledField(
//                           'Code postal',
//                           pinCodeController,
//                           keyboardType: TextInputType.number,
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),

//                 // Section Carte
//                 Card(
//                   elevation: 3,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12)),
//                   child: Padding(
//                     padding: const EdgeInsets.all(16.0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'EMPLACEMENT SUR LA CARTE*',
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                             color: kBlueColor,
//                           ),
//                         ),
//                         const SizedBox(height: 12),
//                         const Text('Sélectionnez l\'emplacement exact sur la carte'),
//                         const SizedBox(height: 12),
//                         SizedBox(
//                           height: 200,
//                           child: MapPicker(
//                             onLocationPicked: (pos) => _pickedLocation = pos,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),

//                 const SizedBox(height: 16),

//                 // Section Images
//                 Card(
//                   elevation: 3,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12)),
//                   child: Padding(
//                     padding: const EdgeInsets.all(16.0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'IMAGES*',
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                             color: kBlueColor,
//                           ),
//                         ),
//                         const SizedBox(height: 12),
//                         ImagePickerGrid(
//                           onImagesPicked: (List<String> imageUrls) {
//                             setState(() {
//                               _imageUrls = imageUrls;
//                             });
//                           },
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),

//                 const SizedBox(height: 24),

//                 // Bouton de soumission
//                 Center(
//                   child: ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: kBlueColor,
//                       padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                     ),
//                     onPressed: _isSubmitting ? null : _submit,
//                     child: _isSubmitting 
//                       ? const Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             SizedBox(
//                               width: 20,
//                               height: 20,
//                               child: CircularProgressIndicator(
//                                 strokeWidth: 2,
//                                 color: Colors.white,
//                               ),
//                             ),
//                             SizedBox(width: 10),
//                             Text(
//                               "Publication en cours...",
//                               style: TextStyle(color: Colors.white),
//                             ),
//                           ],
//                         )
//                       : const Text(
//                           "PUBLIER LA MAISON",
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

