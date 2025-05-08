import 'package:flutter/material.dart';

class PostForm extends StatelessWidget {
  final TextEditingController localityController;
  final TextEditingController cityController;
  final TextEditingController stateController;
  final TextEditingController pinCodeController;
  final TextEditingController houseNoController;
  final TextEditingController societyController;

  const PostForm({
    super.key,
    required this.localityController,
    required this.cityController,
    required this.stateController,
    required this.pinCodeController,
    required this.houseNoController,
    required this.societyController,
  });

  @override
  Widget build(BuildContext context) {
    final Color kBlueColor = Colors.blue.shade700;

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ADDRESS',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: kBlueColor,
              ),
            ),
            const SizedBox(height: 12),
            _buildStyledField('Locality', localityController, kBlueColor),
            _buildStyledField('City', cityController, kBlueColor),
            _buildStyledField('State', stateController, kBlueColor),
            _buildStyledField('House No.', houseNoController, kBlueColor),
            _buildStyledField('Society Name', societyController, kBlueColor),
            _buildStyledField(
              'Pin-Code',
              pinCodeController,
              kBlueColor,
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStyledField(
    String label,
    TextEditingController controller,
    Color color, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: color),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: color, width: 2),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade400),
          ),
        ),
      ),
    );
  }
}
