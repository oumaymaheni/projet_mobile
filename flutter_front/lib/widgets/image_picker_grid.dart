// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';

// class ImagePickerGrid extends StatefulWidget {
//   final List<String> initialImages;
//   final void Function(List<String>) onImagesPicked;
  
//   const ImagePickerGrid({
//     super.key,
//     required this.onImagesPicked,
//     this.initialImages = const [],
//   });

//   @override
//   State<ImagePickerGrid> createState() => _ImagePickerGridState();
// }

// class _ImagePickerGridState extends State<ImagePickerGrid> {
//   late List<String> _imageUrls;
//   final ImagePicker _picker = ImagePicker();
//   bool _isUploading = false;

//   @override
//   void initState() {
//     super.initState();
//     _imageUrls = List.from(widget.initialImages);
//   }

//   Future<void> _pickImages() async {
//     if (_isUploading) return;

//     setState(() => _isUploading = true);
    
//     try {
//       final pickedFiles = await _picker.pickMultiImage(
//         maxWidth: 1920,
//         maxHeight: 1080,
//         imageQuality: 85,
//       );

//       if (pickedFiles.isNotEmpty) {
//         // Simuler l'upload - remplacer par votre logique réelle
//         await Future.delayed(const Duration(seconds: 1));
        
//         final newUrls = List<String>.generate(
//           pickedFiles.length,
//           (index) => 'https://picsum.photos/500/300?random=$index',
//         );

//         setState(() {
//           _imageUrls.addAll(newUrls);
//         });
//         widget.onImagesPicked(_imageUrls);
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Erreur: ${e.toString()}')),
//       );
//     } finally {
//       setState(() => _isUploading = false);
//     }
//   }

//   void _removeImage(int index) {
//     final removedUrl = _imageUrls[index];
//     setState(() {
//       _imageUrls.removeAt(index);
//     });
//     widget.onImagesPicked(_imageUrls);
    
//     // Ici vous pourriez supprimer le fichier du stockage
//     debugPrint('Image à supprimer du stockage: $removedUrl');
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         ElevatedButton.icon(
//           onPressed: _isUploading ? null : _pickImages,
//           icon: _isUploading
//               ? const SizedBox(
//                   width: 20,
//                   height: 20,
//                   child: CircularProgressIndicator(strokeWidth: 2),
//                 )
//               : const Icon(Icons.add_photo_alternate),
//           label: Text(_isUploading ? 'Envoi...' : 'Ajouter photos'),
//         ),
        
//         const SizedBox(height: 12),
        
//         if (_imageUrls.isNotEmpty)
//           GridView.builder(
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             itemCount: _imageUrls.length,
//             gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: 3,
//               crossAxisSpacing: 8,
//               mainAxisSpacing: 8,
//             ),
//             itemBuilder: (context, index) => Stack(
//               fit: StackFit.expand,
//               children: [
//                 Image.network(
//                   _imageUrls[index],
//                   fit: BoxFit.cover,
//                   loadingBuilder: (_, child, progress) =>
//                     progress == null ? child : const Center(
//                       child: CircularProgressIndicator(),
//                     ),
//                   errorBuilder: (_, __, ___) => const Icon(Icons.error),
//                 ),
//                 Positioned(
//                   top: 4,
//                   right: 4,
//                   child: IconButton(
//                     icon: const Icon(Icons.close, size: 20),
//                     onPressed: () => _removeImage(index),
//                     style: IconButton.styleFrom(
//                       backgroundColor: Colors.black54,
//                       padding: EdgeInsets.zero,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//       ],
//     );
//   }
// }

// image_picker_grid.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/image_uploader.dart';

class ImagePickerGrid extends StatefulWidget {
  final void Function(List<String>) onImagesPicked;
  final List<String> initialImages;

  const ImagePickerGrid({
    super.key,
    this.initialImages = const [],
    required this.onImagesPicked,
  });

  @override
  State<ImagePickerGrid> createState() => _ImagePickerGridState();
}

class _ImagePickerGridState extends State<ImagePickerGrid> {
  late List<String> _imageUrls;
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;
  

  @override
  void initState() {
    super.initState();
    // Créer une nouvelle liste pour éviter les références partagées
    _imageUrls = List<String>.from(widget.initialImages);
    debugPrint('ImagePickerGrid - Images initiales: $_imageUrls');
  }

  // S'assurer que les changements dans le widget sont reflétés si les propriétés changent
  @override
  void didUpdateWidget(ImagePickerGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(oldWidget.initialImages, widget.initialImages)) {
      setState(() {
        _imageUrls = List<String>.from(widget.initialImages);
        debugPrint('ImagePickerGrid - Images mises à jour: $_imageUrls');
      });
    }
  }

  Future<void> _pickAndUploadImages() async {
    setState(() => _isUploading = true);
    
    try {
      final pickedFiles = await _picker.pickMultiImage();
      if (pickedFiles.isEmpty) {
        setState(() => _isUploading = false);
        return;
      }

      List<String> newUrls = List<String>.from(_imageUrls);

      for (final xFile in pickedFiles) {
        try {
          String? url;
          
          if (kIsWeb) {
            // Pour le web, nous devons lire les bytes
            final bytes = await xFile.readAsBytes();
            final imageFile = ImageFile(
              file: xFile,
              bytes: bytes,
              name: xFile.name,
            );
            url = await ImageUploader.uploadImage(imageFile);
          } else {
            // Pour mobile
            final imageFile = ImageFile(
              file: xFile,
              path: xFile.path,
              name: xFile.name,
            );
            url = await ImageUploader.uploadImage(imageFile);
          }
          
          // S'assurer d'ajouter uniquement les URLs non-nulles
          if (url != null && url.isNotEmpty) {
            newUrls.add(url);
            debugPrint('Image téléchargée: $url');
          }
        } catch (e) {
          debugPrint('Erreur de téléchargement: $e');
          // Afficher un message d'erreur à l'utilisateur
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Échec du téléchargement d\'une image: $e')),
            );
          }
        }
      }
      
      // Mettre à jour l'état local
      setState(() {
        _imageUrls = newUrls;
        _isUploading = false;
      });
      
      // Informer le parent des nouvelles URLs
      widget.onImagesPicked(_imageUrls);
      debugPrint('ImagePickerGrid - Images mises à jour envoyées au parent: $_imageUrls');
    } catch (e) {
      debugPrint('Erreur de sélection d\'image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la sélection des images: $e')),
        );
      }
      setState(() => _isUploading = false);
    }
  }

  void _removeImage(int index) {
    setState(() {
      _imageUrls.removeAt(index);
    });
    widget.onImagesPicked(_imageUrls);
    debugPrint('Image supprimée, nouvelles images: $_imageUrls');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ElevatedButton.icon(
          onPressed: _isUploading ? null : _pickAndUploadImages,
          icon: _isUploading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.photo_library),
          label: Text(_isUploading ? "Upload en cours..." : "Ajouter des photos"),
        ),
        const SizedBox(height: 10),
        if (_imageUrls.isNotEmpty) ...[
          Text("${_imageUrls.length} image(s) sélectionnée(s)", 
               style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _imageUrls.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
            ),
            itemBuilder: (_, index) => Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    _imageUrls[index],
                    fit: BoxFit.cover,
                    loadingBuilder: (_, child, progress) =>
                      progress == null ? child : const Center(child: CircularProgressIndicator()),
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.error, color: Colors.red),
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => _removeImage(index),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black54,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ] else
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text("Aucune image sélectionnée", 
                     style: TextStyle(fontStyle: FontStyle.italic)),
          ),
      ],
    );
  }
}