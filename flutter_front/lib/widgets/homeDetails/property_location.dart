import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../models/maison_models.dart';

class PropertyLocation extends StatelessWidget {
  final House house;

  const PropertyLocation({
    Key? key,
    required this.house,
  }) : super(key: key);

  void _showFullMap(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: EdgeInsets.zero,
          child: Stack(
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: _buildFullScreenMap(),
              ),
              Positioned(
                top: 40,
                left: 16,
                child: FloatingActionButton(
                  mini: true,
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.close, color: Colors.black),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Emplacement',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _showFullMap(context),
          child: Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(
                children: [
                  _buildMapPreview(),
                  const Center(
                    child: Icon(
                      Icons.location_on,
                      color: Colors.red,
                      size: 40,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMapPreview() {
    try {
      return FlutterMap(
        options: MapOptions(
          center: LatLng(house.latitude, house.longitude),
          zoom: 15.0,
          interactiveFlags: InteractiveFlag.none, // Disable interactions for preview
        ),
        children: [
          TileLayer(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: const ['a', 'b', 'c'],
          ),
        ],
      );
    } catch (e) {
      return Container(
        color: Colors.grey[200],
        child: const Center(child: Text("Carte non disponible")),
      );
    }
  }

  Widget _buildFullScreenMap() {
    try {
      return FlutterMap(
        options: MapOptions(
          center: LatLng(house.latitude, house.longitude),
          zoom: 16.0,
        ),
        children: [
          TileLayer(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: const ['a', 'b', 'c'],
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: LatLng(house.latitude, house.longitude),
                child: const Icon(
                  Icons.location_on,
                  color: Colors.red,
                  size: 40.0,
                ),
              ),
            ],
          ),
        ],
      );
    } catch (e) {
      return Container(
        color: Colors.grey[200],
        child: const Center(child: Text("Carte non disponible")),
      );
    }
  }
}