// map_picker.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapPicker extends StatefulWidget {
  final void Function(LatLng) onLocationPicked;

  const MapPicker({super.key, required this.onLocationPicked});

  @override
  State<MapPicker> createState() => _MapPickerState();
}

class _MapPickerState extends State<MapPicker> {
  LatLng _pickedLocation = LatLng(37.7749, -122.4194); // San Francisco

  void _onTap(TapPosition tapPosition, LatLng latlng) {
    setState(() {
      _pickedLocation = latlng;
    });
    widget.onLocationPicked(latlng);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: FlutterMap(
        options: MapOptions(
          center: _pickedLocation,
          zoom: 13.0,
          onTap: _onTap,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: ['a', 'b', 'c'],
          ),
          MarkerLayer(
            markers: [
              Marker(
                width: 40,
                height: 40,
                point: _pickedLocation,
                child: const Icon(Icons.location_on, color: Colors.red, size: 40),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


// // map_picker.dart
// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';

// class MapPicker extends StatefulWidget {
//   final void Function(LatLng) onLocationPicked;

//   const MapPicker({super.key, required this.onLocationPicked});

//   @override
//   State<MapPicker> createState() => _MapPickerState();
// }

// class _MapPickerState extends State<MapPicker> {
//   LatLng _pickedLocation = const LatLng(37.7749, -122.4194); // Default to San Francisco

//   void _onTap(LatLng position) {
//     setState(() {
//       _pickedLocation = position;
//     });
//     widget.onLocationPicked(position);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       height: 300,
//       child: GoogleMap(
//         initialCameraPosition: CameraPosition(
//           target: _pickedLocation,
//           zoom: 14,
//         ),
//         onTap: _onTap,
//         markers: {
//           Marker(
//             markerId: const MarkerId('picked'),
//             position: _pickedLocation,
//           ),
//         },
//       ),
//     );
//   }
// }
