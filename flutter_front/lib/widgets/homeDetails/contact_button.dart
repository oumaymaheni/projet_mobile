import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user_model.dart'; // Import your User model

class ContactButton extends StatelessWidget {
  final Color primaryBlue;
  final String publisherId;

  const ContactButton({
    Key? key,
    required this.primaryBlue,
    required this.publisherId,
  }) : super(key: key);

  Future<User?> _fetchPublisherDetails() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(publisherId)
          .get();
      if (doc.exists) {
        return User.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching publisher details: $e');
      return null;
    }
  }

  Future<void> _showContactOptions(BuildContext context) async {
    final publisher = await _fetchPublisherDetails();
    if (publisher == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossible de récupérer les informations du propriétaire'),
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (publisher.phone.isNotEmpty && publisher.phone != 'Non renseigné')
              ListTile(
                leading: const Icon(Icons.phone),
                title: const Text('Appeler'),
                onTap: () {
                  Navigator.pop(context);
                  _makePhoneCall(publisher.phone);
                },
              ),
            if (publisher.email.isNotEmpty)
              ListTile(
                leading: const Icon(Icons.email),
                title: const Text('Envoyer un email'),
                onTap: () {
                  Navigator.pop(context);
                  _sendEmail(publisher.email);
                },
              ),
            ListTile(
              leading: const Icon(Icons.close),
              title: const Text('Annuler'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      throw 'Could not launch $launchUri';
    }
  }

  Future<void> _sendEmail(String email) async {
    final Uri launchUri = Uri(
      scheme: 'mailto',
      path: email,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      throw 'Could not launch $launchUri';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: ElevatedButton(
        onPressed: () => _showContactOptions(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text(
          'Contacter',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}