// image_uploader.dart
import 'dart:convert';
import 'dart:typed_data';
import 'dart:io' if (dart.library.html) 'dart:html' as html;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ImageFile {
  final dynamic file; // Could be File (mobile) or html.File (web)
  final Uint8List? bytes;
  final String? path;
  final String name;

  ImageFile({
    required this.file,
    this.bytes,
    this.path,
    required this.name,
  });
}

class ImageUploader {
  static const String _apiKey = '46fdc94ebb8fb966af773d00bc6fc46d';

  static Future<String?> uploadImage(ImageFile image) async {
    final uri = Uri.parse('https://api.imgbb.com/1/upload');
    final request = http.MultipartRequest('POST', uri)
      ..fields['key'] = _apiKey;

    if (kIsWeb) {
      if (image.bytes != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'image',
            image.bytes!,
            filename: image.name,
          ),
        );
      }
    } else {
      // Mobile path
      if (image.path != null) {
        request.files.add(
          await http.MultipartFile.fromPath('image', image.path!),
        );
      }
    }

    return _sendRequest(request);
  }

  static Future<String?> uploadFromBytes(Uint8List bytes, {String filename = 'upload.jpg'}) async {
    final uri = Uri.parse('https://api.imgbb.com/1/upload');
    final request = http.MultipartRequest('POST', uri)
      ..fields['key'] = _apiKey
      ..files.add(http.MultipartFile.fromBytes('image', bytes, filename: filename));

    return _sendRequest(request);
  }

  static Future<String?> _sendRequest(http.MultipartRequest request) async {
    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        final json = jsonDecode(await response.stream.bytesToString());
        return json['data']['url'];
      }
      return null;
    } catch (e) {
      throw Exception('Upload error: $e');
    }
  }
}