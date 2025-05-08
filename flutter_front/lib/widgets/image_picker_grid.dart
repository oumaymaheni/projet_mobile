// image_picker_grid.dart
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../services/image_uploader.dart';

class ImagePickerGrid extends StatefulWidget {
  final void Function(List<String>) onImagesPicked;
  const ImagePickerGrid({super.key, required this.onImagesPicked});

  @override
  State<ImagePickerGrid> createState() => _ImagePickerGridState();
}

class _ImagePickerGridState extends State<ImagePickerGrid> {
  final List<String> _imageUrls = [];
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  Future<void> _pickAndUploadImages() async {
    setState(() => _isUploading = true);
    
    try {
      final pickedFiles = await _picker.pickMultiImage();
      if (pickedFiles.isEmpty) {
        setState(() => _isUploading = false);
        return;
      }

      for (final xFile in pickedFiles) {
        try {
          String? url;
          
          if (kIsWeb) {
            // For web, we need to read bytes
            final bytes = await xFile.readAsBytes();
            final imageFile = ImageFile(
              file: xFile,
              bytes: bytes,
              name: xFile.name,
            );
            url = await ImageUploader.uploadImage(imageFile);
          } else {
            // For mobile
            final imageFile = ImageFile(
              file: xFile,
              path: xFile.path,
              name: xFile.name,
            );
            url = await ImageUploader.uploadImage(imageFile);
          }
          
          // Make sure we only add non-null URLs
          if (url != null && url.isNotEmpty) {
            setState(() {
              _imageUrls.add(url!); // Correction ici
            });
          }
        } catch (e) {
          debugPrint('Upload error: $e');
          // Show an error message to the user
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to upload an image: $e')),
            );
          }
        }
      }
      
      // Update the parent with the new URLs
      widget.onImagesPicked(_imageUrls);
    } catch (e) {
      debugPrint('Image picking error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error selecting images: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
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
        if (_imageUrls.isNotEmpty)
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
                Image.network(
                  _imageUrls[index],
                  fit: BoxFit.cover,
                  loadingBuilder: (_, child, progress) =>
                    progress == null ? child : const Center(child: CircularProgressIndicator()),
                  errorBuilder: (_, __, ___) => const Icon(Icons.error),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () {
                      setState(() {
                        _imageUrls.removeAt(index);
                      });
                      widget.onImagesPicked(_imageUrls);
                    },
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black54,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}