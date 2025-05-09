import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapPicker extends StatefulWidget {
  final LatLng? initialPosition;
  final Function(LatLng) onLocationPicked;
  
  const MapPicker({
    super.key,
    this.initialPosition,
    required this.onLocationPicked,
  });

  @override
  State<MapPicker> createState() => _MapPickerState();
}

class _MapPickerState extends State<MapPicker> {
  late final MapController _mapController;
  LatLng? _currentPosition;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _currentPosition = widget.initialPosition;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialPosition != null) {
        _mapController.move(widget.initialPosition!, 15);
      }
    });
  }

  @override
  void didUpdateWidget(MapPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_initialized && widget.initialPosition != null) {
      _mapController.move(widget.initialPosition!, 15);
      _initialized = true;
    }
  }

  void _handleTap(TapPosition tapPosition, LatLng latLng) {
    setState(() {
      _currentPosition = latLng;
    });
    widget.onLocationPicked(latLng);
    _mapController.move(latLng, _mapController.zoom);
  }

  @override
  Widget build(BuildContext context) {
    final defaultPosition = LatLng(36.8, 10.2); // Tunisie par défaut
    final displayPosition = _currentPosition ?? widget.initialPosition ?? defaultPosition;

    return SizedBox(
      height: 300,
      child: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          center: displayPosition,
          zoom: 15,
          onTap: _handleTap,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: ['a', 'b', 'c'],
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: displayPosition,
                width: 40,
                height: 40,
                child: const Icon(
                  Icons.location_pin,
                  color: Colors.red,
                  size: 40,
                ),
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
// import 'package:flutter_map/flutter_map.dart';
// import 'package:latlong2/latlong.dart';

// class MapPicker extends StatefulWidget {
//   final void Function(LatLng) onLocationPicked;
//   final LatLng? initialPosition;

//   const MapPicker({
//     super.key,
//     this.initialPosition,
//     required this.onLocationPicked,
//   });


//   @override
//   State<MapPicker> createState() => _MapPickerState();
// }

// class _MapPickerState extends State<MapPicker> {
//   LatLng _pickedLocation = LatLng(37.7749, -122.4194); // San Francisco
//   late LatLng? _selectedPosition;

//   @override
//   void initState() {
//     super.initState();
//     _selectedPosition = widget.initialPosition;
//   }
//   void _onTap(TapPosition tapPosition, LatLng latlng) {
//     setState(() {
//       _pickedLocation = latlng;
//     });
//     widget.onLocationPicked(latlng);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       height: 300,
//       child: FlutterMap(
//         options: MapOptions(
//           center: _pickedLocation,
//           zoom: 13.0,
//           onTap: _onTap,
//         ),
//         children: [
//           TileLayer(
//             urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
//             subdomains: ['a', 'b', 'c'],
//           ),
//           MarkerLayer(
//             markers: [
//               Marker(
//                 width: 40,
//                 height: 40,
//                 point: _pickedLocation,
//                 child: const Icon(Icons.location_on, color: Colors.red, size: 40),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

